import 'dart:convert';
import 'dart:io';
import 'package:cakey/ContextData.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mime/mime.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as Path;
import 'package:http_parser/http_parser.dart';
import 'package:provider/provider.dart';

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
          print(await response.stream.bytesToString());
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
          print(response.reasonPhrase);
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(response.reasonPhrase.toString()),backgroundColor: lightPink,)
          );
        }
      }
      else{
        //with profile image....
        print(Path.basename(file.path));

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
          print(await response.stream.bytesToString());
          setState(() {
            fetchProfileByPhn();
          });
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Profile updated!'),backgroundColor: Colors.green,)
          );
        }
        else {
          Navigator.pop(context);
          print(response.reasonPhrase);
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
          Uri.parse("https://cakey-database.vercel.app/api/order/listbyuserid/$userID")
      );
      if(response.statusCode==200){
        print(jsonDecode(response.body));
        setState(() {
          recentOrders = jsonDecode(response.body);
          recentOrders = recentOrders.reversed.toList();
          isLoading = false;
        });
      }
      else{
        print(response.statusCode);
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
          "${int.parse(phoneNumber)}"));
      if(response.statusCode==200){
        // print(jsonDecode(response.body));
        setState(() {
          List body = jsonDecode(response.body);
          print("body $body");
          userID = body[0]['_id'].toString();
          userAddress = body[0]['Address'].toString();
          userProfileUrl = body[0]['ProfileImage'].toString();
          context.read<ContextData>().setProfileUrl(userProfileUrl);
          userName = body[0]['UserName'].toString();
          prefs.setString('userID', userID);
          prefs.setString('userAddress', userAddress);
          prefs.setString('userName', userName);
          context.read<ContextData>().setUserName(userName);
          print(userID + userAddress + userProfileUrl);
          getOrderList();
          Navigator.pop(context);
        });
      }else{
        print("Status code : ${response.statusCode}");
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
        print("file $file");
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
        print('connected');
      }
    } on SocketException catch (_) {
      print('not connected');
    }
  }

  //endregion

  //region Widgets.....
  Widget ProfileView(){
    userProfileUrl = context.watch<ContextData>().getProfileUrl();
    setState(() {
      userNameCtrl = TextEditingController(text: userName=="null"?"No name":userName);
      userAddrCtrl = TextEditingController(text: userAddress=="null"?"No address":userAddress);
    });
    return Column(
      children: [
        const SizedBox(height: 10,),
        Container(
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
                      print('hii');
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
              onPressed: (){},
              child: Text('add new address',style: TextStyle(
                color:Colors.orange,fontFamily: "Poppins",decoration: TextDecoration.underline
              ),)
          ),
        ),
        Container(
          alignment: Alignment.centerLeft,
          child: RaisedButton(
              onPressed: (){
                FocusScope.of(context).unfocus();
                updateProfile();
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
                onChanged: (bool val){
                  setState(() {
                    notifiOnOrOf = val;
                  });
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
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        isLoading?
        Center(child: CircularProgressIndicator(),):
        recentOrders.length>0?ListView.builder(
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
                                  Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        image: DecorationImage(
                                          image: NetworkImage('${recentOrders[index]['Images']}'),
                                          fit: BoxFit.cover
                                        )
                                    ),
                                  ),
                                  const SizedBox(width: 10,),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(3),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(20),
                                          color: Colors.black26
                                        ),
                                        child:Text('ID ${recentOrders[index]['_id']}',style: const TextStyle(
                                            fontSize: 10,fontFamily: "Poppins",color: Colors.black
                                        ),),
                                      ),
                                      Container(
                                        width: 200,
                                        child:Text("${recentOrders[index]['Title']}",style: const TextStyle(
                                            fontSize: 13,fontFamily: "Poppins",
                                            color: Colors.black,fontWeight: FontWeight.bold
                                        ),overflow: TextOverflow.ellipsis,),
                                      ),
                                      Container(
                                        width:200,
                                        child:Text("${recentOrders[index]['Description']}"
                                          ,style: const TextStyle(
                                            fontSize: 12,fontFamily: "Poppins",
                                            color: Colors.black26
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(height: 3,),
                                      Container(
                                        width: MediaQuery.of(context).size.width*0.58,
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text("₹ ${recentOrders[index]['Price']}",style: TextStyle(color: lightPink,
                                                fontWeight: FontWeight.bold,fontFamily: "Poppins"),maxLines: 1,),
                                            recentOrders[index]['Status'].toString().toLowerCase()=='delivered'?
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text("${recentOrders[index]['Status']} ",style: TextStyle(color: Colors.green,
                                                        fontWeight: FontWeight.bold,fontFamily: "Poppins",fontSize: 11),),
                                                    const Icon(Icons.verified_rounded,color: Colors.green,size: 12,)
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
                                             fontWeight: FontWeight.bold,fontFamily: "Poppins",fontSize: 11),),
                                          ],
                                        ),
                                      )
                                    ],
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
                                          onTap: (){
                                            print('phone..');
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
                                          onTap: (){
                                            print('whatsapp');
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
                                     Text('₹${recentOrders[index]['Total']}',style: const TextStyle(fontWeight: FontWeight.bold),),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      const Text('Delivery charge',style: const TextStyle(
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
                                      const Text('Discounts',style: const TextStyle(
                                        fontFamily: "Poppins",
                                        color: Colors.black54,
                                      ),),
                                      Text('${recentOrders[index]['Discount']} %',style: const TextStyle(fontWeight: FontWeight.bold),),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      const Text('Taxes',style: const TextStyle(
                                        fontFamily: "Poppins",
                                        color: Colors.black54,
                                      ),),
                                      Text('0 %',style: const TextStyle(fontWeight: FontWeight.bold),),
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
                                      Text('₹${recentOrders[index]['Total']}',style: TextStyle(fontWeight: FontWeight.bold),),
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
                          ),
                        )
                      ],
                    ),
                  );
              }
          )
        :Center(
          child: Column(
            children: [
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
    print(context.watch<ContextData>().getProfileUrl());
    print(MediaQuery.of(context).size.width*0.58);
    checkInternet();
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        elevation: 0,
        leading:Container(
          margin: const EdgeInsets.all(10),
          child: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10)),
                alignment: Alignment.center,
                height: 20,
                width: 20,
                child: Icon(
                  Icons.chevron_left,
                  color: lightPink,
                  size: 35,
                )),
          ),
        ),
        backgroundColor: lightGrey,
        title: Text(
          'PROFILE',
          style: TextStyle(
            color: darkBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
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
              InkWell(
                onTap: () {
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
                  alignment: Alignment.center,
                  height: 35,
                  width: 35,
                  decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8)),
                  child: Icon(
                    Icons.notifications_none,
                    color: darkBlue,
                    size: 30,
                  ),
                ),
              ),
              const Positioned(
                left: 20,
                top: 18,
                child: const CircleAvatar(
                  radius: 4.5,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: 3.5,
                    backgroundColor: Colors.red,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            width: 10,
          )
        ],
      ),
      body: Container(
        margin: const EdgeInsets.all(10),
        child: Column(
          children: [
            Container(
              height: 50,
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
                      Center(
                        child: SingleChildScrollView(
                            child: OrdersView()
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
}
