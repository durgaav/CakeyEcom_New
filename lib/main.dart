import 'package:cakey/ContextData.dart';
import 'package:cakey/TestLocation.dart';
import 'package:cakey/drawermenu/DrawerHome.dart';
import 'package:provider/provider.dart';
import 'package:cakey/screens/WelcomeScreen.dart';
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

  MaterialColor buildMaterialColor(Color color) {
    List strengths = <double>[.05];
    Map<int, Color> swatch = {};
    final int r = color.red, g = color.green, b = color.blue;


    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    strengths.forEach((strength) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    });
    return MaterialColor(color.value, swatch);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ContextData>(
      create: (context)=>ContextData(),
      child: MaterialApp(
          theme: ThemeData(
              primarySwatch: buildMaterialColor(Color(0xffFE8416D))
          ),
          // theme: ThemeData.dark(),
          debugShowCheckedModeBanner: false,
          // home:TestPage()
          home: authUser!=null?DrawerHome():WelcomeScreen()
      ),
    );
  }
}
