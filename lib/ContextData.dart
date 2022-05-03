

import 'package:flutter/foundation.dart';

class ContextData extends ChangeNotifier {

  String profileUrl = "";
  String userName = "";
  int currentIndex = 0;

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

  void setCurrentIndex(int index){
    currentIndex = index;
    notifyListeners();
  }

  int getCurrentIndex()=>currentIndex;

}