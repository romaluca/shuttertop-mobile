import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shuttertop/misc/app_localizations.dart';
import 'package:shuttertop/misc/utils.dart';
import 'package:shuttertop/models/photo.dart';
import 'package:shuttertop/ui/widget/empty_list.dart';
import 'package:shuttertop/pages/photo_page.dart';
import 'package:shuttertop/ui/widget/block.dart';
import 'package:transparent_image/transparent_image.dart';

class PhotosRow extends StatelessWidget {
  PhotosRow(this.photos, this.photosCount, this.onMoreTap, this.title,
      {this.onElementTap});

  final List<Photo> photos;
  final Function onMoreTap;
  final Function onElementTap;
  final int photosCount;
  final String title;

  @override
  Widget build(BuildContext context) {
    final int maxElements = 5;
    final int photoMaxLength =
        photos.length > maxElements ? maxElements : photos.length;
    final List<Widget> listUp = <Widget>[];
    for (int i = 0; i < (photoMaxLength > 3 ? 2 : 0); i++)
      listUp.add(Expanded(
          flex: 1, child: Container(child: _buildPhoto(context, photos[i]))));

    if (listUp.length > 1)
      listUp.insert(
          1,
          Container(
            width: 8.0,
            height: 20.0,
          ));

    final List<Widget> list = <Widget>[];
    for (int i = photoMaxLength > 3 ? 2 : 0; i < photoMaxLength; i++)
      list.add(Expanded(
          flex: 1, child: Container(child: _buildPhoto(context, photos[i]))));
    if (list.length > 1)
      list.insert(
          1,
          Container(
            width: 8.0,
            height: 20.0,
          ));
    if (list.length > 3)
      list.insert(
          3,
          Container(
            width: 8.0,
            height: 20.0,
          ));
    final Row row = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: list,
      crossAxisAlignment: CrossAxisAlignment.center,
    );

    return Block(
      onTapAll: photosCount > 5 ? onMoreTap : null,
      child: new Container(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: photos.isEmpty
              ? _buildNoPhoto(context)
              : photoMaxLength > 3
                  ? new ClipRRect(
                      borderRadius: new BorderRadius.circular(5.0),
                      child: Column(
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: listUp,
                            crossAxisAlignment: CrossAxisAlignment.center,
                          ),
                          Container(
                            height: 8.0,
                            width: 20.0,
                          ),
                          row
                        ],
                      ))
                  : row),
      title: title,
      subtitle: photosCount.toString(),
    );
  }

  Widget _buildPhoto(BuildContext context, Photo photo) {
    return InkWell(
        onTap: () {
          onElementTap != null
              ? onElementTap(photo)
              : _showPhotoPage(context, photo);
        },
        child: ClipRRect(
            borderRadius: new BorderRadius.circular(8.0),
            child: Container(
                color: Colors.grey[300],
                child: FadeInImage(
                  placeholder: new MemoryImage(kTransparentImage),
                  image: new CachedNetworkImageProvider(photo.getImageUrl(
                      photos.length > 1
                          ? ImageFormat.thumb
                          : ImageFormat.medium)),
                  fit: BoxFit.cover,
                  fadeInDuration: const Duration(milliseconds: 250),
                ))));
  }

  Widget _buildMorePhoto(Photo photo) {
    return InkWell(
        onTap: onMoreTap,
        child: Stack(
          children: <Widget>[
            ClipRRect(
                borderRadius: new BorderRadius.circular(8.0),
                child: Container(
                    color: Colors.grey[300],
                    child: FadeInImage(
                      placeholder: new MemoryImage(kTransparentImage),
                      image: new CachedNetworkImageProvider(photo.getImageUrl(
                          photosCount > 2
                              ? ImageFormat.thumb
                              : ImageFormat.medium)),
                      fit: BoxFit.cover,
                      fadeInDuration: const Duration(milliseconds: 250),
                    ))),
            Positioned(
                top: 0.0,
                left: 0.0,
                right: 0.0,
                bottom: 0.0,
                child: ClipRRect(
                    borderRadius: new BorderRadius.circular(8.0),
                    child: Container(
                        alignment: Alignment.center,
                        color: Color.fromARGB(120, 0, 0, 0),
                        child: Text(
                          "+${photosCount - 3}",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 24.0,
                              fontWeight: FontWeight.w300),
                        ))))
          ],
          alignment: Alignment.center,
        ));
  }

  Widget _buildNoPhoto(BuildContext context) {
    return Container(
        padding: EdgeInsets.only(bottom: 10.0),
        child: EmptyList(Icons.camera_roll,
            AppLocalizations.of(context).nessunaFotoInserita));
  }

  void _showPhotoPage(BuildContext context, Photo photo) {
    Navigator.push(
        context,
        new MaterialPageRoute<Null>(
            settings: const RouteSettings(name: PhotoPage.routeName),
            builder: (BuildContext context) => PhotoPage(photo)));
  }
}
