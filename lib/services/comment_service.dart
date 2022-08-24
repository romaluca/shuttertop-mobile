import 'dart:async';
import 'package:shuttertop/misc/shuttertop.dart';
import 'package:shuttertop/misc/events.dart';
import 'package:shuttertop/models/comment.dart';
import 'package:shuttertop/models/contest.dart';
import 'package:shuttertop/models/entity_base.dart';
import 'package:shuttertop/models/user.dart';
import 'package:shuttertop/services/base_service.dart';

class CommentService extends BaseService implements CommentRepository {
  @override
  String get url => "/comments";

  @override
  Future<RequestListPage<Comment>> fetch(EntityBase element,
      {int page = 0}) async {
    final Map<String, dynamic> commentsContainer = await httpGet(
        params: <String, String>{
          element.fieldId: element.id.toString(),
          "page": page.toString()
        });
    final List<dynamic> commentItems = commentsContainer['comments'];
    return new RequestListPage<Comment>(
        commentItems
            .map((dynamic commentRaw) => new Comment.fromMap(commentRaw))
            .toList(),
        commentsContainer['total_entries']);
  }

  @override
  Future<bool> create(String body, EntityBase element) async {
    final String name =
        (element is Contest) ? "contest" : (element is User) ? "user" : "photo";
    final Map<String, dynamic> data = await httpPost(
        <String, dynamic>{'body': body, 'id': element.id, 'entity': name});
    final Comment comment = new Comment.fromMap(data);
    element.comments.add(comment);
    element.commentsCount += 1;
    shuttertop.eventBus.fire(CommentEvent(comment, element.uId));
    return true;
  }

  /*
  @override
  Future<Null> onNewComment(EntityBase element,
      Function(Map<String, dynamic> c) callback) async {
    final PhoenixSocket socket = await app.socket;
    if (socket.channels.containsKey(element.channelName))
      socket.channels[element.channelName].on("new_comment",
          (Map<dynamic, dynamic> resp, [String ref, String joinRef]) {
        print("on new comment $resp");
        callback(resp);
      });
  }

  @override
  Future<bool> join(EntityBase element, {Function onComment}) async {
    if (await addChannel(element.channelName)) {
      onNewComment(element, onComment);
      return true;
    }
    return false;
  }

  @override
  Future<Null> leave(EntityBase element) async {
    leaveChannel(element.channelName);
  }
  */
}
