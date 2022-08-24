import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shuttertop/misc/app_localizations.dart';
import 'package:shuttertop/misc/costants.dart';
import 'package:shuttertop/misc/shuttertop.dart';
import 'package:shuttertop/ui/widget/button_submit.dart';
import 'package:shuttertop/pages/mail_page.dart';
import 'package:shuttertop/ui/widget/form_page.dart';

class PasswordRecoveryPage extends StatefulWidget {
  PasswordRecoveryPage({Key key}) : super(key: key);

  static const String routeName = '/password_recovery';

  @override
  State createState() => new PasswordRecoveryPageState();
}

class PasswordRecoveryPageState extends State<PasswordRecoveryPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  String email;

  bool _autovalidate = false;
  bool _recoverySuccess = false;
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  @override
  void initState() {
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
      if (await shuttertop.sessionRepository.recovery(email.trim())) {
        setState(() {
          _recoverySuccess = true;
        });
      } else {
        _showInSnackBar(AppLocalizations.of(context).nonTiAbbiamoRintracciato);
      }
    }
  }

  Future<Null> _showInSnackBar(String value) async {
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(value)));
  }

  String _validateEmail(String value) {
    if (value.isEmpty) return AppLocalizations.of(context).emailEObbligatoria;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return _recoverySuccess
        ? MailPage()
        : FormPage(
            title: AppLocalizations.of(context).recuperoPassword,
            scaffoldKey: _scaffoldKey,
            child: Form(
                key: _formKey,
                autovalidate: _autovalidate,
                child: Column(children: <Widget>[
                  TextFormField(
                    autocorrect: false,
                    //autofocus: true,
                    style: Styles.labelStyle,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context).digitaLaTuaEmail,
                      labelText: AppLocalizations.of(context).email,
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: AppColors.brandPrimary),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: AppColors.inputBorderEnabled),
                      ),
                    ),
                    onSaved: (String value) {
                      email = value;
                    },
                    validator: _validateEmail,
                  ),
                  new Container(
                    padding: EdgeInsets.only(top: 36.0),
                    child: ButtonSubmit(
                      height: 48.0,
                      text: AppLocalizations.of(context).recuperati,
                      onTap: () {
                        _handleSubmitted(context);
                      },
                    ),
                  ),
                ])));
  }
}
