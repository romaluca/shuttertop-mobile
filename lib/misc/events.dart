import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shuttertop/models/comment.dart';
import 'package:shuttertop/models/contest.dart';
import 'package:shuttertop/models/photo.dart';
import 'package:shuttertop/models/user.dart';

class ContestEvent {
  Contest contest;

  ContestEvent(this.contest);
}

class PhotoEvent {
  Photo photo;

  PhotoEvent(this.photo);
}

class UserEvent {
  User user;

  UserEvent(this.user);
}

class PhotoDeleteEvent {
  int id;

  PhotoDeleteEvent(this.id);
}

class ContestDeleteEvent {
  int id;

  ContestDeleteEvent(this.id);
}

class CommentEvent {
  Comment comment;
  String uId;

  CommentEvent(this.comment, this.uId);
}

class VoteEvent {
  Photo photo;
  User user;

  VoteEvent(this.photo, this.user);
}

class ContestFollowEvent {
  Contest contest;

  ContestFollowEvent(this.contest);
}

class UserFollowEvent {
  User user;
  UserFollowEvent(this.user);
}

class ImageSharedEvent {
  File image;

  ImageSharedEvent(this.image);
}

class LinkEvent {
  Uri link;

  LinkEvent(this.link);
}

class LocaleChangedEvent {
  Locale locale;

  LocaleChangedEvent(this.locale);
}
