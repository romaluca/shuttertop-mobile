import 'dart:async';
import 'dart:io';
import 'package:shuttertop/misc/events.dart';
import 'package:shuttertop/misc/s3.dart';
import 'package:shuttertop/misc/shuttertop.dart';
import 'package:shuttertop/models/contest.dart';
import 'package:shuttertop/services/base_service.dart';
import 'package:shuttertop/misc/utils.dart';

class ContestService extends BaseService implements ContestRepository {
  @override
  String get url => "/contests";

  Map<String, String> _getTypeFetch(ContestFetchType type) {
    switch (type) {
      case ContestFetchType.joined:
        return <String, String>{"type": "joined"};
      case ContestFetchType.following:
        return <String, String>{"type": "following", "all": "1"};
      default:
        return <String, String>{};
    }
  }

  @override
  Future<RequestListPage<Contest>> fetch(
      {Category category,
      bool inProgress,
      ListOrder order = ListOrder.news,
      int page = 0,
      int pageSize,
      int limit,
      String search,
      int userId,
      ContestFetchType type = ContestFetchType.all}) async {
    final Map<String, String> params = _getTypeFetch(type);
    params["order"] = listOrders[order.index];
    params["page"] = page.toString();
    if (pageSize != null) params["page_size"] = pageSize.toString();
    if (limit != null) params["limit"] = limit.toString();
    if (userId != null) {
      params["user_id"] = userId.toString();
      params["all"] = "1";
    }

    if (search != null) params["search"] = search.toString();
    if (category != null && category.id != 0)
      params["category_id"] = category.id.toString();
    if (inProgress != null && !inProgress) params["expired"] = "true";

    final Map<String, dynamic> contestsContainer =
        await httpGet(params: params);
    final List<dynamic> contestItems = contestsContainer['contests'];
    return new RequestListPage<Contest>(
        contestItems
            .map((dynamic contestRaw) => new Contest.fromMap(contestRaw))
            .toList(),
        contestsContainer['total_entries']);
  }

  @override
  Future<Contest> get(String slug, {Contest contest}) async {
    final Map<String, dynamic> contestContainer = await httpGet(id: slug);
    if (contest != null) {
      contest.refresh(
          contestContainer['contest'],
          contestContainer['photos'],
          contestContainer['photos_user'],
          contestContainer['followers'],
          contestContainer['leaders'],
          contestContainer['comments'],
          contestContainer['user']);
      return contest;
    } else
      return new Contest.fromMap(
          contestContainer['contest'],
          contestContainer['photos'],
          contestContainer['photos_user'],
          contestContainer['followers'],
          contestContainer['leaders'],
          contestContainer['comments'],
          contestContainer['user']);
  }

  /*@override
  Future<bool> follow(Contest contest, ChannelResult callback) async {
    final Map<String, dynamic> payload = <String, dynamic>{
      "type": !contest.followed ? "1" : "0",
      "id": contest.id
    };
    print("contest_follow $payload");
    (await app.userChannel).push("contest_follow", payload).receive("error",
        (Map<dynamic, dynamic> res, [String ref, String joinRef]) {
      print("follow error $res");
      callback(ResponseStatus.Error, res);
    }).receive("ok", (Map<dynamic, dynamic> resp,
        [String ref, String joinRef]) {
      contest.followed = resp["followed"];
      if (contest.followed)
        contest.followers.insert(0, app.currentSession.user);
      else
        contest.followers.remove(app.currentSession.user);
      contest.followersCount = resp["followers_count"];
      callback(ResponseStatus.Ok);
      print("follow ok $resp");
    });
    /*
    socket.channels[0].on("contest_follow", (Map resp, [ref, joinRef]) {
      print("on contest_follow $resp");
      callback(resp);
    });*/
    return true;
  }*/

  @override
  Future<bool> addCover(File imageFile, Contest contest, S3 s3) async {
    final String now = new DateTime.now()
        .toIso8601String()
        .replaceAll(":", "")
        .replaceAll("-", "")
        .substring(0, 15);
    final String coverName = "${now}_C_${contest.id}.jpg";
    try {
      if (await presign(contest.id, "contest", now)) {
        await s3.upload(imageFile.readAsBytesSync(), coverName);
        print("after upload");

        final Contest c =
            Contest.fromMap(await httpPut(contest.id, <String, dynamic>{
          "contest": <String, dynamic>{
            "upload": coverName,
          }
        }));
        contest.upload = c.upload;

        return true;
      } else
        return false;
    } catch (e) {
      print("addCover error: $e");
      return false;
    }
  }

  @override
  Future<bool> delete(int id) async {
    await httpDelete(id: id);
    shuttertop.eventBus.fire(new ContestDeleteEvent(id));
    return true;
  }

  @override
  Future<ResponseApi<Contest>> edit(int id, String name, DateTime expiryAt,
      String description, int categoryId) async {
    final Map<String, dynamic> data = await httpPut(id, <String, dynamic>{
      'contest': <String, dynamic>{
        'name': name,
        'description': description,
        'category_id': categoryId,
        'expiry_at': expiryAt.toIso8601String(),
      }
    });
    final ResponseApi<Contest> ret =
        new ResponseApi<Contest>(!data.containsKey("errors"));
    if (ret.success) {
      ret.element = new Contest.fromMap(data);
      shuttertop.eventBus.fire(ContestEvent(ret.element));
    } else
      ret.errors = data["errors"];
    return ret;
  }

  @override
  Future<ResponseApi<Contest>> create(String name, DateTime startAt,
      DateTime expiryAt, String description, int categoryId) async {
    final Map<String, dynamic> data = await httpPost(<String, dynamic>{
      'contest': <String, dynamic>{
        'name': name,
        'description': description,
        'category_id': categoryId,
        'expiry_at': expiryAt.toIso8601String(),
        //'start_at': startAt
      }
    });
    final ResponseApi<Contest> ret =
        new ResponseApi<Contest>(!data.containsKey("errors"));
    if (ret.success) {
      ret.element = new Contest.fromMap(data);
      shuttertop.eventBus.fire(ContestEvent(ret.element));
    } else
      ret.errors = data["errors"];
    return ret;
  }
/*
  Future<Null> onVote(Contest contest, ChannelResult callback) async {
    final PhoenixSocket socket = await app.socket;
    if (socket.channels.containsKey(contest.channelName))
      socket.channels[contest.channelName].on("vote",
          (Map<dynamic, dynamic> resp, [String ref, String joinRef]) {
        print("on vote $resp");
        final Photo photo =
            contest.photos.firstWhere((Photo p) => p.id == resp["photo_id"]);
        if (photo != null) {
          photo.position = resp["position"];
          photo.votesCount = resp["votes_count"];
        }
        callback(ResponseStatus.Ok);
      });
  }

  @override
  Future<bool> join(Contest contest,
      {ChannelResult onVoted, Function onComment}) async {
    if (await addChannel(contest.channelName) && onVote != null) {
      onVote(contest, onVoted);
      return true;
    }
    return false;
  }

  @override
  Future<Null> leave(Contest contest) async {
    print("exit channel ${contest.channelName}");
    leaveChannel(contest.channelName);
  }*/
}
