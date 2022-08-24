import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shuttertop/misc/app_localizations.dart';
import 'package:shuttertop/misc/costants.dart';
import 'package:shuttertop/misc/shuttertop.dart';
import 'package:shuttertop/models/contest.dart';
import 'package:shuttertop/pages/contest_page.dart';
import 'package:shuttertop/services/base_service.dart';
import 'package:shuttertop/ui/widget/rainbow_gradient.dart';
import 'package:shuttertop/ui/widget/button_submit.dart';
import 'package:shuttertop/models/exceptions.dart';

class ContestCreatePage extends StatefulWidget {
  const ContestCreatePage([this.contest, this.renew = false, Key key])
      : super(key: key);

  static const String routeName = '/contestcreate';

  final Contest contest;
  final bool renew;

  @override
  State createState() => new ContestCreatePageState();
}

class _ContestData {
  String name = '';
  String description = '';
  Category category = Contest.categories.first;
  DateTime expiryAt = new DateTime.now().add(new Duration(days: 7));
}

class ContestCreatePageState extends State<ContestCreatePage>
    with WidgetsBindingObserver {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  _ContestData contestData = new _ContestData();

  bool _autovalidate = false;
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  ResponseApi<Contest> resp;

  @override
  void initState() {
    super.initState();
    try {
      WidgetsBinding.instance.addObserver(this);
      if (widget.contest != null) {
        contestData.name = widget.contest.name;
        contestData.description = widget.contest.description;
        if (!widget.renew) contestData.expiryAt = widget.contest.expiryAt;
        contestData.category = Contest.categories[widget.contest.categoryId];
      }
    } catch (error, stackTrace) {
      FlutterError.reportError(
          FlutterErrorDetails(exception: error, stack: stackTrace));
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print("----comments didChangeAppLifecycleState state=${state.toString()}");
    if (state == AppLifecycleState.paused) shuttertop.disconnect(true);
  }

  Future<Null> _handleSubmitted() async {
    resp = null;
    // await SystemChannels.textInput.invokeMethod('TextInput.hide');
    FocusScope.of(context).requestFocus(new FocusNode());
    final FormState form = _formKey.currentState;
    form.save();
    if (!form.validate()) {
      _autovalidate = true; // Start validating on every change.
      _showInSnackBar(
          AppLocalizations.of(context).sistemaGliErroriPerContinuare);
      return;
    } else if (widget.contest == null || widget.renew)
      await create(
          contestData.name.trim(),
          new DateTime.now(),
          contestData.expiryAt,
          contestData.description,
          contestData.category.id);
    else
      await edit(widget.contest.id, contestData.name, contestData.expiryAt,
          contestData.description, contestData.category.id);
    if (resp.success)
      onContestCreated(resp.element);
    else
      form.validate();
  }

  Future<Null> create(String name, DateTime startAt, DateTime expiryAt,
      String description, int categoryId) async {
    try {
      expiryAt =
          new DateTime(expiryAt.year, expiryAt.month, expiryAt.day, 23, 59, 59);
      resp = await shuttertop.contestRepository
          .create(name, startAt, expiryAt, description, categoryId);
    } on ConnException catch (e) {
      print("ERRORE DI CONNESSIONE $e");
      _showInSnackBar(
          AppLocalizations.of(context).problemiDiConnessioneAlServer);
    } catch (e) {
      print("create errore!!! $e");
      onError();
    }
  }

  Future<Null> edit(int id, String name, DateTime expiryAt, String description,
      int categoryId) async {
    try {
      expiryAt =
          new DateTime(expiryAt.year, expiryAt.month, expiryAt.day, 23, 59, 59);
      resp = await shuttertop.contestRepository
          .edit(id, name, expiryAt, description, categoryId);
    } on ConnException catch (e) {
      print("ERRORE DI CONNESSIONE $e");
      _showInSnackBar(
          AppLocalizations.of(context).problemiDiConnessioneAlServer);
    } catch (e) {
      print("edit errore!!! $e");
      onError();
    }
  }

  void onError() {}

  void _showInSnackBar(String value) {
    Scaffold.of(context).showSnackBar(new SnackBar(content: new Text(value)));
  }

  String _validateName(String value) {
    //if (value.isEmpty) return 'Name is required.';
    try {
      if (resp != null &&
          resp.errors != null &&
          resp.errors.containsKey("name")) {
        if (resp.errors["name"][0] is String)
          return resp.errors["name"][0];
        else {
          showDialog<bool>(
              context: context,
              builder: (BuildContext context) => new AlertDialog(
                      content: new Text(AppLocalizations.of(context)
                          .esisteGiaUnContestInCorsoConQuestoNome),
                      actions: <Widget>[
                        new FlatButton(
                            child: Text(AppLocalizations.of(context)
                                .cambiaNome
                                .toUpperCase()),
                            onPressed: () {
                              Navigator.pop(context, false);
                            }),
                        new FlatButton(
                            child: Text(AppLocalizations.of(context)
                                .portamici
                                .toUpperCase()),
                            onPressed: () {
                              Navigator.pop(context, true);
                            })
                      ])).then((bool res) {
            if (res)
              Navigator.of(context).pushReplacement(new MaterialPageRoute<Null>(
                  settings: const RouteSettings(name: ContestPage.routeName),
                  builder: (BuildContext context) => new ContestPage(
                        Contest.fromMap(resp.errors["name"][0][1]),
                        join: false,
                        initLoad: true,
                      )));
          });
          return resp.errors["name"][0][0];
        }
      }
    } catch (error) {
      //ignore
    }
    return null;
  }

  Future<Null> _selectDate() async {
    final DateTime now = new DateTime.now();
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: now,
        firstDate: now,
        lastDate: now.add(new Duration(days: 100)));
    if (picked != null && picked != contestData.expiryAt) {
      setState(() {
        contestData.expiryAt = picked;
      });
    }
  }

  String _getTitle() {
    try {
      return widget.renew
          ? AppLocalizations.of(context).nuovaEdizione
          : widget.contest == null
              ? AppLocalizations.of(context).nuovoContest
              : AppLocalizations.of(context).modificaContest;
    } catch (error, stackTrace) {
      FlutterError.reportError(
          FlutterErrorDetails(exception: error, stack: stackTrace));
      return "";
    }
  }

  bool _isCategoryEmpty() {
    try {
      return contestData.category.id == 0;
    } catch (error, stackTrace) {
      FlutterError.reportError(
          FlutterErrorDetails(exception: error, stack: stackTrace));
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final String title = _getTitle();
    final Widget body = Container(
        child: Form(
            key: _formKey,
            autovalidate: _autovalidate,
            child: Column(children: <Widget>[
              Expanded(
                  child: Container(
                      child: ListView(
                          padding: EdgeInsets.symmetric(
                              vertical: 12.0, horizontal: 24.0),
                          children: <Widget>[
                    Container(
                        alignment: Alignment.centerLeft,
                        //width: 20.0,

                        child: Text(
                          title,
                          style: TextStyle(
                            color: Colors.black.withOpacity(0.8),
                            fontWeight: FontWeight.bold,
                            fontSize: 36.0,
                          ),
                        )),
                    new Container(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: TextFormField(
                          //autofocus: true,
                          maxLength: 40,
                          textInputAction: TextInputAction.next,
                          enabled: !widget.renew,
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context).nome,
                            labelStyle: Styles.labelStyle,
                            helperText: AppLocalizations.of(context)
                                .nonTiDilungareTagliaCorto,
                            border: const UnderlineInputBorder(),
                            focusedBorder: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: AppColors.brandPrimary),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: AppColors.inputBorderEnabled),
                            ),
                            //filled: true,
                          ),
                          onSaved: (String value) {
                            contestData.name = value;
                          },
                          validator: _validateName,
                          initialValue: contestData.name,
                        )),
                    new Container(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: _InputDropdown(
                          labelText: AppLocalizations.of(context).terminaIl,
                          valueText: new DateFormat.yMMMMd(
                                  Localizations.localeOf(context).toString())
                              .format(contestData.expiryAt),
                          onPressed: _selectDate,
                        )),
                    new Container(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: AppLocalizations.of(context).categoria,
                              labelStyle: Styles.labelStyle,
                              hintText: AppLocalizations.of(context)
                                  .scegliUnaCategoria,
                              border: const UnderlineInputBorder(),
                              focusedBorder: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: AppColors.brandPrimary),
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: AppColors.inputBorderEnabled),
                              ),
                              //filled: true,
                            ),
                            isEmpty: _isCategoryEmpty(),
                            child: DropdownButtonHideUnderline(
                                child: DropdownButton<Category>(
                              value: contestData.category,
                              isDense: true,
                              onChanged: (Category newValue) {
                                setState(() {
                                  contestData.category = newValue;
                                });
                              },
                              items: Contest.categories.map((Category value) {
                                return DropdownMenuItem<Category>(
                                  value: value,
                                  child: Container(child: Text(value.name)),
                                );
                              }).toList(),
                            )))),
                    new Container(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: TextFormField(
                          maxLines: 5,
                          textInputAction: TextInputAction.done,
                          initialValue: contestData?.description ?? "",
                          keyboardType: TextInputType.multiline,
                          decoration: InputDecoration(
                            labelStyle: Styles.labelStyle,
                            hintText: AppLocalizations.of(context)
                                .fornisciUnaSpiegatione,
                            labelText: AppLocalizations.of(context).descrizione,

                            border: const UnderlineInputBorder(),
                            focusedBorder: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: AppColors.brandPrimary),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: AppColors.inputBorderEnabled),
                            ),
                            //filled: true,
                          ),
                          onSaved: (String value) {
                            contestData.description = value;
                          },
                        )),
                  ]))),
              Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          blurRadius: 20.0,
                          offset: Offset(15.0, 5.0),
                          spreadRadius: 5.0)
                    ],
                  ),
                  padding:
                      EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                  child: ButtonSubmit(
                    onTap: _handleSubmitted,
                    height: 36.0,
                    text: AppLocalizations.of(context).crea,
                  )),
            ])));

    return Scaffold(
        backgroundColor: Colors.white,
        body: NestedScrollView(
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverAppBar(
                  backgroundColor: Colors.white,
                  centerTitle: true,
                  iconTheme: IconThemeData(color: Colors.black),
                  title: Text("", style: Styles.header),
                  pinned: false,
                  elevation: 1.0,
                  snap: false,
                  floating: false,
                )
              ];
            },
            body: body));

    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.black),
          elevation: 0.0,
        ),
        body: body);
  }

  void onContestCreated(Contest contest) {
    try {
      Navigator.of(context).pop(contest);
    } catch (e) {
      print("ERRORE onContestCreated: $e");
    }
  }
}

class _InputDropdown extends StatelessWidget {
  const _InputDropdown(
      {Key key,
      this.child,
      this.labelText,
      this.valueText,
      this.valueStyle,
      this.onPressed})
      : super(key: key);

  final String labelText;
  final String valueText;
  final TextStyle valueStyle;
  final VoidCallback onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: Styles.labelStyle,
          border: const UnderlineInputBorder(),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.brandPrimary),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.inputBorderEnabled),
          ),
        ),
        baseStyle: valueStyle,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(valueText, style: valueStyle),
            Icon(Icons.arrow_drop_down,
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.grey.shade700
                    : Colors.white70),
          ],
        ),
      ),
    );
  }
}
