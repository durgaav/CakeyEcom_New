import 'package:flutter/material.dart';

class CustomRaisedButton extends StatelessWidget {

  VoidCallback? onPressed;
  Color? color;
  Widget? child;

  CustomRaisedButton({
    required this.onPressed,
    this.color,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:onPressed,
      child: Container(
        alignment:Alignment.center,
        decoration:BoxDecoration(
          color:color,
          borderRadius:BorderRadius.circular(25)
        ),
        child:child,
      ),
    );
  }
}
