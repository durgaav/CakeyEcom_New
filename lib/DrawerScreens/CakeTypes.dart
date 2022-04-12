import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cakey/screens/CakeDetails.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../ContextData.dart';
import 'package:shimmer/shimmer.dart';
import 'package:http/http.dart' as http;
import '../screens/Profile.dart';

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

  //Strings
  String profileUrl = "";
  String userCurLocation = 'Searching...';
  String poppins = "Poppins";
  String networkMsg = "";
  String searchCakesText = '';

  //booleans
  bool egglesSwitch = false;
  bool _show = true;
  bool isNetworkError = false;
  bool isFiltered = false;
  bool isFilterisOn = false ;
  bool shapeOnlyFilter = false;

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
  RangeValues rangeValues = RangeValues(100, 200);

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

  //Shapes showing...
  List<bool> filterShapesCheck = [];
  List filterShapes = [];

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
                            height: 400,
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
                                      max: 2500,
                                      min: 0,
                                      divisions: 250,
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
                                  SizedBox(height: 8,),
                                  Container(
                                    height: 1.0,
                                    color: Colors.black26,
                                  ),
                                  ExpansionTile(
                                    title: Text('Flavours',style: TextStyle(fontFamily: "Poppins",
                                        fontWeight: FontWeight.bold),),
                                    subtitle: Text('Available Flavours',style: TextStyle(fontFamily: "Poppins",),),
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
                                                  Wrap(
                                                    crossAxisAlignment: WrapCrossAlignment.center,
                                                    runSpacing: 5,
                                                    spacing: 5,
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
                                                      Text(filterCakesFlavList[index].toString(),style: TextStyle(
                                                          color: darkBlue , fontFamily: "Poppins",fontSize: 12,fontWeight: FontWeight.bold
                                                      ),),
                                                    ],
                                                  ),
                                                  SizedBox(height: 5,),
                                                  Container(
                                                    height: 0.5,
                                                    width:double.infinity,
                                                    color: lightPink,
                                                  )
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
                                    subtitle: Text('Available Shapes',style: TextStyle(fontFamily: "Poppins",),),
                                    children: [
                                      ListView.builder(
                                          physics: NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          itemCount: filterCakesShapList.length,
                                          itemBuilder: (context , index){
                                            shapesCheck.add(false);
                                            return InkWell(
                                              splashColor: Colors.red[200],
                                              onTap:(){
                                                setState((){
                                                  if(shapesCheck[index]==false){
                                                    shapesCheck[index]=true;

                                                    if(fixedFilterShapes.contains(filterCakesShapList[index])){

                                                    }else{
                                                      fixedFilterShapes.add(filterCakesShapList[index]);
                                                    }
                                                  }else{
                                                    fixedFilterShapes.remove(filterCakesShapList[index]);
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
                                                    spacing: 5,
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

                                                              if(fixedFilterShapes.contains(filterCakesShapList[index])){

                                                              }else{
                                                                fixedFilterShapes.add(filterCakesShapList[index]);
                                                              }
                                                            }else{
                                                              fixedFilterShapes.remove(filterCakesShapList[index]);
                                                              shapesCheck[index]=false;
                                                            }
                                                          });
                                                        },
                                                      ),
                                                      Text(filterCakesShapList[index].toString(),style: TextStyle(
                                                          color: darkBlue , fontFamily: "Poppins",fontSize: 12,fontWeight: FontWeight.bold
                                                      ),),
                                                    ],
                                                  ),
                                                  SizedBox(height: 5,),
                                                  Container(
                                                    height: 0.5,
                                                    width:double.infinity,
                                                    color: lightPink,
                                                  )
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
                                    title: Text('Cake Toppings',style: TextStyle(fontFamily: "Poppins",
                                        fontWeight: FontWeight.bold),),
                                    subtitle: Text('Available Toppings',style: TextStyle(fontFamily: "Poppins",),),
                                    children: [
                                      ListView.builder(
                                          physics: NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          itemCount: filterCakesTopingList.length,
                                          itemBuilder: (context , index){
                                            topingCheck.add(false);
                                            return InkWell(
                                              splashColor: Colors.red[200],
                                              onTap:(){
                                                setState((){
                                                  if(topingCheck[index]==false){
                                                    topingCheck[index]=true;
                                                    if(fixedFilterTopping.contains(filterCakesTopingList[index])){

                                                    }else{
                                                      fixedFilterTopping.add(filterCakesTopingList[index]);
                                                    }
                                                  }else{
                                                    fixedFilterTopping.remove(filterCakesTopingList[index]);
                                                    topingCheck[index]=false;
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
                                                    spacing: 5,
                                                    children: [
                                                      Checkbox(
                                                        shape: CircleBorder(),
                                                        activeColor: Colors.white,
                                                        fillColor: MaterialStateProperty.resolveWith((states) => Colors.green),
                                                        value: topingCheck[index],
                                                        onChanged: (bool? check){
                                                          setState((){
                                                            if(topingCheck[index]==false){
                                                              topingCheck[index]=true;
                                                              if(fixedFilterTopping.contains(filterCakesTopingList[index])){

                                                              }else{
                                                                fixedFilterTopping.add(filterCakesTopingList[index]);
                                                              }
                                                            }else{
                                                              fixedFilterTopping.remove(filterCakesTopingList[index]);
                                                              topingCheck[index]=false;
                                                            }
                                                          });
                                                        },
                                                      ),
                                                      Text(filterCakesTopingList[index].toString(),style: TextStyle(
                                                          color: darkBlue , fontFamily: "Poppins",fontSize: 12,fontWeight: FontWeight.bold
                                                      ),),
                                                    ],
                                                  ),
                                                  SizedBox(height: 5,),
                                                  Container(
                                                    height: 0.5,
                                                    width:double.infinity,
                                                    color: lightPink,
                                                  )
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
          return Container(
            // padding: EdgeInsets.all(15),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child:SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all(20),
                child: Column(
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
                            hintStyle: TextStyle(fontFamily: "Poppins"),
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
                            hintStyle: TextStyle(fontFamily: "Poppins"),
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
                            hintStyle: TextStyle(fontFamily: "Poppins"),
                            prefixIcon: Icon(Icons.account_circle),
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
                        controller: cakeLocationCtrl,
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.all(5),
                            hintText: "Location",
                            hintStyle: TextStyle(fontFamily: "Poppins"),
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
                      height: 15,
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
                        OutlinedButton(
                          onPressed: (){},
                          child: Text('25 KM',style: TextStyle(color: darkBlue,fontFamily: "Poppins"),),
                        ),
                      ],

                    ),
                    SizedBox(height: 8,),
                    Container(
                      height: 1.0,
                      color: Colors.black26,
                    ),
                    //cake types....
                    SizedBox(height: 8,),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Types',style: TextStyle(color: darkBlue,fontSize: 16,
                          fontWeight: FontWeight.bold,fontFamily: "Poppins"),),
                    ),
                    SizedBox(height: 10,),

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
                    Container(
                      height: 55,
                      width: 200,
                      child: RaisedButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        color: lightPink,
                        onPressed: (){
                          Navigator.pop(context);
                        },
                        child: Text("SEARCH",style: TextStyle(
                            color: Colors.white,fontWeight: FontWeight.bold,fontFamily: "Poppins"
                        ),),
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
                    Container(
                      height: 300,
                      child: SingleChildScrollView(
                          child: ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: filterCakesShapList.length,
                              itemBuilder: (context , index){
                                filterShapesCheck.add(false);
                                return InkWell(
                                  splashColor: Colors.red[200],
                                  onTap:(){
                                    setState((){
                                      if(filterShapesCheck[index]==false){
                                        filterShapesCheck[index]=true;

                                        if(filterShapes.contains(filterCakesShapList[index])){

                                        }else{
                                          filterShapes.add(filterCakesShapList[index]);
                                        }
                                      }else{
                                        filterShapes.remove(filterCakesShapList[index]);
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
                                        spacing: 5,
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
                                                  if(filterShapes.contains(filterCakesShapList[index])){

                                                  }else{
                                                    filterShapes.add(filterCakesShapList[index]);
                                                  }
                                                }else{
                                                  filterShapes.remove(filterCakesShapList[index]);
                                                  filterShapesCheck[index]=false;
                                                }
                                              });
                                            },
                                          ),
                                          Text(filterCakesShapList[index].toString(),style: TextStyle(
                                              color: darkBlue , fontFamily: "Poppins",fontSize: 12,fontWeight: FontWeight.bold
                                          ),),
                                        ],
                                      ),
                                      SizedBox(height: 5,),
                                      Container(
                                        height: 0.5,
                                        width:double.infinity,
                                        color: lightPink,
                                      )
                                    ],
                                  ),
                                );
                              }
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
                              applyFilterByShape(filterShapes);
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

  //load prefss...
  Future<void> loadPrefs() async{
    var pref = await SharedPreferences.getInstance();
    setState(() {
      userCurLocation = pref.getString('userCurrentLocation')??'Not Found';
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

          //Cakes flavours
          for(int i=0;i<cakesList.length;i++){
            if(cakesList[i]['FlavourList'].toList().isNotEmpty){
              for(int j = 0 ; j<cakesList[i]['FlavourList'].length;j++){
                filterCakesFlavList.add(cakesList[i]['FlavourList'][j].toString());
              }
            }else{

            }

            filterCakesFlavList = filterCakesFlavList.toSet().toList();


            //Cakes shapes
            for(int i=0;i<cakesList.length;i++){
              if(cakesList[i]['ShapeList'].toList().isNotEmpty){
                for(int j = 0 ; j<cakesList[i]['ShapeList'].length;j++){
                  filterCakesShapList.add(cakesList[i]['ShapeList'][j].toString());
                }
              }else{

              }

              filterCakesShapList = filterCakesShapList.toSet().toList();

              //Cakes topings
              for(int i=0;i<cakesList.length;i++){
                if(cakesList[i]['CakeToppings'].toList().isNotEmpty){
                  for(int j = 0 ; j<cakesList[i]['CakeToppings'].length;j++){
                    filterCakesTopingList.add(cakesList[i]['CakeToppings'][j].toString());
                  }
                }else{

                }

                filterCakesTopingList = filterCakesTopingList.toSet().toList();

            if(i==0){
              cakesTypes.add('All cakes');
            }else{
              cakesTypes.add(cakesList[i]['TypeOfCake'].toString());
            }
          }

          cakesTypes = cakesTypes.toSet().toList();

        }
     }
   });
      }else{

        setState(() {
          isNetworkError = true;
          networkMsg = "Server error! try again latter";
        });
      }
    }catch(error){
      setState(() {
        isNetworkError = true;
        checkNetwork();
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
    if(cakeSearchList[index]['CakeToppings'].isNotEmpty){
      setState(() {
        for(int i=0;i<cakeSearchList[index]['CakeToppings'].length;i++){
          cakeTopings.add(cakeSearchList[index]['CakeToppings'][i].toString());
        }
      });
    }
    else{
      setState(() {
        cakeTopings = [];
      });
    }

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
    prefs.setStringList('cakeFalvours', cakeFlavs);
    prefs.setStringList('cakeWeights', cakeWeights);
    prefs.setStringList('cakeShapes', cakeShapes);
    prefs.setStringList('cakeToppings', cakeTopings);

    //API STRINGS AND INTS
    prefs.setString('cakeRatings', cakeSearchList[index]['Ratings'].toString());
    prefs.setString('cakeEggOrEggless', cakeSearchList[index]['EggOrEggless'].toString());
    prefs.setString('cakeNames', cakeSearchList[index]['Title'].toString());
    prefs.setString('cakeId', cakeSearchList[index]['_id'].toString());
    prefs.setString('cakePrice', cakeSearchList[index]['Price'].toString());
    prefs.setString('cakeDescription', cakeSearchList[index]['Description'].toString());
    prefs.setString('cakeType', cakeSearchList[index]['TypeOfCake'].toString());
    prefs.setString('vendorID', cakeSearchList[index]['VendorID'].toString());
    prefs.setString('vendorName', cakeSearchList[index]['VendorName'].toString());
    prefs.setString('vendorMobile', cakeSearchList[index]['VendorPhoneNumber'].toString());


    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => CakeDetails(),
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
    //Local Vars
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
    if(filterCakesSearchList[index]['CakeToppings'].isNotEmpty){
      setState(() {
        for(int i=0;i<filterCakesSearchList[index]['CakeToppings'].length;i++){
          cakeTopings.add(filterCakesSearchList[index]['CakeToppings'][i].toString());
        }
      });
    }
    else{
      setState(() {
        cakeTopings = [];
      });
    }

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
    prefs.setStringList('cakeFalvours', cakeFlavs);
    prefs.setStringList('cakeWeights', cakeWeights);
    prefs.setStringList('cakeShapes', cakeShapes);
    prefs.setStringList('cakeToppings', cakeTopings);

    //API STRINGS AND INTS

    prefs.setString('cakeRatings', filterCakesSearchList[index]['Ratings'].toString());
    prefs.setString('cakeEggOrEggless', filterCakesSearchList[index]['EggOrEggless'].toString());
    prefs.setString('cakeNames', filterCakesSearchList[index]['Title'].toString());
    prefs.setString('cakeId', filterCakesSearchList[index]['_id'].toString());
    prefs.setString('cakePrice', filterCakesSearchList[index]['Price'].toString());
    prefs.setString('cakeDescription', filterCakesSearchList[index]['Description'].toString());
    prefs.setString('cakeType', filterCakesSearchList[index]['TypeOfCake'].toString());
    prefs.setString('vendorID', filterCakesSearchList[index]['VendorID'].toString());
    prefs.setString('vendorName', filterCakesSearchList[index]['VendorName'].toString());
    prefs.setString('vendorMobile', filterCakesSearchList[index]['VendorPhoneNumber'].toString());
    // prefs.setString('vendorAddress', filterCakesSearchList[index]['VendorPhoneNumber'].toString());



    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => CakeDetails(),
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

    if(shapeOnlyFilter == true){
      print('shapeOnlyFilter is onn...');
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Clear shapes filter, then apply filter only.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }else{
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
            print("price range is not empty");
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
            print('flavours ok !');
            setState(() {
              for(int i=0;i<eggOrEgglesList.length;i++){
                if(eggOrEgglesList[i]['FlavourList'].isNotEmpty){
                  for(int j = 0 ; j<flavours.length;j++){
                    if(eggOrEgglesList[i]['FlavourList'].contains(flavours[j])){
                      a.add(eggOrEgglesList[i]);
                    }
                  }
                }else{

                }
              }

              isFilterisOn=true;
            });
          }

          //shapes list ok
          if(shapes.isNotEmpty){
            print('shapes okk!');

            setState(() {
              for(int i=0;i<eggOrEgglesList.length;i++){
                if(eggOrEgglesList[i]['ShapeList'].isNotEmpty){
                  for(int j = 0 ; j<shapes.length;j++){
                    if(eggOrEgglesList[i]['ShapeList'].contains(shapes[j])){
                      b.add(eggOrEgglesList[i]);
                    }
                  }
                }else{

                }
              }
              isFilterisOn=true;
            });

          }

          //topings list ok
          if(topings.isNotEmpty){
            print('topings ok');

            setState(() {
              List b = [];
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

          filteredListByUser = a + b + c + d;
          filteredListByUser = filteredListByUser.toSet().toList();
          filteredListByUser = filteredListByUser.reversed.toList();

        }

      });
    }
  }

  //Clear all applied filters...
  void clearAllFilters(){
    if(shapeOnlyFilter==true){
      Navigator.pop(context);
    }else{
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

        filteredListByUser = [];

        //price range = 0
        priceRangeStart = "";
        priceRangeEnd = '';

        //fixed lists
        fixedFilterFlav = [];
        fixedFilterShapes = [];
        fixedFilterTopping = [];

        //Check boxs
        flavsCheck = [];
        shapesCheck = [];
        topingCheck = [];

      });
    }

  }

  //applying shape only filter
  void applyFilterByShape(List shapes){
    List a = [];

    if(isFilterisOn==true){
      print('Filter is onn...');
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Clear filter mode, then apply shapes only.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }else{
      setState(() {
        if(shapes.isEmpty){
          Navigator.pop(context);
          shapeOnlyFilter = false;
        }
        else{
          print('shapes okk!');
          setState(() {
            for(int i=0;i<eggOrEgglesList.length;i++){
              if(eggOrEgglesList[i]['ShapeList'].isNotEmpty){
                for(int j = 0 ; j<shapes.length;j++){
                  if(eggOrEgglesList[i]['ShapeList'].contains(shapes[j])){
                    a.add(eggOrEgglesList[i]);
                  }
                }
              }else{

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

          if(filteredListByUser.isNotEmpty){
            filteredListByUser = filteredListByUser + a;
          }else{
            filteredListByUser = a;
          }
          filteredListByUser = filteredListByUser.toSet().toList();
          filteredListByUser = filteredListByUser.reversed.toList();
        }

      });

    }
  }

  //Clr shapes filter..
  void clearShapesFilter(){
    if(isFilterisOn==true){
      Navigator.pop(context);
    }else{
      setState(() {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Shapes removed!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        filterShapesCheck = [];
        filterShapes = [];
        filteredListByUser = [];
        shapeOnlyFilter=false;
        Navigator.pop(context);
      });
    }
  }

  //endregion

  @override
  void initState() {
    // TODO: implement initState
    Future.delayed(Duration.zero , () async{
      loadPrefs();
      getCakeList();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    profileUrl = context.watch<ContextData>().getProfileUrl();
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    //search & filters controlls
      if(egglesSwitch == true){
        setState(() {
          eggOrEgglesList = cakesList.where((element) =>
              element['EggOrEggless'].toString().toLowerCase().contains("Eggless".toLowerCase())).toList();
        });
      }
      else if(egglesSwitch == false){
        setState(() {
          eggOrEgglesList = cakesList.where((element) =>
              element['EggOrEggless'].toString().toLowerCase().contains("EggAdded".toLowerCase())).toList();
        });
      }

    if(isFilterisOn ==true || shapeOnlyFilter == true){
      setState(() {
        cakeSearchList = filteredListByUser.toList();
      });
      if(searchCakesText.isNotEmpty){
        setState(() {
          cakeSearchList = filteredListByUser.where((element) => element['Title'].toString().toLowerCase().contains(searchCakesText.toLowerCase())).toList();
        });
      }
      else{
        setState(() {
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
          cakeSearchList = eggOrEgglesList.where((element) => element['Title'].toString().toLowerCase().contains(searchCakesText.toLowerCase())).toList();
        });
      }
      else{
        setState(() {
          cakeSearchList = eggOrEgglesList;
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

    return Scaffold(
        appBar: AppBar(
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
        title: Text('TYPES OF CAKES',
            style: TextStyle(
                color: darkBlue, fontWeight: FontWeight.bold, fontSize: 15)),
        elevation: 0.0,
        backgroundColor: lightGrey,
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              InkWell(
                onTap: (){},
                child: Container(
                  padding: EdgeInsets.all(3),
                  decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(8)),
                  child: Icon(
                    Icons.notifications_none,
                    color: darkBlue,
                  ),
                ),
              ),
              Positioned(
                left: 15,
                top: 18,
                child: CircleAvatar(
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
          SizedBox(
            width: 10,
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(blurRadius: 3, color: Colors.black, spreadRadius: 0)
              ],
            ),
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => Profile(defindex: 0,),
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
              child: profileUrl!="null"?CircleAvatar(
                radius: 17.5,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                    radius: 16,
                    backgroundImage:NetworkImage("$profileUrl")
                ),
              ):CircleAvatar(
                radius: 17.5,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                    radius: 16,
                    backgroundImage:AssetImage("assets/images/user.png")
                ),
              ),
            ),
          ),
          SizedBox(
            width: 10,
          ),
        ],
        ),
        bottomSheet:!_show?BottomSheet(
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
                        Text('DO YOU WANT A THEME CAKE?',style: TextStyle(
                            color: lightPink,fontWeight: FontWeight.bold,fontFamily: poppins
                        ),),
                        Icon(Icons.cake,color: lightPink,size: 50,)
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
            )),
        child: SingleChildScrollView(
          child:Column(
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
                            width: 8,
                          ),
                          Text(
                            'Delivery to',
                            style: TextStyle(
                                color: Colors.black54,
                                fontWeight: FontWeight.bold,
                                fontFamily: poppins),
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
              Container(
                padding: EdgeInsets.only(left: 10,top: 10,bottom: 10),
                width: width,
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
                            thumbColor: Colors.white,
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
                              fontFamily: poppins),
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
                                    }else{
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
                                left: 20, right: 20, top: 6, bottom: 6),
                            margin: EdgeInsets.all(10),
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
                                  " ${cakesTypes[index][0].toString().toUpperCase()+cakesTypes[index].toString().substring(1).toLowerCase()}",
                                  style: TextStyle(
                                      color: darkBlue,
                                      fontFamily: poppins),
                                )
                              ],
                            ),
                          ),
                        );
                      })
              ),

              //Tap here reload...
              Visibility(
                visible: isNetworkError,
                child: InkWell(
                  splashColor: Colors.black26,
                  onTap: (){
                    setState(() {
                      getCakeList();
                    });
                  },
                  child: Text('$networkMsg',style: TextStyle(
                      fontFamily: "Poppins",color: Colors.red,fontSize: 16
                  ),),
                ),
              ),

              //Filttered cakes
              Visibility(
                visible: isFiltered,
                child: Column(
                  children: [
                    StaggeredGridView.countBuilder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.all(12.0),
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 12,
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
                                Text('Found\n${filterCakesSearchList.length} Item(s)',style: TextStyle(
                                    color: darkBlue,fontWeight: FontWeight.bold,fontSize: 16
                                )),
                                SizedBox(height: 5,),
                                Container(
                                  margin: EdgeInsets.only(top: 10),
                                  height:height*0.3,
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
                                        radius: 45,
                                        backgroundImage:
                                        filterCakesSearchList[index]['Images'].isEmpty?
                                        NetworkImage("https://w0.peakpx.com/wallpaper/863/651/HD-wallpaper-red-cake-pastries-desserts-cakes-strawberry-cake-berry-cake.jpg"):
                                        NetworkImage(filterCakesSearchList[index]['Images'][0].toString()),
                                      ),
                                      Text("${filterCakesSearchList[index]['Title'][0].toString().toUpperCase()+
                                          filterCakesSearchList[index]['Title'].toString().substring(1).toLowerCase()
                                      }",maxLines: 2,overflow:TextOverflow.ellipsis,style: TextStyle(
                                          color: darkBlue,fontWeight: FontWeight.bold,fontSize: 15
                                      )),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('₹ ${filterCakesSearchList[index]['Price']}',style: TextStyle(
                                              color: lightPink,fontWeight: FontWeight.bold,fontSize: 14
                                          )),
                                          Container(
                                            padding: EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                                color: Colors.grey.withOpacity(0.5),
                                                borderRadius: BorderRadius.circular(8)
                                            ),
                                            child: Text(filterCakesSearchList[index]['WeightList'].isEmpty?'NF':
                                            '${filterCakesSearchList[index]['WeightList'][0].toString().split(',').first+" +"}'
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
                            onTap: (){
                              sendFillDetailsToScreen(index);
                            },
                            child: Column(
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(top: 10),
                                    height:height*0.3,
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
                                          radius: 45,
                                          backgroundImage:
                                          filterCakesSearchList[index]['Images'].isEmpty?
                                          NetworkImage("https://w0.peakpx.com/wallpaper/863/651/HD-wallpaper-red-cake-pastries-desserts-cakes-strawberry-cake-berry-cake.jpg"):
                                          NetworkImage(filterCakesSearchList[index]['Images'][0].toString()),
                                        ),
                                        Text("${filterCakesSearchList[index]['Title'][0].toString().toUpperCase()+
                                            filterCakesSearchList[index]['Title'].toString().substring(1).toLowerCase()}",maxLines: 2,overflow:TextOverflow.ellipsis,style: TextStyle(
                                            color: darkBlue,fontWeight: FontWeight.bold,fontSize: 15
                                        )),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text('₹ ${filterCakesSearchList[index]['Price']}',style: TextStyle(
                                                color: lightPink,fontWeight: FontWeight.bold,fontSize: 14
                                            )),
                                            Container(
                                              padding: EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                  color: Colors.grey.withOpacity(0.5),
                                                  borderRadius: BorderRadius.circular(8)
                                              ),
                                              child: Text(filterCakesSearchList[index]['WeightList'].isEmpty?'NF':
                                              '${filterCakesSearchList[index]['WeightList'][0].toString().split(',').first+" +"}'
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
              Visibility(
                visible: isFiltered?false:true,
                child: Column(
                  children: [
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
                    StaggeredGridView.countBuilder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.all(12.0),
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 12,
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
                                Text('Found\n${cakeSearchList.length} Items',style: TextStyle(
                                    color: darkBlue,fontWeight: FontWeight.bold,fontSize: 16
                                )),
                                SizedBox(height: 5,),
                                Container(
                                  margin: EdgeInsets.only(top: 10),
                                  height:height*0.3,
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
                                        radius: 45,
                                        backgroundImage:
                                        cakeSearchList[index]['Images'].isEmpty?
                                        NetworkImage("https://w0.peakpx.com/wallpaper/863/651/HD-wallpaper-red-cake-pastries-desserts-cakes-strawberry-cake-berry-cake.jpg"):
                                        NetworkImage(cakeSearchList[index]['Images'][0].toString()),
                                      ),
                                      Text("${cakeSearchList[index]['Title'][0].toString().toUpperCase()+
                                          cakeSearchList[index]['Title'].toString().substring(1).toLowerCase()
                                          }",maxLines: 2,overflow:TextOverflow.ellipsis,style: TextStyle(
                                          color: darkBlue,fontWeight: FontWeight.bold,fontSize: 15
                                      )),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('₹ ${cakeSearchList[index]['Price']}',style: TextStyle(
                                              color: lightPink,fontWeight: FontWeight.bold,fontSize: 14
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
                                  height:height*0.3,
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
                                        radius: 45,
                                        backgroundImage:
                                        cakeSearchList[index]['Images'].isEmpty?
                                        NetworkImage("https://w0.peakpx.com/wallpaper/863/651/HD-wallpaper-red-cake-pastries-desserts-cakes-strawberry-cake-berry-cake.jpg"):
                                        NetworkImage(cakeSearchList[index]['Images'][0].toString()),
                                      ),
                                      Text("${cakeSearchList[index]['Title'][0].toString().toUpperCase()+
                                          cakeSearchList[index]['Title'].toString().substring(1).toLowerCase()}",maxLines: 2,overflow:TextOverflow.ellipsis,style: TextStyle(
                                          color: darkBlue,fontWeight: FontWeight.bold,fontSize: 15
                                      )),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('₹ ${cakeSearchList[index]['Price']}',style: TextStyle(
                                              color: lightPink,fontWeight: FontWeight.bold,fontSize: 14
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
              )
            ],
          ),
        ),
      ),
      );
  }
}

