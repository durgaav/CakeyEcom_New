import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cakey/screens/CakeDetails.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:geocoding/geocoding.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../ContextData.dart';
import 'package:shimmer/shimmer.dart';
import 'package:http/http.dart' as http;
import 'dart:math';
import '../Dialogs.dart';
import '../drawermenu/NavDrawer.dart';
import '../screens/Profile.dart';
import 'HomeScreen.dart';
import 'Notifications.dart';

class CakeTypes extends StatefulWidget {
  const CakeTypes({Key? key}) : super(key: key);
  @override
  State<CakeTypes> createState() => _CakeTypesState();
}

class _CakeTypesState extends State<CakeTypes> {
  //region GLOBAL
  //key....
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  //colors...
  Color lightGrey = Color(0xffF5F5F5);
  Color darkBlue = Color(0xffF213959);
  Color lightPink = Color(0xffFE8416D);
  String homeCakeType = '';

  DateTime? currentBackPressTime;

  bool showAddressEdit = false;
  var deliverToCtrl = new TextEditingController();

  //Strings
  String profileUrl = "";
  String userCurLocation = 'Searching...';
  String poppins = "Poppins";
  String networkMsg = "";
  String authToken = "";

  //get caketype from home....
  String searchCakesText = '';
  int homeCTindex = 0;
  bool isHomeCakeType = false;

  //search filter string
  String searchCakeCate = '';
  String searchCakeSubType = '';
  String searchCakeVendor = '';
  String searchCakeLocation = '';

  //my selected vendor
  String myVendorId = '';
  String vendorName = '';
  String vendorPhone = "";
  bool iamYourVendor = false;
  String vendorPhone1 = "";
  String vendorPhone2 = "";
  String userLatitude = "";
  String userLongtitude = "";

  //booleans
  bool egglesSwitch = false;
  bool _show = true;
  bool isNetworkError = false;
  bool isFiltered = false;
  bool isFilterisOn = false;
  bool shapeOnlyFilter = false;
  bool searchModeis = false;
  bool navFromHome = false;

  //TextFields controls for search....
  var cakeCategoryCtrl = new TextEditingController();
  var cakeSubCategoryCtrl = new TextEditingController();
  var cakeVendorCtrl = new TextEditingController();
  var cakeLocationCtrl = new TextEditingController();
  var searchControl = new TextEditingController();

  //Filtering values
  String priceRangeStart = '';
  String priceRangeEnd = '';

  //Numbers int
  RangeValues rangeValues = RangeValues(0, 2500);
  int currentIndex = 0;

  //Lists
  var cakeCate = [];
  List<bool> selIndex = [];
  List cakesList = [];
  //All types
  List cakesTypes = [];
  //Filtered by type
  List cakesByType = [];
  //search all type
  List cakeSearchList = [];
  //search filter type
  List filterCakesSearchList = [];
  //Egg or eggless Lists
  List eggOrEgglesList = [];

  //For filters bottom
  List filterCakesFlavList = [];
  List filterCakesShapList = [];
  List filterCakesTopingList = [];
  List myFilterList = [];
  List filteredListByUser = [];

  //Fil flav
  List<bool> flavsCheck = [];
  List fixedFilterFlav = [];
  //Fil shapes
  List<bool> shapesCheck = [];
  List fixedFilterShapes = [];
  //Fil toping
  List<bool> topingCheck = [];
  List fixedFilterTopping = [];
  //Filter caketype
  List filterTypeList = [
    "Birthday", "Wedding", "Theme Cake", "Normal Cake"
  ];
  List selectedFilter = [];
  List cakeTypeList = [];

  //Shapes showing...
  List<bool> filterShapesCheck = [];
  List filterShapes = [];
  List shapesForFilter = [];
  List shapesOthersForFilter = ["Star Shape", "House Shape", "Car Shape"];
  List<bool> otherShapeCheck = [];
  List myShapesFilter = [];

  List mySelVendors = [];
  bool activeSearch = false;
  List<int> rangeValuesList = [];

  //for search filter
  List categorySearch = [];
  List subCategorySearch = [];
  List vendorBasedSearch = [];

  //endregion

  //region Dialogs

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

