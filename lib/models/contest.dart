import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shuttertop/misc/s3.dart';
import 'package:shuttertop/models/comment.dart';
import 'package:shuttertop/models/entity_base.dart';
import 'package:shuttertop/models/iphotoable.dart';
import 'package:shuttertop/models/photo.dart';
import 'package:shuttertop/models/user.dart';
import 'package:shuttertop/misc/utils.dart';
import 'package:meta/meta.dart';
import 'package:shuttertop/services/base_service.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Category {
  Category({this.id, this.name, this.icon, this.colors});

  final int id;
  final String name;
  final IconData icon;
  final List<Color> colors;
}

enum ContestFetchType { all, joined, following, created }

class Contest extends EntityBase implements IPhotoable {
  DateTime startAt;
  DateTime expiryAt;
  final DateTime insertedAt;
  final User user;
  @override
  int photosCount;
  int followersCount;
  int categoryId;
  bool followed;
  String description;
  @override
  List<Photo> photos;
  List<Photo> leaders;
  List<User> followers;
  int winnerId;
  int edition;
  List<Photo> photosUser;
  bool isExpired;

  static const List<String> imageFormats = const <String>[
    "",
    "540s300/",
    "260s260/",
    "70s70/"
  ];

  static List<Color> colors = <Color>[
    Colors.blueGrey,
    Colors.blueGrey[800],
  ];

  static List<Category> categories = <Category>[
    new Category(id: 0, name: "", icon: null, colors: <Color>[
      Colors.blueGrey,
      Colors.blueGrey[800],
    ]),
    new Category(
        id: 1,
        name: "Arte e cultura",
        icon: FontAwesomeIcons.landmark,
        colors: <Color>[
          Colors.purple,
          Colors.purple[800],
        ]),
    new Category(
        id: 2,
        name: "Cibo",
        icon: FontAwesomeIcons.utensils,
        colors: <Color>[
          Colors.orange,
          Colors.orange[800],
        ]),
    new Category(
        id: 3,
        name: "Eventi",
        icon: FontAwesomeIcons.calendar,
        colors: <Color>[
          Colors.yellow,
          Colors.yellow[800],
        ]),
    new Category(
        id: 4,
        name: "Natura",
        icon: FontAwesomeIcons.cannabis,
        colors: <Color>[
          Colors.green,
          Colors.green[800],
        ]),
    new Category(
        id: 5,
        name: "Sport",
        icon: FontAwesomeIcons.dumbbell,
        colors: <Color>[
          Colors.lime,
          Colors.lime[800],
        ]),
    new Category(
        id: 6,
        name: "Tecnologia",
        icon: FontAwesomeIcons.microchip,
        colors: <Color>[
          Colors.indigo,
          Colors.indigo[800],
        ]),
    new Category(
        id: 7,
        name: "Esseri umani",
        icon: FontAwesomeIcons.child,
        colors: <Color>[
          Colors.pink,
          Colors.pink[800],
        ]),
    new Category(
        id: 8,
        name: "Viaggi",
        icon: FontAwesomeIcons.suitcase,
        colors: <Color>[
          Colors.lightBlue,
          Colors.lightBlue[800],
        ]),
    new Category(
        id: 9,
        name: "Bevande",
        icon: FontAwesomeIcons.glassCheers,
        colors: <Color>[
          Colors.red,
          Colors.red[800],
        ]),
  ];

  Contest(
      {@required int id,
      String name,
      @required String slug,
      String upload,
      List<Comment> comments,
      int commentsCount,
      this.startAt,
      this.expiryAt,
      this.insertedAt,
      this.followersCount,
      @required this.user,
      this.categoryId,
      this.description,
      this.photos,
      this.followers,
      this.edition,
      this.leaders,
      this.isExpired})
      : super(
            id: id,
            name: name,
            slug: slug,
            upload: upload,
            comments: comments,
            commentsCount: commentsCount) {
    photos ??= <Photo>[];
    followers ??= <User>[];
    comments ??= <Comment>[];
    leaders ??= <Photo>[];
    photosUser ??= <Photo>[];
  }

  @override
  Contest.fromMap(Map<String, dynamic> map,
      [List<dynamic> mapPhotos,
      List<dynamic> mapPhotosUser,
      List<dynamic> mapFollowers,
      List<dynamic> mapLeaders,
      List<dynamic> mapComments,
      Map<String, dynamic> mapUser])
      : startAt = DateTime.parse(map['start_at'] ?? map['inserted_at']),
        expiryAt = DateTime.parse(map['expiry_at']),
        insertedAt = map['inserted_at'] != null
            ? DateTime.parse(map['inserted_at'])
            : null,
        user = mapUser != null
            ? new User.fromMap(mapUser)
            : map.containsKey("user") && map["user"] != null
                ? new User.fromMap(map['user'])
                : new User.fromMap(<String, dynamic>{"id": map["user_id"]}),
        followersCount = map["followers_count"] ?? 0,
        photosCount = map["photos_count"] ?? 0,
        isExpired = map["is_expired"] ?? false,
        description = map['description'],
        edition = map["edition"],
        categoryId = map['category_id'],
        winnerId = map['winner_id'],
        photos = mapPhotos != null
            ? mapPhotos
                ?.map((dynamic photoRaw) => new Photo.fromMap(photoRaw))
                ?.toList()
            : <Photo>[],
        leaders = mapLeaders != null
            ? mapLeaders
                ?.map((dynamic photoRaw) => new Photo.fromMap(photoRaw))
                ?.toList()
            : <Photo>[],
        photosUser = mapPhotosUser != null
            ? mapPhotosUser
                ?.map((dynamic photoRaw) => new Photo.fromMap(photoRaw))
                ?.toList()
            : <Photo>[],
        //mapPhotoUser != null ? new Photo.fromMap(mapPhotoUser) : null,
        followed = map['followed'],
        followers = mapFollowers != null
            ? mapFollowers
                ?.map((dynamic userRaw) => new User.fromMap(userRaw))
                ?.toList()
            : <User>[],
        super.fromMap(map, mapComments) {
    assert(id != null);
    if (winnerId != null) {
      photos
          .singleWhere((Photo photo) => photo.id == winnerId,
              orElse: () => null)
          ?.isWinner = true;
      leaders
          .singleWhere((Photo photo) => photo.id == winnerId,
              orElse: () => null)
          ?.isWinner = true;
    }
  }

