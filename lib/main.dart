// @dart=2.9
import 'dart:async';
import 'dart:convert';
import 'package:cakey/drawermenu/CustomAppBars.dart';
import 'package:cakey/drawermenu/app_bar.dart';
import 'package:cakey/functions.dart';
import 'package:cakey/screens/utils.dart';
import 'package:flutter/scheduler.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:cakey/CommonWebSocket.dart';
import 'package:cakey/ContextData.dart';
import 'package:cakey/Dialogs.dart';
import 'package:cakey/TestScreen.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
// import 'package:location/location.dart';
import 'package:cakey/screens/SplashScreen.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Notification/Notification.dart';

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  await NotificationService().init();

  //
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
   // PermissionStatus _permissionGranted;
   // LocationData _userLocation ;
   // Location myLocation = Location();
   FirebaseMessaging messaging = null;
   StreamSubscription<ConnectivityResult> sub;
   var disconected = false;
   IO.Socket socket;
   Timer timer;
   int tempLength = 0;

  //region SOCKETS ***

  void initSocket(BuildContext context) async{

    var pr = await SharedPreferences.getInstance();

    //let data = socket?.emit("adduser", { Email: token?.result?.Email, type: token?.result?.TypeOfUser, _id: token?.result?._id, Id: token?.result?.Id, Name: token?.result?.Name })

    print("Socket connecting...");
    //AlertsAndColors().showLoader(context);
    //IO.Socket socket = IO.io('https://cakey-backend.herokuapp.com');
    socket = IO.io("${SOCKET_URL}", <String, dynamic>{
      'autoConnect': true,
      'transports': ['websocket'],
    });
    socket.connect();
    // socket.onConnect((e) {
    //   print('Connection established. $e');
    //   //Navigator.pop(context);
    // });
    // socket.onDisconnect((e){
    //   print('Connection Disconnected $e');
    //   //Navigator.pop(context);
    // });
    // socket.onConnectError((err) {
    //   print(err);
    // });
    // socket.onError((err) => print(err));

    // socket.emit("adduser",{
    //   "Email":"919876543210",
    //   "type":"Customer",
    //   "_id":"6333e3439e05797c3a35a973",
    //   "Name":"Naveen Surya",
    //   "Id":"CKYCUS-4"
    // });

    socket.on('getUser', (data) {
      print("String.....Customer");
      //chatList.add(MessageModel.fromJson(data));
      print("Socket data ... $data");
      pr.setString("socketActiveMembers", jsonEncode(data));
    });

    socket.on("Typing",(data){
      print(data);
      pr.setString("socketTyping", jsonEncode(data));
    });

    socket.on("getMessage", (data){
      print(data);
      pr.setString("socketMessages", jsonEncode(data));
      //{Consersation_Id: 63b94547ec778dc1a89bd163, Sent_By_Id: helpdeskC@gmail.com, Message: super,
      // Created_By: helpdeskC@gmail.com, Created_On: 07-01-2023 04:17 PM}
    });

    //[{userId: helpdeskC@gmail.com, socketId: 9yO0tv5y0eElbm8PAAAD, type: Helpdesk C}, {userId: 919876543210, socketId: 6B1YHt_Ux3s-SG2wAAAE, type: Customer}]
    //
    // socket.emit("adduser", { "Email": "surya@mindmade.in", "type": "vendor" });
  }

  //endregion

  @override
  void dispose() {
    // TODO: implement dispose
    sub.cancel();
    Future.delayed(Duration.zero,() async{
      var pr = await SharedPreferences.getInstance();
      pr.setString("showMoreVendor", "null");
      pr.remove("socketMessages");
      pr.remove("socketTyping");
      pr.remove("socketActiveMembers");
      pr.remove("chatListener");
      socket.disconnect();
      socket.close();
      socket.destroy();
      timer.cancel();
    });
    super.dispose();
  }

  @override
  void initState() {
    //addPrem();
    sub = Connectivity().onConnectivityChanged.listen((event) {
      print("Con status.... ${event}");
      handleNetwork(event);
      //ConnectivityResult.none
    });
    // CommonWebSocket().initSocket(context);
    Future.delayed(Duration.zero,() async{
      var pr = await SharedPreferences.getInstance();
      pr.setString("showMoreVendor", "null");
      initSocket(context);
    });

    timer = Timer.periodic(Duration(seconds:20), (timer) async {
      var pr = await SharedPreferences.getInstance();
      int lastCount = pr.getInt('lastNotiCount')??0;
      Functions().getNotifications(context).then((value){
        tempLength = value.length;

        if(tempLength > lastCount){
          setState(() {
            MyCustomAppBars.valueNotifier.value = 2;
          });
        }

      }).catchError((e){

      });
    });

    // TODO: implement initState
    messaging = FirebaseMessaging.instance;
    messaging.getToken().then((value){

    });
    FirebaseMessaging.onMessage.listen((RemoteMessage event) {
      //context.read<ContextData>().setNotiCount(1);
      //CustomAppBars().notifier = ValueNotifier(1);
      setState(() {
        MyCustomAppBars.valueNotifier.value = 2;
      });
      print(event.notification.body);
      NotificationService().showNotifications(event.notification.title, event.notification.body);
    });
    FirebaseMessaging.onMessageOpenedApp.listen((message) {

    });
    super.initState();
  }

  handleNetwork(event){
    setState(() {
      if(event == ConnectivityResult.none){
        disconected = true;
        showOverlayNotification((context) {
          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal:8,
              vertical:5
            ),
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: SafeArea(
                child: ListTile(
                  leading:Icon(Icons.wifi_off_sharp , color:  Colors.red,),
                  title: Text("Please check your internet connection",style: TextStyle(
                      fontFamily: "Poppins"
                  ),),
                ),
              ),
            ),
          );
        }, duration: Duration(milliseconds: 6000));
      }else{
        disconected = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ContextData>(
      create: (context)=>ContextData(),
      builder:(context , child){
        return OverlaySupport(
          child: AnnotatedRegion(
            value: const SystemUiOverlayStyle(
              statusBarColor: Color(0xffF5F5F5),
              // For Android.
              // Use [light] for white status bar and [dark] for black status bar.
              statusBarIconBrightness: Brightness.dark,
              // For iOS.
              // Use [dark] for white status bar and [light] for black status bar.
              statusBarBrightness: Brightness.light,
            ),
            child: MaterialApp(
                theme: ThemeData(
                    primarySwatch: buildMaterialColor(Color(0xffFE8416D))
                ),
                // theme: ThemeData.dark(),
                debugShowCheckedModeBanner: false,
                home:SplashScreen()
              // home:TestScreen()
            ),
          ),
        );
      },
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