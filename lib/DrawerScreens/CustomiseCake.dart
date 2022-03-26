import 'package:flutter/material.dart';

class CustomiseCake extends StatefulWidget {
  const CustomiseCake({Key? key}) : super(key: key);

  @override
  State<CustomiseCake> createState() => _CustomiseCakeState();
}

class _CustomiseCakeState extends State<CustomiseCake> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("Custom cakes"),
      ),
    );
  }
}
