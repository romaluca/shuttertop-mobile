import 'dart:async';
import 'dart:io';
import 'package:meta/meta.dart';
import 'package:shuttertop/misc/s3.dart';
import 'package:shuttertop/misc/utils.dart';
import 'package:shuttertop/models/comment.dart';
import 'package:shuttertop/models/contest.dart';
import 'package:shuttertop/models/entity_base.dart';
import 'package:shuttertop/models/iphotoable.dart';
import 'package:shuttertop/models/photo.dart';
import 'package:shuttertop/services/base_service.dart';

class User extends EntityBase implements IPhotoable {
  int winnerCount;
  int score;
  int scorePartial;
  @override
  int photosCount;
  int followersCount;
  int followsUserCount;
  int followsContestCount;
  int contestCount;
  int inProgress;
  bool followed;
  String language;

  @override
  List<Photo> photos;
  Photo bestPhoto;
  List<User> followers;
  List<User> follows;
  List<Contest> contests;

  static const List<String> imageFormats = const <String>[
    "",
    "",
    "300s300/",
    "70s70/"
  ];

  User(
      {this.photos,
      this.followers,
      this.follows,
      this.contests,
      this.bestPhoto,
      this.followersCount,
      this.followsUserCount,
      this.followsContestCount,
      this.contestCount,
      List<Comment> comments,
      int commentsCount,
      this.inProgress,
      @required int id,
      String slug,
      String upload,
      String name})
      : super(
            id: id,
            name: name,
            slug: slug,
            upload: upload,
            comments: comments,
            commentsCount: commentsCount) {
    photos ??= <Photo>[];
    followers ??= <User>[];
    follows ??= <User>[];
    comments ??= <Comment>[];
    contests ??= <Contest>[];
  }

  User.fromMap(
    Map<String, dynamic> map, [
    List<dynamic> mapPhotos,
    List<dynamic> mapFollow,
    List<dynamic> mapFollowers,
    List<dynamic> mapContests,
    List<dynamic> mapComments,
    Map<String, dynamic> mapBestPhoto,
  ])  : winnerCount = map['winner_count'],
        score = map['score'] ?? 0,
        scorePartial = map['score_partial'] ?? 0,
        photosCount = map['photos_count'],
        inProgress = map['in_progress'] ?? 0,
        language = map['language'] ?? "en",
        photos = mapPhotos != null
            ? mapPhotos
                ?.map((dynamic photoRaw) => new Photo.fromMap(photoRaw))
                ?.toList()
            : <Photo>[],
        follows = mapFollow != null
            ? mapFollow
                ?.map((dynamic userRaw) => new User.fromMap(userRaw))
                ?.toList()
            : <User>[],
        followers = mapFollowers != null
            ? mapFollowers
                ?.map((dynamic userRaw) => new User.fromMap(userRaw))
                ?.toList()
            : <User>[],
        bestPhoto =
            (mapBestPhoto != null ? new Photo.fromMap(mapBestPhoto) : null),
        followersCount = map["followers_count"] ?? 0,
        followsUserCount = map["follows_user_count"] ?? 0,
        followsContestCount = map["follows_contest_count"] ?? 0,
        contestCount = map["contest_count"] ?? 0,
        contests = mapContests != null
            ? mapContests
                ?.map((dynamic contestRaw) => new Contest.fromMap(contestRaw))
                ?.toList()
            : <Contest>[],
        followed = map['followed'],
        super.fromMap(map, mapComments) {
    assert(id != null);
  }

  @override
  String get channelName => "user:$id";

  @override
  String get fieldId => "user_id";

  @override
  String get uId => "u_$id";

  @override
  bool operator ==(dynamic o) =>
      identical(this, o) || (o is User && o.id == id);
  @override
  int get hashCode => id.hashCode;

  void refresh(Map<String, dynamic> map,
      [List<dynamic> mapPhotos,
      List<dynamic> mapFollow,
      List<dynamic> mapFollowers,
      List<dynamic> mapContests,
      Map<String, dynamic> mapBestPhoto]) {
    assert(map != null);

    name = map['name'];
    slug = map['slug'];
    upload = map['upload'];
    winnerCount = map['winner_count'];
    score = map['score'] ?? 0;
    scorePartial = scorePartial != null && scorePartial > 0
        ? scorePartial
        : (map['score_partial'] ?? 0);
    photosCount = map['photos_count'];
    inProgress = map['in_progress'];
    language = map['language'] ?? "en";
    photos.clear();
    photos.addAll(mapPhotos != null
        ? mapPhotos
            ?.map((dynamic photoRaw) => new Photo.fromMap(photoRaw))
            ?.toList()
        : <Photo>[]);
    follows.clear();
    follows.addAll(mapFollow != null
        ? mapFollow
            ?.map((dynamic userRaw) => new User.fromMap(userRaw))
            ?.toList()
        : <User>[]);
    followers.clear();
    followers.addAll(mapFollowers != null
        ? mapFollowers
            ?.map((dynamic userRaw) => new User.fromMap(userRaw))
            ?.toList()
        : <User>[]);
    contests.clear();
    contests.addAll(mapContests != null
        ? mapContests
            ?.map((dynamic contestRaw) => new Contest.fromMap(contestRaw))
            ?.toList()
        : <Contest>[]);
    followersCount = map["followers_count"] ?? 0;
    followsUserCount = map["follows_user_count"] ?? 0;
    contestCount = map["contest_count"] ?? 0;
    followed = map['followed'];
    bestPhoto = (mapBestPhoto != null ? new Photo.fromMap(mapBestPhoto) : null);
  }

  @override
  String getImageUrl(ImageFormat size) {
    if (upload != null)
      return "${Utils.imageBaseUrl}${imageFormats[size.index]}$upload";
    else
      return "${Utils.imageBaseUrl}no_image/user.png";
  }

  static String getImageUrlFromUpload(String upload, ImageFormat size) {
    if (upload != null)
      return "${Utils.imageBaseUrl}${imageFormats[size.index]}$upload";
    else
      return "${Utils.imageBaseUrl}no_image/user.png";
  }
}

abstract class UserRepository {
  Future<RequestListPage<User>> fetch(
      {ListUserType type = ListUserType.score,
      UserListItemFormat filterType = UserListItemFormat.normal,
      EntityBase element,
      int page = 0,
      String search});
  Future<ResponseApi<User>> create(String name, String email, String password);
  Future<bool> edit(int id, {String name, String email, String language});
  Future<User> get(String slug, {User user});
  //Future<bool> follow(User user, ChannelResult callback);
  Future<bool> addImage(User user, File imageFile, S3 s3);
  /*Future<bool> join(User user, {ChannelResult onVoted, Function onComment});
  Future<Null> leave(User user);*/
}
