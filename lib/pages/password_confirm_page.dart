import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shuttertop/misc/app_localizations.dart';
import 'package:shuttertop/misc/costants.dart';
import 'package:shuttertop/misc/shuttertop.dart';
import 'package:shuttertop/models/exceptions.dart';
import 'package:shuttertop/ui/widget/button_submit.dart';
import 'package:shuttertop/ui/widget/form_page.dart';
import 'package:shuttertop/ui/widget/password_field.dart';

class PasswordConfirmPage extends StatefulWidget {
  PasswordConfirmPage({Key key, this.token, this.email}) : super(key: key);

  static const String routeName = '/confirm_password';

  final String token;
  final String email;

  @override
  State createState() => new PasswordConfirmPageState();
}

class LoginData {
  String password = '';
  String oldPassword = '';
}

class PasswordConfirmPageState extends State<PasswordConfirmPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  LoginData login = new LoginData();

  String _errorOldPassword;

  bool _autovalidate = false;
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  Future<Null> _handleSubmitted(BuildContext context) async {
    final FormState form = _formKey.currentState;
    _errorOldPassword = null;
    form.save();
    print("_handleSubmited");
    if (!form.validate()) {
      _autovalidate = true; // Start validating on every change.
      _showInSnackBar(
          AppLocalizations.of(context).sistemaGliErroriPerContinuare);
    } else {
      print("_handleSubmited ok");
      try {
        if ((widget.token != null &&
                await shuttertop.sessionRepository.anotherLifeConfirm(
                    widget.email, widget.token, login.password.trim())) ||
            (widget.token == null &&
                await shuttertop.sessionRepository.changePassword(
                    login.password.trim(), login.oldPassword.trim())))
          _onPasswordChanged();
        else
          onError();
      } on ConnException catch (e) {
        print("ERRORE DI CONNESSIONE $e");
        _showInSnackBar(
            AppLocalizations.of(context).problemiDiConnessioneAlServer);
      } catch (e) {
        print("ERRORE _handleSubmitted $e");
        _errorOldPassword =
            AppLocalizations.of(context).controllaCheSiaCorretta;
        _showInSnackBar(AppLocalizations.of(context)
            .controllaCheLaTuaVecchiaPasswordSiaCorretta);
        _formKey.currentState.validate();
      }
    }
  }

  Future<Null> _showInSnackBar(String value) async {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
  }

  void _onPasswordChanged() {
    print("_onPasswordChanged");
    Navigator.of(context).pop<bool>(true);
  }

  void onError() {
    // TODO: implement onError
  }

  String _validateOldPassword(String value) {
    return _errorOldPassword ?? _validatePassword(value);
  }

  String _validateNewPassword(String value) {
    return _validatePassword(value);
  }

  String _validatePassword(String value) {
    if (value.isEmpty)
      return AppLocalizations.of(context).laPasswordEObbligatoria;
    if (value.length < 8)
      return AppLocalizations.of(context).lunghezzaMinima8Caratteri;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FormPage(
        scaffoldKey: _scaffoldKey,
        title: widget.token != null
            ? AppLocalizations.of(context).nuovaPassword
            : AppLocalizations.of(context).cambiaPassword,
        child: Form(
            key: _formKey,
            autovalidate: _autovalidate,
            child: Container(
                child: Column(children: <Widget>[
              widget.token == null
                  ? Container(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: PasswordField(
                        hintText: AppLocalizations.of(context).password,
                        labelText: AppLocalizations.of(context).vecchiaPassword,
                        onSaved: (String value) {
                          login.oldPassword = value;
                        },
                        validator: _validateOldPassword,
                      ))
                  : Container(),
              new Container(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: PasswordField(
                    hintText:
                        AppLocalizations.of(context).digitaLaTuaNuovaPassword,
                    labelText: AppLocalizations.of(context).nuovaPassword,
                    onSaved: (String value) {
                      login.password = value;
                    },
                    validator: _validateNewPassword,
                  )),
              Container(
                padding: EdgeInsets.symmetric(vertical: 40.0),
                child: ButtonSubmit(
                  height: 48.0,
                  text: AppLocalizations.of(context).conferma,
                  onTap: () {
                    _handleSubmitted(context);
                  },
                ),
              ),
            ]))));
  }
}
