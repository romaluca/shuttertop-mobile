import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:shuttertop/misc/app_localizations.dart';
import 'package:shuttertop/misc/costants.dart';

enum JoinButtonMode { home, contest }

class JoinButton extends StatelessWidget {
  const JoinButton(
      {Key key,
      @required this.onTap,
      this.text,
      this.icon,
      this.mode = JoinButtonMode.contest})
      : super(key: key);

  final Function onTap;
  final String text;
  final IconData icon;
  final JoinButtonMode mode;

  @override
  Widget build(BuildContext context) {
    final Color color =
        mode == JoinButtonMode.home ? Colors.white : Colors.grey[700];
    return Material(
        color: Colors.transparent,
        child: PhysicalModel(
            elevation: 2,
            color: Colors.white,
            shadowColor: Colors.grey.withOpacity(0.3),
            borderRadius: BorderRadius.circular(24),
            child: InkWell(
                onTap: onTap,
                child: Container(
                    alignment: Alignment.center,
                    padding:
                        EdgeInsets.symmetric(vertical: 12.0, horizontal: 16),
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            icon,
                            size: icon == OMIcons.addAPhoto ? 26 : 20,
                            color: Colors.grey[700],
                          ),
                          Container(
                              margin: EdgeInsets.only(left: 8),
                              child: Text(
                                text ??
                                    AppLocalizations.of(context)
                                        .partecipa
                                        .toUpperCase(),
                                style: TextStyle(
                                    fontSize: 14.0,
                                    color: color,
                                    fontFamily: "Raleway",
                                    fontWeight: FontWeight.w600),
                                overflow: TextOverflow.ellipsis,
                              )),
                        ])))));
  }
}
