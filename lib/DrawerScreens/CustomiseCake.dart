import 'dart:convert';
import 'dart:io' as fil;
import 'dart:io';
import 'dart:math';
import 'package:cakey/OtherProducts/OtherDetails.dart';
import 'package:cakey/functions.dart';
import 'package:cakey/screens/utils.dart';
import 'package:flutter/services.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:http/http.dart' as http ;
import 'package:cakey/DrawerScreens/VendorsList.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mime/mime.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:url_launcher/url_launcher.dart';
import '../ContextData.dart';
import 'package:path/path.dart' as Path;
import 'package:http_parser/http_parser.dart';
import '../Dialogs.dart';
import '../ProfileDialog.dart';
import '../ShowToFarDialog.dart';
import '../drawermenu/NavDrawer.dart';
import '../drawermenu/app_bar.dart';
import '../screens/AddressScreen.dart';
import '../screens/CakeDetails.dart';
import '../screens/Profile.dart';
import '../screens/SingleVendor.dart';
import 'HomeScreen.dart';
import 'Notifications.dart';
import 'package:google_maps_webservice/places.dart' as wbservice;


class CustomiseCake extends StatefulWidget {
  const CustomiseCake({Key? key}) : super(key: key);

  @override
  State<CustomiseCake> createState() => _CustomiseCakeState();
}

class _CustomiseCakeState extends State<CustomiseCake> {

  //region Variables

  //key
  var _scaffoldKey = GlobalKey<ScaffoldState>();

  //Colors code
  Color lightGrey = Color(0xffF5F5F5);
  Color darkBlue = Color(0xffF213959);
  Color lightPink = Color(0xffFE8416D);
  DateTime? currentBackPressTime;
  //shapes
  var shapesList = [];

  var shapeGrpValue = 0;

  var flavourList = [];

  var flavGrpValue = 0;

  int notiCount = 0;

  //cake articles
  var cakeArticles = ["Default" , 'Cake Article','Cake Article','Cake Art'];
  var artGrpValue = 0;
  String fixedCakeArticle = '';
  String tempCakeName = '';

  //Articles
  var articals = [];
  int articGroupVal = -1;

  int selVendorIndex = 0;

  //String family
  String poppins = "Poppins";
  String userMainLocation ="";
  String profileUrl = '';
  String btnMsg = 'ORDER NOW';
  String tier = 'No Tier';


  //Fixed Strings and Lists
  String fixedCategory = 'Birthday';
  String fixedShape = '';
  //flavours
  List fixedFlavList = [];
  List flavTempList = [];
  List<bool> fixedFlavChecks = [];

  bool vendorListClicked = false;

  String fixedFlavour = 'Vanilla';
  String fixedExtraArticle = '';
  String fixedCakeTower = '';

  //var weight
  int isFixedWeight = -1;
  String fixedWeight = '0.0';
  String fixedDate = 'Select delivery date';
  String fixedSession = 'Select delivery time';
  String deliverAddress = 'Washington , Vellaimaligai , USA ,007 ';
  List<String> deliveryAddress = [];
  int deliverAddressIndex = -1;
  String selectedDropWeight = "Kg";
  String fixedDelliverMethod = "Not Yet Select";

  //cake text ctrls
  var msgCtrl = new TextEditingController();
  var specialReqCtrl = new TextEditingController();
  var addArticleCtrl = new TextEditingController();
  var weightCtrl = new TextEditingController();
  var deliverToCtrl = new TextEditingController();
  var themeCtrl = new TextEditingController();

  var showAddressEdit = false;

  String cakeMessage = '';
  String cakeRequest = "";
  String authToken = "";

  //main variables
  bool egglesSwitch = false;
  bool addOtherArticle = false;
  String userCurLocation = 'Searching...';
  String notificationId = "";

  var weight = [
    // 1, 1.5 , 2 , 2.5 , 3 , 4 , 5 , 5.5, 6 , 7,
  ];

  var cakeTowers = ["2","3","5","8"];
  int currentIndex = 0;

  List<bool> selwIndex = [];
  List<bool> selCakeTower = [];

  //For category selecions
  List<Widget> cateWidget = [];
  List<bool> selCategory = [];
  List categories = ["Birthday" , "Wedding"  ,
    "Anniversary" , "Farewell","Occasion", "Others"
  ];
  List nearestVendors = [];
  List mySelectdVendors = [];
  List filteredEggList = [];

  var selFromVenList = false;

  //my venor details
  String myVendorName = 'null';
  String myVendorId = 'null';
  String myVendorProfile ='null';
  String myVendorDelCharge = 'null';
  String myVendorPhone = 'null';
  String myVendorDesc = 'null';

  bool iamYourVendor = false;

  //file
  var file = new fil.File('');

  //Del or Picup
  var picOrDeliver = ["Pickup","Delivery"];
  var picOrDel = -1;

  bool shapeExpanded = true;
  bool flavourExpanded = false;

  //vendors details
  String vendorID = '';
  String vendorName = '';
  String vendorAddress = '';
  String vendorPhone = '';
  String vendorModId = '';
  String vendorPhone1 = "";
  String vendorPhone2 = "";
  String venLat = "";
  String venLong = "";


  //Current user details
  String userID ='';
  String userModId = '';
  String userName ='';
  String userPhone ='';

  var cateListScrollCtrl = new ScrollController();

  bool newRegUser = false;
  bool nearVendorClicked = false;

  //delivery
  int adminDeliveryCharge = 0;
  int adminDeliveryChargeKm = 0;
  String userLatitude = "";
  String userLongtitude = "";
  bool tooFar = false;

  int _key = 0;

  _collapse() {
    setState(() {
      shapeExpanded = !shapeExpanded;
    });
    int newKey = 0;
    do {
      _key = new Random().nextInt(10000);
    } while(newKey == _key);
  }

  //endregion

  //region Dialogs


