import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shuttertop/misc/app_localizations.dart';
import 'package:shuttertop/misc/costants.dart';
import 'package:shuttertop/misc/events.dart';
import 'package:shuttertop/misc/shuttertop.dart';
import 'package:shuttertop/pages/info_page.dart';
import 'package:shuttertop/pages/welcome_page.dart';
import 'package:shuttertop/ui/users/user_edit_name.dart';
import 'package:shuttertop/ui/widget/widget_utils.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key key}) : super(key: key);

  static const String routeName = '/settings';

  @override
  _SettingsPageState createState() => new _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool _withNotifies = false;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((SharedPreferences e) {
      setState(() => _withNotifies = e.getString('noFcm') == null);
    });
  }

  Future<bool> _addImage(File imageFile) async {
    return await shuttertop.userRepository
        .addImage(shuttertop.currentSession.user, imageFile, shuttertop.getS3);
  }

  Future<bool> _setNotify(bool enabled) async {
    if (enabled) {
      if (await shuttertop.sessionRepository.addToken(shuttertop.platform) !=
          null) {
        (await SharedPreferences.getInstance()).remove('noFcm');
        return true;
      } else
        true;
    } else {
      if (await shuttertop.sessionRepository.removeToken()) {
        (await SharedPreferences.getInstance()).setString('noFcm', "1");
        return true;
      } else
        return false;
    }
    return false;
  }

  Future<Null> _logout() async {
    await shuttertop.disconnect();
    Navigator.of(context).pushNamedAndRemoveUntil(
        WelcomePage.routeName, (Route<dynamic> route) => false);
  }

  Future<Null> _onImageReady(File fileName, [dynamic error]) async {
    if (await _addImage(fileName)) setState(() {});
    print("----------getImage image end");
    Navigator.of(context).pop();
    Navigator.of(context).pop();
  }

  Future<Null> _showUserEditNamePage() async {
    await Navigator.push(
        context,
        new MaterialPageRoute<Null>(
          settings: const RouteSettings(name: UserEditNamePage.routeName),
          builder: (BuildContext context) => new UserEditNamePage(),
        ));
  }

  Future<Null> _showInfoPage() async {
    await Navigator.push(
        context,
        new MaterialPageRoute<Null>(
          settings: const RouteSettings(name: InfoPage.routeName),
          builder: (BuildContext context) => new InfoPage(),
        ));
  }

  static const Map<String, String> lang = <String, String>{
    "en": "English",
    "es": "Español",
    "it": "Italiano",
    "pt": "Português"
  };

  Future<Null> _showLanguageDialog() async {
    String l = await showDialog<String>(
        context: context,
        builder: (BuildContext context) => SimpleDialog(
                title: Text(AppLocalizations.of(context).lingua),
                children: <Widget>[
                  SimpleDialogOption(
                      onPressed: () {
                        Navigator.pop(context, 'en');
                      },
                      child: Text(lang["en"])),
                  SimpleDialogOption(
                      onPressed: () {
                        Navigator.pop(context, 'es');
                      },
                      child: Text(lang["es"])),
                  SimpleDialogOption(
                      onPressed: () {
                        Navigator.pop(context, 'it');
                      },
                      child: Text(lang["it"])),
                  SimpleDialogOption(
                      onPressed: () {
                        Navigator.pop(context, 'pt');
                      },
                      child: Text(lang["pt"]))
                ]));
    if (l != null) {
      if (await shuttertop.userRepository
          .edit(shuttertop.currentSession.user.id, language: l)) {
        setState(() {
          shuttertop.currentSession.user.language = l;
        });
      }

      shuttertop.eventBus.fire(new LocaleChangedEvent(new Locale(l, l)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle titleStyle = TextStyle(
        fontFamily: "Raleway",
        color: Colors.grey[700],
        fontSize: 15,
        fontWeight: FontWeight.w600);
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
                    AppLocalizations.of(context).impostazioni,
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
                  title: Text(AppLocalizations.of(context).nomeDiBattaglia,
                      style: titleStyle),
                  subtitle: Text(shuttertop.currentSession?.user?.name ?? ""),
                  onTap: _showUserEditNamePage,
                ),
                Divider(
                  height: 1.0,
                  color: AppColors.border,
                ),
                ListTile(
                  title: Text(
                    AppLocalizations.of(context).modificaFotoDelProfilo,
                    style: titleStyle,
                  ),
                  onTap: () => WidgetUtils.getImage(
                      context,
                      AppLocalizations.of(context).immagineDiProfilo,
                      _onImageReady),
                ),
                Divider(
                  height: 1.0,
                  color: AppColors.border,
                ),
                ListTile(
                  title: Text(
                    AppLocalizations.of(context).lingua,
                    style: titleStyle,
                  ),
                  subtitle:
                      Text(lang[shuttertop.currentSession.user?.language]),
                  onTap: _showLanguageDialog,
                ),
                Divider(
                  height: 1.0,
                  color: AppColors.border,
                ),
                ListTile(
                  title: Text(AppLocalizations.of(context).cambiaLaTuaPassword,
                      style: titleStyle),
                  onTap: () => WidgetUtils.showPasswordConfirmPage(context),
                ),
                Divider(
                  height: 1.0,
                  color: AppColors.border,
                ),
                SwitchListTile(
                  title: Text(
                    AppLocalizations.of(context).notifiche,
                    style: titleStyle,
                  ),
                  value: _withNotifies,
                  onChanged: (bool value) {
                    setState(() {
                      _withNotifies = value;
                    });
                    _setNotify(_withNotifies);
                  },
                ),
                Divider(
                  height: 1.0,
                  color: AppColors.border,
                ),
                ListTile(
                  title: Text(
                    AppLocalizations.of(context).informazioni,
                    style: titleStyle,
                  ),
                  onTap: _showInfoPage,
                ),
                Divider(
                  height: 1.0,
                  color: AppColors.border,
                ),
                ListTile(
                  onTap: _logout,
                  title: Text(
                    AppLocalizations.of(context).esciDalTunnel,
                    style: titleStyle,
                  ),
                  subtitle: Text(AppLocalizations.of(context).ancheDettoLogout),
                )
              ],
            ))));
  }
}
