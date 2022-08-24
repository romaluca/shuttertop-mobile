import 'package:shuttertop/misc/utils.dart';
import 'package:shuttertop/models/comment.dart';

abstract class EntityBase {
  final int id;
  String name;
  String upload;
  String slug;
  int commentsCount;
  List<Comment> comments;

  EntityBase(
      {this.id,
      this.name,
      this.slug,
      this.upload,
      this.comments,
      this.commentsCount});

  EntityBase.fromMap(Map<String, dynamic> map, [List<dynamic> mapComments])
      : upload = map['upload'],
        id = map['id'],
        name = map['name'],
        commentsCount = map['comments_count'] ?? 0,
        comments = mapComments != null
            ? mapComments
                ?.map((dynamic commentRaw) => new Comment.fromMap(commentRaw))
                ?.toList()
            : <Comment>[],
        slug = map['slug'] {
    assert(id != null);
  }
  String getImageUrl(ImageFormat size);
  String get fieldId;
  String get uId;
  String get channelName;
}
