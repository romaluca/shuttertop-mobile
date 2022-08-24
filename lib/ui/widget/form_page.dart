import 'package:flutter/material.dart';
import 'package:shuttertop/ui/widget/rainbow_gradient.dart';

class FormPage extends StatefulWidget {
  FormPage(
      {@required this.title, @required this.child, this.scaffoldKey, Key key})
      : super(key: key);

  final String title;
  final Widget child;
  final GlobalKey<ScaffoldState> scaffoldKey;

  @override
  State createState() => new FormPageState();
}

class FormPageState extends State<FormPage> {
  @override
  Widget build(BuildContext context) {
    final Widget _body = ListView(children: <Widget>[
      Container(
          padding: EdgeInsets.only(left: 36.0, top: 12.0),
          //width: 20.0,
          child: Text(
            widget.title,
            style: TextStyle(
              color: Colors.black.withOpacity(0.8),
              fontWeight: FontWeight.bold,
              fontSize: 36.0,
            ),
          )),
      Container(
          margin: EdgeInsets.only(left: 12.0, right: 12.0, top: 16.0),
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height - 44.0,
          ),
          padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 24.0),
          child: widget.child)
    ]);

    return Scaffold(
        appBar: AppBar(
          // title: Text(widget.title),
          elevation: 0.0,
        ),
        key: widget.scaffoldKey,
        backgroundColor: Colors.white,
        body: _body);
  }
}
