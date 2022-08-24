import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shuttertop/misc/costants.dart';

class SearchBar extends StatelessWidget {
  final String text;
  final Function onClick;
  final Function onChanged;
  final Function onSubmitted;
  final bool enabled;
  final bool withMargin;
  final bool iconVisible;

  SearchBar(
      {this.text,
      this.enabled,
      this.onClick,
      this.onSubmitted,
      this.onChanged,
      this.withMargin = true,
      this.iconVisible = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(0.0),
      margin: withMargin ? EdgeInsets.only(left: 12.0, right: 5.0) : null,
      child: InkWell(
          onTap: onClick,
          child: Container(
              padding: EdgeInsets.all(12.0),
              child: Row(children: <Widget>[
                iconVisible
                    ? Container(
                        padding: EdgeInsets.only(right: 10.0),
                        child: Icon(Icons.search, color: AppColors.textLight),
                      )
                    : Container(),
                enabled
                    ? Expanded(
                        child: TextField(
                          autofocus: true,
                          onChanged: onChanged,
                          onSubmitted: onSubmitted,
                          style: TextStyle(color: Colors.white, fontSize: 18.0),
                          decoration: InputDecoration.collapsed(
                              hintText: text,
                              hintStyle: TextStyle(color: Colors.white70)),
                        ),
                      )
                    : Expanded(
                        child: Text(
                        text,
                        style: TextStyle(color: Colors.white, fontSize: 16.0),
                      )),
              ]))),
    );
  }
}
