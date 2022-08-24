import 'dart:async';
import 'dart:io';
import 'package:shuttertop/misc/shuttertop.dart';
import 'package:shuttertop/misc/events.dart';
import 'package:shuttertop/misc/s3.dart';
import 'package:shuttertop/models/entity_base.dart';
import 'package:shuttertop/models/user.dart';
import 'package:shuttertop/services/base_service.dart';
import 'package:shuttertop/misc/utils.dart';

class UserService extends BaseService implements UserRepository {
  @override
  String get url => "/users";

  @override
  Future<RequestListPage<User>> fetch(
      {ListUserType type = ListUserType.score,
      EntityBase element,
      UserListItemFormat filterType = UserListItemFormat.normal,
      int page = 0,
      String search}) async {
    final Map<String, String> params = <String, String>{
      "page": page.toString()
    };
    if (search != null) params["search"] = search;
    if (filterType == UserListItemFormat.scoreMonth)
      params["days"] = "30";
    else if (filterType == UserListItemFormat.scoreWeek) params["days"] = "7";
    params["order"] = type.index > 2 ? "news" : listUserType[type.index];
    if (type.index > 2 && element != null)
      params[listUserType[type.index]] = element.id.toString();
    final Map<String, dynamic> usersContainer = await httpGet(params: params);
    final List<dynamic> entries = usersContainer['users'];
    return new RequestListPage<User>(
        entries.map((dynamic user) => new User.fromMap(user)).toList(),
        usersContainer['total_entries']);
  }

  @override
  Future<ResponseApi<User>> create(
      String name, String email, String password) async {
    final Map<String, dynamic> data = await httpPost(<String, dynamic>{
      'user': <String, dynamic>{
        'name': name,
        'email': email,
        'authorizations': <Map<String, dynamic>>[
          <String, dynamic>{
            'password': password,
            'password_confirmation': password
          }
        ]
      }
    }, postUrl: "${shuttertop.siteUrl}/auth/newuser");
    final ResponseApi<User> ret =
        new ResponseApi<User>(!data.containsKey("errors"));
    if (!ret.success) ret.errors = data["errors"];

    return ret;
  }

  @override
  Future<bool> edit(int id,
      {String name, String email, String language}) async {
    final Map<String, dynamic> params = <String, dynamic>{};
    if (name != null) params["name"] = name;
    if (email != null) params["email"] = email;
    if (language != null) params["language"] = language;

    final Map<String, dynamic> data =
        await httpPut(id, <String, dynamic>{'user': params});

    return !data.containsKey("error");
  }

  @override
  Future<User> get(String slug, {User user}) async {
    final Map<String, dynamic> userContainer = await httpGet(id: slug);
    if (user != null)
      user.refresh(
        userContainer['user'],
        userContainer['photos'],
        userContainer['follows'],
        userContainer['followers'],
        userContainer['contests'],
        userContainer['best_photo'],
      );
    else
      user = new User.fromMap(
        userContainer['user'],
        userContainer['photos'],
        userContainer['follows'],
        userContainer['followers'],
        userContainer['contests'],
        userContainer['best_photo'],
      );
    shuttertop.eventBus.fire(UserEvent(user));
    return user;
  }

  @override
  Future<bool> addImage(User user, File imageFile, S3 s3) async {
    final String now = new DateTime.now()
        .toIso8601String()
        .replaceAll(":", "")
        .replaceAll("-", "")
        .substring(0, 15);

    final String imageName = "${now}_U_${user.id}.jpg";
    try {
      if (await presign(user.id, "user", now)) {
        print("-------------------before upload");
        await s3.upload(imageFile.readAsBytesSync(), imageName);
        print("after upload");

        user.refresh(await httpPut(user.id, <String, dynamic>{
          "user": <String, dynamic>{
            "upload": imageName,
          }
        }));

        /*
      bool imageUploaded = false;
      while (!imageUploaded) {
        imageUploaded = await checkStatusGetUrl(user.getImageUrl(ImageFormat.normal));
        if(!imageUploaded)
          sleep(new Duration(milliseconds: 300));
      }*/

        return true;
      } else
        return false;
    } catch (e) {
      print("addImage error: $e");
      return false;
    }
  }

  /*@override
  Future<bool> join(User user,
      {ChannelResult onVoted, Function onComment}) async {
    if (await addChannel(user.channelName)) {
      return true;
    }
    return false;
  }

  @override
  Future<Null> leave(User user) async {
    leaveChannel(user.channelName);
  }*/
}
