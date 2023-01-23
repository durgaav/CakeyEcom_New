import 'dart:convert';
import 'dart:io';
import 'package:cakey/ContextData.dart';
import 'package:cakey/Dialogs.dart';
import 'package:cakey/Notification/Notification.dart';
import 'package:cakey/functions.dart';
import 'package:cakey/screens/AddressScreen.dart';
import 'package:cakey/screens/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mime/mime.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as Path;
import 'package:http_parser/http_parser.dart';
import 'package:url_launcher/url_launcher.dart';
import '../DrawerScreens/CakeTypes.dart';
import '../DrawerScreens/Notifications.dart';
import 'WelcomeScreen.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class Profile extends StatefulWidget {
  int defindex = 0 ;
  Profile({required this.defindex});

  @override
  State<Profile> createState() => _ProfileState(defindex: defindex);
}

class _ProfileState extends State<Profile> with SingleTickerProviderStateMixin {

  //get tab index from pre screen
  int defindex = 0 ;
  _ProfileState({required this.defindex});

  //Colors...
  Color lightGrey =  Color(0xffF5F5F5);
  Color darkBlue =  Color(0xffF213959);
  Color lightPink = Color(0xffFE8416D);

  //for tabs...
  late TabController tabControl ;
  //for expand the tiles..
  List<bool> isExpands = [];
  List recentOrders = [];
  List vendorsList = [];
  String notifyId = "";
  bool notifiOnOrOf = true;
  bool isLoading = true;

  //Phone number
  String phoneNumber = "";
  String authToken = "";
  String selectedAdres = '';

  //file
  File file = new File("");

  //users details
  String userID = "";
  String userAddress = "";
  String userProfileUrl = "";
  String userName = "";
  String fbToken = '';

  //date and time
  int year = 0;
  int month = 0;
  int day = 0;
  int min = 0;
  int hour = 0;
  int days = 0;
  int hours = 0;
  int minutes = 0;
  int seconds = 0;
  int notiCount = 0;

  //sockets
  IO.Socket? socket;

  //Edit text Controllers...
  var userNameCtrl = new TextEditingController();
  var userAddrCtrl = new TextEditingController();
  var pinCodeCtrl = new TextEditingController();

  List<String> addressList=[]; //address list


  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();

  //On start activity..
  @override
  void initState() {
    // TODO: implement initState
    tabControl = new TabController(length: 2,vsync: this,initialIndex: defindex);
    Future.delayed(Duration.zero, () async{
      initSocket(context);
      loadPrefs();
    });
    super.initState();
  }

  //On destroy
  @override
  void dispose() {
    // TODO: implement dispose
    file = new File('');
    super.dispose();
  }

  //socket init
  initSocket(BuildContext context) {

    //let data = socket?.emit("adduser", { Email: token?.result?.Email, type: token?.result?.TypeOfUser, _id: token?.result?._id, Id: token?.result?.Id, Name: token?.result?.Name })

    print("Socket connecting...");
    //AlertsAndColors().showLoader(context);
    //IO.Socket socket = IO.io('https://cakey-backend.herokuapp.com');
    //socket = IO.io("http://sugitechnologies.com:3001", <String, dynamic>{
    socket = IO.io("$SOCKET_URL", <String, dynamic>{
      'autoConnect': true,
      'transports': ['websocket'],
    });
    // socket!.connect();
    // socket!.onConnect((e) {
    //   print('Connection established. $e');
    //   //Navigator.pop(context);
    // });
    // socket!.onDisconnect((e){
    //   print('Connection Disconnected $e');
    //   //Navigator.pop(context);
    // });
    // socket!.onConnectError((err) {
    //   print(err);
    //   //Navigator.pop(context);
    // });
    // socket!.onError((err) => print(err));

    //socket?.emit("adduser", { Email: token?.result?.Email, type: "helpDeskv" })

    // socket.on('getMessage', (newMessage) {
    //   //chatList.add(MessageModel.fromJson(data));
    //   print(newMessage);
    // });
    //
    // socket.emit("adduser", { "Email": "surya@mindmade.in", "type": "vendor" });
  }

  //loadPrefs
  Future<void> loadPrefs() async {
    var prefs = await SharedPreferences.getInstance();
    setState(() {
      phoneNumber = prefs.getString("phoneNumber") ?? "";
      authToken = prefs.getString("authToken") ?? 'no auth';
      addressList = prefs.getStringList('addressList')??[];

      print('addressList... $addressList');

      fetchProfileByPhn();
    });
  }


  //region Alerts....

  //Logout dialog

