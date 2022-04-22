import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:http/http.dart' as http;
import 'package:cakey/ContextData.dart';
import 'package:cakey/DrawerScreens/CakeTypes.dart';
import 'package:cakey/DrawerScreens/VendorsList.dart';
import 'package:cakey/screens/WelcomeScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

import '../screens/Profile.dart';
import '../screens/SingleVendor.dart';
import 'CustomiseCake.dart';
//This is home screen.........
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  //region Vari..
  //Scaff Key..
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  //Colors....
  Color lightGrey = Color(0xffF5F5F5);
  Color darkBlue = Color(0xffF213959);
  Color lightPink = Color(0xffFE8416D);

  //fbase
  User authUser = FirebaseAuth.instance.currentUser!;

  int i = 0;
  //booleans
  bool egglesSwitch = true;
  //prefs val..
  bool newRegUser = true;
  bool profileRemainder = false;
  bool isNetworkError = false;

  //Strings
  String poppins = "Poppins";
  String phoneNumber = '';
  String networkMsg = "";

  //latlong
  String location ='Null, Press Button';
  //address
  String userLocalityAdr = 'Searching...';
  //users details
  String userID = "";
  String userAddress = "";
  String userProfileUrl = "";
  String userName = "";
  String userMainLocation = "";

  //Lists
  List cakesList = [];
  List<String> cakeTypeImages = [];
  List cakesTypes = [];
  List recentOrders = [];
  List vendorsList = [];
  List nearestVendors = [];


  //TextFields controls for search....
  var cakeCategoryCtrl = new TextEditingController();
  var cakeSubCategoryCtrl = new TextEditingController();
  var cakeVendorCtrl = new TextEditingController();
  var cakeLocationCtrl = new TextEditingController();


  //endregion

  //region Alerts

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

  //Filter Bottom sheet(**important...)
  void showFilterBottom(){

    setState(() {
      cakeLocationCtrl.text = userLocalityAdr;
    });

      showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(topRight: Radius.circular(20),topLeft: Radius.circular(20)),
      ),
      context: context,
      isScrollControlled: true,
      builder: (context){
       return StatefulBuilder(
           builder: (BuildContext context , void Function(void Function()) setState){
             return Container(
               // padding: EdgeInsets.all(15),
               padding: EdgeInsets.only(
                 bottom: MediaQuery.of(context).viewInsets.bottom,
               ),
               child:SingleChildScrollView(
                 child: Container(
                   padding: EdgeInsets.all(20),
                   child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     mainAxisSize: MainAxisSize.min,
                     children: [
                       SizedBox(height: 8,),
                       //Title text...
                       Row(
                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                         children: [
                           Text('SEARCH',style: TextStyle(color: darkBlue,fontSize: 18,
                               fontWeight: FontWeight.bold,fontFamily: "Poppins"),),
                           GestureDetector(
                             onTap: ()=>Navigator.pop(context),
                             child: Container(
                                 width: 35,
                                 height: 35,
                                 decoration: BoxDecoration(
                                     color: Colors.black12,
                                     borderRadius: BorderRadius.circular(10)
                                 ),
                                 alignment: Alignment.center,
                                 child: Icon(Icons.close_outlined,color: lightPink,)
                             ),
                           ),
                         ],
                       ),
                       SizedBox(
                         height: 15,
                       ),
                       //Edit texts...
                       Container(
                         height: 45,
                         child: TextField(
                           controller: cakeCategoryCtrl,
                           decoration: InputDecoration(
                               contentPadding: EdgeInsets.all(5),
                               hintText: "Category",
                               hintStyle: TextStyle(fontFamily: "Poppins" , fontSize: 13),
                               prefixIcon: Icon(Icons.search_outlined),
                               border: OutlineInputBorder()
                           ),
                         ),
                       ),
                       SizedBox(
                         height: 15,
                       ),
                       Container(
                         height: 45,
                         child: TextField(
                           controller: cakeSubCategoryCtrl,
                           decoration: InputDecoration(
                               contentPadding: EdgeInsets.all(5),
                               hintText: "Sub Category",
                               hintStyle: TextStyle(fontFamily: "Poppins", fontSize: 13),
                               prefixIcon: Icon(Icons.search_outlined),
                               border: OutlineInputBorder()
                           ),
                         ),
                       ),
                       SizedBox(
                         height: 15,
                       ),
                       Container(
                         height: 45,
                         child: TextField(
                           controller: cakeVendorCtrl,
                           decoration: InputDecoration(
                               contentPadding: EdgeInsets.all(5),
                               hintText: "Vendors",
                               hintStyle: TextStyle(fontFamily: "Poppins", fontSize: 13),
                               prefixIcon: Icon(Icons.sentiment_very_satisfied_rounded),
                               border: OutlineInputBorder()
                           ),
                         ),
                       ),
                       SizedBox(
                         height: 4,
                       ),
                       Text("nearest 10 km radius from your location", style:  TextStyle(
                           color: darkBlue , fontSize: 11 , fontFamily: "Poppins"),),
                       SizedBox(
                         height: 15,
                       ),
                       Container(
                         height: 45,
                         child: TextField(
                           controller: cakeLocationCtrl,
                           decoration: InputDecoration(
                               contentPadding: EdgeInsets.all(5),
                               hintText: "Location",
                               hintStyle: TextStyle(fontFamily: "Poppins", fontSize: 13),
                               prefixIcon: Icon(Icons.location_on),
                               suffixIcon: IconButton(
                                 onPressed: (){},
                                 icon: Icon(Icons.my_location),
                               ),
                               border: OutlineInputBorder()
                           ),
                         ),
                       ),
                       SizedBox(
                         height: 5,
                       ),
                       //kilo meter radius buttons.........
                       Wrap(
                         runSpacing: 5.0,
                         spacing: 5.0,
                         children: [
                           OutlinedButton(
                             onPressed: (){},
                             child: Text('5 KM',style: TextStyle(color: darkBlue,fontFamily: "Poppins"),),
                           ),
                           OutlinedButton(
                             onPressed: (){},
                             child: Text('10 KM',style: TextStyle(color: darkBlue,fontFamily: "Poppins"),),
                           ),
                           OutlinedButton(
                             onPressed: (){},
                             child: Text('15 KM',style: TextStyle(color: darkBlue,fontFamily: "Poppins"),),
                           ),
                           OutlinedButton(
                             onPressed: (){},
                             child: Text('20 KM',style: TextStyle(color: darkBlue,fontFamily: "Poppins"),),
                           ),
                         ],

                       ),
                       SizedBox(
                         height: 10,
                       ),

                       //Divider
                       Container(
                         height: 1.0,
                         color: Colors.black26,
                       ),

                       SizedBox(height: 5,),


                       Align(
                         alignment: Alignment.centerLeft,
                         child: Text('Star Ratting',style: TextStyle(color: darkBlue,fontSize: 16,
                             fontWeight: FontWeight.bold,fontFamily: "Poppins"),),
                       ),
                       SizedBox(height: 5,),
                       //stars rattings...
                       Wrap(
                         runSpacing: 5.0,
                         spacing: 5.0,
                         children: [
                           OutlinedButton(
                             onPressed: (){},
                             child: Text('3 Star',style: TextStyle(fontSize: 12,color: darkBlue,fontFamily: "Poppins"),),
                           ),
                           OutlinedButton(
                             onPressed: (){},
                             child: Text('4 Star',style: TextStyle(fontSize: 12,color: darkBlue,fontFamily: "Poppins"),),
                           ),
                           OutlinedButton(
                             onPressed: (){},
                             child: Text('5 Star',style: TextStyle(fontSize: 12,color: darkBlue,fontFamily: "Poppins"),),
                           ),
                         ],
                       ),

                       SizedBox(height: 5,),
                       //Divider
                       Container(
                         height: 1.0,
                         color: Colors.black26,
                       ),
                       //cake types....
                       SizedBox(height: 5,),

                       Align(
                         alignment: Alignment.centerLeft,
                         child: Text('Types',style: TextStyle(color: darkBlue,fontSize: 16,
                             fontWeight: FontWeight.bold,fontFamily: "Poppins"),),
                       ),
                       SizedBox(height: 5,),
                       //types of cakes btn...
                       Wrap(
                         runSpacing: 5.0,
                         spacing: 5.0,
                         children: [
                           OutlinedButton(
                             onPressed: (){},
                             child: Text('Normal cakes',style: TextStyle(fontSize: 12,color: darkBlue,fontFamily: "Poppins"),),
                           ),
                           OutlinedButton(
                             onPressed: (){},
                             child: Text('Basic Customize cake',style: TextStyle(fontSize: 12,color: darkBlue,fontFamily: "Poppins"),),
                           ),
                           OutlinedButton(
                             onPressed: (){},
                             child: Text('Fully Customize cake',style: TextStyle(fontSize: 12,color: darkBlue,fontFamily: "Poppins"),),
                           ),
                         ],
                       ),

                       SizedBox(height: 10,),
                       //Search button...
                       Center(
                         child: Container(
                           height: 55,
                           width: 200,
                           child: RaisedButton(
                             shape: RoundedRectangleBorder(
                               borderRadius: BorderRadius.circular(30),
                             ),
                             color: lightPink,
                             onPressed: (){
                               Navigator.pop(context);
                               showDpUpdtaeDialog();
                             },
                             child: Text("SEARCH",style: TextStyle(
                                 color: Colors.white,fontWeight: FontWeight.bold,fontFamily: "Poppins"
                             ),),
                           ),
                         ),
                       )

                     ],
                   ),
                 ),
               ),
             );
           }
       );
    }
    );
  }

  //Profile update remainder dialog
  void showDpUpdtaeDialog(){
    showDialog(
        barrierDismissible: true,
        context: context,
        builder: (context){
          return Align(
            alignment: Alignment.topCenter,
            child: Container(
              height: 90,
              decoration: BoxDecoration(
                  color: Colors.white,
                   border: Border.all(color: lightPink,width: 1.5,style: BorderStyle.solid),
                   borderRadius: BorderRadius.only(bottomLeft: Radius.circular(14),
                   bottomRight: Radius.circular(14),
                  )
              ),
              padding: EdgeInsets.all(5),
             child: Row(
               crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(10)
                      ),
                      alignment: Alignment.center,
                      child: Icon(Icons.volume_up_rounded,color: darkBlue,size: 30,)
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        child: Text('Complete Your Profile & Easy To Take\nYour Order',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: TextStyle(color: darkBlue,fontWeight: FontWeight.bold,
                              fontFamily: "Poppins",fontSize: 12,decoration: TextDecoration.none),
                        ),
                      ),
                      SizedBox(height: 5,),
                      Container(
                        height: 25,
                        width: 80,
                        child: RaisedButton(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25)
                          ),
                          color:lightPink,
                          onPressed: (){
                            Navigator.of(context).push(
                              PageRouteBuilder(
                                pageBuilder: (context, animation, secondaryAnimation) => Profile(
                                  defindex: 0,
                                ),
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
                          child: Text('PROFILE',
                            style: TextStyle(color:Colors.white,fontFamily: "Poppins",fontSize: 10),
                          ),
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: ()=>Navigator.pop(context),
                    child: Container(
                        width: 35,
                        height: 35,
                        decoration: BoxDecoration(
                            color: Colors.black12,
                            borderRadius: BorderRadius.circular(10)
                        ),
                        alignment: Alignment.center,
                        child: Icon(Icons.close_outlined,color: darkBlue,)
                    ),
                  ),
                ],
              ),
            ),
          );
        }
    );
  }

  //endregion

  //region Functions


  //send nearest vendor details.
  Future<void> sendNearVendorDataToScreen(int index) async{
    var pref = await SharedPreferences.getInstance();

    //common keyword single****
    pref.setString('singleVendorID', nearestVendors[index]['_id']);
    pref.setString('singleVendorName', nearestVendors[index]['VendorName']);
    pref.setString('singleVendorDesc', nearestVendors[index]['Description']??'No description');
    pref.setString('singleVendorPhone', nearestVendors[index]['PhoneNumber']??'0000000000');
    pref.setString('singleVendorDpImage', nearestVendors[index]['ProfileImage']??'null');
    pref.setString('singleVendorDelivery', nearestVendors[index]['DeliveryCharge']??'null');

    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => SingleVendor(),
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

  }

  //getting prefes
  Future<void> loadPrefs() async{
    var prefs = await SharedPreferences.getInstance();
    setState(() {
      profileRemainder = prefs.getBool("profileUpdated")??false;
      phoneNumber = prefs.getString("phoneNumber")??"";
      newRegUser = prefs.getBool("newRegUser")??false;
    });
    timerTrigger();
    Position position = await _getGeoLocationPosition();
    location ='Lat: ${position.latitude} , Long: ${position.longitude}';
    GetAddressFromLatLong(position);

  }

  //update profile timer dialog for new users
  void timerTrigger() {
    if(newRegUser==true){
      setState(() {
        Timer(
            Duration(seconds: 5),(){
            showDpUpdtaeDialog();
        }
        );
      });
    }else{
      print("New reg user $newRegUser");
    }

  }

  //Fetching user details from API....
  Future<void> fetchProfileByPhn() async{
    showAlertDialog();
    var prefs = await SharedPreferences.getInstance();
    // showAlertDialog();
    //needs to imple..
    http.Response response = await http.get(Uri.parse("https://cakey-database.vercel.app/api/users/list/"
        "${int.parse(phoneNumber)}"));
    if(response.statusCode==200){
      // Navigator.pop(context);
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

        getCakeList();
        getOrderList();
        Navigator.pop(context);
      });
    }else{
      // Navigator.pop(context);
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

  //getting users accurate location address...
  Future<void> GetAddressFromLatLong(Position position)async {
    
    var prefs = await SharedPreferences.getInstance();
    List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
    print(placemarks);
    Placemark place = placemarks[1];
    // Address = '${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';

    setState(()  {
      userLocalityAdr = '${place.subLocality}';
      userMainLocation = '${place.locality}';
      prefs.setString("userCurrentLocation",place.subLocality.toString());
      prefs.setString("userMainLocation",place.locality.toString());
    });
  }

  //Fetching cake list API...
  Future<void> getCakeList() async{
    try{
      http.Response response = await http.get(
          Uri.parse("https://cakey-database.vercel.app/api/cake/list")
      );
      if(response.statusCode==200){
        setState(() {
          isNetworkError = false;
          cakesList = jsonDecode(response.body);
          cakesList = cakesList.reversed.toList();
          for(int i =0 ;i<cakesList.length;i++){
            if(i==0){
              cakesTypes.add('Customize your cake');
            }else{
              cakesTypes.add(cakesList[i]['TypeOfCake']);
            }
          }

          cakesTypes = cakesTypes.toSet().toList();
        });
      }else{
          print('Server error! try again latter');
          setState(() {
            isNetworkError = true;
            networkMsg = "Server error! try again latter";
          });
      }
    }catch(error){
      setState(() {
        isNetworkError = true;
      });
    }
  }

  //Check the internet
  Future<void> checkNetwork() async{
    try {
      final result = await InternetAddress.lookup('www.google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Connected...!'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            )
        );
        setState(() {
          networkMsg = "Network connected";
        });
        print('connected');
      }
    } on SocketException catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('You are offline!'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          )
      );
      print('not connected');
      setState(() {
        networkMsg = "No Internet! Connect & tap here";
      });
    }
    // return connetedOrNot;
  }

  //getting recent orders list by UserId
  Future<void> getOrderList() async{
    try{
      http.Response response = await http.get(
          Uri.parse("https://cakey-database.vercel.app/api/order/listbyuserid/$userID")
      );
      if(response.statusCode==200){
        setState(() {
          isNetworkError = false;
          recentOrders = jsonDecode(response.body);
          recentOrders = recentOrders.reversed.toList();
        });
      }
      else{
        setState(() {
          isNetworkError = true;
        });
      }
    }catch(error){
      setState(() {
        isNetworkError = true;
      });
    }
  }

  //Get vendors list
  Future<void> getVendorsList() async{
    showAlertDialog();
    var res = await http.get(Uri.parse("https://cakey-database.vercel.app/api/vendors/list"));

    if(res.statusCode==200){

      setState(() {
        vendorsList = jsonDecode(res.body);

        nearestVendors = vendorsList.where((element){

          if(element['Address']!=null){
            return element['Address']['City'].toString().toLowerCase().contains(userMainLocation.toLowerCase());
          }
          else{
            return false;
          }

        }).toList();
        

        nearestVendors = nearestVendors.toSet().toList();
        nearestVendors = nearestVendors.reversed.toList();

        Navigator.pop(context);
      });

    }else{
      Navigator.pop(context);
    }
  }

  //endregion

  //onStart
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration.zero ,() async{
      loadPrefs();
      fetchProfileByPhn();
      getVendorsList();
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      key: _scaffoldKey,
      body: SingleChildScrollView(
          child: Column(
            children: [
              //Location and search....
              Container(
                padding: EdgeInsets.only(left:10,top: 8,bottom: 15),
                color: lightGrey,
                child: Column(
                  children: [
                    Container(
                      child: Row(
                        children: [
                          Icon(Icons.location_on,color: Colors.red,),
                          SizedBox(width: 8,),
                          Text('Delivery to',style: TextStyle(color: Colors.black54,fontWeight: FontWeight.bold,fontFamily: poppins),)
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(left: 8),
                      alignment: Alignment.centerLeft,
                      child: Text('$userLocalityAdr',style:TextStyle(fontFamily: poppins,fontSize: 18,color: darkBlue,fontWeight: FontWeight.bold),),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 15),
                      padding: EdgeInsets.only(right: 10),
                      alignment: Alignment.center,
                      child: Row(
                        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: width*0.79,
                            height: 50,
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: "Search cake, vendor, etc...",
                                hintStyle: TextStyle(fontFamily: poppins,fontSize: 13),
                                prefixIcon: Icon(Icons.search),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8)
                                ),
                                contentPadding: EdgeInsets.all(5),
                              ),
                            ),
                          ),
                          SizedBox(width: 5,),
                          Container(
                            width: width*0.13,
                            height: 50,
                            decoration: BoxDecoration(
                                color: lightPink,
                                borderRadius: BorderRadius.circular(8)
                            ),
                            child:IconButton(
                                splashColor: Colors.black26,
                                onPressed:(){
                                  FocusScope.of(context).unfocus();
                                  showFilterBottom();
                                  // showDpUpdtaeDialog();
                                  _getGeoLocationPosition();
                                },
                                icon: Icon(Icons.tune,color:Colors.white,)
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                color: lightGrey,
                height: height*0.71,
                child: RefreshIndicator(
                  onRefresh: () async{
                    Position position = await _getGeoLocationPosition();
                    setState(() {
                      location ='Lat: ${position.latitude} , Long: ${position.longitude}';
                      GetAddressFromLatLong(position);
                      loadPrefs();
                      fetchProfileByPhn();
                      getVendorsList();
                    });
                  },
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Visibility(
                          visible: isNetworkError,
                          child: InkWell(
                            splashColor: Colors.black26,
                            onTap: (){
                              setState(() {
                                loadPrefs();
                              });
                            },
                            child: Text('$networkMsg',style: TextStyle(
                                fontFamily: "Poppins",color: Colors.red,fontSize: 16
                            ),),
                          ),
                        ),

                        cakesList.length==0?
                        StaggeredGridView.countBuilder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.all(12.0),
                            crossAxisCount: 2,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 12,
                            itemCount: 20,
                            staggeredTileBuilder: (int index) => StaggeredTile.fit(1),
                            itemBuilder: (BuildContext context, int index){
                              return Shimmer.fromColors(
                                direction: ShimmerDirection.ttb,
                                baseColor: Colors.grey,
                                highlightColor: Colors.white,
                                child: Container(
                                  padding: EdgeInsets.all(10),
                                  height: 250,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: Colors.black,width: 1)
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: Colors.black,
                                        radius: 45,
                                      ),
                                      Container(
                                        height: 50,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(10),
                                          color: Colors.black,
                                        ),
                                      ),
                                      Container(
                                        height: 25,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(10),
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                        ):
                        //List views and orders...
                        Column(
                          children: [
                            Container(
                              height: 510,
                              decoration: const BoxDecoration(
                                image: DecorationImage(
                                    image:Svg('assets/images/splash.svg'),
                                    fit: BoxFit.cover,
                                    colorFilter:ColorFilter.mode(Colors.white70,BlendMode.darken)
                                ),
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(15),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Type of Cakes',style: TextStyle(fontFamily: poppins,fontSize:18,color: darkBlue,fontWeight: FontWeight.bold),),
                                        InkWell(
                                          onTap: (){
                                            Navigator.of(context).push(
                                              PageRouteBuilder(
                                                pageBuilder: (context, animation, secondaryAnimation) => CakeTypes(),
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
                                          child: Row(
                                            children: [
                                              Text('See All',style: TextStyle(color: lightPink,fontFamily: poppins,fontWeight: FontWeight.bold),),
                                              Icon(Icons.keyboard_arrow_right,color: lightPink,)
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    height:175,
                                    child: ListView.builder(
                                        shrinkWrap: true,
                                        scrollDirection: Axis.horizontal,
                                        itemCount:cakesTypes.length,
                                        itemBuilder: (context , index){
                                          return index==0?
                                           Container(
                                            width: 150,
                                            child: InkWell(
                                              onTap: (){
                                                FocusScope.of(context).unfocus();
                                                Navigator.of(context).push(
                                                  PageRouteBuilder(
                                                    pageBuilder: (context, animation, secondaryAnimation) => CustomiseCake(),
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
                                              child: Column(
                                                children: [
                                                  Container(
                                                    height: 120,
                                                    width: 130,
                                                    decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(20),
                                                        border: Border.all(color: Colors.white,width: 2),
                                                        image: DecorationImage(
                                                            image:AssetImage('assets/images/customcake.png'),
                                                            fit: BoxFit.cover
                                                        )
                                                    ),
                                                  ),
                                                  Text(
                                                    cakesTypes[index]==null?
                                                    'No name':"${cakesTypes[index]}"
                                                    ,style:TextStyle(color: darkBlue,
                                                      fontWeight: FontWeight.bold,fontFamily: poppins),
                                                    textAlign: TextAlign.center,
                                                  )
                                                ],
                                              ),
                                            ),
                                          )
                                          :Container(
                                            width: 150,
                                            child: InkWell(
                                              onTap: (){
                                                FocusScope.of(context).unfocus();
                                                Navigator.of(context).push(
                                                  PageRouteBuilder(
                                                    pageBuilder: (context, animation, secondaryAnimation) => CakeTypes(),
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
                                              child: Column(
                                                children: [
                                                  Container(
                                                    height: 120,
                                                    width: 130,
                                                    decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(20),
                                                        border: Border.all(color: Colors.white,width: 2),
                                                        image: DecorationImage(
                                                            image:
                                                            cakesList[index]['Images'].isEmpty?
                                                            NetworkImage('https://w0.peakpx.com/wallpaper/863/651/HD-wallpaper-red-cake-pastries-desserts-cakes-strawberry-cake-berry-cake.jpg'):
                                                            NetworkImage(cakesList[index]['Images'][0].toString()),
                                                            fit: BoxFit.cover
                                                        )
                                                    ),
                                                  ),
                                                  Text(
                                                    cakesTypes[index]==null?
                                                    'No name':"${cakesTypes[index][0].toString().toUpperCase()+
                                                        cakesTypes[index].toString().substring(1).toLowerCase()}"
                                                    ,style:TextStyle(color: darkBlue,
                                                      fontWeight: FontWeight.bold,fontFamily: poppins),
                                                    textAlign: TextAlign.center,
                                                  )
                                                ],
                                              ),
                                            ),
                                          );
                                        }
                                    ),
                                  ),
                                  Container(
                                    height: 0.5,
                                    width: double.infinity,
                                    margin: EdgeInsets.only(left: 10,right: 10),
                                    color: Colors.black26,
                                  ),
                                  Container(
                                      padding: EdgeInsets.all(10),
                                      width: double.infinity,
                                      alignment: Alignment.centerLeft,
                                      child: Text('Recent Ordered',style: TextStyle(
                                          color: darkBlue,fontWeight: FontWeight.bold,fontSize: 18,fontFamily: poppins
                                      ),)
                                  ),
                                  Container(
                                    height: 220,
                                    child: recentOrders.length>0?
                                    ListView.builder(
                                        itemCount: 3,
                                        scrollDirection: Axis.horizontal,
                                        itemBuilder: (context,index){
                                          return Container(
                                            margin: EdgeInsets.only(left: 10,right: 10),
                                            child: Stack(
                                              alignment: Alignment.topCenter,
                                              children: [
                                                Container(
                                                  height:140,
                                                  width: 200,
                                                  decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(15),
                                                      image: DecorationImage(
                                                          fit: BoxFit.cover,
                                                          image: NetworkImage('${recentOrders[index]['Images']}')
                                                      )
                                                  ),
                                                ),
                                                Positioned(
                                                  top: 100,
                                                  child: Card(
                                                    shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(10)
                                                    ),
                                                    elevation: 7,
                                                    child: Container(
                                                      padding: EdgeInsets.all(8),
                                                      width: 190,
                                                      height: 100,
                                                      child: Column(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Container(
                                                              alignment: Alignment.centerLeft,
                                                              child: Container(
                                                                width: 150,
                                                                child: Text('${recentOrders[index]['Title']}',style: TextStyle(color: darkBlue
                                                                    ,fontWeight: FontWeight.bold,fontFamily: poppins
                                                                ),maxLines: 1,overflow: TextOverflow.ellipsis,),
                                                              )
                                                          ),
                                                          Row(
                                                            children: [
                                                              CircleAvatar(
                                                                radius:14,
                                                                child: Icon(Icons.account_circle,),
                                                              ),
                                                              Container(
                                                                  width: 105,
                                                                  child: Text(' ${recentOrders[index]['VendorName']}',
                                                                    overflow: TextOverflow.ellipsis,style: TextStyle(
                                                                        color: Colors.black54,fontFamily: poppins),maxLines: 1,))
                                                            ],
                                                          ),
                                                          Container(
                                                            height: 0.5,
                                                            color: Colors.black54,
                                                            margin: EdgeInsets.only(left: 5,right: 5),
                                                          ),
                                                          Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              Text("₹ ${recentOrders[index]['Total']}",style: TextStyle(color: lightPink,
                                                                  fontWeight: FontWeight.bold,fontFamily: poppins),maxLines: 1,),
                                                              recentOrders[index]['Status'].toString().toLowerCase()=='delivered'?
                                                              Text("${recentOrders[index]['Status'].toString()}",style: TextStyle(color: Colors.green,
                                                              fontWeight: FontWeight.bold,fontFamily: poppins,fontSize: 12),)
                                                                  :
                                                              Text("${recentOrders[index]['Status']}",style: TextStyle(color: Colors.blueAccent,
                                                                  fontWeight: FontWeight.bold,fontFamily: poppins,fontSize: 12),)
                                                            ],
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }
                                    ):
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.shopping_basket_outlined,
                                            color: lightPink,
                                            size: 35,
                                          ),

                                          Text('No Recent Orders',style: TextStyle(
                                              color: darkBlue,
                                              fontFamily: "Poppins",
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15
                                          ),),

                                        ],
                                    )
                                  )
                                ],
                              ),
                            ),
                            //Vendors........
                            Container(
                              padding: EdgeInsets.all(15),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text('Vendors list',style: TextStyle(fontSize:18,
                                          color: darkBlue,fontWeight: FontWeight.bold,fontFamily: poppins),),
                                      Text('  (10km radius)',style: TextStyle(color: Colors.black45,fontFamily: poppins),),
                                    ],
                                  ),
                                  InkWell(
                                    onTap: (){
                                      Navigator.of(context).push(
                                        PageRouteBuilder(
                                          pageBuilder: (context, animation, secondaryAnimation) => VendorsList(),
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
                                    child: Row(
                                      children: [
                                        Text('See All',style: TextStyle(color: lightPink,fontWeight: FontWeight.bold,fontFamily: poppins),),
                                        Icon(Icons.keyboard_arrow_right,color: lightPink,)
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                Container(
                                  padding: EdgeInsets.only(left: 10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [

                                      Row(
                                        children: [
                                          Transform.scale(
                                            scale: 0.7,
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
                                              fontWeight: FontWeight.bold,fontFamily: poppins),),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  child: ListView.builder(
                                      itemCount: nearestVendors.length,
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemBuilder: (context,index){
                                        return InkWell(
                                          splashColor: Colors.pink[100],
                                          onTap:()=>sendNearVendorDataToScreen(index),
                                          child: Card(
                                            margin: EdgeInsets.only(left: 10,right: 10,top: 10,bottom: 5),
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(15)
                                            ),
                                            child: Container(
                                              // margin: EdgeInsets.all(5),
                                              padding: EdgeInsets.all(6),
                                              height: 130,
                                              decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(15)
                                              ),
                                              child: Row(
                                                children: [
                                                  nearestVendors[index]['ProfileImage']!=null?
                                                  Container(
                                                    height: 120,
                                                    width: 90,
                                                    decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(15),
                                                        image: DecorationImage(
                                                          fit: BoxFit.cover,
                                                          image: NetworkImage('${nearestVendors[index]['ProfileImage']}'),
                                                        )
                                                    ),
                                                  ):
                                                  Container(
                                                    height: 120,
                                                    width: 90,
                                                    decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(15),
                                                        image: DecorationImage(
                                                          fit: BoxFit.cover,
                                                          image: Svg('assets/images/pictwo.svg'),
                                                        )
                                                    ),
                                                  ),
                                                  Container(
                                                    padding: EdgeInsets.only(left: 10),
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                      children: [
                                                        Container(
                                                          width:width*0.63,
                                                          child: Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              Column(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  Container(
                                                                    width:width*0.5,
                                                                    child: Text(
                                                                      '${nearestVendors[index]['VendorName'][0].toString().toUpperCase()+
                                                                      "${nearestVendors[index]['VendorName'].toString().substring(1).toLowerCase()}"}'
                                                                      ,overflow: TextOverflow.ellipsis,style: TextStyle(
                                                                        color: darkBlue,fontWeight: FontWeight.bold,fontSize: 14,fontFamily: poppins
                                                                    ),),
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
                                                                        },
                                                                      ),
                                                                      Text(' 4.5',style: TextStyle(
                                                                          color: Colors.black54,fontWeight: FontWeight.bold,fontSize: 13,fontFamily: poppins
                                                                      ),)
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                              InkWell(
                                                                onTap: (){
                                                                  sendNearVendorDataToScreen(index);
                                                                },
                                                                child: Container(
                                                                  decoration: BoxDecoration(
                                                                      color: lightGrey,
                                                                      shape: BoxShape.circle
                                                                  ),
                                                                  padding: EdgeInsets.all(4),
                                                                  height: 35,
                                                                  width: 35,
                                                                  child: Icon(Icons.keyboard_arrow_right,color: lightPink,),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Container(
                                                          width: width*0.63,
                                                          child: Text(nearestVendors[index]['Description']!=null?
                                                          "${nearestVendors[index]['Description']}":'No description',overflow: TextOverflow.ellipsis,style: TextStyle(
                                                              color: Colors.black54,fontFamily: poppins,fontSize: 13
                                                          ),maxLines: 1,),
                                                        ),
                                                        Container(
                                                          height: 1,
                                                          width: width*0.63,
                                                          color: Colors.black26,
                                                        ),
                                                        Container(
                                                          width: width*0.63,
                                                          child: Wrap(
                                                            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            runSpacing: 5.0,
                                                            spacing: 5.0,
                                                            runAlignment: WrapAlignment.spaceBetween,
                                                            children: [
                                                              nearestVendors[index]['DeliveryCharge']==null?
                                                              Text('DELIVERY FREE',style: TextStyle(
                                                                  color: Colors.orange,fontSize: 10,fontFamily: poppins
                                                              ),):
                                                              Text('10 km Delivery Fee Rs.${nearestVendors[index]['DeliveryCharge']}',style: TextStyle(
                                                                  color: darkBlue,fontSize: 10,fontFamily: poppins,fontWeight: FontWeight.bold
                                                              ),),
                                                              SizedBox(
                                                                width: 20,
                                                              ),
                                                              Text('Includes eggless cake',style: TextStyle(
                                                                  color: Colors.black,fontSize: 10,fontWeight: FontWeight.bold,fontFamily: poppins
                                                              ),overflow: TextOverflow.ellipsis,),
                                                            ],
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      }
                                  ),
                                ),
                                SizedBox(height: 15,),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
    );
  }
}
