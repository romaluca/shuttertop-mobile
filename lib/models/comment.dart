import 'dart:async';
import 'package:meta/meta.dart';
import 'package:shuttertop/models/entity_base.dart';
import 'package:shuttertop/models/photo.dart';
import 'package:shuttertop/models/user.dart';
import 'package:shuttertop/services/base_service.dart';

class Comment {
  final int id;
  final String body;
  final Photo photo;
  final User user;
  final DateTime insertedAt;

  const Comment(
      {@required this.id,
      this.body,
      this.photo,
      @required this.user,
      this.insertedAt});

  Comment.fromMap(Map<dynamic, dynamic> map)
      : id = map['id'],
        body = map['body'],
        insertedAt = DateTime.parse(map['inserted_at']),
        user = map.containsKey("user") && map["user"] != null
            ? new User.fromMap(map['user'])
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
}

abstract class CommentRepository {
  Future<RequestListPage<Comment>> fetch(EntityBase element, {int page = 0});

  Future<bool> create(String body, EntityBase element);
  /*
  void onNewComment(
      EntityBase element, Function(Map<String, dynamic> c) callback);
  Future<bool> join(EntityBase element, {Function onComment});
  Future<Null> leave(EntityBase element);*/
}
