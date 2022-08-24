import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:shuttertop/misc/s3.dart';
import 'package:shuttertop/misc/utils.dart';
import 'package:shuttertop/models/comment.dart';
import 'package:shuttertop/models/contest.dart';
import 'package:shuttertop/models/entity_base.dart';
import 'package:shuttertop/models/iphotoable.dart';
import 'package:shuttertop/models/user.dart';
import 'package:shuttertop/services/base_service.dart';

class Photo extends EntityBase {
  int votesCount;
  bool voted;
  int position;

  String model;
  double fNumber;
  String focalLength;
  int photographicSensitivity;
  double exposureTime;
  double lat;
  double lng;
  int width;
  int height;

  Contest contest;
  User user;
  List<User> tops;
  bool isWinner = false;

  static const List<String> imageFormats = const <String>[
    "",
    "960x960/",
    "500s500/",
    "260s260/"
  ];

  Photo(
      {this.model,
      this.fNumber,
      this.focalLength,
      this.photographicSensitivity,
      this.exposureTime,
      this.lat,
      this.lng,
      String name,
      String upload,
      this.contest,
      @required this.user,
      List<Comment> comments,
      int commentsCount,
      this.tops,
      @required int id,
      @required String slug})
      : super(
            id: id,
            name: name,
            slug: slug,
            upload: upload,
            commentsCount: commentsCount,
            comments: comments) {
    comments ??= <Comment>[];
    tops ??= <User>[];
  }

  Photo.fromMap(Map<String, dynamic> map,
      [Map<String, dynamic> mapUser,
      List<dynamic> mapComments,
      List<dynamic> mapTops])
      : votesCount = map['votes_count'],
        model = map['model'],
        fNumber = map['f_number'],
        focalLength = map['focal_length'],
        photographicSensitivity = map['photographic_sensitivity'],
        width = map['width'],
        height = map['height'],
        lat = map['lat'],
        lng = map['lng'],
        exposureTime = map['exposure_time'],
        position = map['position'],
        isWinner = map['is_winner'] ?? false,
        voted = map['voted'],
        user = mapUser != null
            ? new User.fromMap(mapUser)
            : (map.containsKey('user') && map["user"] != null
                ? new User.fromMap(map['user'])
                : null),
        contest = map.containsKey('contest') && map["contest"] != null
            ? new Contest.fromMap(map['contest'])
            : null,
        tops = mapTops != null
            ? mapTops
                ?.map((dynamic topRaw) => new User.fromMap(topRaw))
                ?.toList()
            : <User>[],
        super.fromMap(map, mapComments) {
    assert(id != null);
  }

  void refresh(Map<String, dynamic> map,
      [Map<String, dynamic> mapUser,
      List<dynamic> mapComments,
      List<dynamic> mapTops]) {
    assert(map != null);
    name = map['name'];
    votesCount = map['votes_count'];
    commentsCount = map['comments_count'];
    position = map['position'];
    isWinner = map['is_winner'] ?? false;
    model = map['model'];
    fNumber = map['f_number'];
    focalLength = map['focal_length'];
    photographicSensitivity = map['photographic_sensitivity'];
    width = map['width'];
    height = map['height'];
    lat = map['lat'];
    lng = map['lng'];
    exposureTime = map['exposure_time'];
    voted = map['voted'];
    if (mapUser != null) {
      if (user == null)
        user = User.fromMap(mapUser);
      else
        user.refresh(mapUser);
    } else if (map.containsKey('user') && map["user"] != null) {
      if (user == null)
        user = User.fromMap(map['user']);
      else
        user.refresh(map['user']);
    }
    if (map.containsKey('contest') && map["contest"] != null) {
      if (contest == null)
        contest = Contest.fromMap(map['contest']);
      else
        contest.refresh(map['contest']);
    }
    tops.clear();
    tops.addAll(mapTops != null
        ? mapTops?.map((dynamic topRaw) => new User.fromMap(topRaw))?.toList()
        : <User>[]);
    comments.clear();
    comments.addAll(mapComments != null
        ? mapComments
            ?.map((dynamic commentRaw) => new Comment.fromMap(commentRaw))
            ?.toList()
        : <Comment>[]);
  }

  @override
  String getImageUrl(ImageFormat size) {
    return "${Utils.imageBaseUrl}${imageFormats[size.index]}$upload";
  }

  double getImageHeight(BuildContext context) {
    try {
      final double photoHeight = height != null
          ? MediaQuery.of(context).size.width * height / width
          : null;
      return photoHeight;
    } catch (error, stackTrace) {
      FlutterError.reportError(
          FlutterErrorDetails(exception: error, stack: stackTrace));
      return 0.0;
    }
  }

  @override
  bool operator ==(dynamic o) =>
      identical(this, o) || (o is Photo && o.id == id);
  @override
  int get hashCode => id.hashCode;

  @override
  String get fieldId => "photo_id";

  @override
  String get uId => "p_$id";

  @override
  String get channelName => "photo:$id";
}

enum PhotosFetchType { all, wins, inProgress }

abstract class PhotoRepository {
  Future<RequestListPage<Photo>> fetch(IPhotoable element,
      {ListOrder order = ListOrder.news,
      int page = 0,
      PhotosFetchType type = PhotosFetchType.all});
  Future<RequestListPage<Photo>> fetchByParams(Map<String, dynamic> params);
  Future<Photo> get(String slug, {Photo photo});
  Future<RequestListPage<Photo>> fetchLeaders(Contest contest, {int page = 0});
  Future<Photo> create(File imageFile, int contestId, S3 s3);
  /*Future<bool> vote(Photo photo, ChannelResult callback);
  void onVote(Photo photo, ChannelResult callback);
  Future<bool> join(Photo photo, {ChannelResult onVoted, Function onComment});
  Future<Null> leave(Photo photo);*/
  Future<bool> report(Photo photo, String message);
  Future<bool> delete(Photo photo);
}