  void showlogoutDialog() {
    showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)
            ),
            title: Text('Logout'
              ,style: TextStyle(color: darkBlue,fontWeight: FontWeight.bold,fontFamily: "Poppins"),
            ),
            content: Text('Are you sure? you will be logged out!',
              style: TextStyle(color: Colors.black,fontWeight: FontWeight.normal,fontFamily: "Poppins"),
            ),
            actions: [
              TextButton(
                onPressed: (){
                  Navigator.pop(context);
                },
                child: Text('Cancel',
                  style: TextStyle(color: Colors.deepPurple,fontFamily: "Poppins"),
                ),
              ),
              TextButton(
                onPressed: (){
                  Navigator.pop(context);
                  Future.delayed(Duration.zero,() async{
                    var pr = await SharedPreferences.getInstance();
                    pr.setString("showMoreVendor", "null");
                    pr.remove("socketMessages");
                    pr.remove("socketTyping");
                    pr.remove("socketActiveMembers");
                    pr.remove("chatListener");
                    socket!.disconnect();
                    socket!.close();
                    socket!.destroy();
                  });
                  FirebaseAuth.instance.signOut();
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => WelcomeScreen()
                      ),
                      ModalRoute.withName('/WelcomeScreen')
                  );
                },
                child: Text('Logout',
                  style: TextStyle(color: Colors.deepPurple,fontFamily: "Poppins"),
                ),
              ),
            ],
          );
        }
    );
  }

  //Alert Dialog....
  void showAlertDialog(){
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context){
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)
            ),
            content: Container(
              height: 75,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // CircularProgressIndicator(),
                  CupertinoActivityIndicator(
                    radius: 17,
                    color: lightPink,
                  ),
                  SizedBox(height: 13,),
                  Text('Please Wait...',style: TextStyle(
                    color: Colors.black,
                    fontFamily: 'Poppins',
                  ),)
                ],
              ),
            ),
          );
        }
    );
  }

  //endregion

  //region Functions....

  //Update the profile
  Future<void> updateProfile([String tokenId="null"]) async {
    var prefs = await SharedPreferences.getInstance();

    print(tokenId);

    showAlertDialog();
    try{
      //without profile img....
      var request = http.MultipartRequest('PUT',
          Uri.parse(
              '${API_URL}api/users/update/$userID'));
      request.headers['Content-Type'] = 'multipart/form-data';

      request.fields.addAll({
        'UserName': userNameCtrl.text.isEmpty?"$userName":userNameCtrl.text,
        'Address': userAddrCtrl.text.isEmpty?"$userAddress":userAddrCtrl.text,
        'Notification':!notifiOnOrOf?'n':"y",
        'Notification_Id':'$tokenId',
        "Pincode":pinCodeCtrl.text
      });


      if(file.path.isNotEmpty){
        request.files.add(await http.MultipartFile.fromPath(
            'file', file.path.toString(),
            filename: Path.basename(file.path),
            contentType: MediaType.parse(lookupMimeType(file.path.toString()).toString())
        ));
      }

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {

        print(await response.stream.bytesToString());

        prefs.setBool("newRegUser", false);
        prefs.setString("userName", userName);
        prefs.setString("userAddress", userAddress);

        Navigator.pop(context);

        context.read<ContextData>().setProfileUpdated(true);
        context.read<ContextData>().setAddress(userAddrCtrl.text);

        setState(() {
          file = new File('');
          fetchProfileByPhn();
        });


        if(addressList.contains(userAddrCtrl.text+" "+pinCodeCtrl.text)){

        }else{
          addressList.add(userAddrCtrl.text+" "+pinCodeCtrl.text);
          context.read<ContextData>().setAddressList(addressList);
          prefs.setStringList('addressList', addressList);
        }

        Functions().showSnackMsg(context,"Profile data updated!", false);

      }
      else {
        Navigator.pop(context);
        checkNetwork();
        Functions().showSnackMsg(context,"Unable to update profile data!", false);
      }
    }catch(error){
      Navigator.pop(context);
      print(error);
      checkNetwork();
    }
  }

  //Order Cancellations
  Future<void> cancelOrder(String id , String byId, String cakeName,int index) async{
    showAlertDialog();
    var headers = {
      'Content-Type': 'application/json'
    };
    var request = http.Request('PUT', Uri.parse('${API_URL}api/order/cancel/$id'));
    request.body = json.encode({
      "Cancelled_By": "User",
      "Status_Updated_By": "$byId"
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {

      var map = jsonDecode(await response.stream.bytesToString());

      if(map["statusCode"]==200){

        Functions().showSnackMsg(context,"${map['message']}", false);
        sendNotificationToVendor(notifyId, index);
        getOrderList(userID);
        NotificationService().showNotifications("Order Cancelled", "Your $cakeName order is cancelled.");
      }else{
        Navigator.pop(context);
        Functions().showSnackMsg(context,"${map['message']}", false);
      }


      // Navigator.pop(context);
    }
    else {
      print(response.reasonPhrase);
      Functions().showSnackMsg(context,"Error!", false);
      Navigator.pop(context);
    }
  }

  //cancel hamper
  Future<void> cancelHamperOrder(String id , int index ,String hamName) async{

    print(userName);

    showAlertDialog();

    var headers = {
      'Content-Type': 'application/json'
    };
    var request = http.Request('PUT', Uri.parse('${API_URL}api/hamperorder/canceled/$id'));
    request.body = json.encode({
      "Cancelled_By": "User"
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {

      var map = jsonDecode(await response.stream.bytesToString());

      if(map["statusCode"]==200){

        Functions().showSnackMsg(context,"${map['message']}", false);

        sendNotificationToVendor(notifyId, index);

        getOrderList(userID);

        NotificationService().showNotifications("Hamper Order Cancelled", "Your $hamName order is cancelled.");

      }else{
        Navigator.pop(context);
        Functions().showSnackMsg(context,"${map['message']}", false);
      }
      // Navigator.pop(context);
    }
    else {
      print(response.reasonPhrase);
      Functions().showSnackMsg(context,"Error!", false);
      Navigator.pop(context);
    }


  }

  //cancel Others
  Future<void> cancelOtherOrder(String id , int index ,String name) async{

    print(userName);

    showAlertDialog();

    var headers = {
      'Content-Type': 'application/json'
    };
    var request = http.Request('PUT', Uri.parse('${API_URL}api/otherproduct/order/acceptorcancel/$id'));
    request.body = json.encode({
      "Status": "Cancelled",
      "Cancelled_By": "User",
      "Status_Updated_By": userID
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {

      var map = jsonDecode(await response.stream.bytesToString());

      if(map["statusCode"]==200){

        Functions().showSnackMsg(context,"${map['message']}", false);

        sendNotificationToVendor(notifyId, index);

        getOrderList(userID);

        NotificationService().showNotifications("Hamper Order Cancelled", "Your $name order is cancelled.");

      }else{
        Navigator.pop(context);
        Functions().showSnackMsg(context,"${map['message']}", false);
      }
      // Navigator.pop(context);
    }
    else {
      print(response.reasonPhrase);
      Functions().showSnackMsg(context,"Error!", false);
      Navigator.pop(context);
    }


  }

  Future<void> sendNotificationToVendor(String? NoId ,int index) async{

    // NoId = "e8q8xT7QT8KdOJC6yuCvrq:APA91bG4-TMDV4jziIvirbC4JYxFPyZHReJJIuKwo4i9QKwedMP35ohnFo1_F53JuJruAlDHl02ux3qt6gUpqj1b3UMjg0b6zqSTO1jB14cXz7Zw7kKz25Q_3_p1CJx-8bwPjFq5lnwR";

    // NoId = "cIGDQG_OR-6RRd5rPRhtIe:APA91bFo_G99mVRJzsrki-G_A6zYRe3SU8WR7Q-U29DL7Th7yngUcKU2fnXz-OFFu24qLkbopgO2chyQRlMjLBZU6uupSY31gIDa0qDNKB9yqQarVBX0LtkzT73JIpQ-6xlxYpic9Yt8";

    var headers = {
      'Authorization': 'Bearer AAAAVEy30Xg:APA91bF5xyWHGwKu-u1N5lxeKd6f9RMbg-R5y3i7fVdy6zNjdloAM6B69P6hXa_g2dlgNxVtwx3tszzKrHq-ql2Kytgv7HvkfA36RiV5PntCdzz_Jve0ElPJRM0kfCKicfxl1vFyudtm',
      'Content-Type': 'application/json'
    };
    var request = http.Request('POST', Uri.parse('https://fcm.googleapis.com/fcm/send'));
    request.body = json.encode({
      "registration_ids": [
        "$NoId",
      ],
      "notification": {
        "title": "Order Cancellation Notifier",
        "body": "Hi ${recentOrders[index]['VendorName']} , ${
            recentOrders[index]['CakeName']!=null?"${recentOrders[index]['CakeName']}":"Customized Cake"
        } is just Order Cancelled By ${recentOrders[index]['UserName']}."
      },
      "data": {
        "msgId": "msg_12342"
      }
    });
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    print(response.statusCode);

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
    }
    else {
      print(response.reasonPhrase);
    }
  }

  //getting order list...
  Future<void> getOrderList(String _id) async{

    //api/ordersandhamperorders/listbyuser/
    //api/orders/listByUser/All/
    print("User TOK ID...$_id");

    try{
      http.Response response = await http.get(
          Uri.parse("${API_URL}api/orders/listByUser/All/$_id"),
          headers: {"Authorization":"$authToken"}
      );

      print("Orders ${response.body}");

      if(response.statusCode==200){
        setState(() {
          recentOrders = jsonDecode(response.body);
          // recentOrders = recentOrders.reversed.toList();
        });
        getVendorsList();
        Navigator.pop(context);
      }
      else{
        setState((){
          // isLoading = false;
        });
        Navigator.pop(context);
      }

    }catch(error){
      setState((){
        // isLoading = false;
      });
      Navigator.pop(context);
    }
  }

  //network check
  Future<void> checkNetwork() async{
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('connected');
      }
    } on SocketException catch (_) {
      NetworkDialog().showNoNetworkAlert(context);
      print('not connected');
    }
  }

  Future<void> getVendorsList() async{
    var map = [];
    var headers = {
      'Authorization': '$authToken'
    };
    var request = http.Request('GET', Uri.parse('${API_URL}api/vendors/list'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      map = jsonDecode(await response.stream.bytesToString());
      setState((){
        vendorsList = map;
      });
    }
    else {
      print(response.reasonPhrase);
    }

  }

  //Fetching user details from API....
  Future<void> fetchProfileByPhn() async{
    var prefs = await SharedPreferences.getInstance();
    showAlertDialog();
    try{
      //http://sugitechnologies.com/cakey/ http://sugitechnologies.com/cakey/
      http.Response response = await http.get(Uri.parse("${API_URL}api/users/list/"
          "${int.parse(phoneNumber)}"),
          headers: {"Authorization":"$authToken"}
      );
      if(response.statusCode==200){
        print(jsonDecode(response.body));
        setState(() {
          List body = jsonDecode(response.body);
          userID = body[0]['_id'].toString();
          userAddress = body[0]['Address'].toString();
          userProfileUrl = body[0]['ProfileImage'].toString();
          fbToken = body[0]['Notification_Id'].toString();
          context.read<ContextData>().setProfileUrl(userProfileUrl);
          userName = body[0]['UserName'].toString();
          pinCodeCtrl.text = body[0]['Pincode'].toString();
          prefs.setString('userID', userID);
          prefs.setString('userAddress', userAddress);
          prefs.setString('userName', userName);
          context.read<ContextData>().setUserName(userName);
        });

        getOrderList(userID);

      }else{
        checkNetwork();
        Navigator.pop(context);
      }
    }catch(e){
      Navigator.pop(context);
      checkNetwork();
    }

  }

  //File piker for getting Profile picture
  Future<void> profilePiker() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      setState(() {
        String path = result.files.single.path.toString();
        file = File(path);
      });
    } else {
      // User canceled the picker
    }
  }

  //Rate the cake & Vendor
  Future<void> rateCake(double rate,String cakeId,int index) async{
    showAlertDialog();
    print(rate);
    print(cakeId);
    print(index);
    var headers = {
      'Content-Type': 'application/json'
    };
    var request = http.Request('PUT',
        Uri.parse('${API_URL}api/cake/ratings/$cakeId'));
    request.body = json.encode({
      "Ratings": rate
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
      Navigator.pop(context);
      Functions().showSnackMsg(context,"Rating is updated to the cake!", false);
      // rateVendor(rate,
      //     recentOrders[index]['VendorID'].toString());
    }
    else {
      print(response.reasonPhrase);
      Navigator.pop(context);
      // rateVendor(rate,
      //     recentOrders[index]['VendorID'].toString());
    }
  }


  void showOrderCancelDialog(String ordid , String userId , String cakeName ,int index){
    showDialog(
        context: context,
        builder: (context)=>
            AlertDialog(
              title: Text("Cancel Order!" , style: TextStyle(
                  color: darkBlue , fontFamily: "Poppins",
                  fontWeight: FontWeight.bold
              ),),
              content:Text(
                  "Are you sure? do you want to cancel this order?", style: TextStyle(
                color: Colors.black , fontFamily: "Poppins",
              )
              ),
              actions: [

                TextButton(
                  onPressed: (){
                    Navigator.pop(context);
                    cancelOrder(ordid, userId, cakeName , index);
                  },
                  child: Text('Cancel Order', style: TextStyle(
                    color: Colors.purple , fontFamily: "Poppins",
                  )),
                ),

                TextButton(
                  onPressed: ()=>Navigator.pop(context),
                  child: Text('No', style: TextStyle(
                    color: Colors.purple , fontFamily: "Poppins",
                  )),
                ),
              ],
            )
    );
  }

  //Notifications....



  //endregion

  //region Widgets.....
  Widget ProfileView(){
    userProfileUrl = context.watch<ContextData>().getProfileUrl();
    setState(() {
      userNameCtrl = TextEditingController(text: userName.toString()=="null"?"":userName);
      userAddrCtrl = TextEditingController(text: userAddress.toString()=="null"?"":userAddress);
      pinCodeCtrl = TextEditingController(text: pinCodeCtrl.toString()=="null"?"":pinCodeCtrl.text);
    });
    addressList = context.watch<ContextData>().getAddressList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10,),

        Center(
          child: Container(
            height: 120,
            child: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(blurRadius: 3, color: Colors.black, spreadRadius: 0)],
                  ),
                  child: file.path.isEmpty?CircleAvatar(
                      radius: 47,
                      backgroundColor: Colors.white,
                      child: userProfileUrl!="null"?Container(
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                            image: DecorationImage(
                                image: NetworkImage('$userProfileUrl'),
                                fit: BoxFit.cover
                            )
                        ),
                      ):CircleAvatar(
                        radius: 45,
                        backgroundImage: AssetImage("assets/images/user.png"),
                      )
                  ):CircleAvatar(
                    radius: 47,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                        radius: 45,
                        backgroundImage: FileImage(file)
                    ),
                  ),
                ),
                Positioned(
                    top: 60,
                    left: 50,
                    child: InkWell(
                      onTap: (){
                        profilePiker();
                      },
                      child: CircleAvatar(
                        radius: 22,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor:Color(0xff25bd87),
                          child: Icon(Icons.camera_alt,color:Colors.white,),
                        ),
                      ),
                    )
                ),
              ],
            ),
          ),
        ),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Name',
              style: TextStyle(
                  fontFamily: "Poppins",
                  fontWeight: FontWeight.bold,
                  color: Colors.grey
              ),
            ),
            SizedBox(height: 10,),
            TextField(
              controller: userNameCtrl,
              textCapitalization: TextCapitalization.sentences,
              maxLines: 1,
              keyboardType: TextInputType.text,
              style: TextStyle(
                fontFamily: "Poppins" ,
              ),
              decoration: InputDecoration(
                hintText: "Enter a UserName",
                border: const OutlineInputBorder(),
                hintStyle: TextStyle(
                    fontFamily: "Poppins" ,
                    color: darkBlue
                ),
              ),
            ),
            const SizedBox(height: 15,),
            Text(
              'Phone',
              style: TextStyle(
                  fontFamily: "Poppins",
                  fontWeight: FontWeight.bold,
                  color: Colors.grey
              ),
            ),
            SizedBox(height: 10,),
            TextField(
              style: TextStyle(
                fontFamily: "Poppins" ,
              ),

              enabled: false,
              controller: TextEditingController(text: phoneNumber),
              maxLines: 1,
              // maxLengthEnforced: true,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: "Type Phone Number",
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15,),
            Text(
              'Enter delivery Address',
              style: TextStyle(
                  fontFamily: "Poppins",
                  fontWeight: FontWeight.bold,
                  color: Colors.grey
              ),
            ),
            SizedBox(height: 10,),
            TextField(
              style: TextStyle(
                fontFamily: "Poppins" ,
              ),
              controller: userAddrCtrl,
              textCapitalization: TextCapitalization.sentences,
              maxLines: 1,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                hintText: "Address",
                border: OutlineInputBorder(),
                hintStyle: TextStyle(
                    fontFamily: "Poppins" ,
                    color: darkBlue
                ),
              ),
            ),
            const SizedBox(height: 15,),
            Text(
              'Pincode',
              style: TextStyle(
                  fontFamily: "Poppins",
                  fontWeight: FontWeight.bold,
                  color: Colors.grey
              ),
            ),
            SizedBox(height: 10,),
            TextField(
              maxLength: 6,
              style: TextStyle(
                fontFamily: "Poppins" ,
              ),
              controller: pinCodeCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "Pincode",
                border: OutlineInputBorder(),
                counterText: "",
                hintStyle: TextStyle(
                    fontFamily: "Poppins" ,
                    color: darkBlue
                ),
              ),
            ),
          ],
        ),

        Container(
          alignment: Alignment.centerLeft,
          child: TextButton(
              onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>AddressScreen()));
              },
              child: Text('add new address',style: TextStyle(
                  color:Colors.orange,fontFamily: "Poppins",decoration: TextDecoration.underline
              ),)
          ),
        ),
        Column(
          children:addressList.map((e){
            return Container(
              // decoration: BoxDecoration(
              //     border: Border.all(color: Colors.black12,width: 1,style:BorderStyle.solid),
              //     // color: Colors.red[50],
              //     borderRadius: BorderRadius.circular(5)
              // ),
              margin: EdgeInsets.only(bottom: 8),
              padding: EdgeInsets.all(10),
              child:Row(
                children: [
                  Expanded(
                    child: Text(e,
                        style: TextStyle(fontFamily: "Poppins",color: Colors.grey[400],fontSize: 13),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
        Container(
          alignment: Alignment.centerLeft,
          child: RaisedButton(
            onPressed: (){
              FocusScope.of(context).unfocus();
              if(userNameCtrl.text.isEmpty||userAddrCtrl.text.isEmpty||pinCodeCtrl.text.isEmpty){
                Functions().showSnackMsg(context,"Make sure fields are not empty!", false);
              }else if(pinCodeCtrl.text.length<6){
                Functions().showSnackMsg(context,"Invalid pin code field!", false);
              }else{
                updateProfile();
              }

            },
            color: darkBlue,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)
            ),
            child: const Text('SAVE',style: const TextStyle(
                color: Colors.white
            ),),
          ),
        ),

        SizedBox(height: 50,),

        Container(
          margin: const EdgeInsets.only(top: 10),
          decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.black12,width: 1,style:BorderStyle.solid),
              borderRadius: BorderRadius.circular(5)
          ),
          child: ListTile(
            leading: Container(
              alignment: Alignment.center,
              height: 45,
              width: 45,
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(5)
              ),
              child: Icon(
                Icons.notifications_outlined,color: darkBlue,
              ),
            ),
            title: const Text('Notifications',style: TextStyle(fontFamily: "Poppins"),),
            trailing: Transform.scale(
              scale: 0.7,
              child: CupertinoSwitch(
                value: notifiOnOrOf,
                thumbColor: notifiOnOrOf?Color(0xff03c04a):Colors.red,
                onChanged: (bool val) async{

                  var pref = await SharedPreferences.getInstance();
                  pref.setBool("notificationKey", val);

                  if(val==true){
                    await FirebaseMessaging.instance.getToken().
                    then((value) => {
                      setState((){
                        fbToken = value!;
                      }),
                      updateProfile(value!)
                    });
                  }else{
                    await FirebaseMessaging.instance.getToken().
                    then((value) => {
                      setState((){
                        fbToken = value!;
                      }),
                      updateProfile("no token")
                    });
                  }

                  setState(() {
                    notifiOnOrOf = val;
                  });

                  // NotificationService().showNotifications();

                  print(pref.getBool('notificationKey'));
                },
                activeColor: Colors.grey[200],
              ),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 10),
          decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.black12,width: 1,style:BorderStyle.solid),
              borderRadius: BorderRadius.circular(5)
          ),
          child: ListTile(
            onTap: (){
              showlogoutDialog();
            },
            leading: Container(
              alignment: Alignment.center,
              height: 45,
              width: 45,
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(5)
              ),
              child: Icon(
                Icons.logout_outlined,color: lightPink,
              ),
            ),
            title: Text('Logout',style: TextStyle(fontFamily: "Poppins" , color: lightPink)),
          ),
        ),
      ],
    );
  }

  Widget OrdersView(){
    recentOrders = [
        {
          "Shape": {
            "Name": "Square",
            "Price": "0"
          },
          "GoogleLocation": {
            "Latitude": 11.0118098,
            "Longitude": 77.0511027
          },
          "_id": "63ce13ab639eac51854c8aaf",
          "CakeID": "63ca8bb0c1a7d89ccc20944f",
          "Cake_ID": "CKYCCO-3",
          "CakeName": "My Customized Cake",
          "EggOrEggless": "Egg",
          "Flavour": [
            {
              "Name": "Vanilla",
              "Price": "0",
              "_id": "63ca8bb0c1a7d89ccc209450"
            }
          ],
          "Weight": "6kg",
          "MessageOnTheCake": "Birthday",
          "SpecialRequest": "None",
          "VendorID": "63ca2c46c1a7d89ccc208146",
          "Vendor_ID": "CKYV-2",
          "VendorName": "Durga",
          "VendorPhoneNumber1": "9123456789",
          "VendorPhoneNumber2": "",
          "VendorAddress": "Surya Nagar, Ondipudur, Tamil Nadu, India",
          "UserID": "63ca2d4ec1a7d89ccc20819d",
          "User_ID": "CKYCUS-1",
          "UserName": "Durga",
          "UserPhoneNumber": "+916385414805",
          "DeliveryAddress": "Krishna Colony ",
          "DeliveryDate": "24-01-2023",
          "DeliverySession": "Morning 10 AM - 11 AM",
          "DeliveryInformation": "Pickup",
          "Vendor_Price": "400",
          "Vendor_Total": "2352.00",
          "Price": "410",
          "ItemCount": 1,
          "Discount": 48,
          "ExtraCharges": "0",
          "DeliveryCharge": "0",
          "Gst": "0",
          "Sgst": "0",
          "Tax": "0",
          "Total": "2412",
          "PaymentType": "Cash on delivery",
          "PaymentStatus": "Cash on delivery",
          "Created_On": "23-01-2023 10:27 AM",
          "Status": "New",
          "Above5KG": "n",
          "PremiumVendor": "n",
          "CustomizeCake": "y",
          "TypeOfCustomizedCake": "Cakey",
          "Vendor_Response_Status": "seen",
          "ShowToVendor": "Yes",
          "Ticket_RaisedFor_Vendor_Cancel": "No",
          "Ticket_Raised_For_Customized_Cake": "Yes",
          "Id": "CKYORD-8",
          "__v": 0
        },
        {
          "Shape": {
            "Name": "Round",
            "Price": "0"
          },
          "GoogleLocation": {
            "Latitude": 11.0118098,
            "Longitude": 77.0511027
          },
          "_id": "63ca94ad639eac51854c84fc",
          "CakeID": "63ca8bfac1a7d89ccc209471",
          "Cake_ID": "CKYCCO-4",
          "CakeName": "My Customized Cake",
          "EggOrEggless": "Egg",
          "Flavour": [
            {
              "Name": "Red Velvet",
              "Price": "0",
              "_id": "63ca8bfac1a7d89ccc209472"
            }
          ],
          "Weight": "3kg",
          "MessageOnTheCake": "Welcome",
          "SpecialRequest": "None",
          "VendorID": "63ca2c46c1a7d89ccc208146",
          "Vendor_ID": "CKYV-2",
          "VendorName": "Durga",
          "VendorPhoneNumber1": "9123456789",
          "VendorPhoneNumber2": "",
          "VendorAddress": "Surya Nagar, Ondipudur, Tamil Nadu, India",
          "UserID": "63ca2d4ec1a7d89ccc20819d",
          "User_ID": "CKYCUS-1",
          "UserName": "Durga",
          "UserPhoneNumber": "+916385414805",
          "DeliveryAddress": "Krishna Colony ",
          "DeliveryDate": "26-01-2023",
          "DeliverySession": "Afternoon 12 PM - 1 PM",
          "DeliveryInformation": "Pickup",
          "Vendor_Price": "100",
          "Vendor_Total": "294.00",
          "Price": "100",
          "ItemCount": 1,
          "Discount": 6,
          "ExtraCharges": "0",
          "DeliveryCharge": "0",
          "Gst": "0",
          "Sgst": "0",
          "Total": "294",
          "PaymentType": "Cash on delivery",
          "PaymentStatus": "Cash on delivery",
          "Created_On": "20-01-2023 06:48 PM",
          "Status": "New",
          "Above5KG": "n",
          "PremiumVendor": "n",
          "CustomizeCake": "y",
          "TypeOfCustomizedCake": "Vendor",
          "Vendor_Response_Status": "seen",
          "ShowToVendor": "Yes",
          "Ticket_RaisedFor_Vendor_Cancel": "No",
          "Ticket_Raised_For_Customized_Cake": "No",
          "Id": "CKYORD-6",
          "__v": 0
        },
        {
          "GoogleLocation": {
            "Latitude": 11.0118098,
            "Longitude": 77.0511027
          },
          "_id": "63ca8bfac1a7d89ccc209471",
          "CakeName": "My Customized Cake",
          "EggOrEggless": "Egg",
          "Images": [],
          "Flavour": [
            {
              "Name": "Red Velvet",
              "Price": "0",
              "_id": "63ca8bfac1a7d89ccc209472"
            }
          ],
          "Shape": "Round",
          "Weight": "3kg",
          "Above5KG": "n",
          "PremiumVendor": "n",
          "MessageOnTheCake": "Welcome",
          "VendorID": "63ca2c46c1a7d89ccc208146",
          "Vendor_ID": "CKYV-2",
          "VendorName": "Durga",
          "VendorPhoneNumber1": "9123456789",
          "VendorPhoneNumber2": "",
          "VendorAddress": "Surya Nagar, Ondipudur, Tamil Nadu, India",
          "UserID": "63ca2d4ec1a7d89ccc20819d",
          "User_ID": "CKYCUS-1",
          "UserName": "Durga",
          "UserPhoneNumber": "+916385414805",
          "DeliveryAddress": "Krishna Colony ",
          "DeliveryInformation": "Pickup",
          "DeliveryDate": "26-01-2023",
          "DeliverySession": "Afternoon 12 PM - 1 PM",
          "Status": "Ordered",
          "Created_On": "20-01-2023 06:11 PM",
          "Notification": "unseen",
          "TypeOfCustomizedCake": "Vendor",
          "Ticket_Raised": "y",
          "Above5KgCustomizedOrderConfirm": "n",
          "Customized_Cake_Price_Approved": "y",
          "Ordered": "y",
          "Id": "CKYCCO-4",
          "__v": 0,
          "DeliveryCharge": "0",
          "Discount": 6,
          "ExtraCharges": "0",
          "Invoice_Sent_By": "63ca2c46c1a7d89ccc208146",
          "Invoice_Sent_On": "20-01-2023 06:25 PM",
          "SpecialRequest": "None",
          "Vendor_Price": "100",
          "Vendor_Total": "294.00",
          "TicketID": "63ca93e0639eac51854c8491",
          "Gst": "0",
          "Price": "100",
          "Sgst": "0",
          "Total": "294",
          "Final_Order_ID": "63ca94ad639eac51854c84fc"
        },
        {
          "GoogleLocation": {
            "Latitude": 11.0118098,
            "Longitude": 77.0511027
          },
          "Assigned_By": {
            "ID": "63ca1bb5c1a7d89ccc207f2d",
            "Name": "Vidhya",
            "Email": "vidhya@mindmade.in",
            "TypeOfUser": "Helpdesk V"
          },
          "Margin": {
            "Percentage": "0",
            "Amount": "0"
          },
          "_id": "63ca8bb0c1a7d89ccc20944f",
          "CakeName": "My Customized Cake",
          "EggOrEggless": "Egg",
          "Images": [],
          "Flavour": [
            {
              "Name": "Vanilla",
              "Price": "0",
              "_id": "63ca8bb0c1a7d89ccc209450"
            }
          ],
          "Shape": "Square",
          "Weight": "6kg",
          "Above5KG": "y",
          "PremiumVendor": "y",
          "MessageOnTheCake": "Birthday",
          "UserID": "63ca2d4ec1a7d89ccc20819d",
          "User_ID": "CKYCUS-1",
          "UserName": "Durga",
          "UserPhoneNumber": "+916385414805",
          "DeliveryAddress": "Krishna Colony ",
          "DeliveryInformation": "Pickup",
          "DeliveryDate": "24-01-2023",
          "DeliverySession": "Morning 10 AM - 11 AM",
          "Status": "Ordered",
          "Created_On": "20-01-2023 06:10 PM",
          "Notification": "unseen",
          "TypeOfCustomizedCake": "Cakey",
          "Ticket_Raised": "y",
          "Above5KgCustomizedOrderConfirm": "n",
          "Customized_Cake_Price_Approved": "y",
          "Ordered": "y",
          "Id": "CKYCCO-3",
          "__v": 0,
          "TicketID": "63ca900c639eac51854c82b3",
          "Assigned_On": "20-01-2023 06:30 PM",
          "VendorAddress": "Surya Nagar, Ondipudur, Tamil Nadu, India",
          "VendorID": "63ca2c46c1a7d89ccc208146",
          "VendorName": "Durga",
          "VendorPhoneNumber1": "9123456789",
          "VendorPhoneNumber2": "",
          "Vendor_ID": "CKYV-2",
          "DeliveryCharge": "0",
          "Discount": 48,
          "ExtraCharges": "0",
          "Invoice_Sent_By": "63ca2c46c1a7d89ccc208146",
          "Invoice_Sent_On": "20-01-2023 06:57 PM",
          "SpecialRequest": "None",
          "Vendor_Price": "400",
          "Vendor_Total": "2352.00",
          "Gst": "0",
          "HelpdeskV_Price": "410",
          "HelpdeskV_Total": "2412",
          "Sgst": "0",
          "Tax": "0",
          "Price": "410",
          "Total": "2412",
          "Final_Order_ID": "63ce13ab639eac51854c8aaf"
        },
        {
          "Shape": {
            "Name": "star",
            "Price": "0"
          },
          "GoogleLocation": {
            "Latitude": 11.0118415,
            "Longitude": 77.0514967
          },
          "_id": "63ca83a9c1a7d89ccc209332",
          "CakeID": "63ca4ba2c1a7d89ccc20855a",
          "Cake_ID": "CKYCCO-1",
          "CakeName": "My Customized Cake",
          "EggOrEggless": "Egg",
          "Flavour": [
            {
              "Name": "Chocolate ",
              "Price": "50",
              "_id": "63ca810ee02881ab138c66fc"
            }
          ],
          "Weight": "2kg",
          "MessageOnTheCake": "No Message",
          "VendorID": "63ca2c46c1a7d89ccc208146",
          "Vendor_ID": "CKYV-2",
          "VendorName": "Durga",
          "VendorPhoneNumber1": "9123456789",
          "VendorPhoneNumber2": "null",
          "VendorAddress": "1st Street, Surya Nagar, Ondipudur, Tamil Nadu, India",
          "UserID": "63ca2d4ec1a7d89ccc20819d",
          "User_ID": "CKYCUS-1",
          "UserName": "Durga",
          "UserPhoneNumber": "+916385414805",
          "DeliveryAddress": "Krishna Colony ",
          "DeliveryDate": "24-01-2023",
          "DeliverySession": "Evening 5 PM - 6 PM",
          "DeliveryInformation": "Delivery",
          "Vendor_Price": "800",
          "Vendor_Total": "1666",
          "Price": "800",
          "ItemCount": 1,
          "Discount": 34,
          "ExtraCharges": "100",
          "DeliveryCharge": "0",
          "Gst": "0",
          "Sgst": "0",
          "Total": "1666",
          "PaymentType": "Cash on delivery",
          "PaymentStatus": "Cash on delivery",
          "Created_On": "20-01-2023 05:36 PM",
          "Status": "New",
          "Above5KG": "n",
          "PremiumVendor": "n",
          "CustomizeCake": "y",
          "TypeOfCustomizedCake": "Vendor",
          "Vendor_Response_Status": "seen",
          "ShowToVendor": "Yes",
          "Ticket_RaisedFor_Vendor_Cancel": "No",
          "Ticket_Raised_For_Customized_Cake": "No",
          "Id": "CKYORD-5",
          "__v": 0
        },
        {
          "Shape": {
            "Name": "Round",
            "Price": "0"
          },
          "GoogleLocation": {
            "Latitude": 10.9963799,
            "Longitude": 77.0255008
          },
          "_id": "63ca7634c1a7d89ccc209027",
          "CakeID": "63ca6daec1a7d89ccc208ebc",
          "Cake_ID": "CKYCCO-2",
          "CakeName": "My Customized Cake",
          "EggOrEggless": "Egg",
          "Flavour": [
            {
              "Name": "Chocolate ",
              "Price": "80",
              "_id": "63ca71e50a5fa66e1ff39e32"
            }
          ],
          "Weight": "7kg",
          "MessageOnTheCake": "Happy Birthday ",
          "VendorID": "63ca699ec1a7d89ccc208d2d",
          "Vendor_ID": "CKYV-3",
          "VendorName": "Vignesh",
          "VendorPhoneNumber1": "9876543211",
          "VendorAddress": "Vasanth Nagar, Singanallur, Tamil Nadu, India",
          "UserID": "63ca2d4ec1a7d89ccc20819d",
          "User_ID": "CKYCUS-1",
          "UserName": "Durga",
          "UserPhoneNumber": "+916385414805",
          "DeliveryAddress": "Krishna Colony ",
          "DeliveryDate": "25-01-2023",
          "DeliverySession": "Evening 6 PM - 7 PM",
          "DeliveryInformation": "Pickup",
          "Vendor_Price": "800",
          "Vendor_Total": "6036.8",
          "Price": "750",
          "ItemCount": 1,
          "Discount": 123.2,
          "ExtraCharges": "560",
          "DeliveryCharge": "0",
          "Gst": "0",
          "Sgst": "0",
          "Tax": "0",
          "Total": "5686.8",
          "PaymentType": "Cash on delivery",
          "PaymentStatus": "Cash on delivery",
          "Created_On": "20-01-2023 04:38 PM",
          "Status": "New",
          "Above5KG": "n",
          "PremiumVendor": "n",
          "CustomizeCake": "y",
          "TypeOfCustomizedCake": "Cakey",
          "Vendor_Response_Status": "no response",
          "ShowToVendor": "Yes",
          "Ticket_RaisedFor_Vendor_Cancel": "No",
          "Ticket_Raised_For_Customized_Cake": "Yes",
          "Id": "CKYORD-4",
          "__v": 0
        },
        {
          "GoogleLocation": {
            "Latitude": 10.9963799,
            "Longitude": 77.0255008
          },
          "Assigned_By": {
            "ID": "63ca1bb5c1a7d89ccc207f2d",
            "Name": "Vidhya",
            "Email": "vidhya@mindmade.in",
            "TypeOfUser": "Helpdesk V"
          },
          "Margin": {
            "Percentage": "0",
            "Amount": "0"
          },
          "_id": "63ca6daec1a7d89ccc208ebc",
          "CakeName": "My Customized Cake",
          "EggOrEggless": "Egg",
          "Images": [],
          "Flavour": [
            {
              "Name": "Chocolate ",
              "Price": "80",
              "_id": "63ca71e50a5fa66e1ff39e32"
            }
          ],
          "Shape": "Round",
          "Weight": "7kg",
          "Above5KG": "y",
          "PremiumVendor": "y",
          "MessageOnTheCake": "Happy Birthday ",
          "UserID": "63ca2d4ec1a7d89ccc20819d",
          "User_ID": "CKYCUS-1",
          "UserName": "Durga",
          "UserPhoneNumber": "+916385414805",
          "DeliveryAddress": "Krishna Colony ",
          "DeliveryInformation": "Pickup",
          "DeliveryDate": "25-01-2023",
          "DeliverySession": "Evening 6 PM - 7 PM",
          "Status": "Ordered",
          "Created_On": "20-01-2023 04:02 PM",
          "Notification": "unseen",
          "TypeOfCustomizedCake": "Cakey",
          "Ticket_Raised": "y",
          "Above5KgCustomizedOrderConfirm": "n",
          "Customized_Cake_Price_Approved": "y",
          "Ordered": "y",
          "Id": "CKYCCO-2",
          "__v": 0,
          "TicketID": "63ca6e17c1a7d89ccc208ee3",
          "Assigned_On": "20-01-2023 04:08 PM",
          "VendorAddress": "Vasanth Nagar, Singanallur, Tamil Nadu, India",
          "VendorID": "63ca699ec1a7d89ccc208d2d",
          "VendorName": "Vignesh",
          "VendorPhoneNumber1": "9876543211",
          "Vendor_ID": "CKYV-3",
          "DeliveryCharge": "0",
          "Discount": 123.2,
          "ExtraCharges": "560",
          "Invoice_Sent_By": "63ca699ec1a7d89ccc208d2d",
          "Invoice_Sent_On": "20-01-2023 04:20 PM",
          "Vendor_Price": "800",
          "Vendor_Total": "6036.8",
          "Gst": "0",
          "HelpdeskV_Price": "750",
          "HelpdeskV_Total": "5686.8",
          "Sgst": "0",
          "Tax": "0",
          "Price": "750",
          "Total": "5686.8",
          "Final_Order_ID": "63ca7634c1a7d89ccc209027"
        },
        {
          "GoogleLocation": {
            "Latitude": 11.0118415,
            "Longitude": 77.0514967
          },
          "_id": "63ca4ba2c1a7d89ccc20855a",
          "CakeName": "My Customized Cake",
          "EggOrEggless": "Egg",
          "Tier": "4tier",
          "Images": [],
          "Flavour": [
            {
              "Name": "Chocolate ",
              "Price": "50",
              "_id": "63ca810ee02881ab138c66fc"
            }
          ],
          "Shape": "star",
          "Weight": "2kg",
          "Above5KG": "n",
          "PremiumVendor": "n",
          "VendorID": "63ca2c46c1a7d89ccc208146",
          "Vendor_ID": "CKYV-2",
          "VendorName": "Durga",
          "VendorPhoneNumber1": "9123456789",
          "VendorPhoneNumber2": "null",
          "VendorAddress": "1st Street, Surya Nagar, Ondipudur, Tamil Nadu, India",
          "UserID": "63ca2d4ec1a7d89ccc20819d",
          "User_ID": "CKYCUS-1",
          "UserName": "Durga",
          "UserPhoneNumber": "+916385414805",
          "DeliveryAddress": "Krishna Colony ",
          "DeliveryInformation": "Delivery",
          "DeliveryDate": "24-01-2023",
          "DeliverySession": "Evening 5 PM - 6 PM",
          "Status": "Ordered",
          "Created_On": "20-01-2023 01:36 PM",
          "Notification": "unseen",
          "TypeOfCustomizedCake": "Vendor",
          "Ticket_Raised": "y",
          "Above5KgCustomizedOrderConfirm": "n",
          "Customized_Cake_Price_Approved": "y",
          "Ordered": "y",
          "Id": "CKYCCO-1",
          "__v": 0,
          "DeliveryCharge": "0",
          "Discount": 34,
          "ExtraCharges": "100",
          "Invoice_Sent_By": "63ca2c46c1a7d89ccc208146",
          "Invoice_Sent_On": "20-01-2023 05:24 PM",
          "MessageOnTheCake": "No Message",
          "Vendor_Price": "800",
          "Vendor_Total": "1666",
          "TicketID": "63ca8135c1a7d89ccc2092a2",
          "Gst": "0",
          "Price": "800",
          "Sgst": "0",
          "Total": "1666",
          "Final_Order_ID": "63ca83a9c1a7d89ccc209332"
        }
    ];
    return Column(
      mainAxisSize: MainAxisSize.max,
      // mainAxisAlignment: MainAxisAlignment.center,
      children: [
        recentOrders.length>0?
        ListView.builder(
            itemCount: recentOrders.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index){
              String diff = recentOrders[index]['Created_On'].toString().split(" ").first;
              String status = recentOrders[index]['Status'];

              if(recentOrders[index]['Status'].toString().toLowerCase()=="rejected"){
                status = "Pending";
              }else if(recentOrders[index]['Status'].toString().toLowerCase()=="assigned"){
                status = "Accepted";
              }

              var myMap = Map();
              var otherPrice = "";
              if(recentOrders[index]['ProductMinWeightPerKg']!=null){
                if(recentOrders[index]['ProductMinWeightPerKg'].isNotEmpty){
                  myMap = recentOrders[index]['ProductMinWeightPerKg'];

                  otherPrice = (
                      double.parse(myMap['PricePerKg'])*changeWeight(myMap['Weight'])
                  ).toStringAsFixed(2);

                }else if(recentOrders[index]['ProductMinWeightPerUnit'].isNotEmpty){
                  myMap = recentOrders[index]['ProductMinWeightPerUnit'];

                  otherPrice = (
                      double.parse(myMap['PricePerUnit'])*changeWeight(myMap['Weight'])*
                          double.parse(myMap['ProductCount'])
                  ).toStringAsFixed(2);

                }else if(recentOrders[index]['ProductMinWeightPerBox'].isNotEmpty){
                  myMap = recentOrders[index]['ProductMinWeightPerBox'];

                  otherPrice = (
                      double.parse(myMap['PricePerBox'])*changeWeight(myMap['Piece'])*
                          double.parse(myMap['ProductCount'])
                  ).toStringAsFixed(2);

                }

              }
              String gramAndKilo = "";
              if(recentOrders[index]['ExtraCharges']!=null){
                if(recentOrders[index]['Weight'].toString().toLowerCase().endsWith("kg")){
                  gramAndKilo = (
                      double.parse(recentOrders[index]['ItemCount'].toString(),(e)=>1) * (
                          (double.parse(recentOrders[index]['Price'].toString())*
                              double.parse(recentOrders[index]['Weight'].toString().
                              toLowerCase().replaceAll("kg", "")))+
                              double.parse(recentOrders[index]['ExtraCharges'].toString())
                      )
                  ).toStringAsFixed(2);
                }else{
                  gramAndKilo = (
                      (double.parse(recentOrders[index]['ItemCount'].toString()) * (
                          (double.parse(recentOrders[index]['Price'].toString()))+
                              double.parse(recentOrders[index]['ExtraCharges'].toString())
                      )/2)
                  ).toStringAsFixed(2);
                }
              }
              isExpands.add(false);
              return recentOrders[index]['CakeName']!=null?
              Container(
                margin: const EdgeInsets.only(top: 10),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black12,width: 1,style:BorderStyle.solid),
                    borderRadius: BorderRadius.circular(15)
                ),
                child: Column(
                  children: [
                    InkWell(
                      onTap:(){

                        setState(() {
                          if(isExpands[index]==false){
                            isExpands[index]=true;

                            List note = vendorsList.where((element) =>
                            element["Id"]==recentOrders[index]['Vendor_ID']).toList();

                            if(note.isNotEmpty){
                              setState((){
                                note[0]['Notification_Id']!=null?
                                notifyId = note[0]['Notification_Id']:notifyId="null";
                              });
                            }

                            //mins calculate

                            year = int.parse(recentOrders[index]['Created_On'].toString().split(" ")
                                .first.split("-").last);
                            month = int.parse(recentOrders[index]['Created_On'].toString().split(" ")
                                .first.split("-")[1]);
                            day = int.parse(recentOrders[index]['Created_On'].toString().split(" ")
                                .first.split("-").first);
                            hour = int.parse(recentOrders[index]['Created_On'].toString().split(" ")[1]
                                .split("")[1].split(":").first);
                            min = int.parse(recentOrders[index]['Created_On'].toString().split(" ")
                            [1].split(":").last);

                            DateTime a = DateTime(year,month,day,hour,min);


                            DateTime b = DateTime.now();

                            Duration difference = b.difference(a);



                            days = difference.inDays;
                            hours = difference.inHours % 24;
                            minutes = difference.inMinutes % 60;
                            seconds = difference.inSeconds % 60;

                          }else{
                            isExpands[index]=false;
                          }
                        });
                      },
                      child: Container(
                          child:Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              recentOrders[index]["Image"]==null||recentOrders[index]["Image"].toString().isEmpty||
                                  !recentOrders[index]["Image"].toString().startsWith("http")?
                              Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    image: DecorationImage(
                                        image:AssetImage("assets/images/chefdoll.jpg"),
                                        fit: BoxFit.cover
                                    )
                                ),
                              ):
                              Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    image: DecorationImage(
                                        image: NetworkImage('${recentOrders[index]['Image']}'),
                                        fit: BoxFit.cover
                                    )
                                ),
                              ),
                              const SizedBox(width: 5,),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                        padding: const EdgeInsets.only(left: 3,right: 3,top: 2,bottom: 2),
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(20),
                                            color: Colors.grey[300]
                                        ),
                                        child:(recentOrders[index]['Id']!= null)?
                                        Text('Order Id ${recentOrders[index]['Id']}',style: const TextStyle(
                                            fontSize: 10,fontFamily: "Poppins",color: Colors.black
                                        ),):Text('cake id',style: const TextStyle(
                                            fontSize: 10,fontFamily: "Poppins",color: Colors.black
                                        ))
                                    ),
                                    SizedBox(height: 5,),
                                    Container(
                                      child:(recentOrders[index]['CakeName'] != null)
                                          ?Text("${recentOrders[index]['CakeName']} ",style: const TextStyle(
                                          fontSize: 12.5,fontFamily: "Poppins",
                                          color: Colors.black,fontWeight: FontWeight.bold
                                      ),overflow: TextOverflow.ellipsis,maxLines: 4,):
                                      Text("My Customise Cake",style: const TextStyle(
                                          fontSize: 12,fontFamily: "Poppins",
                                          color: Colors.black,fontWeight: FontWeight.bold
                                      ),overflow: TextOverflow.ellipsis,),
                                    ),
                                    Container(
                                      child:Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          recentOrders[index]['CustomizeCake'].toString()=="n"?
                                          Wrap(
                                            children: [
                                              Text('(Shape - ${recentOrders[index]['Shape']['Name']})',style: TextStyle(
                                                  fontSize: 11,fontFamily: "Poppins",color: Colors.grey[500]
                                              ),overflow: TextOverflow.ellipsis,maxLines: 10),
                                              Text("(Flavours : ",style: TextStyle(
                                                  fontSize:10.5,fontFamily: "Poppins",
                                                  color: Colors.grey[500]
                                              ),),
                                              for(var i in recentOrders[index]['Flavour'])
                                                Text("${i['Name']})",style: TextStyle(
                                                    fontSize:10.5,fontFamily: "Poppins",
                                                    color:  Colors.grey[500]
                                                ),),
                                            ],
                                          ):
                                          Wrap(
                                            children: [
                                              recentOrders[index]['Shape'] is Map?
                                              Text('(Shape - ${recentOrders[index]['Shape']['Name']})',style: TextStyle(
                                                  fontSize: 11,fontFamily: "Poppins",color: Colors.grey[500]
                                              ),overflow: TextOverflow.ellipsis,maxLines: 10):Text('(Shape - ${recentOrders[index]['Shape']})',style: TextStyle(
                                                  fontSize: 11,fontFamily: "Poppins",color: Colors.grey[500]
                                              ),overflow: TextOverflow.ellipsis,maxLines: 10),
                                              Text("(Flavours : ",style: TextStyle(
                                                  fontSize:10.5,fontFamily: "Poppins",
                                                  color: Colors.grey[500]
                                              ),),
                                              for(var i in recentOrders[index]['Flavour'])
                                                Text("${i['Name']}",style: TextStyle(
                                                    fontSize:10.5,fontFamily: "Poppins",
                                                    color:  Colors.grey[500]
                                                ),),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 3,),

                                    Container(
                                      child:
                                      Row(
                                        // crossAxisAlignment: CrossAxisAlignment.start,
                                        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        mainAxisAlignment:MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(gramAndKilo.isNotEmpty?"₹ $gramAndKilo":"0.00",
                                              style: TextStyle(color: lightPink,
                                                  fontWeight: FontWeight.bold,fontFamily: "Poppins"),maxLines: 2,),
                                          ),
                                          Container(
                                            child:recentOrders[index]['Status'].toString().toLowerCase()=='delivered'?
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text("${recentOrders[index]['Status']} ",style: TextStyle(color: Color(0xff058d05),
                                                        fontWeight: FontWeight.bold,fontFamily: "Poppins",fontSize: 11),),
                                                    const Icon(Icons.check_circle,color: Color(0xff058d05),size: 12,)
                                                  ],
                                                ),
                                                Text("${recentOrders[index]['Status_Updated_On']
                                                    .toString().split(" ").first}",style: TextStyle(color:Colors.grey[400],
                                                    fontFamily: "Poppins",fontSize: 10,fontWeight: FontWeight.bold),),
                                              ],
                                            ):
                                            Text(status,style: TextStyle(
                                                color:status.toLowerCase()=='cancelled'?Colors.red:Colors.blueAccent,
                                                fontWeight: FontWeight.bold,fontFamily: "Poppins",fontSize: 11
                                            ),),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              )
                            ],
                          )
                      ),
                    ),
                    SizedBox(height: 10,),
                    Visibility(
                      visible:isExpands[index],
                      child: AnimatedContainer(
                        duration: const Duration(seconds: 3),
                        curve: Curves.elasticInOut,
                        decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(10),
                                bottomRight: Radius.circular(10)
                            )
                        ),
                        child: Column(
                          children: [
                            ListTile(
                              title: const Text('Vendor',style: const TextStyle(
                                  fontSize: 11,fontFamily: "Poppins"
                              ),),
                              subtitle:Text(recentOrders[index]['VendorName']!=null || recentOrders[index]['VendorName']!=""?
                              '${recentOrders[index]['VendorName']}':"Premium Vendor",style: TextStyle(
                                  fontSize: 14,fontFamily: "Poppins",
                                  fontWeight: FontWeight.bold,color: Colors.black
                              ),),
                              trailing: Container(
                                width: 100,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    InkWell(
                                      onTap: () async{
                                        PhoneDialog().
                                        showPhoneDialog(context,
                                            recentOrders[index]['VendorPhoneNumber1'], recentOrders[index]['VendorPhoneNumber2']);
                                      },
                                      child: Container(
                                        alignment: Alignment.center,
                                        height: 35,
                                        width: 35,
                                        decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.white
                                        ),
                                        child:const Icon(Icons.phone,color: Colors.blueAccent,),
                                      ),
                                    ),
                                    const SizedBox(width: 10,),
                                    InkWell(
                                      onTap: () async{
                                        Functions().handleChatWithVendors(context, recentOrders[index]['Email'], recentOrders[index]['VendorName']);
                                        //PhoneDialog().showPhoneDialog(context, recentOrders[index]['VendorPhoneNumber1'], recentOrders[index]['VendorPhoneNumber2'] , true);
                                      },
                                      child: Container(
                                        alignment: Alignment.center,
                                        height: 35,
                                        width: 35,
                                        decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.white
                                        ),
                                        child:const Icon(Icons.whatsapp_rounded,color: Color(0xff058d05),),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            recentOrders[index]['CustomizeCake'].toString()=="n"?
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.only(left: 15),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Cake Type',style: TextStyle(
                                      fontSize: 11,fontFamily: "Poppins"
                                  ),),
                                  Text('Cakes',style: TextStyle(
                                      fontSize: 14,fontFamily: "Poppins",
                                      fontWeight: FontWeight.bold,color: Colors.black
                                  ),),
                                ],
                              ),
                            ):
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.only(left: 15),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Cake Type',style: TextStyle(
                                      fontSize: 11,fontFamily: "Poppins"
                                  ),),
                                  Text('Customized Cake',style: TextStyle(
                                      fontSize: 14,fontFamily: "Poppins",
                                      fontWeight: FontWeight.bold,color: Colors.black
                                  ),),
                                ],
                              ),
                            ),

                            SizedBox(height: 10,),

                            recentOrders[index]['Status']!="Cancelled"
                                &&days<1&&minutes<=15&&recentOrders[index]['Status']=="New"?
                            Container(
                              padding: EdgeInsets.only(left: 15,right: 15),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Cancel Order In ${15-minutes} Mins",
                                    style: TextStyle(
                                        fontFamily: "Poppins",
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13
                                    ),),
                                  OutlinedButton(
                                    onPressed: (){

                                      showOrderCancelDialog(
                                          recentOrders[index]['_id'],
                                          recentOrders[index]['UserID'],
                                          recentOrders[index]['CakeName'],
                                          index
                                      );

                                    },
                                    child: Text("Cancel Order",style: TextStyle(
                                        fontFamily: "Poppins",
                                        fontSize: 12
                                    ),),
                                    style: ButtonStyle(
                                        backgroundColor: MaterialStateProperty.all(
                                            Colors.transparent
                                        ),
                                        side: MaterialStateProperty.all(
                                            BorderSide(width: 0.5,color: Colors.white)
                                        )
                                    ),
                                  )
                                ],
                              ),
                            ):Container(),

                            Container(
                              margin: const EdgeInsets.only(left: 10,right: 10),
                              color: Colors.black38,
                              height: 1,
                            ),

                            const SizedBox(height: 15,),

                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(width: 8,),
                                const Icon(
                                  Icons.location_on,
                                  color: Colors.red,
                                ),
                                const SizedBox(width: 8,),
                                Container(
                                    width: 260,
                                    child:Text(
                                      recentOrders[index]['DeliveryAddress']!=null?
                                      "${recentOrders[index]['DeliveryAddress'].toString().trim()}":
                                      "Pick Up",
                                      style: TextStyle(
                                          fontFamily: "Poppins",
                                          color: Colors.black54,
                                          fontSize: 13
                                      ),
                                    )
                                ),
                              ],
                            ),
                            const SizedBox(height: 15,),
                            Container(
                              margin: const EdgeInsets.only(left: 10,right: 10),
                              color:Colors.grey[400],
                              height: 1,
                            ),

                            Container(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text('Product Total',style: TextStyle(
                                    fontFamily: "Poppins",
                                    color: Colors.black54,
                                  ),),
                                  recentOrders[index]['ExtraCharges']!=null?
                                  Text("₹ "
                                  //     "${(
                                  //     double.parse(recentOrders[index]['ItemCount'].toString()) * (
                                  //         (double.parse(recentOrders[index]['Price'].toString())*
                                  //             double.parse(recentOrders[index]['Weight'].toString().
                                  //             toLowerCase().replaceAll("kg", "")))+
                                  //             double.parse(recentOrders[index]['ExtraCharges'].toString())
                                  //     )
                                  // ).toStringAsFixed(2)}"
                                      "$gramAndKilo"
                                    ,style: const TextStyle(fontWeight: FontWeight.bold),):
                                  Text(""),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text('Delivery charge',
                                    style: const TextStyle(
                                      fontFamily: "Poppins",
                                      color: Colors.black54,
                                    ),),
                                  recentOrders[index]['DeliveryCharge']!=null?
                                  Text('₹${double.parse(recentOrders[index]['DeliveryCharge'].toString()).toStringAsFixed(2)}',style: const TextStyle(fontWeight: FontWeight.bold),):
                                  Text('₹0.00',style: const TextStyle(fontWeight: FontWeight.bold),),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text('Discounts',
                                    style: const TextStyle(
                                      fontFamily: "Poppins",
                                      color: Colors.black54,
                                    ),),
                                  recentOrders[index]['Discount'] != null?
                                  Text('₹${recentOrders[index]['Discount'].toStringAsFixed(2)}',style: const TextStyle(fontWeight: FontWeight.bold),):
                                  Text('₹0.00',style: const TextStyle(fontWeight: FontWeight.bold),),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text('CGST',style: const TextStyle(
                                    fontFamily: "Poppins",
                                    color: Colors.black54,
                                  ),),
                                  recentOrders[index]['Gst']!=null?
                                  Text('₹${double.parse(recentOrders[index]['Gst']).toStringAsFixed(2)}',style: const TextStyle(fontWeight: FontWeight.bold),):
                                  Text('₹0.00',style: const TextStyle(fontWeight: FontWeight.bold),),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text('SGST',style: const TextStyle(
                                    fontFamily: "Poppins",
                                    color: Colors.black54,
                                  ),),
                                  recentOrders[index]['Sgst']!=null?
                                  Text('₹${double.parse(recentOrders[index]['Sgst']).toStringAsFixed(2)}',style: const TextStyle(fontWeight: FontWeight.bold),):
                                  Text('₹0.00',style: const TextStyle(fontWeight: FontWeight.bold),),
                                ],
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(left: 10,right: 10),
                              color:Colors.grey[400],
                              height: 1,
                            ),
                            Container(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text('Bill Total',style: TextStyle(
                                      fontFamily: "Poppins",
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold
                                  ),),
                                  recentOrders[index]['Total'] != null?
                                  Text('₹${double.parse(recentOrders[index]['Total']).toStringAsFixed(2)}',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ):
                                  Text('₹0.00',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text('Paid via : ${recentOrders[index]['PaymentType']==null?"Not Found":recentOrders[index]['PaymentType']}',style: TextStyle(
                                    fontFamily: "Poppins",
                                    color: Colors.black54,
                                  ),),
                                ],
                              ),
                            ),

                            recentOrders[index]['Status'].toString().toLowerCase()=='delivered'?
                            TextButton(onPressed: (){
                              String rate = '1' ;

                              showDialog(
                                context: context,
                                builder:(context)=>
                                    StatefulBuilder(
                                      builder:(BuildContext context , void Function(void Function()) setState)=>
                                          AlertDialog(
                                            title:Center(
                                              child: Text('Give Rate To Cake',style: TextStyle(
                                                  fontFamily: "Poppins",
                                                  fontSize: 15.5,
                                                  fontWeight: FontWeight.bold
                                              ),),
                                            ),

                                            content:Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                RatingBar.builder(
                                                  initialRating: 1.0,
                                                  minRating: 1,
                                                  direction: Axis.horizontal,
                                                  allowHalfRating: true,
                                                  itemCount: 5,
                                                  itemSize: 30,
                                                  itemPadding: EdgeInsets.symmetric(horizontal: 1.0),
                                                  itemBuilder: (context, _) => Icon(
                                                    Icons.star,
                                                    color: Colors.amber,
                                                  ),
                                                  onRatingUpdate: (rating) {

                                                    setState((){
                                                      rate = rating.toString();
                                                    });
                                                  },
                                                ),
                                                SizedBox(height: 15,),
                                                Text(rate)
                                              ],
                                            ),
                                            actions: [
                                              TextButton(
                                                  onPressed: (){
                                                    Navigator.pop(context);
                                                  },
                                                  child:  Text('Cancel',style: TextStyle(
                                                      fontFamily: "Poppins",
                                                      fontSize: 13.5,
                                                      color:Colors.pinkAccent
                                                  ),)
                                              ),
                                              TextButton(
                                                  onPressed: (){
                                                    Navigator.pop(context);
                                                    rateCake(double.parse(rate),
                                                        recentOrders[index]['CakeID'].toString(), index);
                                                  },
                                                  child:  Text('Rate',style: TextStyle(
                                                      fontFamily: "Poppins",
                                                      fontSize: 13.5,
                                                      color:Color(0xff058d05)
                                                  ),)
                                              ),
                                            ],
                                          ),
                                    ),
                              );


                            },
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.star_border, color: Colors.amber,),
                                    Text(' Rate The Cake',style: TextStyle(
                                        fontFamily: "Poppins"
                                    ),)
                                  ],
                                )):
                            Container(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ):
              recentOrders[index]['HampersName']!=null?
              Container(
                margin: const EdgeInsets.only(top: 10),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black12,width: 1,style:BorderStyle.solid),
                    borderRadius: BorderRadius.circular(15)
                ),
                child: Column(
                  children: [
                    InkWell(
                      onTap:(){
                        setState(() {
                          if(isExpands[index]==false){
                            isExpands[index]=true;

                            List note = vendorsList.where((element) =>
                            element["Id"]==recentOrders[index]['Vendor_ID']).toList();

                            if(note.isNotEmpty){
                              setState((){
                                note[0]['Notification_Id']!=null?
                                notifyId = note[0]['Notification_Id']:notifyId="null";
                              });
                            }


                            //mins calculate

                            year = int.parse(recentOrders[index]['Created_On'].toString().split(" ")
                                .first.split("-").last);
                            month = int.parse(recentOrders[index]['Created_On'].toString().split(" ")
                                .first.split("-")[1]);
                            day = int.parse(recentOrders[index]['Created_On'].toString().split(" ")
                                .first.split("-").first);
                            hour = int.parse(recentOrders[index]['Created_On'].toString().split(" ")[1]
                                .split("")[1].split(":").first);
                            min = int.parse(recentOrders[index]['Created_On'].toString().split(" ")
                            [1].split(":").last);

                            DateTime a = DateTime(year,month,day,hour,min);



                            DateTime b = DateTime.now();

                            Duration difference = b.difference(a);



                            days = difference.inDays;
                            hours = difference.inHours % 24;
                            minutes = difference.inMinutes % 60;
                            seconds = difference.inSeconds % 60;


                          }else{
                            isExpands[index]=false;
                          }
                        });
                      },
                      child: Container(
                          child:Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              recentOrders[index]["HamperImage"]==null||recentOrders[index]["HamperImage"].toString().isEmpty||
                                  !recentOrders[index]["HamperImage"].toString().startsWith("http")?
                              Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    image: DecorationImage(
                                        image:AssetImage("assets/images/chefdoll.jpg"),
                                        fit: BoxFit.cover
                                    )
                                ),
                              ):
                              Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    image: DecorationImage(
                                        image: NetworkImage('${recentOrders[index]['HamperImage']}'),
                                        fit: BoxFit.cover
                                    )
                                ),
                              ),
                              const SizedBox(width: 5,),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                        padding: const EdgeInsets.only(left: 3,right: 3,top: 2,bottom: 2),
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(20),
                                            color: Colors.grey[300]
                                        ),
                                        child:(recentOrders[index]['Id']!= null)?
                                        Text('Order Id ${recentOrders[index]['Id']}',style: const TextStyle(
                                            fontSize: 10,fontFamily: "Poppins",color: Colors.black
                                        ),):Text('cake id',style: const TextStyle(
                                            fontSize: 10,fontFamily: "Poppins",color: Colors.black
                                        ))
                                    ),
                                    SizedBox(height: 5,),
                                    Container(
                                      child:(recentOrders[index]['HampersName'] != null)
                                          ?Text("${recentOrders[index]['HampersName']} ",style: const TextStyle(
                                          fontSize: 12.5,fontFamily: "Poppins",
                                          color: Colors.black,fontWeight: FontWeight.bold
                                      ),overflow: TextOverflow.ellipsis,maxLines: 4,):
                                      Text("Hamper Name",style: const TextStyle(
                                          fontSize: 12,fontFamily: "Poppins",
                                          color: Colors.black,fontWeight: FontWeight.bold
                                      ),overflow: TextOverflow.ellipsis,),
                                    ),
                                    const SizedBox(height: 3,),
                                    Container(
                                      child:
                                      Row(
                                        // crossAxisAlignment: CrossAxisAlignment.start,
                                        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        mainAxisAlignment:MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text("₹ "
                                          //     "${(
                                          //  double.parse(recentOrders[index]['ItemCount'].toString()) * (
                                          //      (double.parse(recentOrders[index]['Price'].toString())*
                                          //          double.parse(recentOrders[index]['Weight'].toString().
                                          //          toLowerCase().replaceAll("kg", "")))+
                                          //          double.parse(recentOrders[index]['ExtraCharges'].toString())
                                          //  )
                                          // ).toStringAsFixed(2)
                                          // }"
                                              "${(double.parse(recentOrders[index]['Price'])*
                                              double.parse(recentOrders[index]['ItemCount'].toString())).toStringAsFixed(2)}",
                                            style: TextStyle(color: lightPink,
                                                fontWeight: FontWeight.bold,fontFamily: "Poppins"),maxLines: 1,),
                                          Container(
                                            child:recentOrders[index]['Status'].toString().toLowerCase()=='delivered'?
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text("${recentOrders[index]['Status']} ",style: TextStyle(color: Color(0xff058d05),
                                                        fontWeight: FontWeight.bold,fontFamily: "Poppins",fontSize: 11),),
                                                    const Icon(Icons.check_circle,color: Color(0xff058d05),size: 12,)
                                                  ],
                                                ),
                                                Text("${recentOrders[index]['Status_Updated_On']
                                                    .toString().split(" ").first}",style: TextStyle(color:Colors.grey[400],
                                                    fontFamily: "Poppins",fontSize: 10,fontWeight: FontWeight.bold),),
                                              ],
                                            ):
                                            Text(status,style: TextStyle(
                                                color:status.toLowerCase()=='cancelled'?Colors.red:Colors.blueAccent,
                                                fontWeight: FontWeight.bold,fontFamily: "Poppins",fontSize: 11
                                            ),),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              )
                            ],
                          )
                      ),
                    ),
                    SizedBox(height: 10,),
                    Visibility(
                      visible:isExpands[index],
                      child: AnimatedContainer(
                        duration: const Duration(seconds: 3),
                        curve: Curves.elasticInOut,
                        decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(10),
                                bottomRight: Radius.circular(10)
                            )
                        ),
                        child: Column(
                          children: [
                            ListTile(
                              title: const Text('Vendor',style: const TextStyle(
                                  fontSize: 11,fontFamily: "Poppins"
                              ),),
                              subtitle:Text('${recentOrders[index]['VendorName']}',style: TextStyle(
                                  fontSize: 14,fontFamily: "Poppins",
                                  fontWeight: FontWeight.bold,color: Colors.black
                              ),),
                              trailing: Container(
                                width: 100,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    InkWell(
                                      onTap: () async{
                                        PhoneDialog().showPhoneDialog(context, recentOrders[index]['VendorPhoneNumber1'], recentOrders[index]['VendorPhoneNumber2']);
                                      },
                                      child: Container(
                                        alignment: Alignment.center,
                                        height: 35,
                                        width: 35,
                                        decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.white
                                        ),
                                        child:const Icon(Icons.phone,color: Colors.blueAccent,),
                                      ),
                                    ),
                                    const SizedBox(width: 10,),
                                    InkWell(
                                      onTap: () async{
                                        Functions().handleChatWithVendors(context, recentOrders[index]['Email'], recentOrders[index]['VendorName']);
                                        //PhoneDialog().showPhoneDialog(context, recentOrders[index]['VendorPhoneNumber1'], recentOrders[index]['VendorPhoneNumber2'] , true);
                                      },
                                      child: Container(
                                        alignment: Alignment.center,
                                        height: 35,
                                        width: 35,
                                        decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.white
                                        ),
                                        child:const Icon(Icons.whatsapp_rounded,color: Color(0xff058d05),),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.only(left: 15),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Type',style: TextStyle(
                                      fontSize: 11,fontFamily: "Poppins"
                                  ),),
                                  Text('Hamper',style: TextStyle(
                                      fontSize: 14,fontFamily: "Poppins",
                                      fontWeight: FontWeight.bold,color: Colors.black
                                  ),),
                                ],
                              ),
                            ),
                            SizedBox(height: 10,),
                            recentOrders[index]['Status']!="Cancelled"
                                &&days <1 &&minutes<=15&&
                                recentOrders[index]['Status']=="New"?
                            Container(
                              padding: EdgeInsets.only(left: 15,right: 15),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Cancel Order In ${15-minutes} Mins",
                                    style: TextStyle(
                                        fontFamily: "Poppins",
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13
                                    ),),
                                  OutlinedButton(
                                    onPressed: (){
                                      cancelHamperOrder(
                                        recentOrders[index]['_id'] ,
                                        index,
                                        recentOrders[index]['HampersName'] ,
                                      );
                                    },
                                    child: Text("Cancel Order",style: TextStyle(
                                        fontFamily: "Poppins",
                                        fontSize: 12
                                    ),),
                                    style: ButtonStyle(
                                        backgroundColor: MaterialStateProperty.all(
                                            Colors.transparent
                                        ),
                                        side: MaterialStateProperty.all(
                                            BorderSide(width: 0.5,color: Colors.white)
                                        )
                                    ),
                                  )
                                ],
                              ),
                            ):
                            Container(),
                            Container(
                              margin: const EdgeInsets.only(left: 10,right: 10),
                              color:Colors.grey[400],
                              height: 1,
                            ),

                            const SizedBox(height: 15,),

                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(width: 8,),
                                const Icon(
                                  Icons.location_on,
                                  color: Colors.red,
                                ),
                                const SizedBox(width: 8,),
                                Container(
                                    width: 260,
                                    child:Text(
                                      recentOrders[index]['DeliveryAddress']!=null?
                                      "${recentOrders[index]['DeliveryAddress'].toString().trim()}":
                                      "Pick Up",
                                      style: TextStyle(
                                          fontFamily: "Poppins",
                                          color: Colors.black54,
                                          fontSize: 13
                                      ),
                                    )
                                ),
                              ],
                            ),
                            const SizedBox(height: 15,),
                            Container(
                              margin: const EdgeInsets.only(left: 10,right: 10),
                              color:Colors.grey[400],
                              height: 1,
                            ),

                            Container(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text('Product Total',style: TextStyle(
                                    fontFamily: "Poppins",
                                    color: Colors.black54,
                                  ),),
                                  Text("₹ "
                                  //     "${(
                                  //     double.parse(recentOrders[index]['ItemCount'].toString()) * (
                                  //         (double.parse(recentOrders[index]['Price'].toString())*
                                  //             double.parse(recentOrders[index]['Weight'].toString().
                                  //             toLowerCase().replaceAll("kg", "")))+
                                  //             double.parse(recentOrders[index]['ExtraCharges'].toString())
                                  //     )
                                  // ).toStringAsFixed(2)}"
                                      "${(double.parse(recentOrders[index]['Price'])*
                                      double.parse(recentOrders[index]['ItemCount'].toString())).toStringAsFixed(2)}"
                                    ,style: const TextStyle(fontWeight: FontWeight.bold),)
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text('Delivery charge',
                                    style: const TextStyle(
                                      fontFamily: "Poppins",
                                      color: Colors.black54,
                                    ),),
                                  Text('₹ ${double.parse(recentOrders[index]['DeliveryCharge'].toString()).toStringAsFixed(2)}',style: const TextStyle(fontWeight: FontWeight.bold),),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text('Discounts',
                                    style: const TextStyle(
                                      fontFamily: "Poppins",
                                      color: Colors.black54,
                                    ),),
                                  recentOrders[index]['Discount']!=null?
                                  Text('₹ ${double.parse(recentOrders[index]['Discount'].toString()).toStringAsFixed(2)}',style:
                                  const TextStyle(fontWeight: FontWeight.bold),):
                                  Text('₹ 0.00',style:
                                  const TextStyle(fontWeight: FontWeight.bold),),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text('CGST',style: const TextStyle(
                                    fontFamily: "Poppins",
                                    color: Colors.black54,
                                  ),),
                                  Text('₹ ${double.parse(recentOrders[index]['Gst']).toStringAsFixed(2)}',style: const TextStyle(fontWeight: FontWeight.bold),),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text('SGST',style: const TextStyle(
                                    fontFamily: "Poppins",
                                    color: Colors.black54,
                                  ),),
                                  Text('₹ ${double.parse(recentOrders[index]['Sgst']).toStringAsFixed(2)}',style: const TextStyle(fontWeight: FontWeight.bold),),
                                ],
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(left: 10,right: 10),
                              color:Colors.grey[400],
                              height: 1,
                            ),
                            Container(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text('Bill Total',style: TextStyle(
                                      fontFamily: "Poppins",
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold
                                  ),),
                                  Text('₹ ${double.parse(recentOrders[index]['Total']).toStringAsFixed(2)}',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text('Paid via : ${recentOrders[index]['PaymentType']}',style: TextStyle(
                                    fontFamily: "Poppins",
                                    color: Colors.black54,
                                  ),),
                                ],
                              ),
                            ),

                            recentOrders[index]['Status'].toString().toLowerCase()=='delivered'?
                            TextButton(onPressed: (){
                              String rate = '1' ;

                              showDialog(
                                context: context,
                                builder:(context)=>
                                    StatefulBuilder(
                                      builder:(BuildContext context , void Function(void Function()) setState)=>
                                          AlertDialog(
                                            title:Center(
                                              child: Text('Give Rate To Cake',style: TextStyle(
                                                  fontFamily: "Poppins",
                                                  fontSize: 15.5,
                                                  fontWeight: FontWeight.bold
                                              ),),
                                            ),

                                            content:Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                RatingBar.builder(
                                                  initialRating: 1.0,
                                                  minRating: 1,
                                                  direction: Axis.horizontal,
                                                  allowHalfRating: true,
                                                  itemCount: 5,
                                                  itemSize: 30,
                                                  itemPadding: EdgeInsets.symmetric(horizontal: 1.0),
                                                  itemBuilder: (context, _) => Icon(
                                                    Icons.star,
                                                    color: Colors.amber,
                                                  ),
                                                  onRatingUpdate: (rating) {

                                                    setState((){
                                                      rate = rating.toString();
                                                    });
                                                  },
                                                ),
                                                SizedBox(height: 15,),
                                                Text(rate)
                                              ],
                                            ),
                                            actions: [
                                              TextButton(
                                                  onPressed: (){
                                                    Navigator.pop(context);
                                                  },
                                                  child:  Text('Cancel',style: TextStyle(
                                                      fontFamily: "Poppins",
                                                      fontSize: 13.5,
                                                      color:Colors.pinkAccent
                                                  ),)
                                              ),
                                              TextButton(
                                                  onPressed: (){
                                                    Navigator.pop(context);
                                                    rateCake(double.parse(rate),
                                                        recentOrders[index]['CakeID'].toString(), index);
                                                  },
                                                  child:  Text('Rate',style: TextStyle(
                                                      fontFamily: "Poppins",
                                                      fontSize: 13.5,
                                                      color:Color(0xff058d05)
                                                  ),)
                                              ),
                                            ],
                                          ),
                                    ),
                              );


                            },
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.star_border, color: Colors.amber,),
                                    Text(' Rate The Cake',style: TextStyle(
                                        fontFamily: "Poppins"
                                    ),)
                                  ],
                                )):
                            Container(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ):
              recentOrders[index]['ProductName']!=null?
              Container(
                margin: const EdgeInsets.only(top: 10),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black12,width: 1,style:BorderStyle.solid),
                    borderRadius: BorderRadius.circular(15)
                ),
                child: Column(
                  children: [
                    InkWell(
                      onTap:(){
                        setState(() {
                          if(isExpands[index]==false){
                            isExpands[index]=true;

                            List note = vendorsList.where((element) =>
                            element["Id"]==recentOrders[index]['Vendor_ID']).toList();

                            if(note.isNotEmpty){
                              setState((){
                                note[0]['Notification_Id']!=null?
                                notifyId = note[0]['Notification_Id']:notifyId="null";
                              });
                            }

                            //mins calculate

                            year = int.parse(recentOrders[index]['Created_On'].toString().split(" ")
                                .first.split("-").last);
                            month = int.parse(recentOrders[index]['Created_On'].toString().split(" ")
                                .first.split("-")[1]);
                            day = int.parse(recentOrders[index]['Created_On'].toString().split(" ")
                                .first.split("-").first);
                            hour = int.parse(recentOrders[index]['Created_On'].toString().split(" ")[1]
                                .split("")[1].split(":").first);
                            min = int.parse(recentOrders[index]['Created_On'].toString().split(" ")
                            [1].split(":").last);

                            DateTime a = DateTime(year,month,day,hour,min);

                            DateTime b = DateTime.now();

                            Duration difference = b.difference(a);

                            days = difference.inDays;
                            hours = difference.inHours % 24;
                            minutes = difference.inMinutes % 60;
                            seconds = difference.inSeconds % 60;

                          }else{
                            isExpands[index]=false;
                          }
                        });
                      },
                      child: Container(
                          child:Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              recentOrders[index]["Image"]==null||recentOrders[index]["Image"].toString().isEmpty||
                                  !recentOrders[index]["Image"].toString().startsWith("http")?
                              Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    image: DecorationImage(
                                        image:AssetImage("assets/images/chefdoll.jpg"),
                                        fit: BoxFit.cover
                                    )
                                ),
                              ):
                              Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    image: DecorationImage(
                                        image: NetworkImage('${recentOrders[index]['Image']}'),
                                        fit: BoxFit.cover
                                    )
                                ),
                              ),
                              const SizedBox(width: 5,),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                        padding: const EdgeInsets.only(left: 3,right: 3,top: 2,bottom: 2),
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(20),
                                            color: Colors.grey[300]
                                        ),
                                        child:(recentOrders[index]['Id']!= null)?
                                        Text('Order Id ${recentOrders[index]['Id']}',style: const TextStyle(
                                            fontSize: 10,fontFamily: "Poppins",color: Colors.black
                                        ),):Text('cake id',style: const TextStyle(
                                            fontSize: 10,fontFamily: "Poppins",color: Colors.black
                                        ))
                                    ),
                                    SizedBox(height: 5,),
                                    Container(
                                      child:(recentOrders[index]['ProductName'] != null)
                                          ?Text("${recentOrders[index]['ProductName']} ",style: const TextStyle(
                                          fontSize: 12.5,fontFamily: "Poppins",
                                          color: Colors.black,fontWeight: FontWeight.bold
                                      ),overflow: TextOverflow.ellipsis,maxLines: 4,):
                                      Text("My Customise Cake",style: const TextStyle(
                                          fontSize: 12,fontFamily: "Poppins",
                                          color: Colors.black,fontWeight: FontWeight.bold
                                      ),overflow: TextOverflow.ellipsis,),
                                    ),
                                    Container(
                                      child:Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Wrap(
                                            children: [
                                              recentOrders[index]['Shape']!=null?
                                              Text('(Shape - ${recentOrders[index]['Shape']})',style: TextStyle(
                                                  fontSize: 11,fontFamily: "Poppins",color: Colors.grey[500]
                                              ),overflow: TextOverflow.ellipsis,maxLines: 10):
                                              Text('(Shape - None)',style: TextStyle(
                                                  fontSize: 11,fontFamily: "Poppins",color: Colors.grey[500]
                                              ),overflow: TextOverflow.ellipsis,maxLines: 10),
                                              Text("(Flavours : ",style: TextStyle(
                                                  fontSize:10.5,fontFamily: "Poppins",
                                                  color: Colors.grey[500]
                                              ),),
                                              for(var i in recentOrders[index]['Flavour'])
                                                Text("${i})",style: TextStyle(
                                                    fontSize:10.5,fontFamily: "Poppins",
                                                    color:  Colors.grey[500]
                                                ),),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 3,),

                                    Container(
                                      child:
                                      Row(
                                        // crossAxisAlignment: CrossAxisAlignment.start,
                                        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        mainAxisAlignment:MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text("₹ "
                                          //     "${(
                                          //  double.parse(recentOrders[index]['ItemCount'].toString()) * (
                                          //      (double.parse(recentOrders[index]['Price'].toString())*
                                          //          double.parse(recentOrders[index]['Weight'].toString().
                                          //          toLowerCase().replaceAll("kg", "")))+
                                          //          double.parse(recentOrders[index]['ExtraCharges'].toString())
                                          //  )
                                          // ).toStringAsFixed(2)
                                          // }"
                                              "${(double.parse(recentOrders[index]['Total'])-
                                              double.parse(recentOrders[index]['Gst'])-
                                              double.parse(recentOrders[index]['Sgst'])-
                                              double.parse(recentOrders[index]['DeliveryCharge'])).toStringAsFixed(2)}",
                                            style: TextStyle(color: lightPink,
                                                fontWeight: FontWeight.bold,fontFamily: "Poppins"),maxLines: 1,),
                                          Container(
                                            child:recentOrders[index]['Status'].toString().toLowerCase()=='delivered'?
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text("${recentOrders[index]['Status']} ",style: TextStyle(color: Color(0xff058d05),
                                                        fontWeight: FontWeight.bold,fontFamily: "Poppins",fontSize: 11),),
                                                    const Icon(Icons.check_circle,color: Color(0xff058d05),size: 12,)
                                                  ],
                                                ),
                                                Text("${recentOrders[index]['Status_Updated_On']
                                                    .toString().split(" ").first}",style: TextStyle(color:Colors.grey[400],
                                                    fontFamily: "Poppins",fontSize: 10,fontWeight: FontWeight.bold),),
                                              ],
                                            ):
                                            Text(status,style: TextStyle(
                                                color:status.toLowerCase()=='cancelled'?Colors.red:Colors.blueAccent,
                                                fontWeight: FontWeight.bold,fontFamily: "Poppins",fontSize: 11
                                            ),),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              )
                            ],
                          )
                      ),
                    ),
                    SizedBox(height: 10,),
                    Visibility(
                      visible:isExpands[index],
                      child: AnimatedContainer(
                        duration: const Duration(seconds: 3),
                        curve: Curves.elasticInOut,
                        decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(10),
                                bottomRight: Radius.circular(10)
                            )
                        ),
                        child: Column(
                          children: [
                            ListTile(
                              title: const Text('Vendor',style: const TextStyle(
                                  fontSize: 11,fontFamily: "Poppins"
                              ),),
                              subtitle:Text('${recentOrders[index]['VendorName']}',style: TextStyle(
                                  fontSize: 14,fontFamily: "Poppins",
                                  fontWeight: FontWeight.bold,color: Colors.black
                              ),),
                              trailing: Container(
                                width: 100,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    InkWell(
                                      onTap: () async{
                                        PhoneDialog().showPhoneDialog(context, recentOrders[index]['VendorPhoneNumber1'], recentOrders[index]['VendorPhoneNumber2']);
                                      },
                                      child: Container(
                                        alignment: Alignment.center,
                                        height: 35,
                                        width: 35,
                                        decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.white
                                        ),
                                        child:const Icon(Icons.phone,color: Colors.blueAccent,),
                                      ),
                                    ),
                                    const SizedBox(width: 10,),
                                    InkWell(
                                      onTap: () async{
                                        Functions().handleChatWithVendors(context, recentOrders[index]['Email'], recentOrders[index]['VendorName']);
                                        //PhoneDialog().showPhoneDialog(context, recentOrders[index]['VendorPhoneNumber1'], recentOrders[index]['VendorPhoneNumber2'] , true);
                                      },
                                      child: Container(
                                        alignment: Alignment.center,
                                        height: 35,
                                        width: 35,
                                        decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.white
                                        ),
                                        child:const Icon(Icons.whatsapp_rounded,color: Color(0xff058d05),),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.only(left: 15),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Type',style: TextStyle(
                                      fontSize: 11,fontFamily: "Poppins"
                                  ),),
                                  Text('Other Product',style: TextStyle(
                                      fontSize: 14,fontFamily: "Poppins",
                                      fontWeight: FontWeight.bold,color: Colors.black
                                  ),),
                                ],
                              ),
                            ),

                            SizedBox(height: 10,),

                            recentOrders[index]['Status']!="Cancelled"
                                &&days<1&&minutes<=15&&recentOrders[index]['Status']=="New"?
                            Container(
                              padding: EdgeInsets.only(left: 15,right: 15),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Cancel Order In ${15-minutes} Mins",
                                    style: TextStyle(
                                        fontFamily: "Poppins",
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13
                                    ),),
                                  OutlinedButton(
                                    onPressed: (){
                                      cancelHamperOrder(
                                        recentOrders[index]['_id'] ,
                                        index,
                                        recentOrders[index]['HampersName'] ,
                                      );
                                    },
                                    child: Text("Cancel Order",style: TextStyle(
                                        fontFamily: "Poppins",
                                        fontSize: 12
                                    ),),
                                    style: ButtonStyle(
                                        backgroundColor: MaterialStateProperty.all(
                                            Colors.transparent
                                        ),
                                        side: MaterialStateProperty.all(
                                            BorderSide(width: 0.5,color: Colors.white)
                                        )
                                    ),
                                  )
                                ],
                              ),
                            ):
                            Container(),

                            Container(
                              margin: const EdgeInsets.only(left: 10,right: 10),
                              color:Colors.grey[400],
                              height: 1,
                            ),

                            const SizedBox(height: 15,),

                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(width: 8,),
                                const Icon(
                                  Icons.location_on,
                                  color: Colors.red,
                                ),
                                const SizedBox(width: 8,),
                                Container(
                                    width: 260,
                                    child:Text(
                                      recentOrders[index]['DeliveryAddress']!=null?
                                      "${recentOrders[index]['DeliveryAddress'].toString().trim()}":
                                      "Pick Up",
                                      style: TextStyle(
                                          fontFamily: "Poppins",
                                          color: Colors.black54,
                                          fontSize: 13
                                      ),
                                    )
                                ),
                              ],
                            ),
                            const SizedBox(height: 15,),
                            Container(
                              margin: const EdgeInsets.only(left: 10,right: 10),
                              color:Colors.grey[400],
                              height: 1,
                            ),

                            Container(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text('Product Total',style: TextStyle(
                                    fontFamily: "Poppins",
                                    color: Colors.black54,
                                  ),),
                                  Text("₹ "
                                  //     "${(
                                  //     double.parse(recentOrders[index]['ItemCount'].toString()) * (
                                  //         (double.parse(recentOrders[index]['Price'].toString())*
                                  //             double.parse(recentOrders[index]['Weight'].toString().
                                  //             toLowerCase().replaceAll("kg", "")))+
                                  //             double.parse(recentOrders[index]['ExtraCharges'].toString())
                                  //     )
                                  // ).toStringAsFixed(2)}"
                                      "${(double.parse(recentOrders[index]['Total'])-
                                      double.parse(recentOrders[index]['Gst'])-
                                      double.parse(recentOrders[index]['Sgst'])-
                                      double.parse(recentOrders[index]['DeliveryCharge'])).toStringAsFixed(2)}"
                                    ,style: const TextStyle(fontWeight: FontWeight.bold),)

                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text('Delivery charge',
                                    style: const TextStyle(
                                      fontFamily: "Poppins",
                                      color: Colors.black54,
                                    ),),
                                  Text('₹ ${double.parse(recentOrders[index]['DeliveryCharge'].toString()).toStringAsFixed(2)}',style: const TextStyle(fontWeight: FontWeight.bold),),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text('Discounts',
                                    style: const TextStyle(
                                      fontFamily: "Poppins",
                                      color: Colors.black54,
                                    ),),
                                  recentOrders[index]['Discount']!=null?
                                  Text('₹ ${double.parse(recentOrders[index]['Discount'].toString()).toStringAsFixed(2)}',style:
                                  const TextStyle(fontWeight: FontWeight.bold),):
                                  Text('₹ 0.00',style:
                                  const TextStyle(fontWeight: FontWeight.bold),),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text('CGST',style: const TextStyle(
                                    fontFamily: "Poppins",
                                    color: Colors.black54,
                                  ),),
                                  Text('₹ ${double.parse(recentOrders[index]['Gst']).toStringAsFixed(2)}',style: const TextStyle(fontWeight: FontWeight.bold),),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text('SGST',style: const TextStyle(
                                    fontFamily: "Poppins",
                                    color: Colors.black54,
                                  ),),
                                  Text('₹ ${double.parse(recentOrders[index]['Sgst']).toStringAsFixed(2)}',style: const TextStyle(fontWeight: FontWeight.bold),),
                                ],
                              ),
                            ),

                            Container(
                              margin: const EdgeInsets.only(left: 10,right: 10),
                              color:Colors.grey[400],
                              height: 1,
                            ),
                            Container(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text('Bill Total',style: TextStyle(
                                      fontFamily: "Poppins",
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold
                                  ),),
                                  Text('₹ ${double.parse(recentOrders[index]['Total']).toStringAsFixed(2)}',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text('Paid via : ${recentOrders[index]['PaymentType']}',style: TextStyle(
                                    fontFamily: "Poppins",
                                    color: Colors.black54,
                                  ),),
                                ],
                              ),
                            ),

                            recentOrders[index]['Status'].toString().toLowerCase()=='delivered'?
                            TextButton(onPressed: (){
                              String rate = '1' ;

                              showDialog(
                                context: context,
                                builder:(context)=>
                                    StatefulBuilder(
                                      builder:(BuildContext context , void Function(void Function()) setState)=>
                                          AlertDialog(
                                            title:Center(
                                              child: Text('Give Rate To Cake',style: TextStyle(
                                                  fontFamily: "Poppins",
                                                  fontSize: 15.5,
                                                  fontWeight: FontWeight.bold
                                              ),),
                                            ),

                                            content:Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                RatingBar.builder(
                                                  initialRating: 1.0,
                                                  minRating: 1,
                                                  direction: Axis.horizontal,
                                                  allowHalfRating: true,
                                                  itemCount: 5,
                                                  itemSize: 30,
                                                  itemPadding: EdgeInsets.symmetric(horizontal: 1.0),
                                                  itemBuilder: (context, _) => Icon(
                                                    Icons.star,
                                                    color: Colors.amber,
                                                  ),
                                                  onRatingUpdate: (rating) {

                                                    setState((){
                                                      rate = rating.toString();
                                                    });
                                                  },
                                                ),
                                                SizedBox(height: 15,),
                                                Text(rate)
                                              ],
                                            ),
                                            actions: [
                                              TextButton(
                                                  onPressed: (){
                                                    Navigator.pop(context);
                                                  },
                                                  child:  Text('Cancel',style: TextStyle(
                                                      fontFamily: "Poppins",
                                                      fontSize: 13.5,
                                                      color:Colors.pinkAccent
                                                  ),)
                                              ),
                                              TextButton(
                                                  onPressed: (){
                                                    Navigator.pop(context);
                                                    rateCake(double.parse(rate),
                                                        recentOrders[index]['CakeID'].toString(), index);
                                                  },
                                                  child:  Text('Rate',style: TextStyle(
                                                      fontFamily: "Poppins",
                                                      fontSize: 13.5,
                                                      color:Color(0xff058d05)
                                                  ),)
                                              ),
                                            ],
                                          ),
                                    ),
                              );


                            },
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.star_border, color: Colors.amber,),
                                    Text(' Rate The Cake',style: TextStyle(
                                        fontFamily: "Poppins"
                                    ),)
                                  ],
                                )):
                            Container(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ):
              Container(
                margin: const EdgeInsets.only(top: 10),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black12,width: 1,style:BorderStyle.solid),
                    borderRadius: BorderRadius.circular(15)
                ),
                child: Column(
                  children: [
                    InkWell(
                      onTap:(){
                        setState(() {
                          if(isExpands[index]==false){
                            isExpands[index]=true;

                            List note = vendorsList.where((element) =>
                            element["Id"]==recentOrders[index]['Vendor_ID']).toList();

                            if(note.isNotEmpty){
                              setState((){
                                note[0]['Notification_Id']!=null?
                                notifyId = note[0]['Notification_Id']:notifyId="null";
                              });
                            }

                            //mins calculate

                            year = int.parse(recentOrders[index]['Created_On'].toString().split(" ")
                                .first.split("-").last);
                            month = int.parse(recentOrders[index]['Created_On'].toString().split(" ")
                                .first.split("-")[1]);
                            day = int.parse(recentOrders[index]['Created_On'].toString().split(" ")
                                .first.split("-").first);
                            hour = int.parse(recentOrders[index]['Created_On'].toString().split(" ")[1]
                                .split("")[1].split(":").first);
                            min = int.parse(recentOrders[index]['Created_On'].toString().split(" ")
                            [1].split(":").last);

                            DateTime a = DateTime(year,month,day,hour,min);

                            DateTime b = DateTime.now();

                            Duration difference = b.difference(a);

                            days = difference.inDays;
                            hours = difference.inHours % 24;
                            minutes = difference.inMinutes % 60;
                            seconds = difference.inSeconds % 60;

                          }else{
                            isExpands[index]=false;
                          }
                        });
                      },
                      child: Container(
                          child:Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              recentOrders[index]["Image"]==null||recentOrders[index]["Image"].toString().isEmpty||
                                  !recentOrders[index]["Image"].toString().startsWith("http")?
                              Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    image: DecorationImage(
                                        image:AssetImage("assets/images/chefdoll.jpg"),
                                        fit: BoxFit.cover
                                    )
                                ),
                              ):
                              Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    image: DecorationImage(
                                        image: NetworkImage('${recentOrders[index]['Image']}'),
                                        fit: BoxFit.cover
                                    )
                                ),
                              ),
                              const SizedBox(width: 5,),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                        padding: const EdgeInsets.only(left: 3,right: 3,top: 2,bottom: 2),
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(20),
                                            color: Colors.grey[300]
                                        ),
                                        child:(recentOrders[index]['Id']!= null)?
                                        Text('Order Id ${recentOrders[index]['Id']}',style: const TextStyle(
                                            fontSize: 10,fontFamily: "Poppins",color: Colors.black
                                        ),):Text('cake id',style: const TextStyle(
                                            fontSize: 10,fontFamily: "Poppins",color: Colors.black
                                        ))
                                    ),
                                    SizedBox(height: 5,),
                                    Container(
                                      child:(recentOrders[index]['CakeName'] != null)
                                          ?Text("${recentOrders[index]['CakeName']} ",style: const TextStyle(
                                          fontSize: 12.5,fontFamily: "Poppins",
                                          color: Colors.black,fontWeight: FontWeight.bold
                                      ),overflow: TextOverflow.ellipsis,maxLines: 4,):
                                      Text("My Customise Cake",style: const TextStyle(
                                          fontSize: 12,fontFamily: "Poppins",
                                          color: Colors.black,fontWeight: FontWeight.bold
                                      ),overflow: TextOverflow.ellipsis,),
                                    ),
                                    Container(
                                      child:Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          recentOrders[index]['CustomizeCake'].toString()=="n"?
                                          Wrap(
                                            children: [
                                              Text('(Shape - ${recentOrders[index]['Shape']['Name']})',style: TextStyle(
                                                  fontSize: 11,fontFamily: "Poppins",color: Colors.grey[500]
                                              ),overflow: TextOverflow.ellipsis,maxLines: 10),
                                              Text("(Flavours : ",style: TextStyle(
                                                  fontSize:10.5,fontFamily: "Poppins",
                                                  color: Colors.grey[500]
                                              ),),
                                              for(var i in recentOrders[index]['Flavour'])
                                                Text("${i['Name']})",style: TextStyle(
                                                    fontSize:10.5,fontFamily: "Poppins",
                                                    color:  Colors.grey[500]
                                                ),),
                                            ],
                                          ):
                                          Wrap(
                                            children: [
                                              Text('(Shape - ${recentOrders[index]['Shape']['Name']})',style: TextStyle(
                                                  fontSize: 11,fontFamily: "Poppins",color: Colors.grey[500]
                                              ),overflow: TextOverflow.ellipsis,maxLines: 10),
                                              Text("(Flavours : ",style: TextStyle(
                                                  fontSize:10.5,fontFamily: "Poppins",
                                                  color: Colors.grey[500]
                                              ),),
                                              for(var i in recentOrders[index]['Flavour'])
                                                Text("${i['Name']}",style: TextStyle(
                                                    fontSize:10.5,fontFamily: "Poppins",
                                                    color:  Colors.grey[500]
                                                ),),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 3,),

                                    Container(
                                      child:
                                      Row(
                                        // crossAxisAlignment: CrossAxisAlignment.start,
                                        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        mainAxisAlignment:MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text("₹ "
                                          //     "${(
                                          //  double.parse(recentOrders[index]['ItemCount'].toString()) * (
                                          //      (double.parse(recentOrders[index]['Price'].toString())*
                                          //          double.parse(recentOrders[index]['Weight'].toString().
                                          //          toLowerCase().replaceAll("kg", "")))+
                                          //          double.parse(recentOrders[index]['ExtraCharges'].toString())
                                          //  )
                                          // ).toStringAsFixed(2)
                                          // }"
                                              "$gramAndKilo",
                                            style: TextStyle(color: lightPink,
                                                fontWeight: FontWeight.bold,fontFamily: "Poppins"),maxLines: 1,),
                                          Container(
                                            child:recentOrders[index]['Status'].toString().toLowerCase()=='delivered'?
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text("${recentOrders[index]['Status']} ",style: TextStyle(color: Color(0xff058d05),
                                                        fontWeight: FontWeight.bold,fontFamily: "Poppins",fontSize: 11),),
                                                    const Icon(Icons.check_circle,color: Color(0xff058d05),size: 12,)
                                                  ],
                                                ),
                                                Text("${recentOrders[index]['Status_Updated_On']
                                                    .toString().split(" ").first}",style: TextStyle(color:Colors.grey[400],
                                                    fontFamily: "Poppins",fontSize: 10,fontWeight: FontWeight.bold),),
                                              ],
                                            ):
                                            Text(status,style: TextStyle(
                                                color:status.toLowerCase()=='cancelled'?Colors.red:Colors.blueAccent,
                                                fontWeight: FontWeight.bold,fontFamily: "Poppins",fontSize: 11
                                            ),),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              )
                            ],
                          )
                      ),
                    ),
                    SizedBox(height: 10,),
                    Visibility(
                      visible:isExpands[index],
                      child: AnimatedContainer(
                        duration: const Duration(seconds: 3),
                        curve: Curves.elasticInOut,
                        decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(10),
                                bottomRight: Radius.circular(10)
                            )
                        ),
                        child: Column(
                          children: [
                            ListTile(
                              title: const Text('Vendor',style: const TextStyle(
                                  fontSize: 11,fontFamily: "Poppins"
                              ),),
                              subtitle:Text('${recentOrders[index]['VendorName']}',style: TextStyle(
                                  fontSize: 14,fontFamily: "Poppins",
                                  fontWeight: FontWeight.bold,color: Colors.black
                              ),),
                              trailing: Container(
                                width: 100,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    InkWell(
                                      onTap: () async{
                                        PhoneDialog().showPhoneDialog(context, recentOrders[index]['VendorPhoneNumber1'], recentOrders[index]['VendorPhoneNumber2']);
                                      },
                                      child: Container(
                                        alignment: Alignment.center,
                                        height: 35,
                                        width: 35,
                                        decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.white
                                        ),
                                        child:const Icon(Icons.phone,color: Colors.blueAccent,),
                                      ),
                                    ),
                                    const SizedBox(width: 10,),
                                    InkWell(
                                      onTap: () async{
                                        Functions().handleChatWithVendors(context, recentOrders[index]['Email'], recentOrders[index]['VendorName']);
                                        //PhoneDialog().showPhoneDialog(context, recentOrders[index]['VendorPhoneNumber1'], recentOrders[index]['VendorPhoneNumber2'] , true);
                                      },
                                      child: Container(
                                        alignment: Alignment.center,
                                        height: 35,
                                        width: 35,
                                        decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.white
                                        ),
                                        child:const Icon(Icons.whatsapp_rounded,color: Color(0xff058d05),),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            recentOrders[index]['CustomizeCake'].toString()=="n"?
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.only(left: 15),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Cake Type',style: TextStyle(
                                      fontSize: 11,fontFamily: "Poppins"
                                  ),),
                                  Text('Cakes',style: TextStyle(
                                      fontSize: 14,fontFamily: "Poppins",
                                      fontWeight: FontWeight.bold,color: Colors.black
                                  ),),
                                ],
                              ),
                            ):
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.only(left: 15),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Cake Type',style: TextStyle(
                                      fontSize: 11,fontFamily: "Poppins"
                                  ),),
                                  Text('Customized Cake',style: TextStyle(
                                      fontSize: 14,fontFamily: "Poppins",
                                      fontWeight: FontWeight.bold,color: Colors.black
                                  ),),
                                ],
                              ),
                            ),

                            SizedBox(height: 10,),

                            recentOrders[index]['Status']!="Cancelled"
                                &&days<1&&minutes<=15&&recentOrders[index]['Status']=="New"?
                            Container(
                              padding: EdgeInsets.only(left: 15,right: 15),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Cancel Order In ${15-minutes} Mins",
                                    style: TextStyle(
                                        fontFamily: "Poppins",
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13
                                    ),),
                                  OutlinedButton(
                                    onPressed: (){

                                      showOrderCancelDialog(
                                          recentOrders[index]['_id'],
                                          recentOrders[index]['UserID'],
                                          recentOrders[index]['CakeName'],
                                          index
                                      );

                                    },
                                    child: Text("Cancel Order",style: TextStyle(
                                        fontFamily: "Poppins",
                                        fontSize: 12
                                    ),),
                                    style: ButtonStyle(
                                        backgroundColor: MaterialStateProperty.all(
                                            Colors.transparent
                                        ),
                                        side: MaterialStateProperty.all(
                                            BorderSide(width: 0.5,color: Colors.white)
                                        )
                                    ),
                                  )
                                ],
                              ),
                            ):Container(),

                            Container(
                              margin: const EdgeInsets.only(left: 10,right: 10),
                              color:Colors.grey[400],
                              height: 1,
                            ),

                            const SizedBox(height: 15,),

                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(width: 8,),
                                const Icon(
                                  Icons.location_on,
                                  color: Colors.red,
                                ),
                                const SizedBox(width: 8,),
                                Container(
                                    width: 260,
                                    child:Text(
                                      recentOrders[index]['DeliveryAddress']!=null?
                                      "${recentOrders[index]['DeliveryAddress'].toString().trim()}":
                                      "Pick Up",
                                      style: TextStyle(
                                          fontFamily: "Poppins",
                                          color: Colors.black54,
                                          fontSize: 13
                                      ),
                                    )
                                ),
                              ],
                            ),
                            const SizedBox(height: 15,),
                            Container(
                              margin: const EdgeInsets.only(left: 10,right: 10),
                              color:Colors.grey[400],
                              height: 1,
                            ),
                            Container(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text('Product Total',style: TextStyle(
                                    fontFamily: "Poppins",
                                    color: Colors.black54,
                                  ),),
                                  recentOrders[index]['ExtraCharges']!=null?
                                  Text("₹ "
                                  //     "${(
                                  //     double.parse(recentOrders[index]['ItemCount'].toString()) * (
                                  //         (double.parse(recentOrders[index]['Price'].toString())*
                                  //             double.parse(recentOrders[index]['Weight'].toString().
                                  //             toLowerCase().replaceAll("kg", "")))+
                                  //             double.parse(recentOrders[index]['ExtraCharges'].toString())
                                  //     )
                                  // ).toStringAsFixed(2)}"
                                      "$gramAndKilo"
                                    ,style: const TextStyle(fontWeight: FontWeight.bold),):
                                  Text(""),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text('Delivery charge',
                                    style: const TextStyle(
                                      fontFamily: "Poppins",
                                      color: Colors.black54,
                                    ),),
                                  Text('₹${double.parse(recentOrders[index]['DeliveryCharge'].toString()).toStringAsFixed(2)}',style: const TextStyle(fontWeight: FontWeight.bold),),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text('Discounts',
                                    style: const TextStyle(
                                      fontFamily: "Poppins",
                                      color: Colors.black54,
                                    ),),
                                  Text('₹${recentOrders[index]['Discount'].toStringAsFixed(2)}',style: const TextStyle(fontWeight: FontWeight.bold),),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text('Gst',style: const TextStyle(
                                    fontFamily: "Poppins",
                                    color: Colors.black54,
                                  ),),
                                  Text('₹${double.parse(recentOrders[index]['Gst']).toStringAsFixed(2)}',style: const TextStyle(fontWeight: FontWeight.bold),),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text('SGST',style: const TextStyle(
                                    fontFamily: "Poppins",
                                    color: Colors.black54,
                                  ),),
                                  Text('₹${double.parse(recentOrders[index]['Sgst']).toStringAsFixed(2)}',style: const TextStyle(fontWeight: FontWeight.bold),),
                                ],
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(left: 10,right: 10),
                              color:Colors.grey[400],
                              height: 1,
                            ),
                            Container(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text('Bill Total',style: TextStyle(
                                      fontFamily: "Poppins",
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold
                                  ),),
                                  Text('₹${double.parse(recentOrders[index]['Total']).toStringAsFixed(2)}',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text('Paid via : ${recentOrders[index]['PaymentType']}',style: TextStyle(
                                    fontFamily: "Poppins",
                                    color: Colors.black54,
                                  ),),
                                ],
                              ),
                            ),

                            recentOrders[index]['Status'].toString().toLowerCase()=='delivered'?
                            TextButton(onPressed: (){
                              String rate = '1' ;

                              showDialog(
                                context: context,
                                builder:(context)=>
                                    StatefulBuilder(
                                      builder:(BuildContext context , void Function(void Function()) setState)=>
                                          AlertDialog(
                                            title:Center(
                                              child: Text('Give Rate To Cake',style: TextStyle(
                                                  fontFamily: "Poppins",
                                                  fontSize: 15.5,
                                                  fontWeight: FontWeight.bold
                                              ),),
                                            ),

                                            content:Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                RatingBar.builder(
                                                  initialRating: 1.0,
                                                  minRating: 1,
                                                  direction: Axis.horizontal,
                                                  allowHalfRating: true,
                                                  itemCount: 5,
                                                  itemSize: 30,
                                                  itemPadding: EdgeInsets.symmetric(horizontal: 1.0),
                                                  itemBuilder: (context, _) => Icon(
                                                    Icons.star,
                                                    color: Colors.amber,
                                                  ),
                                                  onRatingUpdate: (rating) {

                                                    setState((){
                                                      rate = rating.toString();
                                                    });
                                                  },
                                                ),
                                                SizedBox(height: 15,),
                                                Text(rate)
                                              ],
                                            ),
                                            actions: [
                                              TextButton(
                                                  onPressed: (){
                                                    Navigator.pop(context);
                                                  },
                                                  child:  Text('Cancel',style: TextStyle(
                                                      fontFamily: "Poppins",
                                                      fontSize: 13.5,
                                                      color:Colors.pinkAccent
                                                  ),)
                                              ),
                                              TextButton(
                                                  onPressed: (){
                                                    Navigator.pop(context);
                                                    rateCake(double.parse(rate),
                                                        recentOrders[index]['CakeID'].toString(), index);
                                                  },
                                                  child:  Text('Rate',style: TextStyle(
                                                      fontFamily: "Poppins",
                                                      fontSize: 13.5,
                                                      color:Color(0xff058d05)
                                                  ),)
                                              ),
                                            ],
                                          ),
                                    ),
                              );


                            },
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.star_border, color: Colors.amber,),
                                    Text(' Rate The Cake',style: TextStyle(
                                        fontFamily: "Poppins"
                                    ),)
                                  ],
                                )):
                            Container(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
        ):
        Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 15,),
            Icon(Icons.shopping_bag_outlined , color: darkBlue,size: 50,),
            Text('No orders found!' , style: TextStyle(
                color: lightPink , fontWeight: FontWeight.bold , fontSize: 20
            ),),
          ],
        ),
      ],
    );

  }
  //endregion

  @override
  Widget build(BuildContext context) {
    if(context.watch<ContextData>().getAddress().isNotEmpty){
      setState((){selectedAdres = context.watch<ContextData>().getAddress();});
    }else{
      setState((){selectedAdres = userAddress;});
    }

    addressList = context.watch<ContextData>().getAddressList();

    notiCount = context.watch<ContextData>().getNotiCount();

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50),
        child: SafeArea(
          child: Container(
            padding: EdgeInsets.only(left: 15, right: 15),
            color: lightGrey,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      // margin: const EdgeInsets.only(top: 10,bottom: 15),
                      child: InkWell(
                        onTap: (){
                          Navigator.pop(context);
                        },
                        child: Container(
                          height: 30,
                          decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(7)
                          ),
                          alignment: Alignment.center,
                          child: Icon(Icons.chevron_left,size: 30,color: lightPink,),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 15),
                      child: Text(
                        'PROFILE',
                        style: TextStyle(
                            color: darkBlue,
                            fontWeight: FontWeight.bold,fontSize: 18
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: (){
                        setState(() {
                          fetchProfileByPhn();
                        });
                      },
                      icon: Icon(Icons.refresh),
                      color: darkBlue,
                    ),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 10,bottom: 10),
                          child: InkWell(
                            onTap: (){
                              Navigator.of(context).push(
                                PageRouteBuilder(
                                  pageBuilder: (context, animation, secondaryAnimation) => Notifications(),
                                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                    const begin = Offset(1.0, 0.0);
                                    const end = Offset.zero;
                                    const curve = Curves.ease;

                                    final tween = Tween(begin: begin, end: end);
                                    final curvedAnimation = CurvedAnimation(
                                      parent: animation,
                                      curve: curve,
                                    );
                                    return SlideTransition(
                                      position: tween.animate(curvedAnimation),
                                      child: child,
                                    );
                                  },
                                ),
                              );
                            },
                            child: Container(
                              height: 30,
                              padding: EdgeInsets.all(1),
                              decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(7)
                              ),
                              alignment: Alignment.center,
                              child: Icon( Icons.notifications_none,size: 27,color: darkBlue,),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 17,
                          top: 17,
                          child: notiCount > 0?
                          CircleAvatar(
                            radius: 3.5,
                            backgroundColor: Colors.white,
                            child: CircleAvatar(
                              radius: 2.7,
                              backgroundColor: Colors.red,
                            ),
                          ):Container(height:0,width:0),
                        ),
                      ],
                    ),
                    // const SizedBox(
                    //   width: 2,
                    // )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
      body: Container(
        margin: const EdgeInsets.all(10),
        padding: EdgeInsets.only(top: 5),
        child: Column(
          children: [
            Container(
              height: 45,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black54,width: 1),
                borderRadius: BorderRadius.circular(
                  25.0,
                ),
              ),
              child: TabBar(
                controller: tabControl,
                // give the indicator a decoration (color and border radius)
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    25.0,
                  ),
                  color: Colors.black,
                ),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.black,
                tabs: [
                  // first tab [you can add an icon using the icon property]
                  const Tab(
                    text: 'PROFILE INFO',
                  ),
                  // second tab [you can add an icon using the icon property]
                  const Tab(
                    text: 'ORDER INFO',
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                  controller: tabControl,
                  children: [
                    SingleChildScrollView(
                        child: ProfileView()
                    ),
                    SingleChildScrollView(
                        child: OrdersView()
                    ),
                  ]
              ),

            )
          ],
        ),
      ),
    );
  }

  Future<void> SendMessage(String? value) async{
    var headers = {
      'Authorization': 'Bearer AAAAfUzNhqs:APA91bEsu2OWHUz4U7Y2Y0Z3XpkBN0ePeyLEcBioYQd-UQdcr3pDjXvYfDcZaWrSExv-L-BfKBoAs6h10YMqRwNZZU7wrFmxsg8PvkpTtMw1PZEyxeH8Pd25vcKjEtFhhqriBMKcuIEj',
      'Content-Type': 'application/json'
    };
    var request = http.Request('POST', Uri.parse('https://fcm.googleapis.com/fcm/send'));
    request.body = json.encode({
      "registration_ids": [
        "$value",
        "c-H4wpgTQLC-qUTgx5gM2m:APA91bGSHe6VDjHbzr-f62FRtupeHX5HfBGta_K1ghVZQmWjwswqrM63-xZpCfMQ_0KipE7jOJyJdWwnPVgKt4nNj_hQWDj0EwLc_K2q_pHCgOwOv4NiznZDY6inbnGzSsbcb5T8c3WL"
      ],
      "notification": {
        "title": "Order Placed",
        "body": "Your Order Ben 10 Theme Cake Successfully placed.Thank You."
      },
      "data": {
        "msgId": "msg_12342"
      }
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();


    print(response.statusCode);

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
    }
    else {
      print(response.reasonPhrase);
    }

  }
}


