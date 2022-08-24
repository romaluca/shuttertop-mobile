import 'package:flutter/widgets.dart';

class EntityNotification extends Notification {}

class ListElementUpdate<T> extends Notification {
  final int key;
  final T instance;

  ListElementUpdate(this.key, this.instance);
}

class FullScreenNotification extends Notification {
  final Function callBack;
  FullScreenNotification({this.callBack});
}

class AnimationNotification extends Notification {}

class LoadedNotification extends Notification {}
