import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shuttertop/misc/app_localizations.dart';
import 'package:shuttertop/misc/notifications.dart';
import 'package:shuttertop/models/iphotoable.dart';
import 'package:shuttertop/models/photo.dart';
import 'package:shuttertop/pages/photo_slide_page.dart';
import 'package:shuttertop/services/base_service.dart';
import 'package:shuttertop/ui/photos/photo_list_item.dart';
import 'package:shuttertop/ui/widget/empty_list.dart';
import 'package:shuttertop/ui/widget/load_grid_view.dart';
import 'package:shuttertop/ui/widget/load_list_view.dart';
import 'package:shuttertop/misc/shuttertop.dart';
import 'package:shuttertop/ui/widget/simple_page.dart';

class ElementPhotosPage extends StatefulWidget {
  final IPhotoable element;
  final PhotosFetchType type;

  static const String routeName = '/user_photos';

  ElementPhotosPage(this.element, {this.type = PhotosFetchType.all});
  @override
  _ElementPhotosPageState createState() => new _ElementPhotosPageState();
}

class _ElementPhotosPageState extends State<ElementPhotosPage> {
  final List<Photo> elements = <Photo>[];

  String _getSubtitle() {
    switch (widget.type) {
      case PhotosFetchType.wins:
        return AppLocalizations.of(context).vittorie;
      case PhotosFetchType.inProgress:
        return AppLocalizations.of(context).gareInCorso;
      default:
        return AppLocalizations.of(context).foto;
    }
  }

  Widget _getEmptyWidget() {
    switch (widget.type) {
      case PhotosFetchType.wins:
        return EmptyList(
            Icons.star, AppLocalizations.of(context).nonCiSonoStateVittorie);
      case PhotosFetchType.inProgress:
        return EmptyList(
            Icons.timelapse, AppLocalizations.of(context).nonCiSonoGareInCorso);
      default:
        return EmptyList(
            Icons.camera_roll, AppLocalizations.of(context).nonCiSonoFoto);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String subtitle = _getSubtitle();
    return SimplePage(
      widget.element.name,
      new NotificationListener<EntityNotification>(
          onNotification: _onNotify,
          child: Container(
              padding: const EdgeInsets.only(top: 16.0),
              child: LoadingGridView<Photo>(_loadPhotos,

                  // elements: elements,
                  widgetAdapter: _adaptPhotos,
                  // emptyWidget: _getEmptyWidget(),
                  indexer: (Photo e) => e.id))),
      subtitle: subtitle,
    );
  }

  bool _onNotify(EntityNotification notification) {
    setState(() {});
    return false;
  }

  Widget _adaptPhotos(List<Photo> photos, int index) {
    return PhotoListItem(
      photo: photos[index],
      onTap: (Photo p) => _showPhotoSlidePage(photos, index),
    );
  }

  void _showPhotoSlidePage(List<Photo> photos, int index) {
    print("--------photo slide page ${widget.element.photos.length}");

    Navigator.push(
        context,
        new MaterialPageRoute<Null>(
            settings: const RouteSettings(name: PhotoSlidePage.routeName),
            builder: (BuildContext context) => PhotoSlidePage(
                  photos,
                  element: widget.element,
                  params: <String, String>{
                    widget.element.fieldId: widget.element.id.toString()
                  },
                  index: index,
                )));

    setState(() {});
  }

  Future<RequestListPage<Photo>> _loadPhotos(int page) async {
    return await shuttertop.photoRepository
        .fetch(widget.element, page: page, type: widget.type);
  }
}
