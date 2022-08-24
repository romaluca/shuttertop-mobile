import 'package:flutter/material.dart';
import 'package:shuttertop/misc/app_localizations.dart';
import 'package:shuttertop/misc/functions.dart';
import 'package:shuttertop/models/comment.dart';
import 'package:shuttertop/models/entity_base.dart';
import 'package:shuttertop/ui/activities/comment_input.dart';
import 'package:shuttertop/ui/activities/comment_list_item.dart';
import 'package:shuttertop/ui/widget/block.dart';

class CommentBlock extends StatelessWidget {
  CommentBlock(this.element, this.onTapAllComments, this.onTapUser);
  final EntityBase element;
  final ShowCommentsPage onTapAllComments;
  final ShowUserPage onTapUser;

  int _getMaxCommentsLength() {
    try {
      return element.comments.length > 3 ? element.comments.length - 3 : 0;
    } catch (error, stackTrace) {
      FlutterError.reportError(
          FlutterErrorDetails(exception: error, stack: stackTrace));
      return 0;
    }
  }

  bool _isWithShowMore() {
    try {
      return element.commentsCount > 3;
    } catch (error, stackTrace) {
      FlutterError.reportError(
          FlutterErrorDetails(exception: error, stack: stackTrace));
      return false;
    }
  }

  String _getShowMoreText(BuildContext context) {
    try {
      return AppLocalizations.of(context)
          .vediTuttiINCommenti(element.commentsCount);
    } catch (error, stackTrace) {
      FlutterError.reportError(
          FlutterErrorDetails(exception: error, stack: stackTrace));
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> list = <Widget>[];

    list.addAll(element.comments
        .sublist(_getMaxCommentsLength())
        .map((Comment comment) => CommentListItem(
              comment,
              onTapUser,
            ))
        .toList());
    if (_isWithShowMore())
      list.add(InkWell(
          onTap: () => onTapAllComments(element, edit: false),
          child: Container(
              padding: EdgeInsets.symmetric(vertical: 10.0),
              alignment: Alignment.center,
              child: Text(
                _getShowMoreText(context),
              ))));
    list.add(CommentInput(element, onTapAllComments));
    return Container(
        child: Block(
            title: AppLocalizations.of(context).commenti,
            child: Container(
                padding: EdgeInsets.only(top: 12.0),
                child: Column(children: list))));
  }
}
