import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:shuttertop/misc/utils.dart';
import 'package:shuttertop/models/iphotoable.dart';
import 'package:shuttertop/ui/widget/image_zoomable.dart';
//import 'package:zoomable_image/zoomable_image.dart';

class ImageFullScreenPage extends StatefulWidget {
  ImageFullScreenPage(this.element);

  static const String routeName = '/fullpage';

  final IPhotoable element;

  @override
  _ImageFullScreenPageState createState() => new _ImageFullScreenPageState();
}

class _ImageFullScreenPageState extends State<ImageFullScreenPage>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();

    SystemChrome.setEnabledSystemUIOverlays(<SystemUiOverlay>[]);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    super.dispose();
  }

  String _getElementImage() {
    try {
      return widget.element.getImageUrl(ImageFormat.normal);
    } catch (error, stackTrace) {
      FlutterError.reportError(
          FlutterErrorDetails(exception: error, stack: stackTrace));
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Stack(fit: StackFit.expand, children: <Widget>[
          new ImageZoomable(new CachedNetworkImageProvider(_getElementImage())),
          Positioned(
            top: 0.0,
            right: 0.0,
            child: IconButton(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 24.0,
                )),
          ),
        ]));
  }
}
