import 'dart:convert';
import 'package:cakey/DrawerScreens/VendorsList.dart';
import 'package:cakey/screens/CheckOut.dart';
import 'package:cakey/screens/OrderConfirm.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../ContextData.dart';
import '../DrawerScreens/Notifications.dart';
import 'AddressScreen.dart';
import 'Profile.dart';
import 'package:http/http.dart' as http;
import 'package:expandable_text/expandable_text.dart';

class CakeDetails extends StatefulWidget {
  // const CakeDetails({Key? key}) : super(key: key);
  List shapes, flavour, articals;
  CakeDetails(this.shapes, this.flavour, this.articals);

  @override
  State<CakeDetails> createState() =>
      _CakeDetailsState(shapes, flavour, articals);
}

class _CakeDetailsState extends State<CakeDetails> {
  List shapes, flavour, articals;
  _CakeDetailsState(this.shapes, this.flavour, this.articals);

  //region VARIABLES
  //colors.....
  String poppins = "Poppins";
  Color darkBlue = Color(0xffF213959);
  Color lightPink = Color(0xffFE8416D);
  Color lightGrey = Color(0xffF5F5F5);

  //bool
  bool newRegUser = false;

  //my selected vendor
  String myVendorId = '';
  String myVendorName = '';
  String myVendorProfile = '';
  String myVendorDelCharge = '';
  String vendorPhone = "";
  String myVendorDesc = '';
  String myVendorEgg = '';
  bool iamYourVendor = false;
  bool msgError = false;
  bool vendorCakeMode = false;

  //load context vendor...
  bool isMySelVen = false;
  List mySelVendors = [];

  //Lists...
  List cakeImages = [];
  List cakesList = [];
  List myCakesList = [];

  var multiFlav = [];
  List<bool> multiFlavChecs = [];
  List<bool> multiThemeList = [];

  List topings = [];
  var weight = [];
  List nearestVendors = [];

  List themeCakes = [
    {"Name": 'Sinchan Theme Cake', "Price": "550"},
    {"Name": 'Doremon Theme Cake', "Price": "700"},
    {"Name": 'Dora Theme Cake', "Price": "1000"},
    {"Name": 'Panda Theme Cake', "Price": "1500"},
    {"Name": 'Ben 10 Theme Cake', "Price": "3000"},
    {"Name": 'Love Theme Cake', "Price": "600"},
    {"Name": 'Others', "Price": "Depends On Theme Type"},
  ];
  int selectedThemeCake = 0;

  List<bool> selwIndex = [];
  List<bool> toppingsVal = [];
  List<int> flavVal = [];
  List<String> fixedToppings = [];

  //Pageview dots
  List<Widget> dots = [];

  //Articles
  // var articals = ["None","Happy Birth Day" , "Butterflies" , "Hello World"];
  var articalsPrice = ['0', '100', '125', '50'];
  int articGroupVal = -1;
  String fixedArticle = 'none';
  int articleExtraCharge = 0;

  //Pick Or Deliver
  var picOrDeliver = ['Pickup', 'Delivery'];
  var picOrDel = [false, false];

  //Strings......Cake Details
  String cakeId = "";
  String cakeModId = "";
  String cakeName = "";
  String cakeDescription = "";
  String cakeType = '';
  String cakeRatings = "4.5";
  String vendorID = ''; //ven id
  String vendorModID = ''; //ven id
  String vendorName = ''; //ven name
  String vendorMobileNum = ''; //ven mobile
  String vendorAddress = ''; //ven address
  String cakeEggorEgless = "";
  String cakePrice = "";
  String cakeDeliverCharge = '';
  String cakeDiscounts = '';
  String userMainLocation = '';
  String authToken = '';

  int addedFlavPrice = 0;

  //User PROFILE
  String profileUrl = "";
  String userName = '';
  String userPhone = '';
  String userID = '';
  String userModID = '';
  String userAddress = '';

  //For orders
  String deliverDate = 'Not yet select';
  String deliverSession = 'Not yet select';
  //Doubt flav
  String fixedFlavour = 'Default Flavour';
  var fixedFlavList = [];
  //

  //Shape
  var myShapeIndex = 0;
  String fixedShape = '';
  String fixedtheme = '';
  String fixedWeight = '1.0kg';
  String cakeMsg = '';
  String specialReq = '';
  String fixedAddress = '';
  String fixedDelliverMethod = "";
  String selectedDropWeight = 'Kg';

  //for fixing the flavours
  var temp = [];
  var theme = [];

  var myThemeIndex = 0;
  int shapeGrpValue = 0;

  //ints
  int flavGrpValue = 0;
  int themegrpValue = 0; ////
  int pageViewCurIndex = 0;
  int weightIndex = -1;

  int itemCount = 0;
  int totalAmount = 0;
  int deliveryCharge = 0;
  int discounts = 0;
  int taxes = 0;
  int counts = 1;
  int selVendorIndex = 0;
  int flavExtraCharge = 0;

  //Text controls
  var messageCtrl = new TextEditingController();
  var specialReqCtrl = new TextEditingController();
  var customweightCtrl = new TextEditingController();

  var myScrollCtrl = ScrollController();

  //endregion

  //region Alerts

