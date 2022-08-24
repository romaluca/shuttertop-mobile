import 'package:flutter/material.dart';

class EmptyList extends StatelessWidget {
  final IconData icon;
  final String text;

  EmptyList(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return Container(alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,  
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Icon(icon, size: 150.0, color: Colors.grey[300],),
          Text(text, style: TextStyle( color: Colors.grey[400]))
        ],
      ),
    );
  }
}
