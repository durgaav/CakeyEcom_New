import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:cakey/DrawerScreens/CustomiseCake.dart';
import 'package:cakey/drawermenu/app_bar.dart';
import 'package:cakey/screens/Hampers.dart';
import 'package:cakey/DrawerScreens/VendorsList.dart';
import 'package:cakey/screens/CakeDetails.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'dart:math';
import 'package:flutter/widgets.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_webservice/places.dart' as wbservice;
import 'package:http/http.dart' as http;
import 'package:cakey/ContextData.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import 'package:geocoding/geocoding.dart' as geocode;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import '../Dialogs.dart';
import '../OtherProducts/OtherDetails.dart';
import '../ProfileDialog.dart';
import '../drawermenu/NavDrawer.dart';
import '../screens/HamperDetails.dart';
import '../screens/Profile.dart';
import 'package:location/location.dart';
import '../screens/SingleVendor.dart';
import 'CakeTypes.dart';
import 'Notifications.dart';
import 'package:permission_handler/permission_handler.dart' as Handler;

//This is home ...
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

  DateTime? currentBackPressTime;

  int i = 0;
  int deliveryChargeFromAdmin = 0;
  int deliverykmFromAdmin = 0;
  //booleans
  bool egglesSwitch = false;
  //prefs val..
  bool newRegUser = true;
  bool profileRemainder = false;
  bool isNetworkError = false;
  bool ordersLoading = true;
  bool isAllLoading = true;
  bool vendorsLoading = true;
  bool connected = false;
  String cakeType = "";

  //for search
  bool isFiltered = false;
  bool activeSearch = false;
  //for vendors list
  bool onChanged = false;

  String poppins = "Poppins";
  String profileUrl = '';

  //Strings
  String phoneNumber = '';
  String authToken = '';
  String networkMsg = "";
  String searchText = '';

  String selectedCakeType = '';

  //latlong
  String location = 'Null, Press Button';
  //address
  String userLocalityAdr = 'Searching...';
  bool showAddressEdit = false;
  var deliverToCtrl = new TextEditingController();

  //noti count
  int notiCount = 0;

  //users details
  String userID = "";
  String userAddress = "";
  String userProfileUrl = "";
  String userName = "";
  String userMainLocation = "";
  //search filter string
  String searchCakeCate = '';
  String searchCakeSubType = '';
  String searchCakeVendor = '';
  String searchCakeLocation = '';

  //Lists
  List cakesList = [];
  List<String> cakeTypeImages = [];
  List searchCakeType = [];
  List cakesTypes = [];
  List recentOrders = [];
  List vendorsList = [];
  List searchVendors = [];
  List filteredByEggList = [];
  List nearestVendors = [];

  //Filter caketype
  List filterTypeList = ["Birthday", "Wedding", "Theme Cake", "Normal Cake"];
  List selectedFilter = [];
  var adsBanners = [];

