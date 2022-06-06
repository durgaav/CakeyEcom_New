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
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../ContextData.dart';
import 'package:shimmer/shimmer.dart';
import 'package:http/http.dart' as http;
import 'dart:math';

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

  //booleans
  bool egglesSwitch = false;
  bool _show = true;
  bool isNetworkError = false;
  bool isFiltered = false;
  bool isFilterisOn = false ;
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
  List<bool> shapesCheck =[];
  List fixedFilterShapes = [];
  //Fil toping
  List<bool> topingCheck = [];
  List fixedFilterTopping = [];
  //Filter caketype
  List filterTypeList=["Birthday","Wedding","Theme Cake","Normal Cake"];
  List selectedFilter=[];
  List cakeTypeList =[];

  //Shapes showing...
  List<bool> filterShapesCheck = [];
  List filterShapes = [];
  List shapesForFilter = [];
  List shapesOthersForFilter = ["Star Shape" , "House Shape" , "Car Shape"];
  List<bool> otherShapeCheck = [];
  List myShapesFilter = [];

  List mySelVendors =[];
  bool activeSearch = false;
  List<int> rangeValuesList = [];

  //for search filter
  List categorySearch = [];
  List subCategorySearch = [];
  List vendorBasedSearch = [];

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

  //filter bottom.....
  void showFilterBottom(){
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(topRight: Radius.circular(20),topLeft: Radius.circular(20)),
        ),
        isScrollControlled: true,
        context: context,
        builder: (context){
          return StatefulBuilder(
              builder: (BuildContext context,
                  void Function(void Function()) setState){
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
                          SizedBox(height: 8,),
                          //Title text...
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('FILTER',style: TextStyle(color: darkBlue,fontSize: 18,
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
                          SizedBox(height: 8,),
                          Container(
                            height: 1.0,
                            color: Colors.black26,
                          ),
                          SizedBox(height: 8,),
                          Container(
                            height: 300,
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  //Price Slider...
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text('Price Range',style: TextStyle(color: darkBlue,fontSize: 18,
                                        fontWeight: FontWeight.bold,fontFamily: "Poppins"),),
                                  ),
                                  SizedBox(height: 4,),
                                  //Price range slider .....
                                  RangeSlider(
                                      values:rangeValues,
                                      max: rangeValuesList.reduce(max).toDouble(),
                                      min: 0,
                                      divisions:(rangeValuesList.reduce(max)/10).toInt(),
                                      activeColor: lightPink,
                                      inactiveColor: Colors.grey,
                                      labels: RangeLabels(
                                        rangeValues.start.round().toString(),
                                        rangeValues.end.round().toString(),
                                      ),
                                      onChanged: (RangeValues values){
                                        setState((){
                                          rangeValues = values;
                                          priceRangeStart = rangeValues.start.toString();
                                          priceRangeEnd = rangeValues.end.toString();
                                        });

                                      }
                                  ),
                                  SizedBox(height: 4,),
                                  Container(
                                      padding: EdgeInsets.all(5),
                                      child:Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children:[
                                            Text('Start : Rs.${rangeValues.start.toInt()}', style: TextStyle(
                                              fontFamily: "Poppins" ,
                                              fontSize: 13 ,
                                              color: Colors.green,
                                            ),),
                                            Text('End : Rs.${rangeValues.end.toInt()}', style: TextStyle(
                                              fontFamily: "Poppins" ,
                                              fontSize: 13 ,color: Colors.red,

                                            ),),
                                          ]
                                      )
                                  ),
                                  SizedBox(height: 4,),
                                  Container(
                                    height: 1.0,
                                    color: Colors.black26,
                                  ),
                                  ExpansionTile(
                                    title: Text('Flavours',style: TextStyle(fontFamily: "Poppins",
                                        fontWeight: FontWeight.bold),),
                                    subtitle: Text(fixedFilterFlav.isNotEmpty?'${fixedFilterFlav[0]}':'Default',style: TextStyle(fontFamily: "Poppins",),),
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
                                      ListView.builder(
                                          physics: NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          itemCount: filterCakesFlavList.length,
                                          itemBuilder: (context , index){
                                            flavsCheck.add(false);
                                            return InkWell(
                                              splashColor: Colors.red[200],
                                              onTap:(){
                                                setState((){
                                                  if(flavsCheck[index]==false){
                                                    flavsCheck[index]=true;

                                                    if(fixedFilterFlav.contains(filterCakesFlavList[index])){

                                                    }else{
                                                      fixedFilterFlav.add(filterCakesFlavList[index]);
                                                    }
                                                  }else{
                                                    fixedFilterFlav.remove(filterCakesFlavList[index]);
                                                    flavsCheck[index]=false;
                                                  }
                                                });
                                              },
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  SizedBox(height: 5,),
                                                  Row(
                                                    children: [
                                                      Checkbox(
                                                        shape: CircleBorder(),
                                                        activeColor: Colors.white,
                                                        fillColor: MaterialStateProperty.resolveWith((states) => Colors.green),
                                                        value: flavsCheck[index],
                                                        onChanged: (bool? check){
                                                          setState((){
                                                            if(flavsCheck[index]==false){
                                                              flavsCheck[index]=true;
                                                              if(fixedFilterFlav.contains(flavsCheck[index])){

                                                              }else{
                                                                fixedFilterFlav.add(flavsCheck[index]);
                                                              }
                                                            }else{
                                                              fixedFilterFlav.remove(flavsCheck[index]);
                                                              flavsCheck[index]=false;
                                                            }
                                                          });
                                                        },
                                                      ),
                                                      Text(filterCakesFlavList[index][0].toUpperCase()+
                                                          filterCakesFlavList[index].toString().substring(1).toLowerCase(),style: TextStyle(
                                                          color: darkBlue , fontFamily: "Poppins",fontSize: 12,fontWeight: FontWeight.bold
                                                      ),),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            );
                                          }
                                      )
                                    ],
                                  ),
                                  Container(
                                    height: 1.0,
                                    color: Colors.black26,
                                  ),
                                  ExpansionTile(
                                    title: Text('Shapes',style: TextStyle(fontFamily: "Poppins",
                                        fontWeight: FontWeight.bold),),
                                    subtitle: Text(fixedFilterShapes.isNotEmpty?'${fixedFilterShapes[0]}':'Default',style: TextStyle(fontFamily: "Poppins",),),
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
                                      ListView.builder(
                                          physics: NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          itemCount: shapesForFilter.length,
                                          itemBuilder: (context , index){
                                            shapesCheck.add(false);
                                            return InkWell(
                                              splashColor: Colors.red[200],
                                              onTap:(){
                                                setState((){
                                                  if(shapesCheck[index]==false){
                                                    shapesCheck[index]=true;

                                                    if(fixedFilterShapes.contains(shapesForFilter[index])){

                                                    }else{
                                                      fixedFilterShapes.add(shapesForFilter[index]);
                                                    }
                                                  }else{
                                                    fixedFilterShapes.remove(shapesForFilter[index]);
                                                    shapesCheck[index]=false;
                                                  }
                                                });
                                              },
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  SizedBox(height: 5,),
                                                  Wrap(
                                                    crossAxisAlignment: WrapCrossAlignment.center,
                                                    runSpacing: 5,
                                                    children: [
                                                      Checkbox(
                                                        shape: CircleBorder(),
                                                        activeColor: Colors.white,
                                                        fillColor: MaterialStateProperty.resolveWith((states) => Colors.green),
                                                        value: shapesCheck[index],
                                                        onChanged: (bool? check){
                                                          setState((){
                                                            if(shapesCheck[index]==false){
                                                              shapesCheck[index]=true;

                                                              if(fixedFilterShapes.contains(shapesForFilter[index])){

                                                              }else{
                                                                fixedFilterShapes.add(shapesForFilter[index]);
                                                              }
                                                            }else{
                                                              fixedFilterShapes.remove(shapesForFilter[index]);
                                                              shapesCheck[index]=false;
                                                            }
                                                          });
                                                        },
                                                      ),
                                                      Text(shapesForFilter[index].toString()[0].toUpperCase()+
                                                          shapesForFilter[index].toString().substring(1).toLowerCase(),style: TextStyle(
                                                          color: darkBlue , fontFamily: "Poppins",fontSize: 15
                                                      ),),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            );
                                          }
                                      ),
                                    ],
                                  ),
                                  Container(
                                    height: 1.0,
                                    color: Colors.black26,
                                  ),

                                  SizedBox(height: 10,),
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
                                  onPressed: (){
                                    //Going to Aply filters....
                                    applyFilters(priceRangeStart, priceRangeEnd, fixedFilterFlav, fixedFilterShapes, fixedFilterTopping);
                                  },
                                  child: Text("FILTER",style: TextStyle(
                                      color: Colors.white,fontWeight: FontWeight.bold,fontFamily: "Poppins"
                                  ),),
                                ),
                              ),
                              TextButton(
                                onPressed: (){
                                  //clearing all filters
                                  clearAllFilters();
                                },
                                child:  Text("CLEAR",style: TextStyle(
                                    color: lightPink,fontWeight: FontWeight.bold,fontFamily: "Poppins",
                                    decoration: TextDecoration.underline
                                ),),
                              )
                            ],
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

  //Search filter bottom
  void showSearchFilterBottom(){
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
                                onTap: () =>
                                    setState(() {
                                      clearTheSearch();
                                    }),
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
                              onChanged: (String text){
                                // searchCakeCate = cakeCategoryCtrl.text;
                                // searchCakeSubType = cakeSubCategoryCtrl.text;
                                // searchCakeVendor = cakeVendorCtrl.text;
                                // searchCakeLocation = cakeLocationCtrl.text;
                                setState((){
                                  searchCakeCate = text;
                                });
                              },
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
                              onChanged: (String text){
                                // searchCakeCate = cakeCategoryCtrl.text;
                                // searchCakeSubType = cakeSubCategoryCtrl.text;
                                // searchCakeVendor = cakeVendorCtrl.text;
                                // searchCakeLocation = cakeLocationCtrl.text;
                                setState((){
                                  searchCakeSubType = text;
                                });
                              },
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
                              onChanged: (String text){
                                // searchCakeCate = cakeCategoryCtrl.text;
                                // searchCakeSubType = cakeSubCategoryCtrl.text;
                                // searchCakeVendor = cakeVendorCtrl.text;
                                // searchCakeLocation = cakeLocationCtrl.text;
                                setState((){
                                  searchCakeVendor = text;
                                });
                              },
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
                          // Container(
                          //   height: 45,
                          //   child: TextField(
                          //     onChanged: (String text){
                          //       // searchCakeCate = cakeCategoryCtrl.text;
                          //       // searchCakeSubType = cakeSubCategoryCtrl.text;
                          //       // searchCakeVendor = cakeVendorCtrl.text;
                          //       // searchCakeLocation = cakeLocationCtrl.text;
                          //       setState((){
                          //         searchCakeLocation = text;
                          //       });
                          //     },
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
                          SizedBox(
                            height: 5,
                          ),
                          //kilo meter radius buttons.........
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
                          // SizedBox(
                          //   height: 10,
                          // ),
                          //
                          // //Divider
                          // Container(
                          //   height: 1.0,
                          //   color: Colors.black26,
                          // ),
                          //
                          // SizedBox(height: 5,),
                          //
                          //
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
                                  setState((){
                                    Navigator.pop(context);
                                    searchByGivenFilter(
                                        cakeCategoryCtrl.text,
                                        cakeSubCategoryCtrl.text,
                                        cakeVendorCtrl.text,
                                        selectedFilter
                                    );
                                  });

                                },
                                child: Text("SEARCH",style: TextStyle(
                                    color: Colors.white,fontWeight: FontWeight.bold,fontFamily: "Poppins"
                                ),),
                              ),
                            ),
                          ),

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

  //Show shapes bottom sheet
  void showShapesSheet(){
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25)
        ),
        context: context,
        builder: (context){
          return StatefulBuilder(
            builder: (BuildContext context, void Function(void Function()) setState) {
              return Container(
                padding: EdgeInsets.all(10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 8,),
                    //Title text...
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('SHAPES',style: TextStyle(color: darkBlue,fontSize: 18,
                            fontWeight: FontWeight.bold,fontFamily: "Poppins"),),
                        GestureDetector(
                          onTap: (){
                            Navigator.pop(context);

                          },
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
                    SizedBox(height: 8,),
                    Container(
                      height: 1.0,
                      color: Colors.black26,
                    ),
                    Container(
                      height: 300,
                      child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListView.builder(
                                  physics: NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: shapesForFilter.length,
                                  itemBuilder: (context , index){
                                    filterShapesCheck.add(false);
                                    return InkWell(
                                      splashColor: Colors.red[200],
                                      onTap:(){
                                        setState((){
                                          if(filterShapesCheck[index]==false){
                                            filterShapesCheck[index]=true;

                                            if(filterShapes.contains(shapesForFilter[index])){

                                            }else{
                                              filterShapes.add(shapesForFilter[index]);
                                            }
                                          }else{
                                            filterShapes.remove(shapesForFilter[index]);
                                            filterShapesCheck[index]=false;
                                          }
                                        });
                                      },
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(height: 5,),
                                          Wrap(
                                            crossAxisAlignment: WrapCrossAlignment.center,
                                            runSpacing: 5,
                                            children: [
                                              Checkbox(
                                                shape: CircleBorder(),
                                                activeColor: Colors.white,
                                                fillColor: MaterialStateProperty.resolveWith((states) => Colors.green),
                                                value: filterShapesCheck[index],
                                                onChanged: (bool? check){
                                                  setState((){
                                                    if(filterShapesCheck[index]==false){
                                                      filterShapesCheck[index]=true;

                                                      if(filterShapes.contains(shapesForFilter[index])){

                                                      }else{
                                                        filterShapes.add(shapesForFilter[index]);
                                                      }
                                                    }else{
                                                      filterShapes.remove(shapesForFilter[index]);
                                                      filterShapesCheck[index]=false;
                                                    }
                                                  });
                                                },
                                              ),
                                              Text(shapesForFilter[index].toString()[0].toUpperCase()+
                                                  shapesForFilter[index].toString().substring(1).toLowerCase(),style: TextStyle(
                                                  color: darkBlue , fontFamily: "Poppins",fontSize: 15
                                              ),),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                              ),
                              SizedBox(height:6),
                              ExpansionTile(
                                title: Text('OTHERS',style: TextStyle(
                                    color: darkBlue , fontFamily: "Poppins",fontSize: 15,fontWeight: FontWeight.bold
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
                                  ListView.builder(
                                      physics: NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount: shapesOthersForFilter.length,
                                      itemBuilder: (context , index){
                                        return InkWell(
                                          splashColor: Colors.red[200],
                                          onTap:(){
                                            setState((){
                                              if(otherShapeCheck[index]==false){
                                                otherShapeCheck[index]=true;

                                                if(filterShapes.contains(shapesOthersForFilter[index])){

                                                }else{
                                                  filterShapes.add(shapesOthersForFilter[index]);
                                                }
                                              }else{
                                                filterShapes.remove(shapesOthersForFilter[index]);
                                                otherShapeCheck[index]=false;
                                              }
                                            });
                                          },
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(height: 5,),
                                              Wrap(
                                                crossAxisAlignment: WrapCrossAlignment.center,
                                                runSpacing: 5,
                                                children: [
                                                  Checkbox(
                                                    shape: CircleBorder(),
                                                    activeColor: Colors.white,
                                                    fillColor: MaterialStateProperty.resolveWith((states) => Colors.green),
                                                    value: otherShapeCheck[index],
                                                    onChanged: (bool? check){
                                                      setState((){
                                                        if(otherShapeCheck[index]==false){
                                                          otherShapeCheck[index]=true;

                                                          if(filterShapes.contains(shapesOthersForFilter[index])){

                                                          }else{
                                                            filterShapes.add(shapesOthersForFilter[index]);
                                                          }
                                                        }else{
                                                          filterShapes.remove(shapesOthersForFilter[index]);
                                                          otherShapeCheck[index]=false;
                                                        }
                                                      });
                                                    },
                                                  ),
                                                  Text(shapesOthersForFilter[index].toString(),style: TextStyle(
                                                      color: darkBlue , fontFamily: "Poppins",fontSize: 15
                                                  ),),
                                                ],
                                              ),
                                            ],
                                          ),
                                        );
                                      }
                                  ),
                                ],
                              )
                            ],
                          )
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
                            onPressed: (){
                              //Going to Aply filters....
                              setState((){applyFilterByShape(filterShapes);});
                            },
                            child: Text("FILTER",style: TextStyle(
                                color: Colors.white,fontWeight: FontWeight.bold,fontFamily: "Poppins"
                            ),),
                          ),
                        ),
                        TextButton(
                          onPressed: (){
                            //clearing all filters
                            clearShapesFilter();
                          },
                          child:  Text("CLEAR",style: TextStyle(
                              color: lightPink,fontWeight: FontWeight.bold,fontFamily: "Poppins",
                              decoration: TextDecoration.underline
                          ),),
                        )
                      ],
                    )

                  ],
                ),
              );
            },
          );
        }
    );
  }

  //endregion

  //region Functions

  //search by filters
  void searchByGivenFilter(String category, String subCategory , String vendorName, List filterCType){

    List a=[] , b =[], c=[];
    cakeTypeList=[];

    searchControl.text= '$searchCakeCate $searchCakeSubType $searchCakeVendor ${selectedFilter.toString().replaceAll("[", "").replaceAll("]", "")}';

    setState((){

      if(category.isNotEmpty){
        a = eggOrEgglesList.where((element) => element['Category'].toString().toLowerCase()
            .contains(category.toLowerCase())).toList();
        activeSearch = true;
      }

      if(subCategory.isNotEmpty){
        b = eggOrEgglesList.where((element) => element['SubCategory'].toString().toLowerCase()
            .contains(subCategory.toLowerCase())).toList();
        activeSearch = true;
      }

      if(vendorName.isNotEmpty){

        setState((){
          c = eggOrEgglesList.where((element) => element['VendorName'].toString().toLowerCase()
              .contains(vendorName.toLowerCase())).toList();
          activeSearch = true;
        });

      }
      if(filterCType.isNotEmpty){

        for(int i=0;i<cakeSearchList.length;i++){

          if(cakeSearchList[i]['TypeOfCake'].isNotEmpty){
            for(int j = 0 ; j<filterCType.length;j++){

              if(cakeSearchList[i]['TypeOfCake'].contains(filterCType[j])){
                cakeTypeList.add(cakeSearchList[i]);

              }
            }
          }
        }

      }

      cakeSearchList = a + b+ c + cakeTypeList.toList();
      cakeSearchList = cakeSearchList.toSet().toList();
    });
  }

  //load prefss...
  Future<void> loadPrefs() async{
    var pref = await SharedPreferences.getInstance();
    setState(() {
      authToken = pref.getString("authToken")?? 'no auth';
      userCurLocation = pref.getString('userCurrentLocation')??'Not Found';
      myVendorId = pref.getString('myVendorId')??'Not Found';
      vendorName = pref.getString('myVendorName')??'Un Name';
      homeCakeType = pref.getString('homeCakeType')??'null';
      homeCTindex = pref.getInt('homeCTindex')??0;
      isHomeCakeType = pref.getBool('isHomeCake')??false;
      vendorPhone = pref.getString('myVendorPhone')??'0000000000';
      iamYourVendor = pref.getBool('iamYourVendor')??false;
      navFromHome = pref.getBool('naveToHome')??false;

      if(iamYourVendor==true){
        mySelVendors = [
          {
            "VendorName":vendorName
          }
        ];
      }else{

      }

      getCakeList();
    });
  }

  //Fetching cake list API...
  Future<void> getCakeList() async{

    showAlertDialog();

    String commonCake = 'https://cakey-database.vercel.app/api/cake/list';
    String vendorCake = 'https://cakey-database.vercel.app/api/cake/listbyId/$myVendorId';

    try{
      http.Response response = await http.get(
          Uri.parse(iamYourVendor==true?vendorCake:commonCake),
          headers: {"Authorization":"$authToken"}
      );
      if(response.statusCode==200){

        //
        if(response.contentLength!<50){
          setState((){
            networkMsg = "No Cakes Found!";
            rangeValuesList = [100 , 200];
            rangeValues = new RangeValues(0.0,
                rangeValuesList.reduce(max).toDouble());
          });
          fetchFlavours();
          fetchShapes();
          Navigator.pop(context);
        }else{

          setState(() {
            isNetworkError = false;
            cakesList = jsonDecode(response.body);
            // cakesList = cakesList.reversed.toList();

            for(int i=0;i<cakesList.length;i++){

              rangeValuesList.add(int.parse(cakesList[i]['Price']));
              cakesTypes.add(cakesList[i]['TypeOfCake']);
            }

            cakesTypes.insert(0, "All Cakes");
            cakesTypes = cakesTypes.toSet().toList();

            Navigator.pop(context);

            fetchFlavours();
            fetchShapes();
          });
          


          rangeValuesList = rangeValuesList.toSet().toList();


          setState((){
            rangeValues = new RangeValues(0.0,
                rangeValuesList.reduce(max).toDouble());
          });

        }

      }
      else{
        setState(() {
          isNetworkError = true;
          networkMsg = "Error Code : ${response.statusCode} ${response.reasonPhrase}";

          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Code : ${response.statusCode}\nMsg : ${response.reasonPhrase}'),
                backgroundColor: Colors.amber,
                action: SnackBarAction(
                  label: "Retry",
                  onPressed:()=>setState(() {
                    loadPrefs();
                  }),
                ),
              )
          );
        });
        Navigator.pop(context);
      }
    }catch(error){

      setState(() {
        isNetworkError = true;
        networkMsg = "Check Your Connection!";
      });
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
      Navigator.pop(context);
    }
  }

  //Fetching Flavours...API
  Future<void> fetchFlavours() async{

    var res = await http.get(
        Uri.parse('https://cakey-database.vercel.app/api/flavour/list'),
        headers: {"Authorization":"$authToken"}
    );

    if(res.statusCode==200){

      List fl = jsonDecode(res.body);

      for(int i =0 ; i<fl.length;i++){
        setState(() {
          filterCakesFlavList.add(fl[i]['Name'].toString().toLowerCase());
        });
      }

      filterCakesFlavList = filterCakesFlavList.toSet().toList();

    }else{

    }

  }

  //get shapes from api
  Future<void> fetchShapes() async{

    var res = await http.get(
        Uri.parse('https://cakey-database.vercel.app/api/shape/list'),
        headers: {"Authorization":"$authToken"}
    );

    if(res.statusCode==200){

      List fl = jsonDecode(res.body);

      for(int i =0 ; i<fl.length;i++){
        setState(() {
          shapesForFilter.add(fl[i]['Name'].toString().toLowerCase());
        });
      }

      shapesForFilter = shapesForFilter.toSet().toList();

    }else{

    }

  }

  //Check the internet
  Future<void> checkNetwork() async{
    try {
      final result = await InternetAddress.lookup('www.google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('You are online...!'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            )
        );
        setState(() {
          networkMsg = "Network connected";
        });

      }
    } on SocketException catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('You are offline!'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          )
      );

      setState(() {
        networkMsg = "No Internet! Connect & tap here";
      });
    }
    // return connetedOrNot;
  }

  //Send prefs to next screen....
  Future<void> sendDetailsToScreen(int index) async{

    //Local Vars
    List<String> cakeImgs = [];
    List<String> cakeFlavs = [];
    List<String> cakeWeights = [];
    List<String> cakeShapes = [];
    List<String> cakeTopings = [];
    var prefs = await SharedPreferences.getInstance();


    //region API LIST
    //getting cake pics
    if(cakeSearchList[index]['Images'].isNotEmpty){
      setState(() {
        for(int i=0;i<cakeSearchList[index]['Images'].length;i++){
          cakeImgs.add(cakeSearchList[index]['Images'][i].toString());
        }
      });
    }
    else{
      setState(() {
        cakeImgs = [];
      });
    }

    //getting cake flavs
    if(cakeSearchList[index]['FlavourList'].isNotEmpty){
      setState(() {
        for(int i=0;i<cakeSearchList[index]['FlavourList'].length;i++){
          cakeFlavs.add(cakeSearchList[index]['FlavourList'][i].toString());
        }
      });
    }
    else{
      setState(() {
        cakeFlavs = [];
      });
    }

    //getting cake shapes
    if(cakeSearchList[index]['ShapeList'].isNotEmpty){
      setState(() {
        for(int i=0;i<cakeSearchList[index]['ShapeList'].length;i++){
          cakeShapes.add(cakeSearchList[index]['ShapeList'][i].toString());
        }
      });
    }
    else{
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
    if(cakeSearchList[index]['WeightList'].isNotEmpty){
      setState(() {
        for(int i=0;i<cakeSearchList[index]['WeightList'].length;i++){
          cakeWeights.add(cakeSearchList[index]['WeightList'][i].toString());
        }
      });
    }
    else{
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
    prefs.setString('cakeRatings', cakeSearchList[index]['Ratings'].toString());
    prefs.setString('cakeEggOrEggless', cakeSearchList[index]['EggOrEggless'].toString());
    prefs.setString('cakeNames', cakeSearchList[index]['Title'].toString());
    prefs.setString('cakeId', cakeSearchList[index]['_id'].toString());
    prefs.setString('cakesmodId', cakeSearchList[index]['Id'].toString());
    prefs.setString('cakeDiscount', cakeSearchList[index]['Discount'].toString());
    prefs.setString('cakePrice', cakeSearchList[index]['Price'].toString());
    prefs.setString('cakeDescription', cakeSearchList[index]['Description'].toString());
    prefs.setString('cakeType', cakeSearchList[index]['TypeOfCake'].toString());
    prefs.setString('cakeDelCharge', cakeSearchList[index]['DeliveryCharge'].toString());
    prefs.setInt('cakeTaxRate', cakeSearchList[index]['Tax'].toInt());

    prefs.setString('vendorID', cakeSearchList[index]['VendorID'].toString());
    prefs.setString('vendorsmodID', cakeSearchList[index]['Vendor_ID'].toString());
    prefs.setString('vendorName', cakeSearchList[index]['VendorName'].toString());
    prefs.setString('vendorMobile', cakeSearchList[index]['VendorPhoneNumber'].toString());

    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => CakeDetails(
            cakeSearchList[index]['ShapeList'].toList(),cakeSearchList[index]['FlavourList'].toList(),
            cakeSearchList[index]['ArticleList'].toList()
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

  }

  //Send filtered prefs to next screen
  Future<void> sendFillDetailsToScreen(int index) async{

    // filterCakesSearchList

    List<String> cakeImgs = [];
    List<String> cakeFlavs = [];
    List<String> cakeWeights = [];
    List<String> cakeShapes = [];
    List<String> cakeTopings = [];
    var prefs = await SharedPreferences.getInstance();


    //region API LIST
    //getting cake pics
    if(filterCakesSearchList[index]['Images'].isNotEmpty){
      setState(() {
        for(int i=0;i<filterCakesSearchList[index]['Images'].length;i++){
          cakeImgs.add(filterCakesSearchList[index]['Images'][i].toString());
        }
      });
    }
    else{
      setState(() {
        cakeImgs = [];
      });
    }

    //getting cake flavs
    if(filterCakesSearchList[index]['FlavourList'].isNotEmpty){
      setState(() {
        for(int i=0;i<filterCakesSearchList[index]['FlavourList'].length;i++){
          cakeFlavs.add(filterCakesSearchList[index]['FlavourList'][i].toString());
        }
      });
    }
    else{
      setState(() {
        cakeFlavs = [];
      });
    }

    //getting cake shapes
    if(filterCakesSearchList[index]['ShapeList'].isNotEmpty){
      setState(() {
        for(int i=0;i<filterCakesSearchList[index]['ShapeList'].length;i++){
          cakeShapes.add(filterCakesSearchList[index]['ShapeList'][i].toString());
        }
      });
    }
    else{
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
    if(filterCakesSearchList[index]['WeightList'].isNotEmpty){
      setState(() {
        for(int i=0;i<filterCakesSearchList[index]['WeightList'].length;i++){
          cakeWeights.add(filterCakesSearchList[index]['WeightList'][i].toString());
        }
      });
    }
    else{
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
    prefs.setString('cakeRatings', filterCakesSearchList[index]['Ratings'].toString());
    prefs.setString('cakeEggOrEggless', filterCakesSearchList[index]['EggOrEggless'].toString());
    prefs.setString('cakeNames', filterCakesSearchList[index]['Title'].toString());
    prefs.setString('cakeId', filterCakesSearchList[index]['_id'].toString());
    prefs.setString('cakeDiscount', filterCakesSearchList[index]['Discount'].toString());
    prefs.setString('cakePrice', filterCakesSearchList[index]['Price'].toString());
    prefs.setString('cakeDescription', filterCakesSearchList[index]['Description'].toString());
    prefs.setString('cakeType', filterCakesSearchList[index]['TypeOfCake'].toString());
    prefs.setString('cakeDelCharge', filterCakesSearchList[index]['DeliveryCharge'].toString());
    prefs.setInt('cakeTaxRate', filterCakesSearchList[index]['Tax'].toInt());

    prefs.setString('vendorID', filterCakesSearchList[index]['VendorID'].toString());
    prefs.setString('vendorName', filterCakesSearchList[index]['VendorName'].toString());
    prefs.setString('vendorMobile', filterCakesSearchList[index]['VendorPhoneNumber'].toString());

    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => CakeDetails(
            filterCakesSearchList[index]['ShapeList'].toList(),filterCakesSearchList[index]['FlavourList'].toList(),
            filterCakesSearchList[index]['ArticleList'].toList()
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


  }

  //Applying the filters...
  void applyFilters(String priceStart ,String priceEnd , List flavours ,List shapes , List topings){

    List a = [] , b = [] , c = [] ,d = [];

    setState(() {
      //all are empty
      if(priceStart.isEmpty&&priceEnd.isEmpty&&flavours.isEmpty&&shapes.isEmpty&&topings.isEmpty){
        Navigator.pop(context);
        isFilterisOn = false;
      }
      else{
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Filters Applied.'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        //price values ok
        if(priceStart.isNotEmpty||priceEnd.isNotEmpty)
        {
          setState(() {
            for (int i = 0; i < eggOrEgglesList.length; i++) {
              d = eggOrEgglesList.where((element) =>
              int.parse(element['Price'], onError: (e) => 0) >=
                  double.parse(priceRangeStart, (e) => 0).toInt() &&
                  int.parse(element['Price']) <=
                      double.parse(priceRangeEnd, (e) => 0).toInt()
              ).toList();

              isFilterisOn = true;
            }
          });
        }

        //flav list ok
        if(flavours.isNotEmpty){



          for(int i=0;i<eggOrEgglesList.length;i++){



            if(eggOrEgglesList[i]['FlavourList']!=null && eggOrEgglesList[i]['FlavourList'].isNotEmpty){



              for(int j = 0 ; j<eggOrEgglesList[i]['FlavourList'].length;j++){

                if(eggOrEgglesList[i]['FlavourList'][j]['Name']!=null){



                  for(int k = 0;k<flavours.length;k++){

                    if(eggOrEgglesList[i]['FlavourList'][j]['Name'].toString().toLowerCase()
                        .contains(flavours[k].toString().toLowerCase())
                    ){


                      setState((){
                        a.add(eggOrEgglesList[i]);
                        isFilterisOn=true;
                      });

                    }else {

                    }

                  }

                }else{

                }

              }


            }else{


            }



          }

          // try{
          //   setState(() {
          //     for(int i = 0 ;i < eggOrEgglesList.length;i++){
          //       if(eggOrEgglesList[i]['FlavourList'].isNotEmpty && eggOrEgglesList[i]['FlavourList']!=null){
          //
          //         for(int j=0;j<eggOrEgglesList[i]['FlavourList'].length;j++){
          //
          //           if(eggOrEgglesList[i]['FlavourList'][j]['Name']!=null){
          //
          //
          //
          //             // for(int k = 0; k<flavours.length;k++){
          //             //   a = eggOrEgglesList[i]['FlavourList'].where((e)=>e['Name'].toString().toLowerCase()
          //             //   .contains(flavours[k].toString().toLowerCase())
          //             //   ).toList();
          //             // }
          //
          //           }
          //
          //         }
          //
          //       }else{
          //
          //       }
          //     }
          //
          //     a = a.toSet().toList();
          //
          //     isFilterisOn=true;
          //
          //   });
          // }catch(e){

          // }

        }

        //shapes list ok
        if(shapes.isNotEmpty){
          setState(() {
            for(int i=0;i<eggOrEgglesList.length;i++){

              if(eggOrEgglesList[i]['ShapeList'].isNotEmpty){

                for(int j=0;j<shapes.length;j++){
                  if(eggOrEgglesList[i]['ShapeList'].toList().contains(
                      shapes[j][0].toString().toUpperCase()+shapes[j].toString().substring(1).toLowerCase()
                  )){
                    myShapesFilter.add(eggOrEgglesList[i]);
                  }
                }
              }

            }
            isFilterisOn=true;
          });

        }

        //topings list ok
        if(topings.isNotEmpty){

          setState(() {

            for(int i=0;i<eggOrEgglesList.length;i++){
              if(eggOrEgglesList[i]['CakeToppings'].isNotEmpty){
                for(int j = 0 ; j<topings.length;j++){
                  if(eggOrEgglesList[i]['CakeToppings'].contains(topings[j])){
                    c.add(eggOrEgglesList[i]);
                  }
                }
              }else{

              }
            }
            isFilterisOn=true;
          });
        }


        myFilterList = a+b+c+d;
        filteredListByUser = myFilterList + myShapesFilter;
        filteredListByUser = filteredListByUser.toSet().toList();
        filteredListByUser = filteredListByUser.reversed.toList();

      }

    });

  }

  //Clear all applied filters...
  void clearAllFilters(){

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Filters removed.'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
    setState((){
      //Filterd notify text
      isFilterisOn = false;

      myFilterList = [];

      //price range = 0
      priceRangeStart = "";
      priceRangeEnd = '';
      rangeValues = RangeValues(0,rangeValuesList.reduce(max).toDouble());

      //fixed lists
      fixedFilterFlav = [];
      fixedFilterShapes = [];
      fixedFilterTopping = [];

      //Check boxs
      flavsCheck = [];
      shapesCheck = [];
      topingCheck = [];

      filteredListByUser = myFilterList + myShapesFilter;
      filteredListByUser = filteredListByUser.toSet().toList();
      filteredListByUser = filteredListByUser.reversed.toList();

    });

  }

  //applying shape only filter
  void applyFilterByShape(List shapes){

    setState(() {
      if(shapes.isEmpty){
        Navigator.pop(context);
        shapeOnlyFilter = false;
      }
      else{
        myShapesFilter.clear();
        setState(() {
          for(int i=0;i<eggOrEgglesList.length;i++){

            if(eggOrEgglesList[i]['ShapeList'].isNotEmpty){

              for(int j=0;j<shapes.length;j++){
                if(eggOrEgglesList[i]['ShapeList'].toList().contains(
                    shapes[j][0].toString().toUpperCase()+shapes[j].toString().substring(1).toLowerCase()
                )){
                  myShapesFilter.add(eggOrEgglesList[i]);
                }
              }

            }

          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Shapes Applied.'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
          shapeOnlyFilter=true;
          Navigator.pop(context);
        });


        filteredListByUser = myFilterList+ myShapesFilter;
        filteredListByUser = filteredListByUser.toSet().toList();
        filteredListByUser = filteredListByUser.reversed.toList();
      }

    });


  }

  //Clr shapes filter..
  void clearShapesFilter(){
    setState(() {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Shapes removed!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      myShapesFilter=[];
      filterShapesCheck = [];
      filterShapes = [];
      shapeOnlyFilter = false;


      filteredListByUser = myFilterList + myShapesFilter;
      filteredListByUser = filteredListByUser.toSet().toList();
      filteredListByUser = filteredListByUser.reversed.toList();

      Navigator.pop(context);
    });

  }

  //clear the search
  void clearTheSearch(){
    setState(() {
      searchModeis = false;
      searchCakeCate = '';
      searchCakeSubType = '';
      searchCakeVendor = '';
      searchCakeLocation = '';
      Navigator.pop(context);
    });
  }

  //endregion

  @override
  void initState() {
    // TODO: implement initState
    Future.delayed(Duration.zero , () async{
      loadPrefs();
    });
    setState(() {
      for(int i = 0; i<shapesOthersForFilter.length;i++){
        otherShapeCheck.add(false);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    Future.delayed(Duration.zero , () async{
      var pr = await SharedPreferences.getInstance();
      pr.remove('iamYourVendor');
      pr.remove('vendorCakeMode');
      pr.remove('naveToHome');
      context.read<ContextData>().setMyVendors([]);
      context.read<ContextData>().addMyVendor(false);
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

    if(egglesSwitch == true){
      setState(() {
        eggOrEgglesList = cakesList.where((element) =>
            element['EggOrEggless'].toString().toLowerCase().contains("eggless")).toList();

        cakesByType = eggOrEgglesList.where((element) => element['TypeOfCake'].toString().toLowerCase()
            == cakesTypes[currentIndex].toString().toLowerCase()).toList();

      });
    }
    else if(egglesSwitch == false){
      setState(() {
        eggOrEgglesList = cakesList.where((element) =>
        element['EggOrEggless'].toString().toLowerCase()=="egg"||
            element['EggOrEggless'].toString().toLowerCase()=="eggadded"
        ).toList();

        cakesByType = eggOrEgglesList.where((element) => element['TypeOfCake'].toString().toLowerCase()
            == cakesTypes[currentIndex].toString().toLowerCase()).toList();

      });
    }

    if(isFilterisOn ==true || shapeOnlyFilter == true || searchModeis == true){
      setState(() {
        cakeSearchList = filteredListByUser.toList();
      });
      if(searchCakesText.isNotEmpty){
        setState(() {
          activeSearch = true;
          cakeSearchList = filteredListByUser.where((element) =>
              element['Title'].toString().toLowerCase().contains(searchCakesText.toLowerCase())).toList();
        });
      }
      else{
        setState(() {
          activeSearch = false;
          cakeSearchList = filteredListByUser.toList();
        });
      }
      if(isFiltered==true&&searchCakesText.isNotEmpty){
        setState(() {
          filterCakesSearchList = cakesByType.where((element) => element['Title'].toString().toLowerCase().contains(searchCakesText.toLowerCase())).toList();
        });
      }
      else{
        setState(() {
          filterCakesSearchList = cakesByType;
        });
      }
    }
    else{
      if(searchCakesText.isNotEmpty){
        setState(() {
          activeSearch = true;
          cakeSearchList = eggOrEgglesList.where((element) => element['Title'].toString().toLowerCase().contains(searchCakesText.toLowerCase())).toList();
        });
      }
      else{
        setState(() {
          activeSearch = false;
          cakeSearchList = eggOrEgglesList;
        });


        // set search by filters

        if(cakeVendorCtrl.text.isNotEmpty || cakeCategoryCtrl.text.isNotEmpty|| cakeSubCategoryCtrl.text.isNotEmpty ||selectedFilter.isNotEmpty){

          setState((){

            categorySearch = [];
            subCategorySearch = [];
            vendorBasedSearch = [];
            cakeTypeList=[];
            activeSearch = true;

            if(cakeCategoryCtrl.text.isNotEmpty){
              categorySearch = eggOrEgglesList.where((element) => element['Category'].toString().toLowerCase()
                  .contains(cakeCategoryCtrl.text.toLowerCase())).toList();
            }

            if(cakeSubCategoryCtrl.text.isNotEmpty){
              subCategorySearch = eggOrEgglesList.where((element) => element['SubCategory'].toString().toLowerCase()
                  .contains(cakeSubCategoryCtrl.text.toLowerCase())).toList();
            }

            if(cakeVendorCtrl.text.isNotEmpty){
              vendorBasedSearch = eggOrEgglesList.where((element) => element['VendorName'].toString().toLowerCase()
                  .contains(cakeVendorCtrl.text.toLowerCase())).toList();
            }

            if (selectedFilter.isNotEmpty) {

              for(int i=0;i<eggOrEgglesList.length;i++){

                if(eggOrEgglesList[i]['TypeOfCake'].isNotEmpty){
                  for(int j = 0 ; j<selectedFilter.length;j++){

                    if(eggOrEgglesList[i]['TypeOfCake'].contains(selectedFilter[j])){
                      cakeTypeList.add(eggOrEgglesList[i]);

                    }
                  }
                }
              }

            }

            // cakeSearchList.clear();

            cakeSearchList = categorySearch.toList()
                + subCategorySearch.toList() + vendorBasedSearch.toList()+cakeTypeList.toList();
            cakeSearchList = cakeSearchList.toSet().toList();


          });
        }
        else{
          // activeSearch = false;
          cakeSearchList = eggOrEgglesList;
        }

      }
      if(isFiltered==true&&searchCakesText.isNotEmpty){
        setState(() {
          filterCakesSearchList = cakesByType.where((element) => element['Title'].toString().toLowerCase().contains(searchCakesText.toLowerCase())).toList();
        });
      }
      else{
        setState(() {
          filterCakesSearchList = cakesByType;
        });
      }
    }

    return WillPopScope(
      onWillPop: () async{

        return true;
      },
      child: Scaffold(
        bottomSheet:_show?BottomSheet(
          onClosing: () {
          },
          builder: (BuildContext context) {
            return Stack(
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
                        color: Colors.red[100]
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text : 'DO YOU WANT A ',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16
                                ),
                              ),
                              TextSpan(
                                text : 'THEME CAKE ',
                                style: TextStyle(
                                    color: lightPink,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 16
                                ),
                              )
                            ]
                          )
                        ),
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                              color: Colors.transparent,
                              height: 70,
                              width: 70,
                              child: Image(
                                image: AssetImage('assets/images/themecake.png'),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: width*0.86,
                  top: -6,
                  child: IconButton(
                      onPressed: (){
                        setState(() {
                          _show = false;
                        });
                      },
                      icon: Icon(Icons.cancel_rounded,color: Colors.red,size: 30,)
                  ),
                )
              ],
            );
          },
        ):null,
        resizeToAvoidBottomInset: false,
        key: _scaffoldKey,
        body:Container(
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: Svg("assets/images/splash.svg"), fit: BoxFit.cover
              )
          ),
          child:SingleChildScrollView(
              child:RefreshIndicator(
                onRefresh : () async{
                  loadPrefs();
                },
                child: Column(
                  children: [
                    //TEXTs...
                    Container(
                      padding: EdgeInsets.only(left: 8,top: 10,bottom: 10),
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
                                      fontFamily: poppins , fontSize: 13),
                                )
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(left: 8),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '$userCurLocation',
                              style:
                              TextStyle(
                                  fontFamily: poppins,
                                  fontSize: 15,
                                  color: darkBlue,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),

                    iamYourVendor==false?
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.only(left: 10,top: 10,bottom: 10),
                          width: 200,
                          child: Text(
                            'Find And Order Your\nFavourite Cakes ',
                            style: TextStyle(
                                color: darkBlue,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                fontFamily: "Poppins"
                            ),
                          ),
                        ),
                        Container(
                            child:Image(
                              height: 40,
                              width: 40,
                              image: AssetImage('assets/images/smilyfood.png'),
                            )
                        )
                      ],
                    ):
                    //Vendor name and whatsapp...
                    Container(
                      padding:EdgeInsets.only(left: 10,right: 10),
                      child: Column(
                        crossAxisAlignment:CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 10,),
                          Row(
                            children: [
                              Icon(Icons.account_circle_outlined, color: darkBlue,),
                              Text(' VENDOR' , style:TextStyle(color: Colors.grey , fontSize: 12 , fontFamily: 'Poppins' ))
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    child: Text(mySelVendors[0]['VendorName'],style: TextStyle(
                                        color: darkBlue,fontFamily:"Poppins",
                                        fontSize: 18,fontWeight: FontWeight.bold
                                    ),),
                                  ),

                                  Container(
                                      child:Image(
                                        height: 30,
                                        width: 30,
                                        image: AssetImage('assets/images/smilyfood.png'),
                                      )
                                  )

                                ],
                              ),
                              Container(
                                width: 100,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    InkWell(
                                      onTap: (){

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
                          ),
                        ],
                      ),
                    ),

                    //Searchbar..
                    Container(
                      padding: EdgeInsets.all(10),
                      alignment: Alignment.center,
                      child: Row(
                        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: width * 0.79,
                            height: 45,
                            child: TextField(
                              style: TextStyle(fontFamily: poppins,fontSize: 13 , fontWeight: FontWeight.bold),
                              controller: searchControl,
                              onChanged: (String? text){
                                setState(() {
                                  searchCakesText = text!;
                                });
                              },
                              decoration: InputDecoration(
                                  hintText: "Search cake, vendor, etc...",
                                  hintStyle: TextStyle(fontFamily: poppins,fontSize: 13),
                                  prefixIcon: Icon(Icons.search),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8)
                                  ),
                                  contentPadding: EdgeInsets.all(5),
                                  suffixIcon: IconButton(
                                    onPressed: (){
                                      FocusScope.of(context).unfocus();
                                      setState(() {
                                        searchCakesText = '';
                                        searchControl.text = '';
                                        cakeCategoryCtrl.text='';
                                        cakeSubCategoryCtrl.text='';
                                        cakeVendorCtrl.text='';
                                        selectedFilter=[];
                                      });
                                    },
                                    icon: Icon(Icons.close),
                                    iconSize: 16,
                                  )
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Container(
                            width: width * 0.13,
                            height: 45,
                            decoration: BoxDecoration(
                                color: lightPink,
                                borderRadius: BorderRadius.circular(8)
                            ),
                            child: Semantics(
                              label: "Hi how are you",
                              hint: 'Hi bro iam sorry',
                              child: IconButton(
                                  splashColor: Colors.black26,
                                  onPressed: () {
                                    FocusScope.of(context).unfocus();
                                    setState(() {
                                      _show = true;
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
                                egglesSwitch ? 'Eggless' : 'Egg',
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
                            color:Colors.black54,
                          ),
                          InkWell(
                            onTap: (){
                              showShapesSheet();
                            },
                            child: Stack(
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.favorite_border, color: lightPink),
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
                                shapeOnlyFilter?Positioned(
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
                                ):Container()
                              ],
                            ),
                          ),
                          Container(
                            height: 20,
                            width: 2,
                            color:Colors.black54,
                          ),
                          InkWell(
                            onTap: (){
                              showFilterBottom();
                            },
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
                                isFilterisOn?Positioned(
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
                                ):Container()
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),


                    //Cake cate types
                    cakesTypes.length==0?
                    Container(
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
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      CircleAvatar(backgroundColor: Colors.grey,),
                                      SizedBox(width: 10,),
                                      Container(width: 80,height: 20,color: Colors.grey,)
                                    ],
                                  ),
                                ),
                              );
                            })):
                    !activeSearch?
                    Container(
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
                                    for (int i = 0; i < selIndex.length; i++) {
                                      if (i == index) {
                                        if(i==0){
                                          isFiltered = false;
                                          selIndex[i] = true;
                                        }else{
                                          selIndex[i] = true;
                                          isFiltered = true;
                                          if(isFilterisOn==true || shapeOnlyFilter==true){

                                            cakesByType = filteredListByUser.where((element) => element['TypeOfCake'].toString().toLowerCase()
                                                == cakesTypes[index].toString().toLowerCase()).toList();

                                          }else {

                                            currentIndex = index;

                                            cakesByType = eggOrEgglesList.where((element) => element['TypeOfCake'].toString().toLowerCase()
                                                == cakesTypes[index].toString().toLowerCase()).toList();

                                          }
                                        }
                                      } else {
                                        selIndex[i] = false;
                                      }
                                    }
                                  });
                                },
                                child: Container(
                                  padding: EdgeInsets.only(
                                      left: 15, right: 15, top: 6, bottom: 6),
                                  margin: EdgeInsets.only(top:10 , bottom :10 , left:5,right:5),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: lightPink,
                                        width: 0.5,
                                      ),
                                      color: selIndex[index]
                                          ? Colors.red[100]
                                          : Colors.white),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.cake_outlined,
                                        color: lightPink,
                                      ),
                                      Text(
                                        " ${cakesTypes[index][0].toString().
                                        toUpperCase()+cakesTypes[index].toString().substring(1).toLowerCase()
                                        }",
                                        style: TextStyle(
                                            color: darkBlue,
                                            fontFamily: poppins),
                                      )
                                    ],
                                  ),
                                ),
                              );
                            })
                    ):
                    Container(),

                    //Tap here reload...
                    GestureDetector(
                      onTap: (){
                        setState(() {
                          loadPrefs();
                        });
                      },
                      child: AnimatedContainer(
                        height: isNetworkError?35:0,
                        curve: Curves.ease,
                        alignment: Alignment.center,
                        color: Colors.red,
                        duration: Duration(seconds: 2),
                        child: Text('$networkMsg (-Tap Here-)',style: TextStyle(
                            fontFamily: "Poppins",color: Colors.white,fontSize: 13
                        ),textAlign: TextAlign.center,),
                      ),
                    ),

                    //Filttered cakes
                    Visibility(
                      visible:isFiltered,
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
                              return
                                index==0?
                                GestureDetector(
                                  onTap: (){
                                    sendFillDetailsToScreen(index);
                                  },
                                  child: Column(
                                    children: [
                                      SizedBox(height: 10,),
                                      Text('Found',style: TextStyle(
                                          color: darkBlue,fontSize: 16,fontFamily: "Poppins"
                                      )),
                                      Text(filterCakesSearchList.length.toString()+" items",style: TextStyle(
                                          color: darkBlue,fontWeight: FontWeight.bold,
                                          fontSize: 20,fontFamily: "Poppins"
                                      )),
                                      SizedBox(height: 5,),
                                      Container(
                                        margin: EdgeInsets.only(top: 10),
                                        padding:EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(14),
                                          color: Colors.white,
                                          boxShadow: [BoxShadow(blurRadius: 10, color:Colors.black12, spreadRadius: 0)],
                                        ),
                                        child:Column(
                                          children: [
                                            CircleAvatar(
                                              radius: 50,
                                              backgroundImage:
                                              filterCakesSearchList[index]['Images'].isEmpty?
                                              NetworkImage("https://w0.peakpx.com/wallpaper/863/651/HD-wallpaper-red-cake-pastries-desserts-cakes-strawberry-cake-berry-cake.jpg"):
                                              NetworkImage(filterCakesSearchList[index]['Images'][0].toString()),
                                            ),
                                            SizedBox(height: 8,),
                                            Text("${filterCakesSearchList[index]['Title'][0].toString().toUpperCase()+
                                                filterCakesSearchList[index]['Title'].toString().substring(1).toLowerCase()
                                            }",maxLines: 2,overflow:TextOverflow.ellipsis,style: TextStyle(
                                                color: darkBlue,fontWeight: FontWeight.bold,fontSize: 13,fontFamily: "Poppins"
                                            )),
                                            SizedBox(height: 8,),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text('₹ ${filterCakesSearchList[index]['Price']}',style: TextStyle(
                                                    color: lightPink,fontWeight: FontWeight.bold,fontSize: 14,fontFamily: poppins
                                                )),
                                                Container(
                                                  padding: EdgeInsets.all(4),
                                                  decoration: BoxDecoration(
                                                      color: Colors.grey.withOpacity(0.5),
                                                      borderRadius: BorderRadius.circular(8)
                                                  ),
                                                  child: Text(filterCakesSearchList[index]['WeightList'].isEmpty?'NF':
                                                  '${filterCakesSearchList[index]['WeightList'][0].toString()}'
                                                      ,style: TextStyle(
                                                          color: Colors.black,fontWeight: FontWeight.bold,fontSize: 12
                                                      )),
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ):
                                GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: (){
                                    sendFillDetailsToScreen(index);
                                  },
                                  child: Column(
                                      children: [
                                        Container(
                                          margin: EdgeInsets.only(top: 10),
                                          padding:EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(14),
                                            color: Colors.white,
                                            boxShadow: [BoxShadow(blurRadius: 10, color:Colors.black12, spreadRadius: 0)],
                                          ),
                                          child:Column(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              CircleAvatar(
                                                radius: 50,
                                                backgroundImage:
                                                filterCakesSearchList[index]['Images'].isEmpty?
                                                NetworkImage("https://w0.peakpx.com/wallpaper/863/651/HD-wallpaper-red-cake-pastries-desserts-cakes-strawberry-cake-berry-cake.jpg"):
                                                NetworkImage(filterCakesSearchList[index]['Images'][0].toString()),
                                              ),
                                              SizedBox(height: 8,),
                                              Text("${filterCakesSearchList[index]['Title'][0].toString().toUpperCase()+
                                                  filterCakesSearchList[index]['Title'].toString().substring(1).toLowerCase()}",maxLines: 2,overflow:TextOverflow.ellipsis,style: TextStyle(
                                                  color: darkBlue,fontWeight: FontWeight.bold,fontSize: 15
                                              )),
                                              SizedBox(height: 8,),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text('₹ ${filterCakesSearchList[index]['Price']}',style: TextStyle(
                                                      color: lightPink,fontWeight: FontWeight.bold,fontSize: 14,
                                                      fontFamily: "Poppins"
                                                  )),
                                                  Container(
                                                    padding: EdgeInsets.all(4),
                                                    decoration: BoxDecoration(
                                                        color: Colors.grey.withOpacity(0.5),
                                                        borderRadius: BorderRadius.circular(8)
                                                    ),
                                                    child: Text(filterCakesSearchList[index]['WeightList'].isEmpty?'NF':
                                                    '${filterCakesSearchList[index]['WeightList'][0].toString().split(',').first  }'
                                                        ,style: TextStyle(
                                                            color: Colors.black,fontWeight: FontWeight.bold,fontSize: 12
                                                        )),
                                                  )
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ]
                                  ),
                                );
                            },
                            staggeredTileBuilder: (int index) => StaggeredTile.fit(1),
                          ),
                          Visibility(
                            visible: isNetworkError?false:true,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(filterCakesSearchList.length > 0?'Load completed.':'No results found.',style: TextStyle(
                                  fontFamily: "Poppins",fontWeight: FontWeight.bold
                              ),),
                            ),
                          ),
                        ],
                      ),
                    ),
                    //All cakes...
                    !activeSearch?
                    Visibility(
                      visible: isFiltered?false:true,
                      child:Column(
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
                              return
                                index==0?
                                GestureDetector(
                                  onTap: (){
                                    sendDetailsToScreen(index);
                                  },
                                  child: Column(
                                    children: [
                                      SizedBox(height: 10,),
                                      Text('Found',style: TextStyle(
                                          color: darkBlue,fontSize: 16,fontFamily: "Poppins"
                                      )),
                                      Text(cakeSearchList.length.toString()+" items",style: TextStyle(
                                          color: darkBlue,fontWeight: FontWeight.bold,
                                          fontSize: 20,fontFamily: "Poppins"
                                      )),
                                      SizedBox(height: 5,),
                                      Container(
                                        margin: EdgeInsets.only(top: 10),
                                        padding:EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(14),
                                          color: Colors.white,
                                          boxShadow: [BoxShadow(blurRadius: 10, color:Colors.black12, spreadRadius: 0)],
                                        ),
                                        child:Column(
                                          children: [
                                            CircleAvatar(
                                              radius: 50,
                                              backgroundImage:
                                              cakeSearchList[index]['Images']==null
                                                  ||cakeSearchList[index]['Images'].isEmpty?
                                              NetworkImage("https://w0.peakpx.com/wallpaper/863/651/HD-wallpaper-red-cake-pastries-desserts-cakes-strawberry-cake-berry-cake.jpg"):
                                              NetworkImage(cakeSearchList[index]['Images'][0].toString()),
                                            ),
                                            SizedBox(height: 8,),
                                            Text("${cakeSearchList[index]['Title'][0].toString().toUpperCase()+
                                                cakeSearchList[index]['Title'].toString().substring(1).toLowerCase()
                                            }",maxLines: 2,overflow:TextOverflow.ellipsis,style: TextStyle(
                                                color: darkBlue,fontWeight: FontWeight.bold,fontSize: 13,fontFamily: "Poppins"
                                            )),
                                            SizedBox(height: 8,),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text('₹ ${cakeSearchList[index]['Price']}',style: TextStyle(
                                                    color: lightPink,fontWeight: FontWeight.bold,fontSize: 14,
                                                    fontFamily: "Poppins"
                                                )),
                                                Container(
                                                  padding: EdgeInsets.all(4),
                                                  decoration: BoxDecoration(
                                                      color: Colors.grey.withOpacity(0.5),
                                                      borderRadius: BorderRadius.circular(8)
                                                  ),
                                                  child: Text(cakeSearchList[index]['WeightList'].isEmpty?'NF':
                                                  cakeSearchList[index]['WeightList'].length>1?
                                                  '${cakeSearchList[index]['WeightList'][0].toString().split(',').first}':
                                                  '${cakeSearchList[index]['WeightList'][0].toString().split(',').first+" +"}'
                                                      ,style: TextStyle(
                                                          color: Colors.black,fontWeight: FontWeight.bold,fontSize: 12
                                                      )),
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
                                  onTap: (){
                                    sendDetailsToScreen(index);
                                  },
                                  child: Column(
                                    children: [
                                      Container(
                                        margin: EdgeInsets.only(top: 10),
                                        padding:EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(14),
                                          color: Colors.white,
                                          boxShadow: [BoxShadow(blurRadius: 10, color:Colors.black12, spreadRadius: 0)],
                                        ),
                                        child:Column(
                                          children: [
                                            CircleAvatar(
                                              radius: 50,
                                              backgroundImage:
                                              cakeSearchList[index]['Images'].isEmpty?
                                              NetworkImage("https://w0.peakpx.com/wallpaper/863/651/HD-wallpaper-red-cake-pastries-desserts-cakes-strawberry-cake-berry-cake.jpg"):
                                              NetworkImage(cakeSearchList[index]['Images'][0].toString()),
                                            ),
                                            SizedBox(height: 8),
                                            Text("${cakeSearchList[index]['Title'][0].toString().toUpperCase()+
                                                cakeSearchList[index]['Title'].toString().substring(1).toLowerCase()}",maxLines: 2,overflow:TextOverflow.ellipsis,style: TextStyle(
                                                color: darkBlue,fontWeight: FontWeight.bold,fontSize: 13,fontFamily: "Poppins"
                                            )),
                                            SizedBox(height: 8,),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text('₹ ${cakeSearchList[index]['Price']}',style: TextStyle(
                                                    color: lightPink,fontWeight: FontWeight.bold,fontSize: 14,
                                                    fontFamily: "Poppins"
                                                )),
                                                Container(
                                                  padding: EdgeInsets.all(4),
                                                  decoration: BoxDecoration(
                                                      color: Colors.grey.withOpacity(0.5),
                                                      borderRadius: BorderRadius.circular(8)
                                                  ),
                                                  child: Text(cakeSearchList[index]['WeightList'].isEmpty?'NF':
                                                  cakeSearchList[index]['WeightList'].length>1?
                                                  '${cakeSearchList[index]['WeightList'][0].toString().split(',').first}':
                                                  '${cakeSearchList[index]['WeightList'][0].toString().split(',').first+" +"}'
                                                      ,style: TextStyle(
                                                          color: Colors.black,fontWeight: FontWeight.bold,fontSize: 12
                                                      )),
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
                            staggeredTileBuilder: (int index) => StaggeredTile.fit(1),
                          ),
                          Visibility(
                            visible: isNetworkError?false:true,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(cakeSearchList.length>0?'Load completed.':'No results found.',style: TextStyle(
                                  fontFamily: "Poppins",fontWeight: FontWeight.bold
                              ),),
                            ),
                          ),
                        ],
                      ),
                    ):
                    // cakeSearchList.isNotEmpty?
                    Container(
                      child:(cakeSearchList.length == 0)?Text("No Similar datas found",style: TextStyle(fontFamily: "Poppins",fontWeight: FontWeight.bold),): ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount:cakeSearchList.length,
                          itemBuilder: (c , i){
                            return Container(
                              margin: EdgeInsets.only(left: 15 , right: 15 , top: 5 , bottom: 5),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color: Colors.white,
                                  border: Border.all(
                                      color: Colors.grey[400]!,
                                      width:0.5
                                  )
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  //header text (name , stars)
                                  Container(
                                      padding:EdgeInsets.only(top: 4, bottom: 4 , left :10 ,right:10),
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(15),
                                            topRight: Radius.circular(15),
                                          ),
                                          color: Colors.grey[300]
                                      ),
                                      child:Row(
                                          children:[
                                            Container(
                                              width:cakeSearchList[i]['VendorName'].toString().length>25?
                                              130:60,
                                              child: Text('${cakeSearchList[i]['VendorName']}', style:TextStyle(
                                                  color:Colors.black ,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily:'Poppins',
                                                  fontSize:13
                                              ) , maxLines: 1,overflow: TextOverflow.ellipsis,),
                                            ) ,
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
                                                    color: Colors.black54,fontWeight: FontWeight.bold,fontSize: 12,fontFamily: poppins
                                                ),)
                                              ],
                                            ),
                                            Expanded(
                                                child:Container(
                                                    alignment: Alignment.centerRight,
                                                    child:InkWell(
                                                      onTap:(){
                                                        sendDetailsToScreen(i);
                                                      },
                                                      child: Container(
                                                          alignment: Alignment.center,
                                                          height:25,
                                                          width:25,
                                                          decoration: BoxDecoration(
                                                              shape:BoxShape.circle,
                                                              color: Colors.white
                                                          ),
                                                          child: Icon(Icons.arrow_forward_ios_sharp , color:lightPink,size: 15,)
                                                      ),
                                                    )
                                                )
                                            )
                                          ]
                                      )
                                  ),
                                  //body (image , cake name)
                                  InkWell(
                                    splashColor: Colors.red[100],
                                    onTap:(){
                                      sendDetailsToScreen(i);
                                    },
                                    child: Container(
                                        padding: EdgeInsets.all(8),
                                        child:Row(
                                            children:[
                                              cakeSearchList[i]['Images'].isEmpty||cakeSearchList[i]['Images'][0]==''?
                                              Container(
                                                height:85,
                                                width:85,
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(15),
                                                  color: Colors.pink[100],
                                                ),
                                                child: Icon(Icons.cake_outlined , size: 50 , color:lightPink,),
                                              ):
                                              Container(
                                                height:85,
                                                width:85,
                                                decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(15),
                                                    color: Colors.blue,
                                                    image:DecorationImage(
                                                        image: NetworkImage(cakeSearchList[i]['Images'][0]),
                                                        fit:BoxFit.cover
                                                    )
                                                ),
                                              ),
                                              SizedBox(width:8),
                                              Expanded(
                                                  child:Container(
                                                      child:Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children:[
                                                            Container(
                                                              // width:120,
                                                              child: Text('${cakeSearchList[i]['Title']}', style:TextStyle(
                                                                  color:darkBlue,
                                                                  fontWeight: FontWeight.bold,
                                                                  fontFamily:'Poppins',
                                                                  fontSize:12
                                                              ) , maxLines: 2,overflow: TextOverflow.ellipsis,),
                                                            ) ,
                                                            SizedBox(height:5),
                                                            Container(
                                                              // width:120,
                                                              child: Text('Price Rs.${cakeSearchList[i]['Price']}/Kg Min Quantity 1 Kg Customization Available', style:TextStyle(
                                                                  color:Colors.grey,
                                                                  fontWeight: FontWeight.bold,
                                                                  fontFamily:'Poppins',
                                                                  fontSize:10
                                                              ) , maxLines:2,overflow: TextOverflow.ellipsis,
                                                              ),
                                                            ) ,
                                                            SizedBox(height:5),
                                                            Container(
                                                                height:0.5,
                                                                color:Color(0xffdddddd)
                                                            ),
                                                            SizedBox(height:5),
                                                            Container(
                                                              // width:120,
                                                              child: Text(cakeSearchList[i]['DeliveryCharge']=="0"||
                                                                  cakeSearchList[i]['DeliveryCharge']=="null"||cakeSearchList[i]['DeliveryCharge']==null?
                                                              'DELIVERY FREE':'Delivery Charge Rs.${cakeSearchList[i]['DeliveryCharge']}', style:TextStyle(
                                                                  color:Colors.orange,
                                                                  fontWeight: FontWeight.bold,
                                                                  fontFamily:'Poppins',
                                                                  fontSize:10
                                                              ) , maxLines:1,overflow: TextOverflow.ellipsis,),
                                                            ) ,
                                                          ]
                                                      )
                                                  )
                                              )
                                            ]
                                        )
                                    ),
                                  )
                                ],
                              ),
                            );
                          }
                      ),
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



