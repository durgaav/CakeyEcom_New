import 'package:cakey/DrawerScreens/Notifications.dart';
import 'package:cakey/main.dart';
import 'package:cakey/screens/ChatScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {

  //Singleton pattern
  static final NotificationService _notificationService =
  NotificationService._internal();
  factory NotificationService() {
    return _notificationService;
  }
  NotificationService._internal();
  var notificationData = {};

  //instance of FlutterLocalNotificationsPlugin
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();


  Future<void> init() async {

    //Initialization Settings for Android
    final AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('cakeylogo');

    //Initialization Settings for iOS
    final IOSInitializationSettings initializationSettingsIOS =
    IOSInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );

    //InitializationSettings for initializing settings for both platforms (Android & iOS)
    final InitializationSettings initializationSettings =
    InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onSelectNotification:(payload){

        if(payload.toString().toLowerCase()=="chat"){
          Navigator.push(navigatorKey.currentState!.context,MaterialPageRoute(builder: (builder)=>ChatScreen(
            notificationData['Sent_By_Id'] , notificationData['Consersation_Id'] , notificationData['Sent_By_Id'] , online: true,
          )));
        }else{
          Navigator.push(
              navigatorKey.currentState!.context,
              MaterialPageRoute(builder: (context)=>Notifications())
          );
        }
      }
    );
  }

  AndroidNotificationDetails _androidNotificationDetails = AndroidNotificationDetails(
    'channel ID',
    'channel name',
    // 'channel description',
    playSound: true,
    priority: Priority.high,
    importance: Importance.high,
  );

  Future<void> showNotifications(String title , String description,[String payload="null",var data]) async {

    if(data!=null){
      notificationData = data;
    }

    NotificationDetails platformChannelSpecifics =
    NotificationDetails(
        android: _androidNotificationDetails,
        iOS: null
    );

    await flutterLocalNotificationsPlugin.show(
      123,
      '$title',
      '$description',
      platformChannelSpecifics,
      payload:payload,
    );

  }

}