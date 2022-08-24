import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shuttertop/misc/costants.dart';

class SimplePage extends StatelessWidget {
  SimplePage(this.title, this.body, {this.subtitle, this.background});
  final Widget body;
  final String title;
  final String subtitle;
  final Color background;

  static const String routeName = '/simple_page';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: background ?? Colors.white,
        body: NestedScrollView(
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverAppBar(
                  backgroundColor: Colors.white,
                  centerTitle: true,
                  iconTheme: IconThemeData(color: Colors.black),
                  title: subtitle == null
                      ? Text(title, style: Styles.header)
                      : SingleChildScrollView(
                          child: Column(children: <Widget>[
                          Container(
                              padding: EdgeInsets.only(top: 6.0, bottom: 5.0),
                              child: Text(title, style: Styles.header)),
                          Text(
                            subtitle,
                            style: TextStyle(
                                fontSize: 14.0, color: Colors.grey[700]),
                          )
                        ])),
                  pinned: false,
                  elevation: 1.0,
                  snap: false,
                  floating: false,
                )
              ];
            },
            body: body));
  }
}
