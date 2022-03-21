import 'package:cakey/screens/phone_verify.dart';
import 'package:cakey/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


void main(){
  runApp(MyApp());
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.white, // status bar color
  ));
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WelcomeScreen(),
    );
  }
}

