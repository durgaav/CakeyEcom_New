import 'package:cakey/screens/code_verify.dart';
import 'package:cakey/screens/home_screen.dart';
import 'package:cakey/screens/phone_verify.dart';
import 'package:cakey/screens/welcome_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.white, // status bar color
  ));
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  User? authUser = FirebaseAuth.instance.currentUser;
  bool signedIn = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: authUser!=null?HomeScreen():WelcomeScreen()
    );
  }
}