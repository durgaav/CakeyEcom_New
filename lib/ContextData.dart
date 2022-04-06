import 'package:flutter/material.dart';

class ContextData extends ChangeNotifier {
  int _counter = 0;
  List assignedList = [];
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

  void setCount(int count) {
    _counter = count;
    notifyListeners();
  }

  int getcounter() => _counter;

  void addList(List addedList){
    for(int i=0;i<addedList.length;i++){
      assignedList.add(addedList[i]);
    }
    notifyListeners();
  }

  List getList() => assignedList;

}