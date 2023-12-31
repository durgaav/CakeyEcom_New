import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:cakey/Dialogs.dart';
import 'package:cakey/DrawerScreens/VendorsList.dart';
import 'package:cakey/drawermenu/CustomAppBars.dart';
import 'package:cakey/functions.dart';
import 'package:cakey/raised_button_utils.dart';
import 'package:cakey/screens/CheckOut.dart';
import 'package:cakey/screens/OrderConfirm.dart';
import 'package:cakey/screens/SingleVendor.dart';
import 'package:cakey/screens/utils.dart';
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
import '../DrawerScreens/CakeTypes.dart';
import '../DrawerScreens/CustomiseCake.dart';
import '../DrawerScreens/Notifications.dart';
import '../PaymentGateway.dart';
import '../ProfileDialog.dart';
import '../ShowToFarDialog.dart';
import '../drawermenu/app_bar.dart';
import 'AddressScreen.dart';
import 'Profile.dart';
import 'package:http/http.dart' as http;
import 'package:expandable_text/expandable_text.dart';

class CakeDetails extends StatefulWidget {
  // const CakeDetails({Key? key}) : super(key: key);
  List shapes, flavour, articals , cakeTiers , tiersDelTimes;
  var data = {};
  CakeDetails(this.shapes, this.flavour, this.articals ,this.cakeTiers ,this.tiersDelTimes,this.data);

  @override
  State<CakeDetails> createState() =>
      _CakeDetailsState(shapes, flavour, articals , cakeTiers , tiersDelTimes,data);
}

class _CakeDetailsState extends State<CakeDetails> with WidgetsBindingObserver{
  List shapes, flavour, articals , cakeTiers , tiersDelTimes;
  var data = {};
  _CakeDetailsState(this.shapes, this.flavour, this.articals , this.cakeTiers , this.tiersDelTimes,this.data);

  //region VARIABLES
  //colors.....
  String poppins = "Poppins";
  Color darkBlue = Color(0xffF213959);
  Color lightPink = Color(0xffFE8416D);
  Color lightGrey = Color(0xffF5F5F5);

  var tooFar = false;

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
  String onekgdeltime = "";
  String twokgdeltime = "";
  String cakeMindeltime = "";
  String otherInstruction = "";

  String firstVenIndex = "";
  String firstVenAmount = "";
  bool egglessSwitch = false;

  //load context vendor...
  bool isMySelVen = false;
  List mySelVendors = [];

  //Lists...
  List cakeImages = [];
  List cakesList = [];
  List myCakesList = [];
  List<String> deliverAddress = [];
  var deliverAddressIndex = -1;

  var multiFlav = [];
  List<bool> multiFlavChecs = [];
  List<bool> multiThemeList = [];

  int notiCount = 0;

  bool showThemeSheet = true;

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
  String eggEggless = "";
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
  String estimatedDeliverTime = "";

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
  String minDelTierTime = "";

  //For orders
  String deliverDate = 'Select delivery date';
  String deliverSession = 'Select delivery time';
  //Doubt flav
  String fixedFlavour = '';
  var fixedFlavList = [];
  //

  //Shape
  var myShapeIndex = -1;
  String fixedShape = '';
  String fixedtheme = '';
  String fixedWeight = '1.0';
  String myWeight = "";
  String cakeMsg = '';
  String specialReq = '';
  String fixedAddress = '';
  String fixedDelliverMethod = "";
  String selectedDropWeight = 'Kg';
  
  List<String> cakeTypesList = [];

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

  //new GLOBAL

  int itemCounts = 1;

  double productPrice = 0;
  double commonTotalWeight = 1;
  double shapeTotalPrice = 0;
  double flavourTotalPrice = 0;

  List totalImages = [];
  List totalWeightList = [];

  String minimamFinalWeight = "";
  String selectedFinalShape = "";
  String selectedFinalFlav = "";



  //endregion

  //region Alerts

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