//search all type
  List cakeSearchList = [];
  List categoryList = [];
  List subCategoryList = [];
  //for filter search
  List cakeTypeList = [];
  List otherProdList = [];

  List vendorNameList = [];
  List typesList = [];
  //TextFields controls for search....
  var cakeCategoryCtrl = new TextEditingController();
  var cakeSubCategoryCtrl = new TextEditingController();
  var cakeVendorCtrl = new TextEditingController();
  var cakeLocationCtrl = new TextEditingController();
  var mainSearchCtrl = new TextEditingController();

  double userLat = 0.0;
  double userLong = 0.0;

  //latt and long and maps
  double latude = 0.0;
  double longtude = 0.0;
  List<geocode.Placemark> placemarks = [];

  late bool _serviceEnabled;
  late PermissionStatus _permissionGranted;
  LocationData? _userLocation;
  Location myLocation = Location();

  List<String> activeVendorsIds = [];

  List hampers = [];

  //endregion

  //region Alerts

  double changeWeight(String weight) {

    print(weight);

    String givenWeight = weight;
    double converetedWeight = 0.0;

    if(givenWeight.toLowerCase().endsWith("kg")){

      givenWeight = givenWeight.toLowerCase().replaceAll("kg", "");
      converetedWeight = double.parse(givenWeight);

    }else{

      givenWeight = givenWeight.toLowerCase().replaceAll("g", "");
      converetedWeight = double.parse(givenWeight)/1000;

    }

    print("Converted : $converetedWeight");

    return converetedWeight;
  }

  //Default loader dialog
  void showAlertDialog() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
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
                  SizedBox(
                    height: 13,
                  ),
                  Text(
                    'Please Wait...',
                    style: TextStyle(
                      color: Colors.black,
                      fontFamily: 'Poppins',
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }

  //Filter Bottom sheet(**important...)
  void showFilterBottom() {
    List myList = [];

    setState(() {
      for (var i = 0; i < searchCakeType.length; i++) {
        if (searchCakeType[i]['name'].toString().toLowerCase() !=
            "customize your cake" && searchCakeType[i]['name'].toString().toLowerCase() !=
            "others" ) {
          myList.add(searchCakeType[i]['name']);
        }
      }
    });

    showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(20), topLeft: Radius.circular(20)),
        ),
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return StatefulBuilder(builder:
              (BuildContext context, void Function(void Function()) setState) {
            return Container(
              // padding: EdgeInsets.all(15),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 8,
                      ),
                      //Title text...
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text.rich(TextSpan(
                              text: "SEARCH",
                              style: TextStyle(
                                  color: darkBlue,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: "Poppins"),
                              children: [

                              ])),
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                                width: 35,
                                height: 35,
                                decoration: BoxDecoration(
                                    color: Colors.black12,
                                    borderRadius: BorderRadius.circular(10)),
                                alignment: Alignment.center,
                                child: Icon(
                                  Icons.close_outlined,
                                  color: lightPink,
                                )),
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
                          onChanged: (String? text) {
                            searchCakeCate = text!;
                          },
                          controller: cakeCategoryCtrl,
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(5),
                              hintText: "Cake Name",
                              hintStyle: TextStyle(
                                  fontFamily: "Poppins", fontSize: 13),
                              prefixIcon: Icon(Icons.search_outlined),
                              border: OutlineInputBorder()),
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Container(
                        height: 45,
                        child: TextField(
                          onChanged: (String? text) {
                            searchCakeSubType = text!;
                          },
                          controller: cakeSubCategoryCtrl,
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(5),
                              hintText: "Occasion cake",
                              hintStyle: TextStyle(
                                  fontFamily: "Poppins", fontSize: 13),
                              prefixIcon: Icon(Icons.search_outlined),
                              border: OutlineInputBorder()),
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Container(
                        height: 45,
                        child: TextField(
                          onChanged: (String? text) {
                            searchCakeVendor = text!;
                          },
                          controller: cakeVendorCtrl,
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(5),
                              hintText: "Vendors",
                              hintStyle: TextStyle(
                                  fontFamily: "Poppins", fontSize: 13),
                              prefixIcon:
                                  Icon(CupertinoIcons.person_alt_circle),
                              border: OutlineInputBorder()),
                        ),
                      ),
                      SizedBox(
                        height: 4,
                      ),
                      Text(
                        "nearest 10 km radius from your location",
                        style: TextStyle(
                            color: darkBlue,
                            fontSize: 11,
                            fontFamily: "Poppins"),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      SizedBox(
                        height: 10,
                      ),

                      //Divider
                      Container(
                        height: 1.0,
                        color: Colors.black26,
                      ),

                      SizedBox(
                        height: 5,
                      ),

                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Types',
                          style: TextStyle(
                              color: darkBlue,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: "Poppins"),
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),

                      Wrap(
                        runSpacing: -5,
                        spacing: 5,
                        children: myList.map((e) {
                          bool clicked = false;
                          if (selectedFilter.contains(e)) {
                            clicked = true;
                          }
                          return OutlinedButton(
                            onPressed: () {
                              setState(() {
                                if (selectedFilter.contains(e)) {
                                  selectedFilter
                                      .removeWhere((element) => element == e);
                                  clicked = false;
                                } else {
                                  selectedFilter.add(e);
                                  clicked = true;
                                }
                              });
                            },
                            child: Text(
                              e[0].toString().toUpperCase()+e.toString().substring(1).toLowerCase(),
                              style: TextStyle(
                                  fontFamily: "Poppins",
                                  color: clicked ? Colors.white : darkBlue,
                                  fontWeight: FontWeight.bold),
                            ),
                            style: ButtonStyle(
                              side: MaterialStateProperty.all(BorderSide(
                                  width: 1, color: Colors.grey[300]!)),
                              shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                              backgroundColor: MaterialStateProperty.all(
                                clicked
                                    ? darkBlue.withOpacity(0.7)
                                    : Colors.white,
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      SizedBox(
                        height: 10,
                      ),
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
                            onPressed: () {
                              Navigator.pop(context);
                              searchByGivenFilter(
                                  cakeCategoryCtrl.text,
                                  cakeSubCategoryCtrl.text,
                                  cakeVendorCtrl.text,
                                  selectedFilter
                              );
                            },
                            child: Text(
                              "SEARCH",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: "Poppins"),
                            ),
                          ),
                        ),
                      ),

                      Center(
                        child: TextButton(
                          onPressed: () {
                            //clearing all filters
                            Navigator.pop(context);
                            setState(() {
                              activeSearchClear();
                            });
                          },
                          child: Text(
                            "CLEAR",
                            style: TextStyle(
                                color: lightPink,
                                fontWeight: FontWeight.bold,
                                fontFamily: "Poppins",
                                decoration: TextDecoration.underline),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          });
        });
  }

  //Profile update remainder dialog
  void showDpUpdtaeDialog() {
    showDialog(
        barrierDismissible: true,
        context: context,
        builder: (context) {
          return Align(
             alignment: Alignment.topCenter,
             child:Container(
               decoration: BoxDecoration(
                 color: Colors.white,
                 borderRadius: BorderRadius.only(
                   bottomRight: Radius.circular(20),
                   bottomLeft: Radius.circular(20),
                 )
               ),
               padding: EdgeInsets.all(10),
               child: Column(
                 mainAxisSize: MainAxisSize.min,
                 children: [
                   Row(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children:[
                         Container(
                           height : 40,
                           width: 40,
                           alignment: Alignment.center,
                           decoration: BoxDecoration(
                               color: Colors.amber,
                               borderRadius: BorderRadius.circular(10)
                           ),
                           child: Icon(Icons.campaign_rounded,color:darkBlue,size: 28,),
                         ),
                         const SizedBox(width: 8,),
                         Expanded(
                           child: Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                               Text("Complete Your Profile",style: TextStyle(
                                   color: darkBlue,fontFamily: "Poppins",fontWeight: FontWeight.bold,
                                   fontSize: 14.5,decoration: TextDecoration.none
                               ),),
                               SizedBox(height: 5,),
                               Align(
                                 alignment: Alignment.centerRight,
                                 child: Container(
                                   height: 30,
                                   width: 100,
                                   decoration:BoxDecoration(
                                     borderRadius: BorderRadius.circular(20)
                                   ),
                                   child: RaisedButton(
                                     shape: RoundedRectangleBorder(
                                         borderRadius: BorderRadius.circular(20)
                                     ),
                                       onPressed:(){
                                         Navigator.push(context, MaterialPageRoute(builder: (context)=>Profile(defindex: 0)));
                                       },
                                     child: Text("PROFILE",style: TextStyle(
                                         color: Colors.white,fontFamily: "Poppins",fontWeight: FontWeight.bold,
                                         fontSize: 12,decoration: TextDecoration.none
                                     ),),
                                     color: lightPink,
                                   ),
                                 ),
                               )
                             ],
                           ),
                         ),
                         GestureDetector(
                           onTap: () => Navigator.pop(context),
                           child: Container(
                               width: 30,
                               height: 30,
                               decoration: BoxDecoration(
                                   color: Colors.black12,
                                   borderRadius: BorderRadius.circular(7)),
                               alignment: Alignment.center,
                               child: Icon(
                                 Icons.close_outlined,
                                 color: darkBlue,
                               )),
                         ),
                       ]
                   )
                 ],
               ),
             )
            );
        });
  }

  //endregion

  //region Functions

  //send details to next screen
  Future<void> sendDetailsToScreen(String id) async {

    int index = cakeSearchList.indexWhere((element) => element['_id'].toString()==id);

    //Local Vars
    List<String> cakeImgs = [];
    List<String> cakeWeights = [];
    List cakeFlavs = [];
    List cakeShapes = [];
    List cakeTiers = [];
    List tiersDelTimes = [];
    var prefs = await SharedPreferences.getInstance();
    List<String> typesOfCake = [];

    String vendorAddress = cakeSearchList[index]['VendorAddress'];

    //region API LIST LOADING...
    //getting cake pics
    if (cakeSearchList[index]['AdditionalCakeImages'].isNotEmpty) {
      setState(() {
        for (int i = 0; i < cakeSearchList[index]['AdditionalCakeImages'].length; i++) {
          cakeImgs.add(cakeSearchList[index]['AdditionalCakeImages'][i].toString());
        }
      });
    } else {
      setState(() {
        cakeImgs = [
          cakeSearchList[index]['MainCakeImage'].toString()
        ];
      });
    }

    //getting cake types
    if (cakeSearchList[index]['CakeType'].isNotEmpty) {
      setState(() {
        for (int i = 0; i < cakeSearchList[index]['CakeType'].length; i++) {
          typesOfCake.add(cakeSearchList[index]['CakeType'][i].toString());
        }
      });
    }

    // getting cake flavs
    if (cakeSearchList[index]['CustomFlavourList'].isNotEmpty||cakeSearchList[index]['CustomFlavourList']!=null) {
      setState(() {
        cakeFlavs = cakeSearchList[index]['CustomFlavourList'];

        // for(int i = 0 ; i<cakeSearchList[index]['CustomFlavourList'].length;i++){
        //   cakeFlavs.add(cakeSearchList[index]['CustomFlavourList'][i].toString());
        // }

      });
    } else {
      setState(() {
        cakeFlavs = [
        ];
      });
    }

    // // getting cake tiers
    // if (cakeSearchList[index]['TierCakeMinWeightAndPrice'].isNotEmpty||cakeSearchList[index]['TierCakeMinWeightAndPrice']!=null) {
    //   setState(() {
    //     cakeTiers = cakeSearchList[index]['TierCakeMinWeightAndPrice'];
    //   });
    // } else {
    //   setState(() {
    //     cakeTiers = [];
    //   });
    // }

    // if (cakeSearchList[index]['MinTimeForDeliveryFortierCake'].isNotEmpty||cakeSearchList[index]['MinTimeForDeliveryFortierCake']!=null) {
    //   setState(() {
    //     tiersDelTimes = cakeSearchList[index]['MinTimeForDeliveryFortierCake'];
    //   });
    // } else {
    //   setState(() {
    //     tiersDelTimes = [];
    //   });
    // }

    // getting cake shapes
    if (cakeSearchList[index]['CustomShapeList']['Info'].isNotEmpty||
        cakeSearchList[index]['CustomShapeList']['Info']!=null) {
      setState(() {
        cakeShapes = cakeSearchList[index]['CustomShapeList']['Info'];

        // for(int i = 0 ; i<cakeSearchList[index]['CustomShapeList']['Info'].length;i++){
        //   cakeShapes.add(cakeSearchList[index]['CustomShapeList']['Info'][i].toString());
        // }

      });
    } else {
      setState(() {
        cakeShapes = [
        ];
      });
    }


    //getting cake toppings list
    // if(cakeSearchList[index]['CakeToppings'].isNotEmpty){
    //   setState(() {
    //     for(int i=0;i<cakeSearchList[index]['CakeToppings'].length;i++){
    //       cakeTopings.add(cakeSearchList[index]['CakeToppings'][i].toString());
    //     }
    //   });
    // }
    // else{
    //   setState(() {
    //     cakeTopings = [];
    //   });
    // }

    //getting cake weights


    if (cakeSearchList[index]['MinWeightList'].isNotEmpty || cakeSearchList[index]['MinWeightList']!=null) {
      setState(() {
        for (int i = 0; i < cakeSearchList[index]['MinWeightList'].length; i++) {
          cakeWeights.add(cakeSearchList[index]['MinWeightList'][i].toString());
        }
      });
    } else {
      setState(() {
        cakeWeights = [];
      });
    }

    //endregion

    //region REMOVE PREFS...

    prefs.remove('cakeImages');
    prefs.remove('cakeWeights');
    prefs.remove("cake_id");
    prefs.remove("cakeModid");
    prefs.remove("cakeName");
    prefs.remove('firstVenDelCharge');
    prefs.remove('firstVenIndex');
    prefs.remove("cakeCommName");
    prefs.remove("cakeBasicFlav");
    prefs.remove("cakeBasicShape");
    prefs.remove("cakeMinWeight");
    prefs.remove("cakeMinPrice");
    prefs.remove("cakeEggorEggless");
    prefs.remove("cakeEgglessAvail");
    prefs.remove("cakeEgglesCost");
    prefs.remove("cakeTierPoss");
    prefs.remove("cakeThemePoss");
    prefs.remove("cakeToppersPoss");
    prefs.remove("cakeBasicCustom");
    prefs.remove("cakeFullCustom");
    prefs.remove("cakeType");
    prefs.remove("cakeSubType");
    prefs.remove("cakeDescription");
    prefs.remove("cakeCategory");

    prefs.remove("cakeVendorid");
    prefs.remove("cakeVendorModid");
    prefs.remove("cakeVendorName");
    prefs.remove("cakeVendorPhone1");
    prefs.remove("cakeVendorPhone2");
    prefs.remove("cakeVendorAddress");

    prefs.remove('cakeDiscount');
    prefs.remove('cakeTax');
    prefs.remove('cakeDiscount');
    prefs.remove('cakeTopperPoss');

    //endregion

    //set The preferece...

    //API LIST DATAS
    prefs.setStringList('cakeImages', cakeImgs);
    prefs.setStringList('cakeWeights', cakeWeights);
    prefs.setStringList('cakeMainTypes', typesOfCake);

    //API STRINGS AND INTS DATAS
    prefs.setString("cake_id", cakeSearchList[index]['_id']??"null");
    prefs.setString("cakeModid", cakeSearchList[index]['Id']??"null");
    prefs.setString("cakeMainImage", cakeSearchList[index]['MainCakeImage']??"null");
    prefs.setString("cakeName", cakeSearchList[index]['CakeName']??"null");
    prefs.setString("cakeCommName", cakeSearchList[index]['CakeCommonName']??"null");
    prefs.setString("cakeBasicFlav", cakeSearchList[index]['BasicFlavour']??"null");
    prefs.setString("cakeBasicShape", cakeSearchList[index]['BasicShape']??"null");
    prefs.setString("cakeMinWeight", cakeSearchList[index]['MinWeight']??"null");
    prefs.setString("cakeMinPrice", cakeSearchList[index]['BasicCakePrice']??"null");
    prefs.setString("cakeEggorEggless", cakeSearchList[index]['DefaultCakeEggOrEggless']??"null");
    prefs.setString("cakeEgglessAvail", cakeSearchList[index]['IsEgglessOptionAvailable']??"null");
    prefs.setString("cakeEgglesCost", cakeSearchList[index]['BasicEgglessCostPerKg']??"null");
    prefs.setString("cakeCostWithEggless", cakeSearchList[index]['BasicEgglessCostPerKg']??"null");
    prefs.setString("cakeTierPoss", cakeSearchList[index]['IsTierCakePossible']??"null");
    prefs.setString("cakeThemePoss", cakeSearchList[index]['ThemeCakePossible']??"null");
    prefs.setString("cakeToppersPoss", cakeSearchList[index]['ToppersPossible']??"null");
    prefs.setString("cakeBasicCustom", cakeSearchList[index]['BasicCustomisationPossible']??"null");
    prefs.setString("cakeFullCustom", cakeSearchList[index]['FullCustomisationPossible']??"null");

    if(cakeType.toLowerCase()=="others" || cakeType.toLowerCase()=="customize your cake"){
      prefs.setString("cakeSubType","Normal Cakes"??"null");
      prefs.setString("cakeType", "Normal Cakes"??"null");
    }else{
      prefs.setString("cakeSubType",cakeType??"null");
      prefs.setString("cakeType", cakeType??"null");
    }

    prefs.setString("cakeDescription", cakeSearchList[index]['Description']??"null");
    prefs.setString("cakeCategory", cakeSearchList[index]['CakeCategory']??"null");
    prefs.setString("cakeTopperPoss", cakeSearchList[index]['ToppersPossible']??"null");

    prefs.setString("cakeVendorid", cakeSearchList[index]['VendorID']??"null");
    prefs.setString("cakeVendorModid", cakeSearchList[index]['Vendor_ID']??"null");
    prefs.setString("cakeVendorName", cakeSearchList[index]['VendorName']??"null");
    prefs.setString("cakeVendorPhone1", cakeSearchList[index]['VendorPhoneNumber1']??"null");
    prefs.setString("cakeVendorPhone2", cakeSearchList[index]['VendorPhoneNumber2']??"null");
    prefs.setString("cakeVendorAddress", vendorAddress);
    prefs.setString("cakeVendorLatitu", cakeSearchList[index]['GoogleLocation']['Latitude'].toString());
    prefs.setString("cakeVendorLongti", cakeSearchList[index]['GoogleLocation']['Longitude'].toString());
    prefs.setString("cakeOtherInstToCus", cakeSearchList[index]['OtherInstructions'].toString());


    // //3 and 5kg
    // if(cakeSearchList[index]['MinTimeForDeliveryOfA3KgCake']!=null&&
    //     cakeSearchList[index]['MinTimeForDeliveryOfA5KgCake']!=null){
    //   prefs.setString("cake3kgminTime", cakeSearchList[index]['MinTimeForDeliveryOfA3KgCake'].toString());
    //   prefs.setString("cake5kgminTime", cakeSearchList[index]['MinTimeForDeliveryOfA5KgCake'].toString());
    // }else{
    //   prefs.setString("cake3kgminTime", 'Nf');
    //   prefs.setString("cake5kgminTime", 'Nf');
    // }
    //
    // //1 and 2 kg
    // if(cakeSearchList[index]['MinTimeForDeliveryOfA3KgCake']!=null){
    //   prefs.setString("cake1kgminTime", cakeSearchList[index]['MinTimeForDeliveryOfA1KgCake'].toString());
    // }else{
    //   prefs.setString("cake1kgminTime", 'Nf');
    // }
    // //1 and 2 kg
    // if(cakeSearchList[index]['MinTimeForDeliveryOfA2KgCake']!=null){
    //   prefs.setString("cake2kgminTime", cakeSearchList[index]['MinTimeForDeliveryOfA2KgCake'].toString());
    // }else{
    //   prefs.setString("cake2kgminTime", 'Nf');
    // }

    prefs.setString("cakeminDelTime", cakeSearchList[index]['MinTimeForDeliveryOfDefaultCake'].toString());
    prefs.setString("cakeminbetwokgTime", cakeSearchList[index]['MinTimeForDeliveryOfABelow2KgCake'].toString());
    prefs.setString("cakemintwotoourTime", cakeSearchList[index]['MinTimeForDeliveryOfA2to4KgCake'].toString());
    prefs.setString("cakeminfortofivTime", cakeSearchList[index]['MinTimeForDeliveryOfA4to5KgCake'].toString());
    prefs.setString("cakeminabovfiveTime", cakeSearchList[index]['MinTimeForDeliveryOfAAbove5KgCake'].toString());


    //INTEGERS
    prefs.setInt('cakeDiscount', int.parse(cakeSearchList[index]['Discount'].toString()));
    prefs.setInt('cakeTax', int.parse(cakeSearchList[index]['Tax'].toString()));
    prefs.setInt('cakeDiscount', int.parse(cakeSearchList[index]['Discount'].toString()));
    prefs.setDouble("cakeRating",double.parse(cakeSearchList[index]['Ratings'].toString()));


    Navigator.of(context).push(PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => CakeDetails(
          cakeShapes,
          cakeFlavs,
          [],
          cakeTiers,
          tiersDelTimes,
          cakeSearchList[index]
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
    ));
  }

  //search by filters
  void searchByGivenFilter(String category, String subCategory,
      String vendorName, List filterCType) {

    print(category);
    print(subCategory);
    print(vendorName);
    print(filterCType);

    categoryList = [];
    subCategoryList = [];
    vendorNameList = [];
    cakeTypeList = [];
    activeSearch = true;

    List a = [], b = [], c = [], d = [];

    cakeTypeList = [];
    cakeSearchList = [];

    setState(() {
      if (category.isNotEmpty) {
        List a1 = otherProdList
            .where((element) => element['ProductName']
            .toString()
            .toLowerCase()
            .contains(category.toLowerCase()))
            .toList();

        a = cakesList
            .where((element) => element['CakeName']
                .toString()
                .toLowerCase()
                .contains(category.toLowerCase()))
            .toList();
        a = a + a1;
      }

      if (subCategory.isNotEmpty) {
        //CakeSubType
        setState((){
          isFiltered = true;
          for (int i = 0; i < cakesList.length; i++) {
              if(cakesList[i]['CakeSubType'].isNotEmpty && cakesList[i]['CakeSubType'].contains(subCategory)){
                b.add(cakesList[i]);
              }
          }
        });
      }

      if (vendorName.isNotEmpty) {
        setState(() {
          List a1 = otherProdList
              .where((element) => element['VendorName']
              .toString()
              .toLowerCase()
              .contains(vendorName.toLowerCase()))
              .toList();

          c = cakesList
              .where((element) => element['VendorName']
                  .toString()
                  .toLowerCase()
                  .contains(vendorName.toLowerCase()))
              .toList();
          c = c + a1;
        });
      }

      if(filterCType.contains("Others")){
        isFiltered = true;
        activeSearch = true;
        d = otherProdList.toSet().toList();
      }

      if (filterCType.isNotEmpty) {
        isFiltered = true;
        for (int i = 0; i < cakesList.length; i++) {
          if (cakesList[i]['CakeType'].isNotEmpty || cakesList[i]['CakeSubType'].isNotEmpty) {
            for (int j = 0; j < filterCType.length; j++) {
              if (cakesList[i]['CakeType'].contains(filterCType[j]) ||
                  cakesList[i]['CakeSubType'].contains(filterCType[j])) {
                d.add(cakesList[i]);
              }
            }
          }
        }
      }

      isFiltered = true;
      activeSearch = true;
      cakeSearchList = a + b + c + d.toList();
      cakeSearchList = cakeSearchList.toSet().toList();

      print(cakeSearchList.length);
      print(otherProdList.length);

      mainSearchCtrl.text = '$category $subCategory '
          '$vendorName ${filterCType.toString().replaceAll("[", "").replaceAll("]", "")}';
    });
  }

  //clr
  void activeSearchClear() {
    FocusScope.of(context).unfocus();
    setState(() {
      isFiltered = false;
      activeSearch = false;
      mainSearchCtrl.text = "";
      searchText = "";
      searchCakeVendor = '';
      searchCakeSubType = '';
      searchCakeCate = '';
      cakeCategoryCtrl.text = '';
      cakeSubCategoryCtrl.text = '';
      cakeVendorCtrl.text = '';
      selectedFilter.clear();
      cakeSearchList.clear();
    });
  }

  //send nearest vendor details.
  Future<void> sendNearVendorDataToScreen(int index , [String amount="0.0", String km = "0.0"]) async {
    // var pref = await SharedPreferences.getInstance();
    //
    // print(amount);
    // print(km);
    //
    // pref.remove('singleVendorID');
    // pref.remove('firstVenDelCharge');
    // pref.remove('firstVenIndex');
    // pref.remove('singleVendorFromCd');
    // pref.remove('singleVendorRate');
    // pref.remove('singleVendorName');
    // pref.remove('singleVendorDesc');
    // pref.remove('singleVendorPhone1');
    // pref.remove('singleVendorPhone2');
    // pref.remove('singleVendorDpImage');
    // pref.remove('singleVendorAddress');
    // pref.remove('singleVendorSpeciality');
    //
    // //store 1st two vendor deliver charge
    // if(index == 0 && double.parse(km)<2.0 || index == 1 && double.parse(km)<2.0){
    //   amount = "0.0";
    //   pref.setString('firstVenDelCharge', amount ?? 'null');
    //   pref.setString('firstVenIndex', index.toString() ?? 'null');
    // }else{
    //   pref.setString('firstVenDelCharge', amount ?? 'null');
    //   pref.setString('firstVenIndex', "2" ?? 'null');
    // }
    //
    // //common keyword single****
    // pref.setString('singleVendorID', nearestVendors[index]['_id'] ?? 'null');
    // pref.setBool('singleVendorFromCd', false);
    // pref.setString('singleVendorRate',
    //     nearestVendors[index]['Ratings'].toString() ?? '0.0');
    // pref.setString('singleVendorName',
    //     nearestVendors[index]['PreferredNameOnTheApp'] ?? 'null');
    // pref.setString(
    //     'singleVendorDesc', nearestVendors[index]['Description'] ?? 'null');
    // pref.setString(
    //     'singleVendorPhone1', nearestVendors[index]['PhoneNumber1'] ?? 'null');
    // pref.setString(
    //     'singleVendorPhone2', nearestVendors[index]['PhoneNumber2'] ?? 'null');
    // pref.setString(
    //     'singleVendorDpImage', nearestVendors[index]['ProfileImage'] ?? 'null');
    // pref.setString(
    //     'singleVendorAddress', nearestVendors[index]['Address'] ?? 'null');
    // pref.setString('singleVendorSpecial',
    //     nearestVendors[index]['YourSpecialityCakes'].toString());
    //
    // print(nearestVendors[index]['YourSpecialityCakes']);
    //
    // Navigator.push(
    //     context, MaterialPageRoute(builder: (context) => SingleVendor()));
    var pref = await SharedPreferences.getInstance();

    pref.setString('myVendorId', nearestVendors[index]['_id']);
    pref.setStringList('activeVendorsIds',[nearestVendors[index]['_id'].toString()]);
    // pref.setString('myVendorName', nearestVendors[index]['VendorName']);
    // pref.setString('myVendorPhone', nearestVendors[index]['VendorPhoneNumber1']);
    // pref.setString('myVendorDesc', nearestVendors[index]['']);
    // pref.setString('myVendorProfile', nearestVendors[index]['_id']);
    // pref.setString('myVendorDeliverChrg', nearestVendors[index]['_id']);
    // pref.setString('myVendorAddress', nearestVendors[index]['_id']);
    // pref.setString('myVendorEggs', nearestVendors[index]['_id']);

    pref.setBool('iamYourVendor', true);
    pref.setBool('vendorCakeMode',true);

    context.read<ContextData>().addMyVendor(true);
    context.read<ContextData>().setMyVendors([
      nearestVendors[index]
    ]);

    Navigator.push(context, MaterialPageRoute(builder: (context)=>CakeTypes()));

  }

  //getting prefes
  Future<void> loadPrefs() async {
    var prefs = await SharedPreferences.getInstance();
    setState(() {
      authToken = prefs.getString("authToken") ?? 'no auth';
      profileRemainder = prefs.getBool("profileUpdated") ?? false;
      phoneNumber = prefs.getString("phoneNumber") ?? "";
      newRegUser = prefs.getBool("newRegUser") ?? false;

      fetchProfileByPhn();
      //getotherProdList();
      //_getUserLocation();
      getAdminDeliveryCharge();
    });

    timerTrigger();
  }

  //update profile timer dialog for new users
  void timerTrigger() {
    if (newRegUser == true) {
      setState(() {
        Timer(Duration(seconds: 5), () {
          //showDpUpdtaeDialog();
          ProfileAlert().showProfileAlert(context);
        });
      });
    } else {}
  }

  //Fetching user details from API....
  Future<void> fetchProfileByPhn() async {

    setState((){
      isAllLoading = true;
    });

    var prefs = await SharedPreferences.getInstance();
    try {
      http.Response response = await http.get(
          Uri.parse("http://sugitechnologies.com/cakey/api/users/list/"
              "${int.parse(phoneNumber)}"),
          headers: {"Authorization": "$authToken"});
      if (response.statusCode == 200) {
        // Navigator.pop(context);
        setState(() {
          List body = jsonDecode(response.body);

          userID = body[0]['_id'].toString();
          userAddress = body[0]['Address'].toString();
          userProfileUrl = body[0]['ProfileImage'].toString();
          String token = body[0]['Notification_Id'].toString();
          context.read<ContextData>().setProfileUrl(userProfileUrl);
          userName = body[0]['UserName'].toString();

          if (userName == "null" ||
              userName == null ||
              userAddress == "null" ||
              userAddress == null) {
            prefs.setBool('newRegUser', true);
          }
          prefs.setString('userID', userID);
          prefs.setString('userModId', body[0]['Id'].toString());
          prefs.setString('userAddress', userAddress);
          prefs.setString('userName', userName);

          context.read<ContextData>().setUserName(userName);
        });

      } else {
        checkNetwork();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'Code : ${response.statusCode}\nMsg : ${response.reasonPhrase}'),
          backgroundColor: Colors.amber,
          action: SnackBarAction(
            label: "Retry",
            onPressed: () => setState(() {
              loadPrefs();
            }),
          ),
        ));
        Navigator.pop(context);
      }
    } on Exception catch (e) {
      Navigator.pop(context);
      checkNetwork();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error Occurred'),
        backgroundColor: Colors.amber,
        duration: Duration(seconds: 5),
        action: SnackBarAction(
          label: "Retry",
          onPressed: () => setState(() {
            loadPrefs();
          }),
        ),
      ));
    }

    getFbToken();
  }

  Future<void> getFbToken() async {
    await FirebaseMessaging.instance.getToken().then((value) => {
          setState(() {
            updateVendorsFbId(value!);
          }),
    });
    getOrderList();
  }

  Future<void> updateVendorsFbId(String token) async {

    print('fb tok...$token');

    var request = http.MultipartRequest(
        'PUT',
        Uri.parse(
            'http://sugitechnologies.com/cakey/api/users/update/$userID'));
    request.headers['Content-Type'] = 'multipart/form-data';
    request.fields.addAll({'Notification_Id': '$token'});

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());

      print("Token Fetched.");
      // Navigator.pop(context);
    } else {
      print("Token Fetch Error.");
      // Navigator.pop(context);
    }
  }

  //getting vendor address
  Future<void> GetAddressFromLatLong(double? lat, double? long) async {
    var prefs = await SharedPreferences.getInstance();

    placemarks = await geocode.placemarkFromCoordinates(lat!, long!);

    // List<geocode.Location> latLong = await geocode
    //     .locationFromAddress("Street No.10,Coimbatore,Coimbatore,641107");

    geocode.Placemark place = placemarks[0];
    print("Placemarks...");
    print(placemarks[0]);

    setState(() {
      latude = lat;
      longtude = long;
      prefs.setString('userLatitute', "${latude.toString()}");
      prefs.setString('userLongtitude', "${longtude.toString()}");
      var locationAddress = placemarks[0].subLocality.toString()+","+placemarks[0].locality.toString()+","+placemarks[0].administrativeArea.toString()+","
      +placemarks[0].postalCode.toString()+","+placemarks[0].country.toString();
      if (place.subLocality.toString().isEmpty) {
        userLocalityAdr = '${place.locality}';
      } else {
        userLocalityAdr = '${place.subLocality}';
      }
      userMainLocation = '${place.locality}';
      prefs.setString("userCurrentLocation", userLocalityAdr);
      prefs.setString("userMainLocation", place.locality.toString());
    });
  }

  //Distance calculator
  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  //fetch others..
  Future<void> getotherProdList() async{

    var headers = {
      'Authorization': '$authToken'
    };

    otherProdList.clear();

    try{

      var request = http.Request('GET',
          Uri.parse('http://sugitechnologies.com/cakey/api/otherproduct/activevendors/list'));

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        var map = jsonDecode(await response.stream.bytesToString());

        print("map .... $map");

        setState((){
          // otherProdList = map
          //     .where((element) =>
          // calculateDistance(
          //     userLat,
          //     userLong,
          //     element['GoogleLocation']['Latitude'],
          //     element['GoogleLocation']['Longitude']) <=
          //     10)
          //     .toList();

          if(activeVendorsIds.isNotEmpty){
            for(int i = 0;i<activeVendorsIds.length;i++){
              otherProdList = otherProdList+map.where((element) => element['VendorID'].toString().toLowerCase()==
                  activeVendorsIds[i].toLowerCase()).toList();
            }
          }

          otherProdList = otherProdList.toSet().toList();

        });

        print("otherProdList.length");
        print(otherProdList.length);

      }
      else {
        print(response.reasonPhrase);
      }
    }catch(e){
      print(e);
    }

    getHampers();
  }

  //fetch cake types
  Future<void> getCakeType() async {

    try{
      var mainList = [];
      List subType = [];

      var headers = {'Authorization': '$authToken'};
      var request = http.Request('GET',
          Uri.parse('http://sugitechnologies.com/cakey/api/caketype/list'));

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        searchCakeType.clear();
        mainList = jsonDecode(await response.stream.bytesToString());
        setState(() {
          print("CAKE TYPES : " + mainList.toString());
          searchCakeType.add(
              {"name":"Customize your cake"}
          );
          searchCakeType.add(
              {"name":"Others"}
          );
          if (mainList.length!=0) {
            for (int i = 0; i < mainList.length; i++) {

              if (mainList[i]['Type'] != null) {
                searchCakeType.add(
                    {
                      "name":mainList[i]['Type'].toString(),
                      "image":mainList[i]['Type_Image'].toString(),
                    }
                );
              }

              if(mainList[i]['SubType']!=null&&mainList[i]['SubType'].isNotEmpty){
                for(int k = 0 ; k<mainList[i]['SubType'].length;k++){
                  print(mainList[i]['SubType'][k]);
                  searchCakeType.add(
                      {
                        "name":mainList[i]['SubType'][k]['Name'].toString(),
                        "image":mainList[i]['SubType'][k]['SubType_Image'].toString(),
                      }
                  );
                }
              }

            }
          }

          print('Sub types>>>> $searchCakeType');
          // searchCakeType.add("Others");
          // searchCakeType.add("Customize your cake");
          // searchCakeType = searchCakeType.map((e)=>e.toString().toLowerCase()).toSet().toList();
          searchCakeType.toSet().toList();
          //searchCakeType = searchCakeType.reversed.toList();


          setState((){
            isAllLoading = false;
          });


        });
      }
      else {
        print(response.reasonPhrase);
        setState((){
          searchCakeType.clear();
          searchCakeType.add(
              {"name":"Customize your cake"}
          );
          searchCakeType.toSet().toList();
          searchCakeType = searchCakeType.reversed.toList();
        });
        setState((){
          isAllLoading = false;
        });
      }
    }catch(e){
      setState((){
        isAllLoading = false;
      });
    }

  }

  //Fetching cake list API...
  Future<void> getCakeList() async {
    cakesList.clear();
    searchCakeType.clear();
    setState(() {
      isAllLoading = true;
    });
    try {
      http.Response response = await http.get(
          Uri.parse("http://sugitechnologies.com/cakey/api/cakes/activevendors/list"),
          headers: {"Authorization": "$authToken"});
      if (response.statusCode == 200) {
        if (response.body.length < 50) {
          setState(() {
            isAllLoading = false;
          });
        } else {
          setState(() {
            isNetworkError = false;
            List myList = jsonDecode(response.body);

            if(activeVendorsIds.isNotEmpty){
              for(int i = 0;i<activeVendorsIds.length;i++){
                cakesList = cakesList+myList.where((element) => element['VendorID'].toString().toLowerCase()==
                activeVendorsIds[i].toLowerCase()).toList();
              }
            }

            cakesList.toSet().toList();
            cakesList.sort((a,b)=>a['CakeName'].toString().compareTo(b['CakeName'].toString()));

            isAllLoading = false;
          });
        }
      } else {
        setState(() {
          isNetworkError = true;
          networkMsg = "Server error! try again latter";
          isAllLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        isNetworkError = true;
        isAllLoading = false;
      });
    }

    getCakeType();
    getotherProdList();
  }

  //getting recent orders list by UserId
  Future<void> getOrderList() async {

    print("entering order");

    recentOrders.clear();
    setState(() {
      ordersLoading = true;
    });
    try {
      http.Response response = await http.get(
          Uri.parse(
              "http://sugitechnologies.com/cakey/api/ordersandhamperorders/listbyuser/$userID"),
          headers: {"Authorization": "$authToken"}
      );
      if (response.statusCode == 200) {

        print(response.body);

        print("con length");
        print(response.contentLength);

          setState(() {
            isNetworkError = false;
            ordersLoading = false;
            recentOrders = jsonDecode(response.body);
          });

        print(recentOrders.length);

      } else {

        setState(() {
          // isNetworkError = true;
          ordersLoading = false;
        });

      }
    } catch (error) {
      print(error);
      setState(() {
        isNetworkError = true;
        ordersLoading = false;
      });

    }
  }

  //fetchlocation lat long
  Future<void> _getUserLocation() async {
    var pref = await SharedPreferences.getInstance();
    // Check if permission is granted
    _permissionGranted = await myLocation.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await myLocation.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        _permissionGranted = await myLocation.requestPermission();
      }
    }

    myLocation.changeSettings(accuracy: LocationAccuracy.high);

    // Check if location service is enable
    _serviceEnabled = await myLocation.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await myLocation.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    final _locationData = await myLocation.getLocation();

    setState(() {
      _userLocation = _locationData;
      userLat = double.parse(_userLocation!.latitude.toString());
      userLong = double.parse(_userLocation!.longitude.toString());
    });

    pref.setString('userLatitute', "${_userLocation!.latitude}");
    pref.setString('userLongtitude', "${_userLocation!.longitude}");

    print('start location : $userLat , $userLong');

    GetAddressFromLatLong(userLat, userLong);
    getVendorsList(authToken);
  }

  Future<void> getLocationBasedOnAddress(String address) async {
    var pref = await SharedPreferences.getInstance();
    try{
      if (address.isNotEmpty) {
        List<geocode.Location> location =
        await geocode.locationFromAddress(address);
        print(location[0]);
        setState(() {
          userLat = location[0].latitude;
          userLong = location[0].longitude;
          // pref.setString(
          //     'userLatitute', "${userLat}");
          // pref.setString('userLongtitude',
          //     "${userLong}");
          // pref.setString(
          //     "userCurrentLocation",
          //     predictedAddress);
          // userLocalityAdr =
          //     predictedAddress;
          GetAddressFromLatLong(userLat, userLong);
          getVendorForDeliveryto(authToken);
          //getHampers();
          getCakeList();
          getCakeType();
          //getotherProdList();
        });
      }
      else{
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Unable to get location details..."))
        );
      }
    }catch(e){

    }

    GetAddressFromLatLong(userLat, userLong);
    getVendorsList(authToken);
  }

  Future<void> getVendorForDeliveryto(String token) async {
    activeVendorsIds.clear();
    showAlertDialog();
    print("location....");
    print("getting vendors....");
    filteredByEggList.clear();
    try {
      var res = await http.get(
          Uri.parse("http://sugitechnologies.com/cakey/api/activevendors/list"),
          headers: {"Authorization": "$token"});

      if (res.statusCode == 200) {
        setState(() {
          vendorsList = jsonDecode(res.body);

          filteredByEggList = vendorsList
              .where((element) =>
                  calculateDistance(
                      userLat,
                      userLong,
                      element['GoogleLocation']['Latitude'],
                      element['GoogleLocation']['Longitude']) <=
                  10)
              .toList();

          // filteredByEggList = vendorsList.where((element)=>element['Address']['City'].toString().toLowerCase().
          // contains(userMainLocation.toLowerCase())).toList();

          filteredByEggList = filteredByEggList.toSet().toList();

          filteredByEggList.sort((a,b)=>calculateDistance(
              userLat,
              userLong,
              a['GoogleLocation']['Latitude'],
              a['GoogleLocation']['Longitude']).toStringAsFixed(1).compareTo(calculateDistance(
              userLat,
              userLong,
              b['GoogleLocation']['Latitude'],
              b['GoogleLocation']['Longitude']).toStringAsFixed(1)));

          if(filteredByEggList.isNotEmpty){
            for(int i = 0 ; i<filteredByEggList.length;i++){
              activeVendorsIds.add(filteredByEggList[i]['_id'].toString());
            }
          }

          print("-----");
          print(activeVendorsIds);
          print(filteredByEggList.length);

          Navigator.pop(context);
          // getNearbyLoc();
        });
      } else {
        print("Error code : ${res.statusCode}");
        Navigator.pop(context);
      }
    } catch (e) {
      print(e);
      Navigator.pop(context);
    }
    print("getting vendors....done...");
  }

  //Get vendors list
  Future<void> getVendorsList(String token) async {
    print("getting vendors....");
    filteredByEggList.clear();
    activeVendorsIds.clear();
    try {
      var res = await http.get(
          Uri.parse("http://sugitechnologies.com/cakey/api/activevendors/list"),
          headers: {"Authorization": "$token"});

      if (res.statusCode == 200) {
        setState(() {
          vendorsList = jsonDecode(res.body);

          print(vendorsList);

          filteredByEggList = vendorsList
              .where((element) =>
                  calculateDistance(
                      userLat,
                      userLong,
                      element['GoogleLocation']['Latitude'],
                      element['GoogleLocation']['Longitude']) <=
                  10)
              .toList();

          filteredByEggList = filteredByEggList.toSet().toList();

          if(filteredByEggList.isNotEmpty){
            for(int i = 0 ; i<filteredByEggList.length;i++){
              activeVendorsIds.add(filteredByEggList[i]['_id'].toString());
            }
          }

          filteredByEggList.sort((a,b)=>calculateDistance(
              userLat,
              userLong,
              a['GoogleLocation']['Latitude'],
              a['GoogleLocation']['Longitude']).toStringAsFixed(1).compareTo(calculateDistance(
              userLat,
              userLong,
              b['GoogleLocation']['Latitude'],
              b['GoogleLocation']['Longitude']).toStringAsFixed(1)));


          print("-----");
          print(activeVendorsIds);
          print(filteredByEggList.length);

        });
      } else {
        print("Error code : ${res.statusCode}");
      }
    } catch (e) {
      print(e);
    }
    print("getting vendors....done...");


    getCakeList();
  }

  //get Ads Banners
  Future<void> getHampers() async {
    hampers.clear();
    try{
      var headers = {
        'Authorization': '$authToken'
      };
      var request = http.Request('GET', Uri.parse('http://sugitechnologies.com/cakey/api/hamper/approvedlist'));

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        List map = jsonDecode(await response.stream.bytesToString());

        print(map);

        setState((){

          // hampers = map;

          // hampers = map.where((element) =>
          // calculateDistance(
          //     userLat,
          //     userLong,
          //     element['GoogleLocation']['Latitude'],
          //     element['GoogleLocation']['Longitude']) <=
          //     10)
          //     .toList();

          if(activeVendorsIds.isNotEmpty){
            for(int i = 0;i<activeVendorsIds.length;i++){
              hampers = hampers+map.where((element) => element['VendorID'].toString().toLowerCase()==
                  activeVendorsIds[i].toLowerCase()).toList();
            }
          }

          hampers = hampers.toSet().toList();

          print("hamper length....${hampers.length}");

        });

      }
      else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error : "+response.reasonPhrase.toString()))
        );
      }
    }catch(e){
      print(e);
    }

    //fetch noti
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    var list = [];
    try {
      var res = await http.get(Uri.parse(
          "http://sugitechnologies.com/cakey/api/users/notification/$userID"),
          headers: {"Authorization":"$authToken"});
      print(res.statusCode);
      if (res.statusCode == 200) {
        list = jsonDecode(res.body);
        setState(() {
          notiCount = list.length;
        });
      }else{
        setState(() {
          notiCount = 0;
        });
      }
    } catch (e) {
      print(e);
      setState((){
        notiCount = 0;
      });
    }

    context.read<ContextData>().setNotiCount(notiCount);

  }

  //network check
  Future<void> checkNetwork() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('connected');
      }
    } on SocketException catch (_) {
      NetworkDialog().showNoNetworkAlert(context);
      print('not  connected');
    }
  }

  //get admins delivery fee
  Future<void> getAdminDeliveryCharge() async {
    var pref = await SharedPreferences.getInstance();

    try{

      var headers = {'Authorization': '$authToken'};
      var request = http.Request('GET',
          Uri.parse('http://sugitechnologies.com/cakey/api/deliverycharge/list'));

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        var map = jsonDecode(await response.stream.bytesToString());

        if(map.toString().length>27){

          print("map");
          print(map.toString().length);

          print(map[0]["Amount"]);
          print(map[0]["Km"]);

          setState(() {
            deliveryChargeFromAdmin = int.parse(map[0]["Amount"].toString());
            deliverykmFromAdmin = int.parse(map[0]["Km"].toString());

            pref.setInt("todayDeliveryCharge", deliveryChargeFromAdmin);
            pref.setInt("todayDeliveryKm", deliverykmFromAdmin);
          });
        }else{
          setState((){
            deliveryChargeFromAdmin = 0;
            deliverykmFromAdmin = 1;

            pref.setInt("todayDeliveryCharge", deliveryChargeFromAdmin);
            pref.setInt("todayDeliveryKm", deliverykmFromAdmin);
          });
        }

      } else {
        print(response.reasonPhrase);
      }
    }catch(e){
      setState((){
        deliveryChargeFromAdmin = 0;
        deliverykmFromAdmin = 0;

        pref.setInt("todayDeliveryCharge", deliveryChargeFromAdmin);
        pref.setInt("todayDeliveryKm", deliverykmFromAdmin);
      });
    }

  }

  Future<void> getCoordinates(String predictedAddress) async{

    var pref = await SharedPreferences.getInstance();

    print("Getting data...");

    try{
      if (predictedAddress.isNotEmpty) {
        List<geocode.Location> location =
        await geocode.locationFromAddress(predictedAddress);
        print(location[0]);
        setState(() {
          userLat = location[0].latitude;
          userLong = location[0].longitude;
          // pref.setString(
          //     'userLatitute', "${userLat}");
          // pref.setString('userLongtitude',
          //     "${userLong}");
          // pref.setString(
          //     "userCurrentLocation",
          //     predictedAddress);
          // userLocalityAdr =
          //     predictedAddress;
          GetAddressFromLatLong(userLat, userLong);
          getVendorForDeliveryto(authToken);
          //getHampers();
          getCakeList();
          getCakeType();
          //getotherProdList();
        });
      }
      else{
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Unable to get location details..."))
        );
      }

    }catch(e){
      print("Coor error : $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Unable to get location details..."))
      );
    }

  }

  //send others
  Future<void> sendOthers(String id) async{

    int index = otherProdList.indexWhere((element) => element['_id'].toString()==id);

    var prefs = await SharedPreferences.getInstance();
    List weight = [];
    List<String> flavs = [];
    List<String> images = [];

    //add flav
    for(int i = 0 ;i<otherProdList[index]['Flavour'].length;i++){
      flavs.add(otherProdList[index]['Flavour'][i].toString());
    }

    if(otherProdList[index]['AdditionalProductImages']!=null||otherProdList[index]['AdditionalProductImages'].isNotEmpty){
      for(int j = 0;j<otherProdList[index]['AdditionalProductImages'].length;j++){
        images.add(otherProdList[index]['AdditionalProductImages'][j].toString());
      }
    }

    //add images
    for(int i = 0 ;i<otherProdList[index]['ProductImage'].length;i++){
      images.add(otherProdList[index]['ProductImage'][i].toString());
    }

    if(otherProdList[index]['Type'].toString().toLowerCase()=="kg"){
      weight = [otherProdList[index]['MinWeightPerKg']];
    }else if(otherProdList[index]['Type'].toString().toLowerCase()=="unit"){
      weight = otherProdList[index]['MinWeightPerUnit'];
    }else{
      weight = otherProdList[index]['MinWeightPerBox'];
    }


    prefs.setString("otherName" , otherProdList[index]['ProductName'].toString());

    if(otherProdList[index]['Shape']!=null){
      prefs.setString("otherShape" , otherProdList[index]['Shape'].toString());
    } else{
      prefs.setString("otherShape" , "None");
    }

    prefs.setString("otherSubType" , otherProdList[index]['CakeSubType'].toString());
    prefs.setString("otherMainId" , otherProdList[index]['_id'].toString());
    prefs.setString("otherModID" , otherProdList[index]['Id'].toString());
    prefs.setString("otherDiscound" , otherProdList[index]['Discount'].toString());
    prefs.setString("otherComName" , otherProdList[index]['ProductCommonName'].toString());
    prefs.setString("otherVendorId" , otherProdList[index]['VendorID'].toString());
    prefs.setString("otherType" , otherProdList[index]['Type'].toString());
    prefs.setString("otherEggOr" , otherProdList[index]['EggOrEggless'].toString());
    prefs.setString("otherMinDel" , otherProdList[index]['MinTimeForDelivery'].toString());
    prefs.setString("otherBestUse" , otherProdList[index]['BestUsedBefore'].toString());
    prefs.setString("otherStoredIn" , otherProdList[index]['ToBeStoredIn'].toString()??"");
    // prefs.setString("otherKeepInRoom" , otherProdList[index]['KeepTheCakeInRoomTemperature'].toString());
    prefs.setString("otherDescrip" , otherProdList[index]['Description'].toString());
    prefs.setString("otherRatings" , otherProdList[index]['Ratings'].toString());
    prefs.setString("otherVendorAddress" , otherProdList[index]['VendorAddress']);
    prefs.setString("otherVenMainId" , otherProdList[index]['VendorID']);
    prefs.setString("otherVenModId" , otherProdList[index]['Vendor_ID']);
    prefs.setString("otherVenName" , otherProdList[index]['VendorName']);
    prefs.setString("otherVenPhn1" , otherProdList[index]['VendorPhoneNumber1']);
    prefs.setString("otherVenPhn2" , otherProdList[index]['VendorPhoneNumber2']??"");

    if(otherProdList[index]['MinTimeForDelivery']!=null){
      prefs.setString("otherMiniDeliTime" , otherProdList[index]['MinTimeForDelivery']);
    }else{
      prefs.setString("otherMiniDeliTime" ,"1days");
    }

    prefs.setStringList("otherFlavs" , flavs);
    prefs.setStringList("otherImages" , images);

    Navigator.of(context).push(PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => OthersDetails(
        weight: weight,
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
    ));
  }

  //location permission checker
  Future<void> checkLocationPermission() async{

    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    var permiStatus = await Handler.Permission.location.status;
    if(permiStatus.isGranted){
      print("Location is granted...");
      loadPrefs();
      _getUserLocation();
    }
    else if(permiStatus.isDenied){
      showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          isDismissible: false,
          builder: (c){
            return StatefulBuilder(
              builder: (ctx,setState){
                return SafeArea(
                  child: Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage("assets/images/splash.png"),
                            fit: BoxFit.cover
                        )
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Row(
                        //   children: [
                        //     Expanded(child: Container()),
                        //     IconButton(
                        //         onPressed: (){
                        //           Navigator.pop(context);
                        //         },
                        //         icon: Icon(Icons.close)
                        //     ),
                        //   ],
                        // )
                        Icon(Icons.my_location_rounded,size: 60,color:lightPink,),
                        SizedBox(height: 15,),
                        Text("To get better service please allow location permission.",style: TextStyle(
                            fontFamily: "Poppins",
                            fontWeight: FontWeight.bold,
                            fontSize: 16
                        ),textAlign: TextAlign.center,),
                        SizedBox(height: 15,),
                        GestureDetector(
                          onTap: () async{
                            print("Location is not granted...");
                            Map<Handler.Permission, Handler.PermissionStatus> statuses = await [
                              Handler.Permission.location
                            ].request();
                            var permiStatus = await Handler.Permission.location.status;
                            if(permiStatus.isGranted){
                              Navigator.pop(context);
                              print("Location is granted...");
                              loadPrefs();
                              _getUserLocation();
                            }else{

                            }
                          },
                          child: Container(
                            height:height*0.06,
                            width:width*0.6,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                color: Colors.pink,
                                borderRadius: BorderRadius.circular(20)
                            ),
                            child: Text("Allow Location Permission",style: TextStyle(
                                fontFamily: "Poppins",
                                fontWeight: FontWeight.bold,
                                color:Colors.white
                            ),),
                          ),
                        ),
                        // SizedBox(height: 20,),
                        // Row(
                        //   children: [
                        //     Expanded(child: Container(
                        //       height:height*0.001,
                        //       color:Colors.grey,
                        //       margin: EdgeInsets.only(right: 5),
                        //     )),
                        //     Text(" OR ",style: TextStyle(
                        //         fontFamily: "Poppins",
                        //         fontWeight: FontWeight.bold,
                        //         fontSize: 16
                        //     ),),
                        //     Expanded(child: Container(
                        //       height:height*0.001,
                        //       color:Colors.grey,
                        //       margin: EdgeInsets.only(left: 5),
                        //     )),
                        //   ],
                        // ),
                        // SizedBox(height: 15,),
                        // Text("",style: TextStyle(
                        //     fontFamily: "Poppins",
                        //     fontWeight: FontWeight.bold,
                        //     fontSize: 16
                        // ),),
                        SizedBox(height: 15,),
                        GestureDetector(
                          onTap:() async{
                            SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                          },
                          child: Container(
                            height:height*0.06,
                            width:width*0.4,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                color: darkBlue,
                                borderRadius: BorderRadius.circular(20)
                            ),
                            child: Text("Cancel",style: TextStyle(
                                fontFamily: "Poppins",
                                fontWeight: FontWeight.bold,
                                color:Colors.white
                            ),),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
      );
    }
    else if(permiStatus.isPermanentlyDenied){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content:Text("Permission is denied,please allow manually, Go to Settings->Apps->Cakey->Permissions->Location."))
      );
    }
  }

  //endregion

  @override
  void dispose() {
    Future.delayed(Duration.zero, () async {
      var pr = await SharedPreferences.getInstance();
      pr.remove('activeVendorsIds');
      // pr.remove('vendorCakeMode');
      // pr.remove('naveToHome');
    });
    super.dispose();
  }


  //onStart
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration.zero, () async {
      var pr = await SharedPreferences.getInstance();
      if(pr.getString('showMoreVendor')!=null&&pr.getString('showMoreVendor')!="null"){
        var addr = pr.getString('showMoreVendor')??'';
        authToken = pr.getString("authToken") ?? 'no auth';
        getLocationBasedOnAddress(addr);
        loadPrefs();
        //getCoordinates("Thekkalur ,Avinashi , Tiruppur , 641654");
      }else{
        checkLocationPermission();
      }
      //loadPrefs();
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    profileUrl = context.watch<ContextData>().getProfileUrl();
    notiCount = context.watch<ContextData>().getNotiCount();

    //searching..
    if (searchText.isNotEmpty) {

      List sub = otherProdList
          .where((element) => element["ProductName"]
          .toString()
          .toLowerCase()
          .contains(searchText.toLowerCase()))
          .toList();

      cakeSearchList = sub + cakesList
          .where((element) => element["CakeName"]
              .toString()
              .toLowerCase()
              .contains(searchText.toLowerCase()))
          .toList();

      activeSearch = true;
      isFiltered = true;

    } else if (activeSearch == true && cakeSearchList.isNotEmpty) {
      activeSearch = true;
      isFiltered = true;
    } else if (activeSearch == true && cakeSearchList.isEmpty) {
      activeSearch = true;
      isFiltered = true;
    } else {
      activeSearch = false;
      isFiltered = false;
      cakeSearchList.clear();
    }

    //egg or eggless...
    if (egglesSwitch == false) {
      setState(() {
        nearestVendors = filteredByEggList;
      });
    } else {
      setState(() {
        nearestVendors = filteredByEggList
            .where((element) =>
                element['EggOrEggless'] == 'Eggless' ||
                element['EggOrEggless'] == "Egg and Eggless")
            .toList();
      });
    }

    return WillPopScope(
      onWillPop: () async {
        if(activeSearch==true){
          activeSearchClear();
          return Future.value(false);
        }else{
          showDialog(
              context: context,
              builder: (context)=>
                  AlertDialog(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)
                    ),
                    title: Text("Exit Alert" , style: TextStyle(
                        color: darkBlue , fontFamily: "Poppins",
                        fontWeight: FontWeight.bold
                    ),),
                    content:Text(
                        "Are you sure? do you want to exit?", style: TextStyle(
                      color: Colors.black , fontFamily: "Poppins",
                    )
                    ),
                    actions: [
                      FlatButton(
                        onPressed: (){
                          Navigator.pop(context);
                          Future.value(false);
                        },
                        child: Text('Cancel', style: TextStyle(
                          color: Colors.purple , fontFamily: "Poppins",
                        )),
                      ),
                      FlatButton(
                        onPressed: (){
                          SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                          Future.value(true);
                        },
                        child: Text('Exit', style: TextStyle(
                          color: Colors.purple , fontFamily: "Poppins",
                        )),
                      ),
                    ],
                  )
          );

        }
        return Future.value(true);
      },
      child: Scaffold(
        drawer: NavDrawer(screenName: "home"),
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: SafeArea(
            child: Container(
              padding: EdgeInsets.only(left: 15, right: 15),
              color: lightGrey,
              height: 50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () async{
                          var prefs = await SharedPreferences.getInstance();
                          prefs.setStringList('activeVendorsIds',activeVendorsIds);
                          FocusScope.of(context).unfocus();
                          _scaffoldKey.currentState!.openDrawer();
                        },
                        child: Container(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    radius: 5.2,
                                    backgroundColor: darkBlue,
                                  ),
                                  SizedBox(
                                    width: 3,
                                  ),
                                  CircleAvatar(
                                    radius: 5.2,
                                    backgroundColor: darkBlue,
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 3,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                      radius: 5.2, backgroundColor: darkBlue),
                                  SizedBox(
                                    width: 3,
                                  ),
                                  CircleAvatar(
                                    radius: 5.2,
                                    backgroundColor: Colors.red,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      Text("HOME",
                          style: TextStyle(
                              color: darkBlue,
                              fontWeight: FontWeight.bold,
                              fontFamily: poppins,
                              fontSize: 18)),
                    ],
                  ),
                  CustomAppBars().CustomAppBar(context, "", notiCount, profileUrl)
                  // Row(
                  //   children: [
                  //     Stack(
                  //       alignment: Alignment.center,
                  //       children: [
                  //         InkWell(
                  //           onTap: () {
                  //             Navigator.of(context).push(
                  //               PageRouteBuilder(
                  //                 pageBuilder: (context, animation,
                  //                         secondaryAnimation) =>
                  //                     Notifications(),
                  //                 transitionsBuilder: (context, animation,
                  //                     secondaryAnimation, child) {
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
                  //                 color: Colors.grey[300],
                  //                 borderRadius: BorderRadius.circular(6)),
                  //             child: Icon(
                  //               Icons.notifications_none,
                  //               color: darkBlue,
                  //               size: 22,
                  //             ),
                  //           ),
                  //         ),
                  //         notiCount>0?
                  //         Positioned(
                  //           left: 15,
                  //           top: 6,
                  //           child: CircleAvatar(
                  //             radius: 3.7,
                  //             backgroundColor: Colors.white,
                  //             child: CircleAvatar(
                  //               radius: 2.7,
                  //               backgroundColor: Colors.red,
                  //             ),
                  //           ),
                  //         ):Positioned(
                  //           left: 15,
                  //           top: 6,
                  //           child: Container(height: 0,width: 0,),
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
                  //           BoxShadow(
                  //               blurRadius: 3,
                  //               color: Colors.black,
                  //               spreadRadius: 0)
                  //         ],
                  //       ),
                  //       child: InkWell(
                  //         onTap: () {
                  //           Navigator.of(context).push(
                  //             PageRouteBuilder(
                  //               pageBuilder:
                  //                   (context, animation, secondaryAnimation) =>
                  //                       Profile(
                  //                 defindex: 0,
                  //               ),
                  //               transitionsBuilder: (context, animation,
                  //                   secondaryAnimation, child) {
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
                  //         child: profileUrl != "null"
                  //             ? Container(
                  //                height:27,width:27,
                  //                decoration: BoxDecoration(
                  //                  shape: BoxShape.circle,
                  //                  color:Colors.red,
                  //                  image: DecorationImage(
                  //                    image: NetworkImage("${profileUrl}"),
                  //                    fit: BoxFit.fill
                  //                  )
                  //                )
                  //             )
                  //             : CircleAvatar(
                  //                 radius: 14.7,
                  //                 backgroundColor: Colors.white,
                  //                 child: CircleAvatar(
                  //                     radius: 13,
                  //                     backgroundImage:
                  //                         AssetImage("assets/images/user.png")),
                  //               ),
                  //       ),
                  //     ),
                  //   ],
                  // )
                ],
              ),
            ),
          ),
        ),
        key: _scaffoldKey,
        body: Column(
              children: [
                //Location and search....
                Container(
                  padding: EdgeInsets.only(left: 10, top: 8, bottom: 15),
                  color: lightGrey,
                  child: Column(
                    children: [
                      Container(
                        child: Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              color: Colors.red,
                              size: 18,
                            ),
                            SizedBox(
                              width: 3,
                            ),
                            Text(
                              'Delivery to',
                              style: TextStyle(
                                  color: Colors.black54,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: poppins,
                                  fontSize: 13
                              ),
                            )
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(left: 8),
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                width: 200,
                                child: GestureDetector(
                                  onTap: () async{
                                    FocusScope.of(context).unfocus();
                                    // showLocationChangeDialog();

                                    var placeResult = await PlacesAutocomplete.show(
                                        context: context,
                                        mode: Mode.overlay,
                                        language: "in",
                                        hint: "Type location...",
                                        strictbounds: false,
                                        logo: Text(""),
                                        types: [],
                                        apiKey: "AIzaSyBaI458_z7DHPh2opQx4dlFg5G3As0eHwE",
                                        onError: (e){

                                        },
                                        components: [new wbservice.Component(wbservice.Component.country, "in")],
                                    );

                                    if(placeResult == null){

                                    }else{
                                      getCoordinates(placeResult!.description.toString());
                                    }

                                  },
                                  child: Text(
                                    '$userLocalityAdr',
                                    maxLines: 1,
                                    style: TextStyle(
                                        fontFamily: poppins,
                                        fontSize: 13.5,
                                        color: darkBlue,
                                        fontWeight: FontWeight.bold,
                                        overflow: TextOverflow.ellipsis
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 5,),
                            GestureDetector(
                              onTap: () async{

                                FocusScope.of(context).unfocus();

                                // final result = await Navigator.push(
                                //   context,
                                //   MaterialPageRoute(builder: (context) =>LocationScreen()),
                                // );
                                //
                                // if(!mounted) return;
                                //
                                // print("Popped result form .... $result");
                                //
                                // if(result!=null){
                                //   getCoordinates(result.toString());
                                // }
                                var placeResult = await PlacesAutocomplete.show(
                                  context: context,
                                  mode: Mode.overlay,
                                  language: "in",
                                  hint: "Type location...",
                                  strictbounds: false,
                                  logo: Text(""),
                                  types: [],
                                  apiKey: "AIzaSyBaI458_z7DHPh2opQx4dlFg5G3As0eHwE",
                                  onError: (e){

                                  },
                                  components: [new wbservice.Component(wbservice.Component.country, "in")],
                                );
                                if(placeResult == null){

                                }else{
                                  getCoordinates(placeResult!.description.toString());
                                }
                              },
                              child: Icon(Icons.arrow_drop_down),
                            ),
                            SizedBox(width: 10,)
                          ],
                        ),
                      ),
                      Container(
                              padding: EdgeInsets.only(right: 8, top: 10),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: 45,
                                      child: TextField(
                                        style: TextStyle(
                                            fontFamily: poppins,
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold),
                                        controller: mainSearchCtrl,
                                        onChanged: (String? text) {
                                          setState(() {
                                            searchText = text!;
                                          });
                                        },
                                        decoration: InputDecoration(
                                            hintText: "Search cake...",
                                            hintStyle: TextStyle(
                                                fontFamily: poppins,
                                                fontSize: 13,
                                                color: Colors.grey[400]),
                                            prefixIcon: Icon(Icons.search,
                                                color: Colors.grey[400]),
                                            fillColor: Colors.white,
                                            filled: true,
                                            border: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    width: 1,
                                                    color: Colors.grey[200]!,
                                                    style: BorderStyle.solid),
                                                borderRadius:
                                                    BorderRadius.circular(8)),
                                            enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    width: 1.5,
                                                    color: Colors.grey[300]!,
                                                    style: BorderStyle.solid),
                                                borderRadius:
                                                    BorderRadius.circular(8)),
                                            contentPadding: EdgeInsets.all(5),
                                            suffixIcon: IconButton(
                                              onPressed: () {
                                                FocusScope.of(context).unfocus();
                                                setState(() {
                                                  activeSearchClear();
                                                });
                                              },
                                              icon: Icon(Icons.close),
                                              iconSize: 16,
                                            )),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: 45,
                                    width: 45,
                                    margin: EdgeInsets.only(left: 10),
                                    decoration: BoxDecoration(
                                        color: lightPink,
                                        borderRadius: BorderRadius.circular(7)),
                                    child: Semantics(
                                      label: "Hi how are you",
                                      hint: 'Hi bro iam sorry',
                                      child: IconButton(
                                          splashColor: Colors.black26,
                                          onPressed: () {
                                            FocusScope.of(context).unfocus();
                                            showFilterBottom();
                                            // getNearestVendors();
                                          },
                                          icon: Icon(
                                            Icons.tune,
                                            color: Colors.white,
                                          )),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ],
                  ),
                ),
                Expanded(child: Container(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      var pr = await SharedPreferences.getInstance();
                      pr.remove('activeVendorsIds');
                      setState(() {
                        activeVendorsIds = [];
                      });
                      setState(() {
                        loadPrefs();
                        checkLocationPermission();
                      });
                    },
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          !activeSearch
                              ? Column(
                                  children: [
                                    isAllLoading
                                        ?
                                    //Shimmer loading.....
                                    Column(
                                      children: [
                                        Container(
                                          height: 175,
                                          child: ListView.builder(
                                            itemCount: 10,
                                            shrinkWrap: true,
                                            scrollDirection: Axis.horizontal,
                                            itemBuilder: (context, position) {
                                              return Shimmer.fromColors(
                                                baseColor: Colors.white,
                                                highlightColor:
                                                Colors.grey[300]!,
                                                child: Container(
                                                  width: 150,
                                                  padding: EdgeInsets.all(5),
                                                  child: Column(
                                                    mainAxisSize:
                                                    MainAxisSize.min,
                                                    children: [
                                                      Container(
                                                        height: 125,
                                                        width: 130,
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                20),
                                                            color: Colors
                                                                .grey[400]),
                                                      ),
                                                      SizedBox(
                                                        height: 10,
                                                      ),
                                                      Container(
                                                        height: 10,
                                                        width: 110,
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                20),
                                                            color: Colors
                                                                .grey[400]),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                        Container(
                                          height: 0.3,
                                          width: double.infinity,
                                          margin: EdgeInsets.all(10),
                                          color: Colors.black26,
                                        ),
                                        Container(
                                          height: 175,
                                          child: ListView.builder(
                                            itemCount: 10,
                                            shrinkWrap: true,
                                            scrollDirection: Axis.horizontal,
                                            itemBuilder: (context, position) {
                                              return Shimmer.fromColors(
                                                baseColor: Colors.white,
                                                highlightColor:
                                                Colors.grey[300]!,
                                                child: Container(
                                                  width: 150,
                                                  padding: EdgeInsets.all(5),
                                                  child: Column(
                                                    mainAxisSize:
                                                    MainAxisSize.min,
                                                    children: [
                                                      Container(
                                                        height: 125,
                                                        width: 130,
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                20),
                                                            color: Colors
                                                                .grey[400]),
                                                      ),
                                                      SizedBox(
                                                        height: 10,
                                                      ),
                                                      Container(
                                                        height: 10,
                                                        width: 110,
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                20),
                                                            color: Colors
                                                                .grey[400]),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                        Container(
                                          height: 0.3,
                                          width: double.infinity,
                                          margin: EdgeInsets.all(10),
                                          color: Colors.black26,
                                        ),
                                        ListView.builder(
                                            itemCount: 10,
                                            shrinkWrap: true,
                                            physics:
                                            NeverScrollableScrollPhysics(),
                                            itemBuilder: (context, index) {
                                              return Shimmer.fromColors(
                                                baseColor: Colors.white,
                                                highlightColor:
                                                Colors.grey[300]!,
                                                child: Container(
                                                  width: double.infinity,
                                                  height: 125,
                                                  margin: EdgeInsets.all(8),
                                                  padding: EdgeInsets.all(5),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                        20),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Container(
                                                        height: 120,
                                                        width: 90,
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                20),
                                                            color: Colors
                                                                .grey[400]),
                                                      ),
                                                      SizedBox(
                                                        width: 5,
                                                      ),
                                                      Expanded(
                                                        child: Container(
                                                          height: 120,
                                                          decoration: BoxDecoration(
                                                              borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                  20),
                                                              color: Colors
                                                                  .grey[400]),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              );
                                            })
                                      ],
                                    ):
                                    //List views and orders...
                                    Column(
                                      children: [
                                        //Ads View
                                        hampers.isNotEmpty?
                                        Container(
                                          alignment: Alignment.centerLeft,
                                          decoration: const BoxDecoration(
                                            image: DecorationImage(
                                                image: Svg(
                                                    'assets/images/splash.svg'),
                                                fit: BoxFit.cover,
                                                colorFilter: ColorFilter.mode(
                                                    Colors.white,
                                                    BlendMode.darken)),
                                          ),
                                          padding: EdgeInsets.only(left: 15,right: 10,top: 10),
                                          child: Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'Gift Hampers',
                                                style: TextStyle(
                                                    fontFamily: poppins,
                                                    fontSize: 13.5,
                                                    color: darkBlue,
                                                    fontWeight:
                                                    FontWeight.bold
                                                ),
                                              ),
                                              InkWell(
                                                onTap: () async {
                                                  var prefs = await SharedPreferences.getInstance();
                                                  prefs.setStringList('activeVendorsIds',activeVendorsIds);
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(builder: (context) =>Hampers()));
                                                },
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      'See All',
                                                      style: TextStyle(
                                                          color: lightPink,
                                                          fontFamily: poppins,
                                                          fontSize: 13,
                                                          fontWeight:
                                                          FontWeight.bold),
                                                    ),
                                                    Icon(
                                                      Icons
                                                          .keyboard_arrow_right,
                                                      color: lightPink,
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ):Container(),
                                        hampers.isNotEmpty?
                                        Container(
                                            decoration: const BoxDecoration(
                                              image: DecorationImage(
                                                  image: Svg(
                                                      'assets/images/splash.svg'),
                                                  fit: BoxFit.cover,
                                                  colorFilter: ColorFilter.mode(
                                                      Colors.white,
                                                      BlendMode.darken)),
                                            ),
                                            height: height*0.13,
                                            child: ListView.builder(
                                                scrollDirection:
                                                Axis.horizontal,
                                                itemCount: hampers.length,
                                                itemBuilder: (c, i) {
                                                  return GestureDetector(
                                                    onTap: () async{
                                                      var pref = await SharedPreferences.getInstance();
                                                      List<String> productsContains = [];

                                                      if(hampers[i]['Product_Contains']!=null && hampers[i]['Product_Contains'].isNotEmpty){
                                                        for(int j = 0 ; j<hampers[i]['Product_Contains'].length;j++){
                                                          productsContains.add(hampers[i]['Product_Contains'][j].toString());
                                                        }
                                                      }

                                                      pref.remove("hamperImage");
                                                      pref.remove("hamperName");
                                                      pref.remove("hamperPrice");
                                                      pref.remove("hamper_ID");
                                                      pref.remove("hamperDescription");
                                                      pref.remove("hamperVendorName");
                                                      pref.remove("hamperVendorID");
                                                      pref.remove("hamperVendorName");
                                                      pref.remove("hamperVendorPhn1");
                                                      pref.remove("hamperVendorPhn2");
                                                      pref.remove("hamperProducts");

                                                      List<String> extraImages = [];
                                                      if(hampers[i]['AdditionalHamperImage']!=null && hampers[i]['AdditionalHamperImage'].isNotEmpty){
                                                        for(int j = 0;j<hampers[i]['AdditionalHamperImage'].length;j++){
                                                          extraImages.add(hampers[i]['AdditionalHamperImage'][j].toString());
                                                        }
                                                      }

                                                      extraImages.add(hampers[i]['HamperImage'].toString());
                                                      pref.setStringList("hamperImages", extraImages??[]);
                                                      pref.setString("hamperName", hampers[i]['HampersName']??'null');
                                                      pref.setString("hamperPrice", hampers[i]['Price']??'null');
                                                      pref.setString("hamperStartDate", hampers[i]['StartDate']??'null');
                                                      pref.setString("hamperEndDate", hampers[i]['EndDate']??'null');
                                                      pref.setString("hamperDeliStartDate", hampers[i]['DeliveryStartDate']??'null');
                                                      pref.setString("hamperDeliEndDate", hampers[i]['DeliveryEndDate']??'null');
                                                      pref.setString("hamper_ID", hampers[i]['_id']??'null');
                                                      pref.setString("hamperEggreggless", hampers[i]['EggOrEggless']??'null');
                                                      pref.setString("hamperModID", hampers[i]['Id']??'null');
                                                      pref.setString("hamperDescription", hampers[i]['Description']??'null');
                                                      pref.setString("hamperVendorName", hampers[i]['VendorName']??'null');
                                                      pref.setString("hamperVendorID", hampers[i]['VendorID']??'null');
                                                      pref.setString("hamperVendor_ID", hampers[i]['Vendor_ID']??'null');
                                                      pref.setString("hamperVendorAddress", hampers[i]['VendorAddress']??'null');
                                                      pref.setString("hamperVendorPhn1", hampers[i]['VendorPhoneNumber1']??'null');
                                                      pref.setString("hamperVendorPhn2", hampers[i]['VendorPhoneNumber2']??'null');
                                                      pref.setString("hamperTitle", hampers[i]['Title']??'null');
                                                      pref.setString("hamperWeight", hampers[i]['Weight']??'null');
                                                      pref.setString("hamperLat", hampers[i]['GoogleLocation']['Latitude'].toString()??'null');
                                                      pref.setString("hamperLong", hampers[i]['GoogleLocation']['Longitude'].toString()??'null');
                                                      pref.setStringList("hamperProducts", productsContains??[]);

                                                      print(productsContains);

                                                      Navigator.push(context, MaterialPageRoute(builder: (context)=>HamperDetails(
                                                        data:hampers[i],
                                                      )));

                                                    },
                                                    child: Container(
                                                      alignment:
                                                      Alignment.bottomLeft,
                                                      margin: EdgeInsets.all(8),
                                                      width: width*0.55,
                                                      decoration: hampers[i]['HamperImage'] == null ||
                                                          hampers[i]['HamperImage']
                                                              .toString()
                                                              .isEmpty
                                                          ? BoxDecoration(
                                                          border: Border.all(
                                                              color: Colors
                                                                  .grey[300]!,
                                                              style: BorderStyle
                                                                  .solid,
                                                              width: 1.5),
                                                          color: Colors.white,
                                                          borderRadius: BorderRadius.circular(
                                                              22),
                                                          image: DecorationImage(
                                                              image: AssetImage(
                                                                  'assets/images/cakebaner.jpg'),
                                                              fit: BoxFit.cover))
                                                          : BoxDecoration(
                                                          border: Border.all(
                                                              color: Colors.grey[200]!,
                                                              style: BorderStyle.solid,
                                                              width: 1.5),
                                                          color: Colors.white,
                                                          borderRadius: BorderRadius.circular(10),
                                                          image: DecorationImage(image: NetworkImage(hampers[i]['HamperImage'].toString()),
                                                              fit: BoxFit.cover)),
                                                      child: Padding(
                                                        padding:
                                                        const EdgeInsets.only(
                                                            left: 8,
                                                            bottom: 8),
                                                        child: Column(
                                                            mainAxisSize:
                                                            MainAxisSize.min,
                                                            crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                            children: []),
                                                      ),
                                                    ),
                                                  );
                                                })):
                                        Container(),

                                        Container(
                                          height: recentOrders.isNotEmpty
                                              ? height*0.49
                                              : height*0.26,
                                          decoration: const BoxDecoration(
                                            image: DecorationImage(
                                                image: Svg(
                                                    'assets/images/splash.svg'),
                                                fit: BoxFit.cover,
                                                colorFilter: ColorFilter.mode(
                                                    Colors.white70,
                                                    BlendMode.darken)),
                                          ),
                                          child: Column(
                                            children: [
                                              Container(
                                                alignment: Alignment.centerLeft,
                                                padding: EdgeInsets.only(left: 15,right: 10,top: 10,bottom: 10),
                                                child: Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                                  children: [
                                                    Text(
                                                      'Type of Cakes',
                                                      style: TextStyle(
                                                          fontFamily: poppins,
                                                          fontSize: 13.5,
                                                          color: darkBlue,
                                                          fontWeight:
                                                          FontWeight.bold),
                                                    ),
                                                    searchCakeType.length>2?
                                                    InkWell(
                                                      onTap: () async {
                                                        //checkLocationPermission();
                                                        var prefs = await SharedPreferences.getInstance();
                                                        prefs.setStringList('activeVendorsIds',activeVendorsIds);
                                                        prefs.setBool('iamYourVendor', false);
                                                        prefs.setBool('vendorCakeMode',false);
                                                        context.read<ContextData>().setMyVendors([]);
                                                        context.read<ContextData>().addMyVendor(false);
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(builder: (context) => CakeTypes()));
                                                      },
                                                      child: Row(
                                                        children: [
                                                          Text(
                                                            'See All',
                                                            style: TextStyle(
                                                                color:
                                                                lightPink,
                                                                fontFamily:
                                                                poppins,
                                                                fontSize: 13,
                                                                fontWeight:
                                                                FontWeight
                                                                    .bold
                                                            ),
                                                          ),
                                                          Icon(
                                                            Icons
                                                                .keyboard_arrow_right,
                                                            color: lightPink,
                                                          )
                                                        ],
                                                      ),
                                                    ):Container(),
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                padding: EdgeInsets.all(5),
                                                alignment: Alignment.centerLeft,
                                                height: height*0.19,
                                                child: searchCakeType.isEmpty
                                                    ? Center(
                                                  child: Text(
                                                    'No Results Found!',
                                                    style: TextStyle(
                                                        fontFamily:
                                                        "Poppins",
                                                        color: lightPink,
                                                        fontWeight:
                                                        FontWeight
                                                            .bold,
                                                        fontSize: 16),
                                                  ),
                                                )
                                                    : ListView.builder(
                                                    shrinkWrap: true,
                                                    scrollDirection:
                                                    Axis.horizontal,
                                                    itemCount:
                                                    searchCakeType
                                                        .length,
                                                    itemBuilder:
                                                        (context, index) {
                                                      return searchCakeType[index]['name'].toLowerCase().contains('customize your cake')
                                                          ? Container(
                                                        child:
                                                        InkWell(
                                                          onTap:
                                                              () async {
                                                            setState((){
                                                              cakeType = "customize your cake";
                                                            });
                                                            Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder: (context) => CustomiseCake()));
                                                          },
                                                          child:
                                                          Column(
                                                            children: [
                                                              Container(
                                                                margin: EdgeInsets.only(left: 5),
                                                                height:height*0.12,
                                                                width:width*0.32,
                                                                decoration: BoxDecoration(
                                                                    borderRadius: BorderRadius.circular(10),
                                                                    border: Border.all(color: Colors.white, width: 2),
                                                                    image: DecorationImage(image: AssetImage('assets/images/customcake.png'), fit: BoxFit.cover)),
                                                              ),
                                                              SizedBox(
                                                                height:
                                                                2,
                                                              ),
                                                              Text(
                                                                "Customize Your\nCake",
                                                                style: TextStyle(
                                                                    color: darkBlue,
                                                                    fontWeight: FontWeight.bold,
                                                                    fontFamily: poppins,
                                                                    fontSize: 12),
                                                                textAlign:
                                                                TextAlign.center,
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      )
                                                          : Container(
                                                        child:
                                                        InkWell(
                                                          onTap: () {

                                                            setState((){
                                                              cakeType = searchCakeType[index]['name'];
                                                              selectedCakeType = searchCakeType[index]['name'];
                                                              if(selectedCakeType.toLowerCase().contains("others")){
                                                                searchByGivenFilter("", "", "", [searchCakeType[index]['name']]);
                                                              }else{
                                                                searchByGivenFilter("", "", "", [searchCakeType[index]['name']]);
                                                              }
                                                            });

                                                            // Navigator.push(
                                                            //     context,
                                                            //     MaterialPageRoute(
                                                            //         builder: (context) => CakeTypes()));
                                                          },
                                                          child:
                                                          Column(
                                                            children: [
                                                              Container(
                                                                margin: EdgeInsets.only(left: 5),
                                                                height:height*0.12,
                                                                width:width*0.32,
                                                                decoration: BoxDecoration(
                                                                    borderRadius: BorderRadius.circular(10),
                                                                    border: Border.all(color: Colors.white, width: 2),
                                                                    color: Colors.pink[200],
                                                                    image: searchCakeType[index]['image']!=null?
                                                                    DecorationImage(
                                                                        image: NetworkImage(searchCakeType[index]['image']),
                                                                        fit: BoxFit.cover
                                                                    ):DecorationImage(
                                                                        image: AssetImage("assets/images/hamper.png"),
                                                                        fit: BoxFit.contain
                                                                    )
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                  height:
                                                                  2
                                                              ),
                                                              Text(
                                                                searchCakeType[index] == null
                                                                    ? 'No name'
                                                                    : "${searchCakeType[index]['name']}",
                                                                style: TextStyle(
                                                                    color: darkBlue,
                                                                    fontWeight: FontWeight.bold,
                                                                    fontFamily: poppins,
                                                                    fontSize: 12),
                                                                textAlign:
                                                                TextAlign.center,
                                                                maxLines:
                                                                2,
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      );
                                                    }),
                                              ),
                                              recentOrders.isNotEmpty
                                                  ? Container(
                                                height: 0.3,
                                                width: double.infinity,
                                                margin: EdgeInsets.only(
                                                    left: 10, right: 10),
                                                color: Colors.pink[100],
                                              )
                                                  : Container(),
                                              recentOrders.isNotEmpty
                                                  ? Column(
                                                children: [
                                                  Container(
                                                    padding: EdgeInsets.only(left:15,right:10,top:10),
                                                    width:double.infinity,
                                                    alignment: Alignment
                                                        .centerLeft,
                                                    child: Row(
                                                      mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                      children: [
                                                        Text(
                                                          'Recent Ordered',
                                                          style: TextStyle(
                                                              fontFamily:
                                                              poppins,
                                                              fontSize:
                                                              13.5,
                                                              color:
                                                              darkBlue,
                                                              fontWeight:
                                                              FontWeight
                                                                  .bold),
                                                        ),
                                                        recentOrders.length>2?
                                                        InkWell(
                                                          onTap:
                                                              () async {
                                                            Navigator.of(
                                                                context)
                                                                .push(
                                                              PageRouteBuilder(
                                                                pageBuilder: (context,
                                                                    animation,
                                                                    secondaryAnimation) =>
                                                                    Profile(
                                                                      defindex:
                                                                      1,
                                                                    ),
                                                                transitionsBuilder: (context,
                                                                    animation,
                                                                    secondaryAnimation,
                                                                    child) {
                                                                  const begin = Offset(
                                                                      1.0,
                                                                      0.0);
                                                                  const end =
                                                                      Offset.zero;
                                                                  const curve =
                                                                      Curves.ease;

                                                                  final tween = Tween(
                                                                      begin:
                                                                      begin,
                                                                      end:
                                                                      end);
                                                                  final curvedAnimation =
                                                                  CurvedAnimation(
                                                                    parent:
                                                                    animation,
                                                                    curve:
                                                                    curve,
                                                                  );

                                                                  return SlideTransition(
                                                                    position:
                                                                    tween.animate(curvedAnimation),
                                                                    child:
                                                                    child,
                                                                  );
                                                                },
                                                              ),
                                                            );
                                                          },
                                                          child: Row(
                                                            children: [
                                                              Text(
                                                                'See All',
                                                                style: TextStyle(
                                                                    color:
                                                                    lightPink,
                                                                    fontFamily:
                                                                    poppins,
                                                                    fontSize: 13,
                                                                    fontWeight:
                                                                    FontWeight.bold),
                                                              ),
                                                              Icon(
                                                                Icons
                                                                    .keyboard_arrow_right,
                                                                color:
                                                                lightPink,
                                                              )
                                                            ],
                                                          ),
                                                        ):Container(),
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(height: 15,),
                                                  Container(
                                                      height: height*0.17,
                                                      child: ListView.builder(
                                                          itemCount: recentOrders.length < 3 ? recentOrders.length : 3,
                                                          scrollDirection:
                                                          Axis.horizontal,
                                                          itemBuilder:
                                                              (context, index) {

                                                            String diff = recentOrders[index]['Created_On'].toString().split(" ").first;

                                                            print(recentOrders[index]['Created_On']);

                                                            print(differenceOF(DateTime(
                                                                int.parse(diff.split("-").last.toString()),
                                                                int.parse(diff.split("-")[1].toString()),
                                                                int.parse(diff.split("-").first.toString()),
                                                                14,04
                                                            ).toString()));

                                                            print(DateTime(
                                                                int.parse(diff.split("-").last.toString()),
                                                                int.parse(diff.split("-")[1].toString()),
                                                                int.parse(diff.split("-").first.toString()),
                                                                14,05,3
                                                            ));

                                                            print(
                                                                DateTime.now().difference(DateTime(
                                                                    int.parse(diff.split("-").last.toString()),
                                                                    int.parse(diff.split("-")[1].toString()),
                                                                    int.parse(diff.split("-").first.toString()),
                                                                    14,04
                                                                ))
                                                            );

                                                            var myMap = Map();
                                                            var otherPrice = "";

                                                            if(recentOrders[index]['ProductMinWeightPerKg']!=null){
                                                              // print(recentOrders[index]['ProductMinWeightPerKg']);
                                                              // print(recentOrders[index]['ProductMinWeightPerUnit']);
                                                              // print(recentOrders[index]['ProductMinWeightPerBox']);


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

                                                            print(otherPrice);



                                                            String gramAndKilo = "";

                                                            if(recentOrders[index]['ExtraCharges']!=null){
                                                              if(recentOrders[index]['Weight'].toString().toLowerCase().endsWith("kg")){
                                                                print("yes..");
                                                                gramAndKilo = (
                                                                    double.parse(recentOrders[index]['ItemCount'].toString()) * (
                                                                        (double.parse(recentOrders[index]['Price'].toString())*
                                                                            double.parse(recentOrders[index]['Weight'].toString().
                                                                            toLowerCase().replaceAll("kg", "")))+
                                                                            double.parse(recentOrders[index]['ExtraCharges'].toString())
                                                                    )
                                                                ).toStringAsFixed(2);
                                                              }else{
                                                                print("no...");
                                                                gramAndKilo = (
                                                                    (double.parse(recentOrders[index]['ItemCount'].toString()) * (
                                                                        (double.parse(recentOrders[index]['Price'].toString()))+
                                                                            double.parse(recentOrders[index]['ExtraCharges'].toString())
                                                                    )/2)
                                                                ).toStringAsFixed(2);
                                                              }
                                                            }
                                                            return recentOrders[index]['CakeName']!=null?
                                                            GestureDetector(
                                                              onTap: () {
                                                                showModalBottomSheet(
                                                                    context: context,
                                                                    isScrollControlled: true,
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius: BorderRadius.only(
                                                                          topLeft: Radius.circular(20),
                                                                          topRight: Radius.circular(20),
                                                                        )
                                                                    ),
                                                                    builder: (context){
                                                                      return Container(
                                                                        padding: EdgeInsets.all(10),
                                                                        child: Column(
                                                                          mainAxisSize: MainAxisSize.min,
                                                                          children: [
                                                                            Row(
                                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                              children: [
                                                                                Text("ORDER INFO" , style:TextStyle(
                                                                                    color:darkBlue,
                                                                                    fontFamily: "Poppins",
                                                                                    fontSize: 17,
                                                                                    fontWeight: FontWeight.bold
                                                                                )),
                                                                                InkWell(
                                                                                  onTap:()=>Navigator.pop(context),
                                                                                  child: Icon(Icons.cancel,color:Colors.red,size:30),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                            SizedBox(height: 10,),
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
                                                                              color: Colors.black26,
                                                                              height: 0.3,
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
                                                                                  const Text('CGST',style: const TextStyle(
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
                                                                              color: Colors.black26,
                                                                              height: 0.3,
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
                                                                          ],
                                                                        ),
                                                                      );
                                                                    }
                                                                );
                                                              },
                                                              child:
                                                              Container(
                                                                margin: EdgeInsets
                                                                    .only(
                                                                    left:
                                                                    10,
                                                                    right:
                                                                    10),
                                                                child: Stack(
                                                                  alignment:
                                                                  Alignment
                                                                      .topCenter,
                                                                  children: [
                                                                    recentOrders[index]['Image']==null||
                                                                        recentOrders[index]['Image'].toString().isEmpty?
                                                                    Container(
                                                                      width: width /
                                                                          2.2,
                                                                      height:height*0.06,
                                                                      decoration: BoxDecoration(
                                                                          borderRadius:
                                                                          BorderRadius.circular(10),
                                                                          border: Border.all(
                                                                              color: Colors.grey[300]!,
                                                                              width: 1
                                                                          ),
                                                                          image: DecorationImage(fit: BoxFit.cover,
                                                                              image: AssetImage("assets/images/chefdoll.jpg"))
                                                                      ),
                                                                    ):
                                                                    Container(
                                                                      width: width /
                                                                          2.2,
                                                                      height:height*0.06,
                                                                      decoration: BoxDecoration(
                                                                          borderRadius:
                                                                          BorderRadius.circular(10),
                                                                          border: Border.all(
                                                                              color: Colors.grey[300]!,
                                                                              width: 1
                                                                          ),
                                                                          image: DecorationImage(
                                                                              fit: BoxFit.cover,
                                                                              image: NetworkImage('${recentOrders[index]['Image']}'))
                                                                      ),
                                                                    ),
                                                                    Positioned(
                                                                      top:30,
                                                                      child:
                                                                      Card(
                                                                        shape:
                                                                        RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                                        elevation:
                                                                        7,
                                                                        child:
                                                                        Container(
                                                                          padding:
                                                                          EdgeInsets.all(8),
                                                                          width:
                                                                          155,
                                                                          child:
                                                                          Column(
                                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                            mainAxisSize: MainAxisSize.min,
                                                                            children: [
                                                                              Container(
                                                                                  alignment: Alignment.centerLeft,
                                                                                  child: Container(
                                                                                    width: 120,
                                                                                    child: Text(
                                                                                      recentOrders[index]['CakeName']!=null?
                                                                                      '${recentOrders[index]['CakeName']}':"My Cake",
                                                                                      style: TextStyle(color: darkBlue, fontWeight: FontWeight.bold, fontFamily: poppins, fontSize: 12),
                                                                                      maxLines: 1,
                                                                                      overflow: TextOverflow.ellipsis,
                                                                                    ),
                                                                                  )),
                                                                              SizedBox(
                                                                                height: 4,
                                                                              ),
                                                                              Row(
                                                                                children: [
                                                                                  Icon(
                                                                                    Icons.account_circle,
                                                                                  ),
                                                                                  Container(
                                                                                      width: 105,
                                                                                      child: Text(
                                                                                        recentOrders[index]['PremiumVendor']=='y'?
                                                                                        ' Premium Vendor':' ${recentOrders[index]['VendorName']}',
                                                                                        overflow: TextOverflow.ellipsis,
                                                                                        style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold, fontFamily: poppins, fontSize: 11),
                                                                                        maxLines: 1,
                                                                                      ))
                                                                                ],
                                                                              ),
                                                                              SizedBox(
                                                                                height: 4,
                                                                              ),
                                                                              Container(
                                                                                height: 0.3,
                                                                                color: Colors.black54,
                                                                                margin: EdgeInsets.only(left: 5, right: 5),
                                                                              ),
                                                                              SizedBox(
                                                                                height: 4,
                                                                              ),
                                                                              Row(
                                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                children: [
                                                                                  Text(
                                                                                    "₹ ${double.parse(recentOrders[index]['Total'].toString()).toStringAsFixed(2)}",
                                                                                    style: TextStyle(color: lightPink, fontWeight: FontWeight.bold, fontFamily: poppins, fontSize: 12),
                                                                                    maxLines: 1,
                                                                                  ),
                                                                                  Text(
                                                                                    recentOrders[index]['Status'].toString().toLowerCase() == 'rejected'||
                                                                                        recentOrders[index]['Status'].toString().toLowerCase() == 'assigned'?
                                                                                    "Accepted":
                                                                                    "${recentOrders[index]['Status']}",
                                                                                    style: TextStyle(color: recentOrders[index]['Status'].toString().toLowerCase() == 'cancelled'?
                                                                                    Colors.red:Colors.blueAccent, fontWeight: FontWeight.bold, fontFamily: poppins, fontSize: 10),
                                                                                  )
                                                                                ],
                                                                              )
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            )
                                                                :recentOrders[index]['ProductName']!=null?
                                                            GestureDetector(
                                                              onTap: () {
                                                                showModalBottomSheet(
                                                                    context: context,
                                                                    isScrollControlled: true,
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius: BorderRadius.only(
                                                                          topLeft: Radius.circular(20),
                                                                          topRight: Radius.circular(20),
                                                                        )
                                                                    ),
                                                                    builder: (context){
                                                                      return Container(
                                                                        padding: EdgeInsets.all(10),
                                                                        child: Column(
                                                                          mainAxisSize: MainAxisSize.min,
                                                                          children: [
                                                                            Row(
                                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                              children: [
                                                                                Text("ORDER INFO" , style:TextStyle(
                                                                                    color:darkBlue,
                                                                                    fontFamily: "Poppins",
                                                                                    fontSize: 17,
                                                                                    fontWeight: FontWeight.bold
                                                                                )),
                                                                                InkWell(
                                                                                  onTap:()=>Navigator.pop(context),
                                                                                  child: Icon(Icons.cancel,color:Colors.red,size:30),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                            SizedBox(height: 10,),
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
                                                                              color: Colors.black26,
                                                                              height: 0.3,
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
                                                                              color: Colors.black26,
                                                                              height: 0.3,
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
                                                                          ],
                                                                        ),
                                                                      );
                                                                    }
                                                                );
                                                              },
                                                              child:
                                                              Container(
                                                                margin: EdgeInsets
                                                                    .only(
                                                                    left:
                                                                    10,
                                                                    right:
                                                                    10),
                                                                child: Stack(
                                                                  alignment:
                                                                  Alignment
                                                                      .topCenter,
                                                                  children: [
                                                                    recentOrders[index]['Image']==null||
                                                                        recentOrders[index]['Image'].toString().isEmpty?
                                                                    Container(
                                                                      width: width /
                                                                          2.2,
                                                                      height:height*0.06,
                                                                      decoration: BoxDecoration(
                                                                          borderRadius:
                                                                          BorderRadius.circular(10),
                                                                          border: Border.all(
                                                                              color: Colors.grey[300]!,
                                                                              width: 1
                                                                          ),
                                                                          image: DecorationImage(fit: BoxFit.cover,
                                                                              image: AssetImage("assets/images/chefdoll.jpg"))
                                                                      ),
                                                                    ):
                                                                    Container(
                                                                      width: width /
                                                                          2.2,
                                                                      height:height*0.06,
                                                                      decoration: BoxDecoration(
                                                                          borderRadius:
                                                                          BorderRadius.circular(10),
                                                                          border: Border.all(
                                                                              color: Colors.grey[300]!,
                                                                              width: 1
                                                                          ),
                                                                          image: DecorationImage(fit: BoxFit.cover,
                                                                              image: NetworkImage('${recentOrders[index]['Image']}'))),
                                                                    ),
                                                                    Positioned(
                                                                      top:30,
                                                                      child:
                                                                      Card(
                                                                        shape:
                                                                        RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                                        elevation:
                                                                        7,
                                                                        child:
                                                                        Container(
                                                                          padding:
                                                                          EdgeInsets.all(8),
                                                                          width:
                                                                          155,
                                                                          child:
                                                                          Column(
                                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                            mainAxisSize: MainAxisSize.min,
                                                                            children: [
                                                                              Container(
                                                                                  alignment: Alignment.centerLeft,
                                                                                  child: Container(
                                                                                    width: 120,
                                                                                    child: Text(
                                                                                      recentOrders[index]['ProductName']!=null?
                                                                                      '${recentOrders[index]['ProductName']}':"My Cake",
                                                                                      style: TextStyle(color: darkBlue, fontWeight: FontWeight.bold, fontFamily: poppins, fontSize: 12),
                                                                                      maxLines: 1,
                                                                                      overflow: TextOverflow.ellipsis,
                                                                                    ),
                                                                                  )),
                                                                              SizedBox(
                                                                                height: 4,
                                                                              ),
                                                                              Row(
                                                                                children: [
                                                                                  Icon(
                                                                                    Icons.account_circle,
                                                                                  ),
                                                                                  Container(
                                                                                      width: 105,
                                                                                      child: Text(
                                                                                        recentOrders[index]['PremiumVendor']=='y'?
                                                                                        ' Premium Vendor':' ${recentOrders[index]['VendorName']}',
                                                                                        overflow: TextOverflow.ellipsis,
                                                                                        style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold, fontFamily: poppins, fontSize: 11),
                                                                                        maxLines: 1,
                                                                                      ))
                                                                                ],
                                                                              ),
                                                                              SizedBox(
                                                                                height: 4,
                                                                              ),
                                                                              Container(
                                                                                height: 0.3,
                                                                                color: Colors.black54,
                                                                                margin: EdgeInsets.only(left: 5, right: 5),
                                                                              ),
                                                                              SizedBox(
                                                                                height: 4,
                                                                              ),
                                                                              Row(
                                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                children: [
                                                                                  Text(
                                                                                    "₹ ${double.parse(recentOrders[index]['Total'].toString()).toStringAsFixed(2)}",
                                                                                    style: TextStyle(color: lightPink, fontWeight: FontWeight.bold, fontFamily: poppins, fontSize: 12),
                                                                                    maxLines: 1,
                                                                                  ),
                                                                                  recentOrders[index]['Status'].toString().toLowerCase() == 'delivered'
                                                                                      ? Text(
                                                                                    "${recentOrders[index]['Status'].toString()}",
                                                                                    style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontFamily: poppins, fontSize: 10),
                                                                                  )
                                                                                      : Text(
                                                                                    "${recentOrders[index]['Status']}",
                                                                                    style: TextStyle(color: recentOrders[index]['Status'].toString().toLowerCase() == 'cancelled'?
                                                                                    Colors.red:Colors.blueAccent, fontWeight: FontWeight.bold, fontFamily: poppins, fontSize: 10),
                                                                                  )
                                                                                ],
                                                                              )
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ):
                                                            recentOrders[index]['HampersName']!=null?
                                                            GestureDetector(
                                                              onTap: () {
                                                                showModalBottomSheet(
                                                                    context: context,
                                                                    isScrollControlled: true,
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius: BorderRadius.only(
                                                                          topLeft: Radius.circular(20),
                                                                          topRight: Radius.circular(20),
                                                                        )
                                                                    ),
                                                                    builder: (context){
                                                                      return Container(
                                                                        padding: EdgeInsets.all(10),
                                                                        child: Column(
                                                                          mainAxisSize: MainAxisSize.min,
                                                                          children: [
                                                                            Row(
                                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                              children: [
                                                                                Text("ORDER INFO" , style:TextStyle(
                                                                                    color:darkBlue,
                                                                                    fontFamily: "Poppins",
                                                                                    fontSize: 17,
                                                                                    fontWeight: FontWeight.bold
                                                                                )),
                                                                                InkWell(
                                                                                  onTap:()=>Navigator.pop(context),
                                                                                  child: Icon(Icons.cancel,color:Colors.red,size:30),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                            SizedBox(height: 10,),
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
                                                                              color: Colors.black26,
                                                                              height: 0.3,
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
                                                                              color: Colors.black26,
                                                                              height: 0.3,
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
                                                                          ],
                                                                        ),
                                                                      );
                                                                    }
                                                                );
                                                              },
                                                              child:
                                                              Container(
                                                                margin: EdgeInsets
                                                                    .only(
                                                                    left:
                                                                    10,
                                                                    right:
                                                                    10),
                                                                child: Stack(
                                                                  alignment:
                                                                  Alignment
                                                                      .topCenter,
                                                                  children: [
                                                                    recentOrders[index]['HamperImage']==null||
                                                                        recentOrders[index]['HamperImage'].toString().isEmpty?
                                                                    Container(
                                                                      width: width /
                                                                          2.2,
                                                                      height:height*0.06,
                                                                      decoration: BoxDecoration(
                                                                          borderRadius:
                                                                          BorderRadius.circular(10),
                                                                          border: Border.all(
                                                                              color: Colors.grey[300]!,
                                                                              width: 1
                                                                          ),
                                                                          image: DecorationImage(fit: BoxFit.cover,
                                                                              image: AssetImage("assets/images/chefdoll.jpg"))
                                                                      ),
                                                                    ):
                                                                    Container(
                                                                      width: width /
                                                                          2.2,
                                                                      height:height*0.06,
                                                                      decoration: BoxDecoration(
                                                                          borderRadius:
                                                                          BorderRadius.circular(10),
                                                                          border: Border.all(
                                                                              color: Colors.grey[300]!,
                                                                              width: 1
                                                                          ),
                                                                          image: DecorationImage(fit: BoxFit.cover,
                                                                              image: NetworkImage('${recentOrders[index]['HamperImage']}'))),
                                                                    ),
                                                                    Positioned(
                                                                      top:30,
                                                                      child:
                                                                      Card(
                                                                        shape:
                                                                        RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                                        elevation:
                                                                        7,
                                                                        child:
                                                                        Container(
                                                                          padding:
                                                                          EdgeInsets.all(8),
                                                                          width:
                                                                          155,
                                                                          child:
                                                                          Column(
                                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                            mainAxisSize: MainAxisSize.min,
                                                                            children: [
                                                                              Container(
                                                                                  alignment: Alignment.centerLeft,
                                                                                  child: Container(
                                                                                    width: 120,
                                                                                    child: Text(
                                                                                      recentOrders[index]['HampersName']!=null?
                                                                                      '${recentOrders[index]['HampersName']}':"My Cake",
                                                                                      style: TextStyle(color: darkBlue, fontWeight: FontWeight.bold, fontFamily: poppins, fontSize: 12),
                                                                                      maxLines: 1,
                                                                                      overflow: TextOverflow.ellipsis,
                                                                                    ),
                                                                                  )),
                                                                              SizedBox(
                                                                                height: 4,
                                                                              ),
                                                                              Row(
                                                                                children: [
                                                                                  Icon(
                                                                                    Icons.account_circle,
                                                                                  ),
                                                                                  Container(
                                                                                      width: 105,
                                                                                      child: Text(
                                                                                        recentOrders[index]['PremiumVendor']=='y'?
                                                                                        ' Premium Vendor':' ${recentOrders[index]['VendorName']}',
                                                                                        overflow: TextOverflow.ellipsis,
                                                                                        style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold, fontFamily: poppins, fontSize: 11),
                                                                                        maxLines: 1,
                                                                                      ))
                                                                                ],
                                                                              ),
                                                                              SizedBox(
                                                                                height: 4,
                                                                              ),
                                                                              Container(
                                                                                height: 0.3,
                                                                                color: Colors.black54,
                                                                                margin: EdgeInsets.only(left: 5, right: 5),
                                                                              ),
                                                                              SizedBox(
                                                                                height: 4,
                                                                              ),
                                                                              Row(
                                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                children: [
                                                                                  Text(
                                                                                    "₹ ${double.parse(recentOrders[index]['Total'].toString()).toStringAsFixed(2)}",
                                                                                    style: TextStyle(color: lightPink, fontWeight: FontWeight.bold, fontFamily: poppins, fontSize: 12),
                                                                                    maxLines: 1,
                                                                                  ),
                                                                                  recentOrders[index]['Status'].toString().toLowerCase() == 'delivered'
                                                                                      ? Text(
                                                                                    "${recentOrders[index]['Status'].toString()}",
                                                                                    style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontFamily: poppins, fontSize: 10),
                                                                                  )
                                                                                      : Text(
                                                                                    "${recentOrders[index]['Status']}",
                                                                                    style: TextStyle(color: recentOrders[index]['Status'].toString().toLowerCase() == 'cancelled'?
                                                                                    Colors.red:Colors.blueAccent, fontWeight: FontWeight.bold, fontFamily: poppins, fontSize: 10),
                                                                                  )
                                                                                ],
                                                                              )
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ):
                                                            GestureDetector(
                                                              onTap: () {
                                                                showModalBottomSheet(
                                                                    context: context,
                                                                    isScrollControlled: true,
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius: BorderRadius.only(
                                                                          topLeft: Radius.circular(20),
                                                                          topRight: Radius.circular(20),
                                                                        )
                                                                    ),
                                                                    builder: (context){
                                                                      return Container(
                                                                          child:Column(
                                                                              children:[
                                                                                Row(
                                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                  children: [
                                                                                    Text("ORDER INFO" , style:TextStyle(
                                                                                        color:darkBlue,
                                                                                        fontFamily: "Poppins",
                                                                                        fontSize: 17,
                                                                                        fontWeight: FontWeight.bold
                                                                                    )),
                                                                                    InkWell(
                                                                                      onTap:()=>Navigator.pop(context),
                                                                                      child: Icon(Icons.cancel,color:Colors.red,size:30),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                                SizedBox(height: 10,),
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
                                                                                  color: Colors.black26,
                                                                                  height: 0.3,
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
                                                                                  color: Colors.black26,
                                                                                  height: 0.3,
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
                                                                              ]
                                                                          )
                                                                      );
                                                                    }
                                                                );
                                                              },
                                                              child:
                                                              Container(
                                                                margin: EdgeInsets
                                                                    .only(
                                                                    left:
                                                                    10,
                                                                    right:
                                                                    10),
                                                                child: Stack(
                                                                  alignment:
                                                                  Alignment
                                                                      .topCenter,
                                                                  children: [
                                                                    recentOrders[index]['HamperImage']==null||
                                                                        recentOrders[index]['HamperImage'].toString().isEmpty?
                                                                    Container(
                                                                      width: width /
                                                                          2.2,
                                                                      height:height*0.06,
                                                                      decoration: BoxDecoration(
                                                                          borderRadius:
                                                                          BorderRadius.circular(10),
                                                                          image: DecorationImage(fit: BoxFit.cover,
                                                                              image: AssetImage("assets/images/chefdoll.jpg"))
                                                                      ),
                                                                    ):
                                                                    Container(
                                                                      width: width /
                                                                          2.2,
                                                                      height:height*0.06,
                                                                      decoration: BoxDecoration(
                                                                          borderRadius:
                                                                          BorderRadius.circular(10),
                                                                          image: DecorationImage(fit: BoxFit.cover,
                                                                              image: NetworkImage('${recentOrders[index]['HamperImage']}'))),
                                                                    ),
                                                                    Positioned(
                                                                      top:60,
                                                                      child:
                                                                      Card(
                                                                        shape:
                                                                        RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                                        elevation:
                                                                        7,
                                                                        child:
                                                                        Container(
                                                                          padding:
                                                                          EdgeInsets.all(8),
                                                                          width:
                                                                          155,
                                                                          child:
                                                                          Column(
                                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                            mainAxisSize: MainAxisSize.min,
                                                                            children: [
                                                                              Container(
                                                                                  alignment: Alignment.centerLeft,
                                                                                  child: Container(
                                                                                    width: 120,
                                                                                    child: Text(
                                                                                      recentOrders[index]['CakeName']!=null?
                                                                                      '${recentOrders[index]['CakeName']}':"My Cake",
                                                                                      style: TextStyle(color: darkBlue, fontWeight: FontWeight.bold, fontFamily: poppins, fontSize: 12),
                                                                                      maxLines: 1,
                                                                                      overflow: TextOverflow.ellipsis,
                                                                                    ),
                                                                                  )),
                                                                              SizedBox(
                                                                                height: 4,
                                                                              ),
                                                                              Row(
                                                                                children: [
                                                                                  Icon(
                                                                                    Icons.account_circle,
                                                                                  ),
                                                                                  Container(
                                                                                      width: 105,
                                                                                      child: Text(
                                                                                        recentOrders[index]['PremiumVendor']=='y'?
                                                                                        ' Premium Vendor':' ${recentOrders[index]['VendorName']}',
                                                                                        overflow: TextOverflow.ellipsis,
                                                                                        style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold, fontFamily: poppins, fontSize: 11),
                                                                                        maxLines: 1,
                                                                                      ))
                                                                                ],
                                                                              ),
                                                                              SizedBox(
                                                                                height: 4,
                                                                              ),
                                                                              Container(
                                                                                height: 0.3,
                                                                                color: Colors.black54,
                                                                                margin: EdgeInsets.only(left: 5, right: 5),
                                                                              ),
                                                                              SizedBox(
                                                                                height: 4,
                                                                              ),
                                                                              Row(
                                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                children: [
                                                                                  Text(
                                                                                    "₹ ${double.parse(recentOrders[index]['Total'].toString()).toStringAsFixed(2)}",
                                                                                    style: TextStyle(color: lightPink, fontWeight: FontWeight.bold, fontFamily: poppins, fontSize: 12),
                                                                                    maxLines: 1,
                                                                                  ),
                                                                                  recentOrders[index]['Status'].toString().toLowerCase() == 'delivered'
                                                                                      ? Text(
                                                                                    "${recentOrders[index]['Status'].toString()}",
                                                                                    style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontFamily: poppins, fontSize: 10),
                                                                                  )
                                                                                      : Text(
                                                                                    "${recentOrders[index]['Status']}",
                                                                                    style: TextStyle(color: recentOrders[index]['Status'].toString().toLowerCase() == 'cancelled'?
                                                                                    Colors.red:Colors.blueAccent, fontWeight: FontWeight.bold, fontFamily: poppins, fontSize: 10),
                                                                                  )
                                                                                ],
                                                                              )
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            );
                                                          })
                                                  ),


                                                ],
                                              )
                                                  : Container(),
                                            ],
                                          ),
                                        ),
                                        //Vendors........
                                        Container(
                                          padding: EdgeInsets.only(left:15,right:10,top:10,bottom: 10),
                                          child: Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    'Vendors List',
                                                    style: TextStyle(
                                                        fontSize: 13.5,
                                                        color: darkBlue,
                                                        fontWeight:
                                                        FontWeight.bold,
                                                        fontFamily: poppins),
                                                  ),
                                                  Text(
                                                    '',
                                                    style: TextStyle(
                                                        color: Colors.black45,
                                                        fontFamily: poppins),
                                                  ),
                                                ],
                                              ),
                                              InkWell(
                                                onTap: () {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              VendorsList()));
                                                },
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      'See All',
                                                      style: TextStyle(
                                                          color: lightPink,
                                                          fontSize: 13,
                                                          fontWeight:
                                                          FontWeight.bold,
                                                          fontFamily: poppins),
                                                    ),
                                                    Icon(
                                                      Icons
                                                          .keyboard_arrow_right,
                                                      color: lightPink,
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          children: [
                                            Container(
                                              padding:
                                              EdgeInsets.only(left: 10),
                                              child: Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment
                                                    .spaceBetween,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Transform.scale(
                                                        scale: 0.7,
                                                        child: CupertinoSwitch(
                                                          thumbColor:
                                                          Colors.white,
                                                          value: egglesSwitch,
                                                          onChanged:
                                                              (bool? val) {
                                                            setState(() {
                                                              egglesSwitch =
                                                              val!;
                                                              onChanged = true;
                                                            });
                                                          },
                                                          activeColor:
                                                          Colors.green,
                                                        ),
                                                      ),
                                                      Text(
                                                        ' Eggless',
                                                        style: TextStyle(
                                                            color: darkBlue,
                                                            fontFamily:
                                                            poppins),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              child: nearestVendors.isEmpty
                                                  ? Column(
                                                children: [
                                                  SizedBox(height: 20),
                                                  Text(
                                                      'No Results Found!',
                                                      style: TextStyle(
                                                          fontFamily:
                                                          'Poppins',
                                                          color:
                                                          darkBlue)),
                                                  SizedBox(height: 20),
                                                ],
                                              )
                                                  : ListView.builder(
                                                  itemCount:
                                                  nearestVendors.length,
                                                  shrinkWrap: true,
                                                  physics:
                                                  NeverScrollableScrollPhysics(),
                                                  itemBuilder:
                                                      (context, index) {
                                                    var deliverCharge = double.parse("${((deliveryChargeFromAdmin / deliverykmFromAdmin) *
                                                        (calculateDistance(userLat, userLong, nearestVendors[index]['GoogleLocation']['Latitude'],
                                                            nearestVendors[index]['GoogleLocation']['Longitude'])))}").toStringAsFixed(1);
                                                    var betweenKm = (calculateDistance(userLat, userLong, nearestVendors[index]['GoogleLocation']['Latitude'],
                                                        nearestVendors[index]['GoogleLocation']['Longitude'])).toStringAsFixed(1);
                                                    return InkWell(
                                                      splashColor:
                                                      Colors.pink[100],
                                                      onTap: () =>
                                                          sendNearVendorDataToScreen(index , deliverCharge,betweenKm),
                                                      child: Card(
                                                        margin:
                                                        EdgeInsets.only(
                                                            left: 10,
                                                            right: 10,
                                                            top: 10,
                                                            bottom: 5),
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                10)),
                                                        child: Container(
                                                          // margin: EdgeInsets.all(5),
                                                          padding:
                                                          EdgeInsets
                                                              .all(6),
                                                          height: 130,
                                                          decoration: BoxDecoration(
                                                              borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                  10)),
                                                          child: Row(
                                                            children: [
                                                              nearestVendors[index]
                                                              [
                                                              'ProfileImage'] !=
                                                                  null
                                                                  ? Container(
                                                                height:
                                                                120,
                                                                width:
                                                                80,
                                                                decoration: BoxDecoration(
                                                                    borderRadius: BorderRadius.circular(10),
                                                                    image: DecorationImage(
                                                                      fit: BoxFit.cover,
                                                                      image: NetworkImage('${nearestVendors[index]['ProfileImage']}'),
                                                                    )),
                                                              )
                                                                  : Container(
                                                                alignment:
                                                                Alignment.center,
                                                                height:
                                                                120,
                                                                width:
                                                                80,
                                                                decoration: BoxDecoration(
                                                                    borderRadius: BorderRadius.circular(10),
                                                                    color: index.isOdd ? Colors.purple : Colors.teal),
                                                                child:
                                                                Text(
                                                                  nearestVendors[index]['VendorName'][0].toString().toUpperCase(),
                                                                  style: TextStyle(
                                                                      color: Colors.white,
                                                                      fontWeight: FontWeight.bold,
                                                                      fontSize: 35),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                width: 6,
                                                              ),
                                                              Expanded(
                                                                  child:
                                                                  Container(
                                                                    // color:Colors.red,
                                                                    padding:
                                                                    EdgeInsets
                                                                        .all(5),
                                                                    child: Column(
                                                                      mainAxisSize: MainAxisSize.max,
                                                                      mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceAround,
                                                                      crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                      children: [
                                                                        Row(
                                                                          children: [
                                                                            Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                                Container(
                                                                                  width: width * 0.5,
                                                                                  child: Text(
                                                                                    '${nearestVendors[index]['VendorName'][0].toString().toUpperCase() + "${nearestVendors[index]['VendorName'].toString().substring(1).toLowerCase()}"}',
                                                                                    overflow: TextOverflow.ellipsis,
                                                                                    style: TextStyle(color: darkBlue, fontWeight: FontWeight.bold, fontSize: 13, fontFamily: poppins),
                                                                                  ),
                                                                                ),
                                                                                Row(
                                                                                  children: [
                                                                                    RatingBar.builder(
                                                                                      initialRating: double.parse(nearestVendors[index]['Ratings'].toString()),
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
                                                                                      onRatingUpdate: (rating) {},
                                                                                    ),
                                                                                    Text(
                                                                                      ' ${double.parse(nearestVendors[index]['Ratings'].toString())}',
                                                                                      style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold, fontSize: 13, fontFamily: poppins),
                                                                                    )
                                                                                  ],
                                                                                ),
                                                                              ],
                                                                            ),
                                                                            Expanded(
                                                                              child: Align(
                                                                                alignment: Alignment.centerRight,
                                                                                child: InkWell(
                                                                                  onTap: () {
                                                                                    sendNearVendorDataToScreen(index, deliverCharge,betweenKm);
                                                                                  },
                                                                                  child: Container(
                                                                                    decoration: BoxDecoration(color: lightGrey, shape: BoxShape.circle),
                                                                                    padding: EdgeInsets.all(4),
                                                                                    height: 35,
                                                                                    width: 35,
                                                                                    child: Icon(
                                                                                      Icons.keyboard_arrow_right,
                                                                                      color: lightPink,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        SizedBox(
                                                                          height:
                                                                          4,
                                                                        ),
                                                                        Text(
                                                                          "Speciality in " +
                                                                              nearestVendors[index]['YourSpecialityCakes'].toString().replaceAll("[", "").replaceAll("]", ""),
                                                                          style: TextStyle(
                                                                              color: Colors.grey[400],
                                                                              fontFamily: "Poppins",
                                                                              fontSize: 11.5),
                                                                          maxLines:
                                                                          2,
                                                                        ),
                                                                        SizedBox(
                                                                          height:
                                                                          4,
                                                                        ),
                                                                        Divider(
                                                                          height:
                                                                          0.5,
                                                                          color:
                                                                          Color(0xffeeeeee),
                                                                        ),
                                                                        SizedBox(
                                                                          height:
                                                                          4,
                                                                        ),
                                                                        Row(
                                                                          mainAxisAlignment:
                                                                          MainAxisAlignment.spaceBetween,
                                                                          children: [
                                                                            index==1&&double.parse(
                                                                                double.parse("${((calculateDistance(userLat, userLong, nearestVendors[index]['GoogleLocation']['Latitude'],
                                                                                    nearestVendors[index]['GoogleLocation']['Longitude'])))}").toStringAsFixed(1)
                                                                            )<2.0||index==0&&double.parse(
                                                                                double.parse("${((calculateDistance(userLat, userLong, nearestVendors[index]['GoogleLocation']['Latitude'],
                                                                                    nearestVendors[index]['GoogleLocation']['Longitude'])))}").toStringAsFixed(1)
                                                                            )<2.0||
                                                                                double.parse(deliverCharge).toStringAsFixed(1)=="0.0"?
                                                                            Text(
                                                                              'DELIVERY FREE',
                                                                              style: TextStyle(color: Colors.orange, fontSize: 10, fontFamily: poppins),
                                                                            ):
                                                                            Text(
                                                                              "${betweenKm} KM Delivery Fee Rs.${deliverCharge}",
                                                                              style: TextStyle(color: darkBlue, fontSize: 10, fontFamily: poppins, fontWeight: FontWeight.bold),
                                                                            ),
                                                                            Expanded(
                                                                                child: Align(
                                                                                  alignment: Alignment.centerRight,
                                                                                  child: nearestVendors[index]['EggOrEggless'] == 'Egg and Eggless'
                                                                                      ? Text(
                                                                                    'Includes eggless',
                                                                                    style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold, fontFamily: poppins),
                                                                                    overflow: TextOverflow.ellipsis,
                                                                                  )
                                                                                      : Text(
                                                                                    '${nearestVendors[index]['EggOrEggless']}',
                                                                                    style: TextStyle(
                                                                                        color: Colors.black,
                                                                                        fontSize: 9,
                                                                                        fontWeight: FontWeight.bold,
                                                                                        fontFamily: poppins
                                                                                    ),
                                                                                    overflow: TextOverflow.ellipsis,
                                                                                  ),
                                                                                ))
                                                                          ],
                                                                        )
                                                                      ],
                                                                    ),
                                                                  )),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  }),
                                            ),
                                            SizedBox(
                                              height: 15,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                )
                              : Visibility(
                            visible: isFiltered ? true : false,
                            child:
                            cakeSearchList.isNotEmpty?
                            ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                padding: EdgeInsets.only(bottom: 10),
                                itemCount: cakeSearchList.length,
                                itemBuilder: (c, i) {

                                  var item = nearestVendors.where((element) => element['_id'].toString().toLowerCase()==cakeSearchList[i]['VendorID'].toString().toLowerCase()).toList();

                                  print(item);
                                  print(nearestVendors.length);

                                  var deliverCharge = double.parse("${((deliveryChargeFromAdmin / deliverykmFromAdmin) *
                                      (calculateDistance(userLat, userLong, item[0]['GoogleLocation']['Latitude'],
                                          item[0]['GoogleLocation']['Longitude'])))}").toStringAsFixed(1);

                                  print('home del charge ... $deliverCharge');

                                  var betweenKm = (calculateDistance(userLat, userLong, cakeSearchList[i]['GoogleLocation']['Latitude'],
                                      cakeSearchList[i]['GoogleLocation']['Longitude'])).toStringAsFixed(1);

                                  return Container(
                                    margin: EdgeInsets.only(
                                        left: 15, right: 15, top: 5, bottom: 5),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: Colors.white,
                                        border: Border.all(
                                            color: Colors.grey[400]!,
                                            width: 0.5)),
                                    child:
                                    cakeSearchList[i]['CakeName']!=null?
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        //header text (name , stars)
                                        Container(
                                            padding: EdgeInsets.only(
                                                top: 4,
                                                bottom: 4,
                                                left: 10,
                                                right: 10),
                                            decoration: BoxDecoration(
                                                borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(10),
                                                  topRight: Radius.circular(10),
                                                ),
                                                color: lightGrey),
                                            child: Row(children: [
                                              Container(
                                                width: cakeSearchList[i]
                                                ['VendorName']
                                                    .toString()
                                                    .length >
                                                    25
                                                    ? 130
                                                    : 60,
                                                child: Text(
                                                  '${cakeSearchList[i]['VendorName']}',
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight: FontWeight.bold,
                                                      fontFamily: 'Poppins',
                                                      fontSize: 13),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  RatingBar.builder(
                                                    initialRating: double.parse(
                                                        cakeSearchList[i]
                                                        ['Ratings']
                                                            .toString()),
                                                    minRating: 1,
                                                    direction: Axis.horizontal,
                                                    allowHalfRating: true,
                                                    itemCount: 5,
                                                    itemSize: 14,
                                                    itemPadding:
                                                    EdgeInsets.symmetric(
                                                        horizontal: 1.0),
                                                    itemBuilder: (context, _) =>
                                                        Icon(
                                                          Icons.star,
                                                          color: Colors.amber,
                                                        ),
                                                    onRatingUpdate: (rating) {},
                                                  ),
                                                  Text(
                                                    ' ${cakeSearchList[i]['Ratings'].toString()}',
                                                    style: TextStyle(
                                                        color: Colors.black54,
                                                        fontWeight:
                                                        FontWeight.bold,
                                                        fontSize: 12,
                                                        fontFamily: poppins),
                                                  )
                                                ],
                                              ),
                                              Expanded(
                                                  child: Container(
                                                      alignment:
                                                      Alignment.centerRight,
                                                      child: InkWell(
                                                        onTap: () {
                                                          sendDetailsToScreen(cakeSearchList[i]['_id'].toString());
                                                        },
                                                        child: Container(
                                                            alignment:
                                                            Alignment.center,
                                                            height: 25,
                                                            width: 25,
                                                            decoration:
                                                            BoxDecoration(
                                                                shape: BoxShape
                                                                    .circle,
                                                                color: Colors
                                                                    .white),
                                                            child: Icon(
                                                              Icons
                                                                  .arrow_forward_ios_sharp,
                                                              color: lightPink,
                                                              size: 15,
                                                            )),
                                                      )))
                                            ])),
                                        //body (image , cake name)
                                        InkWell(
                                          splashColor: Colors.red[100],
                                          onTap: () {
                                            sendDetailsToScreen(cakeSearchList[i]['_id'].toString());
                                          },
                                          child: Container(
                                              padding: EdgeInsets.all(8),
                                              child: Row(children: [
                                                cakeSearchList[i]['MainCakeImage']
                                                    .isEmpty ||
                                                    cakeSearchList[i][
                                                    'MainCakeImage'] ==
                                                        ''
                                                    ? Container(
                                                  height: 85,
                                                  width: 85,
                                                  alignment:
                                                  Alignment.center,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                    BorderRadius
                                                        .circular(10),
                                                    color: Colors.pink[100],
                                                  ),
                                                  child: Icon(
                                                    Icons.cake_outlined,
                                                    size: 50,
                                                    color: lightPink,
                                                  ),
                                                )
                                                    : Container(
                                                  height: 85,
                                                  width: 85,
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                      BorderRadius
                                                          .circular(10),
                                                      color: Colors.blue,
                                                      image: DecorationImage(
                                                          image: NetworkImage(
                                                              cakeSearchList[
                                                              i][
                                                              'MainCakeImage']),
                                                          fit: BoxFit
                                                              .cover)),
                                                ),
                                                SizedBox(width: 8),
                                                Expanded(
                                                    child: Container(
                                                        child: Column(
                                                            crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                            children: [
                                                              Container(
                                                                // width:120,
                                                                child: Text(
                                                                  '${cakeSearchList[i]['CakeName']}',
                                                                  style: TextStyle(
                                                                      color: darkBlue,
                                                                      fontWeight:
                                                                      FontWeight.bold,
                                                                      fontFamily:
                                                                      'Poppins',
                                                                      fontSize: 12),
                                                                  maxLines: 2,
                                                                  overflow: TextOverflow
                                                                      .ellipsis,
                                                                ),
                                                              ),
                                                              SizedBox(height: 5),
                                                              Container(
                                                                // width:120,
                                                                child: Text.rich(
                                                                  TextSpan(
                                                                      text:
                                                                      'Price Rs.${cakeSearchList[i]['BasicCakePrice']}/Kg Min Quantity '
                                                                          '${cakeSearchList[i]['MinWeight']} ',
                                                                      style: TextStyle(
                                                                          color:
                                                                          Colors.grey,
                                                                          fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                          fontFamily:
                                                                          'Poppins',
                                                                          fontSize: 10),
                                                                      children: [
                                                                        TextSpan(
                                                                          text: cakeSearchList[i]
                                                                          [
                                                                          'BasicCustomisationPossible'] ==
                                                                              "y"
                                                                              ? "Basic Customisation Available"
                                                                              : 'No Customisations Available',
                                                                          style: TextStyle(
                                                                              color: Colors
                                                                                  .grey,
                                                                              fontWeight:
                                                                              FontWeight
                                                                                  .bold,
                                                                              fontFamily:
                                                                              'Poppins',
                                                                              fontSize:
                                                                              10),
                                                                        )
                                                                      ]),
                                                                ),
                                                              ),
                                                              SizedBox(height: 5),
                                                              Container(
                                                                  height: 0.3,
                                                                  color:
                                                                  Color(0xffdddddd)),
                                                              SizedBox(height: 5),
                                                              Container(
                                                                // width:120,
                                                                child:double.parse(
                                                                    double.parse("${((calculateDistance(userLat, userLong, item[0]['GoogleLocation']['Latitude'],
                                                                        item[0]['GoogleLocation']['Longitude'])))}").toStringAsFixed(1)
                                                                )<2.0||
                                                                    double.parse(deliverCharge).toStringAsFixed(1)=="0.0"?
                                                                Text(
                                                                  'DELIVERY FREE',
                                                                  style: TextStyle(color: Colors.orange, fontSize: 10, fontFamily: poppins),
                                                                ):
                                                                Text(
                                                                  'DELIVERY CHARGE RS.${deliverCharge}',
                                                                  style: TextStyle(
                                                                      color:
                                                                      Colors.orange,
                                                                      fontWeight:
                                                                      FontWeight.bold,
                                                                      fontFamily:
                                                                      'Poppins',
                                                                      fontSize: 10),
                                                                  maxLines: 1,
                                                                  overflow: TextOverflow
                                                                      .ellipsis,
                                                                ),
                                                              ),
                                                            ])))
                                              ])),
                                        )
                                      ],
                                    ):
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        //header text (name , stars)
                                        Container(
                                            padding: EdgeInsets.only(
                                                top: 4,
                                                bottom: 4,
                                                left: 10,
                                                right: 10),
                                            decoration: BoxDecoration(
                                                borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(15),
                                                  topRight: Radius.circular(15),
                                                ),
                                                color: lightGrey),
                                            child: Row(children: [
                                              Container(
                                                width: cakeSearchList[i]
                                                ['VendorName'].toString().length >
                                                    25
                                                    ? 130
                                                    : 60,
                                                child: Text(
                                                  '${cakeSearchList[i]['VendorName']}',
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight: FontWeight.bold,
                                                      fontFamily: 'Poppins',
                                                      fontSize: 13),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  RatingBar.builder(
                                                    initialRating: double.parse(
                                                        cakeSearchList[i]
                                                        ['Ratings']
                                                            .toString()),
                                                    minRating: 1,
                                                    direction: Axis.horizontal,
                                                    allowHalfRating: true,
                                                    itemCount: 5,
                                                    itemSize: 14,
                                                    itemPadding:
                                                    EdgeInsets.symmetric(
                                                        horizontal: 1.0),
                                                    itemBuilder: (context, _) =>
                                                        Icon(
                                                          Icons.star,
                                                          color: Colors.amber,
                                                        ),
                                                    onRatingUpdate: (rating) {},
                                                  ),
                                                  Text(
                                                    ' ${cakeSearchList[i]['Ratings'].toString()}',
                                                    style: TextStyle(
                                                        color: Colors.black54,
                                                        fontWeight:
                                                        FontWeight.bold,
                                                        fontSize: 12,
                                                        fontFamily: poppins),
                                                  )
                                                ],
                                              ),
                                              Expanded(
                                                  child: Container(
                                                      alignment:
                                                      Alignment.centerRight,
                                                      child: InkWell(
                                                        onTap: () {
                                                          sendOthers(cakeSearchList[i]['_id'].toString());
                                                        },
                                                        child: Container(
                                                            alignment:
                                                            Alignment.center,
                                                            height: 25,
                                                            width: 25,
                                                            decoration:
                                                            BoxDecoration(
                                                                shape: BoxShape
                                                                    .circle,
                                                                color: Colors
                                                                    .white),
                                                            child: Icon(
                                                              Icons
                                                                  .arrow_forward_ios_sharp,
                                                              color: lightPink,
                                                              size: 15,
                                                            )),
                                                      )))
                                            ])),
                                        //body (image , cake name)
                                        InkWell(
                                          splashColor: Colors.red[100],
                                          onTap: () {
                                            sendOthers(cakeSearchList[i]['_id'].toString());
                                          },
                                          child: Container(
                                              padding: EdgeInsets.all(8),
                                              child: Row(children: [
                                                cakeSearchList[i]['ProductImage']
                                                    .isEmpty
                                                    ? Container(
                                                  height: 85,
                                                  width: 85,
                                                  alignment:
                                                  Alignment.center,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                    BorderRadius
                                                        .circular(15),
                                                    color: Colors.pink[100],
                                                  ),
                                                  child: Icon(
                                                    Icons.cake_outlined,
                                                    size: 50,
                                                    color: lightPink,
                                                  ),
                                                )
                                                    : Container(
                                                  height: 85,
                                                  width: 85,
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                      BorderRadius
                                                          .circular(15),
                                                      color: Colors.blue,
                                                      image: DecorationImage(
                                                          image: NetworkImage(
                                                              cakeSearchList[i]['ProductImage'][0]),
                                                          fit: BoxFit
                                                              .cover)),
                                                ),
                                                SizedBox(width: 8),
                                                Expanded(
                                                    child: Container(
                                                        child: Column(
                                                            crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                            children: [
                                                              Container(
                                                                // width:120,
                                                                child: Text(
                                                                  '${cakeSearchList[i]['ProductName']}',
                                                                  style: TextStyle(
                                                                      color: darkBlue,
                                                                      fontWeight:
                                                                      FontWeight.bold,
                                                                      fontFamily:
                                                                      'Poppins',
                                                                      fontSize: 12),
                                                                  maxLines: 2,
                                                                  overflow: TextOverflow
                                                                      .ellipsis,
                                                                ),
                                                              ),
                                                              SizedBox(height: 5),
                                                              Container(
                                                                // width:120,
                                                                child: Text.rich(
                                                                  cakeSearchList[i]['Type'].toString().toLowerCase()=="kg"?
                                                                  TextSpan(
                                                                      text:
                                                                      'Minimum Price : Rs.${cakeSearchList[i]['MinWeightPerKg']['PricePerKg']}/'
                                                                          '${cakeSearchList[i]['MinWeightPerKg']['Weight']}',
                                                                      style: TextStyle(
                                                                          color:
                                                                          Colors.grey,
                                                                          fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                          fontFamily:
                                                                          'Poppins',
                                                                          fontSize: 10),
                                                                      children: [
                                                                        TextSpan(
                                                                          text : "",
                                                                          style: TextStyle(
                                                                              color: Colors
                                                                                  .grey,
                                                                              fontWeight:
                                                                              FontWeight
                                                                                  .bold,
                                                                              fontFamily:
                                                                              'Poppins',
                                                                              fontSize:
                                                                              10),
                                                                        )
                                                                      ]):
                                                                  cakeSearchList[i]['Type'].toString().toLowerCase()=="unit"?
                                                                  TextSpan(
                                                                      text:
                                                                      'Minimum Price : Rs.${cakeSearchList[i]['MinWeightPerUnit'][0]['PricePerUnit']}/'
                                                                          '${cakeSearchList[i]['MinWeightPerUnit'][0]['Weight']}',
                                                                      style: TextStyle(
                                                                          color:
                                                                          Colors.grey,
                                                                          fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                          fontFamily:
                                                                          'Poppins',
                                                                          fontSize: 10),
                                                                      children: [
                                                                        TextSpan(
                                                                          text : "",
                                                                          style: TextStyle(
                                                                              color: Colors
                                                                                  .grey,
                                                                              fontWeight:
                                                                              FontWeight
                                                                                  .bold,
                                                                              fontFamily:
                                                                              'Poppins',
                                                                              fontSize:
                                                                              10),
                                                                        )
                                                                      ]):
                                                                  cakeSearchList[i]['Type'].toString().toLowerCase()=="box"?
                                                                  TextSpan(
                                                                      text:
                                                                      'Minimum Price : Rs.${cakeSearchList[i]['MinWeightPerBox'][0]['PricePerBox']} / Box',
                                                                      style: TextStyle(
                                                                          color:
                                                                          Colors.grey,
                                                                          fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                          fontFamily:
                                                                          'Poppins',
                                                                          fontSize: 10),
                                                                      children: [
                                                                        TextSpan(
                                                                          text : "",
                                                                          style: TextStyle(
                                                                              color: Colors
                                                                                  .grey,
                                                                              fontWeight:
                                                                              FontWeight
                                                                                  .bold,
                                                                              fontFamily:
                                                                              'Poppins',
                                                                              fontSize:
                                                                              10),
                                                                        )
                                                                      ]):TextSpan(
                                                                      text: ""
                                                                  ),
                                                                ),
                                                              ),
                                                              SizedBox(height: 5),
                                                              Container(
                                                                  height: 0.3,
                                                                  color:
                                                                  Color(0xffdddddd)),
                                                              SizedBox(height: 5),
                                                              Container(
                                                                // width:120,
                                                                child:
                                                                // double.parse(
                                                                //     double.parse("${((calculateDistance(userLat, userLong, item[0]['GoogleLocation']['Latitude'],
                                                                //         item[0]['GoogleLocation']['Longitude'])))}").toStringAsFixed(1)
                                                                // )<2.0||
                                                                //     double.parse(deliverCharge).toStringAsFixed(1)=="0.0"?
                                                                // Text(
                                                                //   'DELIVERY FREE',
                                                                //   style: TextStyle(color: Colors.orange, fontSize: 10, fontFamily: poppins),
                                                                // ):
                                                                Text(
                                                                  'DELIVERY CHARGE RS.${deliverCharge}',
                                                                  style: TextStyle(
                                                                      color:
                                                                      Colors.orange,
                                                                      fontWeight:
                                                                      FontWeight.bold,
                                                                      fontFamily:
                                                                      'Poppins',
                                                                      fontSize: 10),
                                                                  maxLines: 1,
                                                                  overflow: TextOverflow
                                                                      .ellipsis,
                                                                ),
                                                              ),
                                                            ])))
                                              ])),
                                        )
                                      ],
                                    ),
                                  );
                                }):
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text("No Result Found!" , style: TextStyle(
                                  fontFamily: "Poppins",
                                  fontSize: 15
                              ),),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )),
           ],
         ),
      ),
    );
  }
}