differenceOF(String dateTime, {bool numberDate = true}) {
  DateTime date = DateTime.parse(dateTime);
  final dateNow = DateTime.now();
  final difference = dateNow.difference(date);
  if ((difference.inDays / 365).floor() >= 2) {
    return '${(difference.inDays / 365).floor()} Years Ago';
  } else if ((difference.inDays / 365).floor() >= 1) {
    return (numberDate) ? '1 Years Ago' : 'Last Year';
  } else if ((difference.inDays / 30).floor() >= 2) {
    return '${(difference.inDays / 30).floor()} Months Ago';
  } else if ((difference.inDays / 30).floor() >= 1) {
    return (numberDate) ? '1 Month Ago' : 'Last Month';
  } else if ((difference.inDays / 7).floor() >= 2) {
    return '${(difference.inDays / 7).floor()} Weeks Ago';
  } else if ((difference.inDays / 7).floor() >= 1) {
    return (numberDate) ? '1 Week Ago' : 'Last Week';
  } else if (difference.inDays >= 2) {
    return '${difference.inDays} Days Ago';
  } else if (difference.inDays >= 1) {
    return (numberDate) ? '1 Day Ago' : 'Yesterday';
  } else if (difference.inHours >= 2) {
    return '${difference.inHours} Hours Ago';
  } else if (difference.inHours >= 1) {
    return (numberDate) ? '1 Hour Ago' : 'Last Hour';
  } else if (difference.inMinutes >= 2) {
    return '${difference.inMinutes} Minutes Ago';
  } else if (difference.inMinutes >= 1) {
    return (numberDate) ? '1 Minute Ago' : 'Last Minute';
  } else if (difference.inSeconds >= 3) {
    return '${difference.inSeconds} Seconds Ago';
  } else {
    return 'Now';
  }
}


