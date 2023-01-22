import 'package:flutter/material.dart';

class RaisedButton extends StatelessWidget {

  final Function onPressed;
  final Widget child;
  final Color color;
  final ShapeBorder shape;
  const RaisedButton({
    required this.onPressed,
    required this.child,
    required this.color,
    required this.shape,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:onPressed(),
      child: Container(
        child:child,
        color:color,
      ),
    );
  }
}