  void refresh(Map<String, dynamic> map,
      [List<dynamic> mapPhotos,
      List<dynamic> mapPhotosUser,
      List<dynamic> mapFollowers,
      List<dynamic> mapLeaders,
      List<dynamic> mapComments,
      Map<String, dynamic> mapUser]) {
    assert(map != null);
    name = map['name'];
    startAt = DateTime.parse(map['start_at'] ?? map['inserted_at']);
    expiryAt = DateTime.parse(map['expiry_at']);
    if (mapUser != null)
      user.refresh(mapUser);
    else if (map.containsKey("user") && map["user"] != null)
      user.refresh(map['user']);
    upload = map['upload'];
    photosCount = map["photos_count"] ?? 0;
    edition = map["edition"];
    commentsCount = map["comments_count"] ?? 0;
    followersCount = map["followers_count"] ?? 0;
    isExpired = map["is_expired"] ?? false;
    description = map['description'];
    categoryId = map['category_id'];
    winnerId = map['winner_id'];
    photos.clear();
    photos.addAll(mapPhotos != null
        ? mapPhotos
            ?.map((dynamic photoRaw) => new Photo.fromMap(photoRaw))
            ?.toList()
        : <Photo>[]);
    if (comments == null) comments = <Comment>[];
    comments.clear();
    comments.addAll(mapComments != null
        ? mapComments
            ?.map((dynamic commentRaw) => new Comment.fromMap(commentRaw))
            ?.toList()
        : <Comment>[]);
    leaders.clear();
    leaders.addAll(mapLeaders != null
        ? mapLeaders
            ?.map((dynamic photoRaw) => new Photo.fromMap(photoRaw))
            ?.toList()
        : <Photo>[]);
    photosUser.clear();
    photosUser.addAll(mapPhotosUser != null
        ? mapPhotosUser
            ?.map((dynamic photoRaw) => new Photo.fromMap(photoRaw))
            ?.toList()
        : <Photo>[]);
    followed = map['followed'];
    followers.clear();
    followers.addAll(mapFollowers != null
        ? mapFollowers
            ?.map((dynamic userRaw) => new User.fromMap(userRaw))
            ?.toList()
        : <User>[]);
    if (winnerId != null) {
      photos
          .singleWhere((Photo photo) => photo.id == winnerId,
              orElse: () => null)
          ?.isWinner = true;
      leaders
          .singleWhere((Photo photo) => photo.id == winnerId,
              orElse: () => null)
          ?.isWinner = true;
    }
  }

  @override
  String getImageUrl(ImageFormat size) {
    if (upload != null) {
      final String ret =
          "${Utils.imageBaseUrl}${imageFormats[size.index]}$upload";
      return ret;
    } else
      return "${Utils.imageBaseUrl}no_image/contest_${size.toString().substring(size.toString().indexOf('.') + 1)}23.png";
  }

  Category get category => categories[categoryId];

  @override
  String get fieldId => "contest_id";

  @override
  String get uId => "c_$id";

  @override
  bool operator ==(dynamic o) =>
      identical(this, o) || (o is Contest && o.id == id);
  @override
  int get hashCode => id.hashCode;

  @override
  String get channelName => "contest:$id";
}

abstract class ContestRepository {
  Future<RequestListPage<Contest>> fetch(
      {Category category,
      bool inProgress,
      ListOrder order = ListOrder.news,
      int page = 0,
      int pageSize,
      int limit,
      String search,
      ContestFetchType type,
      int userId});
  Future<Contest> get(String slug, {Contest contest});
  //Future<bool> follow(Contest contest, ChannelResult callback);
  Future<ResponseApi<Contest>> create(String name, DateTime startAt,
      DateTime expiryAt, String description, int categoryId);
  Future<ResponseApi<Contest>> edit(int id, String name, DateTime expiryAt,
      String description, int categoryId);
  Future<bool> delete(int id);
  Future<bool> addCover(File fileName, Contest contest, S3 s3);
  //void onVote(BaseApp app, Contest id, ChannelResult callback);

  /*Future<bool> join(Contest contest,
      {ChannelResult onVoted, Function onComment});
  Future<Null> leave(Contest contest);*/
}
