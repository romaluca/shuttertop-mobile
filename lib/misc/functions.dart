import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:shuttertop/misc/utils.dart';
import 'package:shuttertop/models/activity.dart';
import 'package:shuttertop/models/contest.dart';
import 'package:shuttertop/models/entity_base.dart';
import 'package:shuttertop/models/photo.dart';
import 'package:shuttertop/models/user.dart';
import 'package:shuttertop/services/base_service.dart';

typedef Future<RequestListPage<T>> PageRequest<T>(int page);
//typedef Future<List<Map>> ApiPageRequest(int page, int pageSize);
typedef void PaginationThresholdCallback();
typedef Widget WidgetAdapter<T>(List<T> t, int index);
typedef int Indexer<T>(T t);
typedef Future<Null> ContestFollow(Contest contest);
typedef Future<Null> UserFollow(User user);
typedef Future<Null> Vote(Photo photo);
//typedef Future<Null> Comment(Photo photo, String message);
typedef void ShowUserPage(User user);
typedef void ShowPhotoPage(Photo photo);
typedef void ShowContestPage(Contest contest, {@required bool join});
typedef void ShowCommentsPage(EntityBase element, {@required bool edit});
typedef void ShowObjectPage(EntityBase element);
typedef void ShowActivityObjectPage(Activity activity);
typedef void ChannelResult(ResponseStatus status, [dynamic result]);
