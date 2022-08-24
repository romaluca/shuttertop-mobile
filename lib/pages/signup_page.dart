import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shuttertop/misc/app_localizations.dart';
import 'package:shuttertop/misc/costants.dart';
import 'package:shuttertop/misc/shuttertop.dart';
import 'package:shuttertop/models/user.dart';
import 'package:shuttertop/services/base_service.dart';
import 'package:shuttertop/ui/widget/button_submit.dart';
import 'package:shuttertop/pages/mail_page.dart';
import 'package:shuttertop/ui/widget/form_page.dart';
import 'package:shuttertop/ui/widget/password_field.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key key}) : super(key: key);

  static const String routeName = '/signup';

  @override
  State createState() => new SignUpPageState();
}

class _UserData {
  String name = '';
  String email = '';
  String password = '';
}

class SignUpPageState extends State<SignUpPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  _UserData user = new _UserData();

  bool _autovalidate = false;
  bool _signUpSuccess = false;
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  FocusNode focusNodeEmail;
  FocusNode focusNodePassword;
  ResponseApi<User> resp;

  @override
  void initState() {
    super.initState();
    focusNodeEmail = new FocusNode();
    focusNodePassword = new FocusNode();
  }

  Future<Null> _handleSubmitted() async {
    resp = null;
    final FormState form = _formKey.currentState;
    form.save();
    if (!form.validate()) {
      _autovalidate = true; // Start validating on every change.
      _showInSnackBar(
          AppLocalizations.of(context).sistemaGliErroriPerContinuare);
    } else {
      resp = await shuttertop.userRepository
          .create(user.name.trim(), user.email.trim(), user.password.trim());
      if (resp.success)
        _onUserCreated();
      else {
        form.validate();
      }
    }
  }

  void _onUserCreated() {
    setState(() {
      _signUpSuccess = true;
    });
  }

  void _showInSnackBar(String value) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
  }

  String _validateName(String value) {
    if (value.isEmpty)
      return AppLocalizations.of(context).usernameEObbligatorio;
    try {
      if (resp != null &&
          resp.errors != null &&
          resp.errors.containsKey("name")) return resp.errors["name"][0];
    } catch (error) {
      // ignore
    }
    return null;
  }

  String _validateEmail(String value) {
    if (value.isEmpty) return AppLocalizations.of(context).emailEObbligatoria;
    try {
      if (resp != null &&
          resp.errors != null &&
          resp.errors.containsKey("email")) return resp.errors["email"][0];
    } catch (error) {
      //ignore
    }
    return null;
  }

  String _validatePassword(String value) {
    if (value.isEmpty)
      return AppLocalizations.of(context).laPasswordEObbligatoria;
    if (value.length < 8)
      return AppLocalizations.of(context).lunghezzaMinima8Caratteri;
    try {
      if (resp != null &&
          resp.errors != null &&
          resp.errors.containsKey("authorizations"))
        return resp.errors["authorizations"][0]["password"][0];
    } catch (error) {
      //ignore
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle labelStyle = TextStyle(
        fontFamily: "Raleway", fontSize: 16, fontWeight: FontWeight.w600);
    return _signUpSuccess
        ? MailPage()
        : FormPage(
            title: AppLocalizations.of(context).registrati,
            scaffoldKey: _scaffoldKey,
            child: Form(
                key: _formKey,
                autovalidate: _autovalidate,
                child: Column(children: <Widget>[
                  new Container(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: TextFormField(
                        autocorrect: false,
                        textInputAction: TextInputAction.next,
                        onEditingComplete: () =>
                            FocusScope.of(context).requestFocus(focusNodeEmail),
                        //autofocus: true,
                        decoration: InputDecoration(
                          labelStyle: Styles.labelStyle,
                          hintText: AppLocalizations.of(context).ciccioBello,
                          labelText:
                              AppLocalizations.of(context).nomeDiBattaglia,
                          helperText:
                              AppLocalizations.of(context).siiCoincisoERuspante,
                          border: const UnderlineInputBorder(),
                          focusedBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: AppColors.brandPrimary),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: AppColors.inputBorderEnabled),
                          ),
                          //filled: true,
                        ),
                        onSaved: (String value) {
                          user.name = value;
                        },
                        validator: _validateName,
                      )),
                  new Container(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: TextFormField(
                        autocorrect: false,
                        keyboardType: TextInputType.emailAddress,
                        focusNode: focusNodeEmail,
                        textInputAction: TextInputAction.next,
                        onEditingComplete: () => FocusScope.of(context)
                            .requestFocus(focusNodePassword),
                        decoration: InputDecoration(
                          labelStyle: Styles.labelStyle,
                          hintText:
                              AppLocalizations.of(context).digitaLaTuaEmail,
                          labelText: AppLocalizations.of(context).email,
                          border: const UnderlineInputBorder(),
                          focusedBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: AppColors.brandPrimary),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: AppColors.inputBorderEnabled),
                          ),
                          //filled: true,
                        ),
                        onSaved: (String value) {
                          user.email = value;
                        },
                        validator: _validateEmail,
                      )),
                  new Container(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: new PasswordField(
                        //fieldKey: _passwordFieldKey,
                        hintText:
                            AppLocalizations.of(context).digitaLaTuaPassword,
                        helperText: AppLocalizations.of(context)
                            .lunghezzaMinima8Caratteri,
                        labelText: AppLocalizations.of(context).password,
                        focusNode: focusNodePassword,
                        onEditingComplete: () => FocusScope.of(context)
                            .requestFocus(new FocusNode()),
                        onSaved: (String value) {
                          user.password = value;
                        },
                        onFieldSubmitted: (String value) {
                          user.password = value;
                        },
                        validator: _validatePassword,
                      )),
                  Container(
                    padding: EdgeInsets.only(top: 40.0),
                    child: ButtonSubmit(
                      height: 48.0,
                      text: AppLocalizations.of(context).creati,
                      onTap: _handleSubmitted,
                    ),
                  ),
                ])));
  }
}
