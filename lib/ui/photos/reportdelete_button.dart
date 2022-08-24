import 'package:flutter/material.dart';
import 'package:shuttertop/misc/app_localizations.dart';
import 'package:shuttertop/misc/shuttertop.dart';
import 'package:shuttertop/models/contest.dart';
import 'package:shuttertop/models/iphotoable.dart';
import 'package:shuttertop/models/photo.dart';

class ReportDeleteButton extends StatelessWidget {
  const ReportDeleteButton(
    this.photo, {
    this.element,
    Key key,
  }) : super(key: key);

  final Photo photo;
  final IPhotoable element;

  void _report(BuildContext context, Photo photo) async {
    final String risp = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        String value = "";
        return AlertDialog(
          title: new Text(AppLocalizations.of(context).percheNonTiAggrada),
          content: new TextField(
            autofocus: true,
            onChanged: (String text) {
              value = text;
            },
            decoration: new InputDecoration(
                labelText: AppLocalizations.of(context).motivo,
                hintText: AppLocalizations.of(context).esScombinaIlMioCervello),
          ),
          actions: <Widget>[
            new FlatButton(
              child: new Text(AppLocalizations.of(context).annulla),
              onPressed: () {
                Navigator.of(context).pop(null);
              },
            ),
            new FlatButton(
              child: new Text(AppLocalizations.of(context).invia),
              onPressed: () {
                Navigator.of(context).pop(value);
              },
            ),
          ],
        );
      },
    );
    if (risp != null) shuttertop.photoRepository.report(photo, risp);
  }

  void _delete(BuildContext context, Photo photo) async {
    final bool risp = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text(AppLocalizations.of(context).seiSicuro),
          actions: <Widget>[
            new FlatButton(
              child: new Text(AppLocalizations.of(context).annulla),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            new FlatButton(
              child: new Text(AppLocalizations.of(context).invia),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
    if (risp && await shuttertop.photoRepository.delete(photo)) {
      if (element != null) {
        element.photos.remove(photo);
        if (element is Contest) {
          final Contest c = element;
          c.leaders.remove(photo);
        }
        element.photosCount--;
        print("element.photosCount--; : ${element.photosCount}");
      }
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return new PopupMenuButton<BottomNavigationBarType>(
      onSelected: (BottomNavigationBarType value) {
        if (photo.user.id == shuttertop.currentUserId)
          _delete(context, photo);
        else
          _report(context, photo);
      },
      itemBuilder: (BuildContext context) =>
          <PopupMenuItem<BottomNavigationBarType>>[
            PopupMenuItem<BottomNavigationBarType>(
              value: BottomNavigationBarType.fixed,
              child: Text(photo.user.id == shuttertop.currentUserId
                  ? AppLocalizations.of(context).rimuovi
                  : AppLocalizations.of(context).segnala),
            ),
          ],
    );
  }
}
