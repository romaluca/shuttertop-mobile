import 'dart:async';
import 'package:meta/meta.dart';
import 'package:shuttertop/models/comment.dart';
import 'package:shuttertop/models/contest.dart';
import 'package:shuttertop/models/entity_base.dart';
import 'package:shuttertop/models/photo.dart';
import 'package:shuttertop/models/user.dart';
import 'package:shuttertop/services/base_service.dart';

class Topic {
  final int id;
  final Photo photo;
  final User user;
  final Contest contest;
  final User userTo;
  Comment lastComment;
  DateTime readAt;

  Topic(
      {@required this.id,
      this.contest,
      this.photo,
      this.user,
      this.userTo,
      this.lastComment,
      this.readAt});

  Topic.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        readAt = map['read_at'] != null ? DateTime.parse(map['read_at']) : null,
        user = map.containsKey("user") && map["user"] != null
            ? new User.fromMap(map['user'])
            : null,
        userTo = map.containsKey("user_to") && map["user_to"] != null
            ? new User.fromMap(map['user_to'])
            : null,
        contest = map.containsKey("contest") && map["contest"] != null
            ? new Contest.fromMap(map['contest'])
            : null,
        lastComment =
            map.containsKey("last_comment") && map["last_comment"] != null
                ? new Comment.fromMap(map['last_comment'])
                : null,
        photo = map.containsKey("photo") && map["photo"] != null
            ? new Photo.fromMap(map['photo'])
            : null {
    assert(id != null);
  }

  @override
  bool operator ==(dynamic o) =>
      identical(this, o) || (o is Comment && o.id == id);
  @override
  int get hashCode => id.hashCode;

  EntityBase getObject(int currentUserId) {
    if (photo != null)
      return photo;
    else if (contest != null)
      return contest;
    else if (user.id != currentUserId)
      return user;
    else
      return userTo;
  }

  String getName(int currentUserId) {
    if (photo != null)
      return "${photo.user.name} > ${contest.name}";
    else if (contest != null)
      return contest.name;
    else if (user.id != currentUserId)
      return user.name;
    else
      return userTo.name;
  }
}

abstract class TopicRepository {
  Future<RequestListPage<Topic>> fetch({int page = 0});
}
