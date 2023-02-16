import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:cakey/screens/utils.dart';
import 'package:flutter/foundation.dart';

class ContextData extends ChangeNotifier {

  String profileUrl = "";
  String userName = "";
  int currentIndex = 0;
  List myVendorList = [];
  bool isMyVendorAdded = false;
  bool isUpdated = false;
  String address = "";
  List<String> addressList = [];
  Map codeDetails = {};
  bool firstUser = false;
  int notiCount = 0;

  void setFirstUser(bool val){
    firstUser = val;
    notifyListeners();
  }
  bool getFirstUser()=>firstUser;

  void setNotiCount(int noti){
    notiCount = noti;
    notifyListeners();
  }

  int getNotiCount() => notiCount;

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

  void setAddressList(List<String> list){
    addressList = list;
    notifyListeners();
  }

  List<String> getAddressList()=>addressList;

  void setCodeData(Map data){
    codeDetails = data;
    notifyListeners();
  }

  Map getCodeDetails()=>codeDetails;

  //init socket
  IO.Socket? socket;

  void setSocketData(){
    print("Socket connecting...");
    socket = IO.io(SOCKET_URL, <String, dynamic>{
      'autoConnect': true,
      'transports': ['websocket'],
    });
    socket!.connect();
    socket!.onConnect((e) {
      print('Connection established. $e');
      //Navigator.pop(context);
    });
    socket!.onDisconnect((e){
      print('Connection Disconnected $e');
      //Navigator.pop(context);
    });
    socket!.onConnectError((err) {
      print(err);
    });
    socket!.onError((err) => print(err));
    notifyListeners();
  }

  IO.Socket getSocketData() =>socket!;

}