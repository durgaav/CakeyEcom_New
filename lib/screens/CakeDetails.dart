import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:cakey/Dialogs.dart';
import 'package:cakey/DrawerScreens/VendorsList.dart';
import 'package:cakey/screens/CheckOut.dart';
import 'package:cakey/screens/OrderConfirm.dart';
import 'package:cakey/screens/SingleVendor.dart';
import 'package:file_picker/file_picker.dart';
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
  List shapes, flavour, articals , cakeTiers;
  CakeDetails(this.shapes, this.flavour, this.articals ,this.cakeTiers);

  @override
  State<CakeDetails> createState() =>
      _CakeDetailsState(shapes, flavour, articals , cakeTiers);
}

class _CakeDetailsState extends State<CakeDetails> with WidgetsBindingObserver{
  List shapes, flavour, articals , cakeTiers;
  _CakeDetailsState(this.shapes, this.flavour, this.articals , this.cakeTiers);


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
  bool themeSectionVisible = false;
  bool updateCake = false;
  String vendorLat = "";
  String vendorLong = "";
  String thrkgdeltime = "";
  String fvkgdeltime = "";
  String cakeMindeltime = "";

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

  //toppers...
  List toppersList = [];

  List topings = [];
  List<String> weight = [];
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
  int extraShapeCharge = 0;

  //Pick Or Deliver
  var picOrDeliver = ['Pickup', 'Delivery'];
  var picOrDel = [false, false];

  //Strings......Cake Details
  String cakeId = "";
  String cakeModId = "";
  String cakeName = "";
  String commonCakeName = "";
  String cakeDescription = "";
  String cakeType = '';
  String cakeSubType = '';
  String cakeRatings = "4.5";
  String vendorID = ''; //ven id
  String vendorModID = ''; //ven id
  String vendorName = ''; //ven name
  String vendorMobileNum = ''; //ven mobile
  String vendorAddress = ''; //ven address
  String cakeEggorEgless = "";
  String cakeEgglessAvail = "";
  String cakeEgglessPrice = "0.0";
  bool isFromEggless = false;
  String cakePrice = "1.0";
  String defCakePrice = "1.0";
  String cakeDeliverCharge = '';
  int cakeDiscounts = 0;
  String userMainLocation = '';
  String authToken = '';
  String cakeBaseFlav = '';
  String cakeBaseShape = '';
  int addedFlavPrice = 0;
  String isTierPossible = 'n';
  String isThemePossible = "n";
  String basicCakeWeight= "";
  String vendorPhone1 = '';
  String vendorPhone2 = "";
  String vendorLatitude = "";
  String vendorLongtitude = "";

  //topper
  String topperId = "";
  String topperName = "";
  String topperImage = "";
  int topperPrice = 0;
  int topperIndex = -1;
  String isTopperPossible = "n";

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
  String fixedFlavour = '';
  var fixedFlavList = [];
  //

  //Shape
  var myShapeIndex = -1;
  String fixedShape = '';
  String fixedtheme = '';
  String fixedWeight = '1.0';
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
  int weightIndex = 0;
  int tierSelIndex=-1;
  double tierPrice = 0;
  double tempTierPrice = 0;
  String tempCakeWeight = "1.0 kg";

  int itemCount = 0;
  int totalAmount = 0;
  int deliveryCharge = 0;
  int discounts = 0;
  int taxes = 0;
  int counts = 1;
  int selVendorIndex = -1;
  int flavExtraCharge = 0;

  //delivery
  int adminDeliveryCharge = 0;
  int adminDeliveryChargeKm = 0;
  String userLatitude = "";
  String userLongtitude = "";

  //Text controls
  var messageCtrl = new TextEditingController();
  var specialReqCtrl = new TextEditingController();
  var customweightCtrl = new TextEditingController();
  var themeTextCtrl = new TextEditingController();

  //Scroll ctrl
  var myScrollCtrl = ScrollController();

  //File
  File file = new File('');

  bool isNearVendrClicked = false;

  AppLifecycleState? lifeCyState ;

  //endregion

  //region Alerts