  //filter bottom.....
  void showFilterBottom() {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(20), topLeft: Radius.circular(20)),
        ),
        isScrollControlled: true,
        context: context,
        builder: (context) {
          return StatefulBuilder(builder:
              (BuildContext context, void Function(void Function()) setState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                padding: EdgeInsets.all(15),
                child: SingleChildScrollView(
                  child: Column(
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
                            'FILTER',
                            style: TextStyle(
                                color: darkBlue,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                fontFamily: "Poppins"),
                          ),
                          GestureDetector(
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
                                  color: lightPink,
                                )),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Container(
                        height: 1.0,
                        color: Colors.black26,
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Container(
                        height: 300,
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              //Price Slider...
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Price Range',
                                  style: TextStyle(
                                      color: darkBlue,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: "Poppins"),
                                ),
                              ),
                              SizedBox(
                                height: 4,
                              ),
                              //Price range slider .....
                              SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  trackHeight: 2.0,
                                  minThumbSeparation: 2,
                                  thumbColor: lightPink,
                                  thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12.0),
                                  inactiveTickMarkColor:Colors.transparent,
                                  activeTickMarkColor: Colors.transparent,
                                  valueIndicatorColor: Colors.pink[300],
                                  valueIndicatorTextStyle: TextStyle(color: Colors.white),
                                  inactiveTrackColor: Colors.grey[300],
                                ),
                                child: RangeSlider(
                                    values: rangeValues,
                                    max: rangeValuesList.reduce(max).toDouble(),
                                    min: 0,
                                    divisions: (rangeValuesList.reduce(max) / 10)
                                        .toInt(),
                                    labels: RangeLabels(
                                      rangeValues.start.round().toString(),
                                      rangeValues.end.round().toString(),
                                    ),
                                    onChanged: (RangeValues values) {
                                      setState(() {
                                        rangeValues = values;
                                        priceRangeStart =
                                            rangeValues.start.toString();
                                        priceRangeEnd =
                                            rangeValues.end.toString();
                                      });
                                    }),
                              ),
                              SizedBox(
                                height: 4,
                              ),
                              Container(
                                  padding: EdgeInsets.all(5),
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Start : Rs.${rangeValues.start.toInt()}',
                                           style: TextStyle(
                                            fontFamily: "Poppins",
                                            fontSize: 13,
                                            color: Colors.green,
                                          ),
                                        ),
                                        Text(
                                          'End : Rs.${rangeValues.end.toInt()}',
                                          style: TextStyle(
                                            fontFamily: "Poppins",
                                            fontSize: 13,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ])),
                              SizedBox(
                                height: 4,
                              ),
                              Container(
                                height: 1.0,
                                color: Colors.black26,
                              ),
                              ExpansionTile(
                                title: Text(
                                  'Flavours',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontFamily: "Poppins",
                                      color: darkBlue,
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  fixedFilterFlav.isNotEmpty
                                      ? '${fixedFilterFlav[0]}'
                                      : 'Default',
                                  style: TextStyle(
                                    fontFamily: "Poppins",
                                  ),
                                ),
                                trailing: Container(
                                  alignment: Alignment.center,
                                  height: 25,
                                  width: 25,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: darkBlue,
                                    size: 25,
                                  ),
                                ),
                                children: [
                                  ListView.builder(
                                      physics: NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount: filterCakesFlavList.length,
                                      itemBuilder: (context, index) {
                                        flavsCheck.add(false);
                                        return InkWell(
                                          splashColor: Colors.red[200],
                                          onTap: () {
                                            setState(() {
                                              if (flavsCheck[index] == false) {
                                                flavsCheck[index] = true;

                                                if (fixedFilterFlav.contains(
                                                    filterCakesFlavList[index])){
                                                } else {
                                                  fixedFilterFlav.add(filterCakesFlavList[index]);
                                                }

                                              } else {
                                                fixedFilterFlav.remove(filterCakesFlavList[index]);
                                                flavsCheck[index] = false;
                                              }
                                            });
                                          },
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                height: 5,
                                              ),
                                              Row(
                                                children: [
                                                  Checkbox(
                                                    shape: CircleBorder(),
                                                    activeColor: Colors.white,
                                                    fillColor:
                                                        MaterialStateProperty
                                                            .resolveWith(
                                                                (states) =>
                                                                    Colors
                                                                        .green),
                                                    value: flavsCheck[index],
                                                    onChanged: (bool? check) {
                                                      setState(() {
                                                        if (flavsCheck[index] == false) {
                                                          flavsCheck[index] = true;

                                                          if (fixedFilterFlav.contains(
                                                              filterCakesFlavList[index])){
                                                          } else {
                                                            fixedFilterFlav.add(filterCakesFlavList[index]);
                                                          }

                                                        } else {
                                                          fixedFilterFlav.remove(filterCakesFlavList[index]);
                                                          flavsCheck[index] = false;
                                                        }
                                                      });
                                                    },
                                                  ),
                                                  Text(
                                                    filterCakesFlavList[index][0].toUpperCase() + filterCakesFlavList[index]
                                                            .toString()
                                                            .substring(1)
                                                            .toLowerCase(),
                                                    style: TextStyle(
                                                        color: darkBlue,
                                                        fontFamily: "Poppins",
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        );
                                      })
                                ],
                              ),
                              Container(
                                height: 1.0,
                                color: Colors.black26,
                              ),
                              ExpansionTile(
                                title: Text(
                                  'Shapes',
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: darkBlue,
                                      fontFamily: "Poppins",
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  fixedFilterShapes.isNotEmpty
                                      ? '${fixedFilterShapes[0]}'
                                      : 'Default',
                                  style: TextStyle(
                                    fontFamily: "Poppins",
                                  ),
                                ),
                                trailing: Container(
                                  alignment: Alignment.center,
                                  height: 25,
                                  width: 25,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: darkBlue,
                                    size: 25,
                                  ),
                                ),
                                children: [
                                  ListView.builder(
                                      physics: NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount: shapesForFilter.length,
                                      itemBuilder: (context, index) {
                                        shapesCheck.add(false);
                                        return InkWell(
                                          splashColor: Colors.red[200],
                                          onTap: () {
                                            setState(() {
                                              if (shapesCheck[index] == false) {
                                                shapesCheck[index] = true;

                                                if (fixedFilterShapes.contains(
                                                    shapesForFilter[index])) {
                                                } else {
                                                  fixedFilterShapes.add(
                                                      shapesForFilter[index]);
                                                }
                                              } else {
                                                fixedFilterShapes.remove(
                                                    shapesForFilter[index]);
                                                shapesCheck[index] = false;
                                              }
                                            });
                                          },
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                height: 5,
                                              ),
                                              Wrap(
                                                crossAxisAlignment:
                                                    WrapCrossAlignment.center,
                                                runSpacing: 5,
                                                children: [
                                                  Checkbox(
                                                    shape: CircleBorder(),
                                                    activeColor: Colors.white,
                                                    fillColor:
                                                        MaterialStateProperty
                                                            .resolveWith(
                                                                (states) =>
                                                                    Colors
                                                                        .green),
                                                    value: shapesCheck[index],
                                                    onChanged: (bool? check) {
                                                      setState(() {
                                                        if (shapesCheck[
                                                                index] ==
                                                            false) {
                                                          shapesCheck[index] =
                                                              true;

                                                          if (fixedFilterShapes
                                                              .contains(
                                                                  shapesForFilter[
                                                                      index])) {
                                                          } else {
                                                            fixedFilterShapes.add(
                                                                shapesForFilter[
                                                                    index]);
                                                          }
                                                        } else {
                                                          fixedFilterShapes
                                                              .remove(
                                                                  shapesForFilter[
                                                                      index]);
                                                          shapesCheck[index] =
                                                              false;
                                                        }
                                                      });
                                                    },
                                                  ),
                                                  Text(
                                                    shapesForFilter[index]
                                                            .toString()[0]
                                                            .toUpperCase() +
                                                        shapesForFilter[index]
                                                            .toString()
                                                            .substring(1)
                                                            .toLowerCase(),
                                                    style: TextStyle(
                                                        color: darkBlue,
                                                        fontFamily: "Poppins",
                                                        fontSize: 13),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        );
                                      }),
                                ],
                              ),
                              Container(
                                height: 1.0,
                                color: Colors.black26,
                              ),

                              SizedBox(
                                height: 10,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            height: 45,
                            width: 120,
                            child: RaisedButton(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              color: lightPink,
                              onPressed: () {
                                //Going to Aply filters....
                                applyFilters(
                                    priceRangeStart,
                                    priceRangeEnd,
                                    fixedFilterFlav,
                                    fixedFilterShapes,
                                    fixedFilterTopping
                                );
                              },
                              child: Text(
                                "FILTER",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: "Poppins"),
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              //clearing all filters
                              clearAllFilters();
                            },
                            child: Text(
                              "CLEAR",
                              style: TextStyle(
                                  color: lightPink,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: "Poppins",
                                  decoration: TextDecoration.underline),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            );
          });
        });
  }

  //Search filter bottom
  void showSearchFilterBottom() {

    List myList = [];

    setState((){
      for (var i = 0;i<cakesTypes.length;i++){
        if(cakesTypes[i].toString().toLowerCase()!="all cakes"){
          myList.add(cakesTypes[i]);
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
                          Text(
                            'SEARCH',
                            style: TextStyle(
                                // foreground: Paint()
                                //   ..style = PaintingStyle.stroke
                                //   ..strokeWidth = 1.5
                                //   ..color = darkBlue,
                                color: darkBlue,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                fontFamily: "Poppins"),
                          ),
                          GestureDetector(
                            onTap: () => setState(() {
                              clearTheSearch();
                            }),
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
                          onChanged: (String text) {
                            // searchCakeCate = cakeCategoryCtrl.text;
                            // searchCakeSubType = cakeSubCategoryCtrl.text;
                            // searchCakeVendor = cakeVendorCtrl.text;
                            // searchCakeLocation = cakeLocationCtrl.text;
                            setState(() {
                              searchCakeCate = text;
                            });
                          },
                          controller: cakeCategoryCtrl,
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(5),
                              hintText: "Cakename",
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
                          onChanged: (String text) {
                            // searchCakeCate = cakeCategoryCtrl.text;
                            // searchCakeSubType = cakeSubCategoryCtrl.text;
                            // searchCakeVendor = cakeVendorCtrl.text;
                            // searchCakeLocation = cakeLocationCtrl.text;
                            setState(() {
                              searchCakeSubType = text;
                            });
                          },
                          controller: cakeSubCategoryCtrl,
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(5),
                              hintText: "Occasion Cake",
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
                          onChanged: (String text) {
                            // searchCakeCate = cakeCategoryCtrl.text;
                            // searchCakeSubType = cakeSubCategoryCtrl.text;
                            // searchCakeVendor = cakeVendorCtrl.text;
                            // searchCakeLocation = cakeLocationCtrl.text;
                            setState(() {
                              searchCakeVendor = text;
                            });
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
                        height: 5,
                      ),

                      Container(
                        height: 1.0,
                        color: Colors.black26,
                      ),
                      //cake types....
                      SizedBox(
                        height: 5,
                      ),

                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Types',
                          style: TextStyle(
                              color: darkBlue,
                              fontSize: 15,
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
                              onPressed: (){
                                setState((){
                                  if(selectedFilter.contains(e)){
                                    selectedFilter.removeWhere(
                                            (element) => element == e);
                                    clicked = false;
                                  }else{
                                    selectedFilter.add(e);
                                    clicked = true;
                                  }
                                });
                              },
                              child: Text(e,style: TextStyle(
                                fontFamily: "Poppins",
                                color: clicked?Colors.white:darkBlue,
                                fontWeight: FontWeight.bold,
                                fontSize: 13
                              ),),
                              style: ButtonStyle(
                                side: MaterialStateProperty.all(
                                  BorderSide(width: 1 , color: Colors.grey[300]!)
                                ),
                                shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)
                                  ),
                                ),
                                backgroundColor:MaterialStateProperty.all(
                                  clicked?darkBlue.withOpacity(0.7):Colors.white,
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
                              setState(() {
                                Navigator.pop(context);
                                searchByGivenFilter(
                                    cakeCategoryCtrl.text,
                                    cakeSubCategoryCtrl.text,
                                    cakeVendorCtrl.text,
                                    selectedFilter);
                              });
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

  //Show shapes bottom sheet
  void showShapesSheet() {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (BuildContext context,
                void Function(void Function()) setState) {
              return Container(
                padding: EdgeInsets.all(10),
                child: Column(
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
                          'SHAPES',
                          style: TextStyle(
                              color: darkBlue,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: "Poppins"),
                        ),
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
                      height: 8,
                    ),
                    Container(
                      height: 1.0,
                      color: Colors.black26,
                    ),
                    Container(
                      height: 250,
                      child: SingleChildScrollView(
                          child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: shapesForFilter.length,
                              itemBuilder: (context, index) {
                                filterShapesCheck.add(false);
                                return InkWell(
                                  splashColor: Colors.red[200],
                                  onTap: () {
                                    setState(() {
                                      if (filterShapesCheck[index] == false) {
                                        filterShapesCheck[index] = true;

                                        if (filterShapes
                                            .contains(shapesForFilter[index])) {
                                        } else {
                                          filterShapes
                                              .add(shapesForFilter[index]);
                                        }
                                      } else {
                                        filterShapes
                                            .remove(shapesForFilter[index]);
                                        filterShapesCheck[index] = false;
                                      }
                                    });
                                  },
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Wrap(
                                        crossAxisAlignment:
                                            WrapCrossAlignment.center,
                                        runSpacing: 5,
                                        children: [
                                          Checkbox(
                                            shape: CircleBorder(),
                                            activeColor: Colors.white,
                                            fillColor: MaterialStateProperty
                                                .resolveWith(
                                                    (states) => Colors.green),
                                            value: filterShapesCheck[index],
                                            onChanged: (bool? check) {
                                              setState(() {
                                                if (filterShapesCheck[index] ==
                                                    false) {
                                                  filterShapesCheck[index] =
                                                      true;

                                                  if (filterShapes.contains(
                                                      shapesForFilter[index])) {
                                                  } else {
                                                    filterShapes.add(
                                                        shapesForFilter[index]);
                                                  }
                                                } else {
                                                  filterShapes.remove(
                                                      shapesForFilter[index]);
                                                  filterShapesCheck[index] =
                                                      false;
                                                }
                                              });
                                            },
                                          ),
                                          Text(
                                            shapesForFilter[index]
                                                    .toString()[0]
                                                    .toUpperCase() +
                                                shapesForFilter[index]
                                                    .toString()
                                                    .substring(1)
                                                    .toLowerCase(),
                                            style: TextStyle(
                                                color: darkBlue,
                                                fontFamily: "Poppins",
                                                fontSize: 13),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              }),
                          SizedBox(height: 6),

                          // ExpansionTile(
                          //   title: Text(
                          //     'OTHERS',
                          //     style: TextStyle(
                          //         color: darkBlue,
                          //         fontFamily: "Poppins",
                          //         fontSize: 15,
                          //         fontWeight: FontWeight.bold),
                          //   ),
                          //   trailing: Container(
                          //     alignment: Alignment.center,
                          //     height: 25,
                          //     width: 25,
                          //     decoration: BoxDecoration(
                          //       color: Colors.grey[300],
                          //       shape: BoxShape.circle,
                          //     ),
                          //     child: Icon(
                          //       Icons.keyboard_arrow_down_rounded,
                          //       color: darkBlue,
                          //       size: 25,
                          //     ),
                          //   ),
                          //   children: [
                          //     ListView.builder(
                          //         physics: NeverScrollableScrollPhysics(),
                          //         shrinkWrap: true,
                          //         itemCount: shapesOthersForFilter.length,
                          //         itemBuilder: (context, index) {
                          //           return InkWell(
                          //             splashColor: Colors.red[200],
                          //             onTap: () {
                          //               setState(() {
                          //                 if (otherShapeCheck[index] == false) {
                          //                   otherShapeCheck[index] = true;
                          //
                          //                   if (filterShapes.contains(
                          //                       shapesOthersForFilter[index])) {
                          //                   } else {
                          //                     filterShapes.add(
                          //                         shapesOthersForFilter[index]);
                          //                   }
                          //                 } else {
                          //                   filterShapes.remove(
                          //                       shapesOthersForFilter[index]);
                          //                   otherShapeCheck[index] = false;
                          //                 }
                          //               });
                          //             },
                          //             child: Column(
                          //               crossAxisAlignment:
                          //                   CrossAxisAlignment.start,
                          //               children: [
                          //                 SizedBox(
                          //                   height: 5,
                          //                 ),
                          //                 Wrap(
                          //                   crossAxisAlignment:
                          //                       WrapCrossAlignment.center,
                          //                   runSpacing: 5,
                          //                   children: [
                          //                     Checkbox(
                          //                       shape: CircleBorder(),
                          //                       activeColor: Colors.white,
                          //                       fillColor: MaterialStateProperty
                          //                           .resolveWith((states) =>
                          //                               Colors.green),
                          //                       value: otherShapeCheck[index],
                          //                       onChanged: (bool? check) {
                          //                         setState(() {
                          //                           if (otherShapeCheck[
                          //                                   index] ==
                          //                               false) {
                          //                             otherShapeCheck[index] =
                          //                                 true;
                          //
                          //                             if (filterShapes.contains(
                          //                                 shapesOthersForFilter[
                          //                                     index])) {
                          //                             } else {
                          //                               filterShapes.add(
                          //                                   shapesOthersForFilter[
                          //                                       index]);
                          //                             }
                          //                           } else {
                          //                             filterShapes.remove(
                          //                                 shapesOthersForFilter[
                          //                                     index]);
                          //                             otherShapeCheck[index] =
                          //                                 false;
                          //                           }
                          //                         });
                          //                       },
                          //                     ),
                          //                     Text(
                          //                       shapesOthersForFilter[index]
                          //                           .toString(),
                          //                       style: TextStyle(
                          //                           color: darkBlue,
                          //                           fontFamily: "Poppins",
                          //                           fontSize: 15),
                          //                     ),
                          //                   ],
                          //                 ),
                          //               ],
                          //             ),
                          //           );
                          //         }),
                          //   ],
                          // )

                        ],
                      )),
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          height: 45,
                          width: 120,
                          child: RaisedButton(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            color: lightPink,
                            onPressed: () {
                              //Going to Aply filters....
                              setState(() {
                                applyFilterByShape(filterShapes);
                              });
                            },
                            child: Text(
                              "FILTER",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: "Poppins"),
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            //clearing all filters
                            clearShapesFilter();
                          },
                          child: Text(
                            "CLEAR",
                            style: TextStyle(
                                color: lightPink,
                                fontWeight: FontWeight.bold,
                                fontFamily: "Poppins",
                                decoration: TextDecoration.underline),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              );
            },
          );
        });
  }

  //endregion

  //region Functions

  //search by filters
  void searchByGivenFilter(String category, String subCategory,
      String vendorName, List filterCType) {
    List a = [], b = [], c = [] , d = [];

    cakeTypeList = [];

    searchControl.text = '$category $subCategory '
        '$vendorName ${filterCType.toString().replaceAll("[", "").replaceAll("]", "")}';

    setState(() {
      if (category.isNotEmpty) {
        a = eggOrEgglesList
            .where((element) => element['CakeName']
                .toString()
                .toLowerCase()
                .contains(category.toLowerCase()))
            .toList();
        activeSearch = true;
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
          c = eggOrEgglesList
              .where((element) => element['VendorName']
                  .toString()
                  .toLowerCase()
                  .contains(vendorName.toLowerCase()))
              .toList();
          activeSearch = true;
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

      cakeSearchList = a + b + c + d.toList();
      cakeSearchList = cakeSearchList.toSet().toList();

    });
  }

  //load prefss...
  Future<void> loadPrefs() async {
    var pref = await SharedPreferences.getInstance();
    setState(() {
      authToken = pref.getString("authToken") ?? 'no auth';
      userCurLocation = pref.getString('userCurrentLocation') ?? 'Not Found';
      userLatitude = pref.getString('userLatitute')??'Not Found';
      userLongtitude = pref.getString('userLongtitude')??'Not Found';
      //delivery charge
      // adminDeliveryCharge = pref.getInt("todayDeliveryCharge")??0;
      // adminDeliveryChargeKm = pref.getInt("todayDeliveryKm")??0;
      myVendorId = pref.getString('myVendorId') ?? 'Not Found';
      vendorName = pref.getString('myVendorName') ?? 'Un Name';
      vendorPhone = pref.getString('myVendorPhone') ?? '0000000000';
      vendorPhone1 = pref.getString('myVendorPhone1')??'null';
      vendorPhone2 = pref.getString('myVendorPhone2')??'null';
      iamYourVendor = pref.getBool('iamYourVendor')?? false;

      if (iamYourVendor == true) {
        mySelVendors = [
          {"VendorName": vendorName}
        ];
      } else {}

      getCakeType();
      getCakeList();
    });
  }

  //fetch cake types
  Future<void> getCakeType() async {
    cakesTypes.clear();
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
              cakesTypes.add(mainList[i]['Type'].toString());
            }

            if(mainList[i]['SubType'].isNotEmpty && mainList[i]['SubType']!=null){
              for(int k = 0 ; k<mainList[i]['SubType'].length;k++){
                print(mainList[i]['SubType'][k]);
                cakesTypes.add(mainList[i]['SubType'][k].toString());
              }
            }

          }
        }

        print('Sub types>>>> $subType');

        cakesTypes.insert(0, "All Cakes");
        cakesTypes = cakesTypes.toSet().toList();

        // searchCakeType.insert(0, "Customize your cake");
        // // searchCakeType = searchCakeType.map((e)=>e.toString().toLowerCase()).toSet().toList();
        // searchCakeType.toSet().toList();

        print('type cake ::::: $cakesTypes');

      });
    } else {
      print(response.reasonPhrase);
      setState((){

      });
    }
  }

  //Fetching cake list API...
  Future<void> getCakeList() async {
    
    List regular = [];
    List premium = [];
    
    showAlertDialog();

    print("Ven iddd : $myVendorId");

    String commonCake = 'https://cakey-database.vercel.app/api/cake/list';
    String vendorCake =
        'https://cakey-database.vercel.app/api/cake/listbyIdandstatus/$myVendorId';

    try {
      http.Response response = await http.get(
          Uri.parse(iamYourVendor == true ? vendorCake : commonCake),
          headers: {"Authorization": "$authToken"});
      if (response.statusCode == 200) {
        //
        if (response.contentLength! < 50) {
          setState(() {
            rangeValuesList = [100, 200];
            rangeValues =
                new RangeValues(0.0, rangeValuesList.reduce(max).toDouble());
          });
          fetchFlavours();
          fetchShapes();
          Navigator.pop(context);
        } else {
          setState(() {
            isNetworkError = false;
            List cakList = jsonDecode(response.body);
            
            regular = cakList.where((element) => element['CakeCategory'].toString().toLowerCase()=="regular").toList();
            premium = cakList.where((element) => element['CakeCategory'].toString().toLowerCase()=="premium").toList();

            // cakesList = cakesList.reversed.toList();

            for (int i = 0; i < cakList.length; i++) {
              rangeValuesList.add(int.parse(cakList[i]['BasicCakePrice']));
              print(cakList[i]['CakeCategory']);
              // cakesTypes.add(cakList[i]['CakeType'].toString());
            }

            cakesList = cakList.where((element) => calculateDistance(double.parse(userLatitude),
                double.parse(userLongtitude),
                element['GoogleLocation']['Latitude'],element['GoogleLocation']['Longitude'])<=10).toList();



            cakesList = cakesList.reversed.toList();

            // cakesTypes.insert(0, "All Cakes");
            // cakesTypes = cakesTypes.toSet().toList();

            print(cakesTypes);

            Navigator.pop(context);

            fetchFlavours();
            fetchShapes();
          });

          setState(() {
            rangeValues =
                new RangeValues(0.0, rangeValuesList.reduce(max).toDouble());
          });

        }
      } else {
        setState(() {
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
        });
        Navigator.pop(context);
      }
    } catch (error) {
      checkNetwork();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error Occurred'),
        duration: Duration(seconds: 5),
        action: SnackBarAction(
          label: "Retry",
          onPressed: () => setState(() {
            loadPrefs();
          }),
        ),
      ));
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

  //Fetching Flavours...API
  Future<void> fetchFlavours() async {
    var res = await http.get(
        Uri.parse('https://cakey-database.vercel.app/api/flavour/list'),
        headers: {"Authorization": "$authToken"});

    if (res.statusCode == 200) {
      List fl = jsonDecode(res.body);

      for (int i = 0; i < fl.length; i++) {
        setState(() {
          filterCakesFlavList.add(fl[i]['Name'].toString().toLowerCase());
        });
      }

      filterCakesFlavList = filterCakesFlavList.toSet().toList();
    } else {}
  }

  //get shapes from api
  Future<void> fetchShapes() async {
    var res = await http.get(
        Uri.parse('https://cakey-database.vercel.app/api/shape/list'),
        headers: {"Authorization": "$authToken"});

    if (res.statusCode == 200) {
      List fl = jsonDecode(res.body);

      for (int i = 0; i < fl.length; i++) {
        setState(() {
          shapesForFilter.add(fl[i]['Name'].toString().toLowerCase());
        });
      }

      shapesForFilter = shapesForFilter.toSet().toList();
    } else {}
  }

  //Send prefs to next screen....
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

    // getting cake tiers
    if (cakeSearchList[index]['TierCakeMinWeightAndPrice'].isNotEmpty||cakeSearchList[index]['TierCakeMinWeightAndPrice']!=null) {
      setState(() {
        cakeTiers = cakeSearchList[index]['TierCakeMinWeightAndPrice'];
      });
    } else {
      setState(() {
        cakeTiers = [];
      });
    }

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
    // prefs.setString("cakeType", cakeSearchList[index]['CakeType']??"null");
    // prefs.setString("cakeSubType", cakeSearchList[index]['CakeSubType']??"null");
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

    if(cakeSearchList[index]['MinTimeForDeliveryOfA3KgCake']!=null&&
        cakeSearchList[index]['MinTimeForDeliveryOfA5KgCake']!=null){
      prefs.setString("cake3kgminTime", cakeSearchList[index]['MinTimeForDeliveryOfA3KgCake'].toString());
      prefs.setString("cake5kgminTime", cakeSearchList[index]['MinTimeForDeliveryOfA5KgCake'].toString());
    }else{
      prefs.setString("cake3kgminTime", 'Nf');
      prefs.setString("cake5kgminTime", 'Nf');
    }
    prefs.setString("cakeminDelTime", cakeSearchList[index]['MinTimeForDeliveryOfDefaultCake'].toString());



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

  //Distance calculator
  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  //Send filtered prefs to next screen
  Future<void> sendFillDetailsToScreen(int index) async {
    //Local Vars
    List<String> cakeImgs = [];
    List<String> cakeWeights = [];
    List cakeFlavs = [];
    List cakeShapes = [];
    List cakeTiers = [];
    var prefs = await SharedPreferences.getInstance();

    String vendorAddress = filterCakesSearchList[index]['VendorAddress'];

    //region API LIST LOADING...
    //getting cake pics
    if (filterCakesSearchList[index]['AdditionalCakeImages'].isNotEmpty) {
      setState(() {
        for (int i = 0; i < filterCakesSearchList[index]['AdditionalCakeImages'].length; i++) {
          cakeImgs.add(filterCakesSearchList[index]['AdditionalCakeImages'][i].toString());
        }
      });
    } else {
      setState(() {
        cakeImgs = [
          filterCakesSearchList[index]['MainCakeImage'].toString()
        ];
      });
    }

    // getting cake flavs
    if (filterCakesSearchList[index]['CustomFlavourList'].isNotEmpty||filterCakesSearchList[index]['CustomFlavourList']!=null) {
      setState(() {
        cakeFlavs = filterCakesSearchList[index]['CustomFlavourList'];

        // for(int i = 0 ; i<filterCakesSearchList[index]['CustomFlavourList'].length;i++){
        //   cakeFlavs.add(filterCakesSearchList[index]['CustomFlavourList'][i].toString());
        // }

      });
    } else {
      setState(() {
        cakeFlavs = [
        ];
      });
    }

    // getting cake tiers
    if (filterCakesSearchList[index]['TierCakeMinWeightAndPrice'].isNotEmpty||filterCakesSearchList[index]['TierCakeMinWeightAndPrice']!=null) {
      setState(() {
        cakeTiers = filterCakesSearchList[index]['TierCakeMinWeightAndPrice'];
      });
    } else {
      setState(() {
        cakeTiers = [];
      });
    }

    // getting cake shapes
    if (filterCakesSearchList[index]['CustomShapeList']['Info'].isNotEmpty||
        filterCakesSearchList[index]['CustomShapeList']['Info']!=null) {
      setState(() {
        cakeShapes = filterCakesSearchList[index]['CustomShapeList']['Info'];

        // for(int i = 0 ; i<filterCakesSearchList[index]['CustomShapeList']['Info'].length;i++){
        //   cakeShapes.add(filterCakesSearchList[index]['CustomShapeList']['Info'][i].toString());
        // }

      });
    } else {
      setState(() {
        cakeShapes = [
        ];
      });
    }


    //getting cake toppings list
    // if(filterCakesSearchList[index]['CakeToppings'].isNotEmpty){
    //   setState(() {
    //     for(int i=0;i<filterCakesSearchList[index]['CakeToppings'].length;i++){
    //       cakeTopings.add(filterCakesSearchList[index]['CakeToppings'][i].toString());
    //     }
    //   });
    // }
    // else{
    //   setState(() {
    //     cakeTopings = [];
    //   });
    // }

    //getting cake weights


    if (filterCakesSearchList[index]['MinWeightList'].isNotEmpty || filterCakesSearchList[index]['MinWeightList']!=null) {
      setState(() {
        for (int i = 0; i < filterCakesSearchList[index]['MinWeightList'].length; i++) {
          cakeWeights.add(filterCakesSearchList[index]['MinWeightList'][i].toString());
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
    prefs.setString("cake_id", filterCakesSearchList[index]['_id']??"null");
    prefs.setString("cakeModid", filterCakesSearchList[index]['Id']??"null");
    prefs.setString("cakeMainImage", filterCakesSearchList[index]['MainCakeImage']??"null");
    prefs.setString("cakeName", filterCakesSearchList[index]['CakeName']??"null");
    prefs.setString("cakeCommName", filterCakesSearchList[index]['CakeCommonName']??"null");
    prefs.setString("cakeBasicFlav", filterCakesSearchList[index]['BasicFlavour']??"null");
    prefs.setString("cakeBasicShape", filterCakesSearchList[index]['BasicShape']??"null");
    prefs.setString("cakeMinWeight", filterCakesSearchList[index]['MinWeight']??"null");
    prefs.setString("cakeMinPrice", filterCakesSearchList[index]['BasicCakePrice']??"null");
    prefs.setString("cakeEggorEggless", filterCakesSearchList[index]['DefaultCakeEggOrEggless']??"null");
    prefs.setString("cakeEgglessAvail", filterCakesSearchList[index]['IsEgglessOptionAvailable']??"null");
    prefs.setString("cakeEgglesCost", filterCakesSearchList[index]['BasicEgglessCostPerKg']??"null");
    prefs.setString("cakeCostWithEggless", filterCakesSearchList[index]['BasicEgglessCostPerKg']??"null");
    prefs.setString("cakeTierPoss", filterCakesSearchList[index]['IsTierCakePossible']??"null");
    prefs.setString("cakeThemePoss", filterCakesSearchList[index]['ThemeCakePossible']??"null");
    prefs.setString("cakeToppersPoss", filterCakesSearchList[index]['ToppersPossible']??"null");
    prefs.setString("cakeBasicCustom", filterCakesSearchList[index]['BasicCustomisationPossible']??"null");
    prefs.setString("cakeFullCustom", filterCakesSearchList[index]['FullCustomisationPossible']??"null");
    // prefs.setString("cakeType", filterCakesSearchList[index]['CakeType']??"null");
    // prefs.setString("cakeSubType", filterCakesSearchList[index]['CakeSubType']??"null");
    prefs.setString("cakeDescription", filterCakesSearchList[index]['Description']??"null");
    prefs.setString("cakeCategory", filterCakesSearchList[index]['CakeCategory']??"null");
    prefs.setString("cakeTopperPoss", filterCakesSearchList[index]['ToppersPossible']??"null");

    prefs.setString("cakeVendorid", filterCakesSearchList[index]['VendorID']??"null");
    prefs.setString("cakeVendorModid", filterCakesSearchList[index]['Vendor_ID']??"null");
    prefs.setString("cakeVendorName", filterCakesSearchList[index]['VendorName']??"null");
    prefs.setString("cakeVendorPhone1", filterCakesSearchList[index]['VendorPhoneNumber1']??"null");
    prefs.setString("cakeVendorPhone2", filterCakesSearchList[index]['VendorPhoneNumber2']??"null");
    prefs.setString("cakeVendorAddress", vendorAddress);
    prefs.setString("cakeVendorLatitu", filterCakesSearchList[index]['GoogleLocation']['Latitude'].toString());
    prefs.setString("cakeVendorLongti", filterCakesSearchList[index]['GoogleLocation']['Longitude'].toString());

    if(filterCakesSearchList[index]['MinTimeForDeliveryOfA3KgCake']!=null&&
        filterCakesSearchList[index]['MinTimeForDeliveryOfA5KgCake']!=null){
      prefs.setString("cake3kgminTime", filterCakesSearchList[index]['MinTimeForDeliveryOfA3KgCake'].toString());
      prefs.setString("cake5kgminTime", filterCakesSearchList[index]['MinTimeForDeliveryOfA5KgCake'].toString());
    }else{
      prefs.setString("cake3kgminTime", 'Nf');
      prefs.setString("cake5kgminTime", 'Nf');
    }
    prefs.setString("cakeminDelTime", filterCakesSearchList[index]['MinTimeForDeliveryOfDefaultCake'].toString());



    //INTEGERS
    prefs.setInt('cakeDiscount', int.parse(filterCakesSearchList[index]['Discount'].toString()));
    prefs.setInt('cakeTax', int.parse(filterCakesSearchList[index]['Tax'].toString()));
    prefs.setInt('cakeDiscount', int.parse(filterCakesSearchList[index]['Discount'].toString()));
    prefs.setDouble("cakeRating",double.parse(filterCakesSearchList[index]['Ratings'].toString()));


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

  //Applying the filters...
  void applyFilters(String priceStart, String priceEnd, List flavours,
      List shapes, List topings) {


    print("flavours $flavours");
    print(shapes);

    myFilterList.clear();

    List priceFilter = [], flavFilter1 = [], shapeFilter1 = [], d = [] , flavFilter2 = [] , shapeFilter2 = [];

    setState(() {
      //all are empty
      if (priceStart.isEmpty &&
          priceEnd.isEmpty &&
          flavours.isEmpty &&
          shapes.isEmpty &&
          topings.isEmpty) {
        Navigator.pop(context);
        isFilterisOn = false;
      } else {
        Navigator.pop(context);

        //price values ok
        if (priceStart.isNotEmpty || priceEnd.isNotEmpty) {
          setState(() {
            for (int i = 0; i < eggOrEgglesList.length; i++) {
              priceFilter = eggOrEgglesList
                  .where((element) =>
                      int.parse(element['BasicCakePrice'], onError: (e) => 0) >=
                          double.parse(priceRangeStart, (e) => 0).toInt() &&
                      int.parse(element['BasicCakePrice']) <=
                          double.parse(priceRangeEnd, (e) => 0).toInt())
                  .toList();

              isFilterisOn = true;
            }
          });
        }

        //flav list ok
        if (flavours.isNotEmpty) {
          for (int i = 0; i < eggOrEgglesList.length; i++) {
            if (eggOrEgglesList[i]['CustomFlavourList'] != null &&
                eggOrEgglesList[i]['CustomFlavourList'].isNotEmpty) {
              for (int j = 0;
                  j < eggOrEgglesList[i]['CustomFlavourList'].length;
                  j++) {
                if (eggOrEgglesList[i]['CustomFlavourList'][j]['Name'] != null) {
                  for (int k = 0; k < flavours.length; k++) {
                    if (eggOrEgglesList[i]['CustomFlavourList'][j]['Name']
                        .toString()
                        .toLowerCase()
                        .contains(flavours[k].toString().toLowerCase())) {
                      setState(() {
                        flavFilter1.add(eggOrEgglesList[i]);
                        isFilterisOn = true;
                      });
                    } else {}
                  }
                } else {}
              }
            } else {}
          }
        }


        //flavs from basic
        if(flavours.isNotEmpty){
          for (int i = 0; i < flavours.length; i++) {
            flavFilter2 = flavFilter2.toList() + eggOrEgglesList.where((element) => element['BasicFlavour'].toString()
            .toLowerCase().contains(flavours[i].toString().toLowerCase())).toList();
          }
          isFilterisOn = true;
        }

        //shapes list ok
        if (shapes.isNotEmpty) {
          setState(() {
            for (int i=0 ; i < eggOrEgglesList.length; i++) {
              if (eggOrEgglesList[i]['CustomShapeList']['Info'] != null &&
                  eggOrEgglesList[i]['CustomShapeList']['Info'].isNotEmpty) {
                for (int j = 0;
                j < eggOrEgglesList[i]['CustomShapeList']['Info'].length;
                j++) {
                  if (eggOrEgglesList[i]['CustomShapeList']['Info'][j]['Name'] != null) {
                    for (int k = 0; k < shapes.length; k++) {
                      if (eggOrEgglesList[i]['CustomShapeList']['Info'][j]['Name']
                          .toString()
                          .toLowerCase()
                          .contains(shapes[k].toString().toLowerCase())) {
                        setState(() {
                          shapeFilter1.add(eggOrEgglesList[i]);
                          isFilterisOn = true;
                        });
                      } else {}
                    }
                  } else {}
                }
              } else {}
            }
          });
        }

        //apply basic shape
        if(shapes.isNotEmpty){
          for (int i = 0; i < shapes.length; i++) {
            shapeFilter2 = shapeFilter2.toList() + eggOrEgglesList.where((element) => element['BasicShape'].toString()
                .toLowerCase().contains(shapes[i].toString().toLowerCase())).toList();
          }
          isFilterisOn = true;
        }

        //topings list ok
        if (topings.isNotEmpty) {
          setState(() {
            for (int i = 0; i < eggOrEgglesList.length; i++) {
              if (eggOrEgglesList[i]['CakeToppings'].isNotEmpty) {
                for (int j = 0; j < topings.length; j++) {
                  if (eggOrEgglesList[i]['CakeToppings'].contains(topings[j])) {
                    d.add(eggOrEgglesList[i]);
                  }
                }
              } else {}
            }
            isFilterisOn = true;
          });
        }

        myFilterList = priceFilter + flavFilter1 + shapeFilter1 + d + flavFilter2 + shapeFilter2;
        filteredListByUser = myFilterList + myShapesFilter;
        filteredListByUser = filteredListByUser.toSet().toList();
        filteredListByUser = filteredListByUser.reversed.toList();

      }
    });
  }

  //Clear all applied filters...
  void clearAllFilters() {

    setState(() {

      myFilterList.clear();

      //price range = 0
      priceRangeStart = "";
      priceRangeEnd = '';
      rangeValues = RangeValues(0, rangeValuesList.reduce(max).toDouble());

      //fixed lists
      fixedFilterFlav.clear();
      fixedFilterShapes.clear();
      fixedFilterTopping.clear();

      //Check boxs
      flavsCheck.clear();
      shapesCheck.clear();
      topingCheck.clear();

      filteredListByUser = myFilterList + myShapesFilter;
      filteredListByUser = filteredListByUser.toSet().toList();
      filteredListByUser = filteredListByUser.reversed.toList();

      isFilterisOn = false;
    });

    Navigator.pop(context);
  }

  //applying shape only filter
  void applyFilterByShape(List shapes) {

    List shapes1 = [];

    setState(() {
      if (shapes.isEmpty) {
        Navigator.pop(context);
        shapeOnlyFilter = false;
      } else {
        myShapesFilter.clear();
        setState(() {
          for (int i=0 ; i < eggOrEgglesList.length; i++) {
            if (eggOrEgglesList[i]['CustomShapeList']['Info'] != null &&
                eggOrEgglesList[i]['CustomShapeList']['Info'].isNotEmpty) {
              for (int j = 0;
              j < eggOrEgglesList[i]['CustomShapeList']['Info'].length;
              j++) {
                if (eggOrEgglesList[i]['CustomShapeList']['Info'][j]['Name'] != null) {
                  for (int k = 0; k < shapes.length; k++) {
                    if (eggOrEgglesList[i]['CustomShapeList']['Info'][j]['Name']
                        .toString()
                        .toLowerCase()
                        .contains(shapes[k].toString().toLowerCase())) {
                      setState(() {
                        myShapesFilter.add(eggOrEgglesList[i]);
                        shapeOnlyFilter = true;
                      });
                    } else {}
                  }
                } else {}
              }
            } else {}
          }


          if(shapes.isNotEmpty){
            for (int i = 0; i < shapes.length; i++) {
              shapes1 = shapes1.toList() + eggOrEgglesList.where((element) => element['BasicShape'].toString()
                  .toLowerCase().contains(shapes[i].toString().toLowerCase())).toList();
              // print(b[i]['BasicFlavour'].toString()+" Flav");
            }
            shapeOnlyFilter = true;
          }

          shapeOnlyFilter = true;
          Navigator.pop(context);
        });


        myShapesFilter =  myShapesFilter + shapes1;
        filteredListByUser = myFilterList + myShapesFilter;
        filteredListByUser = filteredListByUser.toSet().toList();
        filteredListByUser = filteredListByUser.reversed.toList();

        // if(isFiltered==true){
        //   filterCakesSearchList = myFilterList + myShapesFilter ;
        //   filterCakesSearchList = filterCakesSearchList.toSet().toList();
        //   filterCakesSearchList = filterCakesSearchList.reversed.toList();
        // }

      }
    });
  }

  //Clr shapes filter..
  void clearShapesFilter() {

    setState(() {

        myShapesFilter.clear();
        filterShapesCheck.clear();
        filterShapes.clear();
        shapeOnlyFilter = false;

        filteredListByUser = myFilterList + myShapesFilter;
        filteredListByUser = filteredListByUser.toSet().toList();
        filteredListByUser = filteredListByUser.reversed.toList();

    });

    Navigator.pop(context);

  }

  void activeSearchClear() {
    setState(() {
      searchCakesText = '';
      searchControl.text = '';
      cakeCategoryCtrl.text = '';
      cakeSubCategoryCtrl.text = '';
      cakeVendorCtrl.text = '';
      selectedFilter.clear();
    });
  }

  //clear the search
  void clearTheSearch() {
    setState(() {
      searchModeis = false;
      searchCakeCate = '';
      searchCakeSubType = '';
      searchCakeVendor = '';
      searchCakeLocation = '';
      Navigator.pop(context);
      eggOrEgglesList = cakesList.toList();
    });
  }

  //endregion

  @override
  void initState() {
    // TODO: implement initState
    Future.delayed(Duration.zero, () async {
      loadPrefs();
    });
    setState(() {
      _show = true;
      for (int i = 0; i < shapesOthersForFilter.length; i++) {
        otherShapeCheck.add(false);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    Future.delayed(Duration.zero, () async {
      var pr = await SharedPreferences.getInstance();
      pr.remove('iamYourVendor');
      pr.remove('vendorCakeMode');
      pr.remove('naveToHome');
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    profileUrl = context.watch<ContextData>().getProfileUrl();
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    // mySelVendors = context.watch<ContextData>().getMyVendorsList();

    //search & filters controlls

    /*1) get Egg or Eggless list..*/
    if (egglesSwitch == true) {
      setState(() {
        eggOrEgglesList = cakesList
            .where((element) => element['DefaultCakeEggOrEggless']
                .toString()
                .toLowerCase()
                .contains("eggless") || element['IsEgglessOptionAvailable']
            .toString()
            .toLowerCase()
            .contains("y")  ).toList();

        List subList = eggOrEgglesList.where((element)
        => element['CakeSubType'].contains(cakesTypes[currentIndex])
        ).toList();

        cakesByType = eggOrEgglesList.where((element)
        => element['CakeType'].contains(cakesTypes[currentIndex])
        ).toList();

        cakesByType = cakesByType + subList;

      });
    }
    else if (egglesSwitch == false) {
      setState(() {
        eggOrEgglesList = cakesList.toList();

        List subList = eggOrEgglesList.where((element)
        => element['CakeSubType'].contains(cakesTypes[currentIndex])
        ).toList();

        cakesByType = eggOrEgglesList.where((element)
        => element['CakeType'].contains(cakesTypes[currentIndex])
        ).toList();

        cakesByType = cakesByType + subList;
      });
    }

    /*2) if search and filter modes is on..*/
    if (isFilterisOn == true || shapeOnlyFilter == true || searchModeis == true) {
      setState(() {
        cakeSearchList = filteredListByUser.toList();
      });
      if (searchCakesText.isNotEmpty) {
        setState(() {
          activeSearch = true;
          cakeSearchList = filteredListByUser
              .where((element) => element['CakeName']
                  .toString()
                  .toLowerCase()
                  .contains(searchCakesText.toLowerCase()))
              .toList();
        });
      } else {
        setState(() {
          activeSearch = false;
          cakeSearchList = filteredListByUser.toList();
        });
      }
      if (isFiltered == true && searchCakesText.isNotEmpty) {
        setState(() {
          filterCakesSearchList = cakesByType
              .where((element) => element['CakeName']
                  .toString()
                  .toLowerCase()
                  .contains(searchCakesText.toLowerCase()))
              .toList();
        });
      } else {
        setState(() {
          filterCakesSearchList = cakesByType;
        });
      }
    }
    else {
      if (searchCakesText.isNotEmpty) {
        setState(() {
          activeSearch = true;
          cakeSearchList = eggOrEgglesList
              .where((element) => element['CakeName']
                  .toString()
                  .toLowerCase()
                  .contains(searchCakesText.toLowerCase()))
              .toList();
        });
      } else {
        setState(() {
          activeSearch = false;
          cakeSearchList = eggOrEgglesList;
        });


        /*3) Set list from search filters apply...*/
        if (cakeVendorCtrl.text.isNotEmpty ||
            cakeCategoryCtrl.text.isNotEmpty ||
            cakeSubCategoryCtrl.text.isNotEmpty ||
            selectedFilter.isNotEmpty) {

          setState(() {
            categorySearch = [];
            subCategorySearch = [];
            vendorBasedSearch = [];
            cakeTypeList = [];
            activeSearch = true;

            if (cakeCategoryCtrl.text.isNotEmpty) {
              categorySearch = eggOrEgglesList
                  .where((element) => element['CakeName']
                      .toString()
                      .toLowerCase()
                      .contains(cakeCategoryCtrl.text.toLowerCase()))
                  .toList();
            }

            if (cakeSubCategoryCtrl.text.isNotEmpty) {
              subCategorySearch = eggOrEgglesList
                  .where((element) => element['CakeName']
                      .toString()
                      .toLowerCase()
                      .contains(cakeSubCategoryCtrl.text.toLowerCase()))
                  .toList();
            }

            if (cakeVendorCtrl.text.isNotEmpty) {
              vendorBasedSearch = eggOrEgglesList
                  .where((element) => element['VendorName']
                      .toString()
                      .toLowerCase()
                      .contains(cakeVendorCtrl.text.toLowerCase()))
                  .toList();
            }

            if (selectedFilter.isNotEmpty) {
              for (int i = 0; i < eggOrEgglesList.length; i++) {
                if (eggOrEgglesList[i]['CakeType'].isNotEmpty) {
                  for (int j = 0; j < selectedFilter.length; j++) {
                    if (eggOrEgglesList[i]['CakeType']
                        .contains(selectedFilter[j])) {
                      cakeTypeList.add(eggOrEgglesList[i]);
                    }
                  }
                }
              }
            }

            // cakeSearchList.clear();

            cakeSearchList = categorySearch.toList() +
                subCategorySearch.toList() +
                vendorBasedSearch.toList() +
                cakeTypeList.toList();
            cakeSearchList = cakeSearchList.toSet().toList();
          });
        }
        else {
          // activeSearch = false;
          cakeSearchList = eggOrEgglesList;
        }
      }

      //4) if caketype and search is active
      if (isFiltered == true && searchCakesText.isNotEmpty) {
        setState(() {
          filterCakesSearchList = cakesByType
              .where((element) => element['CakeName']
                  .toString()
                  .toLowerCase()
                  .contains(searchCakesText.toLowerCase()))
              .toList();
        });
      }
      else {
        setState(() {
          filterCakesSearchList = cakesByType;
        });
      }

    }

    return RefreshIndicator(
      onRefresh: () async {
        loadPrefs();
      },
      child: WillPopScope(
        onWillPop: () async {

          if(activeSearch==true){
            activeSearchClear();
            return Future.value(false);
          }else{
            context.read<ContextData>().setMyVendors([]);
            context.read<ContextData>().addMyVendor(false);
            if (iamYourVendor == true) {
              Navigator.pop(context);
              return false;
            }else{
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>HomeScreen()));
            }
          }

          return Future.value(true);

        },
        child:Scaffold(
            drawer: NavDrawer(
              screenName: "ctype",
            ),
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
                          Text("TYPES OF CAKES",
                              style: TextStyle(
                                  color: darkBlue,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: poppins,
                                  fontSize: 16)
                          ),
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

                                        final tween =
                                            Tween(begin: begin, end: end);
                                        final curvedAnimation = CurvedAnimation(
                                          parent: animation,
                                          curve: curve,
                                        );
                                        return SlideTransition(
                                          position:
                                              tween.animate(curvedAnimation),
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
                                    pageBuilder: (context, animation,
                                            secondaryAnimation) =>
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
                                          backgroundImage: AssetImage(
                                              "assets/images/user.png")),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            bottomSheet: _show
                ? BottomSheet(
                    onClosing: () {
                      print('closing sheet...');
                    },
                    builder: (BuildContext context) {
                      return GestureDetector(
                        onTap: () {
                          //
                          setState((){
                            // searchByGivenFilter("", "", "", ["Theme Cake"]);
                            // isFiltered = true;
                            // activeSearch = true;
                            // print(cakeSearchList.length);
                            //
                            // cakesByType = cakeSearchList.where((element) =>
                            //     element['CakeType'].toString().toLowerCase()=="theme cake"
                            // ).toList();
                            searchCakesText = "Theme Cake";
                            searchControl.text = searchCakesText;
                          });
                        },
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              padding: EdgeInsets.all(15),
                              height: 100,
                              color: Colors.white,
                              child: Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(18),
                                    color: Colors.red[100]),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text.rich(TextSpan(children: [
                                      TextSpan(
                                        text: 'DO YOU WANT A ',
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16),
                                      ),
                                      TextSpan(
                                        text: 'THEME CAKE ',
                                        style: TextStyle(
                                            color: lightPink,
                                            fontWeight: FontWeight.w900,
                                            fontSize: 16),
                                      )
                                    ])),
                                    Expanded(
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: Container(
                                          color: Colors.transparent,
                                          height: 70,
                                          width: 70,
                                          child: Image(
                                            image: AssetImage(
                                                'assets/images/themecake.png'),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              left: width * 0.86,
                              top: -6,
                              child: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _show = false;
                                    });
                                  },
                                  icon: Icon(
                                    Icons.cancel_rounded,
                                    color: Colors.red,
                                    size: 30,
                                  )),
                            )
                          ],
                        ),
                      );
                    },
                  )
                : null,
            resizeToAvoidBottomInset: false,
            key: _scaffoldKey,
            body: Container(
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: Svg("assets/images/splash.svg"), fit: BoxFit.cover)),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    //TEXTs...
                    Container(
                      padding: EdgeInsets.only(left: 8, top: 10, bottom: 10),
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
                                  width: 150,
                                  child: GestureDetector(
                                    onTap: (){
                                      setState((){
                                        showAddressEdit = !showAddressEdit;
                                      });
                                      FocusScope.of(context).unfocus();
                                    },
                                    child: Text(
                                      '$userCurLocation',
                                      maxLines: 2 ,
                                      style: TextStyle(
                                          fontFamily: poppins,
                                          fontSize: 15,
                                          color: darkBlue,
                                          fontWeight: FontWeight.bold
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 5,),
                                GestureDetector(
                                  onTap: (){
                                    setState((){
                                      showAddressEdit = !showAddressEdit;
                                    });
                                    FocusScope.of(context).unfocus();
                                  },
                                  child: Icon(Icons.arrow_drop_down),
                                )
                              ],
                            ),
                          ),

                          showAddressEdit?
                          Container(
                            padding: EdgeInsets.only(right: 8,top: 10),
                            child: Row(
                              children: [
                                Expanded(
                                  child:Container(
                                    height: 45,
                                    child: TextField(
                                      controller: deliverToCtrl,
                                      style: TextStyle(fontFamily: poppins,fontSize: 13 ,
                                          fontWeight: FontWeight.bold),
                                      onChanged: (String? text){
                                        setState(() {

                                        });
                                      },
                                      decoration: InputDecoration(
                                          hintText: "Delivery location...",
                                          hintStyle: TextStyle(fontFamily: poppins,fontSize: 13,color: Colors.grey[400]),
                                          prefixIcon: Icon(Icons.search,color: Colors.grey[400]),
                                          fillColor: Colors.white,
                                          filled: true,
                                          border: OutlineInputBorder(
                                              borderSide: BorderSide(width: 1,color: Colors.grey[200]!,style: BorderStyle.solid),
                                              borderRadius: BorderRadius.circular(8)
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(width: 1.5,color: Colors.grey[300]!,style: BorderStyle.solid),
                                              borderRadius: BorderRadius.circular(8)
                                          ),
                                          contentPadding: EdgeInsets.all(5),
                                          suffixIcon: IconButton(
                                            onPressed: (){
                                              FocusScope.of(context).unfocus();
                                              setState(() {
                                                deliverToCtrl.text = "";
                                              });
                                            },
                                            icon: Icon(Icons.close),
                                            iconSize: 16,
                                          )
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  height: 45,
                                  width: 45,
                                  margin: EdgeInsets.only(left: 10),
                                  decoration: BoxDecoration(
                                      color: darkBlue,
                                      borderRadius: BorderRadius.circular(7)
                                  ),
                                  child: Semantics(
                                    child: IconButton(
                                        splashColor: Colors.black26,
                                        onPressed: () async{
                                          var pref = await SharedPreferences.getInstance();
                                          FocusScope.of(context).unfocus();
                                          if(deliverToCtrl.text.isNotEmpty){
                                            List<Location> location =
                                            await locationFromAddress(deliverToCtrl.text);
                                            print(location);
                                            setState((){
                                              userCurLocation = deliverToCtrl.text;
                                              userLatitude = location[0].latitude.toString();
                                              userLongtitude = location[0].longitude.toString();
                                              pref.setString('userLatitute', "${userLatitude}");
                                              pref.setString('userLongtitude', "${userLongtitude}");
                                              pref.setString("userCurrentLocation", deliverToCtrl.text);
                                              // getVendorForDeliveryto(authToken);
                                              getCakeList();
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
                          ):
                          Container()

                        ],
                      ),
                    ),

                    iamYourVendor == false
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                padding: EdgeInsets.only(
                                    left: 10, top: 10, bottom: 10),
                                width: 200,
                                child: Text(
                                  'Find And Order Your\nFavourite Cakes ',
                                  style: TextStyle(
                                      color: darkBlue,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      fontFamily: "Poppins"),
                                ),
                              ),
                              Container(
                                  child: Image(
                                height: 40,
                                width: 40,
                                image: AssetImage('assets/images/smilyfood.png'),
                              ))
                            ],
                          )
                        :
                        //Vendor name and whatsapp...
                        Container(
                            padding: EdgeInsets.only(left: 10, right: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.account_circle_outlined,
                                      color: darkBlue,
                                    ),
                                    Text(' VENDOR ',
                                        style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                            fontFamily: 'Poppins'))
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          child: Text(
                                            "${mySelVendors[0]['VendorName'].toString().toUpperCase()} ",
                                            style: TextStyle(
                                                color: darkBlue,
                                                fontFamily: "Poppins",
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Container(
                                            child: Image(
                                          height: 30,
                                          width: 30,
                                          image: AssetImage(
                                              'assets/images/smilyfood.png'),
                                        ))
                                      ],
                                    ),
                                    Container(
                                      width: 100,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              PhoneDialog().showPhoneDialog(context, vendorPhone1, vendorPhone2);
                                            },
                                            child: Container(
                                              alignment: Alignment.center,
                                              height: 35,
                                              width: 35,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.grey[200],
                                              ),
                                              child: const Icon(
                                                Icons.phone,
                                                color: Colors.blueAccent,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          InkWell(
                                            onTap: () {
                                              PhoneDialog().showPhoneDialog(context, vendorPhone1, vendorPhone2 , true);
                                            },
                                            child: Container(
                                              alignment: Alignment.center,
                                              height: 35,
                                              width: 35,
                                              decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Colors.grey[200]),
                                              child: const Icon(
                                                Icons.whatsapp_rounded,
                                                color: Colors.green,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                    //Searchbar...
                    Container(
                      padding: EdgeInsets.all(10),
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
                                controller: searchControl,
                                onChanged: (String? text) {
                                  setState(() {
                                    searchCakesText = text!;
                                  });
                                },
                                decoration: InputDecoration(
                                    hintText: "Search cake...",
                                    hintStyle: TextStyle(fontFamily: poppins,fontSize: 13,color: Colors.grey[400]),
                                    prefixIcon: Icon(Icons.search,color: Colors.grey[400]),
                                    fillColor: Colors.white,
                                    filled: true,
                                    border: OutlineInputBorder(
                                        borderSide: BorderSide(width: 1,color: Colors.grey[200]!,style: BorderStyle.solid),
                                        borderRadius: BorderRadius.circular(8)
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(width: 1.5,color: Colors.grey[300]!,style: BorderStyle.solid),
                                        borderRadius: BorderRadius.circular(8)
                                    ),
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
                                    setState(() {
                                      // _show = true;
                                    });
                                    showSearchFilterBottom();
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

                    //filters area
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Row(
                            children: [
                              Transform.scale(
                                scale: 0.7,
                                child: CupertinoSwitch(
                                  thumbColor: Color(0xffffffff),
                                  value: egglesSwitch,
                                  onChanged: (bool? val) {
                                    setState(() {
                                      egglesSwitch = val!;
                                    });
                                  },
                                  activeColor: Colors.green,
                                ),
                              ),
                              Text(
                                 'Eggless',
                                style: TextStyle(
                                    color: darkBlue,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: poppins
                                ),
                              ),
                            ],
                          ),
                          Container(
                            height: 20,
                            width: 2,
                            color: Colors.black54,
                          ),
                          InkWell(
                            onTap: () {
                              showShapesSheet();
                            },
                            child: Stack(
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.favorite_border_outlined, color: lightPink),
                                    Text(
                                      ' Shapes',
                                      style: TextStyle(
                                          color: darkBlue,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: poppins),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    )
                                  ],
                                ),
                                shapeOnlyFilter
                                    ? Positioned(
                                        right: 0,
                                        top: 0,
                                        child: CircleAvatar(
                                          radius: 6.5,
                                          backgroundColor: Colors.white,
                                          child: CircleAvatar(
                                            radius: 5.5,
                                            backgroundColor: Colors.red,
                                          ),
                                        ),
                                      )
                                    : Container()
                              ],
                            ),
                          ),
                          Container(
                            height: 20,
                            width: 2,
                            color: Colors.black54,
                          ),
                          InkWell(
                            onTap: () => showFilterBottom(),
                            child: Stack(
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.filter_list, color: lightPink),
                                    Text(
                                      ' Filter',
                                      style: TextStyle(
                                          color: darkBlue,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: poppins),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    )
                                  ],
                                ),
                                isFilterisOn
                                    ? Positioned(
                                        right: 0,
                                        top: 0,
                                        child: CircleAvatar(
                                          radius: 6.5,
                                          backgroundColor: Colors.white,
                                          child: CircleAvatar(
                                            radius: 5.5,
                                            backgroundColor: Colors.red,
                                          ),
                                        ),
                                      )
                                    : Container()
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    //Cake cate types
                    cakesTypes.length == 0
                        ? Container(
                            height: height * 0.08,
                            width: width,
                            child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: 10,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (context, index) {
                                  return Shimmer.fromColors(
                                    direction: ShimmerDirection.ttb,
                                    baseColor: Colors.grey,
                                    highlightColor: Colors.white,
                                    child: Container(
                                      padding: EdgeInsets.only(
                                          left: 20, right: 20, top: 6, bottom: 6),
                                      margin: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Colors.black,
                                          width: 0.5,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          CircleAvatar(
                                            backgroundColor: Colors.grey,
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Container(
                                            width: 80,
                                            height: 20,
                                            color: Colors.grey,
                                          )
                                        ],
                                      ),
                                    ),
                                  );
                                }))
                        : !activeSearch
                            ? Container(
                                height: height * 0.08,
                                width: width,
                                child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: cakesTypes.length,
                                    scrollDirection: Axis.horizontal,
                                    itemBuilder: (context, index) {
                                      selIndex.add(false);
                                      return InkWell(
                                        onTap: () {
                                          setState(() {
                                            for (int i = 0;
                                                i < selIndex.length;
                                                i++) {
                                              if (i == index) {
                                                if (i == 0) {
                                                  isFiltered = false;
                                                  selIndex[i] = true;
                                                } else {
                                                  selIndex[i] = true;
                                                  isFiltered = true;
                                                  currentIndex = index;

                                                  // for(int i =0;i<eggOrEgglesList.length;i++){
                                                  //   if(eggOrEgglesList[i]['CakeType'].contains(cakesTypes[index])){
                                                  //     print("Yessss....");
                                                  //     cakesByType.add(eggOrEgglesList[i]);
                                                  //   }else{
                                                  //     print("test failed...");
                                                  //   }
                                                  // }

                                                  List subList = eggOrEgglesList.where((element)
                                                  => element['CakeSubType'].contains(cakesTypes[index])
                                                  ).toList();

                                                  cakesByType = eggOrEgglesList.where((element)
                                                   => element['CakeType'].contains(cakesTypes[index])
                                                  ).toList();

                                                  cakesByType = cakesByType + subList;

                                                  cakesByType = cakesByType.toSet().toList();
                                                }
                                              } else {
                                                selIndex[i] = false;
                                              }
                                            }
                                          });
                                        },
                                        child: Container(
                                          padding: EdgeInsets.only(
                                              left: 15,
                                              right: 15,
                                              top: 6,
                                              bottom: 6),
                                          margin: EdgeInsets.only(
                                              top: 10,
                                              bottom: 10,
                                              left: 5,
                                              right: 5),
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                color: lightPink,
                                                width: 0.5,
                                              ),
                                              color: selIndex[index]
                                                  ? Colors.red[100]
                                                  : Colors.white),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              index==0?Container(
                                                height: 30,
                                                width: 30,
                                                decoration: BoxDecoration(
                                                  image: DecorationImage(
                                                    image: AssetImage("assets/images/cakefour.jpg")
                                                  )
                                                ),
                                              ):
                                              index==1?Container(
                                                height: 30,
                                                width: 30,
                                                decoration: BoxDecoration(
                                                    image: DecorationImage(
                                                        image: AssetImage("assets/images/cakethree.png")
                                                    )
                                                ),
                                              ):
                                              index==2?Container(
                                                height: 30,
                                                width: 30,
                                                decoration: BoxDecoration(
                                                    image: DecorationImage(
                                                        image: AssetImage("assets/images/cakelist.png")
                                                    )
                                                ),
                                              ):
                                              index==3?Container(
                                                height: 30,
                                                width: 30,
                                                decoration: BoxDecoration(
                                                    image: DecorationImage(
                                                        image: AssetImage("assets/images/cakefour.jpg")
                                                    )
                                                ),
                                              ):
                                              Icon(Icons.cake_outlined , color: lightPink,),

                                              Text(
                                                " ${cakesTypes[index][0].toString().toUpperCase() + cakesTypes[index].toString().substring(1).toLowerCase()}",
                                                style: TextStyle(
                                                    color: darkBlue,
                                                    fontFamily: poppins
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      );
                                    }))
                            : Container(),

                    //Filttered cakes
                    !activeSearch
                        ? Visibility(
                            visible: isFiltered,
                            child: Column(
                              children: [
                                StaggeredGridView.countBuilder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  padding: EdgeInsets.all(8.0),
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 5,
                                  crossAxisSpacing: 7,
                                  itemCount: filterCakesSearchList.length,
                                  itemBuilder: (BuildContext context, int index) {
                                    return index == 0
                                        ? GestureDetector(
                                            onTap: () {
                                              sendFillDetailsToScreen(index);
                                            },
                                            child: Column(
                                              children: [
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                Text('Found',
                                                    style: TextStyle(
                                                        color: darkBlue,
                                                        fontSize: 16,
                                                        fontFamily: "Poppins")),
                                                Text(
                                                    filterCakesSearchList.length
                                                            .toString() +
                                                        " items",
                                                    style: TextStyle(
                                                        color: darkBlue,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 20,
                                                        fontFamily: "Poppins")),
                                                SizedBox(
                                                  height: 5,
                                                ),
                                                Container(
                                                  margin:
                                                      EdgeInsets.only(top: 10),
                                                  padding: EdgeInsets.all(10),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(14),
                                                    color: Colors.white,
                                                    boxShadow: [
                                                      BoxShadow(
                                                          blurRadius: 10,
                                                          color: Colors.black12,
                                                          spreadRadius: 0)
                                                    ],
                                                  ),
                                                  child: Column(
                                                    children: [
                                                      CircleAvatar(
                                                        radius: 50,
                                                        backgroundImage: filterCakesSearchList[
                                                                        index]
                                                                    ['MainCakeImage']
                                                                .isEmpty
                                                            ? NetworkImage(
                                                                "https://w0.peakpx.com/wallpaper/863/651/HD-wallpaper-red-cake-pastries-desserts-cakes-strawberry-cake-berry-cake.jpg")
                                                            : NetworkImage(
                                                                filterCakesSearchList[index]['MainCakeImage']
                                                                    .toString()),
                                                      ),
                                                      SizedBox(
                                                        height: 8,
                                                      ),
                                                      Text(
                                                          "${filterCakesSearchList[index]['CakeName'][0].toString().toUpperCase() + filterCakesSearchList[index]['CakeName'].toString().substring(1).toLowerCase()}",
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                              color: darkBlue,
                                                              fontWeight:
                                                                  FontWeight.bold,
                                                              fontSize: 13,
                                                              fontFamily:
                                                                  "Poppins")),
                                                      SizedBox(
                                                        height: 8,
                                                      ),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text(
                                                              '₹ ${filterCakesSearchList[index]['BasicCakePrice']}',
                                                              style: TextStyle(
                                                                  color:
                                                                      lightPink,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 14,
                                                                  fontFamily:
                                                                      poppins)),
                                                          Container(
                                                            padding:
                                                                EdgeInsets.all(4),
                                                            decoration: BoxDecoration(
                                                                color: Colors.grey
                                                                    .withOpacity(
                                                                        0.5),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8)),
                                                            child: Text(
                                                                filterCakesSearchList[index]['MinWeight'].isEmpty
                                                                    ? 'NF'
                                                                    : '${filterCakesSearchList[index]['MinWeight'].toString()}',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .black,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        12)),
                                                          )
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        : GestureDetector(
                                            behavior: HitTestBehavior.opaque,
                                            onTap: () {
                                              sendFillDetailsToScreen(index);
                                            },
                                            child: Column(children: [
                                              Container(
                                                margin: EdgeInsets.only(top: 10),
                                                padding: EdgeInsets.all(10),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(14),
                                                  color: Colors.white,
                                                  boxShadow: [
                                                    BoxShadow(
                                                        blurRadius: 10,
                                                        color: Colors.black12,
                                                        spreadRadius: 0)
                                                  ],
                                                ),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    CircleAvatar(
                                                      radius: 50,
                                                      backgroundImage: filterCakesSearchList[
                                                                  index]['MainCakeImage']
                                                              .isEmpty
                                                          ? NetworkImage(
                                                              "https://w0.peakpx.com/wallpaper/863/651/HD-wallpaper-red-cake-pastries-desserts-cakes-strawberry-cake-berry-cake.jpg")
                                                          : NetworkImage(
                                                              filterCakesSearchList[index]['MainCakeImage'].toString()),
                                                    ),
                                                    SizedBox(
                                                      height: 8,
                                                    ),
                                                    Text(
                                                        "${filterCakesSearchList[index]['CakeName'][0].toString().toUpperCase() +
                                                            filterCakesSearchList[index]['CakeName'].toString().substring(1).toLowerCase()}",
                                                        maxLines: 2,
                                                        overflow:
                                                            TextOverflow.ellipsis,
                                                        style: TextStyle(
                                                            color: darkBlue,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 15)),
                                                    SizedBox(
                                                      height: 8,
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                            '₹ ${filterCakesSearchList[index]['BasicCakePrice']}',
                                                            style: TextStyle(
                                                                color: lightPink,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 14,
                                                                fontFamily:
                                                                    "Poppins")),
                                                        Container(
                                                          padding:
                                                              EdgeInsets.all(4),
                                                          decoration: BoxDecoration(
                                                              color: Colors.grey
                                                                  .withOpacity(
                                                                      0.5),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8)),
                                                          child: Text(
                                                              filterCakesSearchList[index]['MinWeightList'].isEmpty
                                                                  ? 'NF'
                                                                  : '${filterCakesSearchList[index]['MinWeightList'][0].toString().split(',').first}',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 12)),
                                                        )
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ]),
                                          );
                                  },
                                  staggeredTileBuilder: (int index) =>
                                      StaggeredTile.fit(1),
                                ),
                                Visibility(
                                  visible: isNetworkError ? false : true,
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: Text(
                                      filterCakesSearchList.length > 0
                                          ? 'Load completed.'
                                          : 'No results found.',
                                      style: TextStyle(
                                          fontFamily: "Poppins",
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Container(),
                    //All cakes...
                    !activeSearch
                        ? Visibility(
                            visible: isFiltered ? false : true,
                            child: Column(
                              children: [
                                StaggeredGridView.countBuilder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  padding: EdgeInsets.all(8.0),
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 5,
                                  crossAxisSpacing: 7,
                                  itemCount: cakeSearchList.length,
                                  itemBuilder: (BuildContext context, int index) {
                                    return index == 0
                                        ? GestureDetector(
                                            onTap: () {
                                              sendDetailsToScreen(index);
                                            },
                                            child: Column(
                                              children: [
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                Text('Found',
                                                    style: TextStyle(
                                                        color: darkBlue,
                                                        fontSize: 16,
                                                        fontFamily: "Poppins")),
                                                Text(
                                                    cakeSearchList.length
                                                            .toString() +
                                                        " items",
                                                    style: TextStyle(
                                                        color: darkBlue,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 20,
                                                        fontFamily: "Poppins")),
                                                SizedBox(
                                                  height: 5,
                                                ),
                                                Container(
                                                  margin:
                                                      EdgeInsets.only(top: 10),
                                                  padding: EdgeInsets.all(10),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(14),
                                                    color: Colors.white,
                                                    boxShadow: [
                                                      BoxShadow(
                                                          blurRadius: 10,
                                                          color: Colors.black12,
                                                          spreadRadius: 0)
                                                    ],
                                                  ),
                                                  child: Column(
                                                    children: [
                                                      CircleAvatar(
                                                        radius: 50,
                                                        backgroundImage: cakeSearchList[index]['MainCakeImage'] == null ||
                                                                cakeSearchList[index]['MainCakeImage'].isEmpty
                                                            ? NetworkImage(
                                                                "https://w0.peakpx.com/wallpaper/863/651/HD-wallpaper-red-cake-pastries-desserts-cakes-strawberry-cake-berry-cake.jpg")
                                                            : NetworkImage(
                                                                cakeSearchList[index]['MainCakeImage'].toString()),
                                                      ),
                                                      SizedBox(
                                                        height: 8,
                                                      ),
                                                      Text(
                                                          "${cakeSearchList[index]['CakeName'][0].toString().toUpperCase() + cakeSearchList[index]['CakeName'].toString().substring(1).toLowerCase()}",
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                              color: darkBlue,
                                                              fontWeight:
                                                                  FontWeight.bold,
                                                              fontSize: 13,
                                                              fontFamily:
                                                                  "Poppins")),
                                                      SizedBox(
                                                        height: 8,
                                                      ),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text(
                                                              '₹ ${cakeSearchList[index]['BasicCakePrice']}',
                                                              style: TextStyle(
                                                                  color:
                                                                      lightPink,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 14,
                                                                  fontFamily:
                                                                      "Poppins")),
                                                          Container(
                                                            padding:
                                                                EdgeInsets.all(4),
                                                            decoration: BoxDecoration(
                                                                color: Colors.grey
                                                                    .withOpacity(
                                                                        0.5),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8)),
                                                            child: Text(
                                                                cakeSearchList[index]['MinWeight']
                                                                        .isEmpty
                                                                    ? 'NF'
                                                                    : '${cakeSearchList[index]['MinWeight']}',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .black,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        12)
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                          )
                                        : GestureDetector(
                                            onTap: () {
                                              sendDetailsToScreen(index);
                                            },
                                            child: Column(
                                              children: [
                                                Container(
                                                  margin:
                                                  EdgeInsets.only(top: 10),
                                                  padding: EdgeInsets.all(10),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                    BorderRadius.circular(14),
                                                    color: Colors.white,
                                                    boxShadow: [
                                                      BoxShadow(
                                                          blurRadius: 10,
                                                          color: Colors.black12,
                                                          spreadRadius: 0)
                                                    ],
                                                  ),
                                                  child: Column(
                                                    children: [
                                                      CircleAvatar(
                                                        radius: 50,
                                                        backgroundImage: cakeSearchList[index]['MainCakeImage'] == null ||
                                                            cakeSearchList[index]['MainCakeImage'].isEmpty
                                                            ? NetworkImage(
                                                            "https://w0.peakpx.com/wallpaper/863/651/HD-wallpaper-red-cake-pastries-desserts-cakes-strawberry-cake-berry-cake.jpg")
                                                            : NetworkImage(
                                                            cakeSearchList[index]['MainCakeImage'].toString()),
                                                      ),
                                                      SizedBox(
                                                        height: 8,
                                                      ),
                                                      Text(
                                                          "${cakeSearchList[index]['CakeName'][0].toString().toUpperCase() + cakeSearchList[index]['CakeName'].toString().substring(1).toLowerCase()}",
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                              color: darkBlue,
                                                              fontWeight:
                                                              FontWeight.bold,
                                                              fontSize: 13,
                                                              fontFamily:
                                                              "Poppins")),
                                                      SizedBox(
                                                        height: 8,
                                                      ),
                                                      Row(
                                                        mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                        children: [
                                                          Text(
                                                              '₹ ${cakeSearchList[index]['BasicCakePrice']}',
                                                              style: TextStyle(
                                                                  color:
                                                                  lightPink,
                                                                  fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                                  fontSize: 14,
                                                                  fontFamily:
                                                                  "Poppins")),
                                                          Container(
                                                            padding:
                                                            EdgeInsets.all(4),
                                                            decoration: BoxDecoration(
                                                                color: Colors.grey
                                                                    .withOpacity(
                                                                    0.5),
                                                                borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                    8)),
                                                            child: Text(
                                                                cakeSearchList[index]['MinWeight']
                                                                    .isEmpty
                                                                    ? 'NF'
                                                                    : '${cakeSearchList[index]['MinWeight']}',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .black,
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                    fontSize:
                                                                    12)),
                                                          )
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                          );
                                  },
                                  staggeredTileBuilder: (int index) =>
                                      StaggeredTile.fit(1),
                                ),
                                Visibility(
                                  visible: isNetworkError ? false : true,
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: Text(
                                      cakeSearchList.length > 0
                                          ? 'Load completed.'
                                          : 'No results found.',
                                      style: TextStyle(
                                          fontFamily: "Poppins",
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : // cakeSearchList.isNotEmpty?
                        Container(
                            child: (cakeSearchList.length == 0)
                                ? Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      "No Similar data found!",
                                      style: TextStyle(
                                        fontFamily: "Poppins",
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  )
                                : ListView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: cakeSearchList.length,
                                    itemBuilder: (c, i) {
                                      return Container(
                                        margin: EdgeInsets.only(
                                            left: 15,
                                            right: 15,
                                            top: 5,
                                            bottom: 5),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            color: Colors.white,
                                            border: Border.all(
                                                color: Colors.grey[400]!,
                                                width: 0.5)),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
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
                                                    borderRadius:
                                                        BorderRadius.only(
                                                      topLeft:
                                                          Radius.circular(15),
                                                      topRight:
                                                          Radius.circular(15),
                                                    ),
                                                    color: Colors.grey[300]),
                                                child: Row(children: [
                                                  Container(
                                                    child: Text(
                                                      '${cakeSearchList[i]['VendorName']} ',
                                                      style: TextStyle(
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontFamily: 'Poppins',
                                                          fontSize: 13),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  Row(
                                                    children: [
                                                      RatingBar.builder(
                                                        initialRating: double.parse(cakeSearchList[i]['Ratings'].toString()),
                                                        minRating: 1,
                                                        direction:
                                                            Axis.horizontal,
                                                        allowHalfRating: true,
                                                        itemCount: 5,
                                                        itemSize: 14,
                                                        itemPadding:
                                                            EdgeInsets.symmetric(
                                                                horizontal: 1.0),
                                                        itemBuilder:
                                                            (context, _) => Icon(
                                                          Icons.star,
                                                          color: Colors.amber,
                                                        ),
                                                        onRatingUpdate:
                                                            (rating) {},
                                                      ),
                                                      Text(
                                                        ' ${cakeSearchList[i]['Ratings'].toString().characters.take(3)}',
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
                                                          alignment: Alignment
                                                              .centerRight,
                                                          child: InkWell(
                                                            onTap: () {
                                                              sendDetailsToScreen(
                                                                  i);
                                                            },
                                                            child: Container(
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                height: 25,
                                                                width: 25,
                                                                decoration: BoxDecoration(
                                                                    shape: BoxShape
                                                                        .circle,
                                                                    color: Colors
                                                                        .white),
                                                                child: Icon(
                                                                  Icons
                                                                      .arrow_forward_ios_sharp,
                                                                  color:
                                                                      lightPink,
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
                                                    cakeSearchList[i]['MainCakeImage'].isEmpty ||
                                                            cakeSearchList[i]['MainCakeImage'] == ''
                                                        ? Container(
                                                            height: 85,
                                                            width: 85,
                                                            alignment:
                                                                Alignment.center,
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          15),
                                                              color: Colors
                                                                  .pink[100],
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
                                                                        .circular(
                                                                            15),
                                                                color:
                                                                    Colors.blue,
                                                                image: DecorationImage(
                                                                    image: NetworkImage(
                                                                        cakeSearchList[i]['MainCakeImage']),
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
                                                                      FontWeight
                                                                          .bold,
                                                                  fontFamily:
                                                                      'Poppins',
                                                                  fontSize: 12),
                                                              maxLines: 2,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ),
                                                          SizedBox(height: 5),
                                                          Container(
                                                            // width:120,
                                                            child:
                                                              Text.rich(
                                                                TextSpan(
                                                                  text: 'Price Rs.${cakeSearchList[i]['BasicCakePrice']}/Kg Min Quantity '
                                                                      '${cakeSearchList[i]['MinWeight']} ',
                                                                  style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontFamily: 'Poppins', fontSize: 10),
                                                                children: [
                                                                  TextSpan(
                                                                    text:cakeSearchList[i]['BasicCustomisationPossible']=="y"?
                                                                    "Basic Customisation Available":'No Customisations Available',
                                                                    style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontFamily: 'Poppins', fontSize: 10),
                                                                  )
                                                                ]
                                                                ),
                                                              ),
                                                          ),
                                                          SizedBox(height: 5),
                                                          Container(
                                                              height: 0.5,
                                                              color: Color(
                                                                  0xffdddddd)),
                                                          SizedBox(height: 5),
                                                          Container(
                                                            // width:120,
                                                            child:Text(i.isOdd?'FREE DELIVERY':'DELIVERY FEE RS.20',
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
            ),
          ),
      ),
    );
  }
}
