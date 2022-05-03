

import 'package:flutter/foundation.dart';

class ContextData extends ChangeNotifier {

  String profileUrl = "";
  String userName = "";
  int currentIndex = 0;
  bool vendrorIsSelected = false;

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

  void setSelectVendor(bool trOrfal){
    vendrorIsSelected = trOrfal;
    notifyListeners();
  }

  bool getSelVendor()=>vendrorIsSelected;

}