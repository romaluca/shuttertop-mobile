import 'package:flutter/material.dart';
import 'package:shuttertop/misc/app_localizations.dart';
import 'package:shuttertop/misc/costants.dart';
import 'package:shuttertop/models/contest.dart';

class ContestFiltersDialog extends StatefulWidget {
  final Category category;

  ContestFiltersDialog(this.category);

  @override
  ContestFiltersDialogState createState() => new ContestFiltersDialogState();
}

class ContestFiltersDialogState extends State<ContestFiltersDialog> {
  final double padding = 12.0;
  Category category;

  @override
  void initState() {
    super.initState();
    try {
      category = widget.category;
    } catch (error, stackTrace) {
      FlutterError.reportError(
          FlutterErrorDetails(exception: error, stack: stackTrace));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: NestedScrollView(
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverAppBar(
                  backgroundColor: Colors.white,
                  iconTheme: IconThemeData(color: Colors.black),
                  title: Text(AppLocalizations.of(context).filtriContest,
                      style: TextStyle()),
                  pinned: true,
                  elevation: 1.0,
                  snap: false,
                  floating: false,
                  actions: <FlatButton>[
                    FlatButton(
                        onPressed: () {
                          Navigator.of(context).pop(category);
                        },
                        child: Text(
                            AppLocalizations.of(context).salva.toUpperCase(),
                            style: TextStyle(color: AppColors.brandPrimary))),
                  ],
                )
              ];
            },
            body: Container(
                child: new Padding(
                    padding: const EdgeInsets.only(
                        bottom: 32.0, left: 32.0, right: 32.0),
                    child: ListView(
                      children: <Widget>[
                        Container(
                            padding: EdgeInsets.only(
                                bottom: padding, top: padding * 2),
                            child: Text(
                              AppLocalizations.of(context).categorie,
                              style: TextStyle(
                                  fontSize: 18.0, fontWeight: FontWeight.w500),
                            )),
                      ]..addAll(Contest.categories
                          .map((Category f) => elementCheckable(
                              f.name == ""
                                  ? AppLocalizations.of(context).tutte
                                  : f.name,
                              category.id == f.id,
                              () => category = f))
                          .toList()),
                    )))));
  }

  Widget elementCheckable(String text, bool checked, Function onTap) {
    return InkWell(
        onTap: () {
          onTap();
          setState(() {});
        },
        child: Container(
            height: 50.0,
            padding: EdgeInsets.symmetric(vertical: padding),
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(text),
                  checked
                      ? Icon(
                          Icons.done,
                          color: AppColors.brandPrimary,
                        )
                      : Container()
                ])));
  }
}
