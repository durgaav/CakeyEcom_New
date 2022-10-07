import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cakey/OtherProducts/OtherDetails.dart';
import 'package:cakey/screens/CakeDetails.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
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
import '../drawermenu/app_bar.dart';
import '../screens/Profile.dart';
import 'CustomiseCake.dart';
import 'HomeScreen.dart';
import 'Notifications.dart';
import 'package:google_maps_webservice/places.dart' as wbservice;

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
  String currentCakeType = "";

  var adminDeliveryCharge = 0;
  var adminDeliveryChargeKm = 0;

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

  //noti
  int notiCount = 0;

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

  //other products
  List otherProducts = [];
  List otherFilteredProducts = [];
  List otherEggProducts = [];

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
  List<double> rangeValuesList = [];

  //for search filter
  List categorySearch = [];
  List subCategorySearch = [];
  List vendorBasedSearch = [];

  List seleVendorDetailsList = [];

  List<String> activeVendorsIds = [];

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

    var flavExpand = false;
    var shapeExpand = false;

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
                                  minThumbSeparation: 3,
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
                                onExpansionChanged: (e){
                                  setState((){
                                    flavExpand = e;
                                  });
                                },
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
                                      ? '${fixedFilterFlav.length} flavour(s) selected.'
                                      : 'Choose Flavour',
                                  style: TextStyle(
                                    fontFamily: "Poppins",
                                  ),
                                ),
                                trailing: !flavExpand?
                                Container(
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
                                ):Container(
                                  alignment: Alignment.center,
                                  height: 25,
                                  width: 25,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.keyboard_arrow_up_rounded,
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
                                onExpansionChanged: (e){
                                  setState((){
                                    shapeExpand = e;
                                  });
                                },
                                title: Text(
                                  'Shapes',
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: darkBlue,
                                      fontFamily: "Poppins",
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  filterShapes.isNotEmpty
                                      ? '${filterShapes.length} shape(s) selected'
                                      : 'Choose shapes',
                                  style: TextStyle(
                                    fontFamily: "Poppins",
                                  ),
                                ),
                                trailing: !shapeExpand?
                                Container(
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
                                ):Container(
                                  alignment: Alignment.center,
                                  height: 25,
                                  width: 25,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.keyboard_arrow_up_rounded,
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
                                // if(currentCakeType.toLowerCase()=="others"){
                                //   applyOthersFilter(
                                //     priceRangeStart,
                                //     priceRangeEnd,
                                //     fixedFilterShapes,
                                //     fixedFilterFlav,
                                //   );
                                // }else{
                                //
                                // }
                                applyFilters(
                                    priceRangeStart,
                                    priceRangeEnd,
                                    fixedFilterFlav,
                                    filterShapes,
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
        if(cakesTypes[i]['name'].toString().toLowerCase()!="all cakes" &&
            cakesTypes[i]['name'].toString().toLowerCase()!="others"){
          myList.add(cakesTypes[i]);
        }
      }
    });

    showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(20),
              topLeft: Radius.circular(20)),
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
                          textCapitalization: TextCapitalization.words,
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
                        runSpacing: -5,
                        spacing: 5,
                        children: myList.map((e) {
                          bool clicked = false;
                          if (selectedFilter.contains(e['name'])) {
                            clicked = true;
                          }
                          return OutlinedButton(
                              onPressed: (){
                                setState((){
                                  if(selectedFilter.contains(e['name'])){
                                    selectedFilter.removeWhere(
                                            (element) => element == e['name']);
                                    clicked = false;
                                  }else{
                                    selectedFilter.add(e['name']);
                                    clicked = true;
                                  }
                                });
                              },
                              child: Text(e['name'],style: TextStyle(
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
                                    selectedFilter
                                );
                              });
                            },
                            child: const Text(
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(20),
              topLeft: Radius.circular(20)),
        ),
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

        List sub = otherProducts
            .where((element) => element["ProductName"]
            .toString()
            .toLowerCase()
            .contains(category.toLowerCase()))
            .toList();

        a = eggOrEgglesList
            .where((element) => element['CakeName']
                .toString()
                .toLowerCase()
                .contains(category.toLowerCase()))
            .toList();
        a = sub + a;
        searchModeis = true;
        activeSearch = true;
      }

      if (subCategory.isNotEmpty) {
        //CakeSubType
        setState((){
          b = eggOrEgglesList.where((element) => element['CakeSubType'].contains(subCategory)).toList();
          // for (int i = 0; i < cakesList.length; i++) {
          //   if(cakesList[i]['CakeSubType'].isNotEmpty && cakesList[i]['CakeSubType'].contains(subCategory)){
          //     b.add(cakesList[i]);
          //   }
          // }
          searchModeis = true;
          activeSearch = true;
        });
      }

      if (vendorName.isNotEmpty) {
        setState(() {

          List sub = otherProducts
              .where((element) => element["VendorName"]
              .toString()
              .toLowerCase()
              .contains(vendorName.toLowerCase()))
              .toList();

          c = eggOrEgglesList
              .where((element) => element['VendorName']
                  .toString()
                  .toLowerCase()
                  .contains(vendorName.toLowerCase()))
              .toList();

          c = c+sub;

          searchModeis = true;
          activeSearch = true;
        });
      }

      if (filterCType.isNotEmpty) {
        // isFiltered = true;
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
        searchModeis = true;
        activeSearch = true;
      }

      filteredListByUser = a + b + c + d.toList();
      filteredListByUser = filteredListByUser.toSet().toList();

      print("cakeSearchList len : ${filteredListByUser.length}");
      print("cakeSearchList len : ${eggOrEgglesList.length}");

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
      adminDeliveryCharge = pref.getInt("todayDeliveryCharge")??0;
      adminDeliveryChargeKm = pref.getInt("todayDeliveryKm")??0;
      myVendorId = pref.getString('myVendorId') ?? 'Not Found';
      vendorName = pref.getString('myVendorName') ?? 'Un Name';
      vendorPhone = pref.getString('myVendorPhone') ?? '0000000000';
      vendorPhone1 = pref.getString('myVendorPhone1')??'null';
      vendorPhone2 = pref.getString('myVendorPhone2')??'null';

      iamYourVendor = pref.getBool('iamYourVendor')?? false;

      activeVendorsIds = pref.getStringList('activeVendorsIds')??[];

      // if (iamYourVendor == true) {
      //   mySelVendors = [
      //     {"VendorName": vendorName , "VendorPhn1":vendorPhone1,"VendorPhn2":vendorPhone2}
      //   ];
      // } else {}

      getCakeType();
      getCakeList();
    });
  }

  //fetch others..
  Future<void> getOtherProducts() async{

    var headers = {
      'Authorization': '$authToken'
    };
    otherProducts.clear();
    try{


      var request = http.Request('GET',
          Uri.parse('https://cakey-database.vercel.app/api/otherproduct/activevendors/list'));

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        var map = jsonDecode(await response.stream.bytesToString());

        print("map .... $map");

        setState((){

          if(iamYourVendor == true){

            List myList = map.where((element) =>
            calculateDistance(
                double.parse(userLatitude),
                double.parse(userLongtitude),
                element['GoogleLocation']['Latitude'],
                element['GoogleLocation']['Longitude']) <=
                10)
                .toList();


            otherProducts = myList.where((element) => element['VendorName'].toString().toLowerCase()==
                mySelVendors[0]['VendorName'].toString().toLowerCase()).toList();

          }else{
            // otherProducts = map.where((element) =>
            // calculateDistance(
            //     double.parse(userLatitude),
            //     double.parse(userLongtitude),
            //     element['GoogleLocation']['Latitude'],
            //     element['GoogleLocation']['Longitude']) <=
            //     10)
            //     .toList();

            if(activeVendorsIds.isNotEmpty){
              for(int i = 0;i<activeVendorsIds.length;i++){
                otherProducts = otherProducts+map.where((element) => element['VendorID'].toString().toLowerCase()==
                    activeVendorsIds[i].toLowerCase()).toList();
              }
            }

            otherProducts = otherProducts.toSet().toList();

          }

        });

      }
      else {
        print(response.reasonPhrase);
      }
    }catch(e){
      print(e);
    }


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

        cakesTypes.add(
            {"name":"All Cakes"}
        );
        cakesTypes.add(
            {"name":"Others"}
        );

        if (mainList.length > 1) {
          for (int i = 0; i < mainList.length; i++) {

            if (mainList[i]['Type'] != null) {
              cakesTypes.add(
                  {
                    "name":mainList[i]['Type'].toString(),
                    "image":mainList[i]['Type_Image'].toString(),
                  }
              );
            }

            if(mainList[i]['SubType'].isNotEmpty && mainList[i]['SubType']!=null){
              for(int k = 0 ; k<mainList[i]['SubType'].length;k++){
                print(mainList[i]['SubType'][k]);
                cakesTypes.add(
                    {
                      "name":mainList[i]['SubType'][k]['Name'].toString(),
                      "image":mainList[i]['SubType'][k]['SubType_Image'].toString(),
                    }
                );
              }
            }

          }
        }

        print('Sub types>>>> $subType');

        // cakesTypes.add("All Cakes");
        // List sub = ["All Cakes","Others"];
        // //cakesTypes.add("Others");
        // cakesTypes.sort();
        cakesTypes = cakesTypes.toSet().toList();
        currentIndex = cakesTypes.indexWhere((element) => element['name'].toString().toLowerCase()=="all cakes");

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

    //getOtherProducts();
  }

  //Fetching cake list API...
  Future<void> getCakeList() async {

    //http://sugitechnologies.com:88/cakey/api/

    showAlertDialog();
    cakesList.clear();
    print("Ven iddd : $myVendorId");

    String commonCake = 'https://cakey-database.vercel.app/api/cakes/activevendors/list';
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
        }
        else {
          setState(() {
            isNetworkError = false;
            List cakList = jsonDecode(response.body);

            // cakesList = cakesList.reversed.toList();

            for (int i = 0; i < cakList.length; i++) {
              rangeValuesList.add(double.parse(cakList[i]['BasicCakePrice']));
              print(cakList[i]['CakeCategory']);
              // cakesTypes.add(cakList[i]['CakeType'].toString());
            }

            if(activeVendorsIds.isNotEmpty){
              for(int i=0;i<activeVendorsIds.length;i++){
                cakesList = cakesList + cakList.where((element) =>element['VendorID'].toString().toLowerCase()==
                    activeVendorsIds[i].toLowerCase()).toList();
              }
            }

            cakesList = cakesList.reversed.toList();
            cakesList = cakesList.toSet().toList();
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
      print(error);
      checkNetwork();
      Navigator.pop(context);
    }

    getOtherProducts();

  }

  Future<void> getVendor(String venID) async{

    showAlertDialog();

    try{
      var headers = {
        'Authorization': '$authToken'
      };
      var request = http.Request('GET', Uri.parse('https://cakey-database.vercel.app/api/vendors/list'));

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        var map = jsonDecode(await response.stream.bytesToString());


        setState((){
           seleVendorDetailsList = map.where((e)=>e['_id'].toString().toLowerCase()==venID).toList();
        });

        Navigator.pop(context);
      }
      else {
        print(response.reasonPhrase);
        Navigator.pop(context);
      }
    }catch(e){
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

  //send others
  Future<void> sendOthers(String id) async{

    int index = otherProducts.indexWhere((element) => element['_id'].toString()==id);

    var prefs = await SharedPreferences.getInstance();
    List weight = [];
    List<String> flavs = [];
    List<String> images = [];

    //add flav
    for(int i = 0 ;i<otherProducts[index]['Flavour'].length;i++){
      flavs.add(otherProducts[index]['Flavour'][i].toString());
    }

    if(otherProducts[index]['AdditionalProductImages']!=null||otherProducts[index]['AdditionalProductImages'].isNotEmpty){
      for(int j = 0;j<otherProducts[index]['AdditionalProductImages'].length;j++){
        images.add(otherProducts[index]['AdditionalProductImages'][j].toString());
      }
    }

    //add images
    for(int i = 0 ;i<otherProducts[index]['ProductImage'].length;i++){
      images.add(otherProducts[index]['ProductImage'][i].toString());
    }

    if(otherProducts[index]['Type'].toString().toLowerCase()=="kg"){
      weight = [otherProducts[index]['MinWeightPerKg']];
    }else if(otherProducts[index]['Type'].toString().toLowerCase()=="unit"){
      weight = otherProducts[index]['MinWeightPerUnit'];
    }else{
      weight = otherProducts[index]['MinWeightPerBox'];
    }


    prefs.setString("otherName" , otherProducts[index]['ProductName'].toString());

    if(otherProducts[index]['Shape']!=null){
      prefs.setString("otherShape" , otherProducts[index]['Shape'].toString());
    } else{
      prefs.setString("otherShape" , "None");
    }

    prefs.setString("otherSubType" , otherProducts[index]['CakeSubType'].toString());
    prefs.setString("otherMainId" , otherProducts[index]['_id'].toString());
    prefs.setString("otherModID" , otherProducts[index]['Id'].toString());
    prefs.setString("otherDiscound" , otherProducts[index]['Discount'].toString());
    prefs.setString("otherComName" , otherProducts[index]['ProductCommonName'].toString());
    prefs.setString("otherVendorId" , otherProducts[index]['VendorID'].toString());
    prefs.setString("otherType" , otherProducts[index]['Type'].toString());
    prefs.setString("otherEggOr" , otherProducts[index]['EggOrEggless'].toString());
    prefs.setString("otherMinDel" , otherProducts[index]['MinTimeForDelivery'].toString());
    prefs.setString("otherBestUse" , otherProducts[index]['BestUsedBefore'].toString());
    prefs.setString("otherStoredIn" , otherProducts[index]['ToBeStoredIn'].toString()??"");
    // prefs.setString("otherKeepInRoom" , otherProducts[index]['KeepTheCakeInRoomTemperature'].toString());
    prefs.setString("otherDescrip" , otherProducts[index]['Description'].toString());
    prefs.setString("otherRatings" , otherProducts[index]['Ratings'].toString());
    prefs.setString("otherVendorAddress" , otherProducts[index]['VendorAddress']);
    prefs.setString("otherVenMainId" , otherProducts[index]['VendorID']);
    prefs.setString("otherVenModId" , otherProducts[index]['Vendor_ID']);
    prefs.setString("otherVenName" , otherProducts[index]['VendorName']);
    prefs.setString("otherVenPhn1" , otherProducts[index]['VendorPhoneNumber1']);
    prefs.setString("otherVenPhn2" , otherProducts[index]['VendorPhoneNumber2']??"");

    if(otherProducts[index]['MinTimeForDelivery']!=null){
      prefs.setString("otherMiniDeliTime" , otherProducts[index]['MinTimeForDelivery']);
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

  //Send prefs to next screen....
  Future<void> sendDetailsToScreen(String id) async {

    print(currentCakeType);

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
    prefs.setString("cakeType", cakeSearchList[index]['CakeType'].toString()??"null");
    prefs.setString("cakeSubType", currentCakeType??"null");
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
            tiersDelTimes
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

    print(currentCakeType);

    //Local Vars
    List<String> cakeImgs = [];
    List<String> cakeWeights = [];
    List cakeFlavs = [];
    List cakeShapes = [];
    List cakeTiers = [];
    List tiersDelTimes = [];
    List<String> typesOfCake = [];
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

    //getting cake types
    if (filterCakesSearchList[index]['CakeType'].isNotEmpty) {
      setState(() {
        for (int i = 0; i < filterCakesSearchList[index]['CakeType'].length; i++) {
          typesOfCake.add(filterCakesSearchList[index]['CakeType'][i].toString());
        }
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
    // if (filterCakesSearchList[index]['TierCakeMinWeightAndPrice'].isNotEmpty||filterCakesSearchList[index]['TierCakeMinWeightAndPrice']!=null) {
    //   setState(() {
    //     cakeTiers = filterCakesSearchList[index]['TierCakeMinWeightAndPrice'];
    //   });
    // } else {
    //   setState(() {
    //     cakeTiers = [];
    //   });
    // }
    //
    // if (filterCakesSearchList[index]['MinTimeForDeliveryFortierCake'].isNotEmpty||filterCakesSearchList[index]['MinTimeForDeliveryFortierCake']!=null) {
    //   setState(() {
    //     tiersDelTimes = filterCakesSearchList[index]['MinTimeForDeliveryFortierCake'];
    //   });
    // } else {
    //   setState(() {
    //     tiersDelTimes = [];
    //   });
    // }

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
    prefs.setStringList('cakeMainTypes', typesOfCake);

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
    prefs.setString("cakeType", filterCakesSearchList[index]['CakeType'].toString()??"null");
    prefs.setString("cakeSubType", currentCakeType??"null");
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
    prefs.setString("cakeOtherInstToCus", filterCakesSearchList[index]['OtherInstructions'].toString());

    // if(filterCakesSearchList[index]['MinTimeForDeliveryOfA3KgCake']!=null&&
    //     filterCakesSearchList[index]['MinTimeForDeliveryOfA5KgCake']!=null){
    //   prefs.setString("cake3kgminTime", filterCakesSearchList[index]['MinTimeForDeliveryOfA3KgCake'].toString());
    //   prefs.setString("cake5kgminTime", filterCakesSearchList[index]['MinTimeForDeliveryOfA5KgCake'].toString());
    // }else{
    //   prefs.setString("cake3kgminTime", 'Nf');
    //   prefs.setString("cake5kgminTime", 'Nf');
    // }
    prefs.setString("cakeminDelTime", filterCakesSearchList[index]['MinTimeForDeliveryOfDefaultCake'].toString());
    prefs.setString("cakeminbetwokgTime", filterCakesSearchList[index]['MinTimeForDeliveryOfABelow2KgCake'].toString());
    prefs.setString("cakemintwotoourTime", filterCakesSearchList[index]['MinTimeForDeliveryOfA2to4KgCake'].toString());
    prefs.setString("cakeminfortofivTime", filterCakesSearchList[index]['MinTimeForDeliveryOfA4to5KgCake'].toString());
    prefs.setString("cakeminabovfiveTime", filterCakesSearchList[index]['MinTimeForDeliveryOfAAbove5KgCake'].toString());


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
        tiersDelTimes
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

  void applyOthersFilter(String start , String end , List shape , List flavs){

   // otherProducts;
    List a = [] , b = [] , c = [] , d = [];

    setState((){
      if(start.isEmpty && end.isEmpty && shape.isEmpty && flavs.isEmpty){
        Navigator.pop(context);
      }else{

        //price
        if(start.isNotEmpty && end.isNotEmpty){

          List a1 = [];
          List b1 = [];
          List c1 = [];

          for(int i = 0 ;i<otherProducts.length;i++){

            if(otherProducts[i]['MinWeightPerKg']!=null){
              a1 = otherProducts
                  .where((element) =>
              double.parse(element['MinWeightPerKg']['PricePerKg']) >=
                  double.parse(start, (e) => 0)&&
                  double.parse(element['MinWeightPerKg']['PricePerKg']) <=
                      double.parse(end, (e) => 0))
                  .toList();
            }else if(otherProducts[i]['MinWeightPerUnit']!=null || otherProducts[i]['MinWeightPerUnit'].isNotEmpty){
              b1 = otherProducts
                  .where((element) =>
              double.parse(element['MinWeightPerUnit']['PricePerUnit']) >=
                  double.parse(start, (e) => 0)&&
                  double.parse(element['MinWeightPerUnit']['PricePerUnit']) <=
                      double.parse(end, (e) => 0))
                  .toList();
            }else if(otherProducts[i]['MinWeightPerBox']!=null || otherProducts[i]['MinWeightPerBox'].isNotEmpty){
              c1 = otherProducts
                  .where((element) =>
              double.parse(element['MinWeightPerBox']['PricePerBox']) >=
                  double.parse(start, (e) => 0)&&
                  double.parse(element['MinWeightPerBox']['PricePerBox']) <=
                      double.parse(end, (e) => 0))
                  .toList();
            }

          }

          a = a1 + b1 + c1;

        }

        //shape
        if(shape.isNotEmpty){
          for(int i =0;i<otherProducts.length;i++){
            if(otherProducts[i]['Shape']!=null){
              for(int j = 0 ; j < shape.length;j++){
                b = b + otherProducts.where((element) => element['Shape'].toString().toLowerCase().
                contains(shape[i].toString().toLowerCase())).toList();
              }
            }
          }
        }

        isFilterisOn = true;
        otherFilteredProducts = a + b + [];
        otherFilteredProducts = otherFilteredProducts.toSet().toList();
      }

    });

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
                      double.parse(element['BasicCakePrice']) >=
                          double.parse(priceRangeStart, (e) => 0)&&
                      double.parse(element['BasicCakePrice']) <=
                          double.parse(priceRangeEnd, (e) => 0))
                  .toList();

              isFilterisOn = true;
            }
          });
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Price Filter Based On Minimum Price/Kg")));
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
        // if (shapes.isNotEmpty) {
        //   setState(() {
        //     for (int i=0 ; i < eggOrEgglesList.length; i++) {
        //       if (eggOrEgglesList[i]['CustomShapeList']['Info'] != null &&
        //           eggOrEgglesList[i]['CustomShapeList']['Info'].isNotEmpty) {
        //         for (int j = 0;
        //         j < eggOrEgglesList[i]['CustomShapeList']['Info'].length;
        //         j++) {
        //           if (eggOrEgglesList[i]['CustomShapeList']['Info'][j]['Name'] != null) {
        //             for (int k = 0; k < shapes.length; k++) {
        //               if (eggOrEgglesList[i]['CustomShapeList']['Info'][j]['Name']
        //                   .toString()
        //                   .toLowerCase()
        //                   .contains(shapes[k].toString().toLowerCase())) {
        //                 setState(() {
        //                   shapeFilter1.add(eggOrEgglesList[i]);
        //                   isFilterisOn = true;
        //                 });
        //               } else {}
        //             }
        //           } else {}
        //         }
        //       } else {}
        //     }
        //   });
        //   shapeOnlyFilter = true;
        // }

        //apply basic shape

        if(shapes.isNotEmpty){
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
                shapeFilter1 = shapeFilter1.toList() + eggOrEgglesList.where((element) => element['BasicShape'].toString()
                    .toLowerCase().contains(shapes[i].toString().toLowerCase())).toList();
                // print(b[i]['BasicFlavour'].toString()+" Flav");
              }
              shapeOnlyFilter = true;
            }

            shapeOnlyFilter = true;
          });
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

      myShapesFilter.clear();
      filterShapesCheck.clear();
      filterShapes.clear();
      shapeOnlyFilter = false;

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
      }
      else {
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
      searchModeis = false;
      activeSearch = false;
      filteredListByUser = [];
      //selIndex[cakesTypes.indexWhere((element) => element=="All Cakes")] = true;
      selIndex = [];
      for(int i = 0; i<cakesTypes.length;i++){
        selIndex.add(false);
      }
      isFiltered = false;
      selIndex[cakesTypes.indexWhere((element) => element['name'].toString().toLowerCase()=="all cakes")] = true;
      currentCakeType = "All cakes";
      cakeSearchList = eggOrEgglesList;
      searchCakesText = '';
      searchControl.text = '';
      cakeCategoryCtrl.text = '';
      cakeSubCategoryCtrl.text = '';
      cakeVendorCtrl.text = '';
      selectedFilter.clear();
    });
    print(cakeSearchList.length);
    print(filterCakesSearchList.length);
  }


  Future<void> getVendorForDeliveryto(String token) async {
    activeVendorsIds.clear();
    showAlertDialog();
    activeVendorsIds.clear();
    try {
      var res = await http.get(
          Uri.parse("https://cakey-database.vercel.app/api/activevendors/list"),
          headers: {"Authorization": "$token"});

      if (res.statusCode == 200) {
        setState(() {
          List vendorsList = jsonDecode(res.body);

          List filteredByEggList = vendorsList
              .where((element) =>
          calculateDistance(
              double.parse(userLatitude),
              double.parse(userLongtitude),
              element['GoogleLocation']['Latitude'],
              element['GoogleLocation']['Longitude']) <=
              10)
              .toList();

          // filteredByEggList = vendorsList.where((element)=>element['Address']['City'].toString().toLowerCase().
          // contains(userMainLocation.toLowerCase())).toList();

          filteredByEggList = filteredByEggList.toSet().toList();

          filteredByEggList.sort((a,b)=>calculateDistance(
              double.parse(userLatitude),
              double.parse(userLongtitude),
              a['GoogleLocation']['Latitude'],
              a['GoogleLocation']['Longitude']).toStringAsFixed(1).compareTo(calculateDistance(
              double.parse(userLatitude),
              double.parse(userLongtitude),
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

    getCakeList();

  }

  Future<void> getCoordinates(String predictedAddress) async{

    var pref = await SharedPreferences.getInstance();

    try{
      if (predictedAddress.isNotEmpty) {
        List<Location> location =
        await locationFromAddress(predictedAddress);
        print(location);
        setState((){
          userCurLocation = predictedAddress;
          userLatitude = location[0].latitude.toString();
          userLongtitude = location[0].longitude.toString();
          pref.setString('userLatitute', "${userLatitude}");
          pref.setString('userLongtitude', "${userLongtitude}");
          pref.setString("userCurrentLocation", predictedAddress);
          getVendorForDeliveryto(authToken);
          // getOtherProducts();
        });
      }
      else{
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Unable to get location details..."))
        );
      }

    }catch(e){
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Unable to get location details..."))
      );
    }

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
      context.read<ContextData>().setMyVendors([]);
      context.read<ContextData>().addMyVendor(false);
      pr.remove('iamYourVendor');
      pr.remove('vendorCakeMode');
      pr.remove('naveToHome');
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    profileUrl = context.watch<ContextData>().getProfileUrl();
    notiCount = context.watch<ContextData>().getNotiCount();

    if(iamYourVendor == true){
      mySelVendors = context.watch<ContextData>().getMyVendorsList();
    }else{
      mySelVendors = [];
    }

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
            .contains("y")).toList();

        List subList = eggOrEgglesList.where((element)
        => element['CakeSubType'].contains(cakesTypes[currentIndex]["name"])
        ).toList();

        cakesByType = eggOrEgglesList.where((element)
        => element['CakeType'].contains(cakesTypes[currentIndex]["name"])
        ).toList();

        cakesByType = cakesByType + subList;

      });
    }
    else if (egglesSwitch == false) {
      setState(() {
        eggOrEgglesList = cakesList.toList();

        if(eggOrEgglesList.isNotEmpty && cakesTypes.isNotEmpty){

            List subList = eggOrEgglesList.where((element)
            => element['CakeSubType'].contains(cakesTypes[currentIndex]['name'])
            ).toList();

            cakesByType = eggOrEgglesList.where((element)
            => element['CakeType'].contains(cakesTypes[currentIndex]['name'])
            ).toList();

            cakesByType = cakesByType + subList;

        }

      });
    }

    //set others eggless
    if(currentCakeType.toLowerCase().contains("others")){
      if(egglesSwitch==true){
        otherEggProducts= otherProducts.where((element){
          if(element['EggOrEggless']==null){
            return false;
          }

          return element['EggOrEggless'].toString().toLowerCase()=="eggless";
        }).toList();
      }else{
        otherEggProducts = otherProducts;
      }
    }

    //filter and all cakes
    if(searchCakesText.isNotEmpty){
      activeSearch = true;
      List sub = otherProducts
          .where((element) => element["ProductName"]
          .toString()
          .toLowerCase()
          .contains(searchCakesText.toLowerCase()))
          .toList();

      cakeSearchList = sub + eggOrEgglesList
          .where((element) => element['CakeName']
          .toString()
          .toLowerCase()
          .contains(searchCakesText.toLowerCase()))
          .toList();
    }
    else{

      if(searchModeis==true){
        activeSearch = true;
        cakeSearchList = filteredListByUser;
      }else{
        activeSearch = false;
        if(currentCakeType.toLowerCase()=="all cakes"){
          cakeSearchList = eggOrEgglesList;
        }else{
          //filterCakesSearchList = cakesByType;
          List list = cakesByType.where((element) => element['CakeSubType'].contains(currentCakeType)).toList();
          filterCakesSearchList = list + cakesByType.where((element) => element['CakeType'].contains(currentCakeType)).toList();
        }

        //filter selected
        if(filteredListByUser.isNotEmpty){
          cakeSearchList = filteredListByUser;
          List list = filteredListByUser.where((element) => element['CakeSubType'].contains(currentCakeType)).toList();
          filterCakesSearchList = list + filteredListByUser.where((element) => element['CakeType'].contains(currentCakeType)).toList();
        }else{
          cakeSearchList = eggOrEgglesList;
          List list = cakesByType.where((element) => element['CakeSubType'].contains(currentCakeType)).toList();
          filterCakesSearchList = list + cakesByType.where((element) => element['CakeType'].contains(currentCakeType)).toList();
        }
      }

    }

    // /*2) if search and filter modes is on..*/
    // if (isFilterisOn == true || shapeOnlyFilter == true || searchModeis == true) {
    //   setState(() {
    //     cakeSearchList = filteredListByUser.toList();
    //   });
    //   if (searchCakesText.isNotEmpty) {
    //     setState(() {
    //       activeSearch = true;
    //
    //       List sub = otherProducts
    //           .where((element) => element["ProductName"]
    //           .toString()
    //           .toLowerCase()
    //           .contains(searchCakesText.toLowerCase()))
    //           .toList();
    //
    //       cakeSearchList = sub + filteredListByUser
    //           .where((element) => element['CakeName']
    //               .toString()
    //               .toLowerCase()
    //               .contains(searchCakesText.toLowerCase()))
    //           .toList();
    //     });
    //   }
    //   else {
    //     setState(() {
    //       activeSearch = false;
    //       cakeSearchList = filteredListByUser.toList();
    //     });
    //   }
    //   if (isFiltered == true && searchCakesText.isNotEmpty) {
    //     setState(() {
    //       filterCakesSearchList = cakesByType
    //           .where((element) => element['CakeName']
    //               .toString()
    //               .toLowerCase()
    //               .contains(searchCakesText.toLowerCase()))
    //           .toList();
    //     });
    //   } else {
    //     setState(() {
    //       filterCakesSearchList = cakesByType;
    //     });
    //   }
    // }
    // else {
    //   if (searchCakesText.isNotEmpty) {
    //     setState(() {
    //       activeSearch = true;
    //       List sub = otherProducts
    //           .where((element) => element["ProductName"]
    //           .toString()
    //           .toLowerCase()
    //           .contains(searchCakesText.toLowerCase()))
    //           .toList();
    //
    //       cakeSearchList = sub + eggOrEgglesList
    //           .where((element) => element['CakeName']
    //               .toString()
    //               .toLowerCase()
    //               .contains(searchCakesText.toLowerCase()))
    //           .toList();
    //     });
    //   }
    //   else {
    //     setState(() {
    //       activeSearch = false;
    //       cakeSearchList = eggOrEgglesList;
    //     });
    //
    //     /*3) Set list from search filters apply...*/
    //     if (cakeVendorCtrl.text.isNotEmpty ||
    //         cakeCategoryCtrl.text.isNotEmpty ||
    //         cakeSubCategoryCtrl.text.isNotEmpty ||
    //         selectedFilter.isNotEmpty) {
    //
    //       List sub = [];
    //       List sub2 = [];
    //
    //       setState(() {
    //         categorySearch = [];
    //         subCategorySearch = [];
    //         vendorBasedSearch = [];
    //         cakeTypeList = [];
    //         activeSearch = true;
    //
    //         if (cakeCategoryCtrl.text.isNotEmpty) {
    //           categorySearch = eggOrEgglesList
    //               .where((element) => element['CakeName']
    //                   .toString()
    //                   .toLowerCase()
    //                   .contains(cakeCategoryCtrl.text.toLowerCase()))
    //               .toList();
    //
    //           sub = otherProducts
    //               .where((element) => element["ProductName"]
    //               .toString()
    //               .toLowerCase()
    //               .contains(cakeCategoryCtrl.text.toLowerCase()))
    //               .toList();
    //
    //         }
    //
    //
    //         if (cakeSubCategoryCtrl.text.isNotEmpty) {
    //           subCategorySearch = eggOrEgglesList
    //               .where((element) => element['CakeSubType']
    //                   .contains(cakeSubCategoryCtrl.text))
    //               .toList();
    //         }
    //
    //         if (cakeVendorCtrl.text.isNotEmpty) {
    //           vendorBasedSearch = eggOrEgglesList
    //               .where((element) => element['VendorName']
    //                   .toString()
    //                   .toLowerCase()
    //                   .contains(cakeVendorCtrl.text.toLowerCase()))
    //               .toList();
    //
    //           sub2 = otherProducts
    //           .where((element) => element["VendorName"]
    //           .toString()
    //           .toLowerCase()
    //           .contains(cakeVendorCtrl.text.toLowerCase()))
    //           .toList();
    //
    //         }
    //
    //         if (selectedFilter.isNotEmpty) {
    //           for (int i = 0; i < eggOrEgglesList.length; i++) {
    //             if (eggOrEgglesList[i]['CakeType'].isNotEmpty) {
    //               for (int j = 0; j < selectedFilter.length; j++) {
    //                 if (eggOrEgglesList[i]['CakeType']
    //                     .contains(selectedFilter[j])) {
    //                   cakeTypeList.add(eggOrEgglesList[i]);
    //                 }
    //               }
    //             }
    //           }
    //         }
    //
    //         // cakeSearchList.clear();
    //
    //         cakeSearchList = sub + sub2 + categorySearch.toList() +
    //             subCategorySearch.toList() +
    //             vendorBasedSearch.toList() +
    //             cakeTypeList.toList();
    //         cakeSearchList = cakeSearchList.toSet().toList();
    //       });
    //     }
    //     else {
    //       cakeSearchList = eggOrEgglesList;
    //     }
    //   }
    // }
    //
    // if(isFiltered == true && isFilterisOn == true || shapeOnlyFilter == true ){
    //   List list = filteredListByUser.where((element) => element['CakeSubType'].contains(currentCakeType)).toList();
    //   filterCakesSearchList =
    //       list + filteredListByUser.where((element) =>
    //           element['CakeType'].contains(currentCakeType)).toList();
    //   // if(|| searchModeis == true){
    //   //
    //   // }else{
    //   //   List list = cakesByType.where((element) => element['CakeSubType'].contains(currentCakeType)).toList();
    //   //   filterCakesSearchList = list + cakesByType.where((element) => element['CakeType'].contains(currentCakeType)).toList();
    //   // }
    // }else{
    //   filterCakesSearchList = cakesByType.toList();
    // }

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
            if (iamYourVendor == true) {
              Navigator.pop(context);
              return false;
            }else{
              Navigator.pop(context);
              //Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>HomeScreen()));
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
                      CustomAppBars().CustomAppBar(context, "", notiCount, profileUrl)
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
                          setState((){
                            // selectedFilter = ["Theme Cakes","Theme cakes","Theme Cake","Theme cake"];
                            // selectedFilter = selectedFilter.toSet().toList();
                            // cakeCategoryCtrl.text = "Theme Cake";

                            searchByGivenFilter("Theme Cake", "", "",
                                ["Theme Cakes","Theme cakes","Theme Cake","Theme cake"]);
                          });
                          // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => CustomiseCake()));
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
                                    color: Colors.red[50]),
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
                                            fontSize: 14),
                                      ),
                                      TextSpan(
                                        text: 'THEME CAKE ? ',
                                        style: TextStyle(
                                            color: lightPink,
                                            fontWeight: FontWeight.w900,
                                            fontSize: 14),
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
                                Expanded(
                                  child: Container(
                                    width: 150,
                                    child: GestureDetector(
                                      onTap: () async{
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
                                        '$userCurLocation',
                                        maxLines: 1 ,
                                        style: TextStyle(
                                            fontFamily: poppins,
                                            fontSize: 13.5,
                                            color: darkBlue,
                                            fontWeight: FontWeight.bold
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 5,),
                                GestureDetector(
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
                                      // region: "in",
                                      // types: [
                                      //   "accounting"
                                      //   'airport'
                                      //   'amusement_park'
                                      //   'aquarium'
                                      //   'art_gallery'
                                      //   'atm'
                                      //   'bakery'
                                      //   'bank'
                                      //   'bar'
                                      //   'beauty_salon'
                                      //   'bicycle_store'
                                      //   'book_store'
                                      //   'bowling_alley'
                                      //   'bus_station'
                                      //   'cafe'
                                      //   'campground'
                                      //   'car_dealer'
                                      //   'car_rental'
                                      //   'car_repair'
                                      //   'car_wash'
                                      //   'casino'
                                      //   'cemetery'
                                      //   'church'
                                      //   'city_hall'
                                      //   'clothing_store'
                                      //   'convenience_store'
                                      //   'courthouse'
                                      //   'dentist'
                                      //   'department_store'
                                      //   'doctor'
                                      //   'drugstore'
                                      //   'electrician'
                                      //   'electronics_store'
                                      //   'embassy'
                                      //   'fire_station'
                                      //   'florist'
                                      //   'funeral_home'
                                      //   'furniture_store'
                                      //   'gas_station'
                                      //   'gym'
                                      //   'hair_care'
                                      //   'hardware_store'
                                      //   'hindu_temple'
                                      //   'home_goods_store'
                                      //   'hospital'
                                      //   'insurance_agency'
                                      //   'jewelry_store'
                                      //   'laundry'
                                      //   'lawyer'
                                      //   'library'
                                      //   'light_rail_station'
                                      //   'liquor_store'
                                      //   'local_government_office'
                                      //   'locksmith'
                                      //   'lodging'
                                      //   'meal_delivery'
                                      //   'meal_takeaway'
                                      //   'mosque'
                                      //   'movie_rental'
                                      //   'movie_theater'
                                      //   'moving_company'
                                      //   'museum'
                                      //   'night_club'
                                      //   'painter'
                                      //   'park'
                                      //   'parking'
                                      //   'pet_store'
                                      //   'pharmacy'
                                      //   'physiotherapist'
                                      //   'plumber'
                                      //   'police'
                                      //   'post_office'
                                      //   'primary_school'
                                      //   'real_estate_agency'
                                      //   'restaurant'
                                      //   'roofing_contractor'
                                      //   'rv_park'
                                      //   'school'
                                      //   'secondary_school'
                                      //   'shoe_store'
                                      //   'shopping_mall'
                                      //   'spa'
                                      //   'stadium'
                                      //   'storage'
                                      //   'store'
                                      //   'subway_station'
                                      //   'supermarket'
                                      //   'synagogue'
                                      //   'taxi_stand'
                                      //   'tourist_attraction'
                                      //   'train_station'
                                      //   'transit_station'
                                      //   'travel_agency'
                                      //   'university'
                                      //   'veterinary_care'
                                      //   'zoo'
                                      // ],
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
                                SizedBox(width: 10,),
                              ],
                            ),
                          ),
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
                          ) :
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
                                mySelVendors.isNotEmpty?
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
                                              PhoneDialog().showPhoneDialog(context,
                                                  mySelVendors[0]['PhoneNumber1'].toString(),
                                                  mySelVendors[0]['PhoneNumber2'].toString());
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
                                              // PhoneDialog().showPhoneDialog(context,mySelVendors[0]['PhoneNumber1'].toString(),
                                              //     mySelVendors[0]['PhoneNumber2'].toString(), true);
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
                                ):Container(),
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
                                          fontFamily: poppins
                                      ),
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
                                                if (cakesTypes[index]['name'].toString().toLowerCase().contains("all cakes")) {
                                                  isFiltered = false;
                                                  selIndex[i] = true;
                                                  currentCakeType = "All cakes";
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
                                                  currentCakeType = cakesTypes[index]['name'].toString();
                                                  List subList = eggOrEgglesList.where((element)
                                                  => element['CakeSubType'].contains(currentCakeType)
                                                  ).toList();

                                                  cakesByType = eggOrEgglesList.where((element)
                                                   => element['CakeType'].contains(currentCakeType)
                                                  ).toList();

                                                  cakesByType = cakesByType + subList;

                                                  cakesByType = cakesByType.toSet().toList();

                                                  print(currentCakeType);

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
                                                height: 35,
                                                width: 35,
                                                decoration: BoxDecoration(
                                                  image: DecorationImage(
                                                    image: AssetImage("assets/images/cakefour.jpg")
                                                  )
                                                ),
                                              ):
                                              index==1?Container(
                                                height: 35,
                                                width: 35,
                                                decoration: BoxDecoration(
                                                    image: DecorationImage(
                                                        image: AssetImage("assets/images/hamper.png")
                                                    )
                                                ),
                                              ):Container(
                                                height: 35,
                                                width: 35,
                                                decoration: BoxDecoration(
                                                    image: cakesTypes[index]['image']!=null?
                                                    DecorationImage(
                                                        image: NetworkImage(cakesTypes[index]['image']),
                                                        fit: BoxFit.cover
                                                    ):DecorationImage(
                                                        image: AssetImage("assets/images/hamper.png")
                                                    ),
                                                  shape: BoxShape.circle
                                                ),
                                              ),
                                              Text(
                                                " ${cakesTypes[index]['name']}",
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
                            child: currentCakeType!="Others"?
                            Column(
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
                                                        " Results",
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
                                                      Container(
                                                        height: 100,
                                                        width: 100,
                                                        decoration: BoxDecoration(
                                                            color: Colors.white,
                                                            shape: BoxShape.circle,
                                                            border: Border.all(
                                                                width: 1,
                                                                color: Colors.grey[300]!
                                                            ),
                                                            image: DecorationImage(
                                                                image: NetworkImage(
                                                                  filterCakesSearchList[index]['MainCakeImage'].toString(),
                                                                ),fit: BoxFit.fill
                                                            )
                                                        ),
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
                                                              '₹ ${
                                                                  (double.parse(filterCakesSearchList[index]['BasicCakePrice'].toString())*
                                                                      changeWeight(filterCakesSearchList[index]['MinWeight'].toString())).toStringAsFixed(1)
                                                              }',
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
                                                    Container(
                                                      height: 100,
                                                      width: 100,
                                                      decoration: BoxDecoration(
                                                          color: Colors.white,
                                                          shape: BoxShape.circle,
                                                          border: Border.all(
                                                            width: 1,
                                                            color: Colors.grey[300]!
                                                          ),
                                                          image: DecorationImage(
                                                              image: NetworkImage(
                                                                filterCakesSearchList[index]['MainCakeImage'].toString(),
                                                              ),fit: BoxFit.fill
                                                          )
                                                      ),
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
                                                            '₹ ${
                                                                (double.parse(filterCakesSearchList[index]['BasicCakePrice'].toString())*
                                                                    changeWeight(filterCakesSearchList[index]['MinWeight'].toString())).toStringAsFixed(1)
                                                            }',
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
                                                              filterCakesSearchList[index]['MinWeightList']==null||filterCakesSearchList[index]['MinWeightList'].isEmpty
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
                            ):Container(),
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
                                              sendDetailsToScreen(cakeSearchList[index]['_id'].toString());
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
                                                        " Results",
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
                                                      Container(
                                                        height: 100,
                                                        width: 100,
                                                        decoration: BoxDecoration(
                                                          color: Colors.white,
                                                          shape: BoxShape.circle,
                                                            border: Border.all(
                                                                width: 1,
                                                                color: Colors.grey[300]!
                                                            ),
                                                          image: DecorationImage(
                                                            image: NetworkImage(
                                                               cakeSearchList[index]['MainCakeImage'].toString(),
                                                            ),fit: BoxFit.fill
                                                          )
                                                        ),
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
                                                              '₹ ${
                                                              (double.parse(cakeSearchList[index]['BasicCakePrice'].toString())*
                                                               changeWeight(cakeSearchList[index]['MinWeight'].toString())).toStringAsFixed(1)
                                                              }',
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
                                              sendDetailsToScreen(cakeSearchList[index]['_id'].toString());
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
                                                      Container(
                                                        height: 100,
                                                        width: 100,
                                                        decoration: BoxDecoration(
                                                            color: Colors.white,
                                                            border: Border.all(
                                                                width: 1,
                                                                color: Colors.grey[300]!
                                                            ),
                                                            shape: BoxShape.circle,
                                                            image: DecorationImage(
                                                                image: NetworkImage(
                                                                  cakeSearchList[index]['MainCakeImage'].toString(),
                                                                ),fit: BoxFit.fill
                                                            )
                                                        ),
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
                                                              '₹ ${
                                                                  (double.parse(cakeSearchList[index]['BasicCakePrice'].toString())*
                                                                   changeWeight(cakeSearchList[index]['MinWeight'].toString())).toStringAsFixed(1)
                                                              }',
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
                                      "No data found!",
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

                                      var deliverCharge = double.parse("${(( adminDeliveryCharge / adminDeliveryChargeKm) *
                                          (calculateDistance(double.parse(userLatitude), double.parse(userLongtitude), cakeSearchList[i]['GoogleLocation']['Latitude'],
                                              cakeSearchList[i]['GoogleLocation']['Longitude'])))}").toStringAsFixed(1);
                                      var betweenKm = (calculateDistance(double.parse(userLatitude), double.parse(userLongtitude) ,
                                          cakeSearchList[i]['GoogleLocation']['Latitude'],
                                          cakeSearchList[i]['GoogleLocation']['Longitude'])).toStringAsFixed(1);

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
                                        child:
                                        cakeSearchList[i]['CakeName']!=null?
                                        Column(
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
                                                    color: lightGrey),
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
                                                              sendDetailsToScreen(cakeSearchList[i]['_id'].toString());
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
                                                sendDetailsToScreen(cakeSearchList[i]['_id'].toString());
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
                                                            child:Text('DELIVERY CHARGE Rs.$deliverCharge',
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
                                                    color: Colors.grey[300]),
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
                                                                      height: 0.5,
                                                                      color:
                                                                      Color(0xffdddddd)),
                                                                  SizedBox(height: 5),
                                                                  Container(
                                                                    // width:120,
                                                                    child: Text(
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
                                    }),
                          ),
                    //other products....
                    currentCakeType=="Others" && activeSearch!=true?
                    Container(
                      child: Column(
                        children: [
                          StaggeredGridView.countBuilder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.all(8.0),
                            crossAxisCount: 2,
                            mainAxisSpacing: 5,
                            crossAxisSpacing: 7,
                            itemCount: otherEggProducts.length,
                            itemBuilder: (BuildContext context, int index) {

                              var price , weight;
                              if(otherEggProducts[index]['Type'].toString().toLowerCase()=="kg"){
                                price = otherEggProducts[index]['MinWeightPerKg']['PricePerKg'];
                                weight = otherEggProducts[index]['MinWeightPerKg']['Weight'].toString();
                              }else if(otherEggProducts[index]['Type'].toString().toLowerCase()=="unit"){
                                price = otherEggProducts[index]['MinWeightPerUnit'][0]['PricePerUnit'];
                                weight = otherEggProducts[index]['MinWeightPerUnit'][0]['Weight'];
                              }else{
                                price = otherEggProducts[index]['MinWeightPerBox'][0]['PricePerBox'];
                                weight = otherEggProducts[index]['MinWeightPerBox'][0]['Piece'];
                              }

                              var fixPrice = (double.parse(price.toString())
                                //  *changeWeight(weight.toString())
                              ).toStringAsFixed(1);

                              //otherEggProducts[index]['Type'].toString().toLowerCase()=="kg"?
                              //'${otherEggProducts[index]['MinWeightPerKg']['Weight']}':
                              //otherEggProducts[index]['Type'].toString().toLowerCase()=="unit"?
                              //"${otherEggProducts[index]['MinWeightPerUnit'][0]['Weight']}":
                              //'${otherEggProducts[index]['MinWeightPerBox'][0]['Piece']} Pcs'

                              return index == 0 ?
                              GestureDetector(
                                onTap: () {
                                  sendOthers(otherEggProducts[index]["_id"].toString());
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
                                        otherEggProducts.length
                                            .toString() +
                                            " Results",
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
                                            backgroundImage: otherEggProducts[index]['ProductImage'] == null ||
                                                otherEggProducts[index]['ProductImage'].isEmpty
                                                ? NetworkImage(
                                                "https://w0.peakpx.com/wallpaper/863/651/HD-wallpaper-red-cake-pastries-desserts-cakes-strawberry-cake-berry-cake.jpg")
                                                : NetworkImage(
                                                otherEggProducts[index]['ProductImage'][0].toString()),
                                          ),
                                          SizedBox(
                                            height: 8,
                                          ),
                                          Text(
                                              "${otherEggProducts[index]['ProductName'][0].toString().toUpperCase() +
                                                  otherEggProducts[index]['ProductName'].toString().substring(1).toLowerCase()}",
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
                                                  '₹ $fixPrice',
                                                  style: TextStyle(
                                                      color:
                                                      lightPink,
                                                      fontWeight:
                                                      FontWeight
                                                          .bold,
                                                      fontSize: 14,
                                                      fontFamily:
                                                      "Poppins")
                                              ),
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
                                                    otherEggProducts[index]['Type'].toString().toLowerCase()=="kg"?
                                                    '${otherEggProducts[index]['MinWeightPerKg']['Weight']}':
                                                    otherEggProducts[index]['Type'].toString().toLowerCase()=="unit"?
                                                    "${otherEggProducts[index]['MinWeightPerUnit'][0]['Weight']}":
                                                    '${otherEggProducts[index]['MinWeightPerBox'][0]['Piece']} Pcs',
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
                              ):
                              GestureDetector(
                                onTap: () {
                                  sendOthers(otherEggProducts[index]['_id'].toString());
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
                                            backgroundImage: otherEggProducts[index]['ProductImage'] == null ||
                                                otherEggProducts[index]['ProductImage'].isEmpty
                                                ? NetworkImage(
                                                "https://w0.peakpx.com/wallpaper/863/651/HD-wallpaper-red-cake-pastries-desserts-cakes-strawberry-cake-berry-cake.jpg")
                                                : NetworkImage(
                                                otherEggProducts[index]['ProductImage'][0].toString()),
                                          ),
                                          SizedBox(
                                            height: 8,
                                          ),
                                          Text(
                                              "${otherEggProducts[index]['ProductName'][0].toString().toUpperCase() +
                                                  otherEggProducts[index]['ProductName'].toString().substring(1).toLowerCase()}",
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
                                                  '₹ $fixPrice',
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
                                                    otherEggProducts[index]['Type'].toString().toLowerCase()=="kg"?
                                                    '${otherEggProducts[index]['MinWeightPerKg']['Weight']}':
                                                    otherEggProducts[index]['Type'].toString().toLowerCase()=="unit"?
                                                    "${otherEggProducts[index]['MinWeightPerUnit'][0]['Weight']}":
                                                    '${otherEggProducts[index]['MinWeightPerBox'][0]['Piece']} Pcs',
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
                    ):
                    Container(),

                    SizedBox(height: 10,)

                  ],
                ),
              ),
            ),
          ),
      ),
    );
  }
}

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

  return converetedWeight;
}
