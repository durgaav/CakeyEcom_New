import 'dart:convert';
import 'dart:io';
import 'package:cakey/ContextData.dart';
import 'package:cakey/Notification/Notification.dart';
import 'package:cakey/screens/AddressScreen.dart';
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
import '../DrawerScreens/Notifications.dart';
import 'WelcomeScreen.dart';

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

  //Edit text Controllers...
  var userNameCtrl = new TextEditingController();
  var userAddrCtrl = new TextEditingController();

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();

  //On start activity..
  @override
  void initState() {
    // TODO: implement initState
    tabControl = new TabController(length: 2,vsync: this,initialIndex: defindex);
    Future.delayed(Duration.zero, () async{
      var pref = await SharedPreferences.getInstance();
      setState(() {
        phoneNumber = pref.get("phoneNumber").toString();
      });
      loadPrefs();
      fetchProfileByPhn();
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


  //loadPrefs
  Future<void> loadPrefs() async {
    var prefs = await SharedPreferences.getInstance();
    setState(() {
      phoneNumber = prefs.getString("phoneNumber") ?? "";
      authToken = prefs.getString("authToken") ?? 'no auth';
    });
  }

  //region Alerts....

  //Logout dialog

  void showlogoutDialog() {
    showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            title: Text('Cakey'
              ,style: TextStyle(color: lightPink,fontWeight: FontWeight.bold,fontFamily: "Poppins"),
            ),
            content: Text('Are you sure? you will be logged out!',
              style: TextStyle(color: darkBlue,fontWeight: FontWeight.bold,fontFamily: "Poppins"),
            ),
            actions: [
              FlatButton(
                onPressed: (){
                  Navigator.pop(context);
                },
                child: Text('Cancel',
                  style: TextStyle(color: Colors.green,fontWeight: FontWeight.bold,fontFamily: "Poppins"),
                ),
              ),
              FlatButton(
                onPressed: (){
                  Navigator.pop(context);
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
                  style: TextStyle(color: Colors.deepPurple,fontWeight: FontWeight.bold,fontFamily: "Poppins"),
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
  Future<void> updateProfile() async {
    var prefs = await SharedPreferences.getInstance();
    showAlertDialog();
    try{
      //without profile img....
      if(file.path.isEmpty){
        var request = http.MultipartRequest('PUT',
            Uri.parse(
                'https://cakey-database.vercel.app/api/users/update/$userID'));
        request.headers['Content-Type'] = 'multipart/form-data';
        request.fields.addAll({
          'UserName': userNameCtrl.text.toString(),
          'Address': userAddrCtrl.text.toString()
        });
        http.StreamedResponse response = await request.send();

        if (response.statusCode == 200) {
          prefs.setBool("newRegUser", false);
          prefs.setString("userName", userName);
          Navigator.pop(context);

          setState(() {
            file = new File('');
            fetchProfileByPhn();
          });
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Profile updated!'),backgroundColor: Colors.green,)
          );
        }
        else {
          Navigator.pop(context);

          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(response.reasonPhrase.toString()),backgroundColor: lightPink,)
          );
        }
      }
      else{
        //with profile image....


        var request = http.MultipartRequest('PUT',
            Uri.parse(
                'https://cakey-database.vercel.app/api/users/update/$userID'));
        request.headers['Content-Type'] = 'multipart/form-data';
        request.files.add(await http.MultipartFile.fromPath(
            'file', file.path.toString(),
            filename: Path.basename(file.path),
            contentType: MediaType.parse(lookupMimeType(file.path.toString()).toString())
        ));
        request.fields.addAll({
          'UserName': userNameCtrl.text.toString(),
          'Address': userAddrCtrl.text.toString()
        });

        http.StreamedResponse response = await request.send();

        if (response.statusCode == 200) {
          prefs.setBool("newRegUser", false);
          prefs.setString("userName", userName);
          Navigator.pop(context);

          setState(() {
            fetchProfileByPhn();
          });
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Profile updated!'),backgroundColor: Colors.green,)
          );
        }
        else {
          Navigator.pop(context);

          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(response.reasonPhrase.toString()),backgroundColor:lightPink,)
          );
        }
      }
    }catch(error){
      Navigator.pop(context);
      print(error);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please Check Your Connection!"),backgroundColor:lightPink,)
      );
    }
  }

  //getting order list...
  Future<void> getOrderList() async{

    setState(() {
      isLoading = true;
    });

    try{
      http.Response response = await http.get(
          Uri.parse("https://cakey-database.vercel.app/api/order/listbyuserid/$userID"),
          headers: {"Authorization":"$authToken"}
      );
      if(response.statusCode==200){
        setState(() {
          recentOrders = jsonDecode(response.body);
          recentOrders = recentOrders.reversed.toList();
          isLoading = false;
        });
      }
      else{
        setState(() {
          isLoading = false;
        });
      }
    }catch(error){
      setState(() {
        isLoading = false;
      });
    }
  }


  //Fetching user details from API....
  Future<void> fetchProfileByPhn() async{
    var prefs = await SharedPreferences.getInstance();
    showAlertDialog();

    try{
      http.Response response = await http.get(Uri.parse("https://cakey-database.vercel.app/api/users/list/"
          "${int.parse(phoneNumber)}"),
          headers: {"Authorization":"$authToken"}
      );
      if(response.statusCode==200){
        // print(jsonDecode(response.body));
        setState(() {
          List body = jsonDecode(response.body);

          userID = body[0]['_id'].toString();
          userAddress = body[0]['Address'].toString();
          userProfileUrl = body[0]['ProfileImage'].toString();
          context.read<ContextData>().setProfileUrl(userProfileUrl);
          userName = body[0]['UserName'].toString();
          prefs.setString('userID', userID);
          prefs.setString('userAddress', userAddress);
          prefs.setString('userName', userName);
          context.read<ContextData>().setUserName(userName);

          getOrderList();
          Navigator.pop(context);
        });
      }else{
        Navigator.pop(context);
      }
    }catch(e){
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Check Your Connection! try again'),
            backgroundColor: Colors.amber,
            action: SnackBarAction(
              label: "Retry",
              onPressed:()=>setState(() {
                fetchProfileByPhn();
              }),
            ),
          )
      );
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

  //check the internet con...
  Future<void> checkInternet() async {
    try {
      final result = await InternetAddress.lookup('www.google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {

      }
    } on SocketException catch (_) {

    }
  }

  //Rate the cake & Vendor
  Future<void> rateCake(double rate,String cakeId,int index) async{
    print(rate);
    print(cakeId);
    print(index);
    var headers = {
      'Content-Type': 'application/json'
    };
    var request = http.Request('PUT',
        Uri.parse('https://cakey-database.vercel.app/api/cake/ratings/$cakeId'));
    request.body = json.encode({
      "Ratings": rate
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Rating Updated To Cake'))
      );

      rateVendor(rate,
          recentOrders[index]['VendorID'].toString());
    }
    else {
      print(response.reasonPhrase);
      rateVendor(rate,
          recentOrders[index]['VendorID'].toString());
      
    }

  }

  //Rate the cake & Vendor
  Future<void> rateVendor(double rate,String vendId) async{
    print(rate);

    var headers = {
      'Content-Type': 'application/json'
    };
    var request = http.Request('PUT',
        Uri.parse('https://cakey-database.vercel.app/api/vendor/ratings/$vendId'));
    request.body = json.encode({
      "Ratings": double.parse(rate.toString())
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Rating Updated To Vendor'))
      );
    }
    else {
      print(response.reasonPhrase);
    }

  }


  //Notifications....



  //endregion

  //region Widgets.....
  Widget ProfileView(){
    userProfileUrl = context.watch<ContextData>().getProfileUrl();
    setState(() {
      userNameCtrl = TextEditingController(text: userName=="null"?"No name":userName);
      userAddrCtrl = TextEditingController(text: userAddress=="null"?"No address":userAddress);
    });
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
                      child: userProfileUrl!="null"?CircleAvatar(
                        radius: 45,
                        backgroundImage: NetworkImage("$userProfileUrl"),
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
                          backgroundColor:Color(0xff03c04a),
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
              maxLines: 1,
              keyboardType: TextInputType.text,
              style: TextStyle(
                fontFamily: "Poppins" ,
              ),
              decoration: const InputDecoration(
                hintText: "Type Name",
                border: const OutlineInputBorder(),
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
              'Address',
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
              maxLines: 4,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                hintText: "Type Address",
                border: OutlineInputBorder(),

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

        Container(
          padding:EdgeInsets.only(left:10,top:3,bottom: 3),
          child:Row(
              crossAxisAlignment:CrossAxisAlignment.center,
              children:[
                Expanded(
                  child:Text('$selectedAdres',
                    style: TextStyle(fontFamily: "Poppins",color: Colors.grey,fontSize: 13),
                  ),
                ),
                Icon(Icons.check_circle,color: Colors.green,size: 25,),
              ]
          ),
        ),

        Container(
          alignment: Alignment.centerLeft,
          child: RaisedButton(
            onPressed: (){
              FocusScope.of(context).unfocus();

              if(userNameCtrl.text.toLowerCase()=="no name"||
                  userAddrCtrl.text.toLowerCase()=="no address"||
                  userNameCtrl.text.isEmpty||
                  userAddrCtrl.text.isEmpty){
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Unable To Update'))
                );
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
                    then((value) => SendMessage(value));
                  }else{

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
    return Column(
      // mainAxisSize: MainAxisSize.max,
      // mainAxisAlignment: MainAxisAlignment.center,
      children: [
        isLoading==true?
        Center(
          child: Column(
          children: [
            SizedBox(height: 15,),
            Text('Loading Please Wait...',style: TextStyle(
                color: Colors.purple , fontFamily: "Poppins",
                fontSize: 15
            ),),
          ],
        )):
        recentOrders.length>0?
        ListView.builder(
            itemCount: recentOrders.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index){
              isExpands.add(false);
              return Container(
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
                          }else{
                            isExpands[index]=false;
                          }
                        });
                      },
                      child: Container(
                          child:Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              recentOrders[index]["Images"]==null||recentOrders[index]["Images"].toString().isEmpty||
                                  !recentOrders[index]["Images"].toString().startsWith("http")?
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
                                        image: NetworkImage('${recentOrders[index]['Images']}'),
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
                                      child:(recentOrders[index]['Title'] != null)
                                          ?Text("${recentOrders[index]['Title']} "
                                          "(Rs.${recentOrders[index]['Price']}) × ${recentOrders[index]['ItemCount']}",style: const TextStyle(
                                          fontSize: 12.5,fontFamily: "Poppins",
                                          color: Colors.black,fontWeight: FontWeight.bold
                                      ),overflow: TextOverflow.ellipsis,maxLines: 4,):
                                      Text("My Customized Cake",style: const TextStyle(
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
                                              Text("(Shapes - ${recentOrders[index]['Shape']}), ",style: const TextStyle(
                                                    fontSize:10.5,fontFamily: "Poppins",
                                                    color: Colors.black26
                                                ),
                                                maxLines: 5,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Text("(Article - ${recentOrders[index]['Article']['Name']} Rs.${recentOrders[index]['Article']['Price']}), "
                                                ,style: const TextStyle(
                                                    fontSize:10.5,fontFamily: "Poppins",
                                                    color: Colors.black26
                                                ),
                                                maxLines: 5,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Text("(Flavours : ",style: TextStyle(
                                                  fontSize:10.5,fontFamily: "Poppins",
                                                  color: Colors.black26
                                              ),),
                                              for(var i in recentOrders[index]['Flavour'])
                                                Text("${i['Name']} Price - Rs.${i['Price']} x ${recentOrders[index]['Weight']}, ",style: TextStyle(
                                                    fontSize:10.5,fontFamily: "Poppins",
                                                    color: Colors.black26
                                                ),),

                                              Text(" = Rs.${recentOrders[index]['ExtraCharges']})",style: TextStyle(
                                                  fontSize:10.5,fontFamily: "Poppins",
                                                  color: Colors.black26
                                              ),)

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
                                          ( recentOrders[index]['Price']!= null)?
                                          Text("₹ ${(int.parse(recentOrders[index]['Price'].toString()) *
                                              int.parse(recentOrders[index]['ItemCount'].toString()))+
                                              double.parse(recentOrders[index]['ExtraCharges'].toString())}",
                                              style: TextStyle(color: lightPink,
                                              fontWeight: FontWeight.bold,fontFamily: "Poppins"),maxLines: 1,)
                                              :Text('₹ 0',style: TextStyle(color: lightPink,
                                              fontWeight: FontWeight.bold,fontFamily: "Poppins"),maxLines: 1,),

                                          Container(
                                            child:recentOrders[index]['Status'].toString().toLowerCase()=='delivered'?
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text("${recentOrders[index]['Status']} ",style: TextStyle(color: Colors.green,
                                                        fontWeight: FontWeight.bold,fontFamily: "Poppins",fontSize: 11),),
                                                    const Icon(Icons.check_circle,color: Colors.green,size: 12,)
                                                  ],
                                                ),
                                                Text("${recentOrders[index]['Status_Updated_On']
                                                    .toString().split(" ").first}",style: TextStyle(color: Colors.black26,
                                                    fontFamily: "Poppins",fontSize: 10,fontWeight: FontWeight.bold),),
                                              ],
                                            ):
                                            Text("${recentOrders[index]['Status']}",style: TextStyle(
                                                color:recentOrders[index]['Status'].toString().toLowerCase()
                                                    =='cancelled'?Colors.red:Colors.blueAccent,
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
                            color: Colors.black12,
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
                                        try{
                                          await launchUrl(Uri.parse("tel://${recentOrders[index]['VendorPhoneNumber']}"));
                                        }catch(e){
                                          print('uri er : $e');
                                        }
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
                                        print('whatsapp');
                                        String whatsapp = recentOrders[index]['VendorPhoneNumber'];
                                        var whatsappURl_android = "whatsapp://send?phone="+whatsapp+"&text=hello";
                                        var whatappURL_ios ="https://wa.me/$whatsapp?text=${Uri.parse("hello")}";
                                        if(Platform.isIOS){
                                          // for iOS phone only
                                          if( await canLaunch(whatappURL_ios)){
                                            await launch(whatappURL_ios, forceSafariVC: false);
                                          }else{
                                            ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: new Text("whatsapp no installed")));
                                          }
                                        }else{
                                          // android , web
                                          if( await canLaunch(whatsappURl_android)){
                                            await launch(whatsappURl_android);
                                          }else{
                                            ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: new Text("whatsapp no installed")));
                                          }
                                        }
                                      },
                                      child: Container(
                                        alignment: Alignment.center,
                                        height: 35,
                                        width: 35,
                                        decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.white
                                        ),
                                        child:const Icon(Icons.whatsapp_rounded,color: Colors.green,),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.only(left: 15,bottom: 10),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Cake Type',style: TextStyle(
                                      fontSize: 11,fontFamily: "Poppins"
                                  ),),
                                  Text('${recentOrders[index]['TypeOfCake']}',style: TextStyle(
                                      fontSize: 14,fontFamily: "Poppins",
                                      fontWeight: FontWeight.bold,color: Colors.black
                                  ),),
                                ],
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(left: 10,right: 10),
                              color: Colors.black26,
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
                                      "${recentOrders[index]['DeliveryAddress']}",
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
                              color: Colors.black26,
                              height: 1,
                            ),

                            Container(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text('Item Total',style: TextStyle(
                                    fontFamily: "Poppins",
                                    color: Colors.black54,
                                  ),),
                                  recentOrders[index]['ExtraCharges']!=null?
                                  Text("₹${(int.parse(recentOrders[index]['Price'].toString()) *
                                      int.parse(recentOrders[index]['ItemCount'].toString()))+
                                      double.parse(recentOrders[index]['ExtraCharges'].toString())}"
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
                                  Text('₹${recentOrders[index]['DeliveryCharge']}',style: const TextStyle(fontWeight: FontWeight.bold),),
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
                                  Text('₹${recentOrders[index]['Discount']}',style: const TextStyle(fontWeight: FontWeight.bold),),
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
                                  Text('₹${double.parse(recentOrders[index]['Gst'])}',style: const TextStyle(fontWeight: FontWeight.bold),),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text('Sgst',style: const TextStyle(
                                    fontFamily: "Poppins",
                                    color: Colors.black54,
                                  ),),
                                  Text('₹${double.parse(recentOrders[index]['Sgst'])}',style: const TextStyle(fontWeight: FontWeight.bold),),
                                ],
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(left: 10,right: 10),
                              color: Colors.black26,
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
                                  Text('₹${((int.parse(recentOrders[index]['Price'].toString())*
                                      int.parse(recentOrders[index]['ItemCount'].toString()))
                                      +double.parse(recentOrders[index]['ExtraCharges'].toString())
                                     +double.parse(recentOrders[index]['Gst'].toString())+
                                      double.parse(recentOrders[index]['Sgst'].toString())+
                                      double.parse(recentOrders[index]['DeliveryCharge'].toString()))-
                                      double.parse(recentOrders[index]['Discount'].toString())}',
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
                                              child: Text('Rete Vendor & Cake',style: TextStyle(
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
                                              FlatButton(
                                                  onPressed: (){
                                                    Navigator.pop(context);
                                                  },
                                                  child:  Text('Cancel',style: TextStyle(
                                                      fontFamily: "Poppins",
                                                      fontSize: 13.5,
                                                      color:Colors.pinkAccent
                                                  ),)
                                              ),
                                              FlatButton(
                                                  onPressed: (){
                                                    Navigator.pop(context);
                                                    rateCake(double.parse(rate),
                                                        recentOrders[index]['CakeID'].toString(), index);
                                                  },
                                                  child:  Text('Rate',style: TextStyle(
                                                      fontFamily: "Poppins",
                                                      fontSize: 13.5,
                                                      color:Colors.green
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
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
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
                            fontWeight: FontWeight.bold,fontSize: 17
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
                        const Positioned(
                          left: 17,
                          top: 17,
                          child: const CircleAvatar(
                            radius: 3.5,
                            backgroundColor: Colors.white,
                            child: CircleAvatar(
                              radius: 2.7,
                              backgroundColor: Colors.red,
                            ),
                          ),
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
      'Authorization': 'Bearer AAAAX-GpPCg:APA91bGRWwG0OMA3p8cZTw3401DXf5I91TzGMObQR_6RbrlxlmI9f-_k8tcIer8yp8G7cqInR3z6zIyiJH8WJEkfx4KYT7JVU4ZSf6cEFiS23BwO_zWuJOeEx9tZmBQs1wph9wbsNqlJ',
      'Content-Type': 'application/json'
    };
    var request = http.Request('POST', Uri.parse('https://fcm.googleapis.com/fcm/send'));
    request.body = json.encode({
      "registration_ids": [
           "$value",
       "c-H4wpgTQLC-qUTgx5gM2m:APA91bGSHe6VDjHbzr-f62FRtupeHX5HfBGta_K1ghVZQmWjwswqrM63-xZpCfMQ_0KipE7jOJyJdWwnPVgKt4nNj_hQWDj0EwLc_K2q_pHCgOwOv4NiznZDY6inbnGzSsbcb5T8c3WL"
      ],
      "notification": {
        "title": "FCM",
        "body": "messaging tutorial"
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

