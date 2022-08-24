import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';


class ImageZoomable extends StatefulWidget {
  final ImageProvider image;
  final double maxScale;
  final GestureTapCallback onTap;
  final Color backgroundColor;
  final Widget placeholder;
  final Function notifyScaling;

  ImageZoomable(
    this.image, {
    Key key,

    /// Maximum ratio to blow up image pixels. A value of 2.0 means that the
    /// a single device pixel will be rendered as up to 4 logical pixels.
    this.maxScale = 2.0,
    this.onTap,
    this.backgroundColor = Colors.black,
    this.notifyScaling,
    /// Placeholder widget to be used while [image] is being resolved.
    this.placeholder,
  }) : super(key: key);

  @override
  _ZoomableImageState createState() => new _ZoomableImageState();
}

// See /flutter/examples/layers/widgets/gestures.dart
class _ZoomableImageState extends State<ImageZoomable> {
  ImageStream _imageStream;
  ui.Image _image;
  Size _imageSize;

  Offset _startingFocalPoint;

  Offset _previousOffset;
  Offset _updateOffset;
  Offset _offset; // where the top left corner of the image is drawn

  double _previousScale;
  double _scale; 
  double _initialScale;// multiplier applied to scale the full image

  Orientation _previousOrientation;

  Size _canvasSize;
  

  void _centerAndScaleImage() {
    _imageSize = new Size(
      _image.width.toDouble(),
      _image.height.toDouble(),
    );

    _scale = math.min(
      _canvasSize.width / _imageSize.width,
      _canvasSize.height / _imageSize.height,
    );
    final Size fitted = new Size(
      _imageSize.width * _scale,
      _imageSize.height * _scale,
    );

    final Offset delta = _canvasSize - fitted;
    _offset = delta / 2.0; // Centers the image
    _initialScale = _scale;
    print(_scale);
    if(widget.notifyScaling != null) widget.notifyScaling(false);
  }

  Function() _handleDoubleTap(BuildContext ctx) {
    return () {
      final double newScale = _scale * 2;
      if (newScale > widget.maxScale) {
        _centerAndScaleImage();
        setState(() {});
        return;
      }

      // We want to zoom in on the center of the screen.
      // Since we're zooming by a factor of 2, we want the new offset to be twice
      // as far from the center in both width and height than it is now.
      final Offset center = ctx.size.center(Offset.zero);
      final Offset newOffset = _offset - (center - _offset);

      setState(() {
        _scale = newScale;
        _offset = newOffset;
      });
      if(widget.notifyScaling != null) widget.notifyScaling(true);
    };
  }

  void _handleScaleStart(ScaleStartDetails d) {
    print("starting scale at ${d.focalPoint} from $_offset $_scale");
    _startingFocalPoint = d.focalPoint;
    _previousOffset = _offset;
    _updateOffset = _offset;
    _previousScale = _scale;
  }

  void _handleScaleUpdate(ScaleUpdateDetails d) {
    final double newScale = _previousScale * d.scale;
    if (newScale > widget.maxScale || newScale <= _initialScale) {
      return;
    }

    
    // Ensure that item under the focal point stays in the same place despite zooming
    final Offset normalizedOffset =
        (_startingFocalPoint - _previousOffset) / _previousScale;
    Offset newOffset = d.focalPoint - normalizedOffset * newScale;
    
    if (newScale == _previousScale) {
      final double iWidth = _imageSize.width * newScale;
      if(newOffset.dx > 0 || newOffset.dx + iWidth < _canvasSize.width) {
        newOffset = new Offset(_updateOffset.dx, newOffset.dy);
      }
      final double iHeight = _imageSize.height * newScale;
      if(newOffset.dy > 0 || newOffset.dy + iHeight < _canvasSize.height) {        
        newOffset = new Offset(newOffset.dx, _updateOffset.dy);
      }
    }
    if(_scale != newScale)
      if(widget.notifyScaling != null) widget.notifyScaling(newScale > _initialScale);
    setState(() {
      _scale = newScale;
      _updateOffset = newOffset;
      _offset = newOffset;
    });
      

  }

  

  @override
  Widget build(BuildContext ctx) {
    Widget paintWidget() {
      return new CustomPaint(
        
        child: new Container(color: widget.backgroundColor),
        foregroundPainter: new _ZoomableImagePainter(
          image: _image,
          offset: _offset,
          scale: _scale,
          initialScale: _initialScale,

        ),
      );
    }

    if (_image == null) {
      return widget.placeholder;
    }

    return new LayoutBuilder(builder: (BuildContext ctx, BoxConstraints constraints) {
      final Orientation orientation = MediaQuery.of(ctx).orientation;
      if (orientation != _previousOrientation) {
        _previousOrientation = orientation;
        _canvasSize = constraints.biggest;
        _centerAndScaleImage();
      }

      return new GestureDetector(
        child: paintWidget(),
        onTap: widget.onTap,
        onDoubleTap: _handleDoubleTap(ctx),
        onScaleStart: _handleScaleStart,
        onScaleUpdate: _handleScaleUpdate,
      );
    });
  }

  @override
  void didChangeDependencies() {
    _resolveImage();
    super.didChangeDependencies();
  }

  @override
  void reassemble() {
    _resolveImage(); // in case the image cache was flushed
    super.reassemble();
  }

  void _resolveImage() {
    _imageStream = widget.image.resolve(createLocalImageConfiguration(context));
    _imageStream.addListener(_handleImageLoaded);
  }

  void _handleImageLoaded(ImageInfo info, bool synchronousCall) {
    print("image loaded: $info");
    setState(() {
      _image = info.image;
    });
  }

  @override
  void dispose() {
    _imageStream.removeListener(_handleImageLoaded);
    super.dispose();
  }
}

class _ZoomableImagePainter extends CustomPainter {
  const _ZoomableImagePainter({this.image, this.offset, this.scale, this.initialScale});

  final ui.Image image;
  final Offset offset;
  final double scale;
  final double initialScale;

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final Size imageSize = new Size(image.width.toDouble(), image.height.toDouble());
    final Size targetSize = imageSize * scale;

    paintImage(
      canvas: canvas,
      rect: offset & targetSize,
      image: image,
      fit: BoxFit.fill,
    );
  }

  @override
  bool shouldRepaint(_ZoomableImagePainter old) {
    return old.image != image || old.offset != offset || old.scale != scale;
  }
}