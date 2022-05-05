import 'dart:convert';
import 'dart:io';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:http/http.dart' as http ;
import 'package:cakey/DrawerScreens/VendorsList.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dotted_border/dotted_border.dart';
import '../ContextData.dart';
import '../screens/Profile.dart';
import 'Notifications.dart';

class CustomiseCake extends StatefulWidget {
  const CustomiseCake({Key? key}) : super(key: key);

  @override
  State<CustomiseCake> createState() => _CustomiseCakeState();
}

class _CustomiseCakeState extends State<CustomiseCake> {

  //region Variables
  //Colors code
  Color lightGrey = Color(0xffF5F5F5);
  Color darkBlue = Color(0xffF213959);
  Color lightPink = Color(0xffFE8416D);

  //shapes
  var shapesList = ["Default","Round","Square" , "Heart","Rectangle"];
  var shapeGrpValue = 0;

  //flavour
  var flavourList = ["Default","Strawberry","Blueberry","Chacolate"];
  var flavGrpValue = 0;

  //cake articles
  var cakeArticles = ["Default" , 'Cake Article','Cake Article','Cake Art'];
  var artGrpValue = 0;
  String fixedCakeArticle = 'Default';

  //Articles
  var articals = ["Happy Birth Day" , "Butterflies" , "Hello World"];
  var articalsPrice = ['Rs.100' , 'Rs.125','Rs.50'];
  int articGroupVal = 0;

  int selVendorIndex = 0;

  //String family
  String poppins = "Poppins";
  String userMainLocation ="";
  String profileUrl = '';
  String btnMsg = 'ORDER NOW';


  //Fixed Strings and Lists
  String fixedCategory = '';
  String fixedShape = 'Default';
  String fixedFlavour = 'Default';
  String fixedExtraArticle = '';
  String fixedCakeTower = '';
  String fixedWeight = '';
  String fixedDate = '00-00-0000';
  String fixedSession = 'Morning';
  String deliverAddress = 'Washington , Vellaimaligai , USA ,007 ';

  //cake text ctrls
  var msgCtrl = new TextEditingController();
  var specialReqCtrl = new TextEditingController();
  String cakeMessage = '';
  String cakeRequest = "";

  //main variables
  bool egglesSwitch = true;
  String userCurLocation = 'Searching...';

  var weight = [
    1.5,2,2.5,3,4,5,6,7,8
  ];

  var cakeTowers = ["2","3","5","8"];
  int currentIndex = 0;

  List<bool> selwIndex = [];
  List<bool> selCakeTower = [];

  //For category selecions
  List<Widget> cateWidget = [];
  List<bool> selCategory = [];
  List categories = ["Birthday" , "Wedding" , "Others" , "Anniversary" , "Farewell"];

  List nearestVendors = [];
  List mySelectdVendors = [];

  var selFromVenList = false;

  //my venor details
  String myVendorName = '';
  String myVendorId = '';
  String myVendorProfile ='';
  String myVendorDelCharge = '';
  String myVendorPhone = '';
  String myVendorDesc = '';
  bool iamYourVendor = false;

  //file
  File file = new File('');

  //endregion

  //region Dialogs

