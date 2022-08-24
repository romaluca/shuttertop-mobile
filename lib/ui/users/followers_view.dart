import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shuttertop/misc/utils.dart';
import 'package:shuttertop/models/entity_base.dart';
import 'package:shuttertop/models/user.dart';
import 'package:shuttertop/services/base_service.dart';
import 'package:shuttertop/ui/widget/widget_utils.dart';
import 'package:shuttertop/misc/shuttertop.dart';
import 'package:shuttertop/ui/users/user_list_item.dart';
import 'package:shuttertop/ui/widget/load_list_view.dart';

class FollowersView extends StatefulWidget {
  final EntityBase element;
  final ListUserType type;

  const FollowersView({Key key, this.element, this.type}) : super(key: key);

  static const String routeName = '/followers';

  @override
  _FollowersViewState createState() => new _FollowersViewState();
}

class _FollowersViewState extends State<FollowersView> {
  List<User> elements;

  @override
  void initState() {
    super.initState();
    elements = <User>[];
  }

  Future<RequestListPage<User>> loadFollowers(int page) async {
    return await shuttertop.userRepository
        .fetch(type: widget.type, page: page, element: widget.element);
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _showUserPage(User user) {
    WidgetUtils.showUserPage(context, user);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return LoadingListView<User>(
      loadFollowers,
      elements: elements,
      widgetAdapter: adapt,
      indexer: (User e) => e.id,
    );
  }

  Widget adapt(List<User> user, int index) {
    return UserListItem(
      user[index],
      _showUserPage,
      format: UserListItemFormat.minimal,
    );
  }
}