  //theme select bottom sheet......

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
                    height: 12,
                  ),
                  Container(
                    height: 0.6,
                    color: Colors.grey[400],
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

                  Center(
                    child: Container(
                      margin: EdgeInsets.all(15),
                      height: 45,
                      width: 120,
                      child: CustomRaisedButton(
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
                    height: 12,
                  ),
                  Container(
                    height: 0.6,
                    color: Colors.grey[400],
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
                                  print(shapes[index]);
                                  // myWeight = shapes[index]['MinWeight'].toString();
                                  // fixedWeight = changeKilo(shapes[index]['MinWeight'].toString());
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
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(
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
                                            Text(
                                              shapes[index]['MinWeight'].toString()=='null'?
                                              " min weight ${weight[0]}":
                                              " min weight "+shapes[index]['MinWeight'].toString().
                                              toLowerCase().replaceAll("kg", "")+"Kg",
                                              style: TextStyle(
                                                  fontFamily: "Poppins",
                                                  color: Colors.black,
                                                  fontSize: 13
                                              ),
                                            )
                                          ],
                                        ),
                                    )
                                  ])),
                            );
                          }),
                    ),
                  ),

                  Center(
                    child: Container(
                      margin: EdgeInsets.all(15),
                      height: 45,
                      width: 120,
                      child: CustomRaisedButton(
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
                      height: 12,
                    ),
                    Container(
                      height: 0.6,
                      color: Colors.grey[400],
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
                                                    image: NetworkImage(toppersList[i]['TopperImage']),
                                                    fit:BoxFit.cover
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

                    Center(
                      child: Container(
                        margin: EdgeInsets.all(15),
                        height: 45,
                        width: 120,
                        child: CustomRaisedButton(
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

        Functions().showSnackMsg(context, "Price updated!", false);
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

  //apply egg cake
  void applyEggCake(){

    setState((){
      eggEggless = 'Egg';
      cakePrice = defCakePrice;
      egglessSwitch = false;
    });
  }

  //apply Eggless cake...
  void applyEgglessCake(){

    setState((){
      eggEggless = 'Eggless';
      cakePrice = cakeEgglessPrice;
      egglessSwitch = true;
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
                        child: CustomRaisedButton(
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

  //handleNavigation to pg;
  Future<void> handleNavigation() async{

    var paymentObj = {
      "img": data['MainCakeImage'],
      "name": data['CakeName'],
      "egg":eggEggless,
      "price": data['BasicCakePrice'],
      "count":counts,
      "vendor":data['VendorName'],
      "type": "Cakes",
      "details": data,
      "deliverType": fixedDelliverMethod,
      "deliveryAddress": "deliveryAddress",
      "deliverDate":deliverDate,
      "deliverSession":deliverSession,
      "deliverCharge":fixedDelliverMethod.toLowerCase()=="pickup"?0:((adminDeliveryCharge / adminDeliveryChargeKm)*(calculateDistance(double.parse(userLatitude), double.parse(userLongtitude),
          double.parse(vendorLat), double.parse(vendorLong)))),
      "discount":0,
    };

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (c) => PaymentGateway(
              paymentObjs: paymentObj,
            )
        )
    );

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

  //fetch toppers by ven id..
  Future<void> fetchToppersById(String id) async{
    print("V : $id");
    print("entered...top");

    var res = await http.get(
        Uri.parse("${API_URL}api/toppers/listbyvendorandstock/$id"),
        headers: {"Authorization": "$authToken"});

    print(authToken);
    print(res.body);

    if(res.statusCode==200){

      setState((){
        print('body test...');
        print(res.body);
        if(res.body.length < 50){
        }else{
          toppersList = jsonDecode(res.body);
        }
      });

    }else{
      setState((){
        toppersList = [];
      });
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

      firstVenIndex = prefs.getString('firstVenIndex')??'2';
      firstVenAmount = prefs.getString('firstVenDelCharge')??'0';


      print("del free ven :$firstVenIndex");

      // if(cakeType.contains("Regular") || cakeType.contains("regular") ||
      //     cakeType.contains("Regular Cake") ||
      //     cakeType.contains("Regular Cakes") ||
      //     cakeType.contains("Regular cakes") || cakeType.contains("Normal") ||
      //     cakeType.contains("Normal Cakes") || cakeType.contains("Normal cakes") || cakeType.contains("normal")){
      //
      //   firstVenIndex = "0";
      //
      // }else{
      //   firstVenIndex = "-1";
      // }

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
      eggEggless = prefs.getString('cakeEggorEggless')!;
      cakeEgglessAvail = prefs.getString('cakeEgglessAvail')!;
      cakeEgglessPrice = prefs.getString('cakeEgglesCost')!;
      basicCakeWeight = prefs.getString('cakeMinWeight')!;
      otherInstruction = prefs.getString('cakeOtherInstToCus')??"None";

      fixedWeight = basicCakeWeight;
      myWeight = basicCakeWeight;

      print("egg avail ");
      print(fixedWeight);
      print("egg avail******");

      cakeDescription = prefs.getString('cakeDescription')!;
      cakeType = prefs.getString('cakeType')!;
      cakeSubType = prefs.getString('cakeSubType')!;
      print("Current type ${cakeSubType.toLowerCase()}");
      cakeRatings = prefs.getDouble('cakeRating')!.toString();
      isThemePossible = prefs.getString('cakeThemePoss')!.toString();
      isTierPossible = prefs.getString('cakeTierPoss')!.toString();
      isTopperPossible = prefs.getString('cakeTopperPoss')!.toString();
      taxes = prefs.getInt("cakeTax")!;
      cakeDiscounts = prefs.getInt("cakeDiscount")!;
      weight = prefs.getStringList('cakeWeights')!;
      vendorLat = prefs.getString('cakeVendorLatitu')!;
      vendorLong = prefs.getString('cakeVendorLongti')!;

      thrkgdeltime = prefs.getString('cakeminfortofivTime')!;
      fvkgdeltime = prefs.getString('cakeminabovfiveTime')!;
      onekgdeltime = prefs.getString('cakeminbetwokgTime')!;
      twokgdeltime = prefs.getString('cakemintwotoourTime')!;
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
      
      //types of cake list
      cakeTypesList = prefs.getStringList("cakeMainTypes")??["none"];

      //topper fetch...
      fetchToppersById(vendorID);

      //user
      userPhone = prefs.getString("phoneNumber") ?? "";
      userID = prefs.getString("userID") ?? "";
      userModID = prefs.getString("userModId") ?? "";
      userName = prefs.getString("userName") ?? "";
      userAddress = prefs.getString('userCurrentLocation') ?? 'None';
      deliverAddress = prefs.getStringList('addressList')??[userAddress.trim()];
      newRegUser = prefs.getBool('newRegUser') ?? false;

      print("Users : $vendorID\n $userName\n $userModID\n $userAddress\n $newRegUser\n $userPhone\n");

      cakeImages = cakeImages.toSet().toList();

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


      print(cakeType);

      if(cakeType.contains("Regular") || cakeType.contains("Normal")){

        if(firstVenIndex=="2"){
          firstVenIndex = "-1";
        }else{
          firstVenIndex = "0";
        }

      }else{
        firstVenIndex = "-1";
      }

      print("1st ven...");
      print(firstVenIndex);
      print(firstVenAmount);


      if(weight.isEmpty){
        weight.add(basicCakeWeight);
      }else{
        weight.insert(weight.indexOf(weight.last), basicCakeWeight);
      }

      weight = weight.toSet().toList();

      if(cakeImages.isEmpty){
        cakeImages.add(prefs.getString('cakeMainImage').toString());
      }else{
        cakeImages.insert(0, prefs.getString('cakeMainImage').toString());
      }

      weight = weight.toSet().toList();

    });
    // context.read<ContextData>().addMyVendor(false);
    // context.read<ContextData>().setMyVendors([]);
    getCakesList();
  }

  //***load prefs to ORDER.....***
  Future<void> loadOrderPreference() async {
    var prefs = await SharedPreferences.getInstance();


    print("My cake type $cakeType");



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

    var deliverCharge = double.parse("${((adminDeliveryCharge / adminDeliveryChargeKm) *
        (calculateDistance(double.parse(userLatitude),
            double.parse(userLongtitude),nearestVendors[0]['GoogleLocation']['Latitude'],
            nearestVendors[0]['GoogleLocation']['Longitude'])))}").toStringAsFixed(1);
    var betweenKm = (calculateDistance(double.parse(userLatitude),
        double.parse(userLongtitude), nearestVendors[0]['GoogleLocation']['Latitude'],
        nearestVendors[0]['GoogleLocation']['Longitude'])).toStringAsFixed(1);

    String dlintKm = "";

    print("Location KM...$betweenKm");

    if(mySelVendors.isEmpty||nearestVendors.isEmpty){
      dlintKm = "0.0";
    }else{
      if(double.parse(betweenKm)<2.0){
        dlintKm = "0.0";
      }else{
        dlintKm = deliverCharge;
      }
    }

    // if(cakeType.contains("Regular") || cakeType.contains("Normal")){
    //
    //   if(firstVenIndex=="0"||firstVenIndex=="1"){
    //     dlintKm = "0";
    //   }
    //
    // }

    print("deliver based km $dlintKm");

    //variables for calculations
    double price = 0 , tax = 0, gst = 0 , sgst = 0 , discount = 0
    ,itemCount = 0, total = 0 , extra = 0 ,
        delCharge = fixedDelliverMethod.toLowerCase()=="pickup"?0:double.parse(dlintKm),
        weights = 0, finalPrice = 0;
    double priceAfterDis = 0 , discountedPrice = 0 , flavByWeight = 0 , shapeByWeight = 0 , addedPrice =0;

    String shape = "";

    setState((){

      // if(fixedWeight=="1.0"){
      //   fixedWeight = weight[0].toString();
      // }

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
        extra = (double.parse(flavExtraCharge.toString())+
            double.parse(extraShapeCharge.toString()));
            // *double.parse(fixedWeight.toLowerCase().replaceAll('kg', ""));

        print("extra $extra");

        price = ((counts * (double.parse(cakePrice.toString())+extra))*
            double.parse(fixedWeight.toLowerCase().replaceAll("kg", "").toString()))+double.parse(topperPrice.toString());

        //if tier selected
      if(tierPrice!=0){
        price = double.parse(tierPrice.toString());
        weights = double.parse(changeKilo(tempCakeWeight).toLowerCase().replaceAll("kg", ""));
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
    if(cakeSubType.toLowerCase()=="all cakes"){
      prefs.setString('orderCakeType', cakeType.toString().replaceAll("[", "").replaceAll("]", ""));
    }else{
      prefs.setString('orderCakeType', cakeSubType);
    }
    prefs.setString('orderCakeSubType', cakeSubType);
    prefs.setString('orderCakeImages', cakeImages[0].toString());
    prefs.setString('orderCakeEggOrEggless', eggEggless);
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
    prefs.setDouble('orderCakePaymentExtra', double.parse(extra.toString()));
    prefs.setDouble('orderCakeTopperPrice', double.parse(topperPrice.toStringAsFixed(2))??0.0);
    prefs.setInt('orderCakeTaxperc', taxes??0);
    prefs.setDouble('orderCakeDiscountedPrice',discountedPrice ??0);

    //optionals
    prefs.setString('orderCakeMessage', messageCtrl.text.isNotEmpty?messageCtrl.text:"None");//ops
    prefs.setString('orderCakeRequest', specialReqCtrl.text.isNotEmpty?specialReqCtrl.text:"None");//ops
    prefs.setString('orderCakeVendorId', vendorID??'null');//ops
    prefs.setString('orderCakeVendorModId', vendorModID??'null');//ops
    prefs.setString('orderCakeVendorPh1', vendorPhone1??'null');//ops
    prefs.setString('orderCakeVendorPh2', vendorPhone2??'null');//ops
    prefs.setString('orderCakeVendorName', vendorName??'null');//ops
    prefs.setString('orderCakeVendorAddress', vendorAddress??'null');//ops
    prefs.setString('orderCakeTheme', themeTextCtrl.text.isNotEmpty?themeTextCtrl.text:"null");//ops
    prefs.setString('orderCakeThemeImage', file.path.isNotEmpty?file.path.toString():'null');//ops


    if(nearestVendors.length > 0 && double.parse(fixedWeight)<=5.0){
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

    prefs.setString("theMainCakeDetails",jsonEncode(data));

    // Navigator.of(context).push(
    //   PageRouteBuilder(
    //     pageBuilder: (context, animation, secondaryAnimation) => OrderConfirm(
    //         flav: fixedFlavList,
    //         artic: [
    //           {"Name": '$fixedArticle', "Price": '$articleExtraCharge'}
    //         ].toList()),
    //     transitionsBuilder: (context, animation, secondaryAnimation, child) {
    //       const begin = Offset(1.0, 0.0);
    //       const end = Offset.zero;
    //       const curve = Curves.ease;
    //
    //       final tween = Tween(begin: begin, end: end);
    //       final curvedAnimation = CurvedAnimation(
    //         parent: animation,
    //         curve: curve,
    //       );
    //
    //       return SlideTransition(
    //         position: tween.animate(curvedAnimation),
    //         child: child,
    //       );
    //     },
    //   ),
    // );

    print("the cake price...");

    var priceData = ((((double.parse(fixedWeight.toLowerCase().replaceAll("kg", ""))*
        double.parse(cakePrice)) + (
        double.parse(fixedWeight.toLowerCase().replaceAll("kg", ""))*
            double.parse(flavExtraCharge.toString())) +(
        double.parse(fixedWeight.toLowerCase().replaceAll("kg", ""))*
            double.parse(extraShapeCharge.toString())))*counts)
        +double.parse(topperPrice.toString())).toStringAsFixed(2);

    var extraData = (double.parse(fixedWeight.toLowerCase().replaceAll("kg", ""))*
        double.parse(flavExtraCharge.toString()))+(double.parse(fixedWeight.toLowerCase().replaceAll("kg", ""))*
        double.parse(extraShapeCharge.toString()));

    var deliverChargeData = 0.0;

    if(mySelVendors.isNotEmpty){
      deliverChargeData = double.parse("${((adminDeliveryCharge / adminDeliveryChargeKm) *
          (calculateDistance(double.parse(userLatitude),
              double.parse(userLongtitude),mySelVendors[0]['GoogleLocation']['Latitude'],
              mySelVendors[0]['GoogleLocation']['Longitude'])))}");
    }

    if((calculateDistance(double.parse(userLatitude),
        double.parse(userLongtitude),mySelVendors[0]['GoogleLocation']['Latitude'],
        mySelVendors[0]['GoogleLocation']['Longitude']))<2.0)
    {
      deliverChargeData = 0.0;
    }

    var paymentObj = {
      "img": data['MainCakeImage'],
      "name": data['CakeName'],
      "egg":eggEggless,
      "price":priceData,
      "count":counts,
      "vendor": data['VendorName'],
      "type":"Cakes",
      "details": data,
      "deliverType":fixedDelliverMethod,
      "deliveryAddress": deliverAddress[deliverAddressIndex],
      "deliverDate":deliverDate,
      "deliverSession":deliverSession,
      "deliverCharge":fixedDelliverMethod.toLowerCase()=="pickup"?0:deliverChargeData,
      "discount":data['Discount'],
      "extra_charges":extraData,
      "weight":weight[weightIndex],
      "flavours":fixedFlavList,
      "shapes":shape,
      "tier":"",
      "topper_price":topperPrice,
      "topper_name":topperName,
      "topper_image":topperImage,
      "topper_id":topperId,
      "msg_on_cake":messageCtrl.text,
      "spl_req":specialReqCtrl.text,
      "premium_vendor":"",
      "vendor_id":vendorID,
      "cake_price":cakePrice,
      "vendor_mail":mySelVendors[0]['Email'],
    };

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (c) => PaymentGateway(
              paymentObjs: paymentObj,
            )
        )
    );

    print('Loaded.... ${changeWeight(fixedWeight+"kg")}');
  }

  //get vendorsList
  Future<void> getVendorsList() async {
    print("begin...");

    var res = await http.get(
        Uri.parse("${API_URL}api/activevendors/list"),
        headers: {"Authorization": "$authToken"});

    if (res.statusCode == 200) {
      // getCakesList();
      setState(() {
        List vendorsList = jsonDecode(res.body);
        List temp = [];

        List ctypesList = cakesList.where((element) => element['CakeName'].toString().toLowerCase().contains(
            cakeName.toLowerCase()
        )).toList();

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
        ).toList();

        nearestVendors = nearestVendors.toSet().toList();

      });
    } else {}
    print("...end");

    print(nearestVendors.length);

  }

  //getAllcakes List
  Future<void> getCakesList() async {

    var prefs = await SharedPreferences.getInstance();
    myCakesList.clear();
    List<String> activeVendorsIds = prefs.getStringList('activeVendorsIds')??[];
    showAlertDialog();
    try{
      var res = await http.get(
          Uri.parse('${API_URL}api/cakes/activevendors/list'),
          headers: {"Authorization": "$authToken"});

      if (res.statusCode == 200) {
        setState(() {
          myCakesList = jsonDecode(res.body);
          List cakeList = jsonDecode(res.body);

          // cakeList = myCakesList.where((element) => calculateDistance(double.parse(userLatitude),
          //     double.parse(userLongtitude),
          //     element['GoogleLocation']['Latitude'],element['GoogleLocation']['Longitude'])<=10).toList();

          if(activeVendorsIds.isNotEmpty){
            for(int i = 0;i<activeVendorsIds.length;i++){
              cakeList = cakeList+myCakesList.where((element) => element['VendorID'].toString().toLowerCase()==
                  activeVendorsIds[i].toLowerCase()).toList();
            }
          }

          cakesList = cakeList
              .where((element) =>
              element['CakeName'].toString().toLowerCase().contains(cakeName.toLowerCase().toString()))
              .toList();

          print("Cake list length = ... ${cakesList.length}");

          getVendorsList();
          Navigator.pop(context);
        });
      } else {
        Navigator.pop(context);
      }
    }catch(e){
      Navigator.pop(context);
    }
  }

  void setShapeFixed(int index){
    setState(() {

      if(shapes[index]['MinWeight']==null){
        fixedShape = shapes[index]['Name'];
        extraShapeCharge = int.parse(shapes[index]['Price'], onError: (e)=>0);
        fixedWeight = weight[0];
      }else{
        fixedShape = shapes[index]['Name'];
        extraShapeCharge = int.parse(shapes[index]['Price'], onError: (e)=>0);
        fixedWeight = shapes[index]['MinWeight'].toString();
        customweightCtrl.text = fixedWeight.toString().toLowerCase().replaceAll("kg", "");
        //weightIndex = weight.indexWhere((element) => element.toString().toLowerCase()==fixedWeight.toString().toLowerCase());
      }

    });
  }

  //changing dynamcially cake based on vendors
  Future<void> loadCakeDetailsByVendor(String venId , String cakesType ,
      [int index = 0,bool selectedFrm = false]) async{

    print("updating....");

    List artTempList = [];
    String adrss = "";
    List flavour1 = [];
    List shapes1 = [];

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


    print("Ven cake Update "+"${cakesList.length}");

      //Change ui based on vendor and cake type
      setState((){

        artTempList = cakesList
            .where((element) =>
        element['VendorID']
            .toString().toLowerCase() ==
            venId.toString().toLowerCase())
            .toList();


        // print(artTempList[0]['VendorID']);
        print(artTempList[0]['_id']);

        artTempList = artTempList
            .where((element) => element['CakeName'].toString()==cakesType)
            .toList();

        adrss = artTempList[0]['VendorAddress'];

        data = artTempList[0];

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
        eggEggless = artTempList[0]['DefaultCakeEggOrEggless'];
        cakeEgglessAvail = artTempList[0]['IsEgglessOptionAvailable'];
        cakeEgglessPrice = artTempList[0]['BasicEgglessCostPerKg'];
        basicCakeWeight = artTempList[0]['MinWeight'];
        cakeDescription = artTempList[0]['Description'];
        // cakeType = artTempList[0]['CakeType'];
        // cakeSubType = artTempList[0]['CakeSubType'];
        cakeRatings = artTempList[0]['Ratings'].toString();
        isThemePossible = artTempList[0]['ThemeCakePossible'];
        isTierPossible = artTempList[0]['IsTierCakePossible'];
        isTopperPossible = artTempList[0]['ToppersPossible'];
        taxes = artTempList[0]['Tax'];
        cakeDiscounts = artTempList[0]['Discount'];
        vendorLat = artTempList[0]['GoogleLocation']['Latitude'].toString();
        vendorLong = artTempList[0]['GoogleLocation']['Longitude'].toString();

        thrkgdeltime = artTempList[0]['MinTimeForDeliveryOfA4to5KgCake'];
        fvkgdeltime = artTempList[0]['MinTimeForDeliveryOfAAbove5KgCake'];
        onekgdeltime = artTempList[0]['MinTimeForDeliveryOfABelow2KgCake'];
        twokgdeltime = artTempList[0]['MinTimeForDeliveryOfA2to4KgCake'];
        cakeMindeltime = artTempList[0]['MinTimeForDeliveryOfDefaultCake'];

        weight.clear();

        if (artTempList[0]['MinWeightList'].isNotEmpty || artTempList[0]['MinWeightList']!=null) {
          setState(() {
            for (int i = 0; i < artTempList[0]['MinWeightList'].length; i++) {
              weight.add(artTempList[0]['MinWeightList'][i].toString());
            }
          });
        } else {
          setState(() {
            weight = [];
          });
        }

        print("%%%%%%%%%%%%%%%");
        print(artTempList[0]['MinWeightList']);



        // if(artTempList[0]['MinWeightList'].isNotEmpty){
        //   print("Exc...");
        //   for(int i = 0 ; i<artTempList[0]['MinWeightList'].length;i++){
        //     weight.add(artTempList[0]['MinWeightList'][i].toString());
        //   }
        // }
        cakeImages = cakeImages.toSet().toList();

        //Vendor
        vendorID = artTempList[0]['VendorID'];
        vendorModID = artTempList[0]['Vendor_ID'];
        vendorPhone1 = artTempList[0]['VendorPhoneNumber1'];
        vendorPhone2 = artTempList[0]['VendorPhoneNumber2'];
        vendorAddress = artTempList[0]['VendorAddress'];
        vendorName = artTempList[0]['VendorName'];

        fetchToppersById(vendorID);

        print("Users : $userID\n $userName\n $userModID\n $userAddress\n $newRegUser\n $userPhone\n");


        if(artTempList[0]['TierCakeMinWeightAndPrice']!=null){
          cakeTiers = artTempList[0]['TierCakeMinWeightAndPrice'];
          tiersDelTimes = artTempList[0]['MinTimeForDeliveryFortierCake'];
        }else{
          cakeTiers = [];
          tiersDelTimes = [];
        }



        if(cakeImages.isEmpty){
          cakeImages.add(artTempList[0]['MainCakeImage'].toString());
        }else{
          cakeImages.insert(0, artTempList[0]['MainCakeImage'].toString());
        }


        if(cakeEggorEgless.toLowerCase()=="egg"&&cakeEgglessAvail.toLowerCase()=='y') {
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

        if(weight.isEmpty){
          weight.add(basicCakeWeight);
        }else{
          weight.insert(weight.indexOf(weight.last), basicCakeWeight);
        }

        weight = weight.toSet().toList();

        weight = weight.toSet().toList();

        fixedWeight = basicCakeWeight;
        weightIndex = 0;

      });

    context.read<ContextData>().addMyVendor(false);
    print("....updated");

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

  Future getAndAssignValue() async {
    print("CAKE DATA --> $data");
    setState((){

      //remove
      totalImages.clear();
      totalWeightList.clear();

      totalImages = data['AdditionalCakeImages'];
      totalImages.add(data['MainCakeImage']);
      totalImages.toSet().toList();

      totalWeightList = data['MinWeightList'];
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    Future.delayed(Duration.zero , () async{
      getDetailsFromScreen();
      //getAndAssignValue();
    });
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    // TODO: implement initState
    flavour.clear();
    shapes.clear();
    data = {};
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
    notiCount = context.watch<ContextData>().getNotiCount();
    newRegUser = context.watch<ContextData>().getFirstUser();

    selVendor = context.watch<ContextData>().getAddedMyVendor();
    if(selVendor == true){
      mySelVendors = context.watch<ContextData>().getMyVendorsList();
      loadCakeDetailsByVendor(mySelVendors[0]['_id'] , cakeName , 0);
      isNearVendrClicked = true;
      selVendor = false;
    }

    weight.sort((a,b)=>changeWeight(a.toString()).compareTo(changeWeight(b.toString())));


    if(context.watch<ContextData>().getDpUpdate()==true){
      newRegUser = false;
    }

    // if (context.watch<ContextData>().getAddress().isNotEmpty) {
    //   userAddress = context.watch<ContextData>().getAddress();
    // }

    if (context.watch<ContextData>().getAddressList().isNotEmpty) {
      deliverAddress = context.watch<ContextData>().getAddressList();
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
                            "${data['CakeName']}",
                            style: TextStyle(color: darkBlue),
                          )
                        : Text(""),
                    expandedHeight: 300.0,
                    leading: Container(
                      margin: const EdgeInsets.all(12),
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          height: 30,
                          decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(7)),
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.chevron_left,
                            size: 30,
                            color: lightPink,
                          ),
                        ),
                      ),
                    ),
                    // forceElevated: innerBoxIsScrolled,
                    //floating: true,
                    pinned: true,
                    floating: true,
                    actions: [
                      MyCustomAppBars(onPressed:(){getDetailsFromScreen();},profileUrl:profileUrl,),
                      //CustomAppBars().CustomAppBar(context, "", notiCount, profileUrl,(){getDetailsFromScreen();}),
                      SizedBox(width: 12,),
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
                                              borderRadius: BorderRadius.only(
                                                  bottomLeft: Radius.circular(10),
                                                  bottomRight: Radius.circular(10)
                                              ),
                                              color: Colors.black12,
                                              image: DecorationImage(
                                                  image: NetworkImage(
                                                      "${cakeImages[index]}"),
                                                  fit: BoxFit.cover,
                                              )),
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
                          margin: EdgeInsets.only(left: 20, right: 5, top: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  RatingBar.builder(
                                    initialRating:
                                        double.parse(data['Ratings'].toString(), (e) => 1.5),
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
                                    ignoreGestures:true,
                                    onRatingUpdate: (rating) {
                                      print(rating);
                                    },
                                  ),
                                  Text(
                                    ' ${data['Ratings']}',
                                    style: TextStyle(
                                        color: Colors.black54,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        fontFamily: poppins),
                                  )
                                ],
                              ),
                              Container(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Transform.rotate(
                                      angle: 120,
                                      child: Icon(
                                        Icons.egg_outlined,
                                        color: eggEggless.toLowerCase()=="eggless"?
                                        Colors.green:Color(0xff8D2729),
                                      ),
                                    ),
                                    Text(
                                        '$eggEggless',
                                        style: TextStyle(
                                            color: eggEggless.toLowerCase()=="eggless"?
                                            Colors.green:Color(0xff8D2729),
                                            fontFamily: poppins,
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold
                                        ),
                                      ),
                                    SizedBox(width: 6,),
                                    Transform.scale(
                                      scale: 0.7,
                                      child: CupertinoSwitch(
                                        thumbColor: Color(0xffffffff),
                                        value: egglessSwitch,
                                        onChanged: (bool? val) {
                                          setState(() {
                                            print("egg avail ");
                                            print(eggEggless);
                                            print(cakeEggorEgless);
                                            print(cakeEgglessAvail);
                                            print("egg avail******");
                                            //egglessSwitch = val!;
                                            if(cakeEggorEgless.toLowerCase()=="egg"&&
                                                eggEggless.toLowerCase()=="egg"&&cakeEgglessAvail.toLowerCase()=="y") {
                                              applyEgglessCake();
                                            }
                                            else if(cakeEggorEgless.toLowerCase()=="egg"&&eggEggless.toLowerCase()=="eggless"&&cakeEgglessAvail.toLowerCase()=="y"){
                                              applyEggCake();
                                            }
                                          });
                                        },
                                        activeColor: Colors.green,
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
                            '${data['CakeName']}',
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
                                        "${
                                            ((((double.parse(fixedWeight.toLowerCase().replaceAll("kg", ""))*
                                              double.parse(cakePrice)) + (
                                              double.parse(fixedWeight.toLowerCase().replaceAll("kg", ""))*
                                                  double.parse(flavExtraCharge.toString())) +(
                                              double.parse(fixedWeight.toLowerCase().replaceAll("kg", ""))*
                                                  double.parse(extraShapeCharge.toString())))*counts)
                                             +double.parse(topperPrice.toString())).toStringAsFixed(2)
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
                                      splashColor: Colors.transparent,
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
                                              color: darkBlue)) ),
                                    SizedBox(width: 8),
                                    Column(
                                      children: [
                                        Text(
                                          counts<10?
                                          '0${counts}':
                                          "${counts}",
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
                                      splashColor: Colors.transparent,
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
                                ])
                        ),
                        SizedBox(height:5),
                        Padding(
                          padding: const EdgeInsets.only(left:10),
                          child: Text("Minimum weight: $basicCakeWeight",style: TextStyle(
                              color:Colors.grey,fontFamily: "Poppins",fontSize: 11
                          ),),
                        ),
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
                        Container(
                          child: Row(
                            children: [
                              Expanded(child:Container(
                                padding: EdgeInsets.all(10),
                                child: Column(
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
                              ),),
                              Container(
                                height: 45,
                                width: 1,
                                color: Colors.pink[100],
                              )
                              ,
                              Expanded(child: Container(
                                padding: EdgeInsets.only(left : 15),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Shape',
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                          fontFamily: "Poppins"
                                      ),
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
                              ),),
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: 15, vertical: 10),
                          padding: EdgeInsets.all(12),
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                              color: Color(0xffffe9df),
                              borderRadius: BorderRadius.circular(10)),
                          child: Column(
                            children: [
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
                                      SizedBox(width: 5,),
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
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                "${fixedFlavList.length} Selected Flavs",
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    fontFamily: "Poppins",
                                                    fontSize: 9,
                                                    color: Colors.white
                                                ),
                                              ),
                                              SizedBox(width: 4,),
                                              Icon(Icons.cancel,size: 14,color:Colors.white),
                                            ],
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
                                                color: Colors.white),
                                            child: Icon(
                                              Icons.add,
                                              color: darkBlue,
                                              size: 18,
                                            ),
                                          ),
                                        )
                                            : CircleAvatar(
                                            radius: 15,
                                            backgroundColor: Colors.green,
                                            child: Icon(
                                              Icons.check,
                                              color: Colors.white,
                                              size: 18,
                                            )),
                                      )
                                  )
                                ],
                              ),
                              SizedBox(height: 12),
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
                                      SizedBox(width: 4,),
                                      fixedShape.isNotEmpty
                                          ? GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            fixedShape = "";
                                            myShapeIndex =-1;
                                            extraShapeCharge = 0;
                                            fixedWeight = weight[0];
                                            weightIndex = 0;
                                            customweightCtrl.text = "";
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
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                "${fixedShape}",
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    fontFamily: "Poppins",
                                                    fontSize: 9,
                                                    color: Colors.white
                                                ),
                                              ),
                                              SizedBox(width: 4,),
                                              Icon(Icons.cancel,size: 14,color:Colors.white),
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
                                                color: Colors.white),
                                            child: Icon(
                                              Icons.add,
                                              color: darkBlue,
                                              size: 18,
                                            ),
                                          ),
                                        )
                                      : CircleAvatar(
                                          radius: 15,
                                          backgroundColor: Colors.green,
                                          child: Icon(
                                            Icons.check,
                                            color: Colors.white,
                                            size: 18,
                                          )),
                                ],
                              ),
                              SizedBox(height: 12),
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
                                          margin: EdgeInsets.only(right: 0,left: 7),
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 3),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                            BorderRadius.circular(20),
                                            color: lightPink,
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                "${topperName.split(" ").first}",
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    fontFamily: "Poppins",
                                                    fontSize: 9,
                                                    color: Colors.white
                                                ),
                                              ),
                                              SizedBox(width: 4,),
                                              Icon(Icons.cancel,size: 14,color:Colors.white),
                                            ],
                                          ),
                                        )
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
                                        Functions().showSnackMsg(context, "No custom toppers available!", true);
                                      }

                                    },
                                    child: Container(
                                      width: 30,
                                      height: 30,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white),
                                      child: Icon(
                                        Icons.add,
                                        color: darkBlue,
                                        size: 18,
                                      ),
                                    ),
                                  ):
                                  CircleAvatar(
                                      radius: 15,
                                      backgroundColor: Colors.green,
                                      child: Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 18,
                                      )),
                                ],
                              ),
                              SizedBox(height: 12),
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Info',
                                    style: TextStyle(fontFamily: "Poppins"),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      showModalBottomSheet(
                                          context: context,
                                          isScrollControlled: true,
                                          builder:(c){
                                            return Container(
                                              padding:EdgeInsets.symmetric(
                                                vertical:10,
                                                horizontal:10
                                              ),
                                              child:Column(
                                                mainAxisSize:MainAxisSize.min,
                                                children:[
                                                  ListTile(
                                                    title:Text("Instructions", style:TextStyle(
                                                        fontFamily:"Poppins",
                                                        fontSize:15.5,
                                                        fontWeight:FontWeight.bold
                                                    ),),
                                                    subtitle:Text(data['OtherInstructions'].toString() , style:TextStyle(
                                                      fontFamily:"Poppins",
                                                      fontSize:13.5
                                                    ),),
                                                  ),
                                                  ListTile(
                                                    title:Text("Minimum Weight", style:TextStyle(
                                                        fontFamily:"Poppins",
                                                        fontSize:15.5,
                                                        fontWeight:FontWeight.bold
                                                    ),),
                                                    subtitle:Text('$basicCakeWeight' , style:TextStyle(
                                                        fontFamily:"Poppins",
                                                        fontSize:13.5
                                                    ),),
                                                  ),
                                                  ListTile(
                                                    title:Text("Price base", style:TextStyle(
                                                        fontFamily:"Poppins",
                                                        fontSize:15.5,
                                                        fontWeight:FontWeight.bold
                                                    ),),
                                                    subtitle:Text("$cakePrice X "
                                                        "${fixedWeight.toLowerCase().replaceAll("kg","")}Kg, "
                                                        "Flavour Rs.$flavExtraCharge , Shape Rs.$extraShapeCharge" , style:TextStyle(
                                                      fontFamily:"Poppins",
                                                      fontSize:13.5
                                                    ),),
                                                  ),
                                                ]
                                              )
                                            );
                                          }
                                      );
                                    },
                                    child: Container(
                                      width: 30,
                                      height: 30,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white),
                                      child: Icon(
                                        Icons.add,
                                        color: darkBlue,
                                        size: 18,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(height: 12),
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
                                  height: MediaQuery.of(context).size.height * 0.046,
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

                                              print("mini deli time :${dayMinConverter(cakeMindeltime)}");
                                              print("mini deli time :${cakeMindeltime}");

                                              setState(() {
                                                FocusScope.of(context).unfocus();
                                                weightIndex = index;
                                                fixedWeight = changeKilo(weight[index]);
                                                customweightCtrl.text = changeKilo(weight[index]);
                                                myWeight = weight[index];
                                                print(fixedWeight);
                                              });
                                            },
                                            child: Container(
                                              alignment: Alignment.center,
                                              width: 60,
                                              margin: EdgeInsets.only(left: 10),
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
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
                              // Container(
                              //   padding: EdgeInsets.only(
                              //     left: 15,bottom: 8,top: 8
                              //   ),
                              //   child: Text(
                              //     double.parse(fixedWeight.toString().toLowerCase().replaceAll('kg', ''))>0.5&&
                              //     double.parse(fixedWeight.toString().toLowerCase().replaceAll('kg', ''))<=2.0?
                              //     "Min Delivery Time Of A Cake $onekgdeltime":
                              //     double.parse(fixedWeight.toString().toLowerCase().replaceAll('kg', ''))>2.0&&
                              //     double.parse(fixedWeight.toString().toLowerCase().replaceAll('kg', ''))<=4.0?
                              //     "Min Delivery Time Of A Cake $twokgdeltime":
                              //     double.parse(fixedWeight.toString().toLowerCase().replaceAll('kg', ''))>4.0&&
                              //     double.parse(fixedWeight.toString().toLowerCase().replaceAll('kg', ''))<=5.0?
                              //     "Min Delivery Time Of A Cake $thrkgdeltime":
                              //     double.parse(fixedWeight.toString().toLowerCase().replaceAll('kg', ''))>5.0?
                              //     "Min Delivery Time Of A Cake $fvkgdeltime":
                              //     "Min Delivery Time Of A Cake $cakeMindeltime",
                              //     style: TextStyle(
                              //       color: lightPink,
                              //       fontFamily: "Poppins",
                              //       fontSize: 12
                              //     ),
                              //   ),
                              // ),

                              // cakeSubType.toLowerCase().contains("tier")||cakeSubType.toLowerCase().contains("theme")
                              // ||cakeSubType.toLowerCase().contains("fondant")||
                              // cakeTypesList.toString().toLowerCase().contains("tier")||
                              //     cakeTypesList.toString().toLowerCase().contains("theme")||
                              // cakeTypesList.toString().toLowerCase().contains("fondant")?
                              // Container():
                              // Column(
                              //   crossAxisAlignment: CrossAxisAlignment.start,
                              //   children: [
                              //     Padding(
                              //       padding: const EdgeInsets.only(left: 15.0, top: 5),
                              //       child: Text(
                              //         'Enter Weight',
                              //         style:
                              //         TextStyle(fontFamily: poppins, color: darkBlue),
                              //       ),
                              //     ),
                              //     SizedBox(
                              //       height: 5,
                              //     ),
                              //     Container(
                              //       child: Row(
                              //         crossAxisAlignment: CrossAxisAlignment.center,
                              //         children: [
                              //           SizedBox(
                              //             width: 15,
                              //           ),
                              //           Icon(
                              //             Icons.scale_outlined,
                              //             color: lightPink,
                              //           ),
                              //           Expanded(
                              //             child: Container(
                              //               margin: EdgeInsets.symmetric(horizontal: 10),
                              //               child: TextField(
                              //                 keyboardType: TextInputType.number,
                              //                 textInputAction: TextInputAction.next,
                              //                 controller: customweightCtrl,
                              //                 style: TextStyle(
                              //                     fontFamily: 'Poppins', fontSize: 13),
                              //                 inputFormatters: <TextInputFormatter>[
                              //                   FilteringTextInputFormatter.allow(new RegExp('[0-9.]')),
                              //                   FilteringTextInputFormatter.allow(RegExp(r'^(\d+)?\.?\d{0,2}')),
                              //                   FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')),
                              //                   FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*'))!,
                              //                 ],
                              //                 onChanged: (String text) {
                              //                   setState((){
                              //                     if (customweightCtrl.text.isNotEmpty) {
                              //                       fixedWeight = customweightCtrl.text+"kg";
                              //                       if(weight.indexWhere((element) => element==fixedWeight)!=-1){
                              //                         weightIndex = weight.indexWhere((element) => element==fixedWeight);
                              //                       }else{
                              //                         weightIndex = -1;
                              //                       }
                              //                       print("weight is $fixedWeight");
                              //                     } else {
                              //                       weightIndex = 0;
                              //                       fixedWeight = weight[0].toString();
                              //                     }
                              //                   });
                              //                 },
                              //                 decoration: InputDecoration(
                              //                   contentPadding: EdgeInsets.all(0.0),
                              //                   isDense: true,
                              //                   constraints: BoxConstraints(minHeight: 5),
                              //                   hintText: 'Type here..',
                              //                   hintStyle: TextStyle(
                              //                       fontFamily: 'Poppins', fontSize: 13),
                              //                   // border: InputBorder.none
                              //                 ),
                              //               ),
                              //             ),
                              //           ),
                              //           GestureDetector(
                              //             child: Container(
                              //                 padding: EdgeInsets.all(4),
                              //                 margin: EdgeInsets.only(right: 10),
                              //                 decoration: BoxDecoration(
                              //                     color: Colors.grey[300]!,
                              //                     borderRadius: BorderRadius.circular(5)),
                              //                 child: PopupMenuButton(
                              //                     child: Row(
                              //                       children: [
                              //                         Text('$selectedDropWeight',
                              //                             style: TextStyle(
                              //                                 color: darkBlue,
                              //                                 fontFamily: 'Poppins')
                              //                         ),
                              //                         SizedBox(
                              //                           width: 5,
                              //                         ),
                              //                         Icon(Icons.keyboard_arrow_down,
                              //                             color: darkBlue)
                              //                       ],
                              //                     ),
                              //                     itemBuilder: (context) => [
                              //                       PopupMenuItem(
                              //                           onTap: () {
                              //                             setState(() {
                              //                               selectedDropWeight = "Kg";
                              //                             });
                              //                           },
                              //                           child: Text('Kilo Gram',style: TextStyle(
                              //                               fontFamily: "Poppins"
                              //                           ),)
                              //                       ),
                              //
                              //                       // PopupMenuItem(
                              //                       //     onTap: () {
                              //                       //       setState(() {
                              //                       //         selectedDropWeight = "Ib";
                              //                       //       });
                              //                       //     },
                              //                       //     child: Text('Pounds')),
                              //                       // PopupMenuItem(
                              //                       //     onTap: () {
                              //                       //       setState(() {
                              //                       //         selectedDropWeight = "G";
                              //                       //       });
                              //                       //     },
                              //                       //     child: Text('Gram')),
                              //
                              //
                              //                     ])),
                              //           )
                              //         ],
                              //       ),
                              //     ),
                              //   ],
                              // ),
                              
                            ],
                          ),
                        ),
                        // Cake Tier
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
                        //                     print(tiersDelTimes);
                        //                     FocusScope.of(context).unfocus();
                        //                     setState(() {
                        //                       if(tierSelIndex==index){
                        //                         tierSelIndex = -1;
                        //                         tierPrice = 0;
                        //                         tempTierPrice = 0;
                        //                         tempCakeWeight = "0.0";
                        //                         minDelTierTime = "";
                        //                       }else{
                        //                         tierSelIndex = index;
                        //                         tierPrice = double
                        //                             .parse(cakeTiers[index]['Price'].toString());
                        //                         tempTierPrice = tierPrice;
                        //                         tempCakeWeight = cakeTiers[index]['Weight'].toString();
                        //                         var myList = tiersDelTimes.where((element) => element['Tier']==cakeTiers[index]['Tier']).toList();
                        //                         minDelTierTime = myList[0]['MinTime'].toString();
                        //                       }
                        //                     });
                        //                   },
                        //                   child: Container(
                        //                     alignment: Alignment.center,
                        //                     height: 25,
                        //                     width: 70,
                        //                     margin: EdgeInsets.only(left: 9, ),
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
                        //     Padding(
                        //       padding: const EdgeInsets.only(left: 10,top:5),
                        //       child: Text("Tier Minimum Delivery Time : "
                        //           "${minDelTierTime}",style: TextStyle(
                        //           color: lightPink, fontFamily: "Poppins",fontSize: 12.5),),
                        //     ),
                        //   ],
                        // ):
                        // Container()
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
                                                  border:InputBorder.none,
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
                                          if(index==0){
                                            deliverAddressIndex = 0;
                                            tooFar = false;
                                          }else{
                                            deliverAddressIndex = -1;
                                          }
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

                                    FocusScope.of(context).unfocus();

                                    print(dayMinConverter(cakeMindeltime));

                                    String deliTime = "1";

                                    print("****");
                                    print(basicCakeWeight);
                                    print(thrkgdeltime);
                                    print(fvkgdeltime);
                                    print(onekgdeltime);
                                    print(twokgdeltime);
                                    print(cakeMindeltime);
                                    print("****");

                                    print(changeWeight(fixedWeight));


                                    if(changeWeight(basicCakeWeight) == changeWeight(fixedWeight)){
                                      deliTime = dayMinConverter(cakeMindeltime);
                                    }

                                    else if(onekgdeltime.toLowerCase()!="n/a" && changeWeight(fixedWeight)>=0.5 &&
                                        onekgdeltime.toLowerCase()!="n/a" && changeWeight(fixedWeight)<=2.0){
                                      deliTime = dayMinConverter(onekgdeltime);
                                    }

                                    else if(twokgdeltime.toLowerCase()!="n/a" && changeWeight(fixedWeight)>=2.0 &&
                                        twokgdeltime.toLowerCase()!="n/a" && changeWeight(fixedWeight)<4.0){
                                      deliTime = dayMinConverter(twokgdeltime);
                                    }

                                    else if(thrkgdeltime.toLowerCase()!="n/a" && changeWeight(fixedWeight)>=4.0 &&
                                        thrkgdeltime.toLowerCase()!="n/a" && changeWeight(fixedWeight)<5.0){
                                      deliTime = dayMinConverter(thrkgdeltime);
                                    }

                                    else if(fvkgdeltime.toLowerCase()!="n/a" && changeWeight(fixedWeight)>=5.0){
                                      deliTime = dayMinConverter(fvkgdeltime);
                                    }


                                    // if(thrkgdeltime.toLowerCase()!="n/a" && changeWeight(fixedWeight)<=5.0){
                                    //   deliTime = dayMinConverter(thrkgdeltime);
                                    // }else if(fvkgdeltime.toLowerCase()!="n/a" && changeWeight(fixedWeight)>5.0){
                                    //   deliTime = dayMinConverter(fvkgdeltime);
                                    // }else if(onekgdeltime.toLowerCase()!="n/a" && changeWeight(fixedWeight)>=0.5 &&
                                    //     onekgdeltime.toLowerCase()!="n/a" && changeWeight(fixedWeight)<=0.2){
                                    //   deliTime = dayMinConverter(onekgdeltime);
                                    // }else if(twokgdeltime.toLowerCase()!="n/a" && changeWeight(fixedWeight)<=4.0){
                                    //   deliTime = dayMinConverter(twokgdeltime);
                                    // }else {
                                    //   deliTime = dayMinConverter(cakeMindeltime);
                                    // }

                                    print("Deliver time estimate : .... $deliTime");



                                    DateTime? SelDate = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime(
                                        DateTime.now().year,
                                        DateTime.now().month,
                                        DateTime.now().day+int.parse(deliTime),
                                      ),
                                      lastDate: DateTime(2100),
                                      firstDate: DateTime(
                                        DateTime.now().year,
                                        DateTime.now().month,
                                        DateTime.now().day+int.parse(deliTime),
                                      ),
                                      helpText: "Min Delivery Time : $deliTime day(s)",
                                      builder: (c,child){
                                        return Theme(
                                          data:ThemeData(
                                            dialogTheme: DialogTheme(
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10)
                                              )
                                            ),
                                            colorScheme: ColorScheme.light(
                                                onPrimary: Colors.white,
                                                onSurface: Colors.pink,
                                                primary: Colors.pink
                                            ),
                                            textTheme: const TextTheme(
                                              headline5: TextStyle(
                                                  fontSize: 17,
                                                  fontFamily: "Poppins",
                                                  fontWeight: FontWeight.bold
                                              ),
                                              headline4: TextStyle(
                                                  fontSize: 17,
                                                  fontFamily: "Poppins",
                                                  fontWeight: FontWeight.bold
                                              ),
                                              overline: TextStyle(
                                                fontSize: 14,
                                                fontFamily: "Poppins",
                                                fontWeight: FontWeight.bold
                                              )
                                            )
                                          ),
                                          child:child!
                                        );
                                      }
                                    );

                                    setState(() {
                                      deliverDate = simplyFormat(
                                          time: SelDate, dateOnly: true
                                      );
                                    });

                                    print(cakeMindeltime.replaceAll(RegExp('[^0-9]'), ''));

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
                                                  fontFamily: "Poppins",
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
                                                    BorderRadius.circular(10)),
                                            title:
                                                Text("Select delivery session",
                                                    style: TextStyle(
                                                      color: lightPink,
                                                      fontFamily: "Poppins",
                                                      fontSize: 18,
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
                                                              'Morning 8 AM - 9 AM', style: TextStyle(fontFamily: "Poppins"),),
                                                          onTap: () {
                                                            setState(() {
                                                              deliverSession =
                                                                  'Morning 8 AM - 9 AM';
                                                            });
                                                          }),
                                                      PopupMenuItem(
                                                          child: Text(
                                                              'Morning 9 AM - 10 AM', style: TextStyle(fontFamily: "Poppins"),),
                                                          onTap: () {
                                                            setState(() {
                                                              deliverSession =
                                                                  'Morning 9 AM - 10 AM';
                                                            });
                                                          }),
                                                      PopupMenuItem(
                                                          child: Text(
                                                              'Morning 10 AM - 11 AM', style: TextStyle(fontFamily: "Poppins"),),
                                                          onTap: () {
                                                            setState(() {
                                                              deliverSession =
                                                                  'Morning 10 AM - 11 AM';
                                                            });
                                                          }),
                                                      PopupMenuItem(
                                                          child: Text(
                                                              'Morning 11 AM - 12 PM', style: TextStyle(fontFamily: "Poppins"),),
                                                          onTap: () {
                                                            setState(() {
                                                              deliverSession =
                                                                  'Morning 11 PM - 12 PM';
                                                            });
                                                          }),
                                                      PopupMenuItem(
                                                          child: Text(
                                                              'Afternoon 12 PM - 1 PM', style: TextStyle(fontFamily: "Poppins"),),
                                                          onTap: () {
                                                            setState(() {
                                                              deliverSession =
                                                                  'Afternoon 12 PM - 1 PM';
                                                            });
                                                          }),
                                                      PopupMenuItem(
                                                          child: Text(
                                                              'Afternoon 1 PM - 2 PM', style: TextStyle(fontFamily: "Poppins"),),
                                                          onTap: () {
                                                            setState(() {
                                                              deliverSession =
                                                                  'Afternoon 1 PM - 9 PM';
                                                            });
                                                          }),
                                                      PopupMenuItem(
                                                          child: Text(
                                                              'Afternoon 2 PM - 3 PM', style: TextStyle(fontFamily: "Poppins"),),
                                                          onTap: () {
                                                            setState(() {
                                                              deliverSession =
                                                                  'Afternoon 8 PM - 9 PM';
                                                            });
                                                          }),
                                                      PopupMenuItem(
                                                          child: Text(
                                                              'Afternoon 3 PM - 4 PM', style: TextStyle(fontFamily: "Poppins"),),
                                                          onTap: () {
                                                            setState(() {
                                                              deliverSession =
                                                                  'Afternoon 3 PM - 4 PM';
                                                            });
                                                          }),
                                                      PopupMenuItem(
                                                          child: Text(
                                                              'Afternoon 4 PM - 5 PM', style: TextStyle(fontFamily: "Poppins"),),
                                                          onTap: () {
                                                            setState(() {
                                                              deliverSession =
                                                                  'Afternoon 4 PM - 5 PM';
                                                            });
                                                          }),
                                                      PopupMenuItem(
                                                          child: Text(
                                                              'Evening 5 PM - 6 PM', style: TextStyle(fontFamily: "Poppins"),),
                                                          onTap: () {
                                                            setState(() {
                                                              deliverSession =
                                                                  'Evening 5 PM - 6 PM';
                                                            });
                                                          }),
                                                      PopupMenuItem(
                                                          child: Text(
                                                              'Evening 6 PM - 7 PM', style: TextStyle(fontFamily: "Poppins"),),
                                                          onTap: () {
                                                            setState(() {
                                                              deliverSession =
                                                                  'Evening 6 PM - 7 PM';
                                                            });
                                                          }),
                                                      PopupMenuItem(
                                                          child: Text(
                                                              'Evening 7 PM - 8 PM', style: TextStyle(fontFamily: "Poppins"),),
                                                          onTap: () {
                                                            setState(() {
                                                              deliverSession =
                                                                  'Evening 7 PM - 8 PM';
                                                            });
                                                          }),
                                                      PopupMenuItem(
                                                          child: Text(
                                                              'Evening 8 PM - 9 PM', style: TextStyle(fontFamily: "Poppins"),),
                                                          onTap: () {
                                                            setState(() {
                                                              deliverSession =
                                                                  'Evening 8 PM - 9 PM';
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
                                                  fontFamily: "Poppins",
                                                  color: Colors.grey,
                                                  fontSize: 13),
                                            ),
                                            Icon(CupertinoIcons.clock,
                                                color: darkBlue)
                                          ])),
                                ),
                              ],
                            )),
                        fixedDelliverMethod.toLowerCase()=="delivery"?
                        Column(
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
                                // ListTile(
                                //   onTap: (){
                                //     setState(() {
                                //       // userAddress = e.trim();
                                //       // deliverAddressIndex = deliverAddress.indexWhere((element) => element==e);
                                //     });
                                //   },
                                //   title: Text(
                                //     '${userAddress.trim()}',
                                //     style: TextStyle(
                                //         fontFamily: poppins,
                                //         color: Colors.grey,
                                //         fontSize: 13),
                                //   ),
                                //   trailing:
                                //   // deliverAddressIndex==deliverAddress.indexWhere((element) => element==e)?
                                //   Icon(Icons.check_circle, color: Colors.green ,size: 25,),
                                //   //Container(height:0,width:0),
                                // ),
                                Column(
                                    children:deliverAddress.map((e){
                                      return ListTile(
                                        onTap: () async{
                                          showAlertDialog();
                                          try {
                                            List<Location> locat =
                                            await locationFromAddress(e.toString().trim());
                                            List<Location> venLocation = await locationFromAddress(vendorAddress.trim());
                                            print(locat);
                                            setState(() {
                                              userAddress = e.trim();
                                              userLatitude =
                                                  locat[0].latitude.toString();
                                              userLongtitude =
                                                  locat[0].longitude.toString();
                                              deliverAddressIndex =
                                                  deliverAddress.indexWhere(
                                                          (element) => element == e);
                                              tooFar = false;
                                            });
                                            Navigator.pop(context);
                                            if (calculateDistance(
                                                double.parse(userLatitude),
                                                double.parse(userLongtitude),
                                                venLocation[0].latitude,
                                                venLocation[0].longitude) >
                                                10.0) {
                                              tooFar = true;
                                              TooFarDialog().showTooFarDialog(context, e);
                                              //showTooFarDialog();
                                            }
                                          } catch (e) {
                                            print("Error... $e");
                                            Navigator.pop(context);
                                          }

                                          // showAlertDialog();
                                          // try{
                                          //   List<Location> locat = await locationFromAddress(e);
                                          //   print(locat);
                                          //   setState(() {
                                          //     userAddress = e.trim();
                                          //     userLatitude = locat[0].latitude.toString();
                                          //     userLongtitude = locat[0].longitude.toString();
                                          //     deliverAddressIndex = deliverAddress.indexWhere((element) => element==e);
                                          //   });
                                          //   Navigator.pop(context);
                                          // }catch(e){
                                          //   Navigator.pop(context);
                                          // }
                                        },
                                        title: Text(
                                          '${e.trim()}',
                                          style: TextStyle(
                                              fontFamily: poppins,
                                              color: Colors.grey,
                                              fontSize: 13),
                                        ),
                                        trailing:
                                        deliverAddressIndex==deliverAddress.indexWhere((element) => element==e)?
                                        Icon(Icons.check_circle, color: Colors.green ,size: 25,):
                                        Container(height:0,width:0),
                                      );
                                    }).toList(),
                                    // [
                                    //   ListTile(
                                    //     title: Text(
                                    //       '${userAddress.trim()}',
                                    //       style: TextStyle(
                                    //           fontFamily: poppins,
                                    //           color: Colors.grey,
                                    //           fontSize: 13),
                                    //     ),
                                    //     trailing:
                                    //     Icon(Icons.check_circle, color: Colors.green ,size: 25,),
                                    //   ),
                                    // ]
                                ),
                                GestureDetector(
                                  onTap: (){
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => AddressScreen())
                                    );
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
                        ):
                        Container(),

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
                                            changeWeight(fixedWeight+"kg") <= 5.0
                                            ? Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [

                                                  Text('Selected Vendor',
                                                          style: TextStyle(
                                                              fontSize: 15,
                                                              color: darkBlue,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontFamily:
                                                                  poppins),
                                                  ),

                                                  SizedBox(
                                                    height: 10,
                                                  ),

                                                  InkWell(
                                                          onTap: () async{

                                                            // var pref = await SharedPreferences.getInstance();
                                                            //
                                                            // pref.remove('singleVendorID');
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
                                                            // //common keyword single****
                                                            // pref.setString('singleVendorID', mySelVendors[0]['_id']??'null');
                                                            // pref.setBool('singleVendorFromCd', true);
                                                            // pref.setString('singleVendorRate', mySelVendors[0]['Ratings'].toString()??'0.0');
                                                            // pref.setString('singleVendorName', mySelVendors[0]['VendorName']??'null');
                                                            // pref.setString('singleVendorDesc', mySelVendors[0]['Description']??'null');
                                                            // pref.setString('singleVendorPhone1', mySelVendors[0]['PhoneNumber1']??'null');
                                                            // pref.setString('singleVendorPhone2', mySelVendors[0]['PhoneNumber2']??'null');
                                                            // pref.setString('singleVendorDpImage', mySelVendors[0]['ProfileImage']??'null');
                                                            // pref.setString('singleVendorAddress', mySelVendors[0]['Address']??'null');
                                                            // pref.setString('singleVendorSpecial', mySelVendors[0]['YourSpecialityCakes'].toString()??'null');
                                                            //
                                                            //
                                                            // Navigator.push(context,
                                                            //  MaterialPageRoute(
                                                            //      builder: (context)=>SingleVendor()
                                                            //  )
                                                            // );
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
                                                                                      initialRating:double.parse(mySelVendors[0]['Ratings'].toString(),(e)=>0.0),
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
                                                                            0.3,
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
                                                                              double.parse((calculateDistance(double.parse(userLatitude),
                                                                                  double.parse(userLongtitude), mySelVendors[0]['GoogleLocation']['Latitude'],
                                                                                  mySelVendors[0]['GoogleLocation']['Longitude'])).toStringAsFixed(1))<2.0?
                                                                              Text(
                                                                                "DELIVERY FREE",
                                                                                style: TextStyle(
                                                                                  fontSize: 8,
                                                                                  fontFamily: "Poppins",
                                                                                  color: Colors.orange,
                                                                                ),
                                                                                maxLines: 1,
                                                                              ):
                                                                              Text(
                                                                                "${
                                                                                    (calculateDistance(double.parse(userLatitude),
                                                                                        double.parse(userLongtitude), mySelVendors[0]['GoogleLocation']['Latitude'],
                                                                                        mySelVendors[0]['GoogleLocation']['Longitude'])).toStringAsFixed(1)
                                                                                } KM Charge Rs.${
                                                                                    double.parse("${((adminDeliveryCharge / adminDeliveryChargeKm) *
                                                                                        (calculateDistance(double.parse(userLatitude),
                                                                                            double.parse(userLongtitude),mySelVendors[0]['GoogleLocation']['Latitude'],
                                                                                            mySelVendors[0]['GoogleLocation']['Longitude'])))}").toStringAsFixed(1)
                                                                                }",
                                                                                style: TextStyle(
                                                                                  fontSize: 8,
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
                                                                                    height: 30,
                                                                                    width: 30,
                                                                                    decoration: BoxDecoration(
                                                                                      shape: BoxShape.circle,
                                                                                      color: Colors.grey[200],
                                                                                    ),
                                                                                    child: const Icon(
                                                                                      Icons.phone,
                                                                                      color: Colors.blueAccent,
                                                                                      size: 18,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                const SizedBox(
                                                                                  width: 10,
                                                                                ),
                                                                                InkWell(
                                                                                  onTap: () {

                                                                                    print(mySelVendors[0]);
                                                                                    Functions().handleChatWithVendors(context, mySelVendors[0]['Email'], mySelVendors[0]['VendorName']);
                                                                                    // print('whatsapp : ');

                                                                                    // PhoneDialog().showPhoneDialog(context, mySelVendors[0]['PhoneNumber1'],
                                                                                    //     mySelVendors[0]['PhoneNumber2'], true);
                                                                                  },
                                                                                  child: Container(
                                                                                    alignment: Alignment.center,
                                                                                    height: 30,
                                                                                    width: 30,
                                                                                    decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey[200]),
                                                                                    child: const Icon(
                                                                                      Icons.chat,
                                                                                      color: Colors.pink,
                                                                                      size: 18,
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
                                                        ),

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

                                                          pref.setString("passCakeType","$cakeName");

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
                                                  ):
                                                  Container(),
                                                  !vendorCakeMode?
                                                  SizedBox(
                                                    height: 10,
                                                  ):Container(),
                                                  !vendorCakeMode?
                                                  Container(
                                                    height: 190,
                                                    child: ListView.builder(
                                                        scrollDirection: Axis.horizontal,
                                                        shrinkWrap: true,
                                                        itemCount: nearestVendors.length > 5?5:nearestVendors.length,
                                                        itemBuilder:
                                                            (context, index) {

                                                              var deliverCharge = double.parse("${((adminDeliveryCharge / adminDeliveryChargeKm) *
                                                                  (calculateDistance(double.parse(userLatitude),
                                                                      double.parse(userLongtitude),nearestVendors[index]['GoogleLocation']['Latitude'],
                                                                      nearestVendors[index]['GoogleLocation']['Longitude'])))}").toStringAsFixed(1);
                                                              var betweenKm = (calculateDistance(double.parse(userLatitude),
                                                                  double.parse(userLongtitude), nearestVendors[index]['GoogleLocation']['Latitude'],
                                                                  nearestVendors[index]['GoogleLocation']['Longitude'])).toStringAsFixed(1);

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
                                                                   //fetchToppersById(mySelVendors[0]['VendorID'].toString());
                                                                   loadCakeDetailsByVendor(mySelVendors[0]['_id'].toString(), cakeName , 0);
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
                                                                            double.parse(betweenKm)<=2.0?Text(
                                                                               "DELIVERY FREE",
                                                                              style: TextStyle(color: Colors.orange, fontSize: 10, fontFamily: "Poppins"),
                                                                            ):
                                                                            Text(
                                                                              "${betweenKm} KM Charge Rs.${deliverCharge}",
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
                                //final Button
                                
                                Center(
                                  child: Container(
                                    height: 50,
                                    width: 200,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(25)),
                                    child: CustomRaisedButton(
                                      onPressed: () async {
                                        FocusScope.of(context).unfocus();
                                        if (newRegUser == true) {
                                          ProfileAlert().showProfileAlert(context);
                                        }
                                        else if(tooFar == true){
                                          Functions().showSnackMsg(context, "Delivery address is too far , select nearest delivery address", true);
                                        }
                                        else {
                                          if(double.parse(fixedWeight.toLowerCase().replaceAll("kg", ""))
                                              <double.parse(basicCakeWeight
                                          .toLowerCase().replaceAll("kg", ""))){
                                            Functions().showSnackMsg(context,"Minimum weight is $basicCakeWeight" , true);
                                          }else if(customweightCtrl.text=="0"||customweightCtrl.text=="0.0"||
                                              customweightCtrl.text.startsWith("0")&&
                                                  customweightCtrl.text.endsWith("0")){
                                            Functions().showSnackMsg(context, "Please select the correct weight", true);
                                          }
                                          else if(deliverDate.toLowerCase()=="select delivery date"){
                                            Functions().showSnackMsg(context, "Please select the delivery date.", true);
                                          }else if(deliverSession.toLowerCase()=="select delivery time"){
                                            Functions().showSnackMsg(context, "Please select the delivery session", true);
                                          }else if(fixedDelliverMethod.isEmpty){
                                            Functions().showSnackMsg(context, "Please select pickup / delivery", true);
                                          }else if(deliverAddressIndex==-1){
                                            Functions().showSnackMsg(context, "Please select the delivery address!", true);
                                          }else{
                                            loadOrderPreference();
                                          }
                                        }
                                        ///handleNavigation();
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

String changeKilo(String weight){

  String givenWeight = weight;
  String finalWeight = "";
  if(givenWeight.toLowerCase().endsWith("kg")){
    givenWeight = givenWeight.toLowerCase().replaceAll("kg", "");
    finalWeight = givenWeight+"kg";
  }else{
    givenWeight = givenWeight.toLowerCase().replaceAll("g", "");
    finalWeight = (double.parse(givenWeight)/1000).toString()+"kg";
  }

  print(finalWeight);

  return finalWeight;
}

String dayMinConverter(String deliverTime){
  String givenSess = deliverTime;
  String finalDay = "";
  if(givenSess.toLowerCase().contains("day")||givenSess.toLowerCase().contains("days")){
    finalDay = givenSess.replaceAll(new RegExp(r'[^0-9]'), "");

  }else if(givenSess.toLowerCase().contains("hours")){
    int myDay = (double.parse(givenSess.replaceAll(new RegExp(r'[^0-9]'), ""))/24).toInt();
    if(myDay > 1){
      finalDay = myDay.toString();
    }else{
      finalDay = "1";
    }
  }

  return finalDay;
}

int addZeroBefSingleDigit(int count){
  String befZero = "0";
  int finalCount = 0;
  if(count < 10){
    var temp = befZero+count.toString();
    print(temp);
  }else{
    finalCount = count;
  }

  return finalCount;
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

