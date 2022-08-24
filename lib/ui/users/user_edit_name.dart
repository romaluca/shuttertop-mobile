import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shuttertop/misc/app_localizations.dart';
import 'package:shuttertop/misc/shuttertop.dart';
import 'package:shuttertop/ui/widget/button_submit.dart';
import 'package:shuttertop/ui/widget/form_page.dart';

class UserEditNamePage extends StatefulWidget {
  const UserEditNamePage([Key key]) : super(key: key);

  static const String routeName = '/usereditname';

  @override
  State createState() => new UserEditNamePageState();
}

class UserEditNamePageState extends State<UserEditNamePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  bool _autovalidate = false;
  String _name;
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _name = shuttertop.currentSession.user.name;
  }

  String _validateName(String value) {
    if (value.isEmpty)
      return AppLocalizations.of(context).usernameEObbligatorio;
    return null;
  }

  void _showInSnackBar(String value) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
  }

  Future<Null> _handleSubmitted() async {
    final FormState form = _formKey.currentState;
    form.save();
    if (!form.validate()) {
      _autovalidate = true; // Start validating on every change.
      _showInSnackBar(
          AppLocalizations.of(context).sistemaGliErroriPerContinuare);
    } else {
      if (await shuttertop.userRepository
          .edit(shuttertop.currentSession.user.id, name: _name)) {
        shuttertop.currentSession.user.name = _name;
        Navigator.of(context).pop();
      } //else
      //_showInSnackBar('Errori :(');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormPage(
        title: AppLocalizations.of(context)
            .modificaUsername(shuttertop.currentSession.user.name),
        scaffoldKey: _scaffoldKey,
        child: Form(
            key: _formKey,
            autovalidate: _autovalidate,
            child: Column(children: <Widget>[
              TextFormField(
                autocorrect: false,
                autofocus: true,
                initialValue: shuttertop.currentSession.user.name,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context).nomeDiBattaglia,
                ),
                onSaved: (String value) {
                  _name = value;
                },
                validator: _validateName,
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 40.0),
                child: ButtonSubmit(
                  height: 48.0,
                  text: AppLocalizations.of(context).camuffati,
                  onTap: _handleSubmitted,
                ),
              ),
            ])));
  }
}
