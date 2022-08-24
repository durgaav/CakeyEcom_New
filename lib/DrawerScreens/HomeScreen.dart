import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:cakey/DrawerScreens/CustomiseCake.dart';
import 'package:cakey/screens/Hampers.dart';
import 'package:cakey/DrawerScreens/VendorsList.dart';
import 'package:cakey/screens/CakeDetails.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/rendering.dart';
import 'dart:io';
import 'dart:math';
import 'package:flutter/widgets.dart';
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
import '../drawermenu/NavDrawer.dart';
import '../screens/HamperDetails.dart';
import '../screens/Profile.dart';
import 'package:location/location.dart';
import '../screens/SingleVendor.dart';
import 'CakeTypes.dart';
import 'Notifications.dart';

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

  List hampers = [];

  //endregion

  //region Alerts

  //Default loader dialog
  void showAlertDialog() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
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
        if (searchCakeType[i].toString().toLowerCase() !=
            "customize your cake") {
          myList.add(searchCakeType[i]);
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
                                TextSpan(
                                  text: " If Any One * ",
                                  style: TextStyle(
                                      color: lightPink,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: "Poppins"),
                                )
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
                        runSpacing: 5,
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
                                  selectedFilter);
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
            child: Container(
              width: double.infinity,
              height: 90,
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                      color: lightPink, width: 1.5, style: BorderStyle.solid),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(14),
                    bottomRight: Radius.circular(14),
                  )),
              padding: EdgeInsets.all(5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(10)),
                      alignment: Alignment.center,
                      child: Transform.rotate(
                        angle: -120,
                        child: Icon(
                          Icons.campaign,
                          color: darkBlue,
                          size: 30,
                        ),
                      )),
                  SizedBox(
                    width: 7,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        child: Text(
                          'Complete Your Profile & Easy To Take\nYour Order',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: TextStyle(
                              color: darkBlue,
                              fontWeight: FontWeight.bold,
                              fontFamily: "Poppins",
                              fontSize: 12,
                              decoration: TextDecoration.none),
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Container(
                        height: 25,
                        width: 80,
                        child: RaisedButton(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25)),
                          color: lightPink,
                          onPressed: () {
                            Navigator.of(context).push(
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        Profile(
                                  defindex: 0,
                                ),
                                transitionsBuilder: (context, animation,
                                    secondaryAnimation, child) {
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
                          child: Text(
                            'PROFILE',
                            style: TextStyle(
                                color: Colors.white,
                                fontFamily: "Poppins",
                                fontSize: 10),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.topRight,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                            width: 35,
                            height: 35,
                            decoration: BoxDecoration(
                                color: Colors.black12,
                                borderRadius: BorderRadius.circular(10)),
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.close_outlined,
                              color: darkBlue,
                            )),
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }

  //endregion

  //region Functions

  //send details to next screen
  Future<void> sendDetailsToScreen(int index) async {
    //Local Vars
    List<String> cakeImgs = [];
    List<String> cakeWeights = [];
    List cakeFlavs = [];
    List cakeShapes = [];
    List cakeTiers = [];
    var prefs = await SharedPreferences.getInstance();

    String vendorAddress = cakeSearchList[index]['VendorAddress'];

    //region API LIST LOADING...
    //getting cake pics
    if (cakeSearchList[index]['AdditionalCakeImages'].isNotEmpty) {
      setState(() {
        for (int i = 0;
            i < cakeSearchList[index]['AdditionalCakeImages'].length;
            i++) {
          cakeImgs
              .add(cakeSearchList[index]['AdditionalCakeImages'][i].toString());
        }
      });
    } else {
      setState(() {
        cakeImgs = [cakeSearchList[index]['MainCakeImage'].toString()];
      });
    }

    // getting cake flavs
    if (cakeSearchList[index]['CustomFlavourList'].isNotEmpty ||
        cakeSearchList[index]['CustomFlavourList'] != null) {
      setState(() {
        cakeFlavs = cakeSearchList[index]['CustomFlavourList'];

        // for(int i = 0 ; i<cakesTypes[index]['CustomFlavourList'].length;i++){
        //   cakeFlavs.add(cakesTypes[index]['CustomFlavourList'][i].toString());
        // }
      });
    } else {
      setState(() {
        cakeFlavs = [];
      });
    }

    // getting cake tiers
    if (cakeSearchList[index]['TierCakeMinWeightAndPrice'] != null) {
      setState(() {
        cakeTiers = cakeSearchList[index]['TierCakeMinWeightAndPrice'];
      });
    } else {
      setState(() {
        cakeTiers = [];
      });
    }

    // getting cake shapes
    if (cakeSearchList[index]['CustomShapeList']['Info'].isNotEmpty ||
        cakeSearchList[index]['CustomShapeList']['Info'] != null) {
      setState(() {
        cakeShapes = cakeSearchList[index]['CustomShapeList']['Info'];
      });
    } else {
      setState(() {
        cakeShapes = [];
      });
    }

    if (cakeSearchList[index]['MinWeightList'].isNotEmpty ||
        cakeSearchList[index]['MinWeightList'] != null) {
      setState(() {
        for (int i = 0;
            i < cakeSearchList[index]['MinWeightList'].length;
            i++) {
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

    //API STRINGS AND INTS DATAS
    prefs.setString("cake_id", cakeSearchList[index]['_id'] ?? "null");
    prefs.setString("cakeModid", cakeSearchList[index]['Id'] ?? "null");
    prefs.setString(
        "cakeMainImage", cakeSearchList[index]['MainCakeImage'] ?? "null");
    prefs.setString("cakeName", cakeSearchList[index]['CakeName'] ?? "null");
    prefs.setString(
        "cakeCommName", cakeSearchList[index]['CakeCommonName'] ?? "null");
    prefs.setString(
        "cakeBasicFlav", cakeSearchList[index]['BasicFlavour'] ?? "null");
    prefs.setString(
        "cakeBasicShape", cakeSearchList[index]['BasicShape'] ?? "null");
    prefs.setString(
        "cakeMinWeight", cakeSearchList[index]['MinWeight'] ?? "null");
    prefs.setString(
        "cakeMinPrice", cakeSearchList[index]['BasicCakePrice'] ?? "null");
    prefs.setString("cakeEggorEggless",
        cakeSearchList[index]['DefaultCakeEggOrEggless'] ?? "null");
    prefs.setString("cakeEgglessAvail",
        cakeSearchList[index]['IsEgglessOptionAvailable'] ?? "null");
    prefs.setString("cakeEgglesCost",
        cakeSearchList[index]['BasicEgglessCostPerKg'] ?? "null");
    prefs.setString("cakeCostWithEggless",
        cakeSearchList[index]['BasicEgglessCostPerKg'] ?? "null");
    prefs.setString(
        "cakeTierPoss", cakeSearchList[index]['IsTierCakePossible'] ?? "null");
    prefs.setString(
        "cakeThemePoss", cakeSearchList[index]['ThemeCakePossible'] ?? "null");
    prefs.setString(
        "cakeToppersPoss", cakeSearchList[index]['ToppersPossible'] ?? "null");
    prefs.setString("cakeBasicCustom",
        cakeSearchList[index]['BasicCustomisationPossible'] ?? "null");
    prefs.setString("cakeFullCustom",
        cakeSearchList[index]['FullCustomisationPossible'] ?? "null");

    // if(selectedCakeType == ""){
    //   prefs.setString("cakeType", cakeSearchList[index]['CakeType'] ?? "null");
    //   prefs.setString(
    //       "cakeSubType", cakeSearchList[index]['CakeSubType'] ?? "null");
    // }else{
    //   prefs.setString("cakeType", selectedCakeType ?? "null");
    //   prefs.setString(
    //       "cakeSubType", selectedCakeType ?? "null");
    // }

    if(cakeSearchList[index]['MinTimeForDeliveryOfA3KgCake']!=null&&
        cakeSearchList[index]['MinTimeForDeliveryOfA5KgCake']!=null){
      prefs.setString("cake3kgminTime", cakeSearchList[index]['MinTimeForDeliveryOfA3KgCake'].toString());
      prefs.setString("cake5kgminTime", cakeSearchList[index]['MinTimeForDeliveryOfA5KgCake'].toString());
    }else{
      prefs.setString("cake3kgminTime", 'Nf');
      prefs.setString("cake5kgminTime", 'Nf');
    }
    prefs.setString("cakeminDelTime", cakeSearchList[index]['MinTimeForDeliveryOfDefaultCake'].toString());


    prefs.setString("cakeVendorLatitu", cakeSearchList[index]['GoogleLocation']['Latitude'].toString());
    prefs.setString("cakeVendorLongti", cakeSearchList[index]['GoogleLocation']['Longitude'].toString());


    prefs.setString(
        "cakeDescription", cakeSearchList[index]['Description'] ?? "null");
    prefs.setString(
        "cakeCategory", cakeSearchList[index]['CakeCategory'] ?? "null");
    prefs.setString(
        "cakeTopperPoss", cakeSearchList[index]['ToppersPossible'] ?? "null");

    prefs.setString(
        "cakeVendorid", cakeSearchList[index]['VendorID'] ?? "null");
    prefs.setString(
        "cakeVendorModid", cakeSearchList[index]['Vendor_ID'] ?? "null");
    prefs.setString(
        "cakeVendorName", cakeSearchList[index]['VendorName'] ?? "null");
    prefs.setString("cakeVendorPhone1",
        cakeSearchList[index]['VendorPhoneNumber1'] ?? "null");
    prefs.setString("cakeVendorPhone2",
        cakeSearchList[index]['VendorPhoneNumber2'] ?? "null");
    prefs.setString("cakeVendorAddress", vendorAddress);

    //INTEGERS
    prefs.setInt('cakeDiscount',
        int.parse(cakeSearchList[index]['Discount'].toString()));
    prefs.setInt('cakeTax', int.parse(cakeSearchList[index]['Tax'].toString()));
    prefs.setInt('cakeDiscount',
        int.parse(cakeSearchList[index]['Discount'].toString()));
    prefs.setDouble("cakeRating",
        double.parse(cakeSearchList[index]['Ratings'].toString()));

    Navigator.of(context).push(PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => CakeDetails(
        cakeShapes,
        cakeFlavs,
        [],
        cakeTiers,
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

    setState(() {
      if (category.isNotEmpty) {
        a = cakesList
            .where((element) => element['CakeName']
                .toString()
                .toLowerCase()
                .contains(category.toLowerCase()))
            .toList();
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
          c = cakesList
              .where((element) => element['VendorName']
                  .toString()
                  .toLowerCase()
                  .contains(vendorName.toLowerCase()))
              .toList();
        });
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
  Future<void> sendNearVendorDataToScreen(int index) async {
    var pref = await SharedPreferences.getInstance();

    pref.remove('singleVendorID');
    pref.remove('singleVendorFromCd');
    pref.remove('singleVendorRate');
    pref.remove('singleVendorName');
    pref.remove('singleVendorDesc');
    pref.remove('singleVendorPhone1');
    pref.remove('singleVendorPhone2');
    pref.remove('singleVendorDpImage');
    pref.remove('singleVendorAddress');
    pref.remove('singleVendorSpeciality');

    //common keyword single****
    pref.setString('singleVendorID', nearestVendors[index]['_id'] ?? 'null');
    pref.setBool('singleVendorFromCd', false);
    pref.setString('singleVendorRate',
        nearestVendors[index]['Ratings'].toString() ?? '0.0');
    pref.setString('singleVendorName',
        nearestVendors[index]['PreferredNameOnTheApp'] ?? 'null');
    pref.setString(
        'singleVendorDesc', nearestVendors[index]['Description'] ?? 'null');
    pref.setString(
        'singleVendorPhone1', nearestVendors[index]['PhoneNumber1'] ?? 'null');
    pref.setString(
        'singleVendorPhone2', nearestVendors[index]['PhoneNumber2'] ?? 'null');
    pref.setString(
        'singleVendorDpImage', nearestVendors[index]['ProfileImage'] ?? 'null');
    pref.setString(
        'singleVendorAddress', nearestVendors[index]['Address'] ?? 'null');
    pref.setString('singleVendorSpecial',
        nearestVendors[index]['YourSpecialityCakes'].toString());

    print(nearestVendors[index]['YourSpecialityCakes']);

    Navigator.push(
        context, MaterialPageRoute(builder: (context) => SingleVendor()));
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
      _getUserLocation();
      getAdminDeliveryCharge();
    });

    timerTrigger();
  }

  //update profile timer dialog for new users
  void timerTrigger() {
    if (newRegUser == true) {
      setState(() {
        Timer(Duration(seconds: 5), () {
          showDpUpdtaeDialog();
        });
      });
    } else {}
  }

  //Fetching user details from API....
  Future<void> fetchProfileByPhn() async {

    var prefs = await SharedPreferences.getInstance();
    try {
      http.Response response = await http.get(
          Uri.parse("https://cakey-database.vercel.app/api/users/list/"
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
    getHampers();
  }

  Future<void> getFbToken() async {
    await FirebaseMessaging.instance.getToken().then((value) => {
          setState(() {
            updateVendorsFbId(value!);
          }),
    });
  }

  Future<void> updateVendorsFbId(String token) async {

    print('fb tok...$token');

    var request = http.MultipartRequest(
        'PUT',
        Uri.parse(
            'https://cakey-database.vercel.app/api/users/update/$userID'));
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

    print(placemarks);

    setState(() {
      latude = lat;
      longtude = long;
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

  //fetch cake types
  Future<void> getCakeType() async {
    searchCakeType.clear();
    var mainList = [];
    List subType = [];

    var headers = {'Authorization': '$authToken'};
    var request = http.Request('GET',
        Uri.parse('https://cakey-database.vercel.app/api/caketype/list'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      mainList = jsonDecode(await response.stream.bytesToString());
      setState(() {
        print("CAKE TYPES : " + mainList.toString());
        if (mainList.length > 1) {
          for (int i = 0; i < mainList.length; i++) {

            if (mainList[i]['Type'] != null) {
              searchCakeType.add(mainList[i]['Type'].toString());
            }

            if(mainList[i]['SubType'].isNotEmpty && mainList[i]['SubType']!=null){
              for(int k = 0 ; k<mainList[i]['SubType'].length;k++){
                print(mainList[i]['SubType'][k]);
                searchCakeType.add(mainList[i]['SubType'][k].toString());
              }
            }

          }
        }

        print('Sub types>>>> $subType');

        searchCakeType.insert(0, "Customize your cake");
        // searchCakeType = searchCakeType.map((e)=>e.toString().toLowerCase()).toSet().toList();
        searchCakeType.toSet().toList();

        print('type cake ::::: $searchCakeType');

      });
    } else {
      print(response.reasonPhrase);
      setState((){
        searchCakeType.insert(0, "Customize your cake");
        searchCakeType.toSet().toList();
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
          Uri.parse("https://cakey-database.vercel.app/api/cake/list"),
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

            cakesList = myList
                .where((element) =>
                    calculateDistance(
                        userLat,
                        userLong,
                        element['GoogleLocation']['Latitude'],
                        element['GoogleLocation']['Longitude']) <=
                    10)
                .toList();

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
  }

  //getting recent orders list by UserId
  Future<void> getOrderList() async {
    recentOrders.clear();
    setState(() {
      ordersLoading = true;
    });
    try {
      http.Response response = await http.get(
          Uri.parse(
              "https://cakey-database.vercel.app/api/ordersandhamperorders/listbyuser/$userID"),
          headers: {"Authorization": "$authToken"});
      if (response.statusCode == 200) {

        if (response.contentLength! > 50) {
          setState(() {
            isNetworkError = false;
            ordersLoading = false;
            recentOrders = jsonDecode(response.body);
          });
        } else {
          setState(() {
            recentOrders = [];
            ordersLoading = false;
          });
        }


      } else {

        setState(() {
          // isNetworkError = true;
          ordersLoading = false;
        });

      }
    } catch (error) {
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
        ;
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

  Future<void> getVendorForDeliveryto(String token) async {
    showAlertDialog();
    print("location....");
    print(_userLocation!.latitude);
    print(_userLocation!.longitude);

    print("getting vendors....");
    filteredByEggList.clear();
    try {
      var res = await http.get(
          Uri.parse("https://cakey-database.vercel.app/api/vendors/list"),
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
          filteredByEggList = filteredByEggList.reversed.toList();

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
    try {
      var res = await http.get(
          Uri.parse("https://cakey-database.vercel.app/api/vendors/list"),
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
          filteredByEggList = filteredByEggList.reversed.toList();

          print(filteredByEggList);

        });
      } else {
        print("Error code : ${res.statusCode}");
      }
    } catch (e) {
      print(e);
    }
    print("getting vendors....done...");
    getOrderList();
  }

  //get Ads Banners
  Future<void> getHampers() async {
    hampers.clear();

    try{
      var headers = {
        'Authorization': '$authToken'
      };
      var request = http.Request('GET', Uri.parse('https://cakey-database.vercel.app/api/hamper/approvedlist'));

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        List map = jsonDecode(await response.stream.bytesToString());

        print(map);

        setState((){

          // hampers = map;

          hampers = map.where((element) =>
          calculateDistance(
              userLat,
              userLong,
              element['GoogleLocation']['Latitude'],
              element['GoogleLocation']['Longitude']) <=
              10)
              .toList();


          print("hamper length....${hampers.length}");

        });

      }
      else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response.reasonPhrase.toString()))
        );
      }
    }catch(e){
      print(e);
    }

    getCakeList();
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
      print('not connected');
    }
  }

  //get admins delivery fee
  Future<void> getAdminDeliveryCharge() async {
    var pref = await SharedPreferences.getInstance();
    var map = [];

    var headers = {'Authorization': '$authToken'};
    var request = http.Request('GET',
        Uri.parse('https://cakey-database.vercel.app/api/deliverycharge/list'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      map = jsonDecode(await response.stream.bytesToString());

      if(map.isNotEmpty){
        print(map[0]["Amount"]);
        print(map[0]["Km"]);

        setState(() {
          deliveryChargeFromAdmin = int.parse(map[0]["Amount"].toString());
          deliverykmFromAdmin = int.parse(map[0]["Km"].toString());

          pref.setInt("todayDeliveryCharge", deliveryChargeFromAdmin);
          pref.setInt("todayDeliveryKm", deliverykmFromAdmin);
        });
      }else{
        deliveryChargeFromAdmin = int.parse("0");
        deliverykmFromAdmin = int.parse("0");

        pref.setInt("todayDeliveryCharge", deliveryChargeFromAdmin);
        pref.setInt("todayDeliveryKm", deliverykmFromAdmin);
      }

    } else {
      print(response.reasonPhrase);
    }
  }

  //endregion

  //onStart
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration.zero, () async {
      loadPrefs();
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    profileUrl = context.watch<ContextData>().getProfileUrl();

    //searching..
    if (searchText.isNotEmpty) {
      cakeSearchList = cakesList
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
          DateTime now = DateTime.now();
          if (currentBackPressTime == null ||
              now.difference(currentBackPressTime!) > Duration(seconds: 2)) {
            currentBackPressTime = now;
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text('Tap again to exit.')));
            return Future.value(false);
          }
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
                        onTap: () {
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
                              fontSize: 16)),
                    ],
                  ),
                  Row(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.of(context).push(
                                PageRouteBuilder(
                                  pageBuilder: (context, animation,
                                          secondaryAnimation) =>
                                      Notifications(),
                                  transitionsBuilder: (context, animation,
                                      secondaryAnimation, child) {
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
                              padding: EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(6)),
                              child: Icon(
                                Icons.notifications_none,
                                color: darkBlue,
                                size: 22,
                              ),
                            ),
                          ),
                          Positioned(
                            left: 15,
                            top: 6,
                            child: CircleAvatar(
                              radius: 3.7,
                              backgroundColor: Colors.white,
                              child: CircleAvatar(
                                radius: 2.7,
                                backgroundColor: Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                                blurRadius: 3,
                                color: Colors.black,
                                spreadRadius: 0)
                          ],
                        ),
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        Profile(
                                  defindex: 0,
                                ),
                                transitionsBuilder: (context, animation,
                                    secondaryAnimation, child) {
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
                          child: profileUrl != "null"
                              ? CircleAvatar(
                                  radius: 14.7,
                                  backgroundColor: Colors.white,
                                  child: CircleAvatar(
                                      radius: 13,
                                      backgroundImage:
                                          NetworkImage("$profileUrl")),
                                )
                              : CircleAvatar(
                                  radius: 14.7,
                                  backgroundColor: Colors.white,
                                  child: CircleAvatar(
                                      radius: 13,
                                      backgroundImage:
                                          AssetImage("assets/images/user.png")),
                                ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
        key: _scaffoldKey,
        body: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
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
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            'Delivery to',
                            style: TextStyle(
                                color: Colors.black54,
                                fontWeight: FontWeight.bold,
                                fontFamily: poppins,
                                fontSize: 13),
                          )
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(left: 8),
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: [
                          Container(
                            width: 200,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  showAddressEdit = !showAddressEdit;
                                });
                                FocusScope.of(context).unfocus();
                              },
                              child: Text(
                                '$userLocalityAdr',
                                style: TextStyle(
                                    fontFamily: poppins,
                                    fontSize: 15,
                                    color: darkBlue,
                                    fontWeight: FontWeight.bold,
                                    overflow: TextOverflow.ellipsis),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                showAddressEdit = !showAddressEdit;
                              });
                              FocusScope.of(context).unfocus();
                            },
                            child: Icon(Icons.arrow_drop_down),
                          )
                        ],
                      ),
                    ),
                    showAddressEdit
                        ? Container(
                            padding: EdgeInsets.only(right: 8, top: 10),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 45,
                                    child: TextField(
                                      controller: deliverToCtrl,
                                      style: TextStyle(
                                          fontFamily: poppins,
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold),
                                      onChanged: (String? text) {
                                        setState(() {});
                                      },
                                      decoration: InputDecoration(
                                          hintText: "Delivery location...",
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
                                                deliverToCtrl.text = "";
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
                                      color: darkBlue,
                                      borderRadius: BorderRadius.circular(7)),
                                  child: Semantics(
                                    child: IconButton(
                                        splashColor: Colors.black26,
                                        onPressed: () async {
                                          var pref = await SharedPreferences
                                              .getInstance();
                                          FocusScope.of(context).unfocus();
                                          if (deliverToCtrl.text.isNotEmpty) {
                                            List<geocode.Location> location =
                                                await geocode
                                                    .locationFromAddress(
                                                        deliverToCtrl.text);
                                            print(location);
                                            setState(() {
                                              userLat = location[0].latitude;
                                              userLong = location[0].longitude;
                                              pref.setString(
                                                  'userLatitute', "${userLat}");
                                              pref.setString('userLongtitude',
                                                  "${userLong}");
                                              pref.setString(
                                                  "userCurrentLocation",
                                                  deliverToCtrl.text);
                                              userLocalityAdr =
                                                  deliverToCtrl.text;
                                              getVendorForDeliveryto(authToken);
                                              getHampers();
                                              getCakeList();
                                              getCakeType();
                                            });
                                          }
                                        },
                                        icon: Icon(
                                          Icons.download_done_outlined,
                                          color: Colors.white,
                                        )),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Container(
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

              !activeSearch
                  ? Container(
                      color: lightGrey,
                      height: height * 0.73,
                      child: RefreshIndicator(
                        onRefresh: () async {
                          setState(() {
                            loadPrefs();
                          });
                        },
                        child: SingleChildScrollView(
                          child: Column(
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
                                          height: 0.5,
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
                                          height: 0.5,
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
                                    )
                                  :
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
                                          padding: EdgeInsets.all(15),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'Hampers',
                                                style: TextStyle(
                                                    fontFamily: poppins,
                                                    fontSize: 15,
                                                    color: darkBlue,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              hampers.length>3?
                                              InkWell(
                                                onTap: () async {
                                                  var pr = Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              Hampers()));
                                                },
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      'See All',
                                                      style: TextStyle(
                                                          color: lightPink,
                                                          fontFamily: poppins,
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
                                              ):Container(),
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
                                            height: 140,
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


                                                      pref.setString("hamperImage", hampers[i]['HamperImage']??'null');
                                                      pref.setString("hamperName", hampers[i]['HampersName']??'null');
                                                      pref.setString("hamperPrice", hampers[i]['Price']??'null');
                                                      pref.setString("hamper_ID", hampers[i]['_id']??'null');
                                                      pref.setString("hamperDescription", hampers[i]['Description']??'null');
                                                      pref.setString("hamperVendorName", hampers[i]['VendorName']??'null');
                                                      pref.setString("hamperVendorID", hampers[i]['VendorID']??'null');
                                                      pref.setString("hamperVendor_ID", hampers[i]['Vendor_ID']??'null');
                                                      pref.setString("hamperVendorAddress", hampers[i]['VendorAddress']??'null');
                                                      pref.setString("hamperVendorPhn1", hampers[i]['VendorPhoneNumber1']??'null');
                                                      pref.setString("hamperVendorPhn2", hampers[i]['VendorPhoneNumber2']??'null');
                                                      pref.setString("hamperLat", hampers[i]['GoogleLocation']['Latitude'].toString()??'null');
                                                      pref.setString("hamperLong", hampers[i]['GoogleLocation']['Longitude'].toString()??'null');
                                                      pref.setStringList("hamperProducts", productsContains??[]);

                                                      print(productsContains);

                                                      Navigator.push(context, MaterialPageRoute(builder: (context)=>HamperDetails()));

                                                    },
                                                    child: Container(
                                                      alignment:
                                                          Alignment.bottomLeft,
                                                      margin: EdgeInsets.all(8),
                                                      width: 230,
                                                      decoration: hampers[i]['HamperImage'] == null ||
                                                              hampers[i]['HamperImage']
                                                                  .toString()
                                                                  .isEmpty
                                                          ? BoxDecoration(
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .white,
                                                                  style: BorderStyle
                                                                      .solid,
                                                                  width: 1.5),
                                                              color: Colors.white,
                                                              // boxShadow: [
                                                              //
                                                              // ],
                                                              borderRadius: BorderRadius.circular(
                                                                  22),
                                                              image: DecorationImage(
                                                                  image: AssetImage(
                                                                      'assets/images/cakebaner.jpg'),
                                                                  fit: BoxFit
                                                                      .cover))
                                                          : BoxDecoration(
                                                              border: Border.all(
                                                                  color: Colors.white,
                                                                  style: BorderStyle.solid,
                                                                  width: 1.5),
                                                              color: Colors.white,
                                                              borderRadius: BorderRadius.circular(22),
                                                              image: DecorationImage(image: NetworkImage(hampers[i]['HamperImage'].toString()), fit: BoxFit.cover)),
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
                                              ? 480
                                              : 200,
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
                                                padding: EdgeInsets.all(15),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      'Type of Cakes',
                                                      style: TextStyle(
                                                          fontFamily: poppins,
                                                          fontSize: 15,
                                                          color: darkBlue,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    searchCakeType.length>3?
                                                    InkWell(
                                                      onTap: () async {
                                                        var pr = Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        CakeTypes()));
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
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
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
                                                height: 145,
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
                                                          return searchCakeType[
                                                                      index]
                                                                  .toLowerCase()
                                                                  .contains(
                                                                      'customize your cake')
                                                              ? Container(
                                                                  width: 100,
                                                                  child:
                                                                      InkWell(
                                                                    onTap:
                                                                        () async {
                                                                      Navigator.push(
                                                                          context,
                                                                          MaterialPageRoute(
                                                                              builder: (context) => CustomiseCake()));
                                                                    },
                                                                    child:
                                                                        Column(
                                                                      children: [
                                                                        Container(
                                                                          height:
                                                                              80,
                                                                          width:
                                                                              80,
                                                                          decoration: BoxDecoration(
                                                                              borderRadius: BorderRadius.circular(20),
                                                                              border: Border.all(color: Colors.white, width: 2),
                                                                              image: DecorationImage(image: AssetImage('assets/images/customcake.png'), fit: BoxFit.cover)),
                                                                        ),
                                                                        SizedBox(
                                                                          height:
                                                                              2,
                                                                        ),
                                                                        Text(
                                                                          "Customise Cake",
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
                                                                  width: 100,
                                                                  child:
                                                                      InkWell(
                                                                    onTap: () {

                                                                      setState((){
                                                                        searchByGivenFilter("", "", "", [searchCakeType[index]]);
                                                                        selectedCakeType = searchCakeType[index];
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
                                                                          height:
                                                                              80,
                                                                          width:
                                                                              80,
                                                                          decoration: BoxDecoration(
                                                                              borderRadius: BorderRadius.circular(20),
                                                                              border: Border.all(color: Colors.white, width: 2),
                                                                              color: Colors.pink[200],
                                                                              image: DecorationImage(image: AssetImage('assets/images/themecake.png'), fit: BoxFit.contain)),
                                                                        ),
                                                                        SizedBox(
                                                                          height:
                                                                              2,
                                                                        ),
                                                                        Text(
                                                                          searchCakeType[index] == null
                                                                              ? 'No name'
                                                                              : "${searchCakeType[index][0].toString().toUpperCase() +
                                                                              searchCakeType[index].toString().substring(1).toLowerCase()}",
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
                                                      height: 0.5,
                                                      width: double.infinity,
                                                      margin: EdgeInsets.only(
                                                          left: 10, right: 10),
                                                      color: Colors.black26,
                                                    )
                                                  : Container(),
                                              recentOrders.isNotEmpty
                                                  ? Column(
                                                      children: [
                                                        Container(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  15),
                                                          width:
                                                              double.infinity,
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
                                                                        15,
                                                                    color:
                                                                        darkBlue,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                              recentOrders.length>3?
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

                                                        Container(
                                                          child:
                                                              ListView.builder(
                                                                  shrinkWrap:
                                                                      true,
                                                                  itemCount: recentOrders.length<3?recentOrders.length:3,
                                                                  physics:
                                                                      NeverScrollableScrollPhysics(),
                                                                  itemBuilder:
                                                                      (c, i) {
                                                                    var color =
                                                                        Colors
                                                                            .blue;

                                                                    if (recentOrders[i]['Status']
                                                                            .toString()
                                                                            .toLowerCase() ==
                                                                        "new") {
                                                                      color = Colors
                                                                          .blue;
                                                                    } else if (recentOrders[i]['Status']
                                                                            .toString()
                                                                            .toLowerCase() ==
                                                                        "preparing") {
                                                                      color = Colors
                                                                          .blue;
                                                                    } else if (recentOrders[i]['Status']
                                                                            .toString()
                                                                            .toLowerCase() ==
                                                                        "cancelled") {
                                                                      color =
                                                                          Colors
                                                                              .red;
                                                                    } else if (recentOrders[i]['Status']
                                                                            .toString()
                                                                            .toLowerCase() ==
                                                                        "out for delivery") {
                                                                      color = Colors
                                                                          .green;
                                                                    } else if (recentOrders[i]['Status']
                                                                            .toString()
                                                                            .toLowerCase() ==
                                                                        "delivered") {
                                                                      color = Colors
                                                                          .green;
                                                                    }

                                                                    return recentOrders[i]['CakeName']!=null?
                                                                    GestureDetector(
                                                                      onTap:
                                                                          () async {
                                                                        Navigator.of(context)
                                                                            .push(
                                                                          PageRouteBuilder(
                                                                            pageBuilder: (context, animation, secondaryAnimation) =>
                                                                                Profile(
                                                                              defindex: 1,
                                                                            ),
                                                                            transitionsBuilder: (context,
                                                                                animation,
                                                                                secondaryAnimation,
                                                                                child) {
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
                                                                      child:
                                                                          Card(
                                                                        elevation:
                                                                            0.5,
                                                                        shape: RoundedRectangleBorder(
                                                                            borderRadius:
                                                                                BorderRadius.circular(20)),
                                                                        child:
                                                                            Container(
                                                                          padding:
                                                                              EdgeInsets.all(5),
                                                                          decoration: BoxDecoration(
                                                                              color: Colors.white,
                                                                              borderRadius: BorderRadius.circular(20)),
                                                                          child:
                                                                              Row(
                                                                            children: [
                                                                              recentOrders[i]['Image'] != null
                                                                                  ? CircleAvatar(
                                                                                      backgroundImage: NetworkImage(recentOrders[i]['Image']),
                                                                                      radius: 25,
                                                                                    )
                                                                                  : CircleAvatar(
                                                                                      backgroundImage: AssetImage("assets/images/chefdoll.jpg"),
                                                                                      radius: 25,
                                                                                    ),
                                                                              SizedBox(
                                                                                width: 5,
                                                                              ),
                                                                              Expanded(
                                                                                child: Column(
                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                  children: [
                                                                                    Text(
                                                                                      recentOrders[i]['CakeName'] != null ? recentOrders[i]['CakeName'] : "Customised Cake",
                                                                                      style: TextStyle(color: darkBlue, fontFamily: "Poppins", fontSize: 13, fontWeight: FontWeight.bold),
                                                                                    ),
                                                                                    Row(
                                                                                      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                      children: [
                                                                                        Text(
                                                                                          recentOrders[i]['VendorName']!=null?
                                                                                          recentOrders[i]['VendorName'] + " |":"Premium Vendor |",
                                                                                          style: TextStyle(color: Colors.black, fontFamily: "Poppins", fontSize: 13),
                                                                                        ),
                                                                                        SizedBox(
                                                                                          width: 3,
                                                                                        ),
                                                                                        Text(
                                                                                          recentOrders[i]['Status'],
                                                                                          style: TextStyle(color: color, fontFamily: "Poppins", fontSize: 12),
                                                                                        ),
                                                                                      ],
                                                                                    )
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                              SizedBox(
                                                                                width: 6,
                                                                              ),
                                                                              Text(
                                                                                "Rs." + recentOrders[i]['Total'] + " ",
                                                                                style: TextStyle(color: lightPink, fontFamily: "Poppins", fontSize: 14, fontWeight: FontWeight.bold),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ):
                                                                    recentOrders[i]['HampersName']!=null?
                                                                    GestureDetector(
                                                                      onTap:
                                                                          () async {
                                                                        Navigator.of(context)
                                                                            .push(
                                                                          PageRouteBuilder(
                                                                            pageBuilder: (context, animation, secondaryAnimation) =>
                                                                                Profile(
                                                                                  defindex: 1,
                                                                                ),
                                                                            transitionsBuilder: (context,
                                                                                animation,
                                                                                secondaryAnimation,
                                                                                child) {
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
                                                                      child:
                                                                      Card(
                                                                        elevation:
                                                                        0.5,
                                                                        shape: RoundedRectangleBorder(
                                                                            borderRadius:
                                                                            BorderRadius.circular(20)),
                                                                        child:
                                                                        Container(
                                                                          padding:
                                                                          EdgeInsets.all(5),
                                                                          decoration: BoxDecoration(
                                                                              color: Colors.white,
                                                                              borderRadius: BorderRadius.circular(20)),
                                                                          child:
                                                                          Row(
                                                                            children: [
                                                                              recentOrders[i]['HamperImage'] != null
                                                                                  ? CircleAvatar(
                                                                                backgroundImage: NetworkImage(recentOrders[i]['HamperImage']),
                                                                                radius: 25,
                                                                              )
                                                                                  : CircleAvatar(
                                                                                backgroundImage: AssetImage("assets/images/chefdoll.jpg"),
                                                                                radius: 25,
                                                                              ),
                                                                              SizedBox(
                                                                                width: 5,
                                                                              ),
                                                                              Expanded(
                                                                                child: Column(
                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                  children: [
                                                                                    Text(
                                                                                      recentOrders[i]['HampersName'] != null ? recentOrders[i]['HampersName']: "Customised Cake",
                                                                                      style: TextStyle(color: darkBlue, fontFamily: "Poppins", fontSize: 13, fontWeight: FontWeight.bold),
                                                                                      maxLines: 2,
                                                                                    ),
                                                                                    Row(
                                                                                      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                      children: [
                                                                                        Text(
                                                                                          recentOrders[i]['VendorName']!=null?
                                                                                          recentOrders[i]['VendorName'] + " |":"Premium Vendor |",
                                                                                          style: TextStyle(color: Colors.black, fontFamily: "Poppins", fontSize: 13),
                                                                                        ),
                                                                                        SizedBox(
                                                                                          width: 3,
                                                                                        ),
                                                                                        Text(
                                                                                          recentOrders[i]['Status'],
                                                                                          style: TextStyle(color: color, fontFamily: "Poppins", fontSize: 12),
                                                                                        ),
                                                                                      ],
                                                                                    )
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                              SizedBox(
                                                                                width: 6,
                                                                              ),
                                                                              Text(
                                                                                "Rs." + recentOrders[i]['Total'] + " ",
                                                                                style: TextStyle(color: lightPink, fontFamily: "Poppins", fontSize: 14, fontWeight: FontWeight.bold),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ):
                                                                    recentOrders[i]['ProductName']!=null?
                                                                    GestureDetector(
                                                                      onTap:
                                                                          () async {
                                                                        Navigator.of(context)
                                                                            .push(
                                                                          PageRouteBuilder(
                                                                            pageBuilder: (context, animation, secondaryAnimation) =>
                                                                                Profile(
                                                                                  defindex: 1,
                                                                                ),
                                                                            transitionsBuilder: (context,
                                                                                animation,
                                                                                secondaryAnimation,
                                                                                child) {
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
                                                                      child:
                                                                      Card(
                                                                        elevation:
                                                                        0.5,
                                                                        shape: RoundedRectangleBorder(
                                                                            borderRadius:
                                                                            BorderRadius.circular(20)),
                                                                        child:
                                                                        Container(
                                                                          padding:
                                                                          EdgeInsets.all(5),
                                                                          decoration: BoxDecoration(
                                                                              color: Colors.white,
                                                                              borderRadius: BorderRadius.circular(20)),
                                                                          child:
                                                                          Row(
                                                                            children: [
                                                                              recentOrders[i]['Image'] != null
                                                                                  ? CircleAvatar(
                                                                                backgroundImage: NetworkImage(recentOrders[i]['Image']),
                                                                                radius: 25,
                                                                              )
                                                                                  : CircleAvatar(
                                                                                backgroundImage: AssetImage("assets/images/chefdoll.jpg"),
                                                                                radius: 25,
                                                                              ),
                                                                              SizedBox(
                                                                                width: 5,
                                                                              ),
                                                                              Expanded(
                                                                                child: Column(
                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                  children: [
                                                                                    Text(
                                                                                      recentOrders[i]['ProductName'] != null ?
                                                                                      recentOrders[i]['ProductName']: "Customised Cake",
                                                                                      style: TextStyle(color: darkBlue, fontFamily: "Poppins", fontSize: 13, fontWeight: FontWeight.bold),
                                                                                      maxLines: 2,
                                                                                    ),
                                                                                    Row(
                                                                                      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                      children: [
                                                                                        Text(
                                                                                          recentOrders[i]['VendorName']!=null?
                                                                                          recentOrders[i]['VendorName'] + " |":"Premium Vendor |",
                                                                                          style: TextStyle(color: Colors.black, fontFamily: "Poppins", fontSize: 13),
                                                                                        ),
                                                                                        SizedBox(
                                                                                          width: 3,
                                                                                        ),
                                                                                        Text(
                                                                                          recentOrders[i]['Status'],
                                                                                          style: TextStyle(color: color, fontFamily: "Poppins", fontSize: 12),
                                                                                        ),
                                                                                      ],
                                                                                    )
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                              SizedBox(
                                                                                width: 6,
                                                                              ),
                                                                              Text(
                                                                                "Rs." + recentOrders[i]['Total'] + " ",
                                                                                style: TextStyle(color: lightPink, fontFamily: "Poppins", fontSize: 14, fontWeight: FontWeight.bold),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ):
                                                                    Container();
                                                                  }),
                                                        )

                                                        // Container(
                                                        //     height: 200,
                                                        //     child: ordersLoading
                                                        //         ? Center(
                                                        //         child: Transform.scale(
                                                        //             scale: 0.8,
                                                        //             child:
                                                        //             CircularProgressIndicator()))
                                                        //         : recentOrders.length > 0
                                                        //         ? ListView.builder(
                                                        //         itemCount: recentOrders
                                                        //             .length <
                                                        //             3
                                                        //             ? recentOrders
                                                        //             .length
                                                        //             : 3,
                                                        //         scrollDirection:
                                                        //         Axis.horizontal,
                                                        //         itemBuilder:
                                                        //             (context,
                                                        //             index) {
                                                        //           return GestureDetector(
                                                        //             onTap: () {
                                                        //               Navigator.of(
                                                        //                   context)
                                                        //                   .push(
                                                        //                 PageRouteBuilder(
                                                        //                   pageBuilder: (context,
                                                        //                       animation,
                                                        //                       secondaryAnimation) =>
                                                        //                       Profile(
                                                        //                         defindex:
                                                        //                         1,
                                                        //                       ),
                                                        //                   transitionsBuilder: (context,
                                                        //                       animation,
                                                        //                       secondaryAnimation,
                                                        //                       child) {
                                                        //                     const begin = Offset(
                                                        //                         1.0,
                                                        //                         0.0);
                                                        //                     const end =
                                                        //                         Offset.zero;
                                                        //                     const curve =
                                                        //                         Curves.ease;
                                                        //
                                                        //                     final tween = Tween(
                                                        //                         begin:
                                                        //                         begin,
                                                        //                         end:
                                                        //                         end);
                                                        //                     final curvedAnimation =
                                                        //                     CurvedAnimation(
                                                        //                       parent:
                                                        //                       animation,
                                                        //                       curve:
                                                        //                       curve,
                                                        //                     );
                                                        //
                                                        //                     return SlideTransition(
                                                        //                       position:
                                                        //                       tween.animate(curvedAnimation),
                                                        //                       child:
                                                        //                       child,
                                                        //                     );
                                                        //                   },
                                                        //                 ),
                                                        //               );
                                                        //             },
                                                        //             child:
                                                        //             Container(
                                                        //               margin: EdgeInsets
                                                        //                   .only(
                                                        //                   left:
                                                        //                   10,
                                                        //                   right:
                                                        //                   10),
                                                        //               child: Stack(
                                                        //                 alignment:
                                                        //                 Alignment
                                                        //                     .topCenter,
                                                        //                 children: [
                                                        //                   recentOrders[index]['Image']==null||
                                                        //                   recentOrders[index]['Image'].toString().isEmpty?
                                                        //                   Container(
                                                        //                     width: width /
                                                        //                         2.2,
                                                        //                     height:
                                                        //                     135,
                                                        //                     decoration: BoxDecoration(
                                                        //                         borderRadius:
                                                        //                         BorderRadius.circular(15),
                                                        //                         image: DecorationImage(fit: BoxFit.cover,
                                                        //                             image: AssetImage("assets/images/chefdoll.jpg"))
                                                        //                     ),
                                                        //                   ):
                                                        //                   Container(
                                                        //                     width: width /
                                                        //                         2.2,
                                                        //                     height:
                                                        //                     135,
                                                        //                     decoration: BoxDecoration(
                                                        //                         borderRadius:
                                                        //                         BorderRadius.circular(15),
                                                        //                         image: DecorationImage(fit: BoxFit.cover,
                                                        //                             image: NetworkImage('${recentOrders[index]['Image']}'))),
                                                        //                   ),
                                                        //                   Positioned(
                                                        //                     top: 85,
                                                        //                     child:
                                                        //                     Card(
                                                        //                       shape:
                                                        //                       RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                        //                       elevation:
                                                        //                       7,
                                                        //                       child:
                                                        //                       Container(
                                                        //                         padding:
                                                        //                         EdgeInsets.all(8),
                                                        //                         width:
                                                        //                         155,
                                                        //                         child:
                                                        //                         Column(
                                                        //                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        //                           mainAxisSize: MainAxisSize.min,
                                                        //                           children: [
                                                        //                             Container(
                                                        //                                 alignment: Alignment.centerLeft,
                                                        //                                 child: Container(
                                                        //                                   width: 120,
                                                        //                                   child: Text(
                                                        //                                     recentOrders[index]['CakeName']!=null?
                                                        //                                     '${recentOrders[index]['CakeName']}':"My Cake",
                                                        //                                     style: TextStyle(color: darkBlue, fontWeight: FontWeight.bold, fontFamily: poppins, fontSize: 12),
                                                        //                                     maxLines: 1,
                                                        //                                     overflow: TextOverflow.ellipsis,
                                                        //                                   ),
                                                        //                                 )),
                                                        //                             SizedBox(
                                                        //                               height: 4,
                                                        //                             ),
                                                        //                             Row(
                                                        //                               children: [
                                                        //                                 Icon(
                                                        //                                   Icons.account_circle,
                                                        //                                 ),
                                                        //                                 Container(
                                                        //                                     width: 105,
                                                        //                                     child: Text(
                                                        //                                       recentOrders[index]['PremiumVendor']=='y'?
                                                        //                                       ' Premium Vendor':' ${recentOrders[index]['VendorName']}',
                                                        //                                       overflow: TextOverflow.ellipsis,
                                                        //                                       style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold, fontFamily: poppins, fontSize: 11),
                                                        //                                       maxLines: 1,
                                                        //                                     ))
                                                        //                               ],
                                                        //                             ),
                                                        //                             SizedBox(
                                                        //                               height: 4,
                                                        //                             ),
                                                        //                             Container(
                                                        //                               height: 0.5,
                                                        //                               color: Colors.black54,
                                                        //                               margin: EdgeInsets.only(left: 5, right: 5),
                                                        //                             ),
                                                        //                             SizedBox(
                                                        //                               height: 4,
                                                        //                             ),
                                                        //                             Row(
                                                        //                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        //                               children: [
                                                        //                                 Text(
                                                        //                                   "₹ ${double.parse(recentOrders[index]['Total'].toString()).toStringAsFixed(2)}",
                                                        //                                   style: TextStyle(color: lightPink, fontWeight: FontWeight.bold, fontFamily: poppins, fontSize: 12),
                                                        //                                   maxLines: 1,
                                                        //                                 ),
                                                        //                                 recentOrders[index]['Status'].toString().toLowerCase() == 'delivered'
                                                        //                                     ? Text(
                                                        //                                   "${recentOrders[index]['Status'].toString()}",
                                                        //                                   style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontFamily: poppins, fontSize: 11),
                                                        //                                 )
                                                        //                                     : Text(
                                                        //                                   "${recentOrders[index]['Status']}",
                                                        //                                   style: TextStyle(color: recentOrders[index]['Status'].toString().toLowerCase() == 'cancelled'?
                                                        //                                   Colors.red:Colors.blueAccent, fontWeight: FontWeight.bold, fontFamily: poppins, fontSize: 11),
                                                        //                                 )
                                                        //                               ],
                                                        //                             )
                                                        //                           ],
                                                        //                         ),
                                                        //                       ),
                                                        //                     ),
                                                        //                   ),
                                                        //                 ],
                                                        //               ),
                                                        //             ),
                                                        //           );
                                                        //         })
                                                        //         : Column(
                                                        //       mainAxisAlignment:
                                                        //       MainAxisAlignment
                                                        //           .center,
                                                        //       crossAxisAlignment:
                                                        //       CrossAxisAlignment
                                                        //           .center,
                                                        //       children: [
                                                        //         Icon(
                                                        //           Icons
                                                        //               .shopping_basket_outlined,
                                                        //           color:
                                                        //           lightPink,
                                                        //           size: 35,
                                                        //         ),
                                                        //         Text(
                                                        //           'No Recent Orders',
                                                        //           style: TextStyle(
                                                        //               color:
                                                        //               darkBlue,
                                                        //               fontFamily:
                                                        //               "Poppins",
                                                        //               fontWeight:
                                                        //               FontWeight
                                                        //                   .bold,
                                                        //               fontSize:
                                                        //               15),
                                                        //         ),
                                                        //       ],
                                                        //     )
                                                        // ),


                                                      ],
                                                    )
                                                  : Container(),
                                            ],
                                          ),
                                        ),
                                        //Vendors........
                                        Container(
                                          padding: EdgeInsets.all(15),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    'Vendors list',
                                                    style: TextStyle(
                                                        fontSize: 15,
                                                        color: darkBlue,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontFamily: poppins),
                                                  ),
                                                  Text(
                                                    '  (10km radius)',
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
                                                        return InkWell(
                                                          splashColor:
                                                              Colors.pink[100],
                                                          onTap: () =>
                                                              sendNearVendorDataToScreen(
                                                                  index),
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
                                                                            15)),
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
                                                                              15)),
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
                                                                              borderRadius: BorderRadius.circular(15),
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
                                                                              borderRadius: BorderRadius.circular(15),
                                                                              color: index.isOdd ? Colors.purple : Colors.teal),
                                                                          child:
                                                                              Text(
                                                                            nearestVendors[index]['PreferredNameOnTheApp'][0].toString().toUpperCase(),
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
                                                                    padding:
                                                                        EdgeInsets
                                                                            .all(5),
                                                                    child:
                                                                        Column(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceBetween,
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
                                                                                    '${nearestVendors[index]['PreferredNameOnTheApp'][0].toString().toUpperCase() + "${nearestVendors[index]['PreferredNameOnTheApp'].toString().substring(1).toLowerCase()}"}',
                                                                                    overflow: TextOverflow.ellipsis,
                                                                                    style: TextStyle(color: darkBlue, fontWeight: FontWeight.bold, fontSize: 14, fontFamily: poppins),
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
                                                                                    sendNearVendorDataToScreen(index);
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
                                                                            double.parse("${(calculateDistance(userLat, userLong, nearestVendors[index]['GoogleLocation']['Latitude'],
                                                                                nearestVendors[index]['GoogleLocation']['Longitude'])).toInt()}")==0.0?
                                                                            Text(
                                                                              'DELIVERY FREE',
                                                                              style: TextStyle(color: Colors.orange, fontSize: 10, fontFamily: poppins),
                                                                            ):
                                                                            Text(
                                                                              "${double.parse("${(calculateDistance(userLat, userLong, nearestVendors[index]['GoogleLocation']['Latitude'], nearestVendors[index]['GoogleLocation']['Longitude'])).toInt()}")} KM Delivery Fee Rs.${(deliveryChargeFromAdmin / deliverykmFromAdmin) * (calculateDistance(userLat, userLong, nearestVendors[index]['GoogleLocation']['Latitude'], nearestVendors[index]['GoogleLocation']['Longitude'])).toInt()}",
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
                                                                                      style: TextStyle(color: Colors.black, fontSize: 9, fontWeight: FontWeight.bold, fontFamily: poppins),
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
                          ),
                        ),
                      ),
                    )
                  : Visibility(
                      visible: isFiltered ? true : false,
                      child: (cakeSearchList.length == 0)
                          ? Text(
                              'No Similar Data Found',
                              style: TextStyle(
                                  fontFamily: "Poppins",
                                  fontWeight: FontWeight.bold),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: cakeSearchList.length,
                              itemBuilder: (c, i) {
                                return Container(
                                  margin: EdgeInsets.only(
                                      left: 15, right: 15, top: 5, bottom: 5),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      color: Colors.white,
                                      border: Border.all(
                                          color: Colors.grey[400]!,
                                          width: 0.5)),
                                  child: Column(
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
                                              color: Colors.grey[300]),
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
                                                        sendDetailsToScreen(i);
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
                                          sendDetailsToScreen(i);
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
                                                        height: 0.5,
                                                        color:
                                                            Color(0xffdddddd)),
                                                    SizedBox(height: 5),
                                                    Container(
                                                      // width:120,
                                                      child: Text(
                                                        double.parse("${(calculateDistance(userLat, userLong, cakeSearchList[i]['GoogleLocation']['Latitude'],
                                                            cakeSearchList[i]['GoogleLocation']['Longitude'])).toInt()}")!=0.0?
                                                        'DELIVERY CHARGE RS.${(deliveryChargeFromAdmin / deliverykmFromAdmin) *
                                                            (calculateDistance(userLat, userLong, cakeSearchList[i]['GoogleLocation']['Latitude'],
                                                                cakeSearchList[i]['GoogleLocation']['Longitude'])).toInt()}':'DELIVERY FREE',
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
                              }),
                    )
            ],
          ),
        ),
      ),
    );
  }
}
