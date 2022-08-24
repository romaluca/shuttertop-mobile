import 'dart:async';
import 'package:shuttertop/misc/events.dart';
import 'package:shuttertop/misc/shuttertop.dart';
import 'package:shuttertop/models/activity.dart';
import 'package:shuttertop/models/contest.dart';
import 'package:shuttertop/models/photo.dart';
import 'package:shuttertop/models/user.dart';
import 'package:shuttertop/services/base_service.dart';
import 'package:shuttertop/models/exceptions.dart';

class ActivityService extends BaseService implements ActivityRepository {
  static final String _notifiesUrl = "/notifies";

  @override
  String get url => "/activities";

  Map<String, dynamic> _getFetchParams(
      ActivityFetchType type, Map<String, String> params) {
    if (type == ActivityFetchType.score) params["type"] = "score";
    return params;
  }

  @override
  Future<RequestListPage<Activity>> fetch(
      {int page = 0,
      ActivityFetchType type = ActivityFetchType.all,
      dynamic element,
      bool notEmpty = false}) async {
    final Map<String, String> params = <String, String>{
      "page": page.toString()
    };
    if (element != null) {
      if (element is Contest)
        params["contest_id"] = element.id.toString();
      else if (element is Photo)
        params["photo_id"] = element.id.toString();
      else if (element is User) params["user_id"] = element.id.toString();
    }
    if (type == ActivityFetchType.notBooked) params["not_booked"] = "1";
    final Map<String, dynamic> activitiesContainer = await httpGet(
        params: _getFetchParams(type, params),
        getUrl: type == ActivityFetchType.notifies ||
                type == ActivityFetchType.score
            ? "${shuttertop.siteUrl}$_notifiesUrl"
            : null);
    final List<dynamic> activitieItems = activitiesContainer['activities'];
    if (page == 1 && activitiesContainer['total_entries'] == 0 && notEmpty)
      return new RequestListPage<Activity>(<Activity>[new Activity.blank()], 1);
    else
      return new RequestListPage<Activity>(
          activitieItems
              .map((dynamic activityRaw) => new Activity.fromMap(activityRaw))
              .toList(),
          activitiesContainer['total_entries']);
  }

  @override
  Future<bool> userFollow(User user) async {
    try {
      Map<String, String> data = <String, String>{
        'type': "follow",
        'entity': 'user'
      };
      if (user.followed)
        data = await httpDelete(params: data, id: user.id);
      else {
        data["id"] = user.id.toString();
        data = await httpPost(data);
      }
      user.followed = !user.followed;
      shuttertop.eventBus.fire(UserFollowEvent(user));
    } on ResponseErrorException catch (e) {
      print("ERRORE: userFollow $e");
      return false;
    } catch (e) {
      print("ERRORE: userFollow $e");
      return false;
    }
    return true;
  }

  @override
  Future<bool> contestFollow(Contest contest) async {
    try {
      Map<String, String> data = <String, String>{
        'type': "follow",
        'entity': 'contest'
      };
      if (contest.followed)
        data = await httpDelete(params: data, id: contest.id);
      else {
        data["id"] = contest.id.toString();
        data = await httpPost(data);
      }
      contest.followed = !contest.followed;
      shuttertop.eventBus.fire(ContestFollowEvent(contest));
    } on ResponseErrorException catch (e) {
      print("ERRORE: contestFollow $e");
      return false;
    } catch (e) {
      print("ERRORE: contestFollow $e");
      return false;
    }
    return true;
  }

  @override
  Future<bool> vote(Photo photo) async {
    try {
      Map<String, dynamic> data = <String, String>{
        'type': "vote",
      };
      if (photo.voted)
        data = await httpDelete(params: data, id: photo.id);
      else {
        data["id"] = photo.id.toString();
        data = await httpPost(data);
      }
      if (data.containsKey("status")) {
        return false;
      } else {
        photo.voted = !photo.voted;
        photo.position = data["position"];
        photo.votesCount = data["votes_count"];
        if (photo.voted)
          photo.tops.insert(0, shuttertop.currentSession.user);
        else
          photo.tops.remove(shuttertop.currentSession.user);
      }
      shuttertop.eventBus
          .fire(VoteEvent(photo, shuttertop.currentSession.user));
    } on ResponseErrorException catch (e) {
      print("ERRORE: vote $e");
      return false;
    } catch (e) {
      print("ERRORE: vote $e");
      return false;
    }
    return true;
  }
}
