import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shuttertop/misc/app_localizations.dart';
import 'package:shuttertop/misc/costants.dart';
import 'package:shuttertop/misc/shuttertop.dart';
import 'package:shuttertop/misc/utils.dart';
import 'package:shuttertop/models/contest.dart';
import 'package:shuttertop/models/photo.dart';
import 'package:shuttertop/pages/contests_page.dart';
import 'package:shuttertop/ui/users/avatar.dart';
import 'package:shuttertop/ui/widget/widget_utils.dart';

class SharedPage extends StatefulWidget {
  SharedPage(this.imageFile, {Key key}) : super(key: key);

  static const String routeName = '/shared';

  final File imageFile;

  @override
  State createState() => new SharedPageState();
}

class SharedPageState extends State<SharedPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  Contest contest;

  @override
  void initState() {
    print("SharedPage");
    super.initState();
    contest = null;
  }

  void _addPhoto() async {
    if (contest == null) return;
    print("------addPhoto contestId ${contest.id}");
    final Photo p = await shuttertop.photoRepository
        .create(widget.imageFile, contest.id, shuttertop.getS3);
    print("_____added Photo: $p");
    Navigator.of(context).pop();
    WidgetUtils.showPhotoPage(context, p, showComments: false);
  }

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQueryData = MediaQuery.of(context);
    final double statusBarHeight = mediaQueryData.padding.top;
    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        body: Padding(
            padding: EdgeInsets.only(top: statusBarHeight),
            child: Column(children: <Widget>[
              Container(
                  child: Row(
                children: <Widget>[
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: Colors.black87,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Container(
                    child: Avatar(
                      shuttertop.currentSession.user
                          .getImageUrl(ImageFormat.thumb_small),
                      backColor: Colors.grey,
                      size: 40.0,
                    ),
                    padding: EdgeInsets.only(right: 16.0),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(shuttertop.currentSession.user.name),
                        InkWell(
                            onTap: () async {
                              contest = await Navigator.push(
                                  context,
                                  new MaterialPageRoute<Contest>(
                                    settings: const RouteSettings(
                                        name: ContestsPage.routeName),
                                    builder: (BuildContext context) =>
                                        new ContestsPage(
                                          searchMode: true,
                                        ),
                                  ));
                              setState(() {});
                            },
                            child: Row(
                              children: <Widget>[
                                Flexible(
                                    child: Text(
                                  contest == null
                                      ? AppLocalizations.of(context)
                                          .selezionaUnContest
                                      : contest.name,
                                  style:
                                      TextStyle(color: AppColors.brandPrimary),
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: false,
                                  maxLines: 1,
                                )),
                                Icon(
                                  Icons.arrow_drop_down,
                                  color: AppColors.brandPrimary,
                                )
                              ],
                            )),
                      ],
                    ),
                  ),
                  Container(
                      margin: EdgeInsets.symmetric(horizontal: 12.0),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(50.0)),
                          color: AppColors.brandPrimary),
                      child: FloatingActionButton(
                        onPressed: _addPhoto,
                        elevation: 0.0,
                        child: Icon(
                          Icons.send,
                          color: Colors.white,
                        ),
                      ))
                ],
              )),
              Container(
                  height: 220.0,
                  padding: EdgeInsets.only(top: 20.0),
                  child: Image.file(
                    widget.imageFile,
                    fit: BoxFit.cover,
                  )),
            ])));
  }
}
