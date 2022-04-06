import 'dart:convert';
import 'dart:io';
import 'package:cakey/ContextData.dart';
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
  Color lightGrey = const Color(0xffF5F5F5);
  Color darkBlue = const Color(0xffF213959);
  Color lightPink = const Color(0xffFE8416D);

   //for tabs...
   late TabController tabControl ;
   //for expand the tiles..
   List<bool> isExpands = [];

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

  //Fetching user details from API....
  Future<void> fetchProfileByPhn() async{
    showAlertDialog();
    //needs to imple..
    http.Response response = await http.get(Uri.parse("https://cakey-database.vercel.app/api/users/list/"
        "${int.parse(phoneNumber)}"));
    if(response.statusCode==200){
      // print(jsonDecode(response.body));
      Navigator.pop(context);
      setState(() {
        List body = jsonDecode(response.body);
        print("body $body");
        userID = body[0]['_id'].toString();
        userAddress = body[0]['Address'].toString();
        userProfileUrl = body[0]['ProfileImage'].toString();
        context.read<ContextData>().setProfileUrl(userProfileUrl);
        userName = body[0]['UserName'].toString();
        context.read<ContextData>().setUserName(userName);
        print(userID + userAddress + userProfileUrl);
      });
    }else{
      Navigator.pop(context);
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
                        backgroundColor: Colors.white10,
                        child: Icon(Icons.camera_alt,color: lightPink,),
                      ),
                    ),
                  )
              ),
            ],
          ),
        ),
        TextField(
          controller: userNameCtrl,
          maxLines: 1,
          keyboardType: TextInputType.text,
          decoration: const InputDecoration(
            hintText: "Type Name",
            border: const OutlineInputBorder(),
            label: Text('Name')
          ),
        ),
        const SizedBox(height: 15,),
        TextField(
          enabled: false,
          controller: TextEditingController(text: phoneNumber),
          maxLines: 1,
          maxLengthEnforced: true,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
              hintText: "Type Phone Number",
              border: const OutlineInputBorder(),
              label: const Text('Phone')
          ),
        ),
        const SizedBox(height: 15,),
        TextField(
          controller: userAddrCtrl,
          maxLines: 4,
          keyboardType: TextInputType.multiline,
          decoration: InputDecoration(
              hintText: "Type Address",
              border: OutlineInputBorder(),
              label: Text('Address')
          ),
        ),
        Container(
          alignment: Alignment.centerLeft,
          child: TextButton(
              onPressed: (){},
              child: const Text('add new address',style: const TextStyle(
                color: Colors.orange,fontFamily: "Poppins",decoration: TextDecoration.underline
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
                color: Colors.black26,
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
                value: true,
                onChanged: (bool? val){

                },
                activeColor: Colors.green,
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
            leading: Container(
              alignment: Alignment.center,
              height: 45,
              width: 45,
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(5)
              ),
              child: Icon(
                Icons.logout_outlined,color: lightPink,
              ),
            ),
            title: const Text('Logout',style: TextStyle(fontFamily: "Poppins")),
          ),
        ),
      ],
    );
  }

  Widget OrdersView(){
    return Column(
      children: [
        ListView.builder(
              itemCount: 4,
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
                                        image: const DecorationImage(
                                          image: const NetworkImage('https://www.cakengifts.in/blog/wp-content/uploads/2018/09/happy-birthday-cake-hd-pic.jpg'),
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
                                        child:const Text('Order ID #0000',style: const TextStyle(
                                            fontSize: 10,fontFamily: "Poppins",color: Colors.black
                                        ),),
                                      ),
                                      Container(
                                        width: 200,
                                        child: const Text("Cake name goes here",style: const TextStyle(
                                            fontSize: 13,fontFamily: "Poppins",
                                            color: Colors.black,fontWeight: FontWeight.bold
                                        ),overflow: TextOverflow.ellipsis,),
                                      ),
                                      Container(
                                        width:200,
                                        child: const Text("Cake description goes here it should be long maximum height is 2"
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
                                        width: 200,
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text("₹ 450",style: TextStyle(color: lightPink,
                                                fontWeight: FontWeight.bold,fontFamily: "Poppins"),maxLines: 1,),
                                            index/1==1?Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    const Text("Delivered ",style: TextStyle(color: Colors.green,
                                                        fontWeight: FontWeight.bold,fontFamily: "Poppins",fontSize: 11),),
                                                    const Icon(Icons.verified_rounded,color: Colors.green,size: 12,)
                                                  ],
                                                ),
                                                const Text("28-03-2022",style: TextStyle(color: Colors.black26,
                                                    fontFamily: "Poppins",fontSize: 10,fontWeight: FontWeight.bold),),
                                              ],
                                            ):
                                            const Text("Pending",style: TextStyle(color: Colors.blueAccent,
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
                        Visibility(
                          visible:isExpands[index],
                          child: AnimatedContainer(
                            duration: const Duration(seconds: 3),
                            curve: Curves.elasticInOut,
                            color: Colors.black12,
                            child: Column(
                              children: [
                                ListTile(
                                  title: const Text('Vendor',style: const TextStyle(
                                    fontSize: 11,fontFamily: "Poppins"
                                  ),),
                                  subtitle: const Text('Naveen',style: TextStyle(
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
                                      const Text('Birthday',style: TextStyle(
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
                                          child: const Text(
                                              "1/4 Vellandipalayam thekkalur 641654",
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
                                      const Text('₹500',style: const TextStyle(fontWeight: FontWeight.bold),),
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
                                      const Text('₹10',style: const TextStyle(fontWeight: FontWeight.bold),),
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
                                      const Text('₹500',style: const TextStyle(fontWeight: FontWeight.bold),),
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
                                      const Text('₹500',style: const TextStyle(fontWeight: FontWeight.bold),),
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
                                      const Text('₹500',style: TextStyle(fontWeight: FontWeight.bold),),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      const Text('Paid via : Google pay',style: TextStyle(
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
          ),
      ],
    );
  }
  //endregion

  @override
  Widget build(BuildContext context) {
    print(context.watch<ContextData>().getProfileUrl());
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
                    color: Colors.black26,
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
          Stack(
            alignment: Alignment.center,
            children: [
              InkWell(
                onTap: () => print("hii"),
                child: Container(
                  alignment: Alignment.center,
                  height: 35,
                  width: 35,
                  decoration: BoxDecoration(
                      color: Colors.black26,
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
        margin: const EdgeInsets.all(15),
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
}