  //Default loader dialog
  void showAlertDialog(){
    showDialog(
        context: context,
        barrierDismissible: false,
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

  //Add new Address Alert...
  void showAddAddressAlert(){

    //region private variables

    //Controls
    var streetNameCtrl = new TextEditingController();
    var cityNameCtrl = new TextEditingController();
    var districtNameCtrl = new TextEditingController();
    var pinCodeCtrl = new TextEditingController();

    //Validation (bool)
    bool streetVal = false;
    bool cityVal = false;
    bool districtVal = false;
    bool pincodeVal = false;

    bool loading = false;

    //endregion

    showDialog(
        context: context,
        builder: (context){
          return StatefulBuilder(
              builder:(BuildContext context , void Function(void Function()) setState){
                return AlertDialog(
                  scrollable: true,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)
                  ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Add New Address' , style: TextStyle(
                          color: lightPink , fontFamily: "Poppins" , fontSize: 13
                      ),),
                      IconButton(
                          onPressed:()=>Navigator.pop(context),
                          icon:Icon(Icons.close , color:Colors.red)
                      )
                    ],
                  ),
                  content: Container(
                    width: 250,
                    color: Colors.white,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          loading?LinearProgressIndicator():Container(),
                          TextField(
                            controller: streetNameCtrl,
                            decoration: InputDecoration(
                                hintText: 'Street No.',
                                hintStyle: TextStyle(fontFamily: "Poppins", fontSize: 13),
                                errorText: streetVal?'required street no. & name!':null
                            ),
                          ),
                          SizedBox(height: 15,),
                          TextField(
                            controller: cityNameCtrl,
                            decoration: InputDecoration(
                                hintText: 'City/Area/Town',
                                hintStyle: TextStyle(fontFamily: "Poppins", fontSize: 13),
                                errorText: cityVal?'required city name!':null
                            ),
                          ),SizedBox(height: 15,),

                          TextField(
                            controller: districtNameCtrl,
                            decoration: InputDecoration(
                                hintText: 'District',
                                hintStyle: TextStyle(fontFamily: "Poppins", fontSize: 13),
                                errorText: districtVal?'required district name!':null
                            ),
                          ),
                          SizedBox(height: 15,),
                          TextField(
                            maxLength: 6,
                            controller: pinCodeCtrl,
                            decoration: InputDecoration(
                                hintText: 'Pin Code',
                                hintStyle: TextStyle(fontFamily: "Poppins", fontSize: 13),
                                errorText: pincodeVal?'required pin code!':null
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  actions: [
                    FlatButton(
                        onPressed: () async{

                          setState((){
                            loading = true;
                          });

                          Position position = await _getGeoLocationPosition();
                          List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);

                          Placemark place = placemarks[1];
                          // Address = '${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';

                          setState(()  {
                            streetNameCtrl = new TextEditingController(text: place.street);
                            cityNameCtrl = new TextEditingController(text: place.subLocality);
                            districtNameCtrl = new TextEditingController(text: place.locality);
                            pinCodeCtrl = new TextEditingController(text: place.postalCode);
                          });

                          setState((){
                            loading = false;
                          });

                        },
                        child: Text('Current',style: TextStyle(
                            color: darkBlue,fontFamily: "Poppins"
                        ),)
                    ),
                    FlatButton(
                        onPressed: (){
                          setState((){
                            //street
                            if(streetNameCtrl.text.isEmpty){
                              streetVal = true;
                            }else{
                              streetVal = false;
                            }

                            //city
                            if(cityNameCtrl.text.isEmpty){
                              cityVal = true;
                            }else{
                              cityVal = false;
                            }

                            //dist
                            if(districtNameCtrl.text.isEmpty){
                              districtVal = true;
                            }else{
                              districtVal = false;
                            }

                            //pin
                            if(pinCodeCtrl.text.isEmpty||pinCodeCtrl.text.length <6){
                              pincodeVal = true;
                            }else{
                              pincodeVal = false;
                            }

                            print(

                                'Street no : ${streetNameCtrl.text}\n'
                                    'City : ${cityNameCtrl.text}\n'
                                    'District : ${districtNameCtrl.text}\n'
                                    'Pincode : ${pinCodeCtrl.text}\n'

                            );

                            if(streetNameCtrl.text.isNotEmpty&&cityNameCtrl.text.isNotEmpty&&
                                districtNameCtrl.text.isNotEmpty&&pinCodeCtrl.text.isNotEmpty)
                            {
                              saveNewAddress(streetNameCtrl.text , cityNameCtrl.text , districtNameCtrl.text,
                                  pinCodeCtrl.text);
                            }

                          });
                        },
                        child:Text('Save',style: TextStyle(
                            color: Colors.green,fontFamily: "Poppins"
                        ),)
                    ),
                  ],
                );
              }
          );
        }
    );
  }

  //endregion

  //region Functions

  Future<void> removeMyVendorPref() async{

    var pref = await SharedPreferences.getInstance();

    pref.remove('myVendorId');
    pref.remove('myVendorName');
    pref.remove('myVendorPhone');
    pref.remove('myVendorDesc');
    pref.remove('myVendorProfile');
    pref.remove('myVendorDeliverChrg');
    pref.remove('iamYourVendor');
    pref.remove('iamFromCustomise');

    //remove homescreen caketypes
    pref.remove('homeCakeType');
    pref.remove('homeCTindex');
    pref.remove('isHomeCake');

  }

  //load my vendor Details
  Future<void> loadSelVendorDetails() async{
    var pref = await SharedPreferences.getInstance();
    setState(() {
      myVendorName = pref.getString('myVendorName')??'null';
      myVendorId= pref.getString('myVendorId')??'null';
      myVendorProfile= pref.getString('myVendorProfile')??'null';
      myVendorDelCharge= pref.getString('myVendorDeliverChrg')??'null';
      myVendorPhone= pref.getString('myVendorPhone')??'null';
      myVendorDesc= pref.getString('myVendorDesc')??'null';
      iamYourVendor= pref.getBool('iamYourVendor')??false;
    });
  }


  Future<void> loadPrefs() async{
    var pref = await SharedPreferences.getInstance();
    setState(() {
      userCurLocation = pref.getString('userCurrentLocation')??'Not Found';
      userMainLocation = pref.getString('userMainLocation')??'Not Found';
    });
    getVendorsList();
  }

  //sessions based on time
  String session() {
    var timeNow = DateTime.now().hour;
    if (timeNow <= 12) {
      return "Morning";
    }
    else if ((timeNow > 12) && (timeNow <= 16)) {
      return "Afternoon";
    }
    else if ((timeNow > 16) && (timeNow < 20)) {
      return "Evening";
    }
    else {
      return "Night";
    }
  }

  //Fetching user's current location...Lat Long
  Future<Position> _getGeoLocationPosition() async {

    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      await Geolocator.openLocationSettings();
      print('Location services are disabled.');
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        print('Location permissions are denied');
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      print('Location permissions are permanently denied, we cannot request permissions.');
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.

    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  //add new address
  Future<void> saveNewAddress(String street , String city , String district , String pincode) async{

    setState((){
      deliverAddress = "$street , $city , $district , $pincode";
    });

    Navigator.pop(context);

  }

  //get the vendors....
  Future<void> getVendorsList() async{

    showAlertDialog();
    try{
      var res = await http.get(Uri.parse("https://cakey-database.vercel.app/api/vendors/list"));
      if(res.statusCode==200){
        setState(() {
          List vendorsList = jsonDecode(res.body);

          for(int i = 0; i<vendorsList.length;i++){
            if(vendorsList[i]['Address']!=null&&vendorsList[i]['Address']['City']!=null&&
                vendorsList[i]['Address']['City'].toString().toLowerCase()==userMainLocation.toLowerCase()){
              print('found .... $i');
              setState(() {
                nearestVendors.add(vendorsList[i]);
              });
            }
          }

          Navigator.pop(context);
        });

      }else{
        Navigator.pop(context);
      }
    }on Exception catch(e){
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Check Your Connection! try again'),
            backgroundColor: Colors.amber,
            action: SnackBarAction(
              label: "Retry",
              onPressed:()=>setState(() {
                loadPrefs();
              }),
            ),
          )
      );
    }

  }

  //File piker for upload image
  Future<void> filePicker() async {
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

  //endregion

  @override
  void initState() {
    // TODO: implement initState
    Future.delayed(Duration.zero , () async{
      loadPrefs();

    });
    session();
    setState((){
      fixedSession = session();
    });
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    Future.delayed(Duration.zero , () async{
      removeMyVendorPref();
    });
    super.dispose();
  }

  // void vendorLoad(){
  //   selFromVenList = ;
  //   if(selFromVenList==1){
  //     loadSelVendorDetails();
  //   }else{
  //     return null;
  //   }
  // }

  @override
  Widget build(BuildContext context) {

    profileUrl = context.watch<ContextData>().getProfileUrl();
    selFromVenList = context.watch<ContextData>().getAddedMyVendor();
    mySelectdVendors = context.watch<ContextData>().getMyVendorsList();

    return Scaffold(
      // appBar: AppBar(
      //   leading:Container(
      //     margin: const EdgeInsets.all(10),
      //     child: InkWell(
      //       onTap: () {
      //         Navigator.pop(context);
      //       },
      //       child: Container(
      //           decoration: BoxDecoration(
      //               color: Colors.black26,
      //               borderRadius: BorderRadius.circular(10)),
      //           alignment: Alignment.center,
      //           height: 20,
      //           width: 20,
      //           child: Icon(
      //             Icons.chevron_left,
      //             color: lightPink,
      //             size: 35,
      //           )),
      //     ),
      //   ),
      //   title: Text('FULLY CUSTOMIZATION',
      //       style: TextStyle(
      //           color: darkBlue, fontWeight: FontWeight.bold, fontSize: 15)),
      //   elevation: 0.0,
      //   backgroundColor: lightGrey,
      //   actions: [
      //     Stack(
      //       alignment: Alignment.center,
      //       children: [
      //         InkWell(
      //           onTap: (){
      //             Navigator.of(context).push(
      //               PageRouteBuilder(
      //                 pageBuilder: (context, animation, secondaryAnimation) => Notifications(),
      //                 transitionsBuilder: (context, animation, secondaryAnimation, child) {
      //                   const begin = Offset(1.0, 0.0);
      //                   const end = Offset.zero;
      //                   const curve = Curves.ease;
      //
      //                   final tween = Tween(begin: begin, end: end);
      //                   final curvedAnimation = CurvedAnimation(
      //                     parent: animation,
      //                     curve: curve,
      //                   );
      //                   return SlideTransition(
      //                     position: tween.animate(curvedAnimation),
      //                     child: child,
      //                   );
      //                 },
      //               ),
      //             );
      //           },
      //           child: Container(
      //             padding: EdgeInsets.all(3),
      //             decoration: BoxDecoration(
      //                 color: Colors.black26,
      //                 borderRadius: BorderRadius.circular(8)),
      //             child: Icon(
      //               Icons.notifications_none,
      //               color: darkBlue,
      //             ),
      //           ),
      //         ),
      //         Positioned(
      //           left: 15,
      //           top: 18,
      //           child: CircleAvatar(
      //             radius: 4.5,
      //             backgroundColor: Colors.white,
      //             child: CircleAvatar(
      //               radius: 3.5,
      //               backgroundColor: Colors.red,
      //             ),
      //           ),
      //         ),
      //       ],
      //     ),
      //     SizedBox(
      //       width: 10,
      //     ),
      //     Container(
      //       decoration: BoxDecoration(
      //         color: Colors.white,
      //         shape: BoxShape.circle,
      //         boxShadow: [
      //           BoxShadow(blurRadius: 3, color: Colors.black, spreadRadius: 0)
      //         ],
      //       ),
      //       child: InkWell(
      //         onTap: () {
      //           print('hello surya....');
      //           Navigator.of(context).push(
      //             PageRouteBuilder(
      //               pageBuilder: (context, animation, secondaryAnimation) => Profile(defindex: 0,),
      //               transitionsBuilder: (context, animation, secondaryAnimation, child) {
      //                 const begin = Offset(1.0, 0.0);
      //                 const end = Offset.zero;
      //                 const curve = Curves.ease;
      //
      //                 final tween = Tween(begin: begin, end: end);
      //                 final curvedAnimation = CurvedAnimation(
      //                   parent: animation,
      //                   curve: curve,
      //                 );
      //
      //                 return SlideTransition(
      //                   position: tween.animate(curvedAnimation),
      //                   child: child,
      //                 );
      //               },
      //             ),
      //           );
      //         },
      //         child: profileUrl!="null"?CircleAvatar(
      //           radius: 17.5,
      //           backgroundColor: Colors.white,
      //           child: CircleAvatar(
      //               radius: 16,
      //               backgroundImage:NetworkImage("$profileUrl")
      //           ),
      //         ):CircleAvatar(
      //           radius: 17.5,
      //           backgroundColor: Colors.white,
      //           child: CircleAvatar(
      //               radius: 16,
      //               backgroundImage:AssetImage("assets/images/user.png")
      //           ),
      //         ),
      //       ),
      //     ),
      //     SizedBox(
      //       width: 10,
      //     ),
      //   ],
      // ),
      resizeToAvoidBottomInset: false,
      body:SingleChildScrollView(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //Location name...
              Container(
                padding: EdgeInsets.only(left:10,top: 8,bottom: 15),
                color: lightGrey,
                child: Column(
                  children: [
                    Container(
                      child: Row(
                        children: [
                          Icon(Icons.location_on,color: Colors.red,),
                          SizedBox(width: 5,),
                          Text('Delivery to',style: TextStyle(color: Colors.black54,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,fontFamily: "Poppins"),)
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(left: 8),
                      alignment: Alignment.centerLeft,
                      child: Text('$userCurLocation',style:TextStyle(fontFamily: "Poppins",fontSize: 15,color: darkBlue,fontWeight: FontWeight.bold),),
                    ),
                  ],
                ),
              ),
              //Main widgets....
               Container(
                 height: MediaQuery.of(context).size.height*0.8,
                 child: SingleChildScrollView(
                    child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Text("What Makes Yours Tastier Than The Rest? Customize To Your Heart's",
                                style: TextStyle(color: darkBlue,fontSize: 15,fontFamily: "Poppins",fontWeight: FontWeight.bold),
                              ),
                            ),

                            //Egg Eggless switch
                            Row(
                              children: [
                                Transform.scale(
                                  scale: 0.6,
                                  child: CupertinoSwitch(
                                    thumbColor: Colors.white,
                                    value: egglesSwitch,
                                    onChanged: (bool? val){
                                      setState(() {
                                        egglesSwitch = val!;
                                      });
                                    },
                                    activeColor: Colors.green,
                                  ),
                                ),
                                Text(egglesSwitch?'Eggless':'Egg',style: TextStyle(color: darkBlue,
                                    fontWeight: FontWeight.bold,fontFamily: "Poppins" ,fontSize: 13),),
                              ],
                            ),

                            //Category Text
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Text("Select Category",
                                style: TextStyle(color: darkBlue,fontSize: 14,fontFamily: "Poppins",fontWeight: FontWeight.bold),
                              ),
                            ),

                            //Category stacks ()....
                            Container(
                              height: 80,
                              padding: EdgeInsets.all(10),
                              child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: categories.length,
                                    scrollDirection: Axis.horizontal,
                                    itemBuilder: (context , index){
                                      return Stack(
                                        children: [
                                          GestureDetector(
                                            onTap:(){
                                              setState((){
                                                currentIndex = index;
                                                fixedCategory = categories[currentIndex];
                                              });
                                            },
                                            child: Container(
                                              padding: EdgeInsets.all(5),
                                              child: Container(
                                                padding: EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                    border: Border.all(color: lightPink,width: 1),
                                                    borderRadius: BorderRadius.circular(8)
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Icon(Icons.cake_outlined,color: lightPink,),
                                                    SizedBox(width: 10,),
                                                    Text('${categories[index]}',style: TextStyle(
                                                        fontFamily: "Poppins",
                                                        color: darkBlue
                                                    ),),
                                                    SizedBox(width: 10,),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          currentIndex == index?
                                          Positioned(
                                            right: 0,
                                            child:Container(
                                              alignment: Alignment.center,
                                              height: 20,
                                              width: 20,
                                              decoration: BoxDecoration(
                                                color:Colors.green,
                                                shape: BoxShape.circle
                                              ),
                                              child:Icon(Icons.done_sharp , color:Colors.white , size: 14,)
                                            )
                                          ):Positioned(
                                              right: 0,
                                              child: Container()
                                          ),
                                        ],
                                      );
                                    }
                                )
                            ),

                            //Shapes....flav...toppings
                            ExpansionTile(
                              title: Text('Shapes',style: TextStyle(
                                  fontFamily: "Poppins",fontSize: 13,fontWeight: FontWeight.bold,color: Colors.grey
                              ),),
                              subtitle:Text('$fixedShape',style: TextStyle(
                                  fontFamily: "Poppins",fontSize: 15,fontWeight: FontWeight.w900,
                                  color: darkBlue
                              ),),
                              trailing: Container(
                                alignment: Alignment.center,
                                height: 25,
                                width: 25,
                                decoration: BoxDecoration(
                                  color: Colors.red[100],
                                  shape: BoxShape.circle ,
                                ),
                                child: Icon(Icons.keyboard_arrow_down_rounded , color: darkBlue,size: 25,),
                              ),
                              children: [
                                Container(
                                  child:ListView.builder(
                                        physics: NeverScrollableScrollPhysics(),
                                        itemCount: shapesList.length,
                                        shrinkWrap: true,
                                        itemBuilder: (context, index) {
                                          return RadioListTile(
                                              activeColor: Colors.green,
                                              title: Text(
                                                "${shapesList[index]}",
                                                style: TextStyle(
                                                    fontFamily: "Poppins", color: darkBlue),
                                              ),
                                              value: index,
                                              groupValue: shapeGrpValue,
                                              onChanged: (int? value) {
                                                print(value);
                                                setState(() {
                                                  shapeGrpValue = value!;
                                                  fixedShape = shapesList[index];
                                                });
                                              });
                                        }),
                                ),
                              ],
                            ),
                            Container(
                              margin: EdgeInsets.only(left: 8,right: 8),
                              height: 0.5,
                              color:Colors.pink[200],
                            ),
                            ExpansionTile(
                              title: Text('Flavours',style: TextStyle(
                                  fontFamily: "Poppins",fontSize: 13,fontWeight: FontWeight.bold,color: Colors.grey
                              ),),
                              subtitle:Text('$fixedFlavour',style: TextStyle(
                                  fontFamily: "Poppins",fontSize: 15,fontWeight: FontWeight.w900,
                                  color: darkBlue
                              ),),
                              trailing: Container(
                                alignment: Alignment.center,
                                height: 25,
                                width: 25,
                                decoration: BoxDecoration(
                                  color: Colors.red[100],
                                  shape: BoxShape.circle ,
                                ),
                                child: Icon(Icons.keyboard_arrow_down_rounded , color: darkBlue,size: 25,),
                              ),
                              children: [
                                Container(
                                  child:ListView.builder(
                                      physics: NeverScrollableScrollPhysics(),
                                      itemCount: flavourList.length,
                                      shrinkWrap: true,
                                      itemBuilder: (context, index) {
                                        return RadioListTile(
                                            activeColor: Colors.green,
                                            title: Text(
                                              "${flavourList[index]}",
                                              style: TextStyle(
                                                  fontFamily: "Poppins", color: darkBlue),
                                            ),
                                            value: index,
                                            groupValue: flavGrpValue,
                                            onChanged: (int? value) {
                                              print(value);
                                              setState(() {
                                                flavGrpValue = value!;
                                                fixedFlavour = flavourList[index];
                                              });
                                            });
                                      }),
                                ),
                              ],
                            ),
                            Container(
                              margin: EdgeInsets.only(left: 8,right: 8),
                              height: 0.5,
                              color:Colors.pink[200],
                            ),
                            ExpansionTile(
                              title: Text('Cake Articles',style: TextStyle(
                                  fontFamily: "Poppins",fontSize: 13,fontWeight: FontWeight.bold ,
                                  color: Colors.grey
                              ),),
                              subtitle:Text('$fixedCakeArticle',style: TextStyle(
                                  fontFamily: "Poppins",fontSize: 15,fontWeight: FontWeight.w900,
                                  color: darkBlue
                              ),),
                              trailing: Container(
                                alignment: Alignment.center,
                                height: 25,
                                width: 25,
                                decoration: BoxDecoration(
                                  color: Colors.red[100],
                                  shape: BoxShape.circle ,
                                ),
                                child: Icon(Icons.keyboard_arrow_down_rounded , color: darkBlue,size: 25,),
                              ),
                              children: [
                                Container(
                                  child:ListView.builder(
                                      physics: NeverScrollableScrollPhysics(),
                                      itemCount: cakeArticles.length,
                                      shrinkWrap: true,
                                      itemBuilder: (context, index) {
                                        return RadioListTile(
                                            activeColor: Colors.green,
                                            title: Text(
                                              "${cakeArticles[index]}",
                                              style: TextStyle(
                                                  fontFamily: "Poppins", color: darkBlue),
                                            ),
                                            value: index,
                                            groupValue: artGrpValue,
                                            onChanged: (int? value) {
                                              print(value);
                                              setState(() {
                                                artGrpValue = value!;
                                                fixedCakeArticle = cakeArticles[index];
                                              });
                                            });
                                      }),
                                ),
                              ],
                            ),
                            Container(
                              margin: EdgeInsets.only(left: 8,right: 8),
                              height: 0.5,
                              color:Colors.pink[200],
                            ),

                            //Weight...
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Text("Weight",
                                style: TextStyle(color: darkBlue,fontSize: 14,fontFamily: "Poppins",fontWeight: FontWeight.bold),
                              ),
                            ),
                            Container(
                                height: MediaQuery.of(context).size.height * 0.06,
                                width: MediaQuery.of(context).size.width,
                                margin: EdgeInsets.symmetric(horizontal: 10),
                                //  color: Colors.grey,
                                child: ListView.builder(
                                    itemCount: weight.length,
                                    scrollDirection: Axis.horizontal,
                                    itemBuilder: (context, index) {
                                      selwIndex.add(false);
                                      return InkWell(
                                        onTap: () {

                                          setState(() {
                                            for (int i = 0; i < selwIndex.length; i++) {
                                              if (i == index) {
                                                selwIndex[i] = true;
                                                fixedWeight = weight[index].toString();
                                              } else {
                                                selwIndex[i] = false;
                                              }
                                            }

                                            if(weight[index]>=5){
                                              setState(() {
                                                btnMsg = "CONNECT - HELP DESK";
                                              });
                                            }else{
                                              btnMsg = "ORDER NOW";
                                            }

                                          });
                                        },
                                        child:Container(
                                          width: 70,
                                          alignment: Alignment.center,
                                          margin: EdgeInsets.all(5),
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(18),
                                              border: Border.all(
                                                color: lightPink,
                                                width: 1,
                                              ),
                                              color: selwIndex[index]
                                                  ? Colors.pink
                                                  : Colors.white),
                                          child:
                                          Text(
                                            '${weight[index]} Kg',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontFamily: "Poppins",color: selwIndex[index]?Colors.white:darkBlue
                                            ),
                                          ),
                                        ),
                                      );
                                    })),

                            SizedBox(height:15),
                             Container(
                              margin: EdgeInsets.only(left: 8,right: 8),
                              height: 0.5,
                              color:Colors.pink[200],
                            ),

                            //Tower...
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Text("Cake Tower",
                                style: TextStyle(color: darkBlue,fontSize: 14,fontFamily: "Poppins",fontWeight: FontWeight.bold),
                              ),
                            ),
                            Container(
                                height: MediaQuery.of(context).size.height * 0.06,
                                width: MediaQuery.of(context).size.width,
                                margin: EdgeInsets.symmetric(horizontal: 10),
                                //  color: Colors.grey,
                                child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: cakeTowers.length,
                                    scrollDirection: Axis.horizontal,
                                    itemBuilder: (context, index) {
                                      selCakeTower.add(false);
                                      return InkWell(
                                        onTap: () {
                                          setState(() {
                                            for (int i = 0; i < selCakeTower.length; i++) {
                                              if (i == index) {
                                                selCakeTower[i] = true;
                                                fixedCakeTower = cakeTowers[index];
                                              } else {
                                                selCakeTower[i] = false;
                                              }
                                            }
                                          });
                                        },
                                        child:Container(
                                          width: 60,
                                          alignment: Alignment.center,
                                          margin: EdgeInsets.all(5),
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(18),
                                              border: Border.all(
                                                color: lightPink,
                                                width: 1,
                                              ),
                                              color: selCakeTower[index]
                                                  ? Colors.pink
                                                  : Colors.white
                                          ),
                                          child:
                                          Text(
                                            cakeTowers[index],
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontFamily: "Poppins",color: selCakeTower[index]?Colors.white:darkBlue ,
                                                fontSize: 13
                                            ),
                                          ),
                                        ),
                                      );
                                    })),

                            SizedBox(height:15),
                            Container(
                              margin: EdgeInsets.only(left: 8,right: 8),
                              height: 0.5,
                              color:Colors.pink[200],
                            ),

                            Container(
                              //margin
                                margin: EdgeInsets.all(10),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(' Message on the cake',
                                      style: TextStyle(color: darkBlue,fontSize: 14,fontFamily: "Poppins",fontWeight: FontWeight.bold),
                                    ),

                                    Container(
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              SizedBox(width: 8,),
                                              Icon(Icons.message_outlined,color: lightPink,),
                                              Expanded(
                                                  child: Container(
                                                    margin: EdgeInsets.symmetric(horizontal: 10),
                                                    child: TextField(
                                                      style:TextStyle(fontFamily: 'Poppins' ,
                                                          fontSize: 13
                                                      ),
                                                      decoration: InputDecoration(
                                                        hintText: 'Type here..',
                                                        hintStyle: TextStyle(fontFamily: 'Poppins' ,
                                                        fontSize: 13
                                                        ),
                                                        border: InputBorder.none
                                                      ),
                                                    ),
                                                  ),
                                              )
                                            ],
                                          ),
                                          Container(
                                            margin: EdgeInsets.only(left:10,right: 8),
                                            height: 0.5,
                                            color:Colors.black54,
                                          ),
                                        ],
                                      ),
                                    ),

                                    //Articlessss
                                    Padding(
                                      padding: const EdgeInsets.only(top: 10),
                                      child: Text(
                                        ' Articles',
                                        style: TextStyle(color: darkBlue,fontSize: 14,fontFamily: "Poppins",fontWeight: FontWeight.bold),
                                      ),
                                    ),

                                    Container(
                                        child:ListView.builder(
                                          shrinkWrap : true,
                                          physics : NeverScrollableScrollPhysics(),
                                          itemCount:articals.length,
                                          itemBuilder: (context , index){
                                            return InkWell(
                                              onTap:(){
                                                setState(() {
                                                  articGroupVal = index;
                                                });
                                              },
                                              child: Row(
                                                  children:[
                                                    Radio(
                                                        value: index,
                                                        groupValue: articGroupVal,
                                                        onChanged: (int? val){
                                                          setState(() {
                                                            articGroupVal = val!;
                                                          });
                                                        }
                                                    ),

                                                    Text('${articals[index]} - ',style: TextStyle(
                                                        fontFamily: poppins, color:Colors.black54 , fontSize: 13
                                                    ),),

                                                    Text('${articalsPrice[index]}',style: TextStyle(
                                                        fontFamily: poppins, color:darkBlue , fontSize: 13
                                                    ),),
                                                  ]
                                              ),
                                            );
                                          },
                                        )
                                    ),

                                    Padding(
                                      padding: const EdgeInsets.only(top:10),
                                      child: Text(' Special request to bakers',
                                        style: TextStyle(color: darkBlue,fontSize: 14,fontFamily: "Poppins",fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.all(10),
                                      child: TextField(
                                        style:TextStyle(fontFamily: 'Poppins' ,
                                            fontSize: 13
                                        ),
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor:Colors.grey[200],
                                          hintText: 'Type here..',
                                          hintStyle: TextStyle(fontFamily: 'Poppins' ,
                                              fontSize: 13
                                          ),
                                          border: OutlineInputBorder(
                                              borderSide: BorderSide.none,
                                              borderRadius: BorderRadius.circular(8)
                                          ),
                                        ),
                                        maxLines: 8,
                                        minLines: 5,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        SizedBox(width: 8,),
                                        Text('Delivery Date',
                                          style: TextStyle(color: darkBlue,fontSize: 14,fontFamily: "Poppins",fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(width: 65,),
                                        Text('Delivery Session',
                                          style: TextStyle(color: darkBlue,fontSize: 14,fontFamily: "Poppins",fontWeight: FontWeight.bold),
                                        )
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        SizedBox(width: 5,),
                                        OutlinedButton(
                                          onPressed: () async {
                                            DateTime? SelDate = await showDatePicker(
                                              context: context,
                                              initialDate: DateTime.now(),
                                              lastDate: DateTime(2050),
                                              firstDate: DateTime.now()
                                                  .subtract(Duration(days: 0)),
                                            );

                                            setState(() {
                                              fixedDate = simplyFormat(
                                                  time: SelDate, dateOnly: true);
                                            });

                                            // print(SelDate.toString());
                                            // print(DateTime.now().subtract(Duration(days: 0)));
                                          },
                                          child: Row(
                                            children: [
                                              Text('$fixedDate',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,color: Colors.grey,
                                                  fontSize: 13
                                              ),
                                              ),
                                              SizedBox(width: 10,),
                                              Icon(Icons.date_range_outlined,color:darkBlue)
                                            ],
                                          ),
                                        ),
                                        SizedBox(width: 30,),
                                        OutlinedButton(
                                          onPressed: (){
                                            showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return AlertDialog(
                                                    shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                        BorderRadius.circular(
                                                            20)),
                                                    title: Text(
                                                        "Select delivery session",
                                                        style: TextStyle(
                                                          color: lightPink,
                                                          fontFamily: "Poppins",
                                                          fontSize: 16,
                                                        )),
                                                    content: Column(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        ListTile(
                                                          onTap: () {
                                                            Navigator.pop(context);
                                                            setState(() {
                                                              fixedSession =
                                                              "Morning";
                                                            });
                                                          },
                                                          title: Text('Morning',
                                                              style: TextStyle(
                                                                  color: darkBlue,
                                                                  fontFamily:
                                                                  "Poppins")),
                                                        ),
                                                        ListTile(
                                                          onTap: () {
                                                            Navigator.pop(context);
                                                            setState(() {
                                                              fixedSession =
                                                              "Afternoon";
                                                            });
                                                          },
                                                          title: Text('Afternoon',
                                                              style: TextStyle(
                                                                  color: darkBlue,
                                                                  fontFamily:
                                                                  "Poppins")),
                                                        ),
                                                        ListTile(
                                                          onTap: () {
                                                            Navigator.pop(context);
                                                            setState(() {
                                                              fixedSession =
                                                              "Evening";
                                                            });
                                                          },
                                                          title: Text('Evening',
                                                              style: TextStyle(
                                                                  color: darkBlue,
                                                                  fontFamily:
                                                                  "Poppins"
                                                              )),
                                                        ),
                                                        ListTile(
                                                          onTap: () {
                                                            Navigator.pop(context);
                                                            setState(() {
                                                              fixedSession =
                                                              "Night";
                                                            });
                                                          },
                                                          title: Text('Night',
                                                              style: TextStyle(
                                                                  color: darkBlue,
                                                                  fontFamily:
                                                                  "Poppins")),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                });
                                          },
                                          child: Row(
                                            children: [
                                              Text('$fixedSession',style: TextStyle(
                                                  fontWeight: FontWeight.bold,color: Colors.grey,
                                                  fontSize: 13
                                              ),),
                                              SizedBox(width: 50,),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                )),
                            Padding(
                              padding: const EdgeInsets.only(left: 10.0),
                              child: Text(' Address',
                                style: TextStyle(color: darkBlue,fontSize: 14,fontFamily: "Poppins",fontWeight: FontWeight.bold),
                              ),
                            ),
                            ListTile(
                              title: Text('$deliverAddress',
                                style: TextStyle(fontFamily: poppins,color: Colors.grey,fontSize: 13),
                              ),
                              trailing: Icon(Icons.check_circle,color: Colors.green,),
                            ),
                            Container(
                              margin: EdgeInsets.only(left: 10),
                              alignment: Alignment.centerLeft,
                              child: TextButton(
                                  onPressed: (){
                                    showAddAddressAlert();
                                  },
                                  child: const Text('add new address',style: const TextStyle(
                                      color: Colors.orange,fontFamily: "Poppins",decoration: TextDecoration.underline
                                  ),)
                              ),
                            ),

                            //Image Upload
                            Padding(
                              padding: const EdgeInsets.only(left: 10.0),
                              child: Text(' Upload Image',
                                style: TextStyle(color: darkBlue,fontSize: 14,fontFamily: "Poppins",fontWeight: FontWeight.bold),
                              ),
                            ),
                            
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: DottedBorder(
                                radius: Radius.circular(20),
                                color: Colors.grey,//color of dotted/dash line
                                strokeWidth: 1, //thickness of dash/dots
                                dashPattern: [3,2],
                                child: InkWell(
                                  splashColor: Colors.red[100],
                                  onTap:()=>filePicker(),
                                  child: file.path.isEmpty?Container(
                                    width: MediaQuery.of(context).size.width,
                                    height: 160,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.image_rounded , color: Colors.blueAccent,size: 40,),
                                        Text('Pick Your Image',
                                          style: TextStyle(color: darkBlue,fontSize: 16,fontFamily: "Poppins",fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ):Container(
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.all(10),
                                    width: MediaQuery.of(context).size.width,
                                    height: 160,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          height: 150,
                                          width: 200,
                                          child: Image.file(file),
                                        ),
                                       TextButton(
                                              onPressed: (){
                                                setState(() {
                                                  file = new File('');
                                                });
                                              },
                                              child: Text('Remove' , style: TextStyle(
                                                fontFamily: "Poppins"
                                              ),),
                                       )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: 15,),
                            
                            Container(
                              padding: EdgeInsets.all(10.0),
                              color: Colors.black12,
                              child: Column(
                                children: [
                                  btnMsg.toLowerCase()!='connect - help desk'?
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Text(!selFromVenList?'Select Vendors':'Your Vendor',style: TextStyle(fontSize:15,
                                              color: darkBlue,fontWeight: FontWeight.bold,fontFamily: poppins),),
                                          Text(!selFromVenList?'  (10km radius)':'',style: TextStyle(color: Colors.black45,fontFamily: poppins),),
                                        ],
                                      ),
                                      !selFromVenList?InkWell(
                                        onTap: () async{
                                          print('see more..');
                                          var pref = await SharedPreferences.getInstance();
                                          pref.setBool('iamFromCustomise', true);
                                          setState(() {
                                            // context.read<ContextData>().setCurrentIndex(3);
                                            Navigator.push(context, MaterialPageRoute(
                                                builder: (context)=>VendorsList()
                                            ));
                                          });
                                        },
                                        child: Row(
                                          children: [
                                            Text('See All',style: TextStyle(color: lightPink,fontWeight: FontWeight.bold,fontFamily: poppins),),
                                            Icon(Icons.keyboard_arrow_right,color: lightPink,)
                                          ],
                                        ),
                                      ):Container(),
                                    ],
                                  ):Container(),
                                  SizedBox(height: 15,),
                                  btnMsg.toLowerCase()!='connect - help desk'?
                                  Container(
                                    height: selFromVenList?160:200,
                                    child: !selFromVenList?
                                    ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        shrinkWrap: true,
                                        itemCount: nearestVendors.length,
                                        itemBuilder: (context , index){
                                          return Card(
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10)
                                            ),
                                            child: InkWell(
                                              splashColor:Colors.red[200] ,
                                              onTap: (){
                                                print(index);

                                                String adrss = '1/4 vellandipalayam , Avinashi';

                                                setState((){
                                                  selVendorIndex = index;
                                                });

                                              },
                                              child: Container(
                                                padding: EdgeInsets.all(10),
                                                width: 260,
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      children: [
                                                        nearestVendors[index]['ProfileImage']!=null?
                                                        CircleAvatar(
                                                          radius:32,
                                                          backgroundColor: Colors.white,
                                                          child: CircleAvatar(
                                                            radius:30,
                                                            backgroundImage: NetworkImage('${nearestVendors[index]['ProfileImage']}'),
                                                          ),
                                                        ):
                                                        CircleAvatar(
                                                          radius:32,
                                                          backgroundColor: Colors.white,
                                                          child: CircleAvatar(
                                                            radius:30,
                                                            backgroundImage:Svg('assets/images/pictwo.svg'),
                                                          ),
                                                        ),
                                                        SizedBox(width: 6,),
                                                        Container(
                                                          width:170,
                                                          child: Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              Column(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  Container(
                                                                    width:120,
                                                                    child: Text(nearestVendors[index]['VendorName'].toString().isEmpty?
                                                                    'Un name':'${nearestVendors[index]['VendorName'][0].toString().toUpperCase()+
                                                                        nearestVendors[index]['VendorName'].toString().substring(1).toLowerCase()
                                                                    }',style: TextStyle(
                                                                        color: darkBlue,fontWeight: FontWeight.bold,
                                                                        fontFamily: "Poppins"
                                                                    ),overflow: TextOverflow.ellipsis,),
                                                                  ),
                                                                  Row(
                                                                    children: [
                                                                      RatingBar.builder(
                                                                        initialRating: 4.1,
                                                                        minRating: 1,
                                                                        direction: Axis.horizontal,
                                                                        allowHalfRating: true,
                                                                        itemCount: 5,
                                                                        itemSize: 14,
                                                                        itemPadding: EdgeInsets.symmetric(horizontal: 1.0),
                                                                        itemBuilder: (context, _) => Icon(
                                                                          Icons.star,
                                                                          color: Colors.amber,
                                                                        ),
                                                                        onRatingUpdate: (rating) {
                                                                          print(rating);
                                                                        },
                                                                      ),
                                                                      Text(' 4.5',style: TextStyle(
                                                                          color: Colors.black54,fontWeight: FontWeight.bold,fontSize: 13,fontFamily: poppins
                                                                      ),)
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(height: 10,),
                                                    Container(
                                                      alignment: Alignment.centerLeft,
                                                      child: Text(nearestVendors[index]['Description']!=null?
                                                      " "+nearestVendors[index]['Description']:'',
                                                        style: TextStyle(color: Colors.black54,fontFamily: "Poppins" , fontSize: 13),
                                                        overflow: TextOverflow.ellipsis,
                                                        maxLines: 1,
                                                        textAlign: TextAlign.start,
                                                      ),
                                                    ),
                                                    Container(
                                                      margin:EdgeInsets.only(top: 10),
                                                      height: 0.5,
                                                      color: Colors.black26,
                                                    ),
                                                    SizedBox(height: 15,),
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            nearestVendors[index]['EggOrEggless'].toString()=='Both'?
                                                            Text('Egg and Eggless',style: TextStyle(
                                                                color: darkBlue,
                                                                fontSize: 10,
                                                                fontFamily: "Poppins"
                                                            ),):
                                                            Text('${nearestVendors[index]['EggOrEggless'].toString()}',style: TextStyle(
                                                                color: darkBlue,
                                                                fontSize: 10,
                                                                fontFamily: "Poppins"
                                                            ),),
                                                            SizedBox(height: 8,),
                                                            Text(nearestVendors[index]['DeliveryCharge'].toString()=='null'||
                                                                nearestVendors[index]['DeliveryCharge'].toString()=='0'||
                                                                nearestVendors[index]['DeliveryCharge'].toString()==null
                                                                ?
                                                            'DELIVERY FREE':'Delivery Charge ₹${nearestVendors[index]['DeliveryCharge'].toString()}',style: TextStyle(
                                                                color: Colors.orange,
                                                                fontSize: 10 ,
                                                                fontFamily: "Poppins"
                                                            ),),
                                                          ],
                                                        ),
                                                        selVendorIndex==index?
                                                        Icon(Icons.check_circle,color: Colors.green,):
                                                        Container(),
                                                      ],
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        }
                                    ):
                                    Container(
                                      width: MediaQuery.of(context).size.width,
                                      padding: EdgeInsets.all(5),
                                      margin: EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                          color:Colors.white , 
                                          borderRadius:BorderRadius.circular(10)
                                      ),
                                      child: Row(
                                        children: [
                                          mySelectdVendors[0]['VendorProfile']!=null?
                                          Container(
                                            width:90,
                                            decoration: BoxDecoration(
                                                color:Colors.red ,
                                                borderRadius:BorderRadius.circular(10) ,
                                                image:DecorationImage(
                                                  image:NetworkImage(mySelectdVendors[0]['VendorProfile']),
                                                  fit: BoxFit.cover
                                                )
                                            ),
                                          ):
                                          Container(
                                            width:90,
                                            decoration: BoxDecoration(
                                                color:Colors.red ,
                                                borderRadius:BorderRadius.circular(10) ,
                                                image:DecorationImage(
                                                    image:Svg("assets/images/pictwo.svg"),
                                                    fit: BoxFit.cover
                                                )
                                            ),
                                          ),
                                          SizedBox(width: 8,),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      width:155,
                                                      child: Column(
                                                        mainAxisSize: MainAxisSize.min,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Container(
                                                            child: Text('${mySelectdVendors[0]['VendorName']}' , style: TextStyle(
                                                              color: Colors.black,
                                                              fontWeight: FontWeight.bold,
                                                              fontFamily: "Poppins",
                                                            ),overflow: TextOverflow.ellipsis,),
                                                          ),
                                                          SizedBox(height: 6,) ,
                                                          Row(
                                                            children: [
                                                              RatingBar.builder(
                                                                initialRating: 4.1,
                                                                minRating: 1,
                                                                direction: Axis.horizontal,
                                                                allowHalfRating: true,
                                                                itemCount: 5,
                                                                itemSize: 14,
                                                                itemPadding: EdgeInsets.symmetric(horizontal: 1.0),
                                                                itemBuilder: (context, _) => Icon(
                                                                  Icons.star,
                                                                  color: Colors.amber,
                                                                ),
                                                                onRatingUpdate: (rating) {
                                                                  print(rating);
                                                                },
                                                              ),
                                                              Text(' 4.5',style: TextStyle(
                                                                  color: Colors.black54,fontWeight: FontWeight.bold,fontSize: 13,fontFamily: poppins
                                                              ),)
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Icon(Icons.check_circle,color:Colors.green)
                                                  ],
                                                ),
                                                Text(mySelectdVendors[0]['VendorDesc']!=null||
                                                    mySelectdVendors[0]['VendorDesc']!='null'?
                                                "${mySelectdVendors[0]['VendorDesc']}":"No Description",
                                                  style:TextStyle(
                                                  fontSize:12,
                                                  fontFamily: "Poppins" ,
                                                  color:Colors.grey,
                                                  fontWeight: FontWeight.bold,
                                                ),maxLines: 2,),
                                                Container(
                                                  height:1,
                                                  color:Colors.grey,
                                                  // margin: EdgeInsets.only(left:6,right:6),
                                                ),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(mySelectdVendors[0]['VendorEgg']=='Both'?
                                                        'Includes eggless':'${mySelectdVendors[0]['VendorEgg']}',
                                                          style:TextStyle(
                                                            fontSize:11,
                                                            fontFamily: "Poppins" ,
                                                            color:darkBlue,
                                                          ),maxLines: 1,),
                                                        SizedBox(height:3),
                                                        Text(mySelectdVendors[0]['VendorDelCharge']=='0'||
                                                            mySelectdVendors[0]['VendorDelCharge']==null?
                                                        "DELIVERY FREE":'Delivery Fee Rs.${mySelectdVendors[0]['VendorDelCharge']}',
                                                          style:TextStyle(
                                                            fontSize:10,
                                                            fontFamily: "Poppins" ,
                                                            color:Colors.orange,
                                                          ),maxLines: 1,),
                                                      ],
                                                    ),
                                                    Container(
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
                                                              decoration: BoxDecoration(
                                                                shape: BoxShape.circle,
                                                                color: Colors.grey[200],
                                                              ),
                                                              child:const Icon(Icons.phone,color: Colors.blueAccent,),
                                                            ),
                                                          ),
                                                          const SizedBox(width: 10,),
                                                          InkWell(
                                                            onTap: (){
                                                              print('whatsapp : ');
                                                            },
                                                            child: Container(
                                                              alignment: Alignment.center,
                                                              height: 35,
                                                              width: 35,
                                                              decoration: BoxDecoration(
                                                                  shape: BoxShape.circle,
                                                                  color:Colors.grey[200]
                                                              ),
                                                              child:const Icon(Icons.whatsapp_rounded,color: Colors.green,),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  ):
                                  Container(),
                                  SizedBox(height: 15,),
                                  Container(
                                    height: 50,
                                    width: 200,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(25)
                                    ),
                                    child: RaisedButton(
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(25)
                                      ),
                                      onPressed: (){

                                        print('Show my vendors : $mySelectdVendors');

                                        print(!egglesSwitch?'Egg':'Eggless');
                                        if(fixedCategory.isEmpty){
                                          setState(() {
                                            fixedCategory = categories[0];
                                          });
                                        }

                                        print("Fixed Category : $fixedCategory");
                                        print("Fixed Shape : $fixedShape");
                                        print("Fixed Flav : $fixedFlavour");
                                        print("Fixed Article : $fixedCakeArticle");
                                        print("Fixed Weight : $fixedWeight");
                                        print("Fixed Tower : $fixedCakeTower");

                                      },
                                      color: lightPink,
                                      child: Text("$btnMsg",style: TextStyle(
                                          color: Colors.white,fontWeight: FontWeight.bold
                                      ),),
                                    ),
                                  ),
                                  SizedBox(height: 15,),
                                ],
                              ),
                            ),

                          ],
                        ),
                 ),
               ),
            ],
          ),
      ),
    );
  }
}

String simplyFormat({required DateTime? time, bool dateOnly = false}) {
  List<String> months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];

  String year = time!.year.toString();

  // Add "0" on the left if month is from 1 to 9
  String month = time.month.toString().padLeft(2, '0');

  // Add "0" on the left if day is from 1 to 9
  String day = time.day.toString().padLeft(2, '0');

  // Add "0" on the left if hour is from 1 to 9
  String hour = time.hour.toString().padLeft(2, '0');

  // Add "0" on the left if minute is from 1 to 9
  String minute = time.minute.toString().padLeft(2, '0');

  // Add "0" on the left if second is from 1 to 9
  String second = time.second.toString();

  // return the "yyyy-MM-dd HH:mm:ss" format
  if (dateOnly == false) {
    return "$day-$month-$year $hour:$minute:$second";
  }

  // If you only want year, month, and date
  return "$day-$month-$year";
}
