import 'dart:async';
import 'package:cakey/DrawerScreens/HomeScreen.dart';
import 'package:cakey/screens/WelcomeScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  User? authUser = FirebaseAuth.instance.currentUser;
  bool signedIn = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    Timer(Duration(seconds: 3), (){
      if(authUser!=null){
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen())
        );
      }else{
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => WelcomeScreen())
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            color: Colors.white ,
            image: DecorationImage(
              image: AssetImage('assets/images/splash.png'),
              fit: BoxFit.cover
            )
        ),
        child: Center(
          child: Image(
            image: Svg('assets/images/cakeylogo.svg'),
            height: 150,
            width: 150,
          ),
        ),
      ),
    );
  }
}
