
import 'package:flutter/foundation.dart';

class ContextData extends ChangeNotifier {

  String profileUrl = "";
  String userName = "";
  int currentIndex = 0;
  List myVendorList = [];
  bool isMyVendorAdded = false;
  bool isUpdated = false;
  String address = "";

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

  void addMyVendor(bool added){
    isMyVendorAdded = added;
    notifyListeners();
  }

  bool getAddedMyVendor()=>isMyVendorAdded;

  void setMyVendors(List myList){
    myVendorList = myList;
    notifyListeners();
  }

  List getMyVendorsList()=>myVendorList;

  void setAddress(String adrs){
    address = adrs;
    notifyListeners();
  }

  String getAddress()=>address;

  void setProfileUpdated(bool updated){
    isUpdated = updated;
    notifyListeners();
  }

  bool getDpUpdate()=>isUpdated;

}