import 'dart:async';
import 'dart:io';
import 'package:exif_flutter/exif_flutter.dart';
import 'package:shuttertop/misc/shuttertop.dart';
import 'package:shuttertop/misc/events.dart';
import 'package:shuttertop/misc/s3.dart';
import 'package:shuttertop/models/contest.dart';
import 'package:shuttertop/services/base_service.dart';
import 'package:shuttertop/models/iphotoable.dart';
import 'package:shuttertop/models/photo.dart';
import 'package:shuttertop/misc/utils.dart';

class PhotoService extends BaseService implements PhotoRepository {
  @override
  String get url => "/photos";
  static final String presignUrl = "/presign_upload/photo";

  @override
  Future<RequestListPage<Photo>> fetchByParams(
      Map<String, dynamic> params) async {
    final Map<String, dynamic> photosContainer = await httpGet(params: params);
    final List<dynamic> photoItems = photosContainer['photos'];
    print("photoItems: $photoItems");
    return new RequestListPage<Photo>(
        photoItems
            .map((dynamic photoRaw) => new Photo.fromMap(photoRaw))
            .toList(),
        photosContainer['total_entries']);
  }

  Map<String, String> _getTypeFetch(PhotosFetchType type) {
    switch (type) {
      case PhotosFetchType.inProgress:
        return <String, String>{"type": "in_progress"};
      case PhotosFetchType.wins:
        return <String, String>{"type": "wins"};
      default:
        return <String, String>{};
    }
  }

  @override
  Future<RequestListPage<Photo>> fetch(IPhotoable element,
      {ListOrder order = ListOrder.news,
      int page = 0,
      PhotosFetchType type = PhotosFetchType.all}) async {
    final Map<String, String> params = _getTypeFetch(type);
    if (order == ListOrder.top)
      params['order'] = "top";
    else
      params['order'] = "news";
    params.addAll(<String, String>{
      "page": page.toString(),
      element.fieldId: element.id.toString()
    });
    return fetchByParams(params);
  }

  @override
  Future<RequestListPage<Photo>> fetchLeaders(Contest contest,
      {int page = 0}) async {
    return fetch(contest, order: ListOrder.top, page: page);
  }

  @override
  Future<Photo> create(File imageFile, int contestId, S3 s3) async {
    final String now = new DateTime.now()
        .toIso8601String()
        .replaceAll(":", "")
        .replaceAll("-", "")
        .substring(0, 15);
    final String photoName = "${now}_P_$contestId.jpg";
    try {
      print("-------------------before upload");
      Map<String, dynamic> data = <String, dynamic>{};
      try {
        data = await readExifFromFile(imageFile, true) ?? <String, dynamic>{};
      } catch (ex) {
        print(ex);
      }
      print("-------------------after read exif: $data ");
      //List<int> imgBytes = imageFile.readAsBytesSync();
      print("-------------------after read bytes");
      if (await presign(contestId, "photo", now)) {
        await s3.upload(imageFile.readAsBytesSync(), photoName);
        print("after upload");
        final int dimWidth = data["ImageWidth"] ?? data["PixelXDimension"];
        final int dimHeight = data["ImageHeight"] ?? data["PixelYDimension"];
        final Rational fNumber = data["FNumber"];
        final Rational exposureTime = data["ExposureTime"];
        final Rational photographicSensitivity = data["SpectralSensitivity"];
        final Rational focalLength = data["FocalLength"];
        final int height = data["Orientation"] == 6 || data["Orientation"] == 8
            ? dimWidth
            : dimHeight;
        final int width = data["Orientation"] == 6 || data["Orientation"] == 8
            ? dimHeight
            : dimWidth;

        print(
            "exiffff: $data - fNumber: $fNumber - exposureTime: $exposureTime - photographicSensitivity: $photographicSensitivity - focalLength: $focalLength");
        print("lat: ${data["GPSLatitude"]}");
        final String model = (data["Make"] ?? "") + " " + (data["Model"] ?? "");

        final Photo p = new Photo.fromMap(await httpPost(<String, dynamic>{
          "photo": <String, dynamic>{
            "contest_id": contestId,
            "upload": photoName,
            "width": width,
            "height": height,
            "model": model.trim().isEmpty ? null : model,
            "f_number": fNumber?.toDouble(),
            "photographic_sensitivity": photographicSensitivity?.toDouble(),
            "exposure_time": exposureTime?.toDouble(),
            "focal_length":
                focalLength != null ? focalLength.toDouble().toString() : null,
            "lat": gps(data["GPSLatitude"], data["GPSLatitudeRef"]),
            "lng": gps(data["GPSLongitude"], data["GPSLongitudeRef"])
          }
        }));
        shuttertop.eventBus.fire(PhotoEvent(p));
        /*
      bool imageUploaded = false;
      while (!imageUploaded) {
        imageUploaded =
            await checkStatusGetUrl(p.getImageUrl(ImageFormat.normal));
        if (!imageUploaded) sleep(const Duration(milliseconds: 300));
      }*/

        return p;
      }
    } catch (e) {
      print("addPhoto error: $e");
    }
    return null;
  }

  double gps(dynamic coordinate, dynamic hemisphere) {
    final List<double> coord = <double>[0.0, 0.0, 0.0];
    try {
      if (coordinate == null || hemisphere == null) return null;
      if (coordinate is String) {
        //String s = coordinate;
        //coordinate = s.trim(",").map((e) => e.toString().trim());
      }
      for (int i = 0; i < 3; i++) {
        final List<String> part = coordinate[i].toString().split("/");
        if (part.length == 1) {
          coord[i] = double.parse(part[0]);
        } else if (part.length == 2) {
          coord[i] = double.parse(part[0]) / double.parse(part[1]);
        } else {
          coord[i] = 0.0;
        }
      }
      final double degrees = coord[0];
      final int minutes = coord[1].truncate();
      final int seconds = coord[2].truncate();
      final int sign = (hemisphere == 'W' || hemisphere == 'S') ? -1 : 1;
      return sign * (degrees + (minutes / 60) + (seconds / 3600));
    } catch (ex) {
      print("ERRORE - photo_service.gps $ex");
    }
    return null;
  }

  @override
  Future<Photo> get(String slug, {Photo photo}) async {
    final Map<String, dynamic> photoContainer = await httpGet(id: slug);
    if (photo != null) {
      photo.refresh(photoContainer['photo'], photoContainer['user'],
          photoContainer['comments'], photoContainer['tops']);
      return photo;
    } else
      return new Photo.fromMap(photoContainer['photo'], photoContainer['user'],
          photoContainer['comments'], photoContainer['tops']);
  }

  /*@override
  Future<bool> vote(Photo photo, ChannelResult callback) async {
    final Map<String, dynamic> payload = <String, dynamic>{
      "type": photo.voted ? "0" : "1",
      "photo_id": photo.id
    };
    print("vote $payload");
    (await app.userChannel).push("vote", payload).receive("error",
        (Map<dynamic, dynamic> res, [String ref, String joinRef]) {
      print("vote error $res");
      if (res["status"] == ResponseStatus.Expired.index)
        callback(ResponseStatus.Expired, res);
      callback(ResponseStatus.Error, res);
    }).receive("ok", (Map<dynamic, dynamic> resp,
        [String ref, String joinRef]) {
      print("vote ok $resp");
      photo.voted = resp["voted"];
      photo.position = resp["position"];
      photo.votesCount = resp["votes_count"];
      if (photo.voted)
        photo.tops.insert(0, app.currentSession.user);
      else
        photo.tops.remove(app.currentSession.user);
      callback(ResponseStatus.Ok);
    });
    return true;
  }

  @override
  Future<Null> onVote(Photo photo, ChannelResult callback) async {
    final PhoenixSocket socket = await app.socket;
    if (socket.channels.containsKey(photo.channelName))
      socket.channels[photo.channelName].on("vote", (Map<dynamic, dynamic> resp,
          [String ref, String joinRef]) {
        print("on vote $resp");
        photo.position = resp["position"];
        photo.votesCount = resp["votes_count"];
        if (photo.voted) {
          if (!photo.tops.any((User user) => user.id == app.currentUserId))
            photo.tops.add(app.currentSession.user);
        } else
          photo.tops.removeWhere((User user) => user.id == app.currentUserId);
        callback(ResponseStatus.Ok);
      });
  }


  @override
  Future<bool> join(Photo photo,
      {ChannelResult onVoted, Function onComment}) async {
    final PhoenixSocket socket = await app.socket;
    if (await addChannel(photo.channelName)) {
      socket.channels[photo.channelName].on("new_comment",
          (Map<dynamic, dynamic> resp, [String ref, String joinRef]) {
        print("on new comment $resp");
        if (onComment != null) onComment(resp);
      });
      if (onVoted != null) onVote(photo, onVoted);
      return true;
    }
    return false;
  }

  @override
  Future<Null> leave(Photo photo) async {
    leaveChannel(photo.channelName);
  }*/

  @override
  Future<bool> report(Photo photo, String message) async {
    final Map<String, dynamic> payload = <String, dynamic>{
      "message": message,
      "id": photo.slug
    };
    await httpPost(payload, postUrl: "${shuttertop.siteUrl}/photos/report");
    return true;
  }

  @override
  Future<bool> delete(Photo photo) async {
    await httpDelete(id: photo.slug);
    shuttertop.eventBus.fire(PhotoDeleteEvent(photo.id));
    return true;
  }
}
