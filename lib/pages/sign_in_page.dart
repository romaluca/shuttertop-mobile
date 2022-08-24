import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shuttertop/misc/app_localizations.dart';
import 'package:shuttertop/misc/costants.dart';
import 'package:shuttertop/misc/shuttertop.dart';
import 'package:shuttertop/models/session.dart';
import 'package:shuttertop/pages/password_recovery_page.dart';
import 'package:shuttertop/pages/signup_page.dart';
import 'package:shuttertop/services/base_service.dart';
import 'package:shuttertop/ui/widget/button_submit.dart';
import 'package:shuttertop/ui/widget/form_page.dart';
import 'package:shuttertop/ui/widget/password_field.dart';
import 'package:shuttertop/models/exceptions.dart';

class SignInPage extends StatefulWidget {
  SignInPage({Key key}) : super(key: key);

  static const String routeName = '/signin';

  @override
  State createState() => new SignInPageState();
}

class LoginData {
  String email = '';
  String password = '';
}

class SignInPageState extends State<SignInPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  LoginData login = new LoginData();
  FocusNode focusNodePassword;

  bool _autovalidate = false;
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  @override
  void initState() {
    focusNodePassword = new FocusNode();
    super.initState();
  }

  Future<Null> _handleSubmitted(BuildContext context) async {
    final FormState form = _formKey.currentState;
    form.save();
    print("_handleSubmited");
    if (!form.validate()) {
      _autovalidate = true; // Start validating on every change.
      _showInSnackBar(
          AppLocalizations.of(context).sistemaGliErroriPerContinuare);
    } else {
      print("_handleSubmited ok");
      try {
        final ResponseApi<Session> ret = await shuttertop.sessionRepository
            .signIn(login.email.trim(), login.password.trim());
        if (!ret.success)
          onError();
        else
          _onUserLogged();
      } on ResponseErrorException catch (e) {
        print("Response error $e");
        _showInSnackBar("Email e/o password errati");
      } on ConnException catch (e) {
        print("ERRORE DI CONNESSIONE $e");
        _showInSnackBar(
            AppLocalizations.of(context).problemiDiConnessioneAlServer);
      } catch (e) {
        print("ERRORE $e");
      }
    }
  }

  Future<Null> _showInSnackBar(String value) async {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
  }

  void _showSignUpPage(BuildContext context) {
    Navigator.push(
        context,
        new MaterialPageRoute<Null>(
          settings: const RouteSettings(name: SignUpPage.routeName),
          builder: (BuildContext context) => SignUpPage(),
        ));
    setState(() {});
  }

  void _showRecoveryPage(BuildContext context) {
    Navigator.push(
        context,
        new MaterialPageRoute<Null>(
          settings: const RouteSettings(name: PasswordRecoveryPage.routeName),
          builder: (BuildContext context) => PasswordRecoveryPage(),
        ));
    setState(() {});
  }

  void _onUserLogged() {
    print("onUSerLogged");
    Navigator.of(context).pop<bool>(true);
  }

  void onError() {
    _showInSnackBar(AppLocalizations.of(context).emailEOPasswordErrati);
  }

  String _validateEmail(String value) {
    if (value.isEmpty) return AppLocalizations.of(context).emailEObbligatoria;
    return null;
  }

  String _validatePassword(String value) {
    if (value.isEmpty)
      return AppLocalizations.of(context).laPasswordEObbligatoria;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FormPage(
        scaffoldKey: _scaffoldKey,
        title: AppLocalizations.of(context).login,
        child: Form(
            key: _formKey,
            autovalidate: _autovalidate,
            child: Container(
                child: Column(children: <Widget>[
              new Container(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: TextFormField(
                    autocorrect: false,
                    textCapitalization: TextCapitalization.none,
                    //autofocus: true,
                    textInputAction: TextInputAction.next,
                    onEditingComplete: () =>
                        FocusScope.of(context).requestFocus(focusNodePassword),
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelStyle: Styles.labelStyle,
                      hintText: AppLocalizations.of(context).digitaLaTuaEmail,
                      labelText: AppLocalizations.of(context).email,
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: AppColors.brandPrimary),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: AppColors.inputBorderEnabled),
                      ),

                      //filled: true,
                    ),
                    onSaved: (String value) {
                      login.email = value;
                    },
                    validator: _validateEmail,
                  )),
              new Container(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: PasswordField(
                    hintText: AppLocalizations.of(context).digitaLaTuaPassword,
                    labelText: AppLocalizations.of(context).password,
                    focusNode: focusNodePassword,
                    onFieldSubmitted: (String pwd) =>
                        FocusScope.of(context).requestFocus(new FocusNode()),
                    onSaved: (String value) {
                      login.password = value;
                    },
                    validator: _validatePassword,
                  )),
              Container(
                padding: EdgeInsets.only(bottom: 20.0, top: 40.0),
                child: ButtonSubmit(
                  height: 48.0,
                  text: AppLocalizations.of(context).accedi,
                  onTap: () {
                    _handleSubmitted(context);
                  },
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 0.0),
                child: FlatButton(
                  onPressed: () {
                    _showSignUpPage(context);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(AppLocalizations.of(context).nonHaiUnAccount,
                          style: TextStyle(
                              fontFamily: "Raleway",
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[400])),
                      Text(AppLocalizations.of(context).iscriviti,
                          style: TextStyle(
                              fontFamily: "Raleway",
                              fontWeight: FontWeight.w700,
                              color: Colors.grey[700]))
                    ],
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 0.0),
                child: FlatButton(
                  onPressed: () {
                    _showRecoveryPage(context);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(AppLocalizations.of(context).recuperaLa,
                          style: TextStyle(
                              fontFamily: "Raleway",
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[400])),
                      Text(AppLocalizations.of(context).passwordWithExclamation,
                          style: TextStyle(
                              fontFamily: "Raleway",
                              fontWeight: FontWeight.w700,
                              color: Colors.grey[700]))
                    ],
                  ),
                ),
              ),
            ]))));
  }
}
