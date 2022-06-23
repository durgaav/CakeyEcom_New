// @dart=2.9
import 'package:cakey/ContextData.dart';
import 'package:cakey/TestScreen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:location/location.dart';
import 'package:cakey/screens/SplashScreen.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'Notification/Notification.dart';


Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.white, // status bar color
  ));
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

  await Firebase.initializeApp();

  await NotificationService().init(); //
  // await NotificationService().requestIOSPermissions();

  FirebaseMessaging.onBackgroundMessage(_messageHandler);

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

Future<void> _messageHandler(RemoteMessage message) async {
  print('background message ${message.notification.body}');
  // NotificationService().showNotifications();
}

class _MyAppState extends State<MyApp> {

  User authUser = FirebaseAuth.instance.currentUser;
  bool signedIn = false;

   bool _serviceEnabled;
   PermissionStatus _permissionGranted;
   LocationData _userLocation ;
  Location myLocation = Location();

  FirebaseMessaging messaging = null;

  Future<void> addPrem() async{
    // Check if location service is enable
    _serviceEnabled = await myLocation.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await myLocation.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    // Check if permission is granted
    _permissionGranted = await myLocation.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await myLocation.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
  }

  @override
  void initState() {
    addPrem();
    // TODO: implement initState
    super.initState();
    messaging = FirebaseMessaging.instance;
    messaging.getToken().then((value){
      print("token : $value");
    });
    FirebaseMessaging.onMessage.listen((RemoteMessage event) {
      print("message recieved");
      print(event.notification.body);
      NotificationService().showNotifications(event.notification.title.toString() ,
          event.notification.body.toString() );
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print('Message clicked!');
    });

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
          home:SplashScreen()
          // home:TestScreen()
      ),
    );
  }
}


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