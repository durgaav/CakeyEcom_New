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
  var phoneNumCtrl = new TextEditingController();

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
      profileDetailHandler();
    });
    super.initState();
  }

  Future profileDetailHandler() async {
    Functions().getUserData().then((value){
      if(value.isNotEmpty){
        print(value);
        userID = value['_id'];
        //userModId = value['Id'];
        userNameCtrl.text = value['UserName'];
        phoneNumCtrl.text = value['PhoneNumber'].toString();
        userAddrCtrl.text = value['Address'];
        pinCodeCtrl.text = value['Pincode'];
        userProfileUrl = value['ProfileImage'].toString();
        fbToken = value['Notification_Id'].toString();
        context.read<ContextData>().setUserName(userNameCtrl.text);
        context.read<ContextData>().setProfileUrl(value['ProfileImage'].toString());
        getOrderList(userID);
      }
    });
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
      //phoneNumber = prefs.getString("phoneNumber") ?? "";
      authToken = prefs.getString("authToken") ?? 'no auth';
      addressList = prefs.getStringList('addressList')??[];

      print('addressList... $addressList');

      //fetchProfileByPhn();
    });
    context.read<ContextData>().setAddressList(addressList);
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
        'UserName': userNameCtrl.text,
        'Address': userAddrCtrl.text,
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


        setState(() {
          file = new File('');
          profileDetailHandler();
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

  void showReasonDialog(String type , String ordId) {
    var textCtrl = TextEditingController();
    showModalBottomSheet(
        context: context,
        isScrollControlled:true,
        shape:RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
                top:Radius.circular(15)
            )
        ),
        builder:(c){
          return Padding(
            padding:EdgeInsets.only(bottom:MediaQuery.of(context).viewInsets.bottom),
            child: Container(
              decoration:BoxDecoration(
                borderRadius: BorderRadius.vertical(
                  top:Radius.circular(15)
                )
              ),
              padding:EdgeInsets.symmetric(
                vertical:10,horizontal:10
              ),
              child:Column(
                mainAxisSize:MainAxisSize.min,
                crossAxisAlignment:CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding:EdgeInsets.symmetric(
                      vertical:10, horizontal:5
                    ),
                    child: Text("Hi , please give the reason for cancel this order.",style:TextStyle(
                      color:Colors.black,
                      fontFamily:'Poppins',
                      fontSize:15,
                      fontWeight:FontWeight.bold,
                    ),),
                  ),
                  Row(
                    children: [
                      Icon(Icons.note_alt , color:Colors.red,),
                      SizedBox(width:6,),
                      Expanded(child: TextField(
                        controller:textCtrl,
                        decoration:InputDecoration(
                          border:InputBorder.none,
                          hintText:"Type your reason...",
                          isDense: true,
                          hintStyle:TextStyle(
                            color:Colors.grey,
                            fontFamily:"Poppins",
                            fontSize:13
                          )
                        ),
                      )),
                      SizedBox(width:6,),
                      InkWell(
                        onTap:(){
                          Navigator.pop(context);
                          if(textCtrl.text.isNotEmpty){
                            if(type.toLowerCase()=="cakes"){
                              cancelNormalCakeOrder(textCtrl.text, ordId);
                            }else if(type.toLowerCase()=="gift hampers"){
                              cancelHamperOrder(textCtrl.text, ordId);
                            }else if(type.toLowerCase()=="other products"){
                              cancelOtherProductsOrder(textCtrl.text, ordId);
                            }else{
                              cancelCustomiseOrder(textCtrl.text, ordId);
                            }
                          }else{
                            Functions().showSnackMsg(context,"Please provide order cancellation reason", true);
                          }
                        },
                        child:Text("CANCEL ORDER",style: TextStyle(
                          fontFamily:"Poppins",
                          color:Colors.red,
                          fontSize:13
                        ),),
                      )
                    ],
                  ),
                  SizedBox(height:5,)
                ],
              ),
            ),
          );
        }
    );
  }

  Future cancelNormalCakeOrder(String reason , String ordId) async {
    showAlertDialog();
    try{
      //{"statusCode":200,"message":"Order Rejected"}
      http.Response response = await http.put(
        Uri.parse('${API_URL}api/order/cancel/$ordId'),
        body:jsonEncode(<String , dynamic>{
          "Cancelled_By": "User",
          "ReasonForCancel":reason,
          "Status_Updated_By":userID
        }),
        headers:{
          "Content-Type":"application/json"
        }
      );

      print({
        "Cancelled_By": "User",
        "ReasonForCancel":reason,
        "Status_Updated_By":userID
      });

      if(response.statusCode==200){
        Functions().showSnackMsg(context, jsonDecode(response.body)['message'], false);
        profileDetailHandler();
        Navigator.pop(context);
      }else{
        Navigator.pop(context);
      }

    }catch(e){
      Navigator.pop(context);
    }

  }

  Future cancelHamperOrder(String reason , String ordId) async {
    showAlertDialog();
    try{
      //{"statusCode":200,"message":"Order Rejected"}
      http.Response response = await http.put(
          Uri.parse('${API_URL}api/hamperorder/canceled/$ordId'),
          body:jsonEncode(<String , dynamic>{
            "Cancelled_By": "User",
            "ReasonForCancel":reason,
          }),
          headers:{
            "Content-Type":"application/json"
          }
      );

      print({
        "Cancelled_By": "User",
        "ReasonForCancel":reason,
        "Status_Updated_By":userID
      });

      if(response.statusCode==200){
        Functions().showSnackMsg(context, jsonDecode(response.body)['message'], false);
        profileDetailHandler();
        Navigator.pop(context);
      }else{
        Navigator.pop(context);
      }

    }catch(e){
      Navigator.pop(context);
    }

  }

  Future cancelOtherProductsOrder(String reason , String ordId) async {
    showAlertDialog();
    try{
      //{"statusCode":200,"message":"Order Rejected"}
      http.Response response = await http.put(
          Uri.parse('${API_URL}api/otherproduct/order/acceptorcancel/$ordId'),
          body:jsonEncode(<String , dynamic>{
            "Cancelled_By": "User",
            "Status_Updated_By":userID,
            "Status":"Cancelled",
            "ReasonForCancel":reason,
          }),
          headers:{
            "Content-Type":"application/json"
          }
      );

      print({
        "Cancelled_By": "User",
        "ReasonForCancel":reason,
        "Status_Updated_By":userID
      });

      if(response.statusCode==200){
        Functions().showSnackMsg(context, jsonDecode(response.body)['message'], false);
        profileDetailHandler();
        Navigator.pop(context);
      }else{
        Navigator.pop(context);
      }

    }catch(e){
      Navigator.pop(context);
    }

  }

  Future cancelCustomiseOrder(String reason , String ordId) async {
    showAlertDialog();
    try{
      //{"statusCode":200,"message":"Order Rejected"}
      http.Response response = await http.put(
          Uri.parse('${API_URL}api/customize/cake/cancel/$ordId'),
          body:jsonEncode(<String , dynamic>{
            "Cancelled_By": "User",
            "Status_Updated_By":userID,
            "ReasonForCancel":reason,
          }),
          headers:{
            "Content-Type":"application/json"
          }
      );

      print({
        "Cancelled_By": "User",
        "ReasonForCancel":reason,
        "Status_Updated_By":userID
      });

      if(response.statusCode==200){
        Functions().showSnackMsg(context, jsonDecode(response.body)['message'], false);
        profileDetailHandler();
        Navigator.pop(context);
      }else{
        Navigator.pop(context);
      }

    }catch(e){
      Navigator.pop(context);
    }

  }

  //getting order list...
  Future<void> getOrderList(String _id) async{

    //api/ordersandhamperorders/listbyuser/
    //api/orders/listByUser/All/
    //63d7a28df304865dca2ecffc

    print("User Id $_id");

    showAlertDialog();

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
          userAddrCtrl.text = body[0]['Address'].toString();
          userProfileUrl = body[0]['ProfileImage'].toString();
          fbToken = body[0]['Notification_Id'].toString();
          userNameCtrl.text = body[0]['UserName'].toString();
          pinCodeCtrl.text = body[0]['Pincode'].toString();
          prefs.setString('userID', userID);
          prefs.setString('userAddress', userAddress);
          prefs.setString('userName', userName);
          context.read<ContextData>().setUserName(userName);
          context.read<ContextData>().setProfileUrl(userProfileUrl);
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
        if(Functions().getFileSizeInMB(path)<3){
          file = File(path);
        }else{
          Functions().showSnackMsg(context, "Please select the file below 3 MB",true);
        }
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

  //Notifications....

  //endregion

  //region Widgets.....
  Widget ProfileView(){
    userProfileUrl = context.watch<ContextData>().getProfileUrl();
    setState(() {
      userNameCtrl = TextEditingController(text: userNameCtrl.text.toString()=="null"?"":userNameCtrl.text);
      userAddrCtrl = TextEditingController(text: userAddrCtrl.text.toString()=="null"?"":userAddrCtrl.text);
      pinCodeCtrl = TextEditingController(text: pinCodeCtrl.text.toString()=="null"?"":pinCodeCtrl.text);
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
              controller:phoneNumCtrl,
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

  Widget orderDetailsTile(int index) {

    bool showTile = false;
    String orderId = "";
    String cakeName = "";
    String image ="";
    String vendorName = "Premium Vendor";
    String typeOfCake = "Cakes";
    String shape = "None";
    String status = "";
    List<dynamic> flavours = ["None"];

    double productTotal = 0;
    double extraCharge = 0;
    int count = 1;
    String gramAndKilo = "";
    String address = "";
    double deliveryCharge = 0;
    double discounts = 0;
    double cgst = 0;
    double sgst = 0;
    double billTot = 0;
    String paidVia = "Online";
    var myMap = Map();
    double weight = 0.0;
    double couponVal = 0.0;

    //30-01-2023 03:36 PM
    //2023-02-03 11:11:00.000
    String created = recentOrders[index]['Created_On'];
    String splitted = "";
    if(created.split(" ").last.toLowerCase() == "pm"){
      splitted = '${int.parse(created.split(" ")[1].split(":").first)+12}';
    }else{
      splitted = created.split(" ")[1].split(":").first;
    }
    RegExp regexp = RegExp(r'^0+(?=.)');
    DateTime dateTimeNow = DateTime.now();
    DateTime createdTime = DateTime(
      int.parse(created.split(" ").first.split("-").last.replaceAll(regexp, "")),
      int.parse(created.split(" ").first.split("-")[1].replaceAll(regexp, "")),
      int.parse(created.split(" ").first.split("-").first.replaceAll(regexp, "")),
      int.parse(splitted.replaceAll(regexp, "")),
      int.parse(created.split(" ")[1].split(":").last),
    );

    Duration diff = dateTimeNow.difference(createdTime);

    print(created);
    print(createdTime);


    orderId = recentOrders[index]['Id'].toString();

    // if(recentOrders[index]['HampersName']!=null){
    //   address = recentOrders[index]['DeliveryAddress'].toString();
    //   cakeName = recentOrders[index]['HampersName'].toString();
    //   status = recentOrders[index]['Status'].toString();
    //   image = recentOrders[index]['HamperImage'].toString();
    //   productTotal = double.parse(recentOrders[index]['Price'].toString());
    //   deliveryCharge = double.parse(recentOrders[index]['DeliveryCharge'].toString());
    //   discounts = double.parse(recentOrders[index]['Discount'].toString());
    //   cgst = double.parse(recentOrders[index]['Gst'].toString());
    //   sgst = double.parse(recentOrders[index]['Sgst'].toString());
    //   billTot = double.parse(recentOrders[index]['Total'].toString());
    //   paidVia = recentOrders[index]['PaymentStatus'];
    //   typeOfCake = "Gift Hampers";
    //
    //   if(recentOrders[index]['VendorName']!=null || recentOrders[index]['VendorName']!=""){
    //     vendorName = recentOrders[index]['VendorName'].toString();
    //   }
    // }
    // else if(recentOrders[index]['ProductName']!=null){
    //
    //   if(recentOrders[index]['ProductMinWeightPerKg']!=null){
    //
    //     myMap = recentOrders[index]['ProductMinWeightPerKg'];
    //
    //     productTotal = (double.parse(myMap['PricePerKg'])*changeWeight(myMap['Weight']))*int.parse(recentOrders[index]['ItemCount'].toString());
    //
    //   }
    //   else if(recentOrders[index]['ProductMinWeightPerUnit']!=null){
    //     myMap = recentOrders[index]['ProductMinWeightPerUnit'];
    //
    //     productTotal = (double.parse(myMap['PricePerUnit'])*double.parse(myMap['ProductCount']));
    //
    //   }
    //   else {
    //     myMap = recentOrders[index]['ProductMinWeightPerBox'];
    //     productTotal = double.parse(myMap['PricePerBox'])*double.parse(myMap['ProductCount']);
    //   }
    //
    //   image = recentOrders[index]['Image'].toString();
    //   address = recentOrders[index]['DeliveryAddress'].toString();
    //   status = recentOrders[index]['Status'].toString();
    //   cakeName = recentOrders[index]['ProductName'].toString();
    //   deliveryCharge = double.parse(recentOrders[index]['DeliveryCharge'].toString());
    //   discounts = double.parse(recentOrders[index]['Discount'].toString());
    //   cgst = double.parse(recentOrders[index]['Gst'].toString());
    //   sgst = double.parse(recentOrders[index]['Sgst'].toString());
    //   billTot = double.parse(recentOrders[index]['Total'].toString());
    //   paidVia = recentOrders[index]['PaymentStatus'];
    //   typeOfCake = "Other Products";
    //   flavours = recentOrders[index]['Flavour'];
    //
    //   if(recentOrders[index]['VendorName']!=null || recentOrders[index]['VendorName']!=""){
    //     vendorName = recentOrders[index]['VendorName'].toString();
    //   }
    //
    // }else if(recentOrders[index]['CakeName']!=null && recentOrders[index]['Id'].toString().startsWith("CKYORD")){
    //
    //   address = recentOrders[index]['DeliveryAddress'].toString();
    //   cakeName = recentOrders[index]['CakeName'].toString();
    //   status = recentOrders[index]['Status'].toString();
    //   image = recentOrders[index]['Image'].toString();
    //   productTotal = ((double.parse(recentOrders[index]['Price'].toString())*
    //       changeWeight(recentOrders[index]['Weight'].toString()))+double.parse(recentOrders[index]['ExtraCharges'].toString()))*
    //       int.parse(recentOrders[index]['ItemCount'].toString());
    //   deliveryCharge = double.parse(recentOrders[index]['DeliveryCharge'].toString());
    //   discounts = double.parse(recentOrders[index]['Discount'].toString());
    //   cgst = double.parse(recentOrders[index]['Gst'].toString());
    //   sgst = double.parse(recentOrders[index]['Sgst'].toString());
    //   billTot = double.parse(recentOrders[index]['Total'].toString());
    //   paidVia = recentOrders[index]['PaymentStatus'];
    //   typeOfCake = "Cakes";
    //   shape = recentOrders[index]['Shape']['Name'];
    //
    //   List tempFlavours = recentOrders[index]['Flavour'];
    //   tempFlavours.forEach((e) {
    //     flavours.add(e['Name']);
    //   });
    //
    //   if(recentOrders[index]['VendorName']!=null || recentOrders[index]['VendorName']!=""){
    //     vendorName = recentOrders[index]['VendorName'].toString();
    //   }
    //
    // }else{
    //   cakeName = recentOrders[index]['CakeName'].toString();
    //   image = recentOrders[index]['Images'].isNotEmpty?recentOrders[index]['Images'][0]:"";
    //   status = recentOrders[index]['Status'].toString();
    //   address = recentOrders[index]['DeliveryAddress'].toString();
    //   paidVia = recentOrders[index]['PaymentStatus'];
    //   shape = recentOrders[index]['Shape'];
    //   typeOfCake = "Customised Cakes";
    //
    //   List tempFlavours = recentOrders[index]['Flavour'];
    //   tempFlavours.forEach((e) {
    //     flavours.add(e['Name']);
    //   });
    //
    //   if(recentOrders[index]['VendorName']!=null || recentOrders[index]['VendorName']!=""){
    //     vendorName = recentOrders[index]['VendorName'].toString();
    //   }
    // }

    if(recentOrders[index]['Flavour']!=null){
      List tempFlavours = recentOrders[index]['Flavour'];
      tempFlavours.forEach((e) {
        flavours.add(e['Name']);
      });
    }

    address = recentOrders[index]['DeliveryAddress'].toString();
    cakeName = recentOrders[index]['ProductName'];
    status = recentOrders[index]['Status'].toString();
    image = recentOrders[index]['Image'].toString();
    productTotal = double.parse(recentOrders[index]['Price'].toString(),(e)=>0.00);
    deliveryCharge = double.parse(recentOrders[index]['DeliveryCharge'].toString(),(e)=>0.00);
    discounts = double.parse(recentOrders[index]['Discount'].toString(),(e)=>0.00);
    cgst = double.parse(recentOrders[index]['Gst'].toString(),(e)=>0.00);
    sgst = double.parse(recentOrders[index]['Sgst'].toString(),(e)=>0.00);
    couponVal = double.parse(recentOrders[index]['CouponValue'].toString(),(e)=>0.00);
    billTot = double.parse(recentOrders[index]['Total'].toString(),(e)=>0.00);
    paidVia = recentOrders[index]['PaymentType'];
    typeOfCake = recentOrders[index]['CakeTypeForDisplay'];
    weight = changeWeight(recentOrders[index]['Weight']);
    if(recentOrders[index]['VendorName']==null || recentOrders[index]['VendorName'].toString()=="null"){
      vendorName = "Premium Vendor";
    }else{
      vendorName = recentOrders[index]['VendorName'].toString();
    }

    if(status.toLowerCase()=="rejected"){
      status = "Pending";
    }else if(status.toLowerCase()=="price approved"){
      status = "Sent";
    }


    print("Taped... ${diff.inMinutes} $index");

    return StatefulBuilder(
      builder:(context , setState){
        return Container(
          margin:EdgeInsets.symmetric(vertical:8),
          decoration:BoxDecoration(
            border:Border.all(
              width:1,
              color:Colors.grey[400]!
            ),
            borderRadius:BorderRadius.circular(15)
          ),
          child: Column(
            children: [
              InkWell(
                splashColor:Colors.transparent,
                onTap:(){
                  setState(() {
                    showTile = !showTile;
                  });
                },
                child: Container(
                    margin: EdgeInsets.symmetric(
                        vertical:8,
                        horizontal:6
                    ),
                    child:Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        image==null||image.toString().isEmpty||
                            !image.toString().startsWith("http")?
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
                                  image: NetworkImage('$image'),
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
                                  Text('Order Id $orderId',style: const TextStyle(
                                      fontSize: 10,fontFamily: "Poppins",color: Colors.black
                                  ),):Text('cake id',style: const TextStyle(
                                      fontSize: 10,fontFamily: "Poppins",color: Colors.black
                                  ))
                              ),
                              SizedBox(height: 5,),
                              Container(
                                child: Text("$cakeName",style: const TextStyle(
                                    fontSize: 12.5,fontFamily: "Poppins",
                                    color: Colors.black,fontWeight: FontWeight.bold
                                ),overflow: TextOverflow.ellipsis,maxLines: 2,)
                              ),
                              Container(
                                child:Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Wrap(
                                      children: [
                                        Text('(Shape - $shape)',style: TextStyle(
                                            fontSize: 11,fontFamily: "Poppins",color: Colors.grey[500]
                                        ),overflow: TextOverflow.ellipsis,maxLines: 10),
                                        SizedBox(width:3,),
                                        Text("( Flavours : ",style: TextStyle(
                                            fontSize:10.5,fontFamily: "Poppins",
                                            color: Colors.grey[500]
                                        ),),
                                        for(var e in flavours)
                                          Text("$e , ",style: TextStyle(
                                              fontSize:10.5,fontFamily: "Poppins",
                                              color:  Colors.grey[500]
                                          ),),
                                        Text(" )",style: TextStyle(
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
                                      child: Text("₹ ${((productTotal*count)+extraCharge).toStringAsFixed(2)}",
                                        style: TextStyle(color: lightPink,
                                            fontWeight: FontWeight.bold,fontFamily: "Poppins"),maxLines: 2,),
                                    ),
                                    Container(
                                      child: Text("$status",style: TextStyle(
                                          color:
                                          status.toLowerCase()=="cancelled"?
                                          Colors.red:
                                          Colors.blueAccent,
                                          fontWeight: FontWeight.bold,fontFamily: "Poppins",fontSize: 11
                                      ),),
                                    ),
                                    SizedBox(width:10,)
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
                visible:showTile,
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

                      typeOfCake.toLowerCase()=="customized cake" && weight > 5.0?
                      Container():
                      Column(
                        children: [
                          ListTile(
                            title: const Text('Vendor',style: const TextStyle(
                                fontSize: 11,fontFamily: "Poppins"
                            ),),
                            subtitle:Text("$vendorName",style: TextStyle(
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
                                const Text('Cake Type',style: TextStyle(
                                    fontSize: 11,fontFamily: "Poppins"
                                ),),
                                Text('$typeOfCake',style: TextStyle(
                                    fontSize: 14,fontFamily: "Poppins",
                                    fontWeight: FontWeight.bold,color: Colors.black
                                ),),
                              ],
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 10,),

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
                              child:Text("$address",
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

                      typeOfCake.toLowerCase()=="customized cake" && status.toLowerCase()=="new"?
                      Container(
                        padding:EdgeInsets.all(12),
                        child:Text("We will send the price details as soon as possible.!",style:TextStyle(
                          fontFamily:"Poppins",
                          fontSize:13.5,
                          color:Colors.black
                        ),),
                      ):
                      typeOfCake.toLowerCase()=="customized cake" && status.toLowerCase()=="sent"?
                      Column(
                        children: [
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
                                Text("₹${((productTotal*count)+extraCharge).toStringAsFixed(2)}"
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
                                Text('₹${deliveryCharge.toStringAsFixed(2)}',style: const TextStyle(fontWeight: FontWeight.bold),),
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
                                Text('₹${discounts.toStringAsFixed(2)}',style: const TextStyle(fontWeight: FontWeight.bold),),
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
                                Text('₹${cgst.toStringAsFixed(2)}',style: const TextStyle(fontWeight: FontWeight.bold),),
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
                                Text('₹${sgst.toStringAsFixed(2)}',style: const TextStyle(fontWeight: FontWeight.bold),),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text('Coupon',style: const TextStyle(
                                  fontFamily: "Poppins",
                                  color: Colors.black54,
                                ),),
                                Text('₹${couponVal.toStringAsFixed(2)}',style: const TextStyle(fontWeight: FontWeight.bold),),
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
                                Text('₹${billTot.toStringAsFixed(2)}',
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
                          GestureDetector(
                            onTap:(){
                              Functions().showCustomisePriceAlertBox(
                                  context ,
                                  recentOrders[index]['_id'].toString(),
                                  ()=>{Navigator.pop(context)},
                                  ()=>{Navigator.pop(context)},
                              );
                              //showReasonDialog(typeOfCake , recentOrders[index]['_id']);
                            },
                            child: Container(
                              margin:EdgeInsets.symmetric(
                                  horizontal:50,
                                  vertical:10
                              ),
                              padding:EdgeInsets.symmetric(
                                  vertical:10
                              ),
                              decoration:BoxDecoration(
                                  color:Colors.pink,
                                  borderRadius:BorderRadius.circular(15)
                              ),
                              child:Center(
                                child:Text("ACTIONS",style:TextStyle(
                                    color:Colors.white,
                                    fontFamily:"Poppins"
                                ),),
                              ),
                            ),
                          )
                        ],
                      ):
                      Column(
                        children: [
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
                                Text("₹${((productTotal*count)+extraCharge).toStringAsFixed(2)}"
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
                                Text('₹${deliveryCharge.toStringAsFixed(2)}',style: const TextStyle(fontWeight: FontWeight.bold),),
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
                                Text('₹${discounts.toStringAsFixed(2)}',style: const TextStyle(fontWeight: FontWeight.bold),),
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
                                Text('₹${cgst.toStringAsFixed(2)}',style: const TextStyle(fontWeight: FontWeight.bold),),
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
                                Text('₹${sgst.toStringAsFixed(2)}',style: const TextStyle(fontWeight: FontWeight.bold),),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text('Coupon',style: const TextStyle(
                                  fontFamily: "Poppins",
                                  color: Colors.black54,
                                ),),
                                Text('₹${couponVal.toStringAsFixed(2)}',style: const TextStyle(fontWeight: FontWeight.bold),),
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
                                Text('₹${billTot.toStringAsFixed(2)}',
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
                        ],
                      ),

                      status.toLowerCase()=="new"&&diff.inMinutes<15?
                      GestureDetector(
                        onTap:(){
                          showReasonDialog(typeOfCake , recentOrders[index]['_id']);
                        },
                        child: Container(
                          margin:EdgeInsets.symmetric(
                            horizontal:50,
                            vertical:10
                          ),
                          padding:EdgeInsets.symmetric(
                            vertical:10
                          ),
                          decoration:BoxDecoration(
                            color:Colors.red,
                            borderRadius:BorderRadius.circular(15)
                          ),
                          child:Center(
                            child:Text("Cancel Order",style:TextStyle(
                              color:Colors.white,
                              fontFamily:"Poppins"
                            ),),
                          ),
                        ),
                      ) : Container(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }


  Widget OrdersView(){
    return Column(
      mainAxisSize: MainAxisSize.max,
      // mainAxisAlignment: MainAxisAlignment.center,
      children: [
        recentOrders.isNotEmpty?
        ListView.builder(
            itemCount: recentOrders.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index){
              return orderDetailsTile(index);
            }
        ):
        Center(
          child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment:CrossAxisAlignment.center,
              children: [
                SizedBox(height: 15,),
                Icon(Icons.shopping_bag_outlined , color: darkBlue,size: 50,),
                Text('No orders found!' , style: TextStyle(
                    color: lightPink , fontWeight: FontWeight.bold , fontSize: 20
                ),),
              ],
          ),
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
                    // IconButton(
                    //   onPressed: (){
                    //     setState(() {
                    //       profileDetailHandler();
                    //     });
                    //   },
                    //   icon: Icon(Icons.refresh),
                    //   color: darkBlue,
                    // ),
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
                    RefreshIndicator(
                      onRefresh: () async {
                        loadPrefs();
                        profileDetailHandler();
                      },
                      child: SingleChildScrollView(
                          child: ProfileView(),
                          physics:BouncingScrollPhysics(),
                      ),
                    ),
                    RefreshIndicator(
                      onRefresh: () async {
                        loadPrefs();
                        profileDetailHandler();
                      },
                      child: SingleChildScrollView(
                          child: OrdersView(),
                          physics:BouncingScrollPhysics(),
                      ),
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


