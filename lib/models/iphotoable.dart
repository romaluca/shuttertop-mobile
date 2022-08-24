import 'package:shuttertop/misc/utils.dart';
import 'package:shuttertop/models/photo.dart';

abstract class IPhotoable {
  final int id;
  final String name;
  final List<Photo> photos;
  int photosCount;

  IPhotoable({this.name, this.id, this.photos, this.photosCount});

  String getImageUrl(ImageFormat size);

  String get fieldId;
}