  //Profile update remainder dialog
  void showDpUpdtaeDialog(){
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
                          borderRadius: BorderRadius.circular(10)
                      ),
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
                      GestureDetector(
                        onTap:(){
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
                        child: Container(
                          height: 25,
                          width: 80,
                          alignment: Alignment.center,
                          decoration:BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            color:lightPink
                          ),
                          child: Text(
                            'PROFILE',
                            style: TextStyle(
                                color: Colors.white,
                                fontFamily: "Poppins",
                                fontSize: 10),
                          )
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

  //Default loader dialog
  void showAlertDialog(){
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context){
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

  //add other category
  void showOthersCateDialog(){

    var otherCtrl = new TextEditingController();
    bool error = false;

    showDialog(
        context: context,
        builder: (context){
          return StatefulBuilder(
              builder: (BuildContext context , void Function(void Function()) setState){
                return AlertDialog(
                  title: Text('Other Category', style:
                  TextStyle(
                      color: darkBlue,
                      fontFamily: "Poppins",
                      fontSize: 13
                  )
                    ,),
                  content: Container(
                    child: TextField(
                      controller: otherCtrl,
                      decoration: InputDecoration(
                          hintText: 'Enter Category...',
                          errorText: error==true?
                          "Please enter some text.":
                          null
                      ),
                    ),
                  ),
                  actions: [
                    TextButton(
                        onPressed: (){
                          saveNotOther();
                        },
                        child: Text('Cancel')
                    ),
                    TextButton(
                        onPressed: (){
                          if(otherCtrl.text.isEmpty){
                            setState((){
                              error = true;
                            });
                          }else{
                            setState((){
                              error = false;
                              saveAllOthers(otherCtrl.text, "", "", "");
                            });
                          }
                        },
                        child: Text('Add')
                    )
                  ],
                );
              }
          );
        }
    );

  }

  //add other flavour
  void showOthersFlavourDialog(int index){

    var otherCtrl = new TextEditingController();
    bool error = false;

    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context){
          return StatefulBuilder(
              builder: (BuildContext context , void Function(void Function()) setState){
                return AlertDialog(
                  title: Text('Other Flavour', style:
                  TextStyle(
                      color: darkBlue,
                      fontFamily: "Poppins",
                      fontSize: 13
                  )
                    ,),
                  content: Container(
                    child: TextField(
                      controller: otherCtrl,
                      decoration: InputDecoration(
                          hintText: 'Enter Flavour...',
                          errorText: error==true?
                          "Please enter some text.":
                          null
                      ),
                    ),
                  ),
                  actions: [

                    TextButton(
                        onPressed: (){
                          Navigator.pop(context);
                        },
                        child: Text('Cancel')
                    ),

                    TextButton(
                        onPressed: (){
                          if(otherCtrl.text.isEmpty){
                            setState((){
                              error = true;
                            });
                          }else{
                            setState((){
                              error = false;
                              sendOtherToApi("Flavour", otherCtrl.text);
                              saveAllOthers("", "" ,otherCtrl.text.toString() , "");
                            });
                          }
                        },
                        child: Text('Add')
                    ),
                  ],
                );
              }
          );
        }
    );

  }

  //add other shape
  void showOthersShapeDialog(int index){

    var otherCtrl = new TextEditingController();
    bool error = false;

    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context){
          return StatefulBuilder(
              builder: (BuildContext context , void Function(void Function()) setState){
                return AlertDialog(
                  title: Text('Other Shape', style:
                  TextStyle(
                      color: darkBlue,
                      fontFamily: "Poppins",
                      fontSize: 13
                  )
                    ,),
                  content: Container(
                    child: TextField(
                      controller: otherCtrl,
                      decoration: InputDecoration(
                          hintText: 'Enter Shape...',
                          errorText: error==true?
                          "Please enter some text.":
                          null
                      ),
                    ),
                  ),
                  actions: [

                    TextButton(
                        onPressed: (){
                          saveNotOtherShape();
                        },
                        child: Text('Cancel')
                    ),

                    TextButton(
                        onPressed: (){
                          if(otherCtrl.text.isEmpty){
                            setState((){
                              error = true;
                            });
                          }else{
                            setState((){
                              error = false;
                              sendOtherToApi("Shape", otherCtrl.text);
                              saveAllOthers("", otherCtrl.text ,"", "");
                            });
                          }
                        },
                        child: Text('Add')
                    ),


                  ],
                );
              }
          );
        }
    );

  }

  void showCakeNameEdit(){
    var myCtrl = new TextEditingController(text: "My Customized Cake");
    showDialog(
        context: context,
        builder: (c)=>
            StatefulBuilder(
                builder: (BuildContext context, StateSetter setState){
                  return AlertDialog(
                    title: Text("Cake Name"),
                    content: Container(
                      child: TextField(
                        controller: myCtrl,
                        decoration: InputDecoration(
                          hintText: 'Cake Name'
                        ),
                      ),
                    ),
                    actions: [
                      TextButton(
                          onPressed: (){
                            Navigator.pop(context);
                            setState((){
                              tempCakeName = myCtrl.text;
                            });
                            showConfirmOrder();
                          },
                          child: Text("Order")
                      )
                    ],
                  );
                }
            )
    );
  }

  //Confirm order
  void showConfirmOrder(){
    showDialog(
      context: context,
      builder: (context)=>
          AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)
            ),
            title: Row(
              children: [
                Text('Confirm This Order' , style: TextStyle(
                    color:darkBlue , fontSize: 14.5 , fontFamily: "Poppins",
                    fontWeight: FontWeight.bold
                ),),
              ],
            ),
            content: Text('Are You Sure? Your Customize Cake Will Be Ordred!' , style: TextStyle(
                color:lightPink , fontSize: 13 , fontFamily: "Poppins"
            ),),
            actions: [
              TextButton(
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  child: Text('Cancel')
              ),
              TextButton(
                  onPressed: (){
                    Navigator.pop(context);
                    confirmOrder(tempCakeName);
                  },
                  child: Text('Order Now')
              ),
            ],
          ),
    );
  }

  //endregion

  //region Functions

  //Distance calculator
  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  Future<void> removeMyVendorPref() async{

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

  //load my vendor Details
  Future<void> loadSelVendorDetails() async{
    var pref = await SharedPreferences.getInstance();
    setState((){
      myVendorName = pref.getString('myVendorName')??'null';
      myVendorId= pref.getString('myVendorId')??'null';
      myVendorProfile= pref.getString('myVendorProfile')??'null';
      myVendorDelCharge= pref.getString('myVendorDeliverChrg')??'null';
      myVendorPhone= pref.getString('myVendorPhone')??'null';
      myVendorDesc= pref.getString('myVendorDesc')??'null';
      iamYourVendor= pref.getBool('iamYourVendor')??false;
    });
  }

  Future<void> loadPrefs() async{
    var pref = await SharedPreferences.getInstance();
    setState(() {
      adminDeliveryCharge = pref.getInt("todayDeliveryCharge")??0;
      adminDeliveryChargeKm = pref.getInt("todayDeliveryKm")??0;
      userLatitude = pref.getString('userLatitute')??'Not Found';
      userLongtitude = pref.getString('userLongtitude')??'Not Found';
      newRegUser = pref.getBool('newRegUser')??false;
      userID = pref.getString('userID')??'Not Found';
      userModId = pref.getString('userModId')??'Not Found';
      userName = pref.getString('userName')??'Not Found';
      deliverAddress = pref.getString('userAddress')??'Not Found';
      userPhone = pref.getString('phoneNumber')??'Not Found';
      authToken= pref.getString('authToken')??'null';
      userCurLocation = pref.getString('userCurrentLocation')??'Not Found';
      userMainLocation = pref.getString('userMainLocation')??'Not Found';

      deliveryAddress = pref.getStringList('addressList')??[deliverAddress.trim()];

    });
    getVendorsList();
    getShapesList();
    // prefs.setString('userID', userID);
    // prefs.setString('userAddress', userAddress);
    // prefs.setString('userName', userName);

  }

  //sessions based on time
  String session() {
    var timeNow = DateTime.now().hour;
    if (timeNow <= 12) {
      return "Morning";
    }
    else if ((timeNow > 12) && (timeNow <= 16)) {
      return "Afternoon";
    }
    else if ((timeNow > 16) && (timeNow < 20)) {
      return "Evening";
    }
    else {
      return "Night";
    }
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
        // Android's shouldShowRequestPermissionRListtionale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        print('Location permissions are denied');
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      print('Location permissions are permanently denied, we cannot request permissions.');
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.

    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  //add new address
  Future<void> saveNewAddress(String street , String city , String district , String pincode) async{

    setState((){
      deliverAddress = "$street , $city , $district , $pincode";
    });

    Navigator.pop(context);

  }

  //geting the flavous fom collection
  Future<void> getFlavsList() async{

    try{
      var res = await http.get(Uri.parse('${API_URL}api/flavour/list'),
          headers: {"Authorization":"$authToken"}
      );

      if(res.statusCode==200){
        setState((){
          List myList = jsonDecode(res.body);

          if(myList.isNotEmpty){
            for(int i=0;i<myList.length;i++){
              flavourList.add(myList[i]['Name']);
            }
            flavourList.insert(flavourList.indexWhere((element) => element==flavourList.last)+1, "Others");
          }else{
            flavourList = ["Others"];
          }

        });
      }else{
        print(res.statusCode);
      }
    }catch(e){

    }
    
    // getArticleList();

  }

  //geting the shapes fom collection
  Future<void> getShapesList() async{

    var res = await http.get(Uri.parse('${API_URL}api/shape/list'),
        headers: {"Authorization":"$authToken"}
    );

    if(res.statusCode==200){
      List myList = jsonDecode(res.body);

      if(myList.isNotEmpty){
        setState((){

          shapesList = myList;
          shapesList.insert(myList.indexWhere((element) => element==myList.last)+1, {"Name":"Others"});

        });
      }else{
        setState((){
          shapesList = [
            {"Name":"Others"},
          ];
        });
      }



    }else{
      print(res.statusCode);
    }

    getWeightList();
    
  }

  //geting the article fom collection
  Future<void> getArticleList() async{

    var res = await http.get(Uri.parse('${API_URL}api/article/list'),
        headers: {"Authorization":"$authToken"}
    );

    if(res.statusCode==200){
      List myList = jsonDecode(res.body);
      setState((){
        if(myList.isNotEmpty){
          for(int i=0;i<myList.length;i++){
            articals.add(myList[i]['Name']);
          }
          articals.insert(0, "Others");
        }else{
          articals = ["Others"];
        }

      });
    }else{
      print(res.statusCode);
    }
  }

  //geting the weight fom collection
  Future<void> getWeightList() async{

    try{

      print('weight...');
      var res = await http.get(Uri.parse('${API_URL}api/weight/list'),
          headers: {"Authorization":"$authToken"}
      );
      if(res.statusCode==200){
        setState((){
          List myList = jsonDecode(res.body);

          if(myList.isNotEmpty){
            for(int i=0;i<myList.length;i++){
              weight.add(myList[i]['Weight']);
            }
            print(weight);
          }else{
            weight = ["1kg","2kg","3kg" , "4kg", "5kg" , "6kg"];
          }

          weight = weight.toSet().toList();
          weight.sort((a,b)=>changeWeight(a.toString()).compareTo(changeWeight(b.toString())));

        });
      }else{
        print(res.statusCode);
      }

    }catch(e){

    }

    getFlavsList();

  }

  //get the vendors....
  Future<void> getVendorsList() async{
    print("vendor....");
    showAlertDialog();
    try{
      var res = await http.get(Uri.parse("${API_URL}api/activevendors/list"),
          headers: {"Authorization":"$authToken"}
      );
      if(res.statusCode==200){
        setState(() {
          List vendorsList = jsonDecode(res.body);
          for(int i = 0; i<vendorsList.length;i++){
            /*if(vendorsList[i]['Address']!=null&&vendorsList[i]['Address']['City']!=null&&
                vendorsList[i]['Address']['City'].toString().toLowerCase()==userMainLocation.toLowerCase()){*/
              print('found .... $i');
              setState(() {
                nearestVendors = vendorsList.where((element) =>
                calculateDistance(double.parse(userLatitude),double.parse(userLongtitude),
                    element['GoogleLocation']['Latitude'],element['GoogleLocation']['Longitude'])<=10
                ).toList();

                filteredEggList = vendorsList.where((element) =>
                calculateDistance(double.parse(userLatitude),double.parse(userLongtitude),
                    element['GoogleLocation']['Latitude'],element['GoogleLocation']['Longitude'])<=10
                ).toList();

                print("vendor length : ... ${nearestVendors.length}");
                print("vendor length : ... ${filteredEggList.length}");

              });
          }
          if(filteredEggList.isEmpty){
            nearVendorClicked = true;
          }
          Navigator.pop(context);
        });
      }else{
        checkNetwork();
        Navigator.pop(context);
      }
    }catch(e){
      print("vendor.... $e");
      checkNetwork();
      Navigator.pop(context);
      // ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(content: Text('Error Occurred'),
      //       backgroundColor: Colors.amber,
      //       action: SnackBarAction(
      //         label: "Retry",
      //         onPressed:()=>setState(() {
      //           loadPrefs();
      //         }),
      //       ),
      //     )
      // );
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

  //File piker for upload image
  Future<void> filePicker() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      setState(() {
        String path = result.files.single.path.toString();
        file = fil.File(path);
        print("file $file");
      });
    } else {
      // User canceled the picker
    }
  }

  //save if not enter others
  void saveNotOther(){
    Navigator.pop(context);
    setState((){
      currentIndex=0;
      fixedCategory = "${categories[0]}";
      cateListScrollCtrl.jumpTo(cateListScrollCtrl.position.minScrollExtent);
    });
  }

  void saveNotOtherShape(){
    Navigator.pop(context);
    setState((){
      shapeGrpValue = 0;
      fixedShape = "";
    });
  }

  //Save all added others
  Future<void> saveAllOthers(String category, String shape, String flavour, String article) async{
    print('$category Entre....');

    setState((){

      if(category.isNotEmpty){
        if(category=="Others"){
          currentIndex = 0;
        }else{
          categories.insert(0, '$category');
          currentIndex = 0;
          //cateListScrollCtrl.jumpTo(cateListScrollCtrl.position.minScrollExtent);
          fixedCategory = category;
        }
      }

      if(shape.isNotEmpty){
        fixedShape = shape;
      }

      if(flavour.isNotEmpty){
        flavTempList.add({"Name":flavour, "Price":'0'});
      }

      // fixedCakeArticle = article;
    });


    print(fixedCategory);
    print(fixedShape);
    print(fixedFlavList);
    print(fixedCakeArticle);

    Navigator.pop(context);

  }

  //Load Order Preferences...
  Future<void> confirmOrder(String ckName) async{

    var tempList = [];
    var flavMsg = [];

    setState((){
      if(fixedFlavList.isEmpty){
        fixedFlavList = [{"Name":"Vanilla","Price":"0"}];
      }else{
        fixedFlavList = fixedFlavList+flavTempList;

        for(int i = 0;i<fixedFlavList.length;i++){
          tempList.add(fixedFlavList[i]);
          flavMsg.add(fixedFlavList[i]['Name']);
        }

        tempList = tempList.toSet().toList();
      }

      if(fixedShape.isEmpty){
        fixedShape = "Vanilla";
      }

      fixedWeight = fixedWeight.toLowerCase().replaceAll("kg", "");

      print(double.parse(fixedWeight));

      print(vendorID);

    });

    String message = "Hi , I want this customize cake can you make this?\n\n"+
        "Egg / Eggless : ${egglesSwitch==true?"Eggless":"Egg"}\n"
        "Selected Category : $fixedCategory\n"
        "Selected Shape : $fixedShape\n"
        "Selected Flavour : ${flavMsg.toString().replaceAll("[", "").replaceAll("]","")}\n"
        "Selected Weight : ${fixedWeight.toLowerCase().replaceAll("kg", "")}Kg\n"
        "Deliver Method : $fixedDelliverMethod\n"
        "Deliver Date : $fixedDate\n"
        "Cake Message : ${msgCtrl.text.isNotEmpty?msgCtrl.text:"None"}\n"
        "Deliver Session : $fixedSession\n\n"
        "Thank You.".toString();

    String whatsapp = vendorPhone1;
    var whatsappURl_android = "whatsapp://send?phone="+whatsapp+"&text=${message}";
    var whatappURL_ios ="https://wa.me/$whatsapp?text=${Uri.parse("hello")}";


    showAlertDialog();


    print(message);


    print("letsvdhgdsh "+nearestVendors.length.toString());


    print(
      {
        "User_ID":userModId,
        'UserID': userID,
        'UserName': userName,
        'UserPhoneNumber': userPhone,
        'VendorID': '$vendorID',
        'VendorName': '$vendorName',
        'VendorAddress': '$vendorAddress',
        'Vendor_ID':'$vendorModId',
        'VendorPhoneNumber1':'$vendorPhone1',
        'VendorPhoneNumber2':'$vendorPhone2',
        'PremiumVendor':"n",
        'MessageOnTheCake':msgCtrl.text,
      }
    );


      try{

        // http://sugitechnologies.com/cakey

          var request = http.MultipartRequest('POST',
              Uri.parse('${API_URL}api/customize/cake/new'));

          request.headers['Content-Type'] = 'multipart/form-data';

          request.fields.addAll({
            'CakeType': fixedCategory,
            'CakeName':ckName.isEmpty?"My Customized Cake":ckName,
            'EggOrEggless': egglesSwitch==false?'Egg':'Eggless',
            'Flavour': jsonEncode(tempList),
            'Shape': fixedShape,
            'Weight': fixedWeight+'kg',
            'DeliveryAddress': deliverAddress,
            'DeliveryDate': fixedDate,
            'DeliverySession': fixedSession,
            'DeliveryInformation': fixedDelliverMethod,
            "User_ID":userModId,
            'UserID': userID,
            'UserName': userName,
            'UserPhoneNumber': userPhone,
          });

          if(msgCtrl.text.isNotEmpty){
            request.fields.addAll({
              'MessageOnTheCake':msgCtrl.text,
            });
          }

          if(tier.toLowerCase()!="no tier"){
            request.fields.addAll({
              'Tier':tier,
            });
          }

          if(themeCtrl.text.isNotEmpty){
            request.fields.addAll({
              'Theme':themeCtrl.text,
            });
          }

          if(specialReqCtrl.text.isNotEmpty){
            request.fields.addAll({
              'SpecialRequest':specialReqCtrl.text,
            });
          }

          if(file.path.isNotEmpty){
            request.files.add(await http.MultipartFile.fromPath(
                'files', file.path.toString(),
                filename: Path.basename(file.path),
                contentType: MediaType.parse(lookupMimeType(file.path.toString()).toString())
            ));
          }

          if(double.parse(fixedWeight.toLowerCase().replaceAll("kg", ""))<=5.0){
            request.fields.addAll({
              'VendorID': '$vendorID',
              'VendorName': '$vendorName',
              'VendorAddress': '$vendorAddress',
              'Vendor_ID':'$vendorModId',
              'VendorPhoneNumber1':'$vendorPhone1',
              'VendorPhoneNumber2':'$vendorPhone2',
              'PremiumVendor':"n",
              "GoogleLocation":jsonEncode({"Latitude":venLat , "Longitude":venLong})
            });
          }

          if(double.parse(fixedWeight.toLowerCase().replaceAll("kg", ""))>5.0||nearestVendors.isEmpty){
            request.fields.addAll({
              'PremiumVendor':"y",
            });
          }

          http.StreamedResponse response = await request.send();

          if (response.statusCode == 200) {
            var map = jsonDecode(await response.stream.bytesToString());
            print(map);
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(map['message']),
                  backgroundColor: Colors.green[600],
                  behavior: SnackBarBehavior.floating,
                )
            );

            double.parse(fixedWeight.toLowerCase().replaceAll("kg", ""))<5.0?
            sendNotificationToVendor(notificationId):null;

            // PhoneDialog().showPhoneDialog(context, vendorPhone1, vendorPhone2 , true , message);

            // if(Platform.isIOS){
            //   // for iOS phone only
            //   if( await canLaunch(whatappURL_ios)){
            //     await launch(whatappURL_ios, forceSafariVC: false);
            //   }else{
            //     ScaffoldMessenger.of(context).showSnackBar(
            //         SnackBar(content: new Text("Whatsapp not found.")));
            //   }
            // }else{
            //   // android , web
            //   if( await canLaunch(whatsappURl_android)){
            //     await launch(whatsappURl_android);
            //   }else{
            //     ScaffoldMessenger.of(context).showSnackBar(
            //         SnackBar(content: new Text("Whatsapp not found.")));
            //   }
            // }
            var pr = await SharedPreferences.getInstance();
            pr.setString("showMoreVendor", "null");
            Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context)=>HomeScreen())
            );
          }else{
            checkNetwork();
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error Occurred ${response.statusCode}'),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                )
            );
          }

      }catch(e){
        print(e);
        checkNetwork();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error Occurred'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            )
        );
      }

  }

  //post the others to API
  Future<void> sendOtherToApi(String obj , String value) async{
    print(obj);
    print(value);
    var headers = {
      'Content-Type': 'application/json'
    };
    //var request = http.Request('POST', Uri.parse('http://sugitechnologies.com/cakey/api/${obj.toLowerCase()}/new'));
    var request = http.Request('POST', Uri.parse('${API_URL}api/${obj.toLowerCase()}/new'));
    request.body = json.encode({
      obj: value
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
    }
    else {
      print(response.reasonPhrase);
    }

  }

  Future<void> sendNotificationToVendor(String? NoId) async{
    Functions().sendThePushMsg("You got new customise cake order", "Hi $vendorName , $tempCakeName is just Ordered By $userName.", NoId.toString());
  }

  void showLocationChangeDialog(){
    showDialog(
        context: context,
        builder: (context){
          return StatefulBuilder(
            builder: (context,setState){
              return AlertDialog(
                scrollable: true,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)
                ),
                contentPadding: EdgeInsets.all(10),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("New Location",style: TextStyle(
                        color: darkBlue,fontFamily: "Poppins",
                        fontSize: 16,fontWeight: FontWeight.bold
                    ),),
                    SizedBox(height: 8,),
                    TextField(
                      controller: deliverToCtrl,
                      textCapitalization: TextCapitalization.sentences,
                      decoration:InputDecoration(
                          hintText: "Type location...",
                          hintStyle: TextStyle(
                              color: Colors.grey[400],fontFamily: "Poppins",
                              fontSize: 13,fontWeight: FontWeight.bold
                          ),
                          suffixIcon: InkWell(
                              onTap: ()=>deliverToCtrl.text="",
                              child: Icon(Icons.clear))
                      ),
                    ),
                    SizedBox(height: 8,),
                  ],
                ),
                actions: [
                  TextButton(
                      onPressed: ()=>Navigator.pop(context),
                      child: Text("Cancel",style: TextStyle(
                          color: Colors.purple,fontFamily: "Poppins"
                      ),)
                  ),
                  TextButton(
                      onPressed: () async{
                        Navigator.pop(context);
                        controllLocationResult();
                      },
                      child: Text("Search",style: TextStyle(
                          color: Colors.purple,fontFamily: "Poppins"
                      ),)
                  ),
                ],
              );
            },
          );
        }
    );
  }

  Future<void> getCoordinates(String predictedAddress) async{

    var pref = await SharedPreferences.getInstance();

    try{

      if (predictedAddress.isNotEmpty) {
        List<Location> location =
        await locationFromAddress(predictedAddress);
        print(location);
        setState((){
          // userLat = location[0].latitude;
          // userLong = location[0].longitude;
          // getVendorForDeliveryto(authToken);
          // getCakeList();
          userLatitude = location[0].latitude.toString();
          userLongtitude = location[0].longitude.toString();
          pref.setString('userLatitute', "${userLatitude}");
          pref.setString('userLongtitude', "${userLongtitude}");
          pref.setString("userCurrentLocation", predictedAddress);
          userCurLocation = predictedAddress;
          getVendorsList();
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

  Future<void> controllLocationResult() async{
    var pref = await SharedPreferences.getInstance();
    FocusScope.of(context).unfocus();
    if(deliverToCtrl.text.isNotEmpty){
      List<Location> location =
      await locationFromAddress(deliverToCtrl.text);
      print(location);
      setState((){
        // userLat = location[0].latitude;
        // userLong = location[0].longitude;
        // getVendorForDeliveryto(authToken);
        // getCakeList();
        userLatitude = location[0].latitude.toString();
        userLongtitude = location[0].longitude.toString();
        pref.setString('userLatitute', "${userLatitude}");
        pref.setString('userLongtitude', "${userLongtitude}");
        pref.setString("userCurrentLocation", deliverToCtrl.text);
        userCurLocation = deliverToCtrl.text;
        getVendorsList();
      });
    }
  }

  //endregion

  @override
  void initState() {

    // TODO: implement initState
    Future.delayed(Duration.zero , () async{
      loadPrefs();
      context.read<ContextData>().setMyVendors([]);
      context.read<ContextData>().addMyVendor(false);
    });
    _collapse();
    // session();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    Future.delayed(
      Duration.zero, () async{
      // context.read<ContextData>().addMyVendor(false);
      // context.read<ContextData>().setMyVendors([]);
    }
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    profileUrl = context.watch<ContextData>().getProfileUrl();
    notiCount = context.watch<ContextData>().getNotiCount();

    if (context.watch<ContextData>().getAddressList().isNotEmpty) {
      deliveryAddress = context.watch<ContextData>().getAddressList();
    }

    // if(context.watch<ContextData>().getAddress().isNotEmpty){
    //   deliverAddress = context.watch<ContextData>().getAddress();
    // }else{
    //   deliverAddress = deliverAddress;
    // }

    selFromVenList = context.watch<ContextData>().getAddedMyVendor();
    mySelectdVendors = context.watch<ContextData>().getMyVendorsList();

    setState((){
      if(mySelectdVendors.isNotEmpty){
        vendorID = mySelectdVendors[0]['_id'];
        vendorModId = mySelectdVendors[0]['Id'];
        vendorName = mySelectdVendors[0]['VendorName'];
        vendorPhone1 = mySelectdVendors[0]['PhoneNumber1'];
        vendorPhone2 = mySelectdVendors[0]['PhoneNumber2'];
        vendorAddress = mySelectdVendors[0]['Address'];
      }
    });

    if(egglesSwitch==true){
      //filteredEggList
      nearestVendors = filteredEggList.where((element) =>
      element['EggOrEggless'] == 'Eggless' ||
          element['EggOrEggless'] == "Egg and Eggless")
          .toList();
    }else{
      nearestVendors = filteredEggList;
    }

    return WillPopScope(
      onWillPop: () async{
        //Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>HomeScreen()));
        context.read<ContextData>().setMyVendors([]);
        context.read<ContextData>().addMyVendor(false);
        return Future.value(true);
      },
      child: Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomInset: false,
        drawer: NavDrawer(screenName: "custom",),
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
                          FocusScope.of(context).unfocus();
                          _scaffoldKey.currentState?.openDrawer();
                          vendorListClicked = false;
                          var prefs = await SharedPreferences.getInstance();
                          prefs.setBool('iamYourVendor', false);
                          prefs.setBool('vendorCakeMode',false);
                          context.read<ContextData>().setMyVendors([]);
                          context.read<ContextData>().addMyVendor(false);
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
                                  SizedBox(width: 3,),
                                  CircleAvatar(
                                    radius: 5.2,
                                    backgroundColor: darkBlue,
                                  ),
                                ],
                              ),
                              SizedBox(height: 3,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                      radius: 5.2,
                                      backgroundColor: darkBlue
                                  ),
                                  SizedBox(width: 3,),
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
                      SizedBox(width: 15,),
                      Text("FULLY CUSTOMIZATION",
                          style: TextStyle(color: darkBlue,fontWeight: FontWeight.bold,fontFamily: poppins,
                              fontSize: 18
                          )),
                    ],
                  ),
                  CustomAppBars().CustomAppBar(context, "", notiCount, profileUrl,(){loadPrefs();})
                ],
              ),
            ),
          ),
        ),
          body:SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //Location name...
                Container(
                  padding: EdgeInsets.only(left:10,top: 8,bottom: 15),
                  color: lightGrey,
                  child: Column(
                    children: [
                      Container(
                        child: Row(
                          children: [
                            Icon(Icons.location_on,color: Colors.red,size: 18,),
                            SizedBox(width: 3,),
                            Text('Delivery to',style: TextStyle(color: Colors.black54,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,fontFamily: "Poppins"),)
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
                            SizedBox(width: 10,),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                //Main widgets....
                Container(
                  height:showAddressEdit ? MediaQuery.of(context).size.height*0.74:
                  MediaQuery.of(context).size.height*0.82,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [

                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text("What Makes Yours Tastier Than The Rest? Customize To Your Heart's",
                            style: TextStyle(color: darkBlue,fontSize: 15,fontFamily: "Poppins",
                                fontWeight: FontWeight.bold),
                          ),
                        ),

                        //Egg Eggless switch
                        Row(
                          children: [
                            Transform.scale(
                              scale: 0.6,
                              child: CupertinoSwitch(
                                thumbColor: Colors.white,
                                value: egglesSwitch,
                                onChanged: (bool? val){
                                  setState(() {
                                    egglesSwitch = val!;
                                  });
                                },
                                activeColor: Color(0xff058d05),
                              ),
                            ),
                            Text('Eggless',style: TextStyle(color: darkBlue,
                                fontFamily: "Poppins" ,fontSize: 13),),
                          ],
                        ),

                        //Category Text
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text("Select Categories",
                            style: TextStyle(color: darkBlue,fontSize: 14,fontFamily: "Poppins",),
                          ),
                        ),

                        Container(
                          margin: EdgeInsets.only(left:8,right:8),
                          child: Wrap(
                            children: categories.map((e){
                              return Stack(
                                children: [
                                  GestureDetector(
                                    onTap:(){

                                      if(e.toString().contains("Others")){
                                        print('Yes...');
                                        showOthersCateDialog();
                                      }

                                      setState((){
                                        currentIndex = categories.indexOf(e);
                                        fixedCategory = categories[currentIndex];
                                      });
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(5),
                                      child: Container(
                                          padding: EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                              border: Border.all(color: Color(0xffffa2bb),width: 1),
                                              borderRadius: BorderRadius.circular(5)
                                          ),
                                          child:
                                          e=="Others"?
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.add_circle_outline,color: lightPink,),
                                              SizedBox(width: 10,),
                                              Text('${e}',style: TextStyle(
                                                  fontFamily: "Poppins",
                                                  color: darkBlue,
                                                  fontSize: 13
                                              ),),
                                              SizedBox(width: 10,),
                                            ],
                                          ):
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              categories.indexOf(e)==0?Container(
                                                height: 25,
                                                width: 20,
                                                decoration: BoxDecoration(
                                                    image: DecorationImage(
                                                        image: AssetImage("assets/images/cakefour.jpg")
                                                    )
                                                ),
                                              ):
                                              categories.indexOf(e)==1?Container(
                                                height: 25,
                                                width: 20,
                                                decoration: BoxDecoration(
                                                    image: DecorationImage(
                                                        image: AssetImage("assets/images/cakethree.png")
                                                    )
                                                ),
                                              ):
                                              categories.indexOf(e)==2?Container(
                                                height: 25,
                                                width: 20,
                                                decoration: BoxDecoration(
                                                    image: DecorationImage(
                                                        image: AssetImage("assets/images/cakelist.png")
                                                    )
                                                ),
                                              ):
                                              categories.indexOf(e)==3?Container(
                                                height: 25,
                                                width: 25,
                                                decoration: BoxDecoration(
                                                    image: DecorationImage(
                                                        image: AssetImage("assets/images/cake-image-bottom.png")
                                                    )
                                                ),
                                              ):
                                              Container(
                                                height: 25,
                                                width: 25,
                                                decoration: BoxDecoration(
                                                    image: DecorationImage(
                                                        image: AssetImage("assets/images/customcake.png")
                                                    )
                                                ),
                                              ),
                                              SizedBox(width: 10,),
                                              Text('${e}',style: TextStyle(
                                                  fontFamily: "Poppins",
                                                  color: darkBlue,
                                                  fontSize: 13
                                              ),),
                                              SizedBox(width: 10,),
                                            ],
                                          )
                                      ),
                                    ),
                                  ),
                                  currentIndex == categories.indexOf(e)?
                                  Positioned(
                                      right: 0,
                                      child:Container(
                                          alignment: Alignment.center,
                                          height: 20,
                                          width: 20,
                                          decoration: BoxDecoration(
                                              color:Color(0xff058d05),
                                              shape: BoxShape.circle
                                          ),
                                          child:Icon(Icons.done_sharp , color:Colors.white , size: 14,)
                                      )
                                  ):
                                  Positioned(
                                      right: 0,
                                      child: Container()
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),

                        // //Category stacks ()....
                        // Container(
                        //     height: 80,
                        //     padding: EdgeInsets.all(10),
                        //     child: ListView.builder(
                        //         shrinkWrap: true,
                        //         controller: cateListScrollCtrl,
                        //         itemCount: categories.length,
                        //         scrollDirection: Axis.horizontal,
                        //         itemBuilder: (context , index){
                        //           return Stack(
                        //             children: [
                        //               GestureDetector(
                        //                 onTap:(){
                        //
                        //                   if(categories[index].toString().contains("Others")){
                        //                     print('Yes...');
                        //                     showOthersCateDialog();
                        //                   }
                        //
                        //                   setState((){
                        //                     currentIndex = index;
                        //                     fixedCategory = categories[currentIndex];
                        //                   });
                        //                 },
                        //                 child: Container(
                        //                   padding: EdgeInsets.all(5),
                        //                   child: Container(
                        //                     padding: EdgeInsets.all(8),
                        //                     decoration: BoxDecoration(
                        //                         border: Border.all(color: Color(0xffffa2bb),width: 1),
                        //                         borderRadius: BorderRadius.circular(8)
                        //                     ),
                        //                     child:
                        //                     categories[index]=="Others"?
                        //                     Row(
                        //                       mainAxisSize: MainAxisSize.min,
                        //                       children: [
                        //                         Icon(Icons.add_circle_outline,color: lightPink,),
                        //                         SizedBox(width: 10,),
                        //                         Text('${categories[index]}',style: TextStyle(
                        //                             fontFamily: "Poppins",
                        //                             color: darkBlue
                        //                         ),),
                        //                         SizedBox(width: 10,),
                        //                       ],
                        //                     ):
                        //                     Row(
                        //                       mainAxisSize: MainAxisSize.min,
                        //                       children: [
                        //                         index==0?Container(
                        //                           height: 25,
                        //                           width: 20,
                        //                           decoration: BoxDecoration(
                        //                               image: DecorationImage(
                        //                                   image: AssetImage("assets/images/cakefour.jpg")
                        //                               )
                        //                           ),
                        //                         ):
                        //                         index==1?Container(
                        //                           height: 25,
                        //                           width: 20,
                        //                           decoration: BoxDecoration(
                        //                               image: DecorationImage(
                        //                                   image: AssetImage("assets/images/cakethree.png")
                        //                               )
                        //                           ),
                        //                         ):
                        //                         index==2?Container(
                        //                           height: 25,
                        //                           width: 20,
                        //                           decoration: BoxDecoration(
                        //                               image: DecorationImage(
                        //                                   image: AssetImage("assets/images/cakelist.png")
                        //                               )
                        //                           ),
                        //                         ):
                        //                         index==3?Container(
                        //                           height: 25,
                        //                           width: 25,
                        //                           decoration: BoxDecoration(
                        //                               image: DecorationImage(
                        //                                   image: AssetImage("assets/images/cakefour.jpg")
                        //                               )
                        //                           ),
                        //                         ):
                        //                         Icon(Icons.cake_outlined , color: lightPink,),
                        //                         SizedBox(width: 10,),
                        //                         Text('${categories[index]}',style: TextStyle(
                        //                             fontFamily: "Poppins",
                        //                             color: darkBlue
                        //                         ),),
                        //                         SizedBox(width: 10,),
                        //                       ],
                        //                     )
                        //                   ),
                        //                 ),
                        //               ),
                        //               currentIndex == index?
                        //               Positioned(
                        //                   right: 0,
                        //                   child:Container(
                        //                       alignment: Alignment.center,
                        //                       height: 20,
                        //                       width: 20,
                        //                       decoration: BoxDecoration(
                        //                           color:Colors.green,
                        //                           shape: BoxShape.circle
                        //                       ),
                        //                       child:Icon(Icons.done_sharp , color:Colors.white , size: 14,)
                        //                   )
                        //               ):
                        //               Positioned(
                        //                   right: 0,
                        //                   child: Container()
                        //               ),
                        //             ],
                        //           );
                        //         }
                        //     )
                        // ),

                        //Shapes....flav...toppings
                        Container(
                            margin:const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                color:Color(0xffffe9df),
                                borderRadius: BorderRadius.circular(12)
                            ),
                            child:Column(
                                children:[
                                  ExpansionTile(
                                      key: new Key(_key.toString()),
                                      onExpansionChanged: (e){
                                        setState((){
                                          shapeExpanded = e;
                                        });
                                      },
                                      title: Text('Shape',style: TextStyle(
                                          fontFamily: "Poppins",fontSize: 13,color: Colors.grey
                                      ),),
                                      subtitle:Text(fixedShape.isEmpty?"Select shape":'$fixedShape',style: TextStyle(
                                          fontFamily: "Poppins",fontSize: 13,
                                          color: darkBlue
                                      ),),
                                      trailing:
                                      !shapeExpanded?Container(
                                        alignment: Alignment.center,
                                        height: 25,
                                        width: 25,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle ,
                                        ),
                                        child: Icon(Icons.keyboard_arrow_down_rounded , color: darkBlue,size: 25,),
                                      ):Container(
                                        alignment: Alignment.center,
                                        height: 25,
                                        width: 25,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle ,
                                        ),
                                        child: Icon(Icons.keyboard_arrow_up_outlined , color: darkBlue,size: 25,),
                                      ),
                                      children: [
                                        shapesList.isNotEmpty?
                                        Container(
                                          color:Colors.white,
                                          height: 300,
                                          child:ListView.builder(
                                              itemCount: shapesList.length,
                                              shrinkWrap: true,
                                              itemBuilder: (context, index) {

                                                return InkWell(
                                                  onTap: ()=>setState((){

                                                    shapeGrpValue = index;
                                                    fixedShape = shapesList[index]['Name'];

                                                    if(shapesList[index]['Name'].toString().contains('Others')){
                                                      showOthersShapeDialog(index);
                                                    }

                                                    _collapse();

                                                  }),
                                                  child: Container(
                                                    padding: EdgeInsets.only(top: 7,bottom: 7,left: 10),
                                                    child:
                                                    shapesList[index]['Name']=="Others"?
                                                    Row(
                                                      children: [
                                                        shapeGrpValue!=index?
                                                        Icon(Icons.add_circle_outline_rounded, color: Colors.black,):
                                                        Icon(Icons.check_circle, color: Colors.green,),
                                                        SizedBox(width: 5,),
                                                        Expanded(child: Text(
                                                          "${shapesList[index]['Name']}",
                                                          style: TextStyle(
                                                              fontFamily: "Poppins", color: darkBlue,
                                                              fontWeight: FontWeight.bold,fontSize: 13,
                                                          ),
                                                        ),)
                                                      ],
                                                    ):
                                                    Row(
                                                      children: [
                                                        shapeGrpValue!=index?
                                                        Icon(Icons.radio_button_unchecked, color: Colors.black,):
                                                        Icon(Icons.check_circle, color: Colors.green,),
                                                        SizedBox(width: 5,),
                                                        Expanded(child: Text(
                                                          "${shapesList[index]['Name']}",
                                                          style: TextStyle(
                                                              fontFamily: "Poppins", color: darkBlue,
                                                              fontWeight: FontWeight.bold,fontSize: 13,
                                                          ),
                                                        ),)
                                                      ],
                                                    )
                                                  ),
                                                );
                                              }),
                                        ):
                                        Center(
                                           child:Padding(
                                             padding: const EdgeInsets.all(8.0),
                                             child: Text("No Data Found"),
                                           )
                                        ),
                                      ],
                                    ),
                                  Container(
                                    margin: EdgeInsets.only(left: 8,right: 8),
                                    height: 0.5,
                                    color:Colors.white,
                                  ),
                                  ExpansionTile(
                                    title: Text('Flavours',style: TextStyle(
                                        fontFamily: "Poppins",fontSize: 13,color:Colors.grey
                                    ),),
                                    onExpansionChanged: (e){
                                      setState((){
                                        flavourExpanded = !flavourExpanded;
                                      });
                                    },
                                    subtitle:Text(fixedFlavList.isEmpty&&flavTempList.isEmpty?'Select flavours':
                                    '${fixedFlavList.length+flavTempList.length} Selected Flavours',style: TextStyle(
                                        fontFamily: "Poppins",fontSize: 13,
                                        color: darkBlue
                                    ),),
                                    trailing: !flavourExpanded?Container(
                                      alignment: Alignment.center,
                                      height: 25,
                                      width: 25,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle ,
                                      ),
                                      child: Icon(Icons.keyboard_arrow_down_rounded , color: darkBlue,size: 25,),
                                    ):Container(
                                      alignment: Alignment.center,
                                      height: 25,
                                      width: 25,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle ,
                                      ),
                                      child: Icon(Icons.keyboard_arrow_up_outlined , color: darkBlue,size: 25,),
                                    ),
                                    children: [
                                      flavourList.isNotEmpty?
                                      Container(
                                        color:Colors.white,
                                        height: 300,
                                        child:SingleChildScrollView(
                                          child: Column(
                                            children: [
                                              ListView.builder(
                                                  itemCount: flavourList.length,
                                                  physics: NeverScrollableScrollPhysics(),
                                                  shrinkWrap: true,
                                                  itemBuilder: (context, index) {
                                                    fixedFlavChecks.add(false);
                                                    return InkWell(
                                                      onTap: (){
                                                        if(flavourList[index].toString().contains('Others')){
                                                          print('Index is $index');
                                                          showOthersFlavourDialog(index);
                                                        }else{
                                                          setState((){
                                                            if(fixedFlavChecks[index]==false){
                                                              fixedFlavChecks[index] = true;
                                                              if(fixedFlavList.contains(flavourList[index].toString())){
                                                                print('exists...');
                                                              }else{
                                                                fixedFlavList.add({
                                                                  "Name": flavourList[index]
                                                                      .toString(),
                                                                  "Price": "0"
                                                                });
                                                              }
                                                            }else{
                                                              fixedFlavChecks[index] = false;
                                                              fixedFlavList.removeWhere((element) => element['Name']==flavourList[index].toString());
                                                            }
                                                          });
                                                        }
                                                      },
                                                      child: Container(
                                                        padding: EdgeInsets.only(top: 7,bottom: 7,left: 10),
                                                        child:
                                                        flavourList[index]=="Others"?
                                                        Row(
                                                          children: [
                                                            flavTempList.isEmpty?
                                                            Icon(Icons.add_circle_outline_rounded, color: Colors.green,):
                                                            Icon(Icons.check_circle, color: Colors.green,),
                                                            SizedBox(width: 5,),
                                                            Expanded(child: Text(
                                                              "${flavourList[index]}",
                                                              style: TextStyle(
                                                                  fontFamily: "Poppins", color: darkBlue,
                                                                  fontSize: 13,
                                                                  fontWeight: FontWeight.bold
                                                              ),
                                                            ),),
                                                          ],
                                                        ):
                                                        Row(
                                                          children: [
                                                            fixedFlavChecks[index]!=true?
                                                            Icon(Icons.radio_button_unchecked, color: Colors.green,):
                                                            Icon(Icons.check_circle, color: Colors.green,),
                                                            SizedBox(width: 5,),
                                                            Expanded(child: Text(
                                                              "${flavourList[index]}",
                                                              style: TextStyle(
                                                                  fontFamily: "Poppins", color: darkBlue,
                                                                  fontWeight: FontWeight.bold,fontSize: 13,
                                                              ),
                                                            ),),
                                                          ],
                                                        ),
                                                      ),
                                                    );

                                                  }),
                                              flavTempList.isNotEmpty?
                                              Container(
                                                width: MediaQuery.of(context).size.width,
                                                height: 55,
                                                child: ListView.builder(
                                                    scrollDirection: Axis.horizontal,
                                                    itemCount: flavTempList.length,
                                                    shrinkWrap: true,
                                                    itemBuilder: (c, i)=>Container(
                                                      child: Padding(
                                                        padding: const EdgeInsets.all(4.0),
                                                        child: ActionChip(
                                                            label:Row(
                                                              children: [
                                                                Text(flavTempList[i]['Name']),
                                                                SizedBox(width: 4,),
                                                                Icon(Icons.close , size: 20,)
                                                              ],
                                                            ),
                                                            onPressed: (){
                                                              setState((){
                                                                if(flavTempList.contains(flavTempList[i])){
                                                                  flavTempList.removeWhere((element) => element['Name']==flavTempList[i]['Name']);
                                                                }else{
                                                                  print('Nope...');
                                                                }
                                                              });
                                                            }
                                                        ),
                                                      ),
                                                    )
                                                ),
                                              ):
                                              Container()
                                            ],
                                          ),
                                        ),
                                      ):
                                      Center(
                                          child:Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text("No Data Found"),
                                          )
                                      ),
                                    ],
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(left: 8,right: 8),
                                    height: 0.5,
                                    color:Colors.white,
                                  ),
                                  // ExpansionTile(
                                  //   title: Text('Cake Articles',style: TextStyle(
                                  //       fontFamily: "Poppins",fontSize: 13,fontWeight: FontWeight.bold ,
                                  //       color: Colors.grey
                                  //   ),),
                                  //   subtitle:Text('$fixedCakeArticle',style: TextStyle(
                                  //       fontFamily: "Poppins",fontSize: 15,fontWeight: FontWeight.w900,
                                  //       color: darkBlue
                                  //   ),),
                                  //   trailing: Container(
                                  //     alignment: Alignment.center,
                                  //     height: 25,
                                  //     width: 25,
                                  //     decoration: BoxDecoration(
                                  //       color: Colors.white,
                                  //       shape: BoxShape.circle ,
                                  //     ),
                                  //     child: Icon(Icons.keyboard_arrow_down_rounded , color: darkBlue,size: 25,),
                                  //   ),
                                  //   children: [
                                  //     Container(
                                  //       color:Colors.white,
                                  //       child:ListView.builder(
                                  //           physics: NeverScrollableScrollPhysics(),
                                  //           itemCount: cakeArticles.length,
                                  //           shrinkWrap: true,
                                  //           itemBuilder: (context, index) {
                                  //             return RadioListTile(
                                  //                 activeColor: Colors.green,
                                  //                 title: Text(
                                  //                   "${cakeArticles[index]}",
                                  //                   style: TextStyle(
                                  //                       fontFamily: "Poppins", color: darkBlue
                                  //                   ),
                                  //                 ),
                                  //                 value: index,
                                  //                 groupValue: artGrpValue,
                                  //                 onChanged: (int? value) {
                                  //                   print(value);
                                  //                   setState(() {
                                  //                     artGrpValue = value!;
                                  //                     fixedCakeArticle = cakeArticles[index];
                                  //                   });
                                  //                 });
                                  //           }),
                                  //     ),
                                  //   ],
                                  // ),
                                ]
                            )
                        ),

                        //Weight...
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text("Weight",
                            style: TextStyle(color: Color(0xffaeaeae),fontSize: 14,fontFamily: "Poppins",),
                          ),
                        ),

                        weight.isNotEmpty?
                        Container(
                            height: MediaQuery.of(context).size.height * 0.046,
                            width: MediaQuery.of(context).size.width,
                            margin: EdgeInsets.symmetric(horizontal: 5),
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
                                        isFixedWeight = index;
                                        fixedWeight = changeKilo(weight[index]);
                                        weightCtrl.text = changeKilo(weight[index]);
                                      });
                                    },
                                    child:Container(
                                      width: 70,
                                      alignment: Alignment.center,
                                      margin: EdgeInsets.all(3),
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(
                                            color: Colors.grey[400]!,
                                            width: 1,
                                          ),
                                          color: isFixedWeight==index
                                              ? Colors.pink
                                              : Colors.white
                                      ),
                                      child:
                                      Text(
                                        '${weight[index]}',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontFamily: "Poppins",
                                            color: isFixedWeight==index?Colors.white:darkBlue
                                        ),
                                      ),
                                    ),
                                  );
                                })):Center(
                            child:Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text("No Data Found"),
                            )
                        ),

                        SizedBox(height:7),

                        Padding(
                          padding: const EdgeInsets.only(left :15.0 , top:15),
                          child: Text(
                            'Enter Weight',
                            style: TextStyle(
                                fontFamily: poppins, color: Color(0xffaeaeae)),
                          ),
                        ),

                        SizedBox(height:5),
                        Container(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(width: 15,),
                              Icon(Icons.scale_outlined,color: lightPink,),
                              Expanded(
                                child: Container(
                                  margin: EdgeInsets.symmetric(horizontal: 10),
                                  child: TextField(
                                    keyboardType: TextInputType.number,
                                    controller: weightCtrl,
                                    inputFormatters: <TextInputFormatter>[
                                      FilteringTextInputFormatter.allow(new RegExp('[0-9.]')),
                                      // FilteringTextInputFormatter.allow(RegExp(r'^(\d+)?\.?\d{0,2}')), 
                                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')),
                                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*'))!,
                                    ],
                                    style:TextStyle(fontFamily: 'Poppins' ,
                                        fontSize: 13
                                    ),
                                    onChanged: (String text){
                                      setState((){
                                        if (weightCtrl.text.isNotEmpty) {
                                          fixedWeight = weightCtrl.text+"kg";
                                          if(weight.indexWhere((element) => element==fixedWeight)!=-1){
                                            isFixedWeight = weight.indexWhere((element) => element==fixedWeight);
                                          }else{
                                            isFixedWeight = -1;
                                          }
                                          print("weight is $fixedWeight");
                                        } else {
                                          isFixedWeight = 0;
                                          fixedWeight = weight[0].toString();
                                        }
                                      });

                                    },
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.all(0.0),
                                      border:InputBorder.none,
                                      isDense: true,
                                      hintText: 'Type here..',
                                      hintStyle: TextStyle(fontFamily: 'Poppins' ,
                                          fontSize: 13
                                      ),
                                      // border: InputBorder.none
                                    ),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                child: Container(
                                    padding:EdgeInsets.all(4),
                                    margin:EdgeInsets.only(right:10),
                                    decoration: BoxDecoration(
                                        color:Colors.grey[300]!,
                                        borderRadius:BorderRadius.circular(5)
                                    ),
                                    child:PopupMenuButton(
                                        child: Row(
                                          children: [
                                            Text('$selectedDropWeight' , style:TextStyle(
                                                color:darkBlue , fontFamily:'Poppins'
                                            )),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Icon(Icons.keyboard_arrow_down,
                                                color: darkBlue)
                                          ],
                                        ),
                                        itemBuilder: (context)=>[
                                          PopupMenuItem(
                                              onTap:(){
                                                setState((){
                                                  selectedDropWeight = "Kg";
                                                });
                                              },
                                              child:Text('Kilo Gram')
                                          ),
                                        ]
                                    )
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

                        double.parse(fixedWeight.toLowerCase().replaceAll("kg", ""))>=2.0?
                        Padding(
                          padding: const EdgeInsets.only(left :15.0 , top:15),
                          child: Text(
                            'Select Tier',
                            style: TextStyle(
                                fontFamily: poppins, color: Color(0xffaeaeae)),
                          ),
                        ):Container(),
                        
                        //Tier cake
                        double.parse(fixedWeight.toLowerCase().replaceAll("kg", ""))>=2.0?
                        Container(
                          width: double.infinity,
                          margin: EdgeInsets.only(left:15 ,right:15 ),
                          child: DropdownButton(
                              value:'$tier',
                              hint:Text("Select Tier"),
                              items: <DropdownMenuItem<String>>[
                                DropdownMenuItem(
                                  child: Text("No Tier"),
                                  value: "No Tier",
                                ),
                                DropdownMenuItem(
                                    child: Text("2tier"),
                                    value: "2tier",
                                ),
                                DropdownMenuItem(
                                  child: Text("3tier"),
                                  value: "3tier",
                                ),
                                DropdownMenuItem(
                                  child: Text("4tier"),
                                  value: "4tier",
                                ),
                              ],
                              onChanged: (item){
                                print(item);
                                setState((){
                                  tier = item.toString();
                                });
                              },
                              isExpanded: true,
                          ),
                        ):Container(),

                        //theme....
                        double.parse(fixedWeight.toLowerCase().replaceAll("kg", ""))>=2.0?
                        Container(
                           child: Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children :[
                               Padding(
                                 padding: const EdgeInsets.only(left :15.0 , top:10),
                                 child: Text(
                                   'Themes',
                                   style: TextStyle(
                                       fontFamily: poppins, color: Color(0xffaeaeae)),
                                 ),
                               ),
                               Padding(
                                 padding: const EdgeInsets.only(
                                   left: 10 , right: 10,top:8
                                 ),
                                 child:Row(
                                   crossAxisAlignment:CrossAxisAlignment.center,
                                   children: [
                                     SizedBox(width: 8,),
                                     Icon(Icons.cake_outlined,color: lightPink),
                                     Expanded(
                                       child: Container(
                                         margin: EdgeInsets.symmetric(horizontal: 10),
                                         child: TextField(
                                           style:TextStyle(fontFamily: 'Poppins' ,
                                               fontSize: 13
                                           ),
                                           controller:themeCtrl,
                                           decoration: InputDecoration(
                                             hintText: 'Type theme name here..',
                                             contentPadding: EdgeInsets.all(0.0),
                                             isDense: true,
                                             border:InputBorder.none,
                                             hintStyle: TextStyle(fontFamily: 'Poppins' ,
                                                 fontSize: 13
                                             ),
                                             // border: InputBorder.none
                                           ),
                                         ),
                                       ),
                                     )
                                   ],
                                 ),
                               )
                             ]
                           ),  
                        ):Container(),

                        Container(
                          //margin
                            margin: EdgeInsets.all(10),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(' Message on the cake',
                                  style: TextStyle(color: Color(0xffaeaeae),fontSize: 14,fontFamily: "Poppins",),
                                ),
                                SizedBox(height:5),
                                Container(
                                  child: Column(
                                    children: [
                                      Row(
                                        crossAxisAlignment:CrossAxisAlignment.center,
                                        children: [
                                          SizedBox(width: 8,),
                                          Icon(Icons.message_outlined,color: lightPink,),
                                          Expanded(
                                            child: Container(
                                              margin: EdgeInsets.symmetric(horizontal: 10),
                                              child: TextField(
                                                style:TextStyle(fontFamily: 'Poppins' ,
                                                    fontSize: 13
                                                ),
                                                controller:msgCtrl,
                                                decoration: InputDecoration(
                                                  hintText: 'Type here..',
                                                  contentPadding: EdgeInsets.all(0.0),
                                                  isDense: true,
                                                  border:InputBorder.none,
                                                  hintStyle: TextStyle(fontFamily: 'Poppins' ,
                                                      fontSize: 13
                                                  ),
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
                                //     style: TextStyle(color: darkBlue,fontSize: 14,fontFamily: "Poppins"),
                                //   ),
                                // ),
                                //
                                // Container(
                                //     child:ListView.builder(
                                //       shrinkWrap : true,
                                //       physics : NeverScrollableScrollPhysics(),
                                //       itemCount:articals.length < 5?articals.length:5,
                                //       itemBuilder: (context , index){
                                //         return InkWell(
                                //           onTap:(){
                                //             setState(() {
                                //               if(articals[index].toString().contains('Others')){
                                //
                                //                 if(articGroupVal==index){
                                //                   articGroupVal = -1;
                                //                   addOtherArticle = false;
                                //                 }else{
                                //                   addOtherArticle = true;
                                //                   articGroupVal = index;
                                //                 }
                                //
                                //               }else{
                                //                 if(articGroupVal==index){
                                //                   fixedCakeArticle = 'None';
                                //                   articGroupVal = -1;
                                //                   addOtherArticle = false;
                                //                 }else{
                                //                   articGroupVal = index;
                                //                   fixedCakeArticle = articals[index].toString();
                                //                   addOtherArticle = false;
                                //                 }
                                //               }
                                //
                                //             });
                                //           },
                                //           child: Container(
                                //             padding: EdgeInsets.all(5),
                                //             child: Row(
                                //                 children:[
                                //                   articGroupVal!=index?
                                //                   Icon(Icons.radio_button_unchecked_rounded, color:Colors.black):
                                //                   Icon(Icons.check_circle_rounded, color:Colors.green),
                                //                   SizedBox(width:5),
                                //                   Expanded(
                                //                     child:Text.rich(
                                //                         TextSpan(
                                //                             text: "",
                                //                             children: <InlineSpan>[
                                //                               TextSpan(
                                //                                 text:"${articals[index]} ",
                                //                                 style: TextStyle(
                                //                                     fontFamily: poppins, color:Colors.black54 , fontSize: 13
                                //                                 ),),
                                //                             ]
                                //                         )
                                //                     ),
                                //                   ),
                                //                 ]
                                //             ),
                                //           ),
                                //         );
                                //       },
                                //     )
                                // ),

                                AnimatedSwitcher(
                                    switchInCurve: Curves.ease,
                                    switchOutCurve: Curves.ease,
                                    duration: Duration(seconds: 1),
                                    child: addOtherArticle?
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(' Add Your Article On Cake',
                                          style: TextStyle(color: Color(0xffaeaeae),fontSize: 14,fontFamily: "Poppins",),
                                        ),
                                        SizedBox(height:5),
                                        Container(
                                          child: Column(
                                            children: [
                                              Row(
                                                crossAxisAlignment:CrossAxisAlignment.center,
                                                children: [
                                                  SizedBox(width: 8,),
                                                  Icon(Icons.add_box,color: lightPink,),
                                                  Expanded(
                                                    child: Container(
                                                      margin: EdgeInsets.symmetric(horizontal: 10),
                                                      child: TextField(
                                                        controller: addArticleCtrl,
                                                        style:TextStyle(fontFamily: 'Poppins' ,
                                                            fontSize: 13
                                                        ),
                                                        onChanged: (String text){
                                                          setState((){
                                                            articGroupVal = -1;
                                                            fixedCakeArticle=text;
                                                          });
                                                        },
                                                        onSubmitted: (String text){
                                                          if(text.isNotEmpty){
                                                            sendOtherToApi("Article", text);
                                                          }
                                                        },
                                                        decoration: InputDecoration(
                                                          hintText: 'Type here..',
                                                          contentPadding: EdgeInsets.all(0.0),
                                                          isDense: true,
                                                          hintStyle: TextStyle(fontFamily: 'Poppins' ,
                                                              fontSize: 13
                                                          ),
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
                                      ],
                                    ):
                                    Container()
                                ),

                                Padding(
                                  padding: const EdgeInsets.only(top:10),
                                  child: Text(' Special request to bakers',
                                    style: TextStyle(color: Color(0xffaeaeae),fontSize: 14,fontFamily: "Poppins"),
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.all(10),
                                  child: TextField(
                                    controller: specialReqCtrl,
                                    style:TextStyle(fontFamily: 'Poppins' ,
                                        fontSize: 13
                                    ),
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor:Colors.grey[200],
                                      hintText: 'Type here..',
                                      hintStyle: TextStyle(fontFamily: 'Poppins' ,
                                          fontSize: 13
                                      ),
                                      border: OutlineInputBorder(
                                          borderSide: BorderSide.none,
                                          borderRadius: BorderRadius.circular(8)
                                      ),
                                    ),
                                    maxLines: 8,
                                    minLines: 5,
                                  ),
                                ),
                                Container(
                                    margin: EdgeInsets.symmetric(horizontal: 8),
                                    child: Divider(
                                      color: Colors.pink[100],
                                    )),
                                Padding(
                                  padding: EdgeInsets.only(top: 10),
                                  child: Text(
                                    'Delivery Information',
                                    style: TextStyle(
                                      fontFamily: poppins, color: Color(0xffaeaeae) , fontSize: 14 ,
                                    ),
                                  ),
                                ),
                                Container(
                                    child:ListView.builder(
                                      shrinkWrap : true,
                                      physics : NeverScrollableScrollPhysics(),
                                      itemCount:picOrDeliver.length,
                                      itemBuilder: (context , index){
                                        return InkWell(
                                          onTap:(){
                                            setState(() {
                                              if(index==0){
                                                tooFar = false;
                                                deliverAddressIndex = 1;
                                              }
                                              FocusScope.of(context).unfocus();
                                              picOrDel = index;
                                              fixedDelliverMethod = picOrDeliver[index];
                                            });
                                          },
                                          child: Container(
                                            padding: EdgeInsets.only(left:10 , top:7),
                                            child: Row(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children:[
                                                  picOrDel!=index?
                                                  Icon(Icons.radio_button_unchecked_rounded, color:Colors.black):
                                                  Icon(Icons.check_circle_rounded, color:Color(0xff058d05),),
                                                  SizedBox(width:6),
                                                  Text('${picOrDeliver[index]}',style: TextStyle(
                                                      fontFamily: poppins, color:Colors.grey, fontSize: 14
                                                  ),),
                                                ]
                                            ),
                                          ),
                                        );
                                      },
                                    )
                                ),
                              ],
                            )),

                        //Delivery Details
                        Container(
                          margin:EdgeInsets.only(left:10 , right: 10 , bottom:5),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(top: 10 , bottom:5),
                                child: Text(
                                  'Delivery Details',
                                  style: TextStyle(
                                    fontFamily: poppins, color: Color(0xffaeaeae) , fontSize: 14,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap : () async {
                                  FocusScope.of(context).unfocus();
                                  DateTime? SelDate = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime(
                                        DateTime.now().year,
                                        DateTime.now().month,
                                        DateTime.now().day+1,
                                      ),
                                      lastDate: DateTime(2100),
                                      firstDate: DateTime(
                                        DateTime.now().year,
                                        DateTime.now().month,
                                        DateTime.now().day+1,
                                      ),
                                      helpText: "Select Deliver Date"
                                  );

                                  setState(() {
                                    fixedDate = simplyFormat(
                                        time: SelDate, dateOnly: true);
                                  });

                                  // print(SelDate.toString());
                                  // print(DateTime.now().subtract(Duration(days: 0)));
                                },
                                child: Container(
                                    margin:EdgeInsets.all(5),
                                    padding:EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                        color:Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                            color: Colors.grey[400]!,
                                            width:0.5
                                        )
                                    ),
                                    child:Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children:[
                                          Text(
                                            '$fixedDate',
                                            style: TextStyle(
                                                color: Color(0xffaeaeae),
                                                fontFamily: "Poppins",
                                                fontSize: 13),
                                          ),

                                          Icon(Icons.date_range_outlined,
                                              color: darkBlue)
                                        ]
                                    )
                                ),
                              ),
                              GestureDetector(
                                onTap :  () {
                                  FocusScope.of(context).unfocus();
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                              BorderRadius.circular(
                                                  10)),
                                          title: Text(
                                              "Select delivery session",
                                              style: TextStyle(
                                                color: lightPink,
                                                fontFamily: "Poppins",
                                                fontSize: 18,
                                              )),
                                          content: Container(
                                            height:250,
                                            child: Scrollbar(
                                              isAlwaysShown: true,
                                              child: SingleChildScrollView(
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    PopupMenuItem(
                                                        child: Text(
                                                          'Morning 8 AM - 9 AM', style: TextStyle(fontFamily: "Poppins"),),
                                                        onTap: () {
                                                          setState(() {
                                                            fixedSession =
                                                            'Morning 8 AM - 9 AM';
                                                          });
                                                        }),
                                                    PopupMenuItem(
                                                        child: Text(
                                                          'Morning 9 AM - 10 AM', style: TextStyle(fontFamily: "Poppins"),),
                                                        onTap: () {
                                                          setState(() {
                                                            fixedSession =
                                                            'Morning 9 AM - 10 AM';
                                                          });
                                                        }),
                                                    PopupMenuItem(
                                                        child: Text(
                                                          'Morning 10 AM - 11 AM', style: TextStyle(fontFamily: "Poppins"),),
                                                        onTap: () {
                                                          setState(() {
                                                            fixedSession =
                                                            'Morning 10 AM - 11 AM';
                                                          });
                                                        }),
                                                    PopupMenuItem(
                                                        child: Text(
                                                          'Morning 11 AM - 12 PM', style: TextStyle(fontFamily: "Poppins"),),
                                                        onTap: () {
                                                          setState(() {
                                                            fixedSession =
                                                            'Morning 11 PM - 12 PM';
                                                          });
                                                        }),
                                                    PopupMenuItem(
                                                        child: Text(
                                                          'Afternoon 12 PM - 1 PM', style: TextStyle(fontFamily: "Poppins"),),
                                                        onTap: () {
                                                          setState(() {
                                                            fixedSession =
                                                            'Afternoon 12 PM - 1 PM';
                                                          });
                                                        }),
                                                    PopupMenuItem(
                                                        child: Text(
                                                          'Afternoon 1 PM - 2 PM', style: TextStyle(fontFamily: "Poppins"),),
                                                        onTap: () {
                                                          setState(() {
                                                            fixedSession =
                                                            'Afternoon 1 PM - 9 PM';
                                                          });
                                                        }),
                                                    PopupMenuItem(
                                                        child: Text(
                                                          'Afternoon 2 PM - 3 PM', style: TextStyle(fontFamily: "Poppins"),),
                                                        onTap: () {
                                                          setState(() {
                                                            fixedSession =
                                                            'Afternoon 8 PM - 9 PM';
                                                          });
                                                        }),
                                                    PopupMenuItem(
                                                        child: Text(
                                                          'Afternoon 3 PM - 4 PM', style: TextStyle(fontFamily: "Poppins"),),
                                                        onTap: () {
                                                          setState(() {
                                                            fixedSession =
                                                            'Afternoon 3 PM - 4 PM';
                                                          });
                                                        }),
                                                    PopupMenuItem(
                                                        child: Text(
                                                          'Afternoon 4 PM - 5 PM', style: TextStyle(fontFamily: "Poppins"),),
                                                        onTap: () {
                                                          setState(() {
                                                            fixedSession =
                                                            'Afternoon 4 PM - 5 PM';
                                                          });
                                                        }),
                                                    PopupMenuItem(
                                                        child: Text(
                                                          'Evening 5 PM - 6 PM', style: TextStyle(fontFamily: "Poppins"),),
                                                        onTap: () {
                                                          setState(() {
                                                            fixedSession =
                                                            'Evening 5 PM - 6 PM';
                                                          });
                                                        }),
                                                    PopupMenuItem(
                                                        child: Text(
                                                          'Evening 6 PM - 7 PM', style: TextStyle(fontFamily: "Poppins"),),
                                                        onTap: () {
                                                          setState(() {
                                                            fixedSession =
                                                            'Evening 6 PM - 7 PM';
                                                          });
                                                        }),
                                                    PopupMenuItem(
                                                        child: Text(
                                                          'Evening 7 PM - 8 PM', style: TextStyle(fontFamily: "Poppins"),),
                                                        onTap: () {
                                                          setState(() {
                                                            fixedSession =
                                                            'Evening 7 PM - 8 PM';
                                                          });
                                                        }),
                                                    PopupMenuItem(
                                                        child: Text(
                                                          'Evening 8 PM - 9 PM', style: TextStyle(fontFamily: "Poppins"),),
                                                        onTap: () {
                                                          setState(() {
                                                            fixedSession =
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
                                    margin:EdgeInsets.all(5),
                                    padding:EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                        color:Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                            color: Colors.grey[400]!,
                                            width:0.5
                                        )
                                    ),
                                    child:Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children:[
                                          Text(
                                            '$fixedSession',
                                            style: TextStyle(
                                                color: Color(0xffaeaeae),
                                                fontFamily: "Poppins",
                                                fontSize: 13
                                            ),
                                          ),
                                          Icon(CupertinoIcons.clock,
                                              color: darkBlue)
                                        ]
                                    )
                                ),
                              ),
                            ],
                          ),
                        ),

                        fixedDelliverMethod.toLowerCase()=="delivery"?
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 10.0),
                              child: Text(' Address',
                                style: TextStyle(color: Color(0xffaeaeae),fontSize: 14,fontFamily: "Poppins"),
                              ),
                            ),
                            Column(
                              children:deliveryAddress.map((e){
                                return ListTile(
                                  onTap: () async{
                                    // setState(() {
                                    //   deliveryAddress = e.trim();
                                    //   deliverAddressIndex = deliverAddress.indexWhere((element) => element==e);
                                    // });
                                    print("Vendor address...${vendorAddress.trim()}");
                                    showAlertDialog();
                                    try {
                                      List<Location> locat =
                                      await locationFromAddress(e.toString().trim());
                                      List<Location> venLocation = await locationFromAddress(userCurLocation.trim());
                                      print(locat);
                                      setState(() {
                                        deliverAddress = e.trim();
                                        userLatitude =
                                            locat[0].latitude.toString();
                                        userLongtitude =
                                            locat[0].longitude.toString();
                                        deliverAddressIndex =
                                            deliveryAddress.indexWhere(
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
                                  },
                                  title: Text(
                                    '${e.trim()}',
                                    style: TextStyle(
                                        fontFamily: poppins,
                                        color: Colors.grey,
                                        fontSize: 13),
                                  ),
                                  trailing:
                                  deliverAddressIndex==deliveryAddress.indexWhere((element) => element==e)?
                                  Icon(Icons.check_circle, color: Colors.green ,size: 25,):
                                  Container(height:0,width:0),
                                );
                              }).toList(),
                            ),
                            Container(
                              margin: EdgeInsets.only(left: 12 , top:10 , bottom:10),
                              alignment: Alignment.centerLeft,
                              child: InkWell(
                                onTap:()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>AddressScreen())),
                                child: Text('add new address',style: const TextStyle(
                                    color:Color(0xffff5c01),fontFamily: "Poppins",decoration: TextDecoration.underline
                                ),
                                ),
                              ),
                            ),
                          ],
                        ):Container(),

                        //Image Upload
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Text(' Upload Image',
                            style: TextStyle(color: darkBlue,fontSize: 14,fontFamily: "Poppins"),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: DottedBorder(
                            radius: Radius.circular(20),
                            color: Colors.grey,//color of dotted/dash line
                            strokeWidth: 1, //thickness of dash/dots
                            dashPattern: [3,2],
                            child: InkWell(
                              splashColor: Colors.red[100],
                              onTap:()=>filePicker(),
                              child: file.path.isEmpty?Container(
                                width: MediaQuery.of(context).size.width,
                                height: 160,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.image_rounded , color: Color(0xff3797d3),size: 55,),
                                    Text('Select Files Here',
                                        style: TextStyle(color: darkBlue,fontSize: 13.5,fontFamily: "Poppins",fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                   //  setState(() {
                                  //   file = new fil.File('');
                                  //   });

                              ):Container(
                                alignment: Alignment.center,
                                padding: EdgeInsets.all(5),
                                width: MediaQuery.of(context).size.width,
                                height: 160,
                                child:Container(
                                  color: Colors.red[100],
                                  child:Row(
                                      children: [
                                        Container(
                                          margin:EdgeInsets.all(5),
                                          width:145,
                                          decoration: BoxDecoration(
                                            color:lightGrey,
                                            borderRadius: BorderRadius.circular(10),
                                            image:DecorationImage(
                                                image:FileImage(file),
                                              fit: BoxFit.cover
                                            )
                                          ),
                                        ),
                                        Expanded(
                                          child:Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(file.path.split("/").last,maxLines: 3,style: TextStyle(
                                                fontFamily: "Poppins"
                                              ),),
                                              SizedBox(height:5),
                                              TextButton(
                                                onPressed:(){
                                                  setState(() {
                                                    file = new fil.File('');
                                                  });
                                                },
                                                child:Text('Remove',style: TextStyle(
                                                    fontFamily: "Poppins",color:lightPink
                                                ),),
                                              )
                                            ],
                                          )
                                        ),
                                      ],
                                  )
                                ),
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 15,),

                        Container(
                          padding: EdgeInsets.only(left:10.0 , right:10.0 , top:15, bottom:15),
                          color: Colors.black12,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              nearestVendors.isNotEmpty?
                              Column(
                                children: [
                                  changeWeight(fixedWeight)<=5.0?
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      selFromVenList?
                                      Text('Selected Vendor',style: TextStyle(fontSize:15,
                                          color: darkBlue,fontWeight: FontWeight.bold,fontFamily: poppins),):
                                      Container(),
                                      //mySelectdVendors
                                      selFromVenList?
                                      InkWell(
                                        onTap:() async{

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
                                          // pref.setString('singleVendorID', mySelectdVendors[0]['_id']??'null');
                                          // pref.setBool('singleVendorFromCd', true);
                                          // pref.setString('singleVendorRate', mySelectdVendors[0]['Ratings'].toString()??'0.0');
                                          // pref.setString('singleVendorName', mySelectdVendors[0]['VendorName']??'null');
                                          // pref.setString('singleVendorDesc', mySelectdVendors[0]['Description']??'null');
                                          // pref.setString('singleVendorPhone1', mySelectdVendors[0]['PhoneNumber1']??'null');
                                          // pref.setString('singleVendorPhone2', mySelectdVendors[0]['PhoneNumber2']??'null');
                                          // pref.setString('singleVendorDpImage', mySelectdVendors[0]['ProfileImage']??'null');
                                          // pref.setString('singleVendorAddress', mySelectdVendors[0]['Address']??'null');
                                          // pref.setString('singleVendorSpecial', mySelectdVendors[0]['YourSpecialityCakes'].toString()??'null');
                                          //
                                          //
                                          // Navigator.push(context,
                                          //     MaterialPageRoute(
                                          //         builder: (context)=>SingleVendor()
                                          //     )
                                          // );
                                        },
                                        child: Container(
                                          width: MediaQuery.of(context).size.width,
                                          padding: EdgeInsets.all(5),
                                          margin: EdgeInsets.all(5),
                                          decoration: BoxDecoration(
                                              color:Colors.white ,
                                              borderRadius:BorderRadius.circular(10)
                                          ),
                                          child: Row(
                                            children: [
                                              mySelectdVendors[0]['ProfileImage']!=null?
                                              Container(
                                                width:90,
                                                height:100,
                                                decoration: BoxDecoration(
                                                    color:Colors.red ,
                                                    borderRadius:BorderRadius.circular(10) ,
                                                    image:DecorationImage(
                                                        image:NetworkImage(mySelectdVendors[0]['ProfileImage'].toString()),
                                                        fit: BoxFit.cover
                                                    )
                                                ),
                                              ):
                                              Container(
                                                width:90,
                                                height:105,
                                                decoration: BoxDecoration(
                                                    color:Colors.red ,
                                                    borderRadius:BorderRadius.circular(10) ,
                                                    image:DecorationImage(
                                                        image:Svg("assets/images/pictwo.svg"),
                                                        fit: BoxFit.cover
                                                    )
                                                ),
                                              ),
                                              SizedBox(width: 8,),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Container(
                                                          width:155,
                                                          child: Column(
                                                            mainAxisSize: MainAxisSize.min,
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Container(
                                                                child: Text('${mySelectdVendors[0]['VendorName']}' , style: TextStyle(
                                                                  color: Colors.black,
                                                                  fontWeight: FontWeight.bold,
                                                                  fontFamily: "Poppins",
                                                                ),overflow: TextOverflow.ellipsis,),
                                                              ),
                                                              SizedBox(height: 6,) ,
                                                              Row(
                                                                children: [
                                                                  RatingBar.builder(
                                                                    initialRating: double.parse(mySelectdVendors[0]['Ratings'].toString()),
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
                                                                  Text(' ${mySelectdVendors[0]['Ratings'].toString().
                                                                  characters.take(3)}',
                                                                    style: TextStyle(
                                                                      color: Colors.black54,fontWeight: FontWeight.bold,fontSize: 13,fontFamily: poppins
                                                                  ),)
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        // selVendorIndex==-1?
                                                        Icon(Icons.check_circle,color:Colors.green)
                                                        // :Container(),
                                                      ],
                                                    ),

                                                    Text(mySelectdVendors[0]['Description']!=null||
                                                        mySelectdVendors[0]['Description']!='null'?
                                                    "${mySelectdVendors[0]['Description']}":"No Description",
                                                      style:TextStyle(
                                                        fontSize:12,
                                                        fontFamily: "Poppins" ,
                                                        color:Colors.grey,
                                                        fontWeight: FontWeight.bold,
                                                      ),maxLines: 1,),
                                                    SizedBox(height: 6,) ,
                                                    Container(
                                                      height:1,
                                                      color:Colors.grey,
                                                      // margin: EdgeInsets.only(left:6,right:6),
                                                    ),
                                                    SizedBox(height: 6,) ,
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text(mySelectdVendors[0]['EggOrEggless']=='Both'?
                                                            'Includes eggless':'${mySelectdVendors[0]['EggOrEggless']}',
                                                              style:TextStyle(
                                                                fontSize:11,
                                                                fontFamily: "Poppins" ,
                                                                color:darkBlue,
                                                              ),maxLines: 1,),
                                                            SizedBox(height:3),
                                                            (adminDeliveryCharge/adminDeliveryChargeKm)*
                                                                (calculateDistance(double.parse(userLatitude),
                                                                    double.parse(userLongtitude),
                                                                    mySelectdVendors[0]['GoogleLocation']['Latitude'],
                                                                    mySelectdVendors[0]['GoogleLocation']['Longitude'])).toInt()!=0?
                                                            Text(
                                                                 "${
                                                                     (calculateDistance(double.parse(userLatitude),
                                                                         double.parse(userLongtitude),
                                                                         mySelectdVendors[0]['GoogleLocation']['Latitude'],
                                                                         mySelectdVendors[0]['GoogleLocation']['Longitude'])).toInt()
                                                                 } KM Charge Rs.${
                                                                     (adminDeliveryCharge/adminDeliveryChargeKm)*
                                                                         (calculateDistance(double.parse(userLatitude),
                                                                             double.parse(userLongtitude),
                                                                             mySelectdVendors[0]['GoogleLocation']['Latitude'],
                                                                             mySelectdVendors[0]['GoogleLocation']['Longitude'])).toInt()
                                                                 }",
                                                              style:TextStyle(
                                                                fontSize:10,
                                                                fontFamily: "Poppins" ,
                                                                color:Colors.orange,
                                                              ),maxLines: 1,):
                                                            Text("Free Delivery",
                                                                style:TextStyle(
                                                                  fontSize:10,
                                                                  fontFamily: "Poppins" ,
                                                                  color:Colors.orange,
                                                                )),
                                                          ],
                                                        ),
                                                        Container(
                                                          width: 100,
                                                          child: Row(
                                                            mainAxisAlignment: MainAxisAlignment.end,
                                                            children: [
                                                              InkWell(
                                                                onTap: (){
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
                                                                  child:const Icon(Icons.phone,color: Colors.blueAccent,),
                                                                ),
                                                              ),
                                                              const SizedBox(width: 10,),
                                                              InkWell(
                                                                onTap: (){
                                                                  Functions().handleChatWithVendors(context, mySelectdVendors[0]['Email'], mySelectdVendors[0]['VendorName']);
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
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ):
                                      Container(),
                                      SizedBox(height:10),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Text('Select Vendors',style: TextStyle(fontSize:15,
                                                  color: darkBlue,fontWeight: FontWeight.bold,fontFamily: poppins),),
                                              Text('  (10km radius)',style: TextStyle(color: Colors.black45,fontFamily: poppins),),
                                            ],
                                          ),
                                          InkWell(
                                            onTap: () async{
                                              print('see more..');
                                              var pref = await SharedPreferences.getInstance();
                                              pref.setBool('iamFromCustomise', true);
                                              setState(() {
                                                // context.read<ContextData>().setCurrentIndex(3);
                                                Navigator.push(context, MaterialPageRoute(
                                                    builder: (context)=>VendorsList()
                                                ));
                                              });
                                            },
                                            child: Row(
                                              children: [
                                                Text('See All',style: TextStyle(color: lightPink,fontWeight: FontWeight.bold,fontFamily: poppins),),
                                                Icon(Icons.keyboard_arrow_right,color: lightPink,)
                                              ],
                                            ),
                                          )
                                        ],
                                      ),

                                      SizedBox(height: 15,),

                                      Container(
                                          height: 190,
                                          child:
                                          ListView.builder(
                                              scrollDirection: Axis.horizontal,
                                              shrinkWrap: true,
                                              itemCount: nearestVendors.length,
                                              itemBuilder: (context , index){
                                                return Card(
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(10)
                                                  ),
                                                  child: InkWell(
                                                    splashColor:Colors.red[200] ,
                                                    onTap: (){
                                                      print(index);

                                                      String adrss = '1/4 vellandipalayam , Avinashi';

                                                      setState((){

                                                        nearVendorClicked = true;
                                                        vendorListClicked = true;

                                                        selVendorIndex = index;

                                                        vendorID = nearestVendors[index]['_id'];
                                                        vendorModId = nearestVendors[index]['Id'];
                                                        vendorName = nearestVendors[index]['VendorName'];
                                                        vendorPhone1 = nearestVendors[index]['PhoneNumber1'];
                                                        vendorPhone2 = nearestVendors[index]['PhoneNumber2'];
                                                        vendorAddress = nearestVendors[index]['Address'];
                                                        venLat = nearestVendors[index]['GoogleLocation']['Latitude'].toString();
                                                        venLong = nearestVendors[index]['GoogleLocation']['Longitude'].toString();
                                                        notificationId = nearestVendors[index]['Notification_Id'].toString();

                                                        context.read<ContextData>().addMyVendor(true);
                                                        context.read<ContextData>().setMyVendors([nearestVendors[index]]);
                                                      });

                                                    },
                                                    child: Container(
                                                      padding: EdgeInsets.all(10),
                                                      width: 260,
                                                      child: Column(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          Row(
                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                            children: [
                                                              nearestVendors[index]['ProfileImage']!=null?
                                                              CircleAvatar(
                                                                radius:32,
                                                                backgroundColor: Colors.white,
                                                                child: CircleAvatar(
                                                                  radius:30,
                                                                  backgroundImage: NetworkImage('${nearestVendors[index]['ProfileImage']}'),
                                                                ),
                                                              ):
                                                              CircleAvatar(
                                                                radius:32,
                                                                backgroundColor: Colors.white,
                                                                child: CircleAvatar(
                                                                  radius:30,
                                                                  backgroundImage:Svg('assets/images/pictwo.svg'),
                                                                ),
                                                              ),
                                                              SizedBox(width: 6,),
                                                              Container(
                                                                width:170,
                                                                child: Row(
                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                  children: [
                                                                    Column(
                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                      children: [
                                                                        Container(
                                                                          width:120,
                                                                          child: Text(nearestVendors[index]['VendorName'].toString().isEmpty?
                                                                          'Un name':'${nearestVendors[index]['VendorName'][0].toString().toUpperCase()+
                                                                              nearestVendors[index]['VendorName'].toString().substring(1).toLowerCase()
                                                                          }',style: TextStyle(
                                                                              color: darkBlue,fontWeight: FontWeight.bold,
                                                                              fontFamily: "Poppins"
                                                                          ),overflow: TextOverflow.ellipsis,),
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
                                                                            Text(' ${nearestVendors[index]['Ratings'].toString().
                                                                            characters.take(3)}',style: TextStyle(
                                                                                color: Colors.black54,fontWeight: FontWeight.bold,fontSize: 13,fontFamily: poppins
                                                                            ),)
                                                                          ],
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(height: 10,),
                                                          Container(
                                                            alignment: Alignment.centerLeft,
                                                            child: Text(nearestVendors[index]['Description']!=null?
                                                            " "+nearestVendors[index]['Description']:'',
                                                              style: TextStyle(color: Colors.black54,fontFamily: "Poppins" , fontSize: 13),
                                                              overflow: TextOverflow.ellipsis,
                                                              maxLines: 1,
                                                              textAlign: TextAlign.start,
                                                            ),
                                                          ),
                                                          Container(
                                                            margin:EdgeInsets.only(top: 10),
                                                            height: 1,
                                                            color: Color(0xffeeeeee),
                                                          ),
                                                          SizedBox(height: 15,),
                                                          Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              Column(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  nearestVendors[index]['EggOrEggless'].toString()=='Both'?
                                                                  Text('Egg and Eggless',style: TextStyle(
                                                                      color: darkBlue,
                                                                      fontSize: 10,
                                                                      fontFamily: "Poppins"
                                                                  ),):
                                                                  Text('${nearestVendors[index]['EggOrEggless'].toString()}',style: TextStyle(
                                                                      color: darkBlue,
                                                                      fontSize: 10,
                                                                      fontFamily: "Poppins"
                                                                  ),),
                                                                  SizedBox(height: 8,),
                                                                  ((adminDeliveryCharge/adminDeliveryChargeKm)*
                                                                      (calculateDistance(double.parse(userLatitude),
                                                                          double.parse(userLongtitude),
                                                                          nearestVendors[index]['GoogleLocation']['Latitude'],
                                                                          nearestVendors[index]['GoogleLocation']['Longitude']))).toStringAsFixed(1)!="0.0"?
                                                                  Text('${
                                                                      (calculateDistance(double.parse(userLatitude),
                                                                          double.parse(userLongtitude),
                                                                          nearestVendors[index]['GoogleLocation']['Latitude'],
                                                                          nearestVendors[index]['GoogleLocation']['Longitude'])).toStringAsFixed(1)
                                                                  } KM Delivery Fee Rs.${
                                                                      ((adminDeliveryCharge/adminDeliveryChargeKm)*
                                                                          (calculateDistance(double.parse(userLatitude),
                                                                              double.parse(userLongtitude),
                                                                              nearestVendors[index]['GoogleLocation']['Latitude'],
                                                                              nearestVendors[index]['GoogleLocation']['Longitude']))).toStringAsFixed(1)
                                                                  }',style: TextStyle(
                                                                      color: Colors.orange,
                                                                      fontSize: 10 ,
                                                                      fontFamily: "Poppins"
                                                                  ),
                                                                  ):Text("Free Delivery",style: TextStyle(
                                                                      color: Colors.orange,
                                                                      fontSize: 10,
                                                                      fontFamily: "Poppins"
                                                                  )),
                                                                ],
                                                              ),
                                                              selVendorIndex==index?
                                                              Icon(Icons.check_circle,color: Colors.green,):
                                                              Container(),
                                                            ],
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }
                                          )
                                      ),
                                      SizedBox(height: 15,),
                                    ],
                                  ):
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Selected Vendor',style: TextStyle(fontSize:15,
                                          color: darkBlue,fontWeight: FontWeight.bold,fontFamily: poppins),),
                                      SizedBox(height:10),
                                      Container(
                                          padding:EdgeInsets.all(7),
                                          height:85,
                                          decoration: BoxDecoration(
                                              color:Colors.white,
                                              borderRadius:BorderRadius.circular(10),
                                              border:Border.all(
                                                color: Colors.grey,
                                                width:1,
                                              )
                                          ),
                                          child:Row(
                                              mainAxisAlignment:MainAxisAlignment.spaceBetween,
                                              children:[
                                                Container(
                                                  width:75,
                                                  decoration: BoxDecoration(
                                                      color:Colors.red,
                                                      borderRadius:BorderRadius.circular(10),
                                                      image:DecorationImage(
                                                          image:AssetImage('assets/images/customcake.png'),
                                                          fit:BoxFit.cover
                                                      )
                                                  ),
                                                ),
                                                Container(
                                                    width:80,
                                                    child:Image(
                                                        image:Svg('assets/images/cakeylogo.svg')
                                                    )
                                                ),
                                                Text('PREMIUM\nVENDOR',style:TextStyle(
                                                    color:Color(0xffff5c01),fontFamily: "Poppins",fontSize:18
                                                ))
                                              ]
                                          )
                                      ),
                                    ],
                                  ),
                                ],
                              ):
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Selected Vendor',style: TextStyle(fontSize:15,
                                      color: darkBlue,fontWeight: FontWeight.bold,fontFamily: poppins),),
                                  SizedBox(height:10),
                                  Container(
                                      padding:EdgeInsets.all(7),
                                      height:85,
                                      decoration: BoxDecoration(
                                          color:Colors.white,
                                          borderRadius:BorderRadius.circular(10),
                                          border:Border.all(
                                            color: Colors.grey,
                                            width:1,
                                          )
                                      ),
                                      child:Row(
                                          mainAxisAlignment:MainAxisAlignment.spaceBetween,
                                          children:[
                                            Container(
                                              width:75,
                                              decoration: BoxDecoration(
                                                  color:Colors.red,
                                                  borderRadius:BorderRadius.circular(10),
                                                  image:DecorationImage(
                                                      image:AssetImage('assets/images/customcake.png'),
                                                      fit:BoxFit.cover
                                                  )
                                              ),
                                            ),
                                            Container(
                                                width:80,
                                                child:Image(
                                                    image:Svg('assets/images/cakeylogo.svg')
                                                )
                                            ),
                                            Text('PREMIUM\nVENDOR',style:TextStyle(
                                                color:Color(0xffff5c01),fontFamily: "Poppins",fontSize:18
                                            ))
                                          ]
                                      )
                                  ),
                                ],
                              ),
                              SizedBox(height: 15,),

                              // vendorListClicked || double.parse(fixedWeight.toLowerCase().replaceAll("kg", ""))>=5.0?
                              tooFar?
                              Container():
                              Center(
                                child: GestureDetector(
                                  onTap:(){
                                    FocusScope.of(context).unfocus();
                                    setState((){

                                    });

                                    if(newRegUser==true){
                                      ProfileAlert().showProfileAlert(context);
                                    }
                                    else {
                                      if(weightCtrl.text=="0"||weightCtrl.text=="0.0"||
                                          weightCtrl.text.startsWith("0")&&
                                              weightCtrl.text.endsWith("0")){
                                        ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                                content: Text("Please enter correct weight or select weight!")
                                            )
                                        );
                                      } else if(double.parse(changeWeight(fixedWeight).toString()) <5.0 && nearestVendors.isNotEmpty && !vendorListClicked ) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                                content: Text("Please select vendor...")
                                            )
                                        );
                                      } else if(deliverAddressIndex==-1){
                                        ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                                content: Text("Please select delivery address!")
                                            )
                                        );
                                      } else if(fixedWeight=="0.0"){
                                        ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                                content: Text("Please select weight!")
                                            )
                                        );
                                      }else if(themeCtrl.text.isNotEmpty&&file.path.isEmpty){
                                        ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Please select a image file for theme...'))
                                        );
                                      }else if(fixedShape.isEmpty){
                                        ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Please select a shape'))
                                        );
                                      }else if(fixedFlavList.isEmpty){
                                        ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Please select some flavours'))
                                        );
                                      }
                                      else if(deliverAddress=="null"||deliverAddress.isEmpty){
                                        ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Invalid Address'))
                                        );
                                      }else if(fixedDelliverMethod.toLowerCase()=="not yet select"||
                                          fixedSession.toLowerCase()=="select delivery time"||
                                          fixedDate.toLowerCase()=="select delivery date"){
                                        ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Please Select Pickup/Deliver && Deliver Date/Deliver Session'))
                                        );
                                      }
                                      // else if( changeWeight(fixedWeight) != 5.0 && changeWeight(fixedWeight) <= 5.0
                                      //     && nearVendorClicked==false){
                                      //   ScaffoldMessenger.of(context).showSnackBar(
                                      //       SnackBar(content: Text('Please Select a vendor'))
                                      //   );
                                      // }
                                      else{
                                        setState((){
                                          if(double.parse(fixedWeight.toLowerCase().replaceAll("kg", ""))>5.0){
                                            vendorID = "";
                                          }
                                        });
                                        showCakeNameEdit();
                                      }
                                    }
                                  },
                                  child: Container(
                                    height: MediaQuery.of(context).size.height*0.067,
                                    width: MediaQuery.of(context).size.width-120,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(30),
                                        color:lightPink
                                    ),
                                    child: Text("ORDER NOW",style: TextStyle(
                                        color: Colors.white,fontWeight: FontWeight.bold
                                    ),),
                                  ),
                                ),
                              ),
                              //Container(),
                              SizedBox(height: 30,),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
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
