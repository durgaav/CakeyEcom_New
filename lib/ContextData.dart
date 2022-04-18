import 'package:flutter/material.dart';

class ContextData extends ChangeNotifier {

  String profileUrl = "";
  String userName = "";

  void setProfileUrl(String url){
    profileUrl = url;
    notifyListeners();
  }

  String getProfileUrl() => profileUrl;

  void setUserName(String name){
    userName = name;
    notifyListeners();
  }

  String getUserName() => userName;


}