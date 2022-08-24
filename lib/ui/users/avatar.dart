import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:cached_network_image/cached_network_image.dart';

class Avatar extends StatelessWidget {
  Avatar(this.avatarUrl,
      {this.border = 0.0,
      this.backColor,
      this.size = 130.0,
      this.shadow = 5.0,
      this.withFade = true,
      this.shadowColor = Colors.black38});

  final String avatarUrl;
  final double border;
  final Color backColor;
  final double size;
  final double shadow;
  final Color shadowColor;
  final bool withFade;

  @override
  Widget build(BuildContext context) {
    if (border == 0.0) return getAvatar();
    return Container(
        decoration: BoxDecoration(
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: shadowColor,
              blurRadius: shadow,
            ),
          ],
          shape: BoxShape.circle,
          color: backColor,
        ),
        padding: EdgeInsets.all(border),
        child: getAvatar());
  }

  Widget getAvatar() {
    final List<Widget> content = <Widget>[
      Icon(
        Icons.person,
        color: Colors.white,
        size: size - 10.0,
      ),
    ];

    if (avatarUrl != null) {
      content.add(ClipOval(
        child: FadeInImage(
          placeholder: new MemoryImage(kTransparentImage),
          image: new CachedNetworkImageProvider(avatarUrl),
          fit: BoxFit.cover,
          fadeInDuration: Duration(milliseconds: withFade ? 250 : 0),
        ),
      ));
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        shape: BoxShape.circle,
      ),
      child: Stack(
        alignment: Alignment.center,
        fit: StackFit.expand,
        children: content,
      ),
    );
  }
}
