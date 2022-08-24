import 'package:flutter/material.dart';
import 'package:shuttertop/misc/notifications.dart';

class HighLightedIcon extends StatefulWidget {
  final IconData icon;
  final double size;
  final Color color;
  final AnimationNotification notify;

  HighLightedIcon(
    this.icon, {
    Key key,
    this.size = 24.0,
    this.color,
  })
      : notify = new AnimationNotification(), super(key: key);

  @override
    _AnimatedIconState createState() => new _AnimatedIconState();
     
  
}

class _AnimatedIconState extends State<HighLightedIcon>
    with SingleTickerProviderStateMixin {
  final double dx = 20.0;
  AnimationController controller;
  Animation<double> animation;
  Animation<double> animationOpacity;

  @override
  void initState() {
    super.initState();
    controller = new AnimationController(
        duration: const Duration(milliseconds: 400), vsync: this);
    animation = new Tween<double>(begin: widget.size, end: widget.size + dx)
        .animate(controller);
    animationOpacity = new Tween<double>(begin: 0.0, end: 1.0)
        .animate(controller);        

    animation.addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.completed) {
        controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        widget.notify.dispatch(context);
        /*
        new Future<Null>.delayed(const Duration(seconds: 2), () {
          if (!mounted) return;
          controller?.forward();
        });*/
      }
    });
    controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new _Animator(
      icon: widget.icon,
      animation: animation,
      animationOpacity: animationOpacity,
      color: widget.color,
      size: widget.size + dx,
    );
  }
}

class _Animator extends AnimatedWidget {
  final double size;
  final IconData icon;
  final Color color;
  final Animation<double> animationOpacity;
  _Animator({
    Key key,
    this.icon,
    this.size,
    this.color,
    Animation<double> animation,
    this.animationOpacity,
  })
      : super(key: key, listenable: animation);

  @override
  Widget build(BuildContext context) {
    final Animation<double> animation = listenable;
    
    return new Opacity(
  opacity: animationOpacity.value,
  child: new Container(
      width: size,
      height: size,
      
      child: new Center(
        child: new Icon(
          icon,
          size: animation.value,
          color: color,

        ),
      ),
    ));
  }
}