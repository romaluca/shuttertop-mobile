import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shuttertop/misc/app_localizations.dart';
import 'package:shuttertop/misc/costants.dart';
import 'package:shuttertop/misc/shuttertop.dart';
import 'package:shuttertop/pages/welcome_page.dart';
import 'package:shuttertop/ui/users/user_edit_name.dart';
import 'package:shuttertop/ui/widget/simple_page.dart';
import 'package:shuttertop/ui/widget/widget_utils.dart';
import 'package:package_info/package_info.dart';
import 'package:webview_flutter/webview_flutter.dart';

class InfoPage extends StatefulWidget {
  const InfoPage({Key key}) : super(key: key);

  static const String routeName = '/info';

  @override
  _InfoPageState createState() => new _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  String version = "";
  String buildNumber = "";

  String get siteUrl {
    if (shuttertop.mode == ModeRun.production)
      return "https://${shuttertop.hostName}";
    else
      return "http://${shuttertop.hostName}";
  }

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      setState(() {
        version = packageInfo.version;
        buildNumber = packageInfo.buildNumber;
      });
    });
  }

  Future<Null> _showPage(String name, String url) async {
    await Navigator.push(
        context,
        new MaterialPageRoute<Null>(
          settings: const RouteSettings(name: UserEditNamePage.routeName),
          builder: (BuildContext context) => new SimplePage(
              name,
              WebView(
                initialUrl: "$siteUrl/$url?content=1",
              )),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        body: NestedScrollView(
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverAppBar(
                  backgroundColor: Colors.white,
                  centerTitle: true,
                  iconTheme: IconThemeData(color: Colors.black),
                  title: Text(
                    AppLocalizations.of(context).informazioni,
                    style: Styles.header,
                  ),
                  pinned: true,
                  elevation: 1.0,
                  snap: false,
                  floating: false,
                )
              ];
            },
            body: Container(
                //padding:
                //     EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
                child: ListView(
              children: <Widget>[
                ListTile(
                  title: Text(AppLocalizations.of(context).terminiDelServizio,
                      style: TextStyle()),
                  onTap: () => _showPage(
                      AppLocalizations.of(context).terminiDelServizio, "terms"),
                ),
                Divider(
                  height: 1.0,
                  color: AppColors.border,
                ),
                ListTile(
                  title: Text(
                      AppLocalizations.of(context).informativaSullaPrivacy),
                  onTap: () => _showPage(
                      AppLocalizations.of(context).informativaSullaPrivacy,
                      "privacy"),
                ),
                Divider(
                  height: 1.0,
                  color: AppColors.border,
                ),
                ListTile(
                  title: Text(AppLocalizations.of(context).versione),
                  subtitle: Text(version),
                ),
              ],
            ))));
  }
}
