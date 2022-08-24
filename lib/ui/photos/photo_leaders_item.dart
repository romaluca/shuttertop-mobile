import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shuttertop/misc/app_localizations.dart';
import 'package:shuttertop/misc/costants.dart';
import 'package:shuttertop/misc/functions.dart';
import 'package:shuttertop/misc/utils.dart';
import 'package:shuttertop/models/photo.dart';
import 'package:shuttertop/ui/widget/rainbow_gradient.dart';
import 'package:shuttertop/ui/users/avatar.dart';
import 'package:transparent_image/transparent_image.dart';

class PhotoLeadersItem extends StatelessWidget {
  PhotoLeadersItem(this.photo, this.onTap,
      {this.withPadding = false, this.margin, this.isWinner = false})
      : super(key: new ObjectKey(photo));

  final Photo photo;
  final ShowPhotoPage onTap;
  final bool withPadding;
  final bool isWinner;
  final EdgeInsets margin;

  @override
  Widget build(BuildContext context) {
    return _getBody(context);
  }

  Widget _getBody(BuildContext context) {
    double w = (MediaQuery.of(context).size.width / 2);
    w -= 16;
    return InkWell(
        onTap: () => onTap(photo),
        child: Container(
            margin: margin,
            color: Colors.white,
            height: 150.0,
            //margin: EdgeInsets.only(bottom: 3.0),
            child: Stack(
                alignment: AlignmentDirectional.center,
                children: <Widget>[
                  Positioned(
                      top: 0.0,
                      left: 0.0,
                      bottom: 0.0,
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: FadeInImage(
                            height: 200.0,
                            width: w,
                            placeholder: new MemoryImage(kTransparentImage),
                            image: new CachedNetworkImageProvider(
                                photo.getImageUrl(ImageFormat.thumb)),
                            fit: BoxFit.cover,
                            fadeInDuration: const Duration(milliseconds: 250),
                          ))),
                  Positioned(
                      bottom: 39.0,
                      child: Container(
                          child: Avatar(
                        photo.user.getImageUrl(ImageFormat.thumb_small),
                        backColor: Colors.white,
                        shadow: 0.0,
                        border: 5.0,
                        shadowColor: Colors.transparent,
                        size: 60.0,
                      ))),
                  Positioned(
                      top: 0.0,
                      right: 5.0,
                      bottom: 0.0,
                      child: Container(
                        height: 200.0,
                        width: w - 40,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.all(4.0),
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white),
                                child: Container(
                                  width: 40.0,
                                  height: 40.0,
                                  margin: EdgeInsets.only(bottom: 5.0),
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: Colors.grey[200], width: 1.0),
                                      color: Colors.white),
                                  alignment: Alignment.center,
                                  child: Text(
                                    "${photo.position}",
                                    style: new TextStyle(
                                        fontSize: 18.0,
                                        color: Colors.blueGrey[800],
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ),
                              isWinner
                                  ? Text(
                                      AppLocalizations.of(context)
                                          .winner
                                          .toUpperCase(),
                                      style: TextStyle(
                                          fontSize: 11.0,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.brandPrimary))
                                  : Container(),
                              Container(
                                  alignment: AlignmentDirectional.center,
                                  padding: EdgeInsets.only(bottom: 20.0),
                                  child: Text(
                                    "${photo.user?.name ?? ""} ",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontFamily: "Raleway",
                                        color: Colors.grey[700],
                                        fontSize: 14.0),
                                  )),
                              Text(
                                  AppLocalizations.of(context)
                                      .nTop(photo.votesCount),
                                  style: TextStyle(
                                      color: Colors.grey[400],
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15.0,
                                      fontFamily: "Raleway")),
                            ].where((Widget e) => e != null).toList()),
                      ))
                ].where((Widget e) => e != null).toList())));
  }
}