  //Theme sheet
  void showThemeBottomSheet() async {

    print("Tiers : $cakeTiers");

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
    print(flavour.length);
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
                      child: flavour.isEmpty?
                      Center(
                        child: Text(
                          "No Custom Flavours! :(",
                          style: TextStyle(
                            color: lightPink,
                            fontFamily: "Poppins",
                          ),
                        ),
                      ):
                      ListView.builder(
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
                                          text: flavour[index]['Name'].toString()+" - ",
                                          style: TextStyle(
                                              fontFamily: "Poppins",
                                              color: Colors.grey,
                                              fontWeight: FontWeight.bold),
                                          children: [
                                            TextSpan(
                                                text:
                                                   flavour[index]['Price'].toString()=='0'?
                                                   "Included In Price":
                                                   "Additional Rs."+flavour[index]['Price'].toString()+"/Kg",
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
                      child:shapes.isEmpty?
                      Center(
                        child: Text(
                          "No Custom Shapes! :(",
                          style: TextStyle(
                            color: lightPink,
                            fontFamily: "Poppins",
                          ),
                        ),
                      ):
                      ListView.builder(
                          itemCount: shapes.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return InkWell(
                              onTap: () {
                                setState((){
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
                                      child: Text.rich(
                                        TextSpan(
                                          text: shapes[index]['Name'][0].toString().toUpperCase()+
                                              shapes[index]['Name'].toString().substring(1).toLowerCase()+" - ",
                                            style: TextStyle(
                                                fontFamily: "Poppins",
                                                color: Colors.grey,
                                                fontWeight: FontWeight.bold
                                            ),
                                          children: [
                                            TextSpan(
                                                text:shapes[index]['Price'].toString()=='0'?
                                                "Included In Price":
                                                "Additional Rs."+shapes[index]['Price'].toString()+"/Kg",
                                                style: TextStyle(
                                                    fontFamily: "Poppins",
                                                    color: Colors.black,

                                                ),
                                            ),
                                          ]
                                        ),
                                        )
                                      ),
                                    )
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
                          // saveFixedShape(shapeGrpValue);
                          setShapeFixed(myShapeIndex);
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

  //cake topper sheet
  void showCakeTopperSheet(){
    String name = '',id = "" , image = '';
    int price = 0;
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
        ),
        builder: (context)=>
            StatefulBuilder(builder:(BuildContext context, void Function(void Function()) setState){
              return Container(
                padding: EdgeInsets.all(7),
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
                          'TOPPERS',
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
                      height: 280,
                      child: toppersList.isNotEmpty?
                      Scrollbar(

                        child: ListView.builder(
                            itemCount: toppersList.length,
                            itemBuilder: (c, i)=>
                                InkWell(
                                  splashColor: Colors.red[300]!,
                                  onTap: (){
                                    setState((){
                                      if(topperIndex == i){
                                        topperIndex = -1;
                                        id = '';
                                        name = '';
                                        image = '';
                                        price = 0;
                                      }else{
                                        id = toppersList[i]['_id'].toString();
                                        name = toppersList[i]['TopperName'].toString();
                                        image = toppersList[i]['TopperImage'].toString();
                                        price = int.parse(toppersList[i]['Price'].toString());
                                        topperIndex = i;
                                      }
                                    });
                                  },
                                  child: Container(
                                    child: Stack(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(8),
                                          child: Row(
                                            children: [
                                              Container(
                                                height: 45,
                                                width: 45,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Colors.red[300]!,
                                                  image: DecorationImage(
                                                    image: NetworkImage(toppersList[i]['TopperImage'])
                                                  )
                                                ),
                                              ),
                                              SizedBox(width: 10,),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(toppersList[i]['TopperName'],style:
                                                  TextStyle(color: darkBlue,fontFamily: "Poppins",fontSize: 13.5),),
                                                  SizedBox(height: 5,),
                                                  Text("Rs."+toppersList[i]['Price'],style: TextStyle(color: darkBlue,fontFamily: "Poppins",fontSize: 15,fontWeight: FontWeight.bold),),
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                        Positioned(
                                            left: 0,
                                            top: 0,
                                            child: topperIndex==i?Icon(Icons.check_circle,color: Colors.green,):Container()
                                        )
                                      ],
                                    ),
                                  ),
                                )
                        ),
                      ):
                      Center(
                        child: Text("No Toppers :(",
                          style: TextStyle(color: darkBlue,fontFamily: "Poppins",fontSize: 15,fontWeight: FontWeight.bold),),
                      )
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
                          setState(() {
                            saveFixedToppers(id, name, image, price);
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
       }
     )
    );
  }

  //Saving fixed flavour from bottomsheet

  //save topper
  void saveFixedToppers(String id , String name , String image,int price){
    setState((){
       topperId = id;
       topperName = name;
       topperImage = image;
       topperPrice = price;
    });
    Navigator.pop(context);
  }

  void saveFixedFlav(List list) {

    if(list.isEmpty){
      Navigator.pop(context);
    }else{
      setState(() {

        fixedFlavList = list;
        if (fixedFlavList.isEmpty) {
          fixedFlavour = "$cakeBaseFlav";
          flavExtraCharge = 0;
        } else {
          fixedFlavour = "${fixedFlavList.length} Selected";
        }

        for (int i = 0; i < list.length; i++) {
          flavExtraCharge = int.parse(list[i]['Price']) + flavExtraCharge;
        }

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Price Updated!'),
          duration: Duration(seconds: 2),
        ));
      });
      Navigator.pop(context);
    }

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

  //Show eggless flav sheet
  void showEgglessSheet(){
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
          )
        ),
        context: context,
        builder: (c)=> Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              //header
              Container(
                padding: EdgeInsets.all(7),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Egg/Eggless",style: TextStyle(fontFamily: 'Poppins',
                        color: darkBlue,fontWeight: FontWeight.bold, fontSize: 18),),
                    IconButton(
                        onPressed: ()=>Navigator.pop(context),
                        icon: Icon(Icons.close)
                    )
                  ],
                ),
              ),

              //body
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.all(8),
                child: Text(
                  cakeEgglessAvail.toLowerCase()=='y'?
                  "This cake is also available in Eggless version do you want to try this?\n*addtional cost may apply.\n*Change egg or eggless option in top of screen.":
                  "This cake is not available in Eggless version :(\n*Change egg or eggless option in top of screen",
                  style: TextStyle(
                    fontFamily: "Poppins",
                    color: Colors.black,
                    fontSize: 13
                  ),
                ),
              ),

              //eggless buttons
              Container(
                padding: EdgeInsets.all(8),
                child: Row(
                  children: [
                    Expanded(child: RaisedButton(
                      child: Text('Show in Egg',style: TextStyle(
                          fontFamily: "Poppins",
                          color: Colors.white,
                          fontSize: 13
                      ),),
                      onPressed: ()=>applyEggCake(),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13)
                      ),
                      color: lightPink,
                    )),
                    SizedBox(width: 10,),
                    cakeEgglessAvail.toLowerCase()=='y'?
                    Expanded(child: RaisedButton(
                      child: Text('Show in Eggless',style: TextStyle(
                          fontFamily: "Poppins",
                          color: Colors.white,
                          fontSize: 13
                      ),),
                      onPressed: ()=>applyEgglessCake(),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13)
                      ),
                      color: lightPink,
                    )):Container()
                  ],
                ),
              ),

            ],
          ),
        )
    );
  }

  //apply egg cake
  void applyEggCake(){
    Navigator.pop(context);
    setState((){
      cakeEggorEgless = 'Egg';
      cakePrice = defCakePrice;
    });
  }

  //apply Eggless cake...
  void applyEgglessCake(){
    Navigator.pop(context);
    setState((){
      cakeEggorEgless = 'Eggless';
      cakePrice = cakeEgglessPrice;
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
        int.parse(cakeDiscounts.toString().replaceAll(new RegExp(r'[^0-9]'), ''));
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

  //Distance calculator
  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  //fetch toppers by ven id..
  Future<void> fetchToppersById(String id) async{
    print("V : $id");
    print("entered...top");

    var res = await http.get(
        Uri.parse("https://cakey-database.vercel.app/api/toppers/listbyvendorandstock/$id"),
        headers: {"Authorization": "$authToken"});

    print(authToken);
    print(res.body);

    if(res.statusCode==200){

      setState((){
        print('body');
        print(res.body);
        if(res.body.length < 50){
        }else{
          toppersList = jsonDecode(res.body);
        }
      });

    }else{

    }
    print("exit...top");
  }

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

  //imagePickers
  Future<void> imagePicker() async{
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

  //getting prfs from pre-screen
  Future<void> getDetailsFromScreen() async {

    List flavour1 = [];
    List shapes1 = [];

    print(shapes);
    print(flavour);

    //Local var
    var prefs = await SharedPreferences.getInstance();

    setState(() {

      authToken = prefs.getString('authToken')!;
      userLatitude = prefs.getString('userLatitute')??'Not Found';
      userLongtitude = prefs.getString('userLongtitude')??'Not Found';

      vendorCakeMode = prefs.getBool('vendorCakeMode')??false;

      cakeImages = prefs.getStringList('cakeImages')!;
      cakeId = prefs.getString('cake_id')!;
      cakeModId = prefs.getString('cakeModid')!;
      cakeName = prefs.getString('cakeName')!;
      commonCakeName = prefs.getString('cakeCommName')!;
      cakeBaseFlav = prefs.getString('cakeBasicFlav')!;
      cakeBaseShape = prefs.getString('cakeBasicShape')!;
      cakePrice = prefs.getString('cakeMinPrice')!;
      defCakePrice = prefs.getString('cakeMinPrice')!;
      cakeEggorEgless = prefs.getString('cakeEggorEggless')!;
      cakeEgglessAvail = prefs.getString('cakeEgglessAvail')!;
      cakeEgglessPrice = prefs.getString('cakeEgglesCost')!;
      basicCakeWeight = prefs.getString('cakeMinWeight')!;
      cakeDescription = prefs.getString('cakeDescription')!;
      cakeType = prefs.getString('cakeType')!;
      cakeSubType = prefs.getString('cakeSubType')!;
      cakeRatings = prefs.getDouble('cakeRating')!.toString();
      isThemePossible = prefs.getString('cakeThemePoss')!.toString();
      isTierPossible = prefs.getString('cakeTierPoss')!.toString();
      isTopperPossible = prefs.getString('cakeTopperPoss')!.toString();
      taxes = prefs.getInt("cakeTax")!;
      cakeDiscounts = prefs.getInt("cakeDiscount")!;
      weight = prefs.getStringList('cakeWeights')!;
      vendorLat = prefs.getString('cakeVendorLatitu')!;
      vendorLong = prefs.getString('cakeVendorLongti')!;
      thrkgdeltime = prefs.getString('cake3kgminTime')!;
      fvkgdeltime = prefs.getString('cake5kgminTime')!;
      cakeMindeltime = prefs.getString('cakeminDelTime')!;

      //Vendor
      vendorID = prefs.getString('cakeVendorid')!;
      vendorModID = prefs.getString('cakeVendorModid')!;
      vendorPhone1 = prefs.getString('cakeVendorPhone1')!;
      vendorPhone2 = prefs.getString('cakeVendorPhone2')!;
      vendorAddress = prefs.getString('cakeVendorAddress')!;
      vendorName = prefs.getString('cakeVendorName')!;

      //delivery charge
      adminDeliveryCharge = prefs.getInt("todayDeliveryCharge")??0;
      adminDeliveryChargeKm = prefs.getInt("todayDeliveryKm")??0;

      fetchToppersById(vendorID);

      //user
      userPhone = prefs.getString("phoneNumber") ?? "";
      userID = prefs.getString("userID") ?? "";
      userModID = prefs.getString("userModId") ?? "";
      userName = prefs.getString("userName") ?? "";
      userAddress = prefs.getString('userAddress') ?? 'None';
      newRegUser = prefs.getBool('newRegUser') ?? false;

      print("Users : $vendorID\n $userName\n $userModID\n $userAddress\n $newRegUser\n $userPhone\n");

      if(weight.isEmpty){
        weight.add(basicCakeWeight);
      }else{
        weight.insert(0, basicCakeWeight);
      }

      if(cakeImages.isEmpty){
        cakeImages.add(prefs.getString('cakeMainImage').toString());
      }else{
        cakeImages.insert(0, prefs.getString('cakeMainImage').toString());
      }

      weight = weight.toSet().toList();
      cakeImages = cakeImages.toSet().toList();

      if(cakeEggorEgless.toLowerCase()=="egg"&&cakeEgglessAvail.toLowerCase()=='y'){
        showEgglessSheet();
      }

      if(cakeEggorEgless.toLowerCase()=="eggless"){
        isFromEggless = true;
      }


      print(cakeEgglessPrice);

      if(flavour1.isEmpty){
        flavour1.add({"Name":"$cakeBaseFlav","Price":"0"});
      }

      if(shapes1.isEmpty){
        shapes1.add({"Name":"$cakeBaseShape","Price":"0"});
      }

      flavour = flavour.toSet().toList() + flavour1.toSet().toList();
      shapes = shapes.toSet().toList()+shapes1.toSet().toList();

      flavour = flavour.reversed.toList();
      shapes = shapes.reversed.toList();


      getCakesList();
    });
    context.read<ContextData>().addMyVendor(false);
    context.read<ContextData>().setMyVendors([]);
  }

  //***load prefs to ORDER.....***
  Future<void> loadOrderPreference() async {
    var prefs = await SharedPreferences.getInstance();

    print('*****removing.... ');

    prefs.remove('orderCakeID');
    prefs.remove('orderCakeModID');
    prefs.remove('orderCakeName');
    prefs.remove('orderCakeCommonName');
    prefs.remove('orderCakeDescription');
    prefs.remove('orderCakeType');
    prefs.remove('orderCakeSubType');
    prefs.remove('orderCakeImages');
    prefs.remove('orderCakeEggOrEggless');
    prefs.remove('orderCakePrice');
    prefs.remove('orderCakeisPremium');

    // prefs.remove('orderCakeFlavour',fix flavour.split("-").first.toString());

    prefs.remove('orderCakeShape');
    prefs.remove('orderCakeWeight');
    prefs.remove('orderCakeMessage');
    prefs.remove('orderCakeRequest');
    prefs.remove('orderCakeWeight');

    //vendor..
    prefs.remove('orderCakeVendorId');
    prefs.remove('orderCakeVendorModId');
    prefs.remove('orderCakeVendorName');
    prefs.remove('orderCakeVendorPh1');
    prefs.remove('orderCakeVendorPh2');
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
    prefs.remove('orderCakeTheme');
    prefs.remove('orderCakeThemeImage');
    prefs.remove('orderCakeGst');
    prefs.remove('orderCakeSGst');
    prefs.remove('orderCakeTotalPrice');
    prefs.remove('orderCakeDelCharge');
    prefs.remove('orderCakeTopperid');
    prefs.remove('orderCakeTopperName');
    prefs.remove('orderCakeTopperImg');
    prefs.remove('orderCakeTopperPrice');
    prefs.remove('orderCakeVenLat');
    prefs.remove('orderCakeVenLong');

    print('.....removed****');

    String dlintKm = "";

    if(mySelVendors.isEmpty||nearestVendors.isEmpty){
      dlintKm = "0";
    }else{
      dlintKm =  ((adminDeliveryCharge/adminDeliveryChargeKm)*
          (calculateDistance(double.parse(userLatitude),
              double.parse(userLongtitude),
              mySelVendors[0]['GoogleLocation']['Latitude'],
              mySelVendors[0]['GoogleLocation']['Longitude'])).toInt()).toString();
    }



    print("deliver based km $dlintKm");

    //variables for calculations
    double price = 0 , tax = 0, gst = 0 , sgst = 0 , discount = 0
    ,itemCount = 0, total = 0 , extra = 0 ,
        delCharge = fixedDelliverMethod.toLowerCase()=="pickup"?0:double.parse(dlintKm),
        weights = 0, finalPrice = 0;
    double priceAfterDis = 0 , discountedPrice = 0 , flavByWeight = 0 , shapeByWeight = 0 , addedPrice =0;

    String shape = "";

    setState((){

      if(fixedWeight=="1.0"){
        fixedWeight = weight[0].toString();
      }

      fixedWeight = fixedWeight.toLowerCase().replaceAll("kg", "");

      if(fixedFlavList.isEmpty){
        fixedFlavList = [
          {
            "Name":"$cakeBaseFlav",
            "Price":"0"
          }
        ];
      }else{
        fixedFlavList = fixedFlavList;
      }

      if(fixedShape.isEmpty){
        shape = '{"Name":"$cakeBaseShape","Price":"0"}';
      }else{
        shape = '{"Name":"$fixedShape","Price":"$extraShapeCharge"}';
      }

      print("status of list ${nearestVendors.length}");

      //calculations

      //counts * (double.parse(cakePrice.toString()) +
      // double.parse(extraCharges.toString()))*double.parse(weight.toLowerCase().replaceAll('kg', ""))

      //--> Assign
        extra = double.parse(flavExtraCharge.toString())+
            double.parse(extraShapeCharge.toString())+
            double.parse(topperPrice.toString());

        print("extra $extra");

        price = (counts * (double.parse(cakePrice.toString())+extra))*
            double.parse(fixedWeight.toLowerCase().replaceAll("kg", "").toString());

        //if tier selected
      if(tierPrice!=0){
        price = double.parse(tierPrice.toString());
        weights = 1.0;
      }

        print("price $price");

        tax = (price * taxes)/100;

        print("%% $tax");

        gst = tax/2;
        sgst = tax/2;

        total = price + tax + delCharge;

        print("tooo $total");
        print("dis % $cakeDiscounts");

        discountedPrice = (price*cakeDiscounts)/100;

        print("Dis Price $discountedPrice");



    });

    print('flav ; $fixedFlavList');

    print("Ven diiidid $vendorID");

    //load Order Details
    prefs.setString('orderCakeID', cakeId);
    prefs.setString('orderCakeModID', cakeModId);
    prefs.setString('orderCakeName', cakeName);
    prefs.setString('orderCakeCommonName', commonCakeName);
    prefs.setString('orderCakeType', cakeType);
    prefs.setString('orderCakeSubType', cakeSubType);
    prefs.setString('orderCakeImages', cakeImages[0].toString());
    prefs.setString('orderCakeEggOrEggless', cakeEggorEgless);
    prefs.setString('orderCakeVenLat', vendorLat);
    prefs.setString('orderCakeVenLong', vendorLong);

    if(tierPrice!=0){
      print(" tempCakeWeight $tempCakeWeight");
      tempCakeWeight.toLowerCase().replaceAll("kg", "");
      prefs.setString('orderCakeWeight', weights.toString()+"kg");
      prefs.setString('orderCakePrice', tempTierPrice.toString());
      prefs.setString("orderCakeTier", cakeTiers[tierSelIndex]['Tier'].toString());
      prefs.setString("orderCakeTierWeight", cakeTiers[tierSelIndex]['Weight'].toString());
    }else{
      prefs.setString('orderCakeWeight', fixedWeight+"kg");
      prefs.setString('orderCakePrice', cakePrice);
      prefs.setString("orderCakeTier", "null");
      prefs.setString("orderCakeTierWeight", "null");
    }

    prefs.setString('orderCakeDescription', cakeDescription);
    prefs.setString('orderCakeisPremium', vendorID.isNotEmpty?"n":"y");
    prefs.setString('orderCakeDeliverDate', deliverDate);
    prefs.setString('orderCakeDeliverSession',deliverSession);
    prefs.setString('orderCakeDeliverType',fixedDelliverMethod);
    prefs.setString('orderCakeShape',shape);

    //integers
    prefs.setInt('orderCakeItemCount', counts);
    prefs.setInt('orderCakeDiscount', cakeDiscounts);
    prefs.setDouble('orderCakeGst', gst);
    prefs.setDouble('orderCakeSGst', sgst);
    prefs.setDouble('orderCakeItemTotal', addedPrice);
    prefs.setDouble('orderCakeBillTotal', finalPrice);
    prefs.setDouble('orderCakeDelCharge', delCharge);
    prefs.setInt('orderCakePaymentExtra', extraShapeCharge+flavExtraCharge+topperPrice);
    prefs.setInt('orderCakeTopperPrice', topperPrice??0);
    prefs.setInt('orderCakeTaxperc', taxes??0);
    prefs.setDouble('orderCakeDiscountedPrice',discountedPrice ??0);

    //optionals
    prefs.setString('orderCakeMessage', messageCtrl.text.isNotEmpty?messageCtrl.text:"null");//ops
    prefs.setString('orderCakeRequest', specialReqCtrl.text.isNotEmpty?specialReqCtrl.text:"null");//ops
    prefs.setString('orderCakeVendorId', vendorID??'null');//ops
    prefs.setString('orderCakeVendorModId', vendorModID??'null');//ops
    prefs.setString('orderCakeVendorPh1', vendorPhone1??'null');//ops
    prefs.setString('orderCakeVendorPh2', vendorPhone2??'null');//ops
    prefs.setString('orderCakeVendorName', vendorName??'null');//ops
    prefs.setString('orderCakeVendorAddress', vendorAddress??'null');//ops
    prefs.setString('orderCakeTheme', themeTextCtrl.text.isNotEmpty?themeTextCtrl.text:"null");//ops
    prefs.setString('orderCakeThemeImage', file.path.isNotEmpty?file.path.toString():'null');//ops


    if(nearestVendors.length > 0 && double.parse(fixedWeight)<5.0){
      prefs.setString('orderCakeNearestIsEmpty', "no"??'null');
      prefs.setString('orderCakeVendorName', vendorName??'null');//ops
    }else{
      prefs.setString('orderCakeNearestIsEmpty', "yes"??'null');
      prefs.setString('orderCakeVendorName', "Premium Vendor"??'null');
      prefs.setDouble('orderCakeDelCharge', 0);
    }

    //users
    prefs.setString('orderCakeUserID', userID);
    prefs.setString('orderCakeUserModID', userModID);
    prefs.setString('orderCakeUserNum', userPhone);
    prefs.setString('orderCakeDeliverAddress', userAddress);
    prefs.setString('orderCakeUserName', userName);

    //if toppers enabled
    prefs.setString('orderCakeTopperid', topperId??'null');
    prefs.setString('orderCakeTopperName', topperName??'null');
    prefs.setString('orderCakeTopperImg', topperImage??'null');

    print(jsonDecode(shape));

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

  //add new address
  Future<void> saveNewAddress(String street, String city, String district, String pincode) async {
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
        List temp = [];

        List ctypesList = cakesList.where((element) => element['CakeType'].toString().toLowerCase()
            ==cakeType.toLowerCase()).toList();

        print(ctypesList.length);

        for(int i = 0 ; i<ctypesList.length;i++){
          print(ctypesList[i]['VendorID']);

          temp = temp + vendorsList.where((element) =>
          element['_id'].toString().toLowerCase()==ctypesList[i]['VendorID'].toString().toLowerCase()
          ).toList();

        }

        mySelVendors = vendorsList.where((element) => element['_id'].toString().toLowerCase()==vendorID.toLowerCase()).toList();
        print("mySelVendors $mySelVendors");

        nearestVendors = temp.where((element) =>
        calculateDistance(double.parse(userLatitude),double.parse(userLongtitude),
            element['GoogleLocation']['Latitude'],element['GoogleLocation']['Longitude'])<=10
        ).toList();;
        nearestVendors = nearestVendors.toSet().toList();
      });
    } else {}
    print("...end");

    print(nearestVendors.length);

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
                element['CakeType'].toString().toLowerCase().contains(cakeType.toLowerCase().toString()))
            .toList();

        getVendorsList();
        Navigator.pop(context);
      });
    } else {
      Navigator.pop(context);
    }
  }

  void setShapeFixed(int index){
    setState(() {
      fixedShape = shapes[index]['Name'];
      extraShapeCharge = int.parse(shapes[index]['Price'], onError: (e)=>0);
    });
  }


  //changing dynamcially cake based on vendors
  Future<void> loadCakeDetailsByVendor(String venId , String cakesType , [int index = 0,bool selectedFrm = false]) async{

    List artTempList = [];
    String adrss = "";
    List flavour1 = [];
    List shapes1 = [];

    context.read<ContextData>().addMyVendor(false);

    //clear the flavlist
    fixedFlavour = "";
    fixedFlavList.clear();
    multiFlavChecs.clear();
    flavExtraCharge = 0;
    temp.clear();

    //clear the shapes
    fixedShape = "";
    myShapeIndex =-1;
    extraShapeCharge = 0;

    //clear the toppers
    topperPrice = 0;
    topperName = "";
    topperImage = "";
    topperId = "";
    topperIndex = -1;

    //tier
    tierSelIndex = -1;
    tierPrice = 0;
    tempTierPrice = 0;
    tempCakeWeight = "0.0";


    try {
      
      //Change ui based on vendor and cake type
      setState((){
        artTempList = myCakesList
            .where((element) =>
        element['VendorID']
            .toString().toLowerCase() ==
            venId.toString().toLowerCase())
            .toList();

        artTempList = artTempList
            .where((element) => element[
        'CakeType']
            .toString()
            .toLowerCase()
            .contains(cakesType
            .toString()
            .toLowerCase()))
            .toList();

        print("artTempList $artTempList");

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


        cakeImages = artTempList[0]['AdditionalCakeImages'];
        cakeId = artTempList[0]['_id'];
        cakeModId = artTempList[0]['Id'];
        cakeName = artTempList[0]['CakeName'];
        commonCakeName = artTempList[0]['CakeCommonName'];
        cakeBaseFlav = artTempList[0]['BasicFlavour'];
        cakeBaseShape = artTempList[0]['BasicShape'];
        cakePrice = artTempList[0]['BasicCakePrice'];
        defCakePrice = artTempList[0]['BasicCakePrice'];
        cakeEggorEgless = artTempList[0]['DefaultCakeEggOrEggless'];
        cakeEgglessAvail = artTempList[0]['IsEgglessOptionAvailable'];
        cakeEgglessPrice = artTempList[0]['BasicEgglessCostPerKg'];
        basicCakeWeight = artTempList[0]['MinWeight'];
        cakeDescription = artTempList[0]['Description'];
        cakeType = artTempList[0]['CakeType'];
        cakeSubType = artTempList[0]['CakeSubType'];
        cakeRatings = artTempList[0]['Ratings'].toString();
        isThemePossible = artTempList[0]['ThemeCakePossible'];
        isTierPossible = artTempList[0]['IsTierCakePossible'];
        isTopperPossible = artTempList[0]['ToppersPossible'];
        taxes = artTempList[0]['Tax'];
        cakeDiscounts = artTempList[0]['Discount'];
        vendorLat = artTempList[0]['GoogleLocation']['Latitude'];
        vendorLong = artTempList[0]['GoogleLocation']['Longitude'];
        // weight = artTempList[0]['MinWeightList'];

        for(int i = 0 ; i<artTempList[0]['MinWeightList'].length;i++){
          weight.add(artTempList[0]['MinWeightList'][i].toString());
        }

        //Vendor
        vendorID = artTempList[0]['VendorID'];
        vendorModID = artTempList[0]['Vendor_ID'];
        vendorPhone1 = artTempList[0]['VendorPhoneNumber1'];
        vendorPhone2 = artTempList[0]['VendorPhoneNumber2'];
        vendorAddress = "artTempList[0]['VendorAddress']";
        vendorName = artTempList[0]['VendorName'];

        fetchToppersById(vendorID);
        
        print("Users : $userID\n $userName\n $userModID\n $userAddress\n $newRegUser\n $userPhone\n");

        if(weight.isEmpty){
          weight.add(basicCakeWeight);
        }else{
          weight.insert(0, basicCakeWeight);
        }

        cakeTiers = artTempList[0]['TierCakeMinWeightAndPrice'];

        if(cakeImages.isEmpty){
          cakeImages.add(artTempList[0]['MainCakeImage'].toString());
        }else{
          cakeImages.insert(0, artTempList[0]['MainCakeImage'].toString());
        }

        weight = weight.toSet().toList();
        fixedWeight = weight[0].toString();
        weightIndex = 0;
        cakeImages = cakeImages.toSet().toList();

        if(cakeEggorEgless.toLowerCase()=="egg"&&cakeEgglessAvail.toLowerCase()=='y'){
          // showEgglessSheet();
        }

        if(cakeEggorEgless.toLowerCase()=="eggless"){
          isFromEggless = true;
        }


        print(cakeEgglessPrice);

        if(flavour1.isEmpty){
          flavour1.add({"Name":"$cakeBaseFlav","Price":"0"});
        }

        if(shapes1.isEmpty){
          shapes1.add({"Name":"$cakeBaseShape","Price":"0"});
        }

        flavour.clear();
        shapes.clear();
        flavour = artTempList[0]['CustomFlavourList'];
        shapes = artTempList[0]['CustomShapeList']['Info'];

        flavour = flavour.toSet().toList() + flavour1.toSet().toList();
        shapes = shapes.toSet().toList()+shapes1.toSet().toList();

        flavour = flavour.reversed.toList();
        shapes = shapes.reversed.toList();
      });

    } catch (e){

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

  @override
  void initState() {
    // TODO: implement initState
    Future.delayed(Duration.zero , () async{
      getDetailsFromScreen();
    });
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    // TODO: implement initState
    flavour.clear();
    shapes.clear();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.inactive:
        print('appLifeCycleState inactive');
        break;
      case AppLifecycleState.resumed:
        print('appLifeCycleState resumed');
        break;
      case AppLifecycleState.paused:
        print('appLifeCycleState paused');
        break;
      case AppLifecycleState.detached:
        print('appLifeCycleState detached');
        break;
    }
  }

  bool selVendor = false;

  @override
  Widget build(BuildContext context) {
    profileUrl = context.watch<ContextData>().getProfileUrl();
    selVendor = context.watch<ContextData>().getAddedMyVendor();
    if(selVendor == true){
      mySelVendors = context.watch<ContextData>().getMyVendorsList();
      loadCakeDetailsByVendor(mySelVendors[0]['_id'] , cakeType , 0);
      isNearVendrClicked = true;
    }
    if(context.watch<ContextData>().getDpUpdate()==true){
      newRegUser = false;
    }
    if (context.watch<ContextData>().getAddress().isNotEmpty) {
      userAddress = context.watch<ContextData>().getAddress();
    } else {
      userAddress = userAddress;
    }

    return WillPopScope(
      onWillPop: () async {
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
                              GestureDetector(
                                onTap:()=>isFromEggless?
                                null:showEgglessSheet(),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
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
                                            fontWeight: FontWeight.bold
                                        ),
                                      ),
                                  ],
                                ),
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
                                fontWeight: FontWeight.w600
                            ),
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
                                      tempTierPrice!=0?
                                      Text(
                                        "${(tempTierPrice * counts)+flavExtraCharge+extraShapeCharge+topperPrice}",
                                        style: TextStyle(
                                          color: lightPink,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 23,
                                        ),
                                      ):
                                      Text(
                                        ""
                                            "${
                                          ((double.parse(fixedWeight.toLowerCase().replaceAll("kg", ""))*
                                              double.parse(cakePrice)) + (
                                              double.parse(fixedWeight.toLowerCase().replaceAll("kg", ""))*
                                                  double.parse(flavExtraCharge.toString())) +(
                                              double.parse(fixedWeight.toLowerCase().replaceAll("kg", ""))*
                                                  double.parse(extraShapeCharge.toString())) +
                                              double.parse(topperPrice.toString())) * counts
                                        }"
                                            ,
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
                                          fontFamily: "Poppins"
                                      ),
                                    ),
                                    SizedBox(
                                      height: 2,
                                    ),
                                    // fixedFlavList.isEmpty
                                    //     ?
                                    Text(fixedFlavour.isNotEmpty?'$fixedFlavour':'$cakeBaseFlav',
                                            style: TextStyle(
                                                fontFamily: "Poppins",
                                                color: darkBlue,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600),
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
                                    // fixedShape.isEmpty
                                    //     ?
                                    Text(fixedShape.isNotEmpty?'$fixedShape':"$cakeBaseShape",
                                            style: TextStyle(
                                                color: darkBlue,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                fontFamily: "Poppins"
                                                ),
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
                              // Row(
                              //   mainAxisAlignment:
                              //       MainAxisAlignment.spaceBetween,
                              //   children: [
                              //     Text(
                              //       'Theme',
                              //       style: TextStyle(fontFamily: "Poppins"),
                              //     ),
                              //     fixedtheme.isNotEmpty
                              //         ? GestureDetector(
                              //             onTap: () {
                              //               setState(() {
                              //                 fixedtheme = "";
                              //               });
                              //             },
                              //             child: Container(
                              //               width: 100,
                              //               alignment: Alignment.center,
                              //               margin: EdgeInsets.only(right: 100),
                              //               padding: EdgeInsets.symmetric(
                              //                   horizontal: 10, vertical: 3),
                              //               decoration: BoxDecoration(
                              //                 borderRadius:
                              //                     BorderRadius.circular(20),
                              //                 color: lightPink,
                              //               ),
                              //               child: Wrap(
                              //                 children: [
                              //                   Text(
                              //                     '${fixedtheme}',
                              //                     maxLines: 1,
                              //                     overflow:
                              //                         TextOverflow.ellipsis,
                              //                     style: TextStyle(
                              //                         fontFamily: "Poppins",
                              //                         fontSize: 9,
                              //                         color: Colors.white),
                              //                   ),
                              //                 ],
                              //               ),
                              //             ),
                              //           )
                              //         : Container(),
                              //     fixedtheme.isEmpty
                              //         ? GestureDetector(
                              //             onTap: () {
                              //               // showThemeBottomSheet();
                              //               setState((){
                              //
                              //                 if(isThemePossible.toLowerCase()=='y'){
                              //                   themeSectionVisible = !themeSectionVisible;
                              //                 }else{
                              //                   ScaffoldMessenger.of(context).showSnackBar(
                              //                     SnackBar(
                              //                         content: Text("No Custom Themes :("),
                              //                         duration: Duration(seconds: 2),
                              //                     )
                              //                   );
                              //                 }
                              //
                              //               });
                              //             },
                              //             child: Container(
                              //               width: 30,
                              //               height: 30,
                              //               alignment: Alignment.center,
                              //               decoration: BoxDecoration(
                              //                   shape: BoxShape.circle,
                              //                   boxShadow: [
                              //                     BoxShadow(
                              //                         blurRadius: 3,
                              //                         color: Colors.black26,
                              //                         spreadRadius: 1
                              //                     )
                              //                   ],
                              //                   color: Colors.white),
                              //               child: Icon(
                              //                 Icons.add,
                              //                 color: darkBlue,
                              //               ),
                              //             ),
                              //           )
                              //         : CircleAvatar(
                              //             radius: 15,
                              //             backgroundColor: Colors.green,
                              //             child: Icon(
                              //               Icons.check,
                              //               color: Colors.white,
                              //               size: 16,
                              //             )),
                              //   ],
                              // ),
                              // SizedBox(height: 6),
                              // Visibility(
                              //   visible: themeSectionVisible,
                              //   child: Container(
                              //       height:175,
                              //       decoration: BoxDecoration(
                              //         color: Colors.white,
                              //         borderRadius: BorderRadius.circular(18)
                              //       ),
                              //       child: Column(
                              //         children: [
                              //           //theme name editor
                              //           Padding(
                              //             padding: EdgeInsets.all(10),
                              //             child: TextField(
                              //               maxLines: 1,
                              //               style: TextStyle(
                              //                   fontFamily: "Poppins",
                              //                   fontSize: 13
                              //               ),
                              //               controller: themeTextCtrl,
                              //               onChanged: (text){
                              //
                              //               },
                              //               keyboardType: TextInputType.text,
                              //               decoration: InputDecoration(
                              //                 hintText: "Enter Theme Name",
                              //                 hintStyle: TextStyle(
                              //                   fontFamily: "Poppins",
                              //                   fontSize: 13
                              //                 ),
                              //                 contentPadding: EdgeInsets.all(5.0),
                              //                 isDense: true,
                              //               ),
                              //             ),
                              //           ),
                              //
                              //           //Imageview
                              //           Container(
                              //             padding: EdgeInsets.all(8),
                              //             child: Row(
                              //               mainAxisSize: MainAxisSize.min,
                              //               children: [
                              //                 Container(
                              //                   decoration: BoxDecoration(
                              //                     borderRadius: BorderRadius.circular(10),
                              //                     border: Border.all(color: Colors.grey , width: 1.0),
                              //                     image: file.path.isNotEmpty?DecorationImage(
                              //                       image: FileImage(file),
                              //                       fit: BoxFit.cover,
                              //                     ):null
                              //                   ),
                              //                   height: 100,
                              //                   width: 100,
                              //                   child: file.path.isEmpty?
                              //                   Icon(Icons.image_outlined,color:lightPink):
                              //                   null
                              //                 ),
                              //                 SizedBox(width: 10,),
                              //                 RaisedButton(
                              //                     onPressed: (){
                              //                       file.path.isEmpty?
                              //                       imagePicker():
                              //                       setState((){
                              //                         file = new File("");
                              //                       });
                              //                     },
                              //                     child: Text(file.path.isEmpty?'Choose Image':'Remove Image',style:
                              //                       TextStyle(fontFamily: "Poppins", color: Colors.white),),
                              //                     shape: RoundedRectangleBorder(
                              //                       borderRadius: BorderRadius.circular(10)
                              //                     ),
                              //                     color: lightPink,
                              //                 )
                              //               ],
                              //             ),
                              //           ),
                              //
                              //         ],
                              //       ),
                              //   ),
                              // ),
                              // SizedBox(height: 6),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [

                                  Row(
                                    children: [
                                      Text(
                                        'Flavours',
                                        style: TextStyle(fontFamily: "Poppins"),
                                      ),
                                      fixedFlavour != "" ?
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            fixedFlavour = "";
                                            fixedFlavList.clear();
                                            multiFlavChecs.clear();
                                            flavExtraCharge = 0;
                                            temp.clear();
                                          });
                                        },
                                        child: Container(
                                          alignment: Alignment.centerLeft,
                                          margin: EdgeInsets.only(right: 0),
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 3
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                            BorderRadius.circular(17),
                                            color: lightPink,
                                          ),
                                          child: Text(
                                            "${fixedFlavList.length} Selected Flavs",
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                fontFamily: "Poppins",
                                                fontSize: 9,
                                                color: Colors.white
                                            ),
                                          ),
                                        ),
                                      ) :
                                      Container(),
                                    ],
                                  ),
                                  Expanded(
                                      child: Container(
                                        alignment: Alignment.centerRight,
                                        child: fixedFlavour.isEmpty
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
                                      )
                                  )
                                ],
                              ),
                              SizedBox(height: 6),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [

                                  Row(
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
                                            myShapeIndex =-1;
                                            extraShapeCharge = 0;
                                          });
                                        },
                                        child: Container(
                                          alignment: Alignment.center,
                                          margin: EdgeInsets.only(right: 0),
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
                                    ],
                                  ),

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
                              SizedBox(height: 6),
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [

                                  Row(
                                    children:[
                                      Text(
                                        'Toppers',
                                        style: TextStyle(fontFamily: "Poppins"),
                                      ),
                                      topperName != ""
                                          ? GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            topperPrice = 0;
                                            topperName = "";
                                            topperImage = "";
                                            topperId = "";
                                            topperIndex = -1;
                                          });
                                        },
                                        child: Container(
                                          alignment: Alignment.center,
                                          margin: EdgeInsets.only(right: 120),
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 3
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                            BorderRadius.circular(17),
                                            color: lightPink,
                                          ),
                                          child: Text(
                                            "${topperName.split(' ').first}",
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                fontFamily: "Poppins",
                                                fontSize: 9,
                                                color: Colors.white
                                            ),
                                          ),
                                        ),
                                      )
                                          : Container(),
                                    ]
                                  ),

                                  topperName.isEmpty ?
                                  GestureDetector(
                                    onTap: () {

                                      if(isTopperPossible.toLowerCase()=="y"){
                                        showCakeTopperSheet();
                                      }else{
                                        ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text("No Custom Toppers :("),
                                              duration: Duration(seconds: 2),
                                            )
                                        );
                                      }

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
                                  ):
                                  CircleAvatar(
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
                            ],
                          ),
                        ),


                        //Weight Area
                        Visibility(
                          visible: tierSelIndex==-1?true:false,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 10.0, bottom: 5, left: 15
                                ),
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
                                                  if(weight[index].toString().contains("500")){

                                                    print("Yes"+weight[index].toString().split("g").first);
                                                    // fixedWeight = weight[index].toString().split("g")[0]+"kg";
                                                    fixedWeight = (double.parse(weight[index].toString().split("g").first)/1000).toString()+"kg";
                                                    // print(500/1000);

                                                  }else{
                                                    fixedWeight = double.parse(weight[index].toString().toLowerCase().replaceAll("kg", "")).toString();
                                                    print("no..");
                                                  }

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
                                                      color: Colors.grey[400]!, width: 1),
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
                                            ));
                                      })),

                              //sho
                              Container(
                                padding: EdgeInsets.only(
                                  left: 15,bottom: 8,top: 8
                                ),
                                child: Text(
                                  double.parse(fixedWeight.toString().toLowerCase().replaceAll('kg', ''))>=3.0?
                                  'Min Delivery Time Of Cake $thrkgdeltime':
                                  double.parse(fixedWeight.toString().toLowerCase().replaceAll('kg', ''))>=5.0?
                                  "Min Delivery Time Of Cake $fvkgdeltime":
                                  'Min Delivery Time Of Cake $cakeMindeltime',
                                  style: TextStyle(
                                    color: lightPink,
                                    fontFamily: "Poppins",
                                    fontSize: 13
                                  ),
                                ),
                              ),

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
                                            FilteringTextInputFormatter.allow(new RegExp('[0-9.]')),
                                            FilteringTextInputFormatter.allow(RegExp(r'^(\d+)?\.?\d{0,2}')),
                                            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')),
                                            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*'))!,
                                          ],
                                          onChanged: (String text) {
                                            setState((){
                                              if (customweightCtrl.text.isNotEmpty) {
                                                weightIndex = -1;
                                                fixedWeight = customweightCtrl.text+"kg";
                                                print("weight is $fixedWeight");
                                              } else {
                                                weightIndex = 0;
                                                fixedWeight = weight[0].toString();
                                              }
                                            });
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
                                                          fontFamily: 'Poppins')
                                                  ),
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
                            ],
                          ),
                        ),

                        //Cake Tier
                        // isTierPossible.toLowerCase()=="y"?
                        // Column(
                        //   crossAxisAlignment: CrossAxisAlignment.start,
                        //   children: [
                        //     Padding(
                        //       padding: const EdgeInsets.only(
                        //           top: 10.0, bottom: 5, left: 15),
                        //       child: Text(
                        //         'Cake Tier',
                        //         style: TextStyle(
                        //             color: darkBlue, fontFamily: "Poppins"),
                        //       ),
                        //     ),
                        //     Container(
                        //         height: MediaQuery.of(context).size.height * 0.057,
                        //         width: MediaQuery.of(context).size.width,
                        //         margin: EdgeInsets.symmetric(horizontal: 10),
                        //         //  color: Colors.grey,
                        //         child: ListView.builder(
                        //             itemCount: cakeTiers.length,
                        //             scrollDirection: Axis.horizontal,
                        //             itemBuilder: (context, index) {
                        //               selwIndex.add(false);
                        //               return InkWell(
                        //                   onTap: () {
                        //                     print(cakeTiers[index]);
                        //                     FocusScope.of(context).unfocus();
                        //                     setState(() {
                        //                       if(tierSelIndex==index){
                        //                         tierSelIndex = -1;
                        //                         tierPrice = 0;
                        //                         tempTierPrice = 0;
                        //                         tempCakeWeight = "0.0";
                        //                       }else{
                        //                         tierSelIndex = index;
                        //                         tierPrice = double
                        //                             .parse(cakeTiers[index]['Price'].toString());
                        //                         tempTierPrice = tierPrice;
                        //                         tempCakeWeight = cakeTiers[index]['Weight'].toString();
                        //                       }
                        //                     });
                        //                   },
                        //                   child: Container(
                        //                     alignment: Alignment.center,
                        //                     padding: EdgeInsets.symmetric(
                        //                         horizontal: 13),
                        //                     // height:10,
                        //                     margin: EdgeInsets.only(
                        //                         left: 9, top: 9, bottom: 9),
                        //                     decoration: BoxDecoration(
                        //                         borderRadius:
                        //                         BorderRadius.circular(20),
                        //                         border: Border.all(
                        //                             color: lightPink, width: 1),
                        //                         color: tierSelIndex == index
                        //                             ? Colors.pink
                        //                             : Colors.white),
                        //                     child: Text(
                        //                       "${cakeTiers[index]['Tier']}",
                        //                       style: TextStyle(
                        //                         fontWeight: FontWeight.bold,
                        //                         fontFamily: poppins,
                        //                         color: tierSelIndex == index
                        //                             ? Colors.white
                        //                             : darkBlue,
                        //                         fontSize: 13.5,
                        //                       ),
                        //                     ),
                        //                   ));
                        //             })),
                        //   ],
                        // ):
                        // Container(),
                        // Container(
                        //     margin: EdgeInsets.symmetric(horizontal: 15),
                        //     child: Divider(
                        //       color: Colors.pink[100],
                        //     )),

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
                                    ],
                                  ),
                                ),

                                // //Articlessss
                                // Padding(
                                //   padding: const EdgeInsets.only(top: 10),
                                //   child: Text(
                                //     ' Articles',
                                //     style: TextStyle(
                                //         fontFamily: "Poppins", color: darkBlue),
                                //   ),
                                // ),
                                //
                                // Container(
                                //     child: ListView.builder(
                                //   shrinkWrap: true,
                                //   physics: NeverScrollableScrollPhysics(),
                                //   itemCount: articals.length,
                                //   itemBuilder: (context, index) {
                                //     return InkWell(
                                //       onTap: () {
                                //         setState(() {
                                //           if (articGroupVal == index) {
                                //             articGroupVal = -1;
                                //             fixedArticle = 'None';
                                //             articleExtraCharge = 0;
                                //           } else {
                                //             articGroupVal = index;
                                //             fixedArticle = articals[index]
                                //                     ['Name']
                                //                 .toString();
                                //             articleExtraCharge = int.parse(
                                //                 articals[index]['Price']
                                //                     .toString());
                                //             ScaffoldMessenger.of(context)
                                //                 .showSnackBar(SnackBar(
                                //               content: Text('Price Updated!'),
                                //               duration: Duration(seconds: 2),
                                //             ));
                                //           }
                                //         });
                                //       },
                                //       child: Container(
                                //           padding: EdgeInsets.only(
                                //               top: 5, bottom: 5, left: 8),
                                //           child: Row(children: [
                                //             articGroupVal != index
                                //                 ? Icon(
                                //                     Icons
                                //                         .radio_button_unchecked_rounded,
                                //                     color: Colors.black)
                                //                 : Icon(
                                //                     Icons.check_circle_rounded,
                                //                     color: Colors.green),
                                //             SizedBox(width: 6),
                                //             Expanded(
                                //                 child: Text.rich(
                                //                     TextSpan(children: [
                                //               TextSpan(
                                //                   text:
                                //                       '${articals[index]['Name']} - ',
                                //                   style: TextStyle(
                                //                     color: Colors.grey,
                                //                     fontFamily: "Poppins",
                                //                   )),
                                //               TextSpan(
                                //                   text:
                                //                       'Rs.${articals[index]['Price']}',
                                //                   style: TextStyle(
                                //                     color: Colors.black,
                                //                     fontFamily: "Poppins",
                                //                     fontWeight: FontWeight.bold,
                                //                   ))
                                //             ])))
                                //           ])),
                                //     );
                                //   },
                                // )),

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
                                      fillColor: Colors.grey[300],
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
                                  padding: EdgeInsets.only(top: 10, left: 6),
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
                                      splashColor: Colors.grey,
                                      onTap: () {
                                        FocusScope.of(context).unfocus();
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
                                                  color: Colors.grey,
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
                                      top: 10, left: 6, bottom: 5),
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
                                                  
                                                  color: Colors.grey,
                                                  fontSize: 13),
                                            ),
                                            Icon(Icons.edit_calendar_outlined,
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
                                                              'Morning 8 - 9', style: TextStyle(fontFamily: "Poppins"),),
                                                          onTap: () {
                                                            setState(() {
                                                              deliverSession =
                                                                  'Morning 8 - 9';
                                                            });
                                                          }),
                                                      PopupMenuItem(
                                                          child: Text(
                                                              'Morning 9 - 10', style: TextStyle(fontFamily: "Poppins"),),
                                                          onTap: () {
                                                            setState(() {
                                                              deliverSession =
                                                                  'Morning 9 - 10';
                                                            });
                                                          }),
                                                      PopupMenuItem(
                                                          child: Text(
                                                              'Morning 10 - 11', style: TextStyle(fontFamily: "Poppins"),),
                                                          onTap: () {
                                                            setState(() {
                                                              deliverSession =
                                                                  'Morning 10 - 11';
                                                            });
                                                          }),
                                                      PopupMenuItem(
                                                          child: Text(
                                                              'Morning 11 - 12', style: TextStyle(fontFamily: "Poppins"),),
                                                          onTap: () {
                                                            setState(() {
                                                              deliverSession =
                                                                  'Morning 11 - 12';
                                                            });
                                                          }),
                                                      PopupMenuItem(
                                                          child: Text(
                                                              'Afternoon 12 - 1', style: TextStyle(fontFamily: "Poppins"),),
                                                          onTap: () {
                                                            setState(() {
                                                              deliverSession =
                                                                  'Afternoon 12 - 1';
                                                            });
                                                          }),
                                                      PopupMenuItem(
                                                          child: Text(
                                                              'Afternoon 1 - 2', style: TextStyle(fontFamily: "Poppins"),),
                                                          onTap: () {
                                                            setState(() {
                                                              deliverSession =
                                                                  'Afternoon 1 - 9';
                                                            });
                                                          }),
                                                      PopupMenuItem(
                                                          child: Text(
                                                              'Afternoon 2 - 3', style: TextStyle(fontFamily: "Poppins"),),
                                                          onTap: () {
                                                            setState(() {
                                                              deliverSession =
                                                                  'Afternoon 8 - 9';
                                                            });
                                                          }),
                                                      PopupMenuItem(
                                                          child: Text(
                                                              'Afternoon 3 - 4', style: TextStyle(fontFamily: "Poppins"),),
                                                          onTap: () {
                                                            setState(() {
                                                              deliverSession =
                                                                  'Afternoon 3 - 4';
                                                            });
                                                          }),
                                                      PopupMenuItem(
                                                          child: Text(
                                                              'Afternoon 4 - 5', style: TextStyle(fontFamily: "Poppins"),),
                                                          onTap: () {
                                                            setState(() {
                                                              deliverSession =
                                                                  'Afternoon 4 - 5';
                                                            });
                                                          }),
                                                      PopupMenuItem(
                                                          child: Text(
                                                              'Evening 5 - 6', style: TextStyle(fontFamily: "Poppins"),),
                                                          onTap: () {
                                                            setState(() {
                                                              deliverSession =
                                                                  'Evening 5 - 6';
                                                            });
                                                          }),
                                                      PopupMenuItem(
                                                          child: Text(
                                                              'Evening 6 - 7', style: TextStyle(fontFamily: "Poppins"),),
                                                          onTap: () {
                                                            setState(() {
                                                              deliverSession =
                                                                  'Evening 6 - 7';
                                                            });
                                                          }),
                                                      PopupMenuItem(
                                                          child: Text(
                                                              'Evening 7 - 8', style: TextStyle(fontFamily: "Poppins"),),
                                                          onTap: () {
                                                            setState(() {
                                                              deliverSession =
                                                                  'Evening 7 - 8';
                                                            });
                                                          }),
                                                      PopupMenuItem(
                                                          child: Text(
                                                              'Evening 8 - 9', style: TextStyle(fontFamily: "Poppins"),),
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

                                                  color: Colors.grey,
                                                  fontSize: 13),
                                            ),
                                            Icon(Icons.keyboard_arrow_down,
                                                color: darkBlue)
                                          ])),
                                ),
                              ],
                            )),

                        fixedDelliverMethod.toLowerCase()=="delivery"?Column(
                          crossAxisAlignment: CrossAxisAlignment.start,  
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 10.0),
                              child: Text(
                                ' Address',
                                style:
                                    TextStyle(fontFamily: poppins, color: darkBlue),
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ListTile(
                                  title: Text(
                                    '${userAddress.trim()}',
                                    style: TextStyle(
                                        fontFamily: poppins,
                                        color: Colors.grey,
                                        fontSize: 13),
                                  ),
                                  trailing:
                                      Icon(Icons.check_circle, color: Colors.green ,size: 25,),
                                ),
                                GestureDetector(
                                  onTap: (){
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => AddressScreen()));
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 14),
                                    child: Text(
                                      'add new address',
                                      style: const TextStyle(
                                          color: Colors.orange,
                                          fontFamily: "Poppins",
                                          decoration: TextDecoration.underline),
                                    ),
                                  ),
                                ),


                              ],
                            ),
                            SizedBox(
                              height: 15,
                            ),
                          ],
                        ):Container(),

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
                                                double.parse(fixedWeight.toLowerCase()
                                                        .replaceAll("kg", "")) <
                                                    5.0
                                            ? Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  isNearVendrClicked == true ?
                                                  Text('Selected Vendor',
                                                          style: TextStyle(
                                                              fontSize: 15,
                                                              color: darkBlue,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontFamily:
                                                                  poppins),
                                                        ) : Container(),

                                                  isNearVendrClicked == true ?
                                                  SizedBox(
                                                    height: 10,
                                                  ):Container(),

                                                  isNearVendrClicked == true ?
                                                  InkWell(
                                                          onTap: () async{

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
                                                            pref.setString('singleVendorID', mySelVendors[0]['_id']??'null');
                                                            pref.setBool('singleVendorFromCd', true);
                                                            pref.setString('singleVendorRate', mySelVendors[0]['Ratings'].toString()??'0.0');
                                                            pref.setString('singleVendorName', mySelVendors[0]['VendorName']??'null');
                                                            pref.setString('singleVendorDesc', mySelVendors[0]['Description']??'null');
                                                            pref.setString('singleVendorPhone1', mySelVendors[0]['PhoneNumber1']??'null');
                                                            pref.setString('singleVendorPhone2', mySelVendors[0]['PhoneNumber2']??'null');
                                                            pref.setString('singleVendorDpImage', mySelVendors[0]['ProfileImage']??'null');
                                                            pref.setString('singleVendorAddress', mySelVendors[0]['Address']??'null');
                                                            pref.setString('singleVendorSpecial', mySelVendors[0]['YourSpecialityCakes'].toString()??'null');


                                                            Navigator.push(context,
                                                             MaterialPageRoute(
                                                                 builder: (context)=>SingleVendor()
                                                             )
                                                            );
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
                                                                mySelVendors[0]['ProfileImage'] != null
                                                                    ? Container(
                                                                        width:
                                                                            90,
                                                                        height:
                                                                            100,
                                                                        decoration: BoxDecoration(
                                                                            color:
                                                                                Colors.red,
                                                                            borderRadius: BorderRadius.circular(10),
                                                                            image: DecorationImage(image: NetworkImage(mySelVendors[0]['ProfileImage'].toString()), fit: BoxFit.cover)),
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
                                                                            image: DecorationImage(image: AssetImage("assets/images/vendorimage.jpeg"), fit: BoxFit.cover)),
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
                                                                                      initialRating:double.parse(mySelVendors[0]['Ratings'].toString()),
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
                                                                                      ' ${mySelVendors[0]['Ratings'].toString().characters.take(3)}',
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
                                                                        "Speciality in ${mySelVendors[0]['YourSpecialityCakes'].
                                                                        toString().replaceAll("[", "").replaceAll("]", "")}",
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
                                                                                mySelVendors[0]['EggOrEggless']=="Both"?'Egg And Eggless':"${mySelVendors[0]['EggOrEggless']}",
                                                                                style: TextStyle(
                                                                                  fontSize: 11,
                                                                                  fontFamily: "Poppins",
                                                                                  color: darkBlue,
                                                                                ),
                                                                                maxLines: 1,
                                                                              ),
                                                                              SizedBox(height: 3),
                                                                              Text(
                                                                                "${
                                                                                    (calculateDistance(double.parse(userLatitude),
                                                                                        double.parse(userLongtitude),
                                                                                        mySelVendors[0]['GoogleLocation']['Latitude'],
                                                                                        mySelVendors[0]['GoogleLocation']['Longitude'])).toInt()
                                                                                } KM Charge Rs.${
                                                                                    (adminDeliveryCharge/adminDeliveryChargeKm)*
                                                                                        (calculateDistance(double.parse(userLatitude),
                                                                                            double.parse(userLongtitude),
                                                                                            mySelVendors[0]['GoogleLocation']['Latitude'],
                                                                                            mySelVendors[0]['GoogleLocation']['Longitude'])).toInt()
                                                                                }",
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
                                                                                    PhoneDialog().showPhoneDialog(context, mySelVendors[0]['PhoneNumber1'], mySelVendors[0]['PhoneNumber2']);
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
                                                                                    PhoneDialog().showPhoneDialog(context, mySelVendors[0]['PhoneNumber1'],
                                                                                        mySelVendors[0]['PhoneNumber2'], true);
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
                                                        ) : Container(),

                                                  SizedBox(
                                                    height: 10,
                                                  ),

                                                  !vendorCakeMode?
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

                                                          pref.setString("passCakeType","$cakeType");

                                                          setState(() {
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
                                                  ):Container(),
                                                  !vendorCakeMode?
                                                  SizedBox(
                                                    height: 10,
                                                  ):Container(),
                                                  !vendorCakeMode?
                                                  Container(
                                                    height: 200,
                                                    child: ListView.builder(
                                                        scrollDirection: Axis.horizontal,
                                                        shrinkWrap: true,
                                                        itemCount: nearestVendors.length > 5?5:nearestVendors.length,
                                                        itemBuilder:
                                                            (context, index) {
                                                          return Card(
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10)),
                                                            child: InkWell(
                                                              splashColor: Colors.red[200],
                                                              onTap: () {

                                                                context.read<ContextData>().addMyVendor(false);
                                                                context.read<ContextData>().setMyVendors([]);

                                                                setState(() {
                                                                   selVendorIndex = index;
                                                                   mySelVendors = [nearestVendors[index]];
                                                                   isNearVendrClicked = true;
                                                                   print(mySelVendors);
                                                                   loadCakeDetailsByVendor(mySelVendors[0]['_id'].toString(), cakeType , 0);
                                                                });
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
                                                                                        onRatingUpdate: (rating) {
                                                                                          print(rating);
                                                                                        },
                                                                                      ),
                                                                                      Text(
                                                                                        ' ${nearestVendors[index]['Ratings'].toString().characters.take(3)}',
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
                                                                      color: Color(0xffeeeeee)
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
                                                                            // index==0?Text(
                                                                            //    "DELIVERY FREE",
                                                                            //   style: TextStyle(color: Colors.orange, fontSize: 10, fontFamily: "Poppins"),
                                                                            // ):
                                                                            Text(
                                                                              "${
                                                                                  (calculateDistance(double.parse(userLatitude),
                                                                                      double.parse(userLongtitude),
                                                                                      nearestVendors[index]['GoogleLocation']['Latitude'],
                                                                                      nearestVendors[index]['GoogleLocation']['Longitude'])).toInt()
                                                                              } KM Charge Rs.${
                                                                                  (adminDeliveryCharge/adminDeliveryChargeKm)*
                                                                                      (calculateDistance(double.parse(userLatitude),
                                                                                          double.parse(userLongtitude),
                                                                                          nearestVendors[index]['GoogleLocation']['Latitude'],
                                                                                          nearestVendors[index]['GoogleLocation']['Longitude'])).toInt()
                                                                              }",
                                                                              style: TextStyle(color: Colors.orange, fontSize: 10, fontFamily: "Poppins"),
                                                                            )
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
                                                  ):
                                                  Container(),
                                                ],
                                              ) :
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
                                                          fontSize: 18
                                                      ))
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
                                        if(customweightCtrl.text=="0"||customweightCtrl.text=="0.0"||
                                            customweightCtrl.text.startsWith("0")&&
                                                customweightCtrl.text.endsWith("0")){
                                          ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                  content: Text("Please enter correct weight or select weight!")
                                              )
                                          );
                                        }
                                        else if(deliverDate.toLowerCase()=="not yet select"){
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text("Please select deliver date"))
                                          );
                                        }else if(deliverSession.toLowerCase()=="not yet select"){
                                          ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text("Please select deliver session"))
                                          );
                                        }else if(fixedDelliverMethod.isEmpty){
                                          ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text("Please select pickup or delivery"))
                                          );
                                        }else{
                                          loadOrderPreference();
                                        }
                                      }
                                    },
                                    color: lightPink,
                                    child: Text(
                                      "ORDER NOW",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold
                                      ),
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

