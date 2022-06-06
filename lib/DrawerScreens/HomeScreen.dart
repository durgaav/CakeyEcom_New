import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:cakey/screens/CakeDetails.dart';
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
import '../screens/Profile.dart';
import 'package:location/location.dart';

//This is home screen.........
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  //TODO : API AUTH
  // final response = await http.get(url, headers: {
  // 'Content-Type': 'application/json',
  // 'Accept': 'application/json',
  // 'Authorization': 'Bearer $token',
  // });

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
  bool egglesSwitch = false;
  //prefs val..
  bool newRegUser = true;
  bool profileRemainder = false;
  bool isNetworkError = false;
  bool ordersLoading = true;
  bool isAllLoading = true;
  bool vendorsLoading = true;
  //for search
  bool isFiltered = false;
  bool activeSearch = false;

  //Strings
  String poppins = "Poppins";
  String phoneNumber = '';
  String authToken = '';
  String networkMsg = "";
  String searchText = '';

  //latlong
  String location = 'Null, Press Button';
  //address
  String userLocalityAdr = 'Searching...';
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
  List filterTypeList=["Birthday","Wedding","Theme Cake","Normal Cake"];
  List selectedFilter=[];

  List adsSlogans = [
    "Christmas cake",
    "Rainbow Blasts",
    "Happy Birthday"
  ];
  List adsImages = [
    "https://png.pngtree.com/background/20210714/original/pngtree-marry-christmas-background-with-cake-picture-image_1229140.jpg",
    "https://t4.ftcdn.net/jpg/03/98/87/59/360_F_398875973_mt8RQRetLLhlQEI2n4Tayxo07cXnhhoK.jpg",
    "https://www.meme-arsenal.com/memes/980f4a38ccbd4c71c6a2236bea5f49cc.jpg"
  ];


