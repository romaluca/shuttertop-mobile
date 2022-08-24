import 'dart:async';

import 'package:meta/meta.dart';
import 'package:shuttertop/misc/utils.dart';
import 'package:shuttertop/models/comment.dart';
import 'package:shuttertop/models/contest.dart';
import 'package:shuttertop/models/entity_base.dart';
import 'package:shuttertop/models/photo.dart';
import 'package:shuttertop/models/user.dart';
import 'package:shuttertop/services/base_service.dart';

enum activityType {
  followUser,
  followContest,
  contestCreated,
  firstAvatar,
  commentedPhoto,
  joined,
  signup,
  vote,
  win,
  followPhoto,
  commentedContest,
  commentedUser
}

List<String> actions = <String>[
  "segue",
  "segue",
  "ha creato",
  "ha la sua prima immagine di profilo",
  "ha commentato una foto in",
  "partecipa a",
  "si è registrato",
  "ha votato",
  "ha vinto",
  "segue",
  "ha commentato il contest",
  "",
];

List<String> actionsYou = <String>[
  "Segui",
  "Segue",
  "Hai creato",
  "Hai la tua prima immagine di profilo",
  "Hai commentato una foto in",
  "Partecipi a",
  "Ti sei registrato",
  "Hai votato una foto in",
  "Hai vinto",
  "Segui",
  "Hai commentato un contest",
  "Hai scritto a"
];

List<String> actionsMe = <String>[
  "ti segue",
  "segue il tuo contest",
  "",
  "",
  "ha commentato una tua foto in",
  "partecipa a",
  "",
  "ha votato una tua foto in",
  "Hai vinto",
  "Segue una tua foto",
  "Ha commentato il tuo contest",
  "Ti ha scritto"
];

class Activity {
  final int id;
  final int points;
  final activityType type;
  final User userTo;
  final Photo photo;
  final Contest contest;
  final User user;
  final Comment comment;
  final DateTime insertedAt;

  const Activity(
      {@required this.id,
      this.points,
      this.type,
      this.userTo,
      this.photo,
      this.contest,
      this.user,
      this.comment,
      this.insertedAt});

  Activity.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        points = map['points'],
        type = activityType.values[map['type']],
        insertedAt = DateTime.parse(map['inserted_at']),
        contest = map.containsKey('contest') && map["contest"] != null
            ? new Contest.fromMap(map['contest'])
            : null,
        user = map.containsKey("user") && map["user"] != null
            ? new User.fromMap(map['user'])
            : null,
        userTo = map.containsKey("user_to") && map["user_to"] != null
            ? new User.fromMap(map['user_to'])
            : null,
        comment = map.containsKey("comment") && map["comment"] != null
            ? new Comment.fromMap(map['comment'])
            : null,
        photo = map.containsKey("photo") && map["photo"] != null
            ? new Photo.fromMap(map['photo'])
            : null {
    assert(id != null);
  }

  Activity.blank()
      : id = -1,
        points = 0,
        type = null,
        insertedAt = null,
        contest = null,
        user = null,
        userTo = null,
        comment = null,
        photo = null;

  String getActionName(User currentUser) {
    if (currentUser?.id == user?.id && currentUser?.id == userTo?.id)
      return "${actionsYou[type.index]} ";
    if (currentUser?.id == userTo?.id) return " ${actionsMe[type.index]} ";
    if (currentUser?.id == user?.id)
      return "${actionsYou[type.index]} ";
    else
      return " ${actions[type.index]} ";
  }

  String getObjectName(User currentUser) {
    switch (type) {
      case activityType.joined:
      case activityType.contestCreated:
      case activityType.win:
      case activityType.followContest:
      case activityType.commentedPhoto:
      case activityType.commentedContest:
      case activityType.vote:
        return contest?.name;
      case activityType.followUser:
      case activityType.commentedUser:
      case activityType.firstAvatar:
        if (currentUser?.id == userTo?.id)
          return "";
        else
          return userTo?.name;
        break;
      default:
        return userTo?.name;
    }
  }

  EntityBase getSubject() {
    switch (type) {
      case activityType.joined:
        return photo;
      case activityType.contestCreated:
      case activityType.win:
      case activityType.followContest:
        return contest;
      case activityType.commentedPhoto:
      case activityType.vote:
        return photo;
      case activityType.followUser:
      case activityType.commentedUser:
        return user;
        break;
      default:
        return userTo;
    }
  }

  EntityBase getObject() {
    switch (type) {
      case activityType.joined:
      case activityType.contestCreated:
      case activityType.win:
      case activityType.followContest:
      case activityType.commentedPhoto:
      case activityType.vote:
        return contest;
      case activityType.followUser:
        return userTo;
        break;
      default:
        return userTo;
    }
  }

  String getImageUrl() {
    return type == activityType.joined ||
            type == activityType.commentedPhoto ||
            type == activityType.vote
        ? photo?.getImageUrl(ImageFormat.thumb_small)
        : contest?.getImageUrl(ImageFormat.thumb_small);
  }

  @override
  bool operator ==(dynamic o) =>
      identical(this, o) || (o is Activity && o.id == id);
  @override
  int get hashCode => id.hashCode;
}

enum ActivityFetchType { all, notifies, score, notBooked }

abstract class ActivityRepository {
  Future<RequestListPage<Activity>> fetch(
      {int page = 0,
      ActivityFetchType type = ActivityFetchType.all,
      dynamic element,
      bool notEmpty = false});
  Future<bool> userFollow(User user);
  Future<bool> contestFollow(Contest contest);
  Future<bool> vote(Photo photo);
}