  //Theme sheet
  void showThemeBottomSheet() async {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
        ),
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (c, void Function(void Function()) setState) {
            return Container(
              padding: EdgeInsets.all(15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 8,
                  ),
                  //Title text...
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'THEMES',
                        style: TextStyle(
                            color: darkBlue,
                            fontSize: 18,
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
                    height: 5,
                  ),
                  Container(
                    height: 0.5,
                    color: Color(0xff333333),
                  ),
                  Expanded(
                    child: Container(
                      height: 220,
                      child: Scrollbar(
                        child: ListView.builder(
                            itemCount: themeCakes.length,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              return InkWell(
                                onTap: () {
                                  setState(() {
                                    myThemeIndex = index;
                                    themegrpValue = index;
                                  });
                                },
                                child: Container(
                                    padding: EdgeInsets.all(8),
                                    child: Row(children: [
                                      myThemeIndex != index
                                          ? Icon(
                                              Icons
                                                  .radio_button_unchecked_outlined,
                                              color: Colors.black,
                                              size: 28,
                                            )
                                          : Icon(
                                              Icons.check_circle_rounded,
                                              color: Colors.green,
                                              size: 28,
                                            ),
                                      SizedBox(width: 8),
                                      Expanded(
                                          child: Text.rich(TextSpan(
                                              text:
                                                  "${themeCakes[index]['Name']} - ",
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.grey[500],
                                                  fontFamily: "Poppins",
                                                  fontWeight: FontWeight.bold),
                                              children: [
                                            TextSpan(
                                              text:
                                                  'Additional Rs.${themeCakes[index]['Price']}',
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.black,
                                                fontFamily: "Poppins",
                                                // fontWeight: FontWeight.bold
                                              ),
                                            )
                                          ])))
                                    ])),
                              );
                            }),
                      ),
                    ),
                  ),
                  //button for add
                  Container(
                    height: 45,
                    width: 120,
                    child: RaisedButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      color: lightPink,
                      onPressed: () {
                        saveFixedTheme(themegrpValue);
                        Navigator.pop(context);
                      },
                      child: Text(
                        "ADD",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Poppins"),
                      ),
                    ),
                  ),
                ],
              ),
            );
          });
        });
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

  //theme select bottom sheet......

  //cake toppings bottom sheet...
  void showCakeToppingsSheet() {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
        ),
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder:
              (BuildContext context, void Function(void Function()) setState) {
            return Container(
              padding: EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 8,
                  ),
                  //Title text...
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'CAKE TOPPINGS',
                        style: TextStyle(
                            color: darkBlue,
                            fontSize: 18,
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

                  Container(
                    height: 290,
                    child: Scrollbar(
                      child: ListView.builder(
                          itemCount: topings.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            toppingsVal.add(false);
                            return ListTile(
                              onTap: () {
                                setState(() {
                                  if (toppingsVal[index] == false) {
                                    toppingsVal[index] = true;

                                    if (fixedToppings
                                        .contains(topings[index])) {
                                      print('exists...');
                                    } else {
                                      fixedToppings.add(topings[index]);
                                    }
                                  } else {
                                    fixedToppings.remove(topings[index]);
                                    toppingsVal[index] = false;
                                  }
                                });
                              },
                              leading: Transform.scale(
                                scale: 1.3,
                                child: Checkbox(
                                  checkColor: Colors.white,
                                  fillColor: MaterialStateProperty.resolveWith(
                                      (states) => Colors.green),
                                  value: toppingsVal[index],
                                  onChanged: (bool? value) {
                                    print(value);
                                    setState(() {
                                      if (toppingsVal[index] == false) {
                                        toppingsVal[index] = true;
                                        if (fixedToppings
                                            .contains(topings[index])) {
                                          print('exists...');
                                        } else {
                                          fixedToppings.add(topings[index]);
                                        }
                                      } else {
                                        fixedToppings.remove(topings[index]);
                                        toppingsVal[index] = false;
                                      }
                                    });
                                  },
                                  shape: CircleBorder(),
                                ),
                              ),
                              title: Text(
                                "${topings[index]}",
                                style: TextStyle(
                                    fontFamily: "Poppins", color: darkBlue),
                              ),
                            );
                          }),
                    ),
                  ),

                  Container(
                    margin: EdgeInsets.all(15),
                    height: 45,
                    width: 120,
                    child: RaisedButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      color: lightPink,
                      onPressed: () {
                        saveFixedToppings();
                        Navigator.pop(context);
                      },
                      child: Text(
                        "ADD",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Poppins"),
                      ),
                    ),
                  ),
                ],
              ),
            );
          });
        });
  }

  //Cake flavours sheet...
  void showCakeFlavSheet() {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
        ),
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder:
              (BuildContext context, void Function(void Function()) setState) {
            return Container(
              padding: EdgeInsets.all(10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 8,
                  ),
                  //Title text...
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'FLAVOUR',
                        style: TextStyle(
                            color: darkBlue,
                            fontSize: 18,
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

                  Container(
                    height: 200,
                    child: Scrollbar(
                      // thumbVisibility: true,
                      child: ListView.builder(
                          itemCount: flavour.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            multiFlavChecs.add(false);
                            return InkWell(
                              splashColor: Colors.red[200],
                              onTap: () {
                                setState(() {
                                  if (multiFlavChecs[index] == false) {
                                    multiFlavChecs[index] = true;
                                    if (temp.contains(flavour[index])) {
                                    } else {
                                      temp.add(flavour[index]);
                                    }
                                  } else {
                                    temp.removeWhere(
                                        (element) => element == flavour[index]);
                                    multiFlavChecs[index] = false;
                                  }
                                });

                                print(temp.toString());
                              },
                              child: Container(
                                  padding: EdgeInsets.all(8),
                                  child: Row(children: [
                                    multiFlavChecs[index] == false
                                        ? Icon(
                                            Icons
                                                .radio_button_unchecked_outlined,
                                            color: Colors.green,
                                            size: 28,
                                          )
                                        : Icon(
                                            Icons.check_circle_rounded,
                                            color: Colors.green,
                                            size: 28,
                                          ),
                                    SizedBox(width: 8),
                                    Expanded(
                                        child: Container(
                                            child: Text.rich(
                                      TextSpan(
                                          text: "${flavour[index]['Name']} - ",
                                          style: TextStyle(
                                              fontFamily: "Poppins",
                                              color: Colors.grey,
                                              fontWeight: FontWeight.bold),
                                          children: [
                                            TextSpan(
                                                text:
                                                    "Additional Rs.${flavour[index]['Price']}/kg",
                                                style: TextStyle(
                                                  fontFamily: "Poppins",
                                                  color: Colors.black,
                                                ))
                                          ]),
                                    )))
                                  ])),
                            );
                          }),
                    ),
                  ),

                  Container(
                    margin: EdgeInsets.all(15),
                    height: 45,
                    width: 120,
                    child: RaisedButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      color: lightPink,
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          saveFixedFlav(temp);
                        });
                      },
                      child: Text(
                        "ADD",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Poppins"),
                      ),
                    ),
                  ),
                ],
              ),
            );
          });
        });
  }

  //Cake Shapes bottom...
  void showCakeShapesSheet() {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
        ),
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder:
              (BuildContext context, void Function(void Function()) setState) {
            return Container(
              padding: EdgeInsets.all(10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
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
                            fontSize: 18,
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

                  Container(
                    height: 220,
                    child: Scrollbar(
                      child: ListView.builder(
                          itemCount: shapes.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  myShapeIndex = index;
                                  shapeGrpValue = index;
                                });
                              },
                              child: Container(
                                  padding: EdgeInsets.all(8),
                                  child: Row(children: [
                                    myShapeIndex != index
                                        ? Icon(
                                            Icons
                                                .radio_button_unchecked_outlined,
                                            color: Colors.black,
                                            size: 28,
                                          )
                                        : Icon(
                                            Icons.check_circle_rounded,
                                            color: Colors.green,
                                            size: 28,
                                          ),
                                    SizedBox(width: 8),
                                    Expanded(
                                        child: Container(
                                      child: Text("${shapes[index]}",
                                          style: TextStyle(
                                              fontFamily: "Poppins",
                                              color: Colors.grey,
                                              fontWeight: FontWeight.bold)),
                                    ))
                                  ])),
                            );
                          }),
                    ),
                  ),

                  Container(
                    margin: EdgeInsets.all(15),
                    height: 45,
                    width: 120,
                    child: RaisedButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      color: lightPink,
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          saveFixedShape(shapeGrpValue);
                        });
                      },
                      child: Text(
                        "ADD",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Poppins"),
                      ),
                    ),
                  ),
                ],
              ),
            );
          });
        });
  }

  //Saving fixed flavour from bottomsheet

  void saveFixedFlav(List list) {
    setState(() {
      fixedFlavList = list;
      if (fixedFlavList.isEmpty) {
        fixedFlavour = "Default Flavour";
      } else {
        fixedFlavour = "${fixedFlavList.length} Selected";
      }

      for (int i = 0; i < list.length; i++) {
        addedFlavPrice = int.parse(list[i]['Price']) + addedFlavPrice;
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Price Updated!'),
        duration: Duration(seconds: 2),
      ));
    });
  }

  //Saving fixed shape
  void saveFixedShape(int i) {
    setState(() {
      fixedShape = shapes[i];
    });
  }

  //Saving fixed topping..
  void saveFixedToppings() {
    setState(() {
      fixedToppings.removeWhere((element) => element == 'index');
    });
    print(fixedToppings);
  }

  void saveFixedTheme(int i) {
    setState(() {
      fixedtheme = themeCakes[i]['Name'];
    });
  }

  //Add new Address Alert...
  void showAddAddressAlert() {
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
        builder: (context) {
          return StatefulBuilder(builder:
              (BuildContext context, void Function(void Function()) setState) {
            return AlertDialog(
              scrollable: true,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Add New Address',
                    style: TextStyle(
                        color: lightPink, fontFamily: "Poppins", fontSize: 13),
                  ),
                  IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close, color: Colors.red))
                ],
              ),
              content: Container(
                width: 250,
                color: Colors.white,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      loading ? LinearProgressIndicator() : Container(),
                      TextField(
                        controller: streetNameCtrl,
                        decoration: InputDecoration(
                            hintText: 'Street No.',
                            hintStyle:
                                TextStyle(fontFamily: "Poppins", fontSize: 13),
                            errorText: streetVal
                                ? 'required street no. & name!'
                                : null),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      TextField(
                        controller: cityNameCtrl,
                        decoration: InputDecoration(
                            hintText: 'City/Area/Town',
                            hintStyle:
                                TextStyle(fontFamily: "Poppins", fontSize: 13),
                            errorText: cityVal ? 'required city name!' : null),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      TextField(
                        controller: districtNameCtrl,
                        decoration: InputDecoration(
                            hintText: 'District',
                            hintStyle:
                                TextStyle(fontFamily: "Poppins", fontSize: 13),
                            errorText:
                                districtVal ? 'required district name!' : null),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      TextField(
                        maxLength: 6,
                        controller: pinCodeCtrl,
                        decoration: InputDecoration(
                            hintText: 'Pin Code',
                            hintStyle:
                                TextStyle(fontFamily: "Poppins", fontSize: 13),
                            errorText:
                                pincodeVal ? 'required pin code!' : null),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                FlatButton(
                    onPressed: () async {
                      setState(() {
                        loading = true;
                      });

                      Position position = await _getGeoLocationPosition();
                      List<Placemark> placemarks =
                          await placemarkFromCoordinates(
                              position.latitude, position.longitude);

                      Placemark place = placemarks[1];
                      // Address = '${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';

                      setState(() {
                        streetNameCtrl =
                            new TextEditingController(text: place.street);

                        if (place.subLocality.toString().isEmpty) {
                          cityNameCtrl =
                              new TextEditingController(text: place.locality);
                        } else {
                          cityNameCtrl = new TextEditingController(
                              text: place.subLocality);
                        }

                        districtNameCtrl = new TextEditingController(
                            text: place.subAdministrativeArea);
                        pinCodeCtrl =
                            new TextEditingController(text: place.postalCode);
                      });

                      setState(() {
                        loading = false;
                      });
                    },
                    child: Text(
                      'Current',
                      style: TextStyle(color: darkBlue, fontFamily: "Poppins"),
                    )),
                FlatButton(
                    onPressed: () {
                      setState(() {
                        //street
                        if (streetNameCtrl.text.isEmpty) {
                          streetVal = true;
                        } else {
                          streetVal = false;
                        }

                        //city
                        if (cityNameCtrl.text.isEmpty) {
                          cityVal = true;
                        } else {
                          cityVal = false;
                        }

                        //dist
                        if (districtNameCtrl.text.isEmpty) {
                          districtVal = true;
                        } else {
                          districtVal = false;
                        }

                        //pin
                        if (pinCodeCtrl.text.isEmpty ||
                            pinCodeCtrl.text.length < 6) {
                          pincodeVal = true;
                        } else {
                          pincodeVal = false;
                        }

                        print('Street no : ${streetNameCtrl.text}\n'
                            'City : ${cityNameCtrl.text}\n'
                            'District : ${districtNameCtrl.text}\n'
                            'Pincode : ${pinCodeCtrl.text}\n');

                        if (streetNameCtrl.text.isNotEmpty &&
                            cityNameCtrl.text.isNotEmpty &&
                            districtNameCtrl.text.isNotEmpty &&
                            pinCodeCtrl.text.isNotEmpty) {
                          saveNewAddress(streetNameCtrl.text, cityNameCtrl.text,
                              districtNameCtrl.text, pinCodeCtrl.text);
                        }
                      });
                    },
                    child: Text(
                      'Save',
                      style:
                          TextStyle(color: Colors.green, fontFamily: "Poppins"),
                    )),
              ],
            );
          });
        });
  }

  //Order confirmation dialog**************use lesss*********
  void showOrderConfirmSheet() {
    int count = counts;
    int itemPrice = int.parse(cakePrice);
    int cakesPrice = 0;
    int deliverCharge = 0;
    int tax = 0;
    int totalAmt = 0;
    int afterdiscount = 0;
    int additionals = 0;

    String fixflavour = '';
    String fixshape = '';
    String fixtopings = '';
    String fixweight = '';

    if (fixedFlavour.isEmpty) {
      setState(() {
        if (flavour.isNotEmpty) {
          setState(() {
            fixflavour = fixedFlavour.split("-").first.toString();
            flavExtraCharge = int.parse(
                    fixflavour.replaceAll(new RegExp(r'[^0-9]'), ''),
                    onError: (e) => 0) +
                articleExtraCharge;
            additionals = flavExtraCharge;
          });
        } else {
          setState(() {
            fixflavour = fixedFlavour.split("-").first.toString();
            flavExtraCharge = int.parse(
                    fixflavour.replaceAll(new RegExp(r'[^0-9]'), ''),
                    onError: (e) => 0) +
                articleExtraCharge;
            additionals = flavExtraCharge;
          });
        }
      });
    } else {
      setState(() {
        fixflavour = fixedFlavour;
        flavExtraCharge = int.parse(
                fixflavour.replaceAll(new RegExp(r'[^0-9]'), ''),
                onError: (e) => 0) +
            articleExtraCharge;
        additionals = flavExtraCharge;
      });
    }

    if (fixedShape.isEmpty) {
      setState(() {
        if (shapes.isNotEmpty) {
          fixshape = shapes[0].toString();
        } else {
          fixshape = 'None';
        }
      });
    } else {
      setState(() {
        fixshape = fixedShape;
      });
    }

    if (fixedWeight.isEmpty) {
      setState(() {
        if (weight.isNotEmpty) {
          fixweight = weight[0].toString();
        } else {
          fixweight = 'None';
        }
      });
    } else {
      setState(() {
        fixweight = fixedWeight;
      });
    }

    if (fixedToppings.isEmpty) {
      setState(() {
        fixtopings = 'None';
      });
    } else {
      setState(() {
        fixtopings = "${fixedToppings.length}+ Toppings";
      });
    }

    if (iamYourVendor == true) {
      setState(() {
        deliveryCharge = int.parse(
            myVendorDelCharge.replaceAll(new RegExp(r'[^0-9]'), ''),
            onError: (e) => 0);
      });
    } else {
      setState(() {
        deliveryCharge = int.parse(
            cakeDeliverCharge.replaceAll(new RegExp(r'[^0-9]'), ''),
            onError: (e) => 0);
      });
    }

    int discount =
        int.parse(cakeDiscounts.replaceAll(new RegExp(r'[^0-9]'), ''));
    print('discounts $discount');

    setState(() {
      afterdiscount = (itemPrice / 100 * discount).toInt();
    });
    print('after dis total : $afterdiscount');

    setState(() {
      cakesPrice = itemPrice - afterdiscount.toInt();
      totalAmt = additionals + cakesPrice + deliverCharge;
      tax = (totalAmt * taxes / 100).toInt();
      totalAmt = additionals + cakesPrice + deliverCharge + tax;
      print('Bill total : $cakesPrice');
      print('Tax total : $tax');
    });

    showModalBottomSheet<dynamic>(
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        context: context,
        builder: (context) {
          return StatefulBuilder(builder:
              (BuildContext context, void Function(void Function()) setState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20), color: Colors.white),
              padding: EdgeInsets.all(10),
              margin: EdgeInsets.only(bottom: 35, left: 15, right: 15),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 5,
                  ),
                  //Title text...
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'ORDER CONFIRM',
                        style: TextStyle(
                            color: darkBlue,
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
                    color: lightPink,
                    height: 0.5,
                    width: double.infinity,
                  ),
                  Container(
                    height: 450,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            trailing: Text(
                              '₹ $cakePrice',
                              style: TextStyle(
                                fontSize: 15,
                                color: lightPink,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            title: Text(
                              '$cakeName',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontFamily: "Poppins",
                                  fontSize: 13,
                                  color: darkBlue,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                          ExpansionTile(
                            title: Text(
                              'Flavour , Shape etc..',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontFamily: poppins,
                                  color: darkBlue),
                            ),
                            children: [
                              Container(
                                padding: EdgeInsets.only(left: 15, right: 15),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Flavour',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontFamily: "Poppins",
                                        fontSize: 13,
                                      ),
                                    ),
                                    Text(
                                      fixedFlavour.isNotEmpty
                                          ? '${fixedFlavour.split('-').first.toString()}'
                                          : 'Default',
                                      style: TextStyle(
                                        color: darkBlue,
                                        fontFamily: "Poppins",
                                        fontSize: 15,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Container(
                                      color: Colors.grey,
                                      height: 0.5,
                                      width: double.infinity,
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      'Shape',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontFamily: "Poppins",
                                        fontSize: 13,
                                      ),
                                    ),
                                    Text(
                                      '$fixshape',
                                      style: TextStyle(
                                        color: darkBlue,
                                        fontFamily: "Poppins",
                                        fontSize: 15,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Container(
                                      color: Colors.grey,
                                      height: 0.5,
                                      width: double.infinity,
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      'Weight',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontFamily: "Poppins",
                                        fontSize: 13,
                                      ),
                                    ),
                                    Text(
                                      '$fixweight',
                                      style: TextStyle(
                                        color: darkBlue,
                                        fontFamily: "Poppins",
                                        fontSize: 15,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                          ExpansionTile(
                            title: Text(
                              'Delivery address & date etc...',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontFamily: poppins,
                                  color: darkBlue),
                            ),
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 15,
                                  ),
                                  Icon(
                                    Icons.calendar_today,
                                    color: lightPink,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    '$deliverDate',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontFamily: "Poppins",
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 15,
                                  ),
                                  Icon(
                                    CupertinoIcons.clock,
                                    color: lightPink,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    '$deliverSession',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontFamily: "Poppins",
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 15,
                                  ),
                                  Icon(
                                    Icons.home_outlined,
                                    color: lightPink,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Container(
                                    width: 250,
                                    child: Text(
                                      '$userAddress',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontFamily: "Poppins",
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 15,
                                  ),
                                  Icon(
                                    Icons.directions_bike_outlined,
                                    color: lightPink,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    '$fixedDelliverMethod',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontFamily: "Poppins",
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Container(
                            padding: EdgeInsets.only(left: 15, right: 15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Item count ($count)',
                                  style: TextStyle(
                                      color: darkBlue, fontFamily: "Poppins"),
                                ),
                                Row(
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          count++;
                                          setState(() {
                                            cakesPrice = itemPrice -
                                                afterdiscount.toInt();
                                            totalAmt = additionals +
                                                cakesPrice +
                                                deliverCharge +
                                                tax;
                                          });
                                        });
                                      },
                                      child: Row(
                                        children: [
                                          Container(
                                              height: 30,
                                              width: 30,
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: lightPink),
                                              child: Icon(
                                                Icons.add,
                                                color: Colors.white,
                                              ))
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          if (count > 1) {
                                            count = count - 1;
                                          }
                                        });
                                      },
                                      child: Row(
                                        children: [
                                          Container(
                                              height: 30,
                                              width: 30,
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: lightPink),
                                              child: Icon(
                                                Icons.remove,
                                                color: Colors.white,
                                              ))
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                          SizedBox(height: 10),
                          Container(
                            padding: EdgeInsets.only(left: 5, right: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(10),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Item Total',
                                        style: TextStyle(
                                          fontFamily: "Poppins",
                                          color: Colors.black54,
                                        ),
                                      ),
                                      RichText(
                                          text: TextSpan(text: '', children: [
                                        TextSpan(
                                          text: '₹ $cakePrice',
                                          style: TextStyle(
                                              color: Colors.grey,
                                              fontStyle: FontStyle.italic,
                                              fontWeight: FontWeight.normal,
                                              decoration:
                                                  TextDecoration.lineThrough),
                                        ),
                                        TextSpan(
                                          text: '  ₹ ${count * cakesPrice}',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: darkBlue),
                                        ),
                                      ]))
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      const Text(
                                        'Additional',
                                        style: const TextStyle(
                                          fontFamily: "Poppins",
                                          color: Colors.black54,
                                        ),
                                      ),
                                      Text(
                                        '₹${flavExtraCharge}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      const Text(
                                        'Delivery charge',
                                        style: const TextStyle(
                                          fontFamily: "Poppins",
                                          color: Colors.black54,
                                        ),
                                      ),
                                      Text(
                                        '₹${deliverCharge}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      const Text(
                                        'Discounts',
                                        style: const TextStyle(
                                          fontFamily: "Poppins",
                                          color: Colors.black54,
                                        ),
                                      ),
                                      Text(
                                        '${discount} %',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      // ₹
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      const Text(
                                        'Taxes',
                                        style: const TextStyle(
                                          fontFamily: "Poppins",
                                          color: Colors.black54,
                                        ),
                                      ),
                                      Text(
                                        '${taxes} %',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(
                                      left: 10, right: 10),
                                  color: Colors.black26,
                                  height: 1,
                                ),
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      const Text(
                                        'Bill Total',
                                        style: TextStyle(
                                            fontFamily: "Poppins",
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        '₹${count * totalAmt}',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                      child: Container(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            height: 50,
                            width: double.infinity,
                            margin: EdgeInsets.only(left: 6, right: 6),
                            child: RaisedButton(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30)),
                              color: lightPink,
                              onPressed: () {
                                // int itemCount = 0;
                                // int totalAmount = 0;
                                // int deliveryCharge = 0;
                                // int discounts = 0;
                                // int taxes = 0;
                                setState(() {
                                  totalAmount = count * totalAmt;
                                  itemCount = count * cakesPrice;
                                  deliveryCharge = deliverCharge;
                                  discounts = discount;
                                  taxes = taxes;
                                  counts = count;
                                });
                                loadOrderPreference();
                              },
                              child: Text(
                                'Confirm Checkout',
                                style: TextStyle(
                                    fontFamily: "Poppins", color: Colors.white),
                              ),
                            ),
                          )))
                ],
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

  //endregion

  //region FUNCTIONS

  //Session based on time...
  String session() {
    var timeNow = DateTime.now().hour;
    if (timeNow <= 12) {
      return "Morning";
    } else if ((timeNow > 12) && (timeNow <= 16)) {
      return "Afternoon";
    } else if ((timeNow > 16) && (timeNow < 20)) {
      return "Evening";
    } else {
      return "Night";
    }
  }

  //getting prfs from pre-screen
  Future<void> recieveDetailsFromScreen() async {
    //Local var
    var prefs = await SharedPreferences.getInstance();

    setState(() {
      //locations
      // userCurLocation = pref.getString('userCurrentLocation')??'Not Found';
      userMainLocation = prefs.getString('userMainLocation') ?? 'Not Found';

      //My selected vendor
      myVendorId = prefs.getString('myVendorId') ?? 'Not Found';
      myVendorName = prefs.getString('myVendorName') ?? 'Un Name';
      myVendorDelCharge = prefs.getString('myVendorDeliverChrg') ?? 'Un Name';
      myVendorProfile = prefs.getString('myVendorProfile') ?? 'Un Name';
      myVendorDesc = prefs.getString('myVendorDesc') ?? 'Un Name';
      vendorPhone = prefs.getString('myVendorPhone') ?? '0000000000';
      vendorAddress = prefs.getString('singleVendorAddress') ?? 'null';
      myVendorEgg = prefs.getString('myVendorEggs') ?? 'null';
      iamYourVendor = prefs.getBool('iamYourVendor') ?? false;
      vendorCakeMode = prefs.getBool('vendorCakeMode') ?? false;
      authToken = prefs.getString("authToken") ?? 'no auth';

      //Lists
      cakeImages = prefs.getStringList('cakeImages') ?? [];
      // flavour = prefs.getStringList('cakeFalvours') ?? [];
      // shapes = prefs.getStringList('cakeShapes') ?? [];
      topings = prefs.getStringList('cakeToppings') ?? [];
      weight = prefs.getStringList('cakeWeights') ?? [];

      //Strings
      cakeRatings = prefs.getString('cakeRatings') ?? '0.0';
      cakeEggorEgless = prefs.getString('cakeEggOrEggless') ?? 'Unknown';
      cakeName = prefs.getString('cakeNames') ?? 'Unknown';
      cakeId = prefs.getString('cakeId') ?? '0';
      cakeModId = prefs.getString('cakesmodId') ?? 'no';
      cakePrice = prefs.getString('cakePrice') ?? '0';
      cakeDescription =
          prefs.getString('cakeDescription') ?? 'No descriptions.';
      cakeType = prefs.getString('cakeType') ?? 'None';
      cakeDeliverCharge = prefs.getString('DeliveryCharge') ?? '';
      cakeDiscounts = prefs.getString('cakeDiscount') ?? '';
      taxes = prefs.getInt('cakeTaxRate') ?? 0;

      //user
      userPhone = prefs.getString("phoneNumber") ?? "";
      userID = prefs.getString("userID") ?? "";
      userModID = prefs.getString("userModId") ?? "";
      userName = prefs.getString("userName") ?? "";
      userAddress = prefs.getString('userAddress') ?? 'None';
      newRegUser = prefs.getBool('newRegUser') ?? false;

      //vendors
      vendorModID = prefs.getString('vendorsmodID') ?? 'no';
      // vendorAddress = prefs.getString('') ?? 'Unknown';
      // vendorMobileNum = prefs.getString('vendorMobile') ?? '0000000000';
      // vendorID = prefs.getString('vendorID') ?? 'Unknown';
      // vendorName = prefs.getString('vendorName') ?? 'Unknown';

      getCakesList();
    });
  }

  //***load prefs to ORDER.....***
  Future<void> loadOrderPreference() async {
    var prefs = await SharedPreferences.getInstance();

    setState(() {
      if (vendorName.isEmpty) {
        vendorName = nearestVendors[selVendorIndex]['VendorName'];
        vendorAddress =
            nearestVendors[selVendorIndex]['Address']['FullAddress'];
        vendorID = nearestVendors[selVendorIndex]['_id'];
        vendorPhone = nearestVendors[selVendorIndex]['PhoneNumber1'];
        vendorModID = nearestVendors[selVendorIndex]['Id'];
      }
    });

    print('*****removing....');

    prefs.remove('orderCakeID');
    prefs.remove('orderCakeModID');
    prefs.remove('orderCakeName');
    prefs.remove('orderCakeDescription');
    prefs.remove('orderCakeType');
    prefs.remove('orderCakeImages');
    prefs.remove('orderCakeEggOrEggless');
    prefs.remove('orderCakePrice');

    // prefs.remove('orderCakeFlavour',fixflavour.split("-").first.toString());

    prefs.remove('orderCakeShape');
    prefs.remove('orderCakeWeight');
    prefs.remove('orderCakeMessage');
    prefs.remove('orderCakeRequest');

    prefs.remove('orderCakeWeight');

    //vendor..
    prefs.remove('orderCakeVendorId');
    prefs.remove('orderCakeVendorModId');
    prefs.remove('orderCakeVendorName');
    prefs.remove('orderCakeVendorNum');
    prefs.remove('orderCakeVendorAddress');

    //user...
    prefs.remove('orderCakeUserName');
    prefs.remove('orderCakeUserID');
    prefs.remove('orderCakeUserModID');
    prefs.remove('orderCakeUserNum');
    prefs.remove('orderCakeDeliverAddress');
    prefs.remove('orderCakeDeliverDate');
    prefs.remove('orderCakeDeliverSession');
    prefs.remove('orderCakeDeliveryInformation');

    // prefs.remove('orderCakeArticle',fixedArticle);

    //for delivery...
    prefs.remove('orderCakeItemCount');
    prefs.remove('orderFromCustom');
    prefs.remove('orderCakeTotalAmt');
    prefs.remove('orderCakeDeliverAmt');
    prefs.remove('orderCakeDiscount');
    prefs.remove('orderCakeTaxes');
    prefs.remove('orderCakePaymentType');
    prefs.remove('orderCakePaymentStatus');
    prefs.remove('orderCakePaymentExtra');

    print('.....removed****');

    //endregion

    print(fixedFlavList);
    double flavCharge = 0.0;

    setState(() {
      if (fixedFlavList.isEmpty) {
        fixedFlavList = [
          {"Name": "Default Flavour", "Price": "0"}
        ];
      } else {
        fixedFlavList = fixedFlavList.toSet().toList();
      }

      // if(customweightCtrl.text.isEmpty&&fixedWeight.isEmpty){
      //   fixedWeight = "1kg";
      // }else{
      //   fixedWeight = "${customweightCtrl.text}kg";
      // }
    });

    print('Loading....');

    prefs.setString('orderCakeID', cakeId);
    prefs.setString('orderFromCustom', "no");
    prefs.setString('orderCakeModID', cakeModId);
    prefs.setString('orderCakeName', cakeName);
    prefs.setString('orderCakeDescription', cakeDescription);
    prefs.setString('orderCakeType', cakeType);
    prefs.setString('orderCakeImages', cakeImages[0].toString());
    prefs.setString('orderCakeEggOrEggless', cakeEggorEgless);
    prefs.setString(
        'orderCakePrice', cakePrice.replaceAll(new RegExp(r'[^0-9]'), ''));

    // prefs.setString('orderCakeFlavour',fixflavour.split("-").first.toString());

    prefs.setString(
        'orderCakeShape', fixedShape.isEmpty ? "${shapes[0]}" : '$fixedShape');
    prefs.setString('orderCakeWeight',
        fixedWeight == "0.0" ? '${weight[0]}' : "$fixedWeight");

    if (messageCtrl.text.isNotEmpty) {
      prefs.setString('orderCakeMessage', messageCtrl.text.toString());
    } else {
      prefs.setString('orderCakeMessage', 'No message');
    }

    if (specialReqCtrl.text.isNotEmpty) {
      prefs.setString('orderCakeRequest', specialReqCtrl.text.toString());
    } else {
      prefs.setString('orderCakeRequest', 'No special requests');
    }

    prefs.setString('orderCakeWeight', fixedWeight);

    //vendor..
    prefs.setString('orderCakeVendorId', vendorID);
    prefs.setString('orderCakeVendorModId', vendorModID);
    prefs.setString('orderCakeVendorName', vendorName);
    prefs.setString('orderCakeVendorNum', vendorMobileNum);
    prefs.setString('orderCakeVendorAddress', vendorAddress);

    //user...
    prefs.setString('orderCakeUserName', userName);
    prefs.setString('orderCakeUserID', userID);
    prefs.setString('orderCakeUserModID', userModID);
    prefs.setString('orderCakeUserNum', userPhone);
    prefs.setString('orderCakeDeliverAddress', userAddress);
    prefs.setString('orderCakeDeliverDate', deliverDate);
    prefs.setString('orderCakeDeliverSession', deliverSession);
    prefs.setString('orderCakeDeliveryInformation', fixedDelliverMethod);

    // prefs.setString('orderCakeArticle',fixedArticle);

    //for delivery...
    prefs.setInt('orderCakeItemCount', counts);
    prefs.setInt('orderCakeTotalAmt', totalAmount);
    prefs.setInt(
        'orderCakeDeliverAmt', fixedDelliverMethod == "Pickup" ? 0 : 50);
    prefs.setInt('orderCakeDiscount', discounts);
    prefs.setInt('orderCakeTaxes', taxes);
    prefs.setString('orderCakePaymentType', 'none');
    prefs.setString('orderCakePaymentStatus', 'none');

    // print(int.parse(fixedWeight.replaceAll("kg", "")));

    if (fixedFlavList.isNotEmpty) {
      for (int i = 0; i < fixedFlavList.length; i++) {
        setState(() {
          flavCharge = double.parse(fixedWeight.replaceAll("kg", "")) *
              (flavCharge + double.parse('${fixedFlavList[i]['Price']}'));
        });
      }

      print(double.parse(fixedWeight.replaceAll("kg", "")));
      print('flav charge :  $flavCharge');

      if (flavCharge == 0.0 && articleExtraCharge == 0) {
        prefs.setString('orderCakePaymentExtra', "0.0");
      } else {
        prefs.setString(
            'orderCakePaymentExtra', "${(flavCharge + articleExtraCharge)}");
      }
    }

    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => OrderConfirm(
            flav: fixedFlavList,
            artic: [
              {"Name": '$fixedArticle', "Price": '$articleExtraCharge'}
            ].toList()),
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

    print('Loaded....');
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
      print(
          'Location permissions are permanently denied, we cannot request permissions.');
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  //add new address
  Future<void> saveNewAddress(
      String street, String city, String district, String pincode) async {
    setState(() {
      userAddress = "$street , $city , $district , $pincode";
    });

    Navigator.pop(context);
  }

  //get vendorsList
  Future<void> getVendorsList() async {
    print("begin...");

    var res = await http.get(
        Uri.parse("https://cakey-database.vercel.app/api/vendors/list"),
        headers: {"Authorization": "$authToken"});

    if (res.statusCode == 200) {
      // getCakesList();
      setState(() {
        List vendorsList = jsonDecode(res.body);

        // for(int i = 0; i<vendorsList.length;i++){
        //   if(vendorsList[i]['Address']!=null&&vendorsList[i]['Address']['City']!=null&&
        //       vendorsList[i]['Address']['City'].toString().toLowerCase()==userMainLocation.toLowerCase()){
        //     print('found .... $i');
        //     setState(() {
        //       nearestVendors.add(vendorsList[i]);
        //     });
        //   }
        // }

        for (int i = 0; i < vendorsList.length; i++) {
          // print(cakesList[i]['VendorName'] + "Id" + cakesList[i]['_id']);

          for (int j = 0; j < cakesList.length; j++) {
            if (vendorsList[i]['_id'].toString() ==
                cakesList[j]['VendorID'].toString()) {
              // print('yesss... $i $j');
              setState(() {
                nearestVendors.add(vendorsList[i]);
              });
            } else {
              // print('nooo... $i $j');
            }
          }
        }
      });
    } else {}
    print("...end");
  }

  //getAllcakes List
  Future<void> getCakesList() async {
    showAlertDialog();
    var res = await http.get(
        Uri.parse('https://cakey-database.vercel.app/api/cake/list'),
        headers: {"Authorization": "$authToken"});

    if (res.statusCode == 200) {
      setState(() {
        myCakesList = jsonDecode(res.body);
        cakesList = myCakesList
            .where((element) =>
                element['Title'].toString().contains(cakeName.toString()))
            .toList();

        getVendorsList();
        Navigator.pop(context);
      });
    } else {
      Navigator.pop(context);
    }
  }

  //endregion

  //region PGDots
  //Indecator pageview
  Widget _indicator(bool isActive) {
    return AnimatedContainer(
      duration: Duration(seconds: 1),
      curve: Curves.linear,
      height: 10,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.0),
        height: isActive ? 10 : 8.0,
        width: isActive ? 12 : 8.0,
        decoration: BoxDecoration(
          boxShadow: [
            isActive
                ? BoxShadow(
                    color: Color(0XFF2FB7B2).withOpacity(0.72),
                    blurRadius: 4.0,
                    spreadRadius: 1.0,
                    offset: Offset(
                      0.0,
                      0.0,
                    ),
                  )
                : BoxShadow(
                    color: Colors.transparent,
                  )
          ],
          shape: BoxShape.circle,
          color: isActive ? lightPink : Color(0XFFEAEAEA),
        ),
      ),
    );
  }

  //Buliding the dots by image length
  List<Widget> _buildPageIndicator() {
    List<Widget> list = [];
    for (int i = 0; i < cakeImages.length; i++) {
      list.add(i == pageViewCurIndex ? _indicator(true) : _indicator(false));
    }
    return list;
  }

  Future<void> removeMyVendorPref() async {
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

  //endregion

  // @override
  // void dispose() {
  //   // TODO: implement dispose
  //   Future.delayed(Duration.zero , () async{
  //     removeMyVendorPref();
  //   });
  //   context.read<ContextData>().setMyVendors([]);
  //   context.read<ContextData>().addMyVendor(false);
  //   super.dispose();
  // }

  @override
  void initState() {
    // TODO: implement initState
    recieveDetailsFromScreen();
    // session();
    // setState((){
    //   deliverSession = session();
    // });
    // context.read<ContextData>().setMyVendors([]);
    // context.read<ContextData>().addMyVendor(false);
    flavour.insert(0, {"Name": "Default Flavour", "Price": "0"});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    profileUrl = context.watch<ContextData>().getProfileUrl();
    iamYourVendor = context.watch<ContextData>().getAddedMyVendor();
    mySelVendors = context.watch<ContextData>().getMyVendorsList();
    if (context.watch<ContextData>().getAddress().isNotEmpty) {
      userAddress = context.watch<ContextData>().getAddress();
    } else {
      userAddress = userAddress;
    }

    return WillPopScope(
      onWillPop: () async {
        setState(() {
          // if(vendorCakeMode==true){
          //   print('VendorCakeMode : $vendorCakeMode');
          // }else{
          //   print('VendorCakeMode : false');
          //   context.read<ContextData>().setMyVendors([]);
          //   context.read<ContextData>().addMyVendor(false);
          // }
        });
        return true;
      },
      child: Scaffold(
        body: SafeArea(
          child: NestedScrollView(
              headerSliverBuilder:
                  (BuildContext context, bool innerBoxIsScrolled) {
                return <Widget>[
                  SliverAppBar(
                    title: innerBoxIsScrolled
                        ? Text(
                            "$cakeName",
                            style: TextStyle(color: darkBlue),
                          )
                        : Text(""),
                    expandedHeight: 300.0,
                    leading: Container(
                      margin: const EdgeInsets.all(10),
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          context.read<ContextData>().setMyVendors([]);
                          context.read<ContextData>().addMyVendor(false);
                        },
                        child: Container(
                          height: 30,
                          decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(7)
                          ),
                          alignment: Alignment.center,
                          child: Icon(Icons.chevron_left,size: 30,color: lightPink,),
                        ),
                      ),
                    ),
                    // forceElevated: innerBoxIsScrolled,
                    //floating: true,
                    pinned: true,
                    floating: true,
                    actions: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          InkWell(
                            onTap: () {
                              print("Scrolled $innerBoxIsScrolled");

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
                              alignment: Alignment.center,
                              height: 35,
                              width: 35,
                              decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(8)),
                              child: Icon(
                                Icons.notifications_none,
                                color: darkBlue,
                              ),
                            ),
                          ),
                          Positioned(
                            left: 20,
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
                                  radius: 17.5,
                                  backgroundColor: Colors.white,
                                  child: CircleAvatar(
                                      radius: 16,
                                      backgroundImage:
                                          NetworkImage("$profileUrl")),
                                )
                              : CircleAvatar(
                                  radius: 17.5,
                                  backgroundColor: Colors.white,
                                  child: CircleAvatar(
                                      radius: 16,
                                      backgroundImage:
                                          AssetImage("assets/images/user.png")),
                                ),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                    ],
                    backgroundColor: lightGrey,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Container(
                        margin: EdgeInsets.all(7),
                        height: 250,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.black12,
                        ),
                        child: cakeImages.length != 0
                            ? StatefulBuilder(builder: (BuildContext context,
                                void Function(void Function()) setState) {
                                return Stack(children: [
                                  PageView.builder(
                                      itemCount: cakeImages.length,
                                      onPageChanged: (int i) {
                                        setState(() {
                                          pageViewCurIndex = i;
                                        });
                                      },
                                      itemBuilder: (context, index) {
                                        return Container(
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              color: Colors.black12,
                                              image: DecorationImage(
                                                  image: NetworkImage(
                                                      "${cakeImages[index]}"),
                                                  fit: BoxFit.cover)),
                                        );
                                      }),
                                  Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: _buildPageIndicator(),
                                        ),
                                        SizedBox(
                                          height: 15,
                                        )
                                      ],
                                    ),
                                  ),
                                ]);
                              })
                            : Center(
                                child: Text(
                                'No Images Found!',
                                style: TextStyle(
                                    fontFamily: "Poppins",
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: darkBlue),
                              )),
                        width: double.infinity,
                      ),
                    ),
                  ),
                ];
              },
              body: SingleChildScrollView(
                // controller: myScrollCtrl,
                // physics: BouncingScrollPhysics(),
                child: SafeArea(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: EdgeInsets.only(left: 20, right: 20, top: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  RatingBar.builder(
                                    initialRating:
                                        double.parse(cakeRatings, (e) => 1.5),
                                    minRating: 1,
                                    direction: Axis.horizontal,
                                    allowHalfRating: true,
                                    itemCount: 5,
                                    itemSize: 15,
                                    itemPadding:
                                        EdgeInsets.symmetric(horizontal: 1.0),
                                    itemBuilder: (context, _) => Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                    ),
                                    onRatingUpdate: (rating) {
                                      print(rating);
                                    },
                                  ),
                                  Container(
                                    padding: EdgeInsets.only(left: 5),
                                    child: (cakeRatings != null)
                                        ? (cakeRatings != 'null')
                                            ? Text(
                                                ' $cakeRatings',
                                                style: TextStyle(
                                                    color: Colors.black54,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 13,
                                                    fontFamily: poppins),
                                              )
                                            : Text('3.5',
                                                style: TextStyle(
                                                    color: Colors.black54,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 13,
                                                    fontFamily: poppins))
                                        : Text(cakeRatings),
                                  )
                                ],
                              ),
                              Row(
                                children: [
                                  Transform.rotate(
                                    angle: 120,
                                    child: Icon(
                                      Icons.egg_outlined,
                                      color: Colors.amber,
                                    ),
                                  ),
                                  Text(
                                    '$cakeEggorEgless',
                                    style: TextStyle(
                                        color: Colors.amber,
                                        fontFamily: poppins,
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold),
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                        Container(
                            margin: EdgeInsets.symmetric(horizontal: 15),
                            child: Divider(
                              color: Colors.pink[100],
                            )),
                        Container(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          child: Text(
                            '${cakeName}',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontFamily: "Poppins",
                                fontSize: 18,
                                color: darkBlue,
                                fontWeight: FontWeight.w600),
                          ),
                        ),

                        Container(
                            padding: EdgeInsets.only(left: 10, right: 10),
                            alignment: Alignment.bottomLeft,
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    alignment: Alignment.bottomLeft,
                                    child: Row(children: [
                                      Text(
                                        '₹',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        "${(articleExtraCharge + (double.parse(fixedWeight.replaceAll("kg", "")) * addedFlavPrice) + (int.parse(cakePrice, onError: (e) => 0)) * counts)}",
                                        style: TextStyle(
                                          color: lightPink,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 23,
                                        ),
                                      ),
                                    ]),
                                  ),
                                  //increase decrease
                                  Row(children: [
                                    //decrease
                                    InkWell(
                                      splashColor: Colors.red[200]!,
                                      onTap: () {
                                        if (counts > 1) {
                                          setState(() {
                                            counts = counts - 1;
                                          });
                                        }
                                      },
                                      child: Container(
                                          height: 30,
                                          width: 30,
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: Colors.pink[400]!,
                                                width: 0.5,
                                              )),
                                          child: Icon(Icons.remove_sharp,
                                              color: darkBlue)),
                                    ),
                                    SizedBox(width: 8),
                                    Column(
                                      children: [
                                        Text(
                                          '${counts}',
                                          style: TextStyle(
                                            color: lightPink,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: "Poppins",
                                            fontSize: 20,
                                          ),
                                        ),
                                        Text(
                                          'UNIT',
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: "Poppins",
                                            fontSize: 10,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(width: 8),
                                    InkWell(
                                      splashColor: Colors.red[200]!,
                                      onTap: () {
                                        setState(() {
                                          counts++;
                                        });
                                      },
                                      child: Container(
                                          height: 30,
                                          width: 30,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: Colors.pink[400]!,
                                                width: 0.5,
                                              )),
                                          child:
                                              Icon(Icons.add, color: darkBlue)),
                                    ),
                                  ])
                                ])),

                        Container(
                            margin: EdgeInsets.all(10),
                            child: ExpandableText(
                              "$cakeDescription",
                              expandText: "",
                              collapseText: "collapse",
                              expandOnTextTap: true,
                              collapseOnTextTap: true,
                              style: TextStyle(
                                  color: Colors.grey, fontFamily: "Poppins"),
                            )),

                        Container(
                            margin: EdgeInsets.symmetric(horizontal: 15),
                            child: Divider(
                              color: Colors.pink[100],
                            )),

                        //Flavours and shapes
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Container(
                            margin: EdgeInsets.only(left: 15, right: 15),
                            width: MediaQuery.of(context).size.width,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Flavours',
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                          fontFamily: "Poppins"),
                                    ),
                                    SizedBox(
                                      height: 2,
                                    ),
                                    fixedFlavList.isEmpty
                                        ? Text(
                                            'Default Flavour',
                                            style: TextStyle(
                                                fontFamily: "Poppins",
                                                color: darkBlue,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600),
                                          )
                                        : Text(
                                            '${fixedFlavour}',
                                            style: TextStyle(
                                                color: darkBlue,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                fontFamily: "Poppins"),
                                          )
                                  ],
                                ),
                                Expanded(child: Container()),
                                Container(
                                  height: 45,
                                  width: 1,
                                  color: Colors.pink[100],
                                ),
                                SizedBox(
                                  width: 25,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Shapes',
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                          fontFamily: "Poppins"),
                                    ),
                                    SizedBox(
                                      height: 2,
                                    ),
                                    fixedShape.isEmpty
                                        ? Text(
                                            shapes.isEmpty
                                                ? 'None'
                                                : '${shapes[0]}',
                                            style: TextStyle(
                                                color: darkBlue,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                fontFamily: "Poppins"),
                                          )
                                        : Text(
                                            '$fixedShape',
                                            style: TextStyle(
                                                color: darkBlue,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                fontFamily: "Poppins"),
                                          )
                                  ],
                                ),
                                Expanded(child: Container()),
                              ],
                            ),
                          ),
                        ),
                        

                        Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: 15, vertical: 10),
                          padding: EdgeInsets.all(12),
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                              color: Colors.red[50],
                              borderRadius: BorderRadius.circular(10)),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Theme',
                                    style: TextStyle(fontFamily: "Poppins"),
                                  ),
                                  fixedtheme.isNotEmpty
                                      ? GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              fixedtheme = "";
                                            });
                                          },
                                          child: Container(
                                            width: 100,
                                            alignment: Alignment.center,
                                            margin: EdgeInsets.only(right: 100),
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 3),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              color: lightPink,
                                            ),
                                            child: Wrap(
                                              children: [
                                                Text(
                                                  '${fixedtheme}',
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      fontFamily: "Poppins",
                                                      fontSize: 9,
                                                      color: Colors.white),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      : Container(),
                                  fixedtheme.isEmpty
                                      ? GestureDetector(
                                          onTap: () {
                                            showThemeBottomSheet();
                                          },
                                          child: Container(
                                            width: 30,
                                            height: 30,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  BoxShadow(
                                                      blurRadius: 3,
                                                      color: Colors.black26,
                                                      spreadRadius: 1)
                                                ],
                                                color: Colors.white),
                                            child: Icon(
                                              Icons.add,
                                              color: darkBlue,
                                            ),
                                          ),
                                        )
                                      : CircleAvatar(
                                          radius: 15,
                                          backgroundColor: Colors.green,
                                          child: Icon(
                                            Icons.check,
                                            color: Colors.white,
                                            size: 16,
                                          )),
                                ],
                              ),
                              SizedBox(height: 6),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Flavours',
                                    style: TextStyle(fontFamily: "Poppins"),
                                  ),
                                  fixedFlavour != ""
                                      ? GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              fixedFlavour = "";
                                              fixedFlavList.clear();
                                              multiFlavChecs.clear();
                                              addedFlavPrice = 0;
                                              temp.clear();
                                            });
                                          },
                                          child: Container(
                                            alignment: Alignment.center,
                                            margin: EdgeInsets.only(right: 120),
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 3),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(17),
                                              color: lightPink,
                                            ),
                                            child: Text(
                                              '${fixedFlavour}',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  fontFamily: "Poppins",
                                                  fontSize: 9,
                                                  color: Colors.white),
                                            ),
                                          ),
                                        )
                                      : Container(),
                                  fixedFlavour.isEmpty
                                      ? GestureDetector(
                                          onTap: () {
                                            showCakeFlavSheet();
                                          },
                                          child: Container(
                                            width: 30,
                                            height: 30,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  BoxShadow(
                                                      blurRadius: 3,
                                                      color: Colors.black26,
                                                      spreadRadius: 1)
                                                ],
                                                color: Colors.white),
                                            child: Icon(
                                              Icons.add,
                                              color: darkBlue,
                                            ),
                                          ),
                                        )
                                      : CircleAvatar(
                                          radius: 15,
                                          backgroundColor: Colors.green,
                                          child: Icon(
                                            Icons.check,
                                            color: Colors.white,
                                            size: 16,
                                          )),
                                ],
                              ),
                              SizedBox(height: 6),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Shapes',
                                    style: TextStyle(fontFamily: "Poppins"),
                                  ),
                                  fixedShape.isNotEmpty
                                      ? GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              fixedShape = "";
                                            });
                                          },
                                          child: Container(
                                            alignment: Alignment.center,
                                            margin: EdgeInsets.only(right: 150),
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 3),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              color: lightPink,
                                            ),
                                            child: Wrap(
                                              children: [
                                                Text(
                                                  '${fixedShape}',
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      fontFamily: "Poppins",
                                                      fontSize: 9,
                                                      color: Colors.white),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      : Container(),
                                  fixedShape.isEmpty
                                      ? GestureDetector(
                                          onTap: () {
                                            showCakeShapesSheet();
                                          },
                                          child: Container(
                                            width: 30,
                                            height: 30,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  BoxShadow(
                                                      blurRadius: 3,
                                                      color: Colors.black26,
                                                      spreadRadius: 1)
                                                ],
                                                color: Colors.white),
                                            child: Icon(
                                              Icons.add,
                                              color: darkBlue,
                                            ),
                                          ),
                                        )
                                      : CircleAvatar(
                                          radius: 15,
                                          backgroundColor: Colors.green,
                                          child: Icon(
                                            Icons.check,
                                            color: Colors.white,
                                            size: 16,
                                          )),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 10.0, bottom: 5, left: 15),
                          child: Text(
                            'Weight',
                            style: TextStyle(
                                color: darkBlue, fontFamily: "Poppins"),
                          ),
                        ),
                        Container(
                            height: MediaQuery.of(context).size.height * 0.057,
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
                                          FocusScope.of(context).unfocus();
                                          if (customweightCtrl
                                              .text.isNotEmpty) {
                                            customweightCtrl.text = "";
                                            weightIndex = index;
                                            fixedWeight = weight[index];
                                          } else {
                                            weightIndex = index;
                                            fixedWeight =
                                                weight[index].toString();
                                            print(fixedWeight);
                                          }
                                        });
                                      },
                                      child: Container(
                                        alignment: Alignment.center,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 13),
                                        // height:10,
                                        margin: EdgeInsets.only(
                                            left: 9, top: 9, bottom: 9),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            border: Border.all(
                                                color: lightPink, width: 1),
                                            color: weightIndex == index
                                                ? Colors.pink
                                                : Colors.white),
                                        child: Text(
                                          weight[index],
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontFamily: poppins,
                                            color: weightIndex == index
                                                ? Colors.white
                                                : darkBlue,
                                            fontSize: 13.5,
                                          ),
                                        ),
                                      )
                                      //
                                      // Container(
                                      //   width: 60,
                                      //   alignment: Alignment.center,
                                      //   margin: EdgeInsets.all(5),
                                      //   decoration: BoxDecoration(
                                      //       borderRadius: BorderRadius.circular(20),
                                      //       border: Border.all(
                                      //         color: lightPink,
                                      //         width: 1,
                                      //       ),
                                      //       color: weightIndex==index
                                      //           ? Colors.pink
                                      //           : Colors.white),
                                      //   child: Text(
                                      //     weight[index],
                                      //     style: TextStyle(
                                      //         fontWeight: FontWeight.bold,
                                      //         fontSize: 13,
                                      //         fontFamily: poppins,
                                      //         color: weightIndex==index
                                      //             ? Colors.white
                                      //             : darkBlue
                                      //     ),
                                      //   ),
                                      // ),
                                      );
                                })),
                        Padding(
                          padding: const EdgeInsets.only(left: 15.0, top: 5),
                          child: Text(
                            'Enter Weight',
                            style:
                                TextStyle(fontFamily: poppins, color: darkBlue),
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Container(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 15,
                              ),
                              Icon(
                                Icons.scale_outlined,
                                color: lightPink,
                              ),
                              Expanded(
                                child: Container(
                                  margin: EdgeInsets.symmetric(horizontal: 10),
                                  child: TextField(
                                    keyboardType: TextInputType.number,
                                    textInputAction: TextInputAction.next,
                                    controller: customweightCtrl,
                                    style: TextStyle(
                                        fontFamily: 'Poppins', fontSize: 13),
                                    inputFormatters: <TextInputFormatter>[
                                      FilteringTextInputFormatter.allow(
                                          new RegExp('[1-9.]'))
                                    ],
                                    onChanged: (String text) {
                                      setState(() {
                                        if (text.isNotEmpty) {
                                          if (weightIndex != -1) {
                                            weightIndex = -1;
                                            fixedWeight = text;
                                            try {
                                              print(double.parse(
                                                  customweightCtrl.text));
                                            } catch (e) {
                                              print(e);
                                            }
                                          }
                                        } else {
                                          weightIndex = 0;
                                          fixedWeight = weight[0].toString();
                                        }
                                      });
                                    },
                                    onSubmitted: (String text) {
                                      if (text.isNotEmpty) {
                                        if (weightIndex != -1) {
                                          weightIndex = -1;
                                          fixedWeight = text;
                                          try {
                                            print(double.parse(
                                                customweightCtrl.text));
                                          } catch (e) {
                                            print(e);
                                          }
                                        }
                                      } else {
                                        weightIndex = 0;
                                        fixedWeight = weight[0].toString();
                                      }
                                    },
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.all(0.0),
                                      isDense: true,
                                      constraints: BoxConstraints(minHeight: 5),
                                      hintText: 'Type here..',
                                      hintStyle: TextStyle(
                                          fontFamily: 'Poppins', fontSize: 13),
                                      // border: InputBorder.none
                                    ),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                child: Container(
                                    padding: EdgeInsets.all(4),
                                    margin: EdgeInsets.only(right: 10),
                                    decoration: BoxDecoration(
                                        color: Colors.grey[300]!,
                                        borderRadius: BorderRadius.circular(5)),
                                    child: PopupMenuButton(
                                        child: Row(
                                          children: [
                                            Text('$selectedDropWeight',
                                                style: TextStyle(
                                                    color: darkBlue,
                                                    fontFamily: 'Poppins')),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Icon(Icons.keyboard_arrow_down,
                                                color: darkBlue)
                                          ],
                                        ),
                                        itemBuilder: (context) => [
                                              PopupMenuItem(
                                                  onTap: () {
                                                    setState(() {
                                                      selectedDropWeight = "Kg";
                                                    });
                                                  },
                                                  child: Text('Kilo Gram',style: TextStyle(
                                                    fontFamily: "Poppins"
                                                  ),)
                                              ),
                                              // PopupMenuItem(
                                              //     onTap: () {
                                              //       setState(() {
                                              //         selectedDropWeight = "Ib";
                                              //       });
                                              //     },
                                              //     child: Text('Pounds')),
                                              // PopupMenuItem(
                                              //     onTap: () {
                                              //       setState(() {
                                              //         selectedDropWeight = "G";
                                              //       });
                                              //     },
                                              //     child: Text('Gram')),
                                            ])),
                              )
                            ],
                          ),
                        ),
                        Container(
                            margin: EdgeInsets.symmetric(horizontal: 15),
                            child: Divider(
                              color: Colors.pink[100],
                            )),
                        Container(
                            //margin
                            margin: EdgeInsets.all(10),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ' Message on the cake',
                                  style: TextStyle(
                                      fontFamily: poppins, color: darkBlue),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Container(
                                  child: Column(
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            width: 8,
                                          ),
                                          Icon(
                                            Icons.message_outlined,
                                            color: lightPink,
                                          ),
                                          Expanded(
                                            child: Container(
                                              margin: EdgeInsets.symmetric(
                                                  horizontal: 10),
                                              child: TextField(
                                                controller: messageCtrl,
                                                style: TextStyle(
                                                    fontFamily: 'Poppins',
                                                    fontSize: 13),
                                                decoration: InputDecoration(
                                                  hintText: 'Type here..',
                                                  contentPadding:
                                                      EdgeInsets.all(0.0),
                                                  isDense: true,
                                                  hintStyle: TextStyle(
                                                      fontFamily: 'Poppins',
                                                      fontSize: 13),
                                                  // border: InputBorder.none
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                      // Container(
                                      //   margin: EdgeInsets.only(left: 40,right: 8),
                                      //   height: 0.5,
                                      //   color:Colors.black54,
                                      // ),
                                    ],
                                  ),
                                ),

                                //Articlessss
                                Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Text(
                                    ' Articles',
                                    style: TextStyle(
                                        fontFamily: "Poppins", color: darkBlue),
                                  ),
                                ),

                                Container(
                                    child: ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: articals.length,
                                  itemBuilder: (context, index) {
                                    return InkWell(
                                      onTap: () {
                                        setState(() {
                                          if (articGroupVal == index) {
                                            articGroupVal = -1;
                                            fixedArticle = 'None';
                                            articleExtraCharge = 0;
                                          } else {
                                            articGroupVal = index;
                                            fixedArticle = articals[index]
                                                    ['Name']
                                                .toString();
                                            articleExtraCharge = int.parse(
                                                articals[index]['Price']
                                                    .toString());
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(SnackBar(
                                              content: Text('Price Updated!'),
                                              duration: Duration(seconds: 2),
                                            ));
                                          }
                                        });
                                      },
                                      child: Container(
                                          padding: EdgeInsets.only(
                                              top: 5, bottom: 5, left: 8),
                                          child: Row(children: [
                                            articGroupVal != index
                                                ? Icon(
                                                    Icons
                                                        .radio_button_unchecked_rounded,
                                                    color: Colors.black)
                                                : Icon(
                                                    Icons.check_circle_rounded,
                                                    color: Colors.green),
                                            SizedBox(width: 6),
                                            Expanded(
                                                child: Text.rich(
                                                    TextSpan(children: [
                                              TextSpan(
                                                  text:
                                                      '${articals[index]['Name']} - ',
                                                  style: TextStyle(
                                                    color: Colors.grey,
                                                    fontFamily: "Poppins",
                                                  )),
                                              TextSpan(
                                                  text:
                                                      'Rs.${articals[index]['Price']}',
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontFamily: "Poppins",
                                                    fontWeight: FontWeight.bold,
                                                  ))
                                            ])))
                                          ])),
                                    );
                                  },
                                )),

                                Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Text(
                                    ' Special request to bakers',
                                    style: TextStyle(
                                        fontFamily: "Poppins", color: darkBlue),
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.all(10),
                                  child: TextField(
                                    style: TextStyle(
                                        fontFamily: 'Poppins', fontSize: 13),
                                    controller: specialReqCtrl,
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Colors.black12,
                                      hintText: 'Type here..',
                                      hintStyle: TextStyle(
                                          fontFamily: 'Poppins', fontSize: 13),
                                      border: OutlineInputBorder(
                                          borderSide: BorderSide.none,
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                    ),
                                    maxLines: 8,
                                    minLines: 5,
                                  ),
                                ),

                                Container(
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 15),
                                    child: Divider(
                                      color: Colors.pink[100],
                                    )),
                                Padding(
                                  padding: EdgeInsets.only(top: 10, left: 10),
                                  child: Text(
                                    'Delivery Information',
                                    style: TextStyle(
                                        fontFamily: poppins,
                                        color: darkBlue,
                                        fontSize: 15),
                                  ),
                                ),
                                Container(
                                    child: ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: picOrDeliver.length,
                                  itemBuilder: (context, index) {
                                    return InkWell(
                                      onTap: () {
                                        setState(() {
                                          for (int i = 0;
                                              i < picOrDel.length;
                                              i++) {
                                            if (i == index) {
                                              fixedDelliverMethod =
                                                  picOrDeliver[i];
                                              picOrDel[i] = true;
                                            } else {
                                              picOrDel[i] = false;
                                            }
                                          }
                                        });
                                      },
                                      child: Container(
                                        padding: EdgeInsets.only(
                                            top: 5, bottom: 5, left: 8),
                                        child: Row(children: [
                                          picOrDel[index] == false
                                              ? Icon(
                                                  Icons
                                                      .radio_button_unchecked_rounded,
                                                  color: Colors.black)
                                              : Icon(Icons.check_circle_rounded,
                                                  color: Colors.green),
                                          SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              '${picOrDeliver[index]}',
                                              style: TextStyle(
                                                  fontFamily: poppins,
                                                  color: Colors.black54,
                                                  fontSize: 13),
                                            ),
                                          )
                                        ]),
                                      ),
                                    );
                                  },
                                )),

                                Padding(
                                  padding: EdgeInsets.only(
                                      top: 10, left: 10, bottom: 5),
                                  child: Text(
                                    'Delivery Details',
                                    style: TextStyle(
                                        fontFamily: poppins,
                                        color: darkBlue,
                                        fontSize: 15),
                                  ),
                                ),

                                GestureDetector(
                                  onTap: () async {
                                    DateTime? SelDate = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      lastDate: DateTime(2100),
                                      firstDate: DateTime.now()
                                          .subtract(Duration(days: 0)),
                                    );

                                    setState(() {
                                      deliverDate = simplyFormat(
                                          time: SelDate, dateOnly: true);
                                    });

                                    // print(SelDate.toString());
                                    // print(DateTime.now().subtract(Duration(days: 0)));
                                  },
                                  child: Container(
                                      margin: EdgeInsets.all(5),
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                              color: Colors.grey[400]!,
                                              width: 0.5)),
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              '$deliverDate',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.grey,
                                                  fontSize: 13),
                                            ),
                                            Icon(Icons.date_range_outlined,
                                                color: darkBlue)
                                          ])),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20)),
                                            title:
                                                Text("Select delivery session",
                                                    style: TextStyle(
                                                      color: lightPink,
                                                      fontFamily: "Poppins",
                                                      fontSize: 16,
                                                    )),
                                            content: Container(
                                              height: 250,
                                              child: Scrollbar(
                                                isAlwaysShown: true,
                                                child: SingleChildScrollView(
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      PopupMenuItem(
                                                          child: Text(
                                                              'Morning 8 - 9'),
                                                          onTap: () {
                                                            setState(() {
                                                              deliverSession =
                                                                  'Morning 8 - 9';
                                                            });
                                                          }),
                                                      PopupMenuItem(
                                                          child: Text(
                                                              'Morning 9 - 10'),
                                                          onTap: () {
                                                            setState(() {
                                                              deliverSession =
                                                                  'Morning 9 - 10';
                                                            });
                                                          }),
                                                      PopupMenuItem(
                                                          child: Text(
                                                              'Morning 10 - 11'),
                                                          onTap: () {
                                                            setState(() {
                                                              deliverSession =
                                                                  'Morning 10 - 11';
                                                            });
                                                          }),
                                                      PopupMenuItem(
                                                          child: Text(
                                                              'Morning 11 - 12'),
                                                          onTap: () {
                                                            setState(() {
                                                              deliverSession =
                                                                  'Morning 11 - 12';
                                                            });
                                                          }),
                                                      PopupMenuItem(
                                                          child: Text(
                                                              'Afternoon 12 - 1'),
                                                          onTap: () {
                                                            setState(() {
                                                              deliverSession =
                                                                  'Afternoon 12 - 1';
                                                            });
                                                          }),
                                                      PopupMenuItem(
                                                          child: Text(
                                                              'Afternoon 1 - 2'),
                                                          onTap: () {
                                                            setState(() {
                                                              deliverSession =
                                                                  'Afternoon 1 - 9';
                                                            });
                                                          }),
                                                      PopupMenuItem(
                                                          child: Text(
                                                              'Afternoon 2 - 3'),
                                                          onTap: () {
                                                            setState(() {
                                                              deliverSession =
                                                                  'Afternoon 8 - 9';
                                                            });
                                                          }),
                                                      PopupMenuItem(
                                                          child: Text(
                                                              'Afternoon 3 - 4'),
                                                          onTap: () {
                                                            setState(() {
                                                              deliverSession =
                                                                  'Afternoon 3 - 4';
                                                            });
                                                          }),
                                                      PopupMenuItem(
                                                          child: Text(
                                                              'Afternoon 4 - 5'),
                                                          onTap: () {
                                                            setState(() {
                                                              deliverSession =
                                                                  'Afternoon 4 - 5';
                                                            });
                                                          }),
                                                      PopupMenuItem(
                                                          child: Text(
                                                              'Evening 5 - 6'),
                                                          onTap: () {
                                                            setState(() {
                                                              deliverSession =
                                                                  'Evening 5 - 6';
                                                            });
                                                          }),
                                                      PopupMenuItem(
                                                          child: Text(
                                                              'Evening 6 - 7'),
                                                          onTap: () {
                                                            setState(() {
                                                              deliverSession =
                                                                  'Evening 6 - 7';
                                                            });
                                                          }),
                                                      PopupMenuItem(
                                                          child: Text(
                                                              'Evening 7 - 8'),
                                                          onTap: () {
                                                            setState(() {
                                                              deliverSession =
                                                                  'Evening 7 - 8';
                                                            });
                                                          }),
                                                      PopupMenuItem(
                                                          child: Text(
                                                              'Evening 8 - 9'),
                                                          onTap: () {
                                                            setState(() {
                                                              deliverSession =
                                                                  'Evening 8 - 9';
                                                            });
                                                          }),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        });
                                  },
                                  child: Container(
                                      margin: EdgeInsets.all(5),
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                              color: Colors.grey[400]!,
                                              width: 0.5)),
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              '$deliverSession',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.grey,
                                                  fontSize: 13),
                                            ),
                                            Icon(Icons.keyboard_arrow_down,
                                                color: darkBlue)
                                          ])),
                                ),
                              ],
                            )),
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Text(
                            ' Address',
                            style:
                                TextStyle(fontFamily: poppins, color: darkBlue),
                          ),
                        ),
                        ListTile(
                          title: Text(
                            '$userAddress',
                            style: TextStyle(
                                fontFamily: poppins,
                                color: Colors.grey,
                                fontSize: 13),
                          ),
                          trailing:
                              Icon(Icons.check_circle, color: Colors.green),
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 10),
                          alignment: Alignment.centerLeft,
                          child: TextButton(
                              onPressed: () {
                                // showAddAddressAlert();
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => AddressScreen()));
                              },
                              child: const Text(
                                'add new address',
                                style: const TextStyle(
                                    color: Colors.orange,
                                    fontFamily: "Poppins",
                                    decoration: TextDecoration.underline),
                              )),
                        ),
                        SizedBox(
                          height: 15,
                        ),

                        Container(
                          padding: EdgeInsets.all(10.0),
                          color: Colors.black12,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              //below 5 kg ui
                              nearestVendors.isNotEmpty
                                  ? Column(
                                      children: [
                                        customweightCtrl.text.isEmpty ||
                                                double.parse(
                                                        customweightCtrl.text) <
                                                    6.0 ||
                                                double.parse(fixedWeight
                                                        .replaceAll("kg", "")) <
                                                    6.0
                                            ? Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  iamYourVendor == true
                                                      ? Text(
                                                          'Your Vendor',
                                                          style: TextStyle(
                                                              fontSize: 15,
                                                              color: darkBlue,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontFamily:
                                                                  poppins),
                                                        )
                                                      : Container(),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  iamYourVendor == true
                                                      ? InkWell(
                                                          onTap: () {
                                                            // setState((){
                                                            //   selVendorIndex = -1;
                                                            // });
                                                          },
                                                          child: Container(
                                                            width:
                                                                MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width,
                                                            padding:
                                                                EdgeInsets.all(
                                                                    5),
                                                            margin:
                                                                EdgeInsets.all(
                                                                    5),
                                                            decoration: BoxDecoration(
                                                                color: Colors
                                                                    .white,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10)),
                                                            child: Row(
                                                              children: [
                                                                mySelVendors[0][
                                                                            'VendorProfile'] !=
                                                                        null
                                                                    ? Container(
                                                                        width:
                                                                            90,
                                                                        height:
                                                                            100,
                                                                        decoration: BoxDecoration(
                                                                            color:
                                                                                Colors.red,
                                                                            borderRadius: BorderRadius.circular(10),
                                                                            image: DecorationImage(image: NetworkImage(mySelVendors[0]['VendorProfile'].toString()), fit: BoxFit.cover)),
                                                                      )
                                                                    : Container(
                                                                        width:
                                                                            90,
                                                                        height:
                                                                            100,
                                                                        decoration: BoxDecoration(
                                                                            color:
                                                                                Colors.red,
                                                                            borderRadius: BorderRadius.circular(10),
                                                                            image: DecorationImage(image: Svg("assets/images/pictwo.svg"), fit: BoxFit.cover)),
                                                                      ),
                                                                SizedBox(
                                                                  width: 8,
                                                                ),
                                                                Expanded(
                                                                  child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    children: [
                                                                      Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.spaceBetween,
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                          Container(
                                                                            width:
                                                                                155,
                                                                            child:
                                                                                Column(
                                                                              mainAxisSize: MainAxisSize.min,
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                                Container(
                                                                                  child: Text(
                                                                                    '${mySelVendors[0]['VendorName']}',
                                                                                    style: TextStyle(
                                                                                      color: Colors.black,
                                                                                      fontWeight: FontWeight.bold,
                                                                                      fontFamily: "Poppins",
                                                                                    ),
                                                                                    overflow: TextOverflow.ellipsis,
                                                                                  ),
                                                                                ),
                                                                                SizedBox(
                                                                                  height: 6,
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
                                                                                    Text(
                                                                                      ' 4.5',
                                                                                      style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold, fontSize: 13, fontFamily: poppins),
                                                                                    )
                                                                                  ],
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                          Icon(
                                                                              Icons.check_circle,
                                                                              color: Colors.green),
                                                                        ],
                                                                      ),
                                                                      Text(
                                                                        mySelVendors[0]['VendorDesc'] != null ||
                                                                                mySelVendors[0]['VendorDesc'] != 'null'
                                                                            ? "${mySelVendors[0]['VendorDesc']}"
                                                                            : "No Description",
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              12,
                                                                          fontFamily:
                                                                              "Poppins",
                                                                          color:
                                                                              Colors.grey,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                        ),
                                                                        maxLines:
                                                                            1,
                                                                      ),
                                                                      SizedBox(
                                                                        height:
                                                                            6,
                                                                      ),
                                                                      Container(
                                                                        height:
                                                                            1,
                                                                        color: Colors
                                                                            .grey,
                                                                        // margin: EdgeInsets.only(left:6,right:6),
                                                                      ),
                                                                      SizedBox(
                                                                        height:
                                                                            6,
                                                                      ),
                                                                      Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.spaceBetween,
                                                                        children: [
                                                                          Column(
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,
                                                                            children: [
                                                                              Text(
                                                                                mySelVendors[0]['VendorEgg'] == 'Both' ? 'Includes eggless' : '${mySelVendors[0]['VendorEgg']}',
                                                                                style: TextStyle(
                                                                                  fontSize: 11,
                                                                                  fontFamily: "Poppins",
                                                                                  color: darkBlue,
                                                                                ),
                                                                                maxLines: 1,
                                                                              ),
                                                                              SizedBox(height: 3),
                                                                              Text(
                                                                                mySelVendors[0]['VendorDelCharge'] == '0' || mySelVendors[0]['VendorDelCharge'] == null ? "DELIVERY FREE" : 'Delivery Fee Rs.${mySelVendors[0]['VendorDelCharge']}',
                                                                                style: TextStyle(
                                                                                  fontSize: 10,
                                                                                  fontFamily: "Poppins",
                                                                                  color: Colors.orange,
                                                                                ),
                                                                                maxLines: 1,
                                                                              ),
                                                                            ],
                                                                          ),
                                                                          Container(
                                                                            width:
                                                                                100,
                                                                            child:
                                                                                Row(
                                                                              mainAxisAlignment: MainAxisAlignment.end,
                                                                              children: [
                                                                                InkWell(
                                                                                  onTap: () {
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
                                                                                    print('whatsapp : ');
                                                                                  },
                                                                                  child: Container(
                                                                                    alignment: Alignment.center,
                                                                                    height: 35,
                                                                                    width: 35,
                                                                                    decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey[200]),
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
                                                                      )
                                                                    ],
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        )
                                                      : Container(),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Text(
                                                            'Select Vendors',
                                                            style: TextStyle(
                                                                fontSize: 15,
                                                                color: darkBlue,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontFamily:
                                                                    poppins),
                                                          ),
                                                          Text(
                                                            '  (10km radius)',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .black45,
                                                                fontFamily:
                                                                    poppins),
                                                          ),
                                                        ],
                                                      ),
                                                      InkWell(
                                                        onTap: () async {
                                                          var pref =
                                                              await SharedPreferences
                                                                  .getInstance();
                                                          pref.setBool(
                                                              'iamFromCustomise',
                                                              true);
                                                          setState(() {
                                                            // context.read<ContextData>().setCurrentIndex(3);
                                                            Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            VendorsList()
                                                                ));
                                                          });
                                                        },
                                                        child: Row(
                                                          children: [
                                                            Text(
                                                              'See All',
                                                              style: TextStyle(
                                                                  color:
                                                                      lightPink,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontFamily:
                                                                      poppins),
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
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  Container(
                                                    height: 200,
                                                    child: ListView.builder(
                                                        scrollDirection:
                                                            Axis.horizontal,
                                                        shrinkWrap: true,
                                                        itemCount:
                                                            nearestVendors
                                                                .length,
                                                        itemBuilder:
                                                            (context, index) {
                                                          return Card(
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10)),
                                                            child: InkWell(
                                                              splashColor:
                                                                  Colors
                                                                      .red[200],
                                                              onTap: () {
                                                                List
                                                                    artTempList =
                                                                    [];
                                                                // print(index);

                                                                String adrss =
                                                                    '1/4 vellandipalayam , Avinashi';

                                                                setState(() {
                                                                  selVendorIndex =
                                                                      index;

                                                                  //
                                                                  // vendorID = nearestVendors[selVendorIndex]['_id'].toString();
                                                                  // vendorName = nearestVendors[selVendorIndex]['VendorName'].toString();
                                                                  // vendorMobileNum = nearestVendors[selVendorIndex]['PhoneNumber'].toString();
                                                                  // vendorAddress = adrss;

                                                                  context
                                                                      .read<
                                                                          ContextData>()
                                                                      .addMyVendor(
                                                                          true);
                                                                  context
                                                                      .read<
                                                                          ContextData>()
                                                                      .setMyVendors([
                                                                    {
                                                                      "VendorId":
                                                                          nearestVendors[index]
                                                                              [
                                                                              '_id'],
                                                                      "VendorModId":
                                                                          nearestVendors[index]
                                                                              [
                                                                              'Id'],
                                                                      "VendorName":
                                                                          nearestVendors[index]
                                                                              [
                                                                              'VendorName'],
                                                                      "VendorDesc":
                                                                          nearestVendors[index]
                                                                              [
                                                                              'Description'],
                                                                      "VendorProfile":
                                                                          nearestVendors[index]
                                                                              [
                                                                              'ProfileImage'],
                                                                      "VendorPhone":
                                                                          nearestVendors[index]
                                                                              [
                                                                              'PhoneNumber1'],
                                                                      "VendorDelCharge":
                                                                          nearestVendors[index]
                                                                              [
                                                                              'DeliveryCharge'],
                                                                      "VendorEgg":
                                                                          nearestVendors[index]
                                                                              [
                                                                              'EggOrEggless'],
                                                                      "VendorAddress":
                                                                          nearestVendors[index]['Address']
                                                                              [
                                                                              'FullAddress'],
                                                                    }
                                                                  ]);

                                                                  // myCakesList.where((element) => element['Title'].toString().contains(cakeName.toString())).toList();

                                                                  artTempList = myCakesList
                                                                      .where((element) =>
                                                                          element['VendorID']
                                                                              .toString() ==
                                                                          nearestVendors[index]['_id']
                                                                              .toString())
                                                                      .toList();

                                                                  artTempList = artTempList
                                                                      .where((element) => element[
                                                                              'Title']
                                                                          .toString()
                                                                          .toLowerCase()
                                                                          .contains(cakeName
                                                                              .toString()
                                                                              .toLowerCase()))
                                                                      .toList();

                                                                  adrss = artTempList[0]['VendorAddress']['Street'].toString() +
                                                                      "," +
                                                                      artTempList[0]['VendorAddress']
                                                                              [
                                                                              'City']
                                                                          .toString() +
                                                                      "," +
                                                                      artTempList[0]['VendorAddress']
                                                                              [
                                                                              'District']
                                                                          .toString() +
                                                                      "," +
                                                                      artTempList[0]['VendorAddress']
                                                                              [
                                                                              'Pincode']
                                                                          .toString();

                                                                  // print(artTempList[0]['VendorAddress']);

                                                                  cakeImages = artTempList[
                                                                              0]
                                                                          [
                                                                          'Images']
                                                                      .toList();
                                                                  cakeId = artTempList[
                                                                              0]
                                                                          [
                                                                          '_id']
                                                                      .toString();
                                                                  cakeType = artTempList[
                                                                              0]
                                                                          [
                                                                          'TypeOfCake']
                                                                      .toString();
                                                                  cakeModId = artTempList[
                                                                              0]
                                                                          ['Id']
                                                                      .toString();
                                                                  weight = artTempList[
                                                                              0]
                                                                          [
                                                                          'WeightList']
                                                                      .toList();
                                                                  // cakeRatings = artTempList[index]['Images'].toList();
                                                                  cakeEggorEgless =
                                                                      artTempList[0]
                                                                              [
                                                                              'EggOrEggless']
                                                                          .toString();
                                                                  cakeName = artTempList[
                                                                              0]
                                                                          [
                                                                          'Title']
                                                                      .toString();
                                                                  cakePrice = artTempList[
                                                                              0]
                                                                          [
                                                                          'Price']
                                                                      .toString();
                                                                  cakeDescription =
                                                                      artTempList[0]
                                                                              [
                                                                              'Description']
                                                                          .toString();
                                                                  flavour = artTempList[0]
                                                                              [
                                                                              'FlavourList']
                                                                          .toList() +
                                                                      [
                                                                        {
                                                                          "Name":
                                                                              'Default Flavour',
                                                                          "Price":
                                                                              '0'
                                                                        }
                                                                      ];
                                                                  shapes = artTempList[
                                                                              0]
                                                                          [
                                                                          'ShapeList']
                                                                      .toList();
                                                                  articals = artTempList[
                                                                              0]
                                                                          [
                                                                          'ArticleList']
                                                                      .toList();

                                                                  vendorID = artTempList[
                                                                              0]
                                                                          [
                                                                          'VendorID']
                                                                      .toString();
                                                                  vendorModID =
                                                                      artTempList[0]
                                                                              [
                                                                              'Vendor_ID']
                                                                          .toString();
                                                                  vendorName = artTempList[
                                                                              0]
                                                                          [
                                                                          'VendorName']
                                                                      .toString();
                                                                  vendorAddress =
                                                                      adrss;
                                                                  vendorMobileNum =
                                                                      artTempList[0]
                                                                              [
                                                                              'VendorPhoneNumber']
                                                                          .toString();

                                                                  // print(vendorID);
                                                                  // print(vendorModID);
                                                                  // print(cakeId);
                                                                  // print(cakeModId);

                                                                  // myScrollCtrl.jumpTo(myScrollCtrl.position.minScrollExtent);
                                                                });

                                                                ScaffoldMessenger.of(
                                                                        context)
                                                                    .showSnackBar(
                                                                        SnackBar(
                                                                  content: Text(
                                                                      'Updated to vendor (${artTempList[0]['VendorName']})'),
                                                                  duration:
                                                                      Duration(
                                                                          seconds:
                                                                              1),
                                                                ));

                                                                // print('$vendorID \n $vendorName \n '
                                                                //     '$vendorMobileNum \n $vendorAddress');
                                                                //
                                                                // print('index :$index / venIndex : $selVendorIndex');
                                                              },
                                                              child: Container(
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(
                                                                            10),
                                                                width: 260,
                                                                child: Column(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .min,
                                                                  children: [
                                                                    Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .start,
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        nearestVendors[index]['ProfileImage'] !=
                                                                                null
                                                                            ? CircleAvatar(
                                                                                radius: 32,
                                                                                backgroundColor: Colors.white,
                                                                                child: CircleAvatar(
                                                                                  radius: 30,
                                                                                  backgroundImage: NetworkImage('${nearestVendors[index]['ProfileImage']}'),
                                                                                ),
                                                                              )
                                                                            : CircleAvatar(
                                                                                radius: 32,
                                                                                backgroundColor: Colors.white,
                                                                                child: CircleAvatar(
                                                                                  radius: 30,
                                                                                  backgroundImage: Svg('assets/images/pictwo.svg'),
                                                                                ),
                                                                              ),
                                                                        SizedBox(
                                                                          width:
                                                                              6,
                                                                        ),
                                                                        Container(
                                                                          width:
                                                                              170,
                                                                          child:
                                                                              Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.spaceBetween,
                                                                            children: [
                                                                              Column(
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                children: [
                                                                                  Container(
                                                                                    width: 120,
                                                                                    child: Text(
                                                                                      nearestVendors[index]['VendorName'].toString().isEmpty ? 'Un name' : '${nearestVendors[index]['VendorName'][0].toString().toUpperCase() + nearestVendors[index]['VendorName'].toString().substring(1).toLowerCase()}',
                                                                                      style: TextStyle(color: darkBlue, fontWeight: FontWeight.bold, fontFamily: "Poppins"),
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
                                                                                        itemPadding: EdgeInsets.symmetric(horizontal: 1.0),
                                                                                        itemBuilder: (context, _) => Icon(
                                                                                          Icons.star,
                                                                                          color: Colors.amber,
                                                                                        ),
                                                                                        onRatingUpdate: (rating) {
                                                                                          print(rating);
                                                                                        },
                                                                                      ),
                                                                                      Text(
                                                                                        ' 4.5',
                                                                                        style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold, fontSize: 13, fontFamily: poppins),
                                                                                      )
                                                                                    ],
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    SizedBox(
                                                                      height:
                                                                          10,
                                                                    ),
                                                                    Container(
                                                                      alignment:
                                                                          Alignment
                                                                              .centerLeft,
                                                                      child:
                                                                          Text(
                                                                        nearestVendors[index]['Description'] != null || nearestVendors[index]['Description'] != "null"
                                                                            ? " " +
                                                                                nearestVendors[index]['Description']
                                                                            : '',
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.black54,
                                                                            fontFamily: "Poppins"),
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                        maxLines:
                                                                            1,
                                                                        textAlign:
                                                                            TextAlign.start,
                                                                      ),
                                                                    ),
                                                                    Container(
                                                                      margin: EdgeInsets
                                                                          .only(
                                                                              top: 10),
                                                                      height:
                                                                          0.5,
                                                                      color: Colors
                                                                          .black26,
                                                                    ),
                                                                    SizedBox(
                                                                      height:
                                                                          15,
                                                                    ),
                                                                    Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceBetween,
                                                                      children: [
                                                                        Column(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                            nearestVendors[index]['EggOrEggless'].toString() == 'Both'
                                                                                ? Text(
                                                                                    'Egg and Eggless',
                                                                                    style: TextStyle(color: darkBlue, fontSize: 10, fontFamily: "Poppins"),
                                                                                  )
                                                                                : Text(
                                                                                    '${nearestVendors[index]['EggOrEggless'].toString()}',
                                                                                    style: TextStyle(color: darkBlue, fontSize: 10, fontFamily: "Poppins"),
                                                                                  ),
                                                                            SizedBox(
                                                                              height: 8,
                                                                            ),
                                                                            Text(
                                                                              nearestVendors[index]['DeliveryCharge'].toString() == 'null' || nearestVendors[index]['DeliveryCharge'].toString() == '0' || nearestVendors[index]['DeliveryCharge'].toString() == null ? 'DELIVERY FREE' : 'Delivery Charge ₹${nearestVendors[index]['DeliveryCharge'].toString()}',
                                                                              style: TextStyle(color: Colors.orange, fontSize: 10, fontFamily: "Poppins"),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        selVendorIndex ==
                                                                                index
                                                                            ? Icon(
                                                                                Icons.check_circle,
                                                                                color: Colors.green,
                                                                              )
                                                                            : Container(),
                                                                      ],
                                                                    )
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          );
                                                        }),
                                                  ),
                                                ],
                                              )
                                            :
                                            //premium vendor / help-desk ui
                                            Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Selected Vendor',
                                                    style: TextStyle(
                                                        fontSize: 15,
                                                        color: darkBlue,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontFamily: poppins),
                                                  ),
                                                  SizedBox(height: 10),
                                                  Container(
                                                      padding:
                                                          EdgeInsets.all(7),
                                                      height: 85,
                                                      decoration: BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          border: Border.all(
                                                            color: Colors.grey,
                                                            width: 1,
                                                          )),
                                                      child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Container(
                                                              width: 75,
                                                              decoration: BoxDecoration(
                                                                  color: Colors
                                                                      .red,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10),
                                                                  image: DecorationImage(
                                                                      image: AssetImage(
                                                                          'assets/images/customcake.png'),
                                                                      fit: BoxFit
                                                                          .cover)),
                                                            ),
                                                            Container(
                                                                width: 80,
                                                                child: Image(
                                                                    image: Svg(
                                                                        'assets/images/cakeylogo.svg'))),
                                                            Text(
                                                                'PREMIUM\nVENDOR',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .orange,
                                                                    fontFamily:
                                                                        "Poppins",
                                                                    fontSize:
                                                                        18))
                                                          ])),
                                                ],
                                              ),
                                      ],
                                    )
                                  : Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Selected Vendor',
                                          style: TextStyle(
                                              fontSize: 15,
                                              color: darkBlue,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: poppins),
                                        ),
                                        SizedBox(height: 10),
                                        Container(
                                            padding: EdgeInsets.all(7),
                                            height: 85,
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                border: Border.all(
                                                  color: Colors.grey,
                                                  width: 1,
                                                )),
                                            child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Container(
                                                    width: 75,
                                                    decoration: BoxDecoration(
                                                        color: Colors.red,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                        image: DecorationImage(
                                                            image: AssetImage(
                                                                'assets/images/customcake.png'),
                                                            fit: BoxFit.cover)),
                                                  ),
                                                  Container(
                                                      width: 80,
                                                      child: Image(
                                                          image: Svg(
                                                              'assets/images/cakeylogo.svg'))),
                                                  Text('PREMIUM\nVENDOR',
                                                      style: TextStyle(
                                                          color: Colors.orange,
                                                          fontFamily: "Poppins",
                                                          fontSize: 18))
                                                ])),
                                      ],
                                    ),

                              SizedBox(
                                height: 15,
                              ),
                              Center(
                                child: Container(
                                  height: 50,
                                  width: 200,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(25)),
                                  child: RaisedButton(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(25)),
                                    onPressed: () async {
                                      FocusScope.of(context).unfocus();

                                      if (newRegUser == true) {
                                        showDpUpdtaeDialog();
                                      } else {
                                        if (mySelVendors.isNotEmpty) {
                                          if (fixedWeight == '0.0' ||
                                              fixedDelliverMethod == "" ||
                                              deliverDate.toLowerCase() ==
                                                  "not yet select" ||
                                              deliverSession.toLowerCase() ==
                                                  "not yet select") {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(SnackBar(
                                              content: Text(
                                                  'Please Select : Cake Weight , Deliver Date,Session & Deliver Type.!'),
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              // backgroundColor: Colors.red[300],
                                              duration: Duration(minutes: 1),
                                              action: SnackBarAction(
                                                textColor: Colors.red,
                                                onPressed: () {},
                                                label: 'Close',
                                              ),
                                            ));
                                          } else if (userAddress.isEmpty ||
                                              userAddress == "null" ||
                                              userAddress == null) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(SnackBar(
                                              content: Text(
                                                  'Please Change Your Address!'),
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              // backgroundColor: Colors.red[300],
                                              duration: Duration(minutes: 1),
                                              action: SnackBarAction(
                                                textColor: Colors.red,
                                                onPressed: () {},
                                                label: 'Close',
                                              ),
                                            ));
                                          } else {
                                            setState(() {
                                              vendorName =
                                                  mySelVendors[0]['VendorName'];
                                              vendorID =
                                                  mySelVendors[0]['VendorId'];
                                              vendorMobileNum = mySelVendors[0]
                                                  ['VendorPhone'];
                                              vendorModID = mySelVendors[0]
                                                  ['VendorModId'];
                                              vendorAddress = mySelVendors[0]
                                                  ['VendorAddress'];
                                            });

                                            loadOrderPreference();
                                          }
                                        } else {
                                          if (fixedWeight == '0.0' ||
                                              fixedDelliverMethod == "" ||
                                              deliverDate.toLowerCase() ==
                                                  "not yet select" ||
                                              deliverSession.toLowerCase() ==
                                                  "not yet select") {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(SnackBar(
                                              content: Text(
                                                  'Please Select : Cake Weight , Deliver Date,Session & Deliver Type.!'),
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              // backgroundColor: Colors.red[300],
                                              duration: Duration(minutes: 1),
                                              action: SnackBarAction(
                                                textColor: Colors.red,
                                                onPressed: () {},
                                                label: 'Close',
                                              ),
                                            ));
                                          }
                                          // else if(selVendorIndex==-1){
                                          //   ScaffoldMessenger.of(context).showSnackBar(
                                          //       SnackBar(
                                          //         content: Text('Plese select a Vendor!'),
                                          //         behavior: SnackBarBehavior.floating,
                                          //         // backgroundColor: Colors.red[300],
                                          //         duration: Duration(minutes: 1),
                                          //         action: SnackBarAction(
                                          //           textColor: Colors.red,
                                          //           onPressed: (){
                                          //           },
                                          //           label: 'Close',
                                          //         ),
                                          //       )
                                          //   );
                                          // }
                                          else if (userAddress.isEmpty ||
                                              userAddress == "null" ||
                                              userAddress == null) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(SnackBar(
                                              content: Text(
                                                  'Please Change Your Address!'),
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              // backgroundColor: Colors.red[300],
                                              duration: Duration(minutes: 1),
                                              action: SnackBarAction(
                                                textColor: Colors.red,
                                                onPressed: () {},
                                                label: 'Close',
                                              ),
                                            ));
                                          } else {
                                            loadOrderPreference();
                                          }
                                        }
                                      }
                                    },
                                    color: lightPink,
                                    child: Text(
                                      "ORDER NOW",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )),
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