//search all type
  List cakeSearchList = [];
  List categoryList = [];
  List subCategoryList = [];
  //for filter search
  List cakeTypeList=[];

  List vendorNameList = [];
  List typesList = [];
  //TextFields controls for search....
  var cakeCategoryCtrl = new TextEditingController();
  var cakeSubCategoryCtrl = new TextEditingController();
  var cakeVendorCtrl = new TextEditingController();
  var cakeLocationCtrl = new TextEditingController();
  var mainSearchCtrl = new TextEditingController();



  //latt and long and maps
  double latude = 0.0;
  double longtude = 0.0;
  List<geocode.Placemark> placemarks = [];

  late bool _serviceEnabled;
  late PermissionStatus _permissionGranted;
  LocationData? _userLocation;
  Location myLocation = Location();

  //endregion

  //region Alerts

  //send details to next screen
  Future<void> sendDetailsToScreen(int index) async {
    //Local Vars
    List<String> cakeImgs = [];
    List<String> cakeFlavs = [];
    List<String> cakeWeights = [];
    List<String> cakeShapes = [];
    List<String> cakeTopings = [];
    var prefs = await SharedPreferences.getInstance();

    //region API LIST
    //getting cake pics
    if (cakesTypes[index]['Images'].isNotEmpty) {
      setState(() {
        for (int i = 0; i < cakesTypes[index]['Images'].length; i++) {
          cakeImgs.add(cakesTypes[index]['Images'][i].toString());
        }
      });
    } else {
      setState(() {
        cakeImgs = [];
      });
    }



    //getting cake flavs
    if (cakesTypes[index]['FlavourList'].isNotEmpty) {
      setState(() {
        for (int i = 0; i < cakesTypes[index]['FlavourList'].length; i++) {
          cakeFlavs.add(cakesTypes[index]['FlavourList'][i].toString());
        }
      });
    } else {
      setState(() {
        cakeFlavs = [];
      });
    }

    //getting cake shapes
    if (cakesTypes[index]['ShapeList'].isNotEmpty) {
      setState(() {
        for (int i = 0; i < cakesTypes[index]['ShapeList'].length; i++) {
          cakeShapes.add(cakesTypes[index]['ShapeList'][i].toString());
        }
      });
    } else {
      setState(() {
        cakeShapes = [];
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
    if (cakesTypes[index]['WeightList'].isNotEmpty) {
      setState(() {
        for (int i = 0; i < cakesTypes[index]['WeightList'].length; i++) {
          cakeWeights.add(cakesTypes[index]['WeightList'][i].toString());
        }
      });
    } else {
      setState(() {
        cakeWeights = [];
      });
    }
    //endregion

    //set The preferece...

    //API LIST
    prefs.setStringList('cakeImages', cakeImgs);
    // prefs.setStringList('cakeFalvours', cakeFlavs);
    prefs.setStringList('cakeWeights', cakeWeights);
    // prefs.setStringList('cakeShapes', cakeShapes);
    prefs.setStringList('cakeToppings', cakeTopings);

    //API STRINGS AND INTS
    prefs.setString('cakeRatings', cakesTypes[index]['Ratings'].toString());
    prefs.setString(
        'cakeEggOrEggless', cakesTypes[index]['EggOrEggless'].toString());
    prefs.setString('cakeNames', cakesTypes[index]['Title'].toString());
    prefs.setString('cakeId', cakesTypes[index]['_id'].toString());
    prefs.setString(
        'cakeDiscount', cakesTypes[index]['Discount'].toString());
    prefs.setString('cakePrice', cakesTypes[index]['Price'].toString());
    prefs.setString(
        'cakeDescription', cakesTypes[index]['Description'].toString());
    prefs.setString('cakeType', cakesTypes[index]['TypeOfCake'].toString());
    prefs.setString(
        'cakeDelCharge', cakesTypes[index]['DeliveryCharge'].toString());
    prefs.setInt('cakeTaxRate', cakesTypes[index]['Tax'].toInt());

    prefs.setString('vendorID', cakesTypes[index]['VendorID'].toString());
    prefs.setString(
        'vendorName', cakesTypes[index]['VendorName'].toString());
    prefs.setString(
        'vendorMobile', cakesTypes[index]['VendorPhoneNumber'].toString());

    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => CakeDetails(
            cakesTypes[index]['ShapeList'].toList(),
            cakesTypes[index]['FlavourList'].toList(),
            cakesTypes[index]['ArticleList'].toList()),
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
    setState(() {
      cakeLocationCtrl.text = userLocalityAdr;
    });

    showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(20), topLeft: Radius.circular(20)
          ),
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
                          Text(
                            'SEARCH',
                            style: TextStyle(
                                color: darkBlue,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontFamily: "Poppins"),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                              // searchCakeVendor = '';
                              // searchCakeSubType = '';
                              // searchCakeCate = '';
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
                              hintText: "Category",
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
                              hintText: "Sub Category",
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
                              Icon(Icons.sentiment_very_satisfied_rounded),
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
                      // Container(
                      //   height: 45,
                      //   child: TextField(
                      //     controller: cakeLocationCtrl,
                      //     decoration: InputDecoration(
                      //         contentPadding: EdgeInsets.all(5),
                      //         hintText: "Location",
                      //         hintStyle: TextStyle(fontFamily: "Poppins", fontSize: 13),
                      //         prefixIcon: Icon(Icons.location_on),
                      //         suffixIcon: IconButton(
                      //           onPressed: (){},
                      //           icon: Icon(Icons.my_location),
                      //         ),
                      //         border: OutlineInputBorder()
                      //     ),
                      //   ),
                      // ),
                      // SizedBox(
                      //   height: 5,
                      // ),
                      // //kilo meter radius buttons.........
                      // Wrap(
                      //   runSpacing: 5.0,
                      //   spacing: 5.0,
                      //   children: [
                      //     OutlinedButton(
                      //       onPressed: (){},
                      //       child: Text('5 KM',style: TextStyle(color: darkBlue,fontFamily: "Poppins"),),
                      //     ),
                      //     OutlinedButton(
                      //       onPressed: (){},
                      //       child: Text('10 KM',style: TextStyle(color: darkBlue,fontFamily: "Poppins"),),
                      //     ),
                      //     OutlinedButton(
                      //       onPressed: (){},
                      //       child: Text('15 KM',style: TextStyle(color: darkBlue,fontFamily: "Poppins"),),
                      //     ),
                      //     OutlinedButton(
                      //       onPressed: (){},
                      //       child: Text('20 KM',style: TextStyle(color: darkBlue,fontFamily: "Poppins"),),
                      //     ),
                      //   ],
                      //
                      // ),
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

                      // Align(
                      //   alignment: Alignment.centerLeft,
                      //   child: Text('Star Ratting',style: TextStyle(color: darkBlue,fontSize: 16,
                      //       fontWeight: FontWeight.bold,fontFamily: "Poppins"),),
                      // ),
                      // SizedBox(height: 5,),
                      // //stars rattings...
                      // Wrap(
                      //   runSpacing: 5.0,
                      //   spacing: 5.0,
                      //   children: [
                      //     OutlinedButton(
                      //       onPressed: (){},
                      //       child: Text('3 Star',style: TextStyle(fontSize: 12,color: darkBlue,fontFamily: "Poppins"),),
                      //     ),
                      //     OutlinedButton(
                      //       onPressed: (){},
                      //       child: Text('4 Star',style: TextStyle(fontSize: 12,color: darkBlue,fontFamily: "Poppins"),),
                      //     ),
                      //     OutlinedButton(
                      //       onPressed: (){},
                      //       child: Text('5 Star',style: TextStyle(fontSize: 12,color: darkBlue,fontFamily: "Poppins"),),
                      //     ),
                      //   ],
                      // ),
                      //
                      // SizedBox(height: 5,),
                      // //Divider
                      // Container(
                      //   height: 1.0,
                      //   color: Colors.black26,
                      // ),
                      // //cake types....
                      // SizedBox(height: 5,),

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


                      // Container(
                      //   height: 200,
                      //     child: ListView.builder(
                      //         itemCount: filterTypeList.length,
                      //         shrinkWrap: true,
                      //         itemBuilder: (context, index) {
                      //           return
                      //             Wrap(
                      //               children:
                      //               filterTypeList.map(
                      //                     (item) {
                      //                   bool isSelected = false;
                      //                   // if (selectCakeType.contains(item)) {
                      //                   //   isSelected = true;
                      //                   // }
                      //                   return GestureDetector(
                      //                     onTap: () {
                      //                       // if (!selectCakeType.contains(item)) {
                      //                       //   if (selectCakeType.length < 5) {
                      //                       //     setState(() {
                      //                       //       selectCakeType.add(item);
                      //                       //     });
                      //                       //
                      //                       //   }
                      //                       // } else {
                      //                       //   setState(() {
                      //                       //     selectCakeType
                      //                       //         .removeWhere((element) => element == item);
                      //                       //   });
                      //                       //
                      //                       // }
                      //                     },
                      //                     child: Container(
                      //                         margin: EdgeInsets.symmetric(
                      //                             horizontal: 5, vertical: 4),
                      //                         child: Container(
                      //                           height: 30,
                      //                           padding: EdgeInsets.symmetric(
                      //                               vertical: 5, horizontal: 12),
                      //                           decoration: BoxDecoration(
                      //                               color:isSelected?lightPink:Colors.white,
                      //                               borderRadius: BorderRadius.circular(5),
                      //                               border: Border.all(
                      //                                   color:isSelected?lightPink:Colors.grey,width: 1)),
                      //                           child: Text(
                      //                             item,
                      //                             style: TextStyle(
                      //                                 color:
                      //                                 isSelected ? Colors.white : darkBlue,
                      //                                 fontSize: 14),
                      //                           ),
                      //                         )),
                      //                   );
                      //                 },
                      //               ).toList(),
                      //             );
                      //
                      //         }),
                      // ),


                      Container(
                        height: 100,
                        child: ListView.builder(
                            itemCount: 1,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              return
                                Wrap(
                                  children:
                                  filterTypeList.map(
                                        (item) {
                                      bool isSelected = false;
                                      if (selectedFilter!.contains(item)) {
                                        isSelected = true;
                                      }
                                      return GestureDetector(
                                        onTap: () {
                                          setState((){
                                            if (!selectedFilter.contains(item)) {
                                              if (selectedFilter.length < 5) {
                                                selectedFilter.add(item);

                                              }
                                            } else {
                                              selectedFilter
                                                  .removeWhere((element) => element == item);
                                            }
                                          });
                                        },
                                        child: Container(
                                            margin: EdgeInsets.symmetric(
                                                horizontal: 5, vertical: 4),
                                            child: Container(
                                              height: 30,
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 5, horizontal: 12),
                                              decoration: BoxDecoration(
                                                  color: isSelected?lightPink:Colors.white,
                                                  borderRadius: BorderRadius.circular(5),
                                                  border: Border.all(width: 1,color: isSelected?lightPink:Colors.grey)),
                                              child: Text(item, style: TextStyle(fontSize: 14,color:isSelected?Colors.white:darkBlue,fontFamily: "Poppins"),),
                                            )),
                                      );
                                    },
                                  ).toList(),
                                );
                            }),
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
                      child: Icon(
                        Icons.volume_up_rounded,
                        color: darkBlue,
                        size: 30,
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

  //search by filters
  void searchByGivenFilter(
      String category, String subCategory, String vendorName, List filterCType) {
    categoryList = [];
    subCategoryList = [];
    vendorNameList = [];
    cakeTypeList =[];
    activeSearch = true;
    mainSearchCtrl.text =
    '$searchCakeCate $searchCakeSubType $searchCakeVendor ${selectedFilter.toString().replaceAll("[", "").
    replaceAll("]", "")}';
    // search=true;
    setState(() {
      if (category.isEmpty && subCategory.isEmpty && vendorName.isEmpty && filterCType.isEmpty) {
        categoryList = [];
        subCategoryList = [];
        vendorNameList = [];
        cakeTypeList=[];
        isFiltered = false;
        activeSearch = false;
      }
      else if(filterCType.isNotEmpty){
        isFiltered=true;

        for(int i=0;i<cakesList.length;i++){
          if(cakesList[i]['TypeOfCake'].isNotEmpty){
            for(int j = 0 ; j<filterCType.length;j++){
              if(cakesList[i]['TypeOfCake'].contains(filterCType[j])){
                cakeTypeList.add(cakesList[i]);
              }
            }
          }
        }
        // cakeTypeList=cakesList.where((element) => element['TypeOfCake'].toString().toLowerCase().contains(filterCType.toString().toLowerCase())).toList();
      }
      if (category.isNotEmpty) {
        isFiltered = true;
        categoryList = cakesList
            .where((element) => element['Category']
            .toString()
            .toLowerCase()
            .contains(category.toLowerCase()))
            .toList();
      }

      if (subCategory.isNotEmpty) {
        isFiltered = true;
        activeSearch = true;
        subCategoryList = cakesList
            .where((element) => element['SubCategory']
            .toString()
            .toLowerCase()
            .contains(subCategory.toLowerCase()))
            .toList();
      }


      if (vendorName.isNotEmpty) {
        isFiltered = true;
        setState(() {
          activeSearch = true;
          vendorNameList = cakesList
              .where((element) => element['VendorName']
              .toString()
              .toLowerCase()
              .contains(vendorName.toLowerCase()))
              .toList();
        });

        cakesTypes = categoryList.toList() +
            subCategoryList.toList() +
            vendorNameList.toList()+cakeTypeList.toList();
        cakesTypes = cakesTypes.toSet().toList();
      }
    });
  }

  //endregion

  //region Functions

  //send nearest vendor details.
  Future<void> sendNearVendorDataToScreen(int index) async {
    var pref = await SharedPreferences.getInstance();

    String address = "${nearestVendors[index]['Address']['Street']} , "
        "${nearestVendors[index]['Address']['City']} , "
        "${nearestVendors[index]['Address']['District']} , "
        "${nearestVendors[index]['Address']['Pincode']} , ";

    //common keyword single****
    pref.setString('singleVendorID', nearestVendors[index]['_id']);
    pref.setString('singleVendorName', nearestVendors[index]['VendorName']);
    pref.setString('singleVendorDesc',
        nearestVendors[index]['Description'] ?? 'No description');
    pref.setString('singleVendorPhone',
        nearestVendors[index]['PhoneNumber'] ?? '0000000000');
    pref.setString(
        'singleVendorDpImage', nearestVendors[index]['ProfileImage'] ?? 'null');
    pref.setString('singleVendorDelivery',
        nearestVendors[index]['DeliveryCharge'] ?? 'null');
    pref.setString('singleVendorAddress', address ?? 'null');

    context.read<ContextData>().setCurrentIndex(4);
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
    });
  }

  //update profile timer dialog for new users
  void timerTrigger() {
    if (newRegUser == true) {
      setState(() {
        Timer(Duration(seconds: 5), () {
          showDpUpdtaeDialog();
        });
      });
    } else {

    }
  }

  //Fetching user details from API....
  Future<void> fetchProfileByPhn() async {
    showAlertDialog();
    var prefs = await SharedPreferences.getInstance();

    try {
      http.Response response = await http
          .get(Uri.parse("https://cakey-database.vercel.app/api/users/list/"
          "${int.parse(phoneNumber)}"),
          headers: {"Authorization":"$authToken"}
      );
      if (response.statusCode == 200) {
        // Navigator.pop(context);
        setState(() {

          List body = jsonDecode(response.body);



          userID = body[0]['_id'].toString();
          userAddress = body[0]['Address'].toString();
          userProfileUrl = body[0]['ProfileImage'].toString();
          context.read<ContextData>().setProfileUrl(userProfileUrl);
          userName = body[0]['UserName'].toString();

          if(userName=="null"||userName==null||userAddress=="null"||
              userAddress==null){
            prefs.setBool('newRegUser', true);
           }

          prefs.setString('userID', userID);
          prefs.setString('userAddress', userAddress);
          prefs.setString('userName', userName);

          context.read<ContextData>().setUserName(userName);

          getCakeList();
          getOrderList();
          getVendorsList();
          Navigator.pop(context);
          timerTrigger();
        });
      } else {
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
        setState(() {
          isNetworkError = true;
          networkMsg =
          "Error Code : ${response.statusCode} ${response.reasonPhrase}";
        });
        Navigator.pop(context);
      }
    } on Exception catch (e) {
      setState(() {
        isNetworkError = true;
        networkMsg = "Check Your Connection!";
      });

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Check Your Connection! try again'),
        backgroundColor: Colors.amber,
        action: SnackBarAction(
          label: "Retry",
          onPressed: () => setState(() {
            loadPrefs();
          }),
        ),
      ));
    }
  }

  // //Fetching user's current location...Lat Long
  // Future<Position> _getGeoLocationPosition() async {
  //
  //   bool serviceEnabled;
  //   LocationPermission permission;
  //
  //   // Test if location services are enabled.
  //   serviceEnabled = await Geolocator.isLocationServiceEnabled();
  //   if (!serviceEnabled) {
  //     // Location services are not enabled don't continue
  //     // accessing the position and request users of the
  //     // App to enable the location services.
  //     await Geolocator.openLocationSettings();
  //     print('Location services are disabled.');
  //     return Future.error('Location services are disabled.');
  //   }
  //
  //   permission = await Geolocator.checkPermission();
  //   if (permission == LocationPermission.denied) {
  //     permission = await Geolocator.requestPermission();
  //     if (permission == LocationPermission.denied) {
  //       // Permissions are denied, next time you could try
  //       // requesting permissions again (this is also where
  //       // Android's shouldShowRequestPermissionRationale
  //       // returned true. According to Android guidelines
  //       // your App should show an explanatory UI now.
  //       print('Location permissions are denied');
  //       return Future.error('Location permissions are denied');
  //     }
  //   }
  //
  //   if (permission == LocationPermission.deniedForever) {
  //     // Permissions are denied forever, handle appropriately.
  //     print('Location permissions are permanently denied, we cannot request permissions.');
  //     return Future.error(
  //         'Location permissions are permanently denied, we cannot request permissions.');
  //   }
  //
  //   // When we reach here, permissions are granted and we can
  //   // continue accessing the position of the device.
  //
  //   return await Geolocator.getCurrentPosition(
  //       desiredAccuracy: LocationAccuracy.high
  //   );
  // }
  //

  //getting users accurate location address...

  Future<void> GetAddressFromLatLong(double? lat, double? long) async {
    var prefs = await SharedPreferences.getInstance();

    placemarks = await geocode.placemarkFromCoordinates(lat!, long!);

    // List<geocode.Location> latLong = await geocode
    //     .locationFromAddress("Street No.10,Coimbatore,Coimbatore,641107");

    geocode.Placemark place = placemarks[0];

    // print(placemarks);

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

    // print("Distance : "+calculateDistance(11.024932, 76.8994178, position.latitude, position.longitude).toString());
  }

  //Calculate the distance

  //Distance calculator
  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  //Fetching cake list API...
  Future<void> getCakeList() async {
    cakesList.clear();
    searchCakeType.clear();
    setState(() {
      isAllLoading = true;
    });

    try {
      http.Response response = await http
          .get(Uri.parse("https://cakey-database.vercel.app/api/cake/list"),
          headers: {"Authorization":"$authToken"}
      );
      if (response.statusCode == 200) {
        setState(() {
          isNetworkError = false;
          cakesList = jsonDecode(response.body);

          cakesList = cakesList.reversed.toList();

          for(int i=0;i<cakesList.length;i++){
            // print(searchCakeType[i]['TypeOfCake']);
            // rangeValuesList.add(int.parse(cakesList[i]['Price']));
            searchCakeType.add(cakesList[i]['TypeOfCake']);
          }

          searchCakeType = searchCakeType.toSet().toList();
          searchCakeType =searchCakeType.reversed.toList();
          searchCakeType.insert(0, "Customize your cake");
          isAllLoading = false;
        });
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
  }

  //Check the internet
  Future<void> checkNetwork() async {
    try {
      final result = await InternetAddress.lookup('www.google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Connected...!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ));
        setState(() {
          networkMsg = "Network connected";
        });
      }
    } on SocketException catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('You are offline!'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ));

      setState(() {
        networkMsg = "No Internet! Connect & tap here";
      });
    }
    // return connetedOrNot;
  }

  //getting recent orders list by UserId
  Future<void> getOrderList() async {
    recentOrders.clear();
    setState(() {
      ordersLoading = true;
    });

    try {
      http.Response response = await http.get(Uri.parse(
          "https://cakey-database.vercel.app/api/order/listbyuserid/$userID"),
          headers: {"Authorization":"$authToken"}
      );
      if (response.statusCode == 200) {

        if(response.contentLength!>50){
          setState(() {
            isNetworkError = false;
            ordersLoading = false;
            recentOrders = jsonDecode(response.body);
            recentOrders = recentOrders.reversed.toList();
          });
        }else{
          setState((){
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
    // Check if permission is granted
    _permissionGranted = await myLocation.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await myLocation.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        _permissionGranted = await myLocation.requestPermission();
        ;
      }
    }

    myLocation.changeSettings(accuracy: LocationAccuracy.balanced);

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
      print(
          _userLocation!.latitude.toString() + "  ${_userLocation!.longitude}");
    });

    GetAddressFromLatLong(_userLocation!.latitude, _userLocation!.longitude);
  }

  Future<void> getNearbyLoc() async {
    List<List<geocode.Location>> location = [];
    List myList = vendorsList;
    List newlist = [];


    try{
      for (var i = 0; i < myList.length; i++) {
        try {
          if (myList[i]['Address'] != null &&
              myList[i]['Address']['FullAddress'] != null) {
            location.add(await geocode
                .locationFromAddress(myList[i]['Address']['FullAddress']));

            myList[i].addEntries([
              MapEntry('lat', location[i][0].latitude),
              MapEntry('long', location[i][0].longitude),
            ]);
          }
        } catch (e) {
          print(e);
        }
      }

    }catch(e){
      print(e);
    }

    for(int i = 0 ;i<myList.length;i++){

      // try{
      //   print("***st***");
      //   print(latude);
      //   print(longtude);
      //   print(myList[i]['lat']);
      //   print(myList[i]['long']);
      //   print(myList[i]['Address']['FullAddress']);
      //   print(calculateDistance(latude, longtude, myList[i]['lat'], myList[i]['long']).toStringAsFixed(2));
      //   // print(calculateDistance(latude, longtude, 11.1526, 77.2109).toStringAsFixed(2));
      //   print("***end***");
      // }catch(e){
      //   print(e);
      // }

    }

  }

  //Get vendors list
  Future<void> getVendorsList() async {
    filteredByEggList.clear();

    try {
      var res = await http
          .get(Uri.parse("https://cakey-database.vercel.app/api/vendors/list"),
          headers: {"Authorization":"$authToken"}
      );

      if (res.statusCode == 200) {
        setState(() {
          vendorsList = jsonDecode(res.body);

          // getNearbyLoc();

          for (int i = 0; i < vendorsList.length; i++) {
            if (vendorsList[i]['Address'] != null &&
                vendorsList[i]['Address']['City']
                    .toString()
                    .toLowerCase()
                    .contains(userMainLocation.toLowerCase())) {
              setState(() {
                filteredByEggList.add(vendorsList[i]);
              });
            }
          }

          // filteredByEggList = vendorsList.where((element)=>element['Address']['City'].toString().toLowerCase().
          // contains(userMainLocation.toLowerCase())).toList();

          filteredByEggList = filteredByEggList.toSet().toList();
          filteredByEggList = filteredByEggList.reversed.toList();


          getNearbyLoc();

        });
      } else {
        print(res.statusCode);
      }
    } catch (e) {
      print("vendor error: $e");
    }
  }

  //endregion

  //onStart
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getUserLocation();
    Future.delayed(Duration.zero, () async {
      loadPrefs();
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    // Changing locations
    // myLocation.onLocationChanged.listen((LocationData currentLocation) {
    //   // Use current location
    //   setState(() {
    //     GetAddressFromLatLong(currentLocation.latitude, currentLocation.longitude);
    //   });
    //
    // });

    //perform search

    if (searchText.isNotEmpty) {
      setState(() {
        isFiltered = true;
        activeSearch = true;
      });
    } else {
      activeSearch = false;
      cakesTypes = searchCakeType;
      nearestVendors = searchVendors;
    }
    if (isFiltered == true) {
      categoryList = [];
      subCategoryList = [];
      vendorNameList = [];
      cakeTypeList=[];
      if (searchText.isNotEmpty) {
        setState(() {
          cakesTypes = cakesList
              .where((element) => element['Title']
              .toString()
              .toLowerCase()
              .contains(searchText.toLowerCase()))
              .toList();
          cakesTypes = cakesTypes.toList();

        });
      }
      if (cakeCategoryCtrl.text.isNotEmpty ||
          cakeSubCategoryCtrl.text.isNotEmpty ||
          cakeVendorCtrl.text.isNotEmpty||selectedFilter.isNotEmpty) {



        if (selectedFilter.isNotEmpty) {


          setState(() {
            isFiltered = true;
            activeSearch = true;
            for(int i=0;i<cakesList.length;i++){

              if(cakesList[i]['TypeOfCake'].isNotEmpty){
                for(int j = 0 ; j<selectedFilter.length;j++){

                  if(cakesList[i]['TypeOfCake'].contains(selectedFilter[j])){
                    cakeTypeList.add(cakesList[i]);

                  }
                }
              }
            }          });

        }

        if (cakeCategoryCtrl.text.isNotEmpty) {


          setState(() {
            isFiltered = true;

            activeSearch = true;

            categoryList = cakesList
                .where((element) => element['Category']
                .toString()
                .toLowerCase()
                .contains(cakeCategoryCtrl.text.toString().toLowerCase()))
                .toList();

          });

        }
        if (cakeSubCategoryCtrl.text.isNotEmpty) {

          setState(() {
            isFiltered = true;
            // print(activeSearch);
            activeSearch = true;
            // print(activeSearch);
            subCategoryList = cakesList
                .where((element) => element['SubCategory']
                .toString()
                .toLowerCase()
                .contains(
                cakeSubCategoryCtrl.text.toString().toLowerCase()))
                .toList();
            // print(vendorNameList);
          });

        }

        if (cakeVendorCtrl.text.isNotEmpty) {


          setState(() {
            isFiltered = true;
            // print(activeSearch);
            activeSearch = true;
            // print(activeSearch);
            vendorNameList = cakesList
                .where((element) => element['VendorName']
                .toString()
                .toLowerCase()
                .contains(cakeVendorCtrl.text.toString().toLowerCase()))
                .toList();
            // print(vendorNameList);
          });

        }
        cakesTypes = categoryList.toList() +
            subCategoryList.toList() +
            vendorNameList.toList()+cakeTypeList.toList();
        cakesTypes = cakesTypes.toSet().toList();

      }

    } else {
      setState(() {
        activeSearch = false;
        // cakeSearchList=cakesList;
        cakesTypes = searchCakeType;
        nearestVendors = searchVendors;
      });
    }

    //set egg or eggless
    if (egglesSwitch == false) {
      setState(() {
        nearestVendors = filteredByEggList
            .where((element) =>
        element['EggOrEggless'] == 'Egg' ||
            element['EggOrEggless'] == 'Both')
            .toList();
      });
    } else {
      setState(() {
        nearestVendors = filteredByEggList
            .where((element) => element['EggOrEggless'] == 'Eggless')
            .toList();
      });
    }

    return Scaffold(
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
                    child: Text(
                      '$userLocalityAdr',
                      style: TextStyle(
                          fontFamily: poppins,
                          fontSize: 15,
                          color: darkBlue,
                          fontWeight: FontWeight.bold),
                    ),
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
                          width: width * 0.79,
                          height: 50,
                          child: TextField(
                            style: TextStyle(
                                color: Colors.black,
                                fontFamily: poppins,
                                fontSize: 13,
                                fontWeight: FontWeight.bold),
                            controller: mainSearchCtrl,
                            onChanged: (String text) {
                              setState(() {
                                searchText = text;
                              });
                            },
                            decoration: InputDecoration(
                              hintText: "Search cake, vendor, etc...",
                              hintStyle:
                              TextStyle(fontFamily: poppins, fontSize: 13),
                              prefixIcon: Icon(Icons.search),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  FocusScope.of(context).unfocus();
                                  setState(() {
                                    mainSearchCtrl.text = "";
                                    searchText = "";
                                    searchCakeVendor = '';
                                    searchCakeSubType = '';
                                    searchCakeCate = '';
                                    cakeCategoryCtrl.text = '';
                                    cakeSubCategoryCtrl.text = '';
                                    cakeVendorCtrl.text = '';
                                    selectedFilter=[];
                                  });
                                },
                                icon: Icon(Icons.clear_sharp),
                              ),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              contentPadding: EdgeInsets.all(5),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Container(
                          width: width * 0.13,
                          height: 50,
                          decoration: BoxDecoration(
                              color: lightPink,
                              borderRadius: BorderRadius.circular(8)),
                          child: IconButton(
                              splashColor: Colors.black26,
                              onPressed: () {
                                FocusScope.of(context).unfocus();
                                showFilterBottom();
                              },
                              icon: Icon(
                                Icons.tune,
                                color: Colors.white,
                              )),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            //Tap here to retry....
            GestureDetector(
              onTap: () {
                setState(() {
                  loadPrefs();
                });
              },
              child: AnimatedContainer(
                height: isNetworkError ? 35 : 0,
                curve: Curves.ease,
                alignment: Alignment.center,
                color: Colors.red,
                duration: Duration(seconds: 2),
                child: Text(
                  '$networkMsg (-Tap Here-)',
                  style: TextStyle(
                      fontFamily: "Poppins", color: Colors.white, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
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
                    _getUserLocation();
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
                                  highlightColor: Colors.grey[300]!,
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
                                                  .circular(20),
                                              color:
                                              Colors.grey[400]),
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
                                                  .circular(20),
                                              color:
                                              Colors.grey[400]),
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
                                  highlightColor: Colors.grey[300]!,
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
                                                  .circular(20),
                                              color:
                                              Colors.grey[400]),
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
                                                  .circular(20),
                                              color:
                                              Colors.grey[400]),
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
                                  highlightColor: Colors.grey[300]!,
                                  child: Container(
                                    width: double.infinity,
                                    height: 125,
                                    margin: EdgeInsets.all(8),
                                    padding: EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      borderRadius:
                                      BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          height: 120,
                                          width: 90,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                              BorderRadius
                                                  .circular(20),
                                              color:
                                              Colors.grey[400]),
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
                          Container(
                              color: Colors.white,
                              height: 140,
                              child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: 3,
                                  itemBuilder: (c, i) {
                                    return Container(
                                      alignment:
                                      Alignment.bottomLeft,
                                      margin: EdgeInsets.all(8),
                                      width: 230,
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.white,
                                              style:
                                              BorderStyle.solid,
                                              width: 1.5),
                                          color: Colors.white,
                                          borderRadius:
                                          BorderRadius.circular(
                                              22),
                                          image: DecorationImage(
                                              image: NetworkImage(adsImages[i]),
                                              fit: BoxFit.cover)
                                      ),
                                      child: Padding(
                                        padding:
                                        const EdgeInsets.only(
                                            left: 8, bottom: 8),
                                        child: Column(
                                            mainAxisSize:
                                            MainAxisSize.min,
                                            crossAxisAlignment:
                                            CrossAxisAlignment
                                                .start,
                                            children: [
                                              Text(
                                                '${adsSlogans[i].toString().split(' ').first.toUpperCase()}',
                                                style: TextStyle(
                                                    color: Colors
                                                        .white,
                                                    fontWeight:
                                                    FontWeight
                                                        .bold,
                                                    fontSize: 25,
                                                    fontFamily:
                                                    'Poppins',
                                                  // shadows: [
                                                  //   Shadow( // bottomLeft
                                                  //       offset: Offset(-1.5, -1.5),
                                                  //       color: Colors.black54
                                                  //   ),
                                                  //   Shadow( // bottomRight
                                                  //       offset: Offset(1.5, -1.5),
                                                  //       color: Colors.black54
                                                  //   ),
                                                  //   Shadow( // topRight
                                                  //       offset: Offset(1.5, 1.5),
                                                  //       color: Colors.black54
                                                  //   ),
                                                  //   Shadow( // topLeft
                                                  //       offset: Offset(-1.5, 1.5),
                                                  //       color: Colors.black54
                                                  //   ),
                                                  // ]
                                                ),
                                              ),
                                              Text(
                                                "${adsSlogans[i].toString().split(' ')[1].toUpperCase()}",
                                                style: TextStyle(
                                                    color: Colors.primaries[Random().nextInt(Colors.primaries.length)],
                                                    fontWeight:
                                                    FontWeight
                                                        .bold,
                                                    fontSize: 25,
                                                    fontFamily:
                                                    'Poppins',
                                                    // shadows: [
                                                    //   Shadow( // bottomLeft
                                                    //       offset: Offset(-1.5, -1.5),
                                                    //       color: Colors.black54
                                                    //   ),
                                                    //   Shadow( // bottomRight
                                                    //       offset: Offset(1.5, -1.5),
                                                    //       color: Colors.black54
                                                    //   ),
                                                    //   Shadow( // topRight
                                                    //       offset: Offset(1.5, 1.5),
                                                    //       color: Colors.black54
                                                    //   ),
                                                    //   Shadow( // topLeft
                                                    //       offset: Offset(-1.5, 1.5),
                                                    //       color: Colors.black54
                                                    //   ),
                                                    // ]
                                                ),
                                              ),
                                            ]),
                                      ),
                                    );
                                  })),

                          Container(
                            height: 500,
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
                                      InkWell(
                                        onTap: () async {
                                          var pr =
                                          await SharedPreferences
                                              .getInstance();
                                          pr.setBool(
                                              'naveToHome', true);
                                          context
                                              .read<ContextData>()
                                              .setCurrentIndex(1);
                                          // getNearbyLoc();
                                          // Navigator.pushReplacement(context,
                                          // MaterialPageRoute(builder: (context)=>CakeTypes())
                                          // );
                                        },
                                        child: Row(
                                          children: [
                                            Text(
                                              'See All',
                                              style: TextStyle(
                                                  color: lightPink,
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
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.all(5),
                                  alignment: Alignment.centerLeft,
                                  height: 175,
                                  child: cakesTypes.isEmpty
                                      ? Center(
                                    child: Text(
                                      'No Results Found!',
                                      style: TextStyle(
                                          fontFamily:
                                          "Poppins",
                                          color: lightPink,
                                          fontWeight:
                                          FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                  )
                                      : ListView.builder(
                                      shrinkWrap: true,
                                      scrollDirection:
                                      Axis.horizontal,
                                      itemCount:
                                      cakesTypes.length,
                                      itemBuilder:
                                          (context, index) {
                                        return cakesTypes[index]
                                            .contains(
                                            'Customize your cake')
                                            ? Container(
                                          width: 150,
                                          child: InkWell(
                                            onTap:
                                                () async {
                                              FocusScope.of(
                                                  context)
                                                  .unfocus();
                                              var pr =
                                              await SharedPreferences
                                                  .getInstance();
                                              pr.setBool(
                                                  'naveToHome',
                                                  true);
                                              context
                                                  .read<
                                                  ContextData>()
                                                  .setCurrentIndex(
                                                  2);
                                            },
                                            child: Column(
                                              children: [
                                                Container(
                                                  height:
                                                  120,
                                                  width:
                                                  130,
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                      BorderRadius.circular(20),
                                                      border: Border.all(color: Colors.white, width: 2),
                                                      image: DecorationImage(image: AssetImage('assets/images/customcake.png'), fit: BoxFit.cover)),
                                                ),
                                                SizedBox(
                                                  height:
                                                  2,
                                                ),
                                                Text(
                                                  cakesTypes[index] ==
                                                      null
                                                      ? 'No name'
                                                      : "Customise Your \nCake",
                                                  style: TextStyle(
                                                      color:
                                                      darkBlue,
                                                      fontWeight: FontWeight
                                                          .bold,
                                                      fontFamily:
                                                      poppins,
                                                      fontSize:
                                                      13),
                                                  textAlign:
                                                  TextAlign.center,
                                                )
                                              ],
                                            ),
                                          ),
                                        )
                                            : Container(
                                          width: 150,
                                          child: InkWell(
                                            onTap:
                                                () async {
                                              FocusScope.of(
                                                  context)
                                                  .unfocus();
                                              var prefs =
                                              await SharedPreferences
                                                  .getInstance();
                                              prefs.setString(
                                                  'homeCakeType',
                                                  cakesTypes[
                                                  index]);
                                              prefs.setInt(
                                                  'homeCTindex',
                                                  index);
                                              prefs.setBool(
                                                  'isHomeCake',
                                                  true);
                                              context
                                                  .read<
                                                  ContextData>()
                                                  .setCurrentIndex(
                                                  1);
                                            },
                                            child: Column(
                                              children: [
                                                Container(
                                                  height:
                                                  120,
                                                  width:
                                                  130,
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                      BorderRadius.circular(20),
                                                      border: Border.all(color: Colors.white, width: 2),
                                                      image: DecorationImage(image: cakesList[index]['Images'].isEmpty ? NetworkImage('https://w0.peakpx.com/wallpaper/863/651/HD-wallpaper-red-cake-pastries-desserts-cakes-strawberry-cake-berry-cake.jpg') : NetworkImage(cakesList[index]['Images'][0].toString()), fit: BoxFit.cover)),
                                                ),
                                                SizedBox(
                                                  height:
                                                  2,
                                                ),
                                                Text(
                                                  cakesTypes[index] ==
                                                      null
                                                      ? 'No name'
                                                      : "${cakesTypes[index][0].toString().toUpperCase() + cakesTypes[index].toString().substring(1).toLowerCase()}",
                                                  style: TextStyle(
                                                      color:
                                                      darkBlue,
                                                      fontWeight: FontWeight
                                                          .bold,
                                                      fontFamily:
                                                      poppins,
                                                      fontSize:
                                                      13),
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
                                Container(
                                  height: 0.5,
                                  width: double.infinity,
                                  margin: EdgeInsets.only(
                                      left: 10, right: 10),
                                  color: Colors.black26,
                                ),
                                Container(
                                  padding: EdgeInsets.all(15),
                                  width: double.infinity,
                                  alignment: Alignment.centerLeft,
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment
                                        .spaceBetween,
                                    children: [
                                      Text(
                                        'Recent Ordered',
                                        style: TextStyle(
                                            fontFamily: poppins,
                                            fontSize: 15,
                                            color: darkBlue,
                                            fontWeight:
                                            FontWeight.bold
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () async {
                                          Navigator.of(context)
                                              .push(
                                            PageRouteBuilder(
                                              pageBuilder: (context,
                                                  animation,
                                                  secondaryAnimation) =>
                                                  Profile(
                                                    defindex: 1,
                                                  ),
                                              transitionsBuilder:
                                                  (context,
                                                  animation,
                                                  secondaryAnimation,
                                                  child) {
                                                const begin =
                                                Offset(
                                                    1.0, 0.0);
                                                const end =
                                                    Offset.zero;
                                                const curve =
                                                    Curves.ease;

                                                final tween = Tween(
                                                    begin: begin,
                                                    end: end);
                                                final curvedAnimation =
                                                CurvedAnimation(
                                                  parent: animation,
                                                  curve: curve,
                                                );

                                                return SlideTransition(
                                                  position:
                                                  tween.animate(
                                                      curvedAnimation),
                                                  child: child,
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
                                                  color: lightPink,
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
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                    height: 200,
                                    child: ordersLoading
                                        ? Center(
                                        child: Transform.scale(
                                            scale: 0.8,
                                            child:
                                            CircularProgressIndicator()))
                                        : recentOrders.length > 0
                                        ? ListView.builder(
                                        itemCount: recentOrders
                                            .length <
                                            3
                                            ? recentOrders
                                            .length
                                            : 3,
                                        scrollDirection:
                                        Axis.horizontal,
                                        itemBuilder:
                                            (context,
                                            index) {
                                          return GestureDetector(
                                            onTap: () {
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
                                                  recentOrders[index]['Images']==null||
                                                  recentOrders[index]['Images'].toString().isEmpty?
                                                  Container(
                                                    width: width /
                                                        2.2,
                                                    height:
                                                    135,
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                        BorderRadius.circular(15),
                                                        image: DecorationImage(fit: BoxFit.cover,
                                                            image: AssetImage("assets/images/chefdoll.jpg"))
                                                    ),
                                                  ):
                                                  Container(
                                                    width: width /
                                                        2.2,
                                                    height:
                                                    135,
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                        BorderRadius.circular(15),
                                                        image: DecorationImage(fit: BoxFit.cover,
                                                            image: NetworkImage('${recentOrders[index]['Images']}'))),
                                                  ),
                                                  Positioned(
                                                    top: 85,
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
                                                                    recentOrders[index]['Title']!=null?
                                                                    '${recentOrders[index]['Title']}':"My Customized Cake",
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
                                                                      ' ${recentOrders[index]['VendorName']}',
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
                                                              height: 0.5,
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
                                                                  "₹ ${recentOrders[index]['Total']}",
                                                                  style: TextStyle(color: lightPink, fontWeight: FontWeight.bold, fontFamily: poppins, fontSize: 12),
                                                                  maxLines: 1,
                                                                ),
                                                                recentOrders[index]['Status'].toString().toLowerCase() == 'delivered'
                                                                    ? Text(
                                                                  "${recentOrders[index]['Status'].toString()}",
                                                                  style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontFamily: poppins, fontSize: 11),
                                                                )
                                                                    : Text(
                                                                  "${recentOrders[index]['Status']}",
                                                                  style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontFamily: poppins, fontSize: 11),
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
                                        : Column(
                                      mainAxisAlignment:
                                      MainAxisAlignment
                                          .center,
                                      crossAxisAlignment:
                                      CrossAxisAlignment
                                          .center,
                                      children: [
                                        Icon(
                                          Icons
                                              .shopping_basket_outlined,
                                          color:
                                          lightPink,
                                          size: 35,
                                        ),
                                        Text(
                                          'No Recent Orders',
                                          style: TextStyle(
                                              color:
                                              darkBlue,
                                              fontFamily:
                                              "Poppins",
                                              fontWeight:
                                              FontWeight
                                                  .bold,
                                              fontSize:
                                              15),
                                        ),
                                      ],
                                    )
                                ),
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
                                    context
                                        .read<ContextData>()
                                        .setCurrentIndex(3);
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
                                        Icons.keyboard_arrow_right,
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
                                padding: EdgeInsets.only(left: 10),
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
                                            onChanged: (bool? val) {
                                              setState(() {
                                                egglesSwitch = val!;
                                              });
                                            },
                                            activeColor:
                                            Colors.green,
                                          ),
                                        ),
                                        Text(
                                          egglesSwitch
                                              ? 'Eggless'
                                              : 'Egg',
                                          style: TextStyle(
                                              color: darkBlue,
                                              fontWeight:
                                              FontWeight.bold,
                                              fontFamily: poppins),
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
                                    Text('No Results Found!',
                                        style: TextStyle(
                                            fontFamily:
                                            'Poppins',
                                            color: darkBlue)),
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
                                            EdgeInsets.all(
                                                6),
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
                                                  90,
                                                  decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(15),
                                                      image: DecorationImage(
                                                        fit: BoxFit.cover,
                                                        image: NetworkImage('${nearestVendors[index]['ProfileImage']}'),
                                                      )),
                                                )
                                                    : Container(
                                                  height:
                                                  120,
                                                  width:
                                                  90,
                                                  decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(15),
                                                      image: DecorationImage(
                                                        fit: BoxFit.cover,
                                                        image: Svg('assets/images/pictwo.svg'),
                                                      )),
                                                ),
                                                Container(
                                                  padding: EdgeInsets
                                                      .only(
                                                      left:
                                                      10),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                    CrossAxisAlignment
                                                        .start,
                                                    mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround,
                                                    children: [
                                                      Container(
                                                        width: width *
                                                            0.63,
                                                        child:
                                                        Row(
                                                          mainAxisAlignment:
                                                          MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                Container(
                                                                  width: width * 0.5,
                                                                  child: Text(
                                                                    '${nearestVendors[index]['VendorName'][0].toString().toUpperCase() + "${nearestVendors[index]['VendorName'].toString().substring(1).toLowerCase()}"}',
                                                                    overflow: TextOverflow.ellipsis,
                                                                    style: TextStyle(color: darkBlue, fontWeight: FontWeight.bold, fontSize: 14, fontFamily: poppins),
                                                                  ),
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
                                                                      onRatingUpdate: (rating) {},
                                                                    ),
                                                                    Text(
                                                                      ' 4.5',
                                                                      style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold, fontSize: 13, fontFamily: poppins),
                                                                    )
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                            InkWell(
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
                                                          ],
                                                        ),
                                                      ),
                                                      Container(
                                                        width: width *
                                                            0.63,
                                                        child:
                                                        Text(
                                                          nearestVendors[index]['Description'] != null
                                                              ? "${nearestVendors[index]['Description']}"
                                                              : 'No description',
                                                          overflow:
                                                          TextOverflow.ellipsis,
                                                          style: TextStyle(
                                                              color: Colors.black54,
                                                              fontFamily: poppins,
                                                              fontSize: 13),
                                                          maxLines:
                                                          1,
                                                        ),
                                                      ),
                                                      Container(
                                                        height:
                                                        1,
                                                        width: width *
                                                            0.63,
                                                        color: Colors
                                                            .black26,
                                                      ),
                                                      Container(
                                                          width:
                                                          width * 0.63,
                                                          child: nearestVendors[index]['DeliveryCharge'] == null || nearestVendors[index]['DeliveryCharge'] == '0'
                                                              ? Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            // runSpacing: 5.0,
                                                            // spacing: 5.0,
                                                            // runAlignment: WrapAlignment.spaceBetween,
                                                            children: [
                                                              Text(
                                                                'DELIVERY FREE',
                                                                style: TextStyle(color: Colors.orange, fontSize: 10, fontFamily: poppins),
                                                              ),
                                                              SizedBox(
                                                                width: 20,
                                                              ),
                                                              nearestVendors[index]['EggOrEggless'] == 'Both'
                                                                  ? Text(
                                                                'Includes eggless',
                                                                style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold, fontFamily: poppins),
                                                                overflow: TextOverflow.ellipsis,
                                                              )
                                                                  : Text(
                                                                '${nearestVendors[index]['EggOrEggless']}',
                                                                style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold, fontFamily: poppins),
                                                                overflow: TextOverflow.ellipsis,
                                                              )
                                                            ],
                                                          )
                                                              : Wrap(
                                                            alignment: WrapAlignment.start,
                                                            children: [
                                                              Text(
                                                                '10 Km Delivery Charge Rs.${nearestVendors[index]['DeliveryCharge']}',
                                                                style: TextStyle(color: darkBlue, fontSize: 10, fontFamily: poppins),
                                                              ),
                                                              SizedBox(
                                                                width: 40,
                                                              ),
                                                              nearestVendors[index]['EggOrEggless'] == 'Both'
                                                                  ? Text(
                                                                'Includes eggless',
                                                                style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold, fontFamily: poppins),
                                                                overflow: TextOverflow.ellipsis,
                                                              )
                                                                  : Text(
                                                                '${nearestVendors[index]['EggOrEggless']}',
                                                                style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold, fontFamily: poppins),
                                                                overflow: TextOverflow.ellipsis,
                                                              )
                                                            ],
                                                          ))
                                                    ],
                                                  ),
                                                )
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
              child: (cakesTypes.length == 0)
                  ? Text('No Similar Data Found',style: TextStyle(fontFamily:"Poppins",fontWeight: FontWeight.bold),)
                  : ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: cakesTypes.length,
                  itemBuilder: (c, i) {
                    return Container(
                      margin: EdgeInsets.only(
                          left: 15, right: 15, top: 5, bottom: 5),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.white,
                          border: Border.all(
                              color: Colors.grey[400]!, width: 0.5)),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                                  width: cakesTypes[i]['VendorName']
                                      .toString()
                                      .length >
                                      25
                                      ? 130
                                      : 60,
                                  child: Text(
                                    '${cakesTypes[i]['VendorName']}',
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
                                      initialRating: 4.1,
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
                                      onRatingUpdate: (rating) {

                                      },
                                    ),
                                    Text(
                                      ' 4.5',
                                      style: TextStyle(
                                          color: Colors.black54,
                                          fontWeight: FontWeight.bold,
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
                                  cakesTypes[i]['Images'].isEmpty ||
                                      cakesTypes[i]['Images']
                                      [0] ==
                                          ''
                                      ? Container(
                                    height: 85,
                                    width: 85,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      borderRadius:
                                      BorderRadius.circular(
                                          15),
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
                                                cakesTypes[i][
                                                'Images']
                                                [0]),
                                            fit: BoxFit.cover)),
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
                                                    '${cakesTypes[i]['Title']}',
                                                    style: TextStyle(
                                                        color: darkBlue,
                                                        fontWeight:
                                                        FontWeight.bold,
                                                        fontFamily: 'Poppins',
                                                        fontSize: 12),
                                                    maxLines: 2,
                                                    overflow:
                                                    TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                SizedBox(height: 5),
                                                Container(
                                                  // width:120,
                                                  child: Text(
                                                    'Price Rs.${cakesTypes[i]['Price']}/Kg Min Quantity 1 Kg Customization Available',
                                                    style: TextStyle(
                                                        color: Colors.grey,
                                                        fontWeight:
                                                        FontWeight.bold,
                                                        fontFamily: 'Poppins',
                                                        fontSize: 10),
                                                    maxLines: 2,
                                                    overflow:
                                                    TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                SizedBox(height: 5),
                                                Container(
                                                    height: 0.5,
                                                    color: Color(0xffdddddd)),
                                                SizedBox(height: 5),
                                                Container(
                                                  // width:120,
                                                  child: Text(
                                                    cakesTypes[i]['DeliveryCharge'] ==
                                                        "0" ||
                                                        cakesTypes[i][
                                                        'DeliveryCharge'] ==
                                                            "null" ||
                                                        cakesTypes[i][
                                                        'DeliveryCharge'] ==
                                                            null
                                                        ? 'DELIVERY FREE'
                                                        : 'Delivery Charge Rs.${cakesTypes[i]['DeliveryCharge']} ',
                                                    style: TextStyle(
                                                        color: Colors.orange,
                                                        fontWeight:
                                                        FontWeight.bold,
                                                        fontFamily: 'Poppins',
                                                        fontSize: 10),
                                                    maxLines: 1,
                                                    overflow:
                                                    TextOverflow.ellipsis,
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
    );
  }
}

