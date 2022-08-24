import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shuttertop/misc/app_localizations.dart';
import 'package:shuttertop/misc/utils.dart';
import 'package:shuttertop/models/user.dart';
import 'package:shuttertop/pages/user_page.dart';
import 'package:shuttertop/ui/widget/block.dart';
import 'package:shuttertop/ui/users/avatar.dart';
import 'package:transparent_image/transparent_image.dart';

class UsersRow extends StatelessWidget {
  UsersRow(this.users, this.count, this.title, this.onTap);

  final List<User> users;
  final String title;
  final int count;
  final Function onTap;

  List<Widget> _getUsers(BuildContext context, int start, int end) {
    final double width = (MediaQuery.of(context).size.width - 28) / 3 - 8;
    return users
        .sublist(start, end)
        .map((User user) => InkWell(
            onTap: () {
              _showUserPage(context, user);
            },
            child: Container(
              height: width + 30,
              padding: EdgeInsets.symmetric(horizontal: 4.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                      height: width,
                      width: width,
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                              color: Colors.grey[300],
                              child: FadeInImage(
                                  fit: BoxFit.cover,
                                  placeholder:
                                      new MemoryImage(kTransparentImage),
                                  image: new CachedNetworkImageProvider(
                                    user.getImageUrl(ImageFormat.medium),
                                  ))))),
                  Container(
                      width: width,
                      height: 10,
                      alignment: Alignment.center,
                      padding: EdgeInsets.only(top: 5.0),
                      child: Text(
                        user.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 13.0,
                            fontFamily: "Raleway",
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800]),
                      ))
                ],
              ),
            )))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) return Container(width: 0.0, height: 0.0);
    final double width = (MediaQuery.of(context).size.width - 28) / 3 - 8;

    final List<Widget> list =
        _getUsers(context, 0, users.length > 3 ? 3 : users.length);
    final List<Widget> listSec = users.length > 3
        ? _getUsers(context, 3, users.length > 6 ? 6 : users.length)
        : <Widget>[];
    return Block(
      onTapAll: (count ?? 0) > 6 ? onTap : null,
      titleViewAll: AppLocalizations.of(context).visualizzaTutti,
      child: Column(children: <Widget>[
        Container(
            height: width + 40,
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: list,
            )),
        listSec.isEmpty
            ? Container()
            : Container(
                height: width + 60,
                padding: EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: listSec,
                )),
      ]),
      title: title,
      subtitle: count.toString(),
    );
  }

  void _showUserPage(BuildContext context, User user) {
    Navigator.push(
        context,
        new MaterialPageRoute<Null>(
            settings: const RouteSettings(name: UserPage.routeName),
            builder: (BuildContext context) => UserPage(user)));
  }
}
