import 'dart:convert';
import 'dart:io' as fil;
import 'package:flutter/services.dart';
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
import '../ContextData.dart';
import 'package:path/path.dart' as Path;
import 'package:http_parser/http_parser.dart';

import '../screens/AddressScreen.dart';
import '../screens/Profile.dart';


class CustomiseCake extends StatefulWidget {
  const CustomiseCake({Key? key}) : super(key: key);

  @override
  State<CustomiseCake> createState() => _CustomiseCakeState();
}

class _CustomiseCakeState extends State<CustomiseCake> {

  //region Variables
  //Colors code
  Color lightGrey = Color(0xffF5F5F5);
  Color darkBlue = Color(0xffF213959);
  Color lightPink = Color(0xffFE8416D);

  //shapes
  var shapesList = [];
  // var shapesList = ["Round","Square","Heart","Any Shape" , "Others"];
  var shapeGrpValue = 0;

  //flavour
  // var flavourList = [
  //   "Vanilla",
  //   "Chocolate" ,
  //   "Strawberry",
  //   "Black Forest",
  //   "Red Velvet",
  //   "Others",
  // ];
  var flavourList = [];

  var flavGrpValue = 0;

  //cake articles
  var cakeArticles = ["Default" , 'Cake Article','Cake Article','Cake Art'];
  var artGrpValue = 0;
  String fixedCakeArticle = '';

  //Articles
  var articals = [
    // {"article":'Happy Birthday',"price":'100'},
    // {"article":'Butterflies',"price":'85'},
    // {"article":'Sweet Heart',"price":'150'},
    // {"article":'Welcome Home',"price":'70'},
    // {"article":'I Love You',"price":'70'},
    // {"article":'Others',"price":'70'},
  ];
  int articGroupVal = -1;

  int selVendorIndex = 0;

  //String family
  String poppins = "Poppins";
  String userMainLocation ="";
  String profileUrl = '';
  String btnMsg = 'ORDER NOW';


  //Fixed Strings and Lists
  String fixedCategory = 'Birthday';
  String fixedShape = 'Round';
  //flavours
  List fixedFlavList = [];
  List flavTempList = [];
  List<bool> fixedFlavChecks = [];

  String fixedFlavour = 'Vanilla';
  String fixedExtraArticle = '';
  String fixedCakeTower = '';

  //var weight
  int isFixedWeight = -1;
  String fixedWeight = '0.0';
  String fixedDate = 'Not Yet Select';
  String fixedSession = 'Not Yet Select';
  String deliverAddress = 'Washington , Vellaimaligai , USA ,007 ';
  String selectedDropWeight = "Kg";
  String fixedDelliverMethod = "";

  //cake text ctrls
  var msgCtrl = new TextEditingController();
  var specialReqCtrl = new TextEditingController();
  var addArticleCtrl = new TextEditingController();
  var weightCtrl = new TextEditingController();
  String cakeMessage = '';
  String cakeRequest = "";
  String authToken = "";

  //main variables
  bool egglesSwitch = true;
  bool addOtherArticle = false;
  String userCurLocation = 'Searching...';

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

  //vendors details
  String vendorID = '';
  String vendorName = '';
  String vendorAddress = '';
  String vendorPhone = '';
  String vendorModId = '';

  //Current user details
  String userID ='';
  String userModId = '';
  String userName ='';
  String userPhone ='';

  var cateListScrollCtrl = new ScrollController();

  bool newRegUser = false;

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

  //Add new Address Alert...
  void showAddAddressAlert(){

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
        builder: (context){
          return StatefulBuilder(
              builder:(BuildContext context , void Function(void Function()) setState){
                return AlertDialog(
                  scrollable: true,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)
                  ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Add New Address' , style: TextStyle(
                          color: lightPink , fontFamily: "Poppins" , fontSize: 13
                      ),),
                      IconButton(
                          onPressed:()=>Navigator.pop(context),
                          icon:Icon(Icons.close , color:Colors.red)
                      )
                    ],
                  ),
                  content: Container(
                    width: 250,
                    color: Colors.white,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          loading?LinearProgressIndicator():Container(),
                          TextField(
                            controller: streetNameCtrl,
                            decoration: InputDecoration(
                                hintText: 'Street No.',
                                hintStyle: TextStyle(fontFamily: "Poppins", fontSize: 13),
                                errorText: streetVal?'required street no. & name!':null
                            ),
                          ),
                          SizedBox(height: 15,),
                          TextField(
                            controller: cityNameCtrl,
                            decoration: InputDecoration(
                                hintText: 'City/Area/Town',
                                hintStyle: TextStyle(fontFamily: "Poppins", fontSize: 13),
                                errorText: cityVal?'required city name!':null
                            ),
                          ),SizedBox(height: 15,),

                          TextField(
                            controller: districtNameCtrl,
                            decoration: InputDecoration(
                                hintText: 'District',
                                hintStyle: TextStyle(fontFamily: "Poppins", fontSize: 13),
                                errorText: districtVal?'required district name!':null
                            ),
                          ),
                          SizedBox(height: 15,),
                          TextField(
                            maxLength: 6,
                            controller: pinCodeCtrl,
                            decoration: InputDecoration(
                                hintText: 'Pin Code',
                                hintStyle: TextStyle(fontFamily: "Poppins", fontSize: 13),
                                errorText: pincodeVal?'required pin code!':null
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  actions: [
                    FlatButton(
                        onPressed: () async{

                          setState((){
                            loading = true;
                          });

                          Position position = await _getGeoLocationPosition();
                          List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);

                          Placemark place = placemarks[1];
                          // Address = '${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';

                          setState(()  {
                            streetNameCtrl = new TextEditingController(text: place.street);
                            cityNameCtrl = new TextEditingController(text: place.subLocality);
                            districtNameCtrl = new TextEditingController(text: place.locality);
                            pinCodeCtrl = new TextEditingController(text: place.postalCode);
                          });

                          setState((){
                            loading = false;
                          });

                        },
                        child: Text('Current',style: TextStyle(
                            color: darkBlue,fontFamily: "Poppins"
                        ),)
                    ),
                    FlatButton(
                        onPressed: (){
                          setState((){
                            //street
                            if(streetNameCtrl.text.isEmpty){
                              streetVal = true;
                            }else{
                              streetVal = false;
                            }

                            //city
                            if(cityNameCtrl.text.isEmpty){
                              cityVal = true;
                            }else{
                              cityVal = false;
                            }

                            //dist
                            if(districtNameCtrl.text.isEmpty){
                              districtVal = true;
                            }else{
                              districtVal = false;
                            }

                            //pin
                            if(pinCodeCtrl.text.isEmpty||pinCodeCtrl.text.length <6){
                              pincodeVal = true;
                            }else{
                              pincodeVal = false;
                            }

                            print(

                                'Street no : ${streetNameCtrl.text}\n'
                                    'City : ${cityNameCtrl.text}\n'
                                    'District : ${districtNameCtrl.text}\n'
                                    'Pincode : ${pinCodeCtrl.text}\n'

                            );

                            if(streetNameCtrl.text.isNotEmpty&&cityNameCtrl.text.isNotEmpty&&
                                districtNameCtrl.text.isNotEmpty&&pinCodeCtrl.text.isNotEmpty)
                            {
                              saveNewAddress(streetNameCtrl.text , cityNameCtrl.text , districtNameCtrl.text,
                                  pinCodeCtrl.text);
                            }

                          });
                        },
                        child:Text('Save',style: TextStyle(
                            color: Colors.green,fontFamily: "Poppins"
                        ),)
                    ),
                  ],
                );
              }
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
                    FlatButton(
                        onPressed: (){
                          saveNotOther();
                        },
                        child: Text('Cancel')
                    ),
                    FlatButton(
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

                    FlatButton(
                        onPressed: (){
                          Navigator.pop(context);
                        },
                        child: Text('Cancel')
                    ),

                    FlatButton(
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

                    FlatButton(
                        onPressed: (){
                          saveNotOtherShape();
                        },
                        child: Text('Cancel')
                    ),

                    FlatButton(
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
              FlatButton(
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  child: Text('Cancel')
              ),
              FlatButton(
                  onPressed: (){
                    Navigator.pop(context);
                    confirmOrder();
                  },
                  child: Text('Order Now')
              ),
            ],
          ),
    );
  }

  //endregion

  //region Functions

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
    setState(() {
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
      newRegUser = pref.getBool('newRegUser')??false;
      userID = pref.getString('userID')??'Not Found';
      userModId = pref.getString('userModId')??'Not Found';
      userName = pref.getString('userName')??'Not Found';
      deliverAddress = pref.getString('userAddress')??'Not Found';
      userPhone = pref.getString('phoneNumber')??'Not Found';
      authToken= pref.getString('authToken')??'null';
      userCurLocation = pref.getString('userCurrentLocation')??'Not Found';
      userMainLocation = pref.getString('userMainLocation')??'Not Found';
    });
    getShapesList();
    getWeightList();
    getFlavsList();
    getArticleList();
    getVendorsList();

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

    var res = await http.get(Uri.parse('https://cakey-database.vercel.app/api/flavour/list'),
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

  }

  //geting the shapes fom collection
  Future<void> getShapesList() async{
    
    var res = await http.get(Uri.parse('https://cakey-database.vercel.app/api/shape/list'),
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
    
  }

  //geting the article fom collection
  Future<void> getArticleList() async{

    var res = await http.get(Uri.parse('https://cakey-database.vercel.app/api/article/list'),
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
    print('weight...');
    var res = await http.get(Uri.parse('https://cakey-database.vercel.app/api/weight/list'),
        headers: {"Authorization":"$authToken"}
    );
    if(res.statusCode==200){
      setState((){
        List myList = jsonDecode(res.body);

        if(myList.isNotEmpty){
          for(int i=0;i<myList.length;i++){
            weight.add(myList[i]['Weight']);
          }
          weight.sort();
        }else{
          weight = ["1kg","2kg","3kg" , "4kg", "5kg" , "6kg"];
        }

      });
    }else{
      print(res.statusCode);
    }
  }

  //get the vendors....
  Future<void> getVendorsList() async{
    showAlertDialog();
    try{
      var res = await http.get(Uri.parse("https://cakey-database.vercel.app/api/vendors/list"),
          headers: {"Authorization":"$authToken"}
      );
      if(res.statusCode==200){
        setState(() {
          List vendorsList = jsonDecode(res.body);

          for(int i = 0; i<vendorsList.length;i++){
            if(vendorsList[i]['Address']!=null&&vendorsList[i]['Address']['City']!=null&&
                vendorsList[i]['Address']['City'].toString().toLowerCase()==userMainLocation.toLowerCase()){
              print('found .... $i');
              setState(() {
                nearestVendors.add(vendorsList[i]);
              });
            }
          }

          Navigator.pop(context);
        });
      }else{
        Navigator.pop(context);
      }
    }on Exception catch(e){
      Navigator.pop(context);
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
      fixedShape = "Round";
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
          cateListScrollCtrl.jumpTo(cateListScrollCtrl.position.minScrollExtent);
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
  Future<void> confirmOrder() async{

    var tempList = [];

    setState((){
      if(fixedFlavList.isEmpty){
        fixedFlavList = [jsonEncode({"Name":"Vanilla","Price":"0"})];
      }else{
        fixedFlavList = fixedFlavList+flavTempList;

        for(int i = 0;i<fixedFlavList.length;i++){
          tempList.add(jsonEncode(fixedFlavList[i]));
        }

        tempList = tempList.toSet().toList();
      }

      print(tempList);
      print(fixedWeight);


      print(json.encode({
        'TypeOfCake': '$fixedCategory',
        'EggOrEggless': egglesSwitch==false?'Egg':'Eggless',
        'Flavour': tempList.toString(),
        'Shape': '$fixedShape',
        'Article': fixedCakeArticle.isEmpty?'{"Name":"None","Price":"0"}':
        '{"Name":"$fixedCakeArticle","Price":"0"}',
        'Weight': '${fixedWeight}',
        'SpecialRequest':specialReqCtrl.text.isEmpty?'None':'${specialReqCtrl.text}',
        'MessageOnTheCake':msgCtrl.text.isEmpty?'None':'${msgCtrl.text}',
        'DeliveryAddress': '$deliverAddress',
        'DeliveryDate': '$fixedDate',
        'DeliverySession': '$fixedSession',
        'DeliveryInformation': '$fixedDelliverMethod',
        'VendorID': '$vendorID',
        'VendorName': '$vendorName',
        'VendorPhoneNumber': '$vendorPhone',
        'VendorAddress': '$vendorAddress',
        'Vendor_ID':'$vendorModId',
        "User_ID":"$userModId",
        'SpecialRequest':specialReqCtrl.text.isEmpty?'None':'${specialReqCtrl.text}',
        'UserID': '$userID',
        'UserName': '$userName',
        'UserPhoneNumber': '$userPhone'
      }));

    });

    showAlertDialog();

    //below 5 kg it will work...
    if(double.parse(fixedWeight.replaceAll("kg", "")) < 6.0){

      print("below 5");
      print(file.path);

      try{

        //user not select the file
        if(file.path.isEmpty){

          var request = http.MultipartRequest('POST',
              Uri.parse('https://cakey-database.vercel.app/api/customize/cake/new'));

          request.headers['Content-Type'] = 'multipart/form-data';

          request.fields.addAll({
            'TypeOfCake': '$fixedCategory',
            'EggOrEggless': egglesSwitch==false?'Egg':'Eggless',
            'Flavour': tempList.toString(),
            'Shape': '$fixedShape',
            'Article': fixedCakeArticle.isEmpty?'{"Name":"None","Price":"0"}':
             '{"Name":"$fixedCakeArticle","Price":"0"}',
            'Weight': '${fixedWeight}kg',
            'SpecialRequest':specialReqCtrl.text.isEmpty?'None':'${specialReqCtrl.text}',
            'MessageOnTheCake':msgCtrl.text.isEmpty?'None':'${msgCtrl.text}',
            'DeliveryAddress': '$deliverAddress',
            'DeliveryDate': '$fixedDate',
            'DeliverySession': '$fixedSession',
            'DeliveryInformation': '$fixedDelliverMethod',
            'VendorID': '$vendorID',
            'VendorName': '$vendorName',
            'VendorPhoneNumber': '$vendorPhone',
            'VendorAddress': '$vendorAddress',
            'Vendor_ID':'$vendorModId',
            "User_ID":"$userModId",
            'SpecialRequest':specialReqCtrl.text.isEmpty?'None':'${specialReqCtrl.text}',
            'UserID': '$userID',
            'UserName': '$userName',
            'UserPhoneNumber': '$userPhone'
          });

          // request.files.add(await http.MultipartFile.fromPath(
          //     'files', file.path.toString(),
          //     filename: Path.basename(file.path),
          //     contentType: MediaType.parse(lookupMimeType(file.path.toString()).toString())
          // ));

          http.StreamedResponse response = await request.send();

          if (response.statusCode == 200) {
            print(await response.stream.bytesToString());
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Order Posted.!'),
                  backgroundColor: Colors.green[600],
                  behavior: SnackBarBehavior.floating,
                )
            );
          }
          else {
            print(response.reasonPhrase);
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(response.reasonPhrase.toString()),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                )
            );
            Navigator.pop(context);
          }

        }else{

          print("abv 5");

          var request = http.MultipartRequest('POST',
              Uri.parse('https://cakey-database.vercel.app/api/customize/cake/new'));

          request.headers['Content-Type'] = 'multipart/form-data';

          request.fields.addAll({
            'TypeOfCake': '$fixedCategory',
            'EggOrEggless': egglesSwitch==false?'Egg':'Eggless',
            'Flavour': '$tempList',
            'Shape': '$fixedShape',
            'SpecialRequest':specialReqCtrl.text.isEmpty?'None':'${specialReqCtrl.text}',
            'Article': fixedCakeArticle.isEmpty?'{"Name":"None","Price":"0"}':
              '{"Name":"$fixedCakeArticle","Price":"0"}',
            'Weight': '${fixedWeight}kg',
            'MessageOnTheCake':msgCtrl.text.isEmpty?'None':'${msgCtrl.text}',
            'DeliveryAddress': '$deliverAddress',
            'DeliveryDate': '$fixedDate',
            'DeliverySession': '$fixedSession',
            'DeliveryInformation': '$fixedDelliverMethod',
            'VendorName': '$vendorName',
            'VendorPhoneNumber': '$vendorPhone',
            'VendorAddress': '$vendorAddress',
            'Vendor_ID':'$vendorModId',
            "User_ID":"$userModId",
            'UserName': '$userName',
            'UserPhoneNumber': '$userPhone',
            'VendorID': '$vendorID',
            'UserID': '$userID',
          });

          request.files.add(await http.MultipartFile.fromPath(
              'files', file.path.toString(),
              filename: Path.basename(file.path),
              contentType: MediaType.parse(lookupMimeType(file.path.toString()).toString())
          ));

          http.StreamedResponse response = await request.send();

          if (response.statusCode == 200) {
            print(await response.stream.bytesToString());
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Order Posted.!'),
                  backgroundColor: Colors.green[600],
                  behavior: SnackBarBehavior.floating,
                )
            );
          }
          else {
            print(response.reasonPhrase);
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(response.reasonPhrase.toString()),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                )
            );
            Navigator.pop(context);
          }

        }

      }catch(e){
        print(e);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Something Went Wrong!'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            )
        );
      }

    }else{


      try{

        //user not select the file
        if(file.path.isEmpty){


          var request = http.MultipartRequest('POST',
              Uri.parse('https://cakey-database.vercel.app/api/customize/cake/new'));

          request.headers['Content-Type'] = 'multipart/form-data';

          request.fields.addAll({
            'TypeOfCake': '$fixedCategory',
            'EggOrEggless': egglesSwitch==false?'Egg':'Eggless',
            'Flavour': '$tempList',
            'Shape': '$fixedShape',
            'Article': fixedCakeArticle.isEmpty?'{"Name":"None","Price":"0"}':
            '{"Name":"$fixedCakeArticle","Price":"0"}',
            'Weight': '${fixedWeight}kg',
            'MessageOnTheCake':msgCtrl.text.isEmpty?'None':'${msgCtrl.text}',
            'DeliveryAddress': '$deliverAddress',
            'DeliveryDate': '$fixedDate',
            'DeliverySession': '$fixedSession',
            'DeliveryInformation': '$fixedDelliverMethod',
            'SpecialRequest':specialReqCtrl.text.isEmpty?'None':'${specialReqCtrl.text}',
            "User_ID":"$userModId",
            'UserID': '$userID',
            'UserName': '$userName',
            'UserPhoneNumber': '$userPhone'
          });

          // request.files.add(await http.MultipartFile.fromPath(
          //     'files', file.path.toString(),
          //     filename: Path.basename(file.path),
          //     contentType: MediaType.parse(lookupMimeType(file.path.toString()).toString())
          // ));

          http.StreamedResponse response = await request.send();

          if (response.statusCode == 200) {
            print(await response.stream.bytesToString());
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Order Posted.!'),
                  backgroundColor: Colors.green[600],
                  behavior: SnackBarBehavior.floating,
                )
            );
          }
          else {
            print(response.reasonPhrase);
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(response.reasonPhrase.toString()),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                )
            );
            Navigator.pop(context);
          }

        }else{

          var request = http.MultipartRequest('POST',
              Uri.parse('https://cakey-database.vercel.app/api/customize/cake/new'));

          request.headers['Content-Type'] = 'multipart/form-data';

          // for (String item in fixedFlavList) {
          //   request.files.add(http.MultipartFile.fromString('Flavour', item));
          // }


          request.fields.addAll({
            'TypeOfCake': '$fixedCategory',
            'EggOrEggless': egglesSwitch==false?'Egg':'Eggless',
            'Flavour': '$tempList',
            'Shape': '$fixedShape',
            'Article': fixedCakeArticle.isEmpty?'{"Name":"None","Price":"0"}':
            '{"Name":"$fixedCakeArticle","Price":"0"}',
            'SpecialRequest':specialReqCtrl.text.isEmpty?'None':'${specialReqCtrl.text}',
            'Weight': '${fixedWeight}',
            'MessageOnTheCake':msgCtrl.text.isEmpty?'None':'${msgCtrl.text}',
            'DeliveryAddress': '$deliverAddress',
            'DeliveryDate': '$fixedDate',
            'DeliverySession': '$fixedSession',
            'DeliveryInformation': '$fixedDelliverMethod',
            "User_ID":"$userModId",
            'UserID': '$userID',
            'User_ID':'$userModId',
            'UserName': '$userName',
            'UserPhoneNumber': '$userPhone'
          });

          request.files.add(await http.MultipartFile.fromPath(
              'files', file.path.toString(),
              filename: Path.basename(file.path),
              contentType: MediaType.parse(lookupMimeType(file.path.toString()).toString())
          ));

          http.StreamedResponse response = await request.send();

          if (response.statusCode == 200) {
            print(await response.stream.bytesToString());
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Order Posted.!'),
                  backgroundColor: Colors.green[600],
                  behavior: SnackBarBehavior.floating,
                )
            );
          }
          else {
            print(response.reasonPhrase);
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(response.reasonPhrase.toString()),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                )
            );
            Navigator.pop(context);
          }

        }

      }catch(e){
        print(e);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Something Went Wrong!'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            )
        );

      }


    }

  }

  //post the others to API
  Future<void> sendOtherToApi(String obj , String value) async{
    print(obj);
    print(value);
    var headers = {
      'Content-Type': 'application/json'
    };
    var request = http.Request('POST', Uri.parse('https://cakey-database.vercel.app/api/${obj.toLowerCase()}/new'));
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

  //endregion

  @override
  void initState() {

    // TODO: implement initState
    Future.delayed(Duration.zero , () async{
      loadPrefs();
      context.read<ContextData>().setMyVendors([]);
      context.read<ContextData>().addMyVendor(false);
    });
    // session();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {

    profileUrl = context.watch<ContextData>().getProfileUrl();
    if(context.watch<ContextData>().getAddress().isNotEmpty){
      deliverAddress = context.watch<ContextData>().getAddress();
    }else{
      deliverAddress = deliverAddress;
    }
    selFromVenList = context.watch<ContextData>().getAddedMyVendor();
    mySelectdVendors = context.watch<ContextData>().getMyVendorsList();

    // "VendorId":nearestVendors[index]['_id'],
    // "VendorModId":nearestVendors[index]['Id'],
    // "VendorName":nearestVendors[index]['VendorName'],
    // "VendorDesc":nearestVendors[index]['Description'],
    // "VendorProfile":nearestVendors[index]['ProfileImage'],
    // "VendorPhone":nearestVendors[index]['PhoneNumber1'],
    // "VendorDelCharge":nearestVendors[index]['DeliveryCharge'],
    // "VendorEgg":nearestVendors[index]['EggOrEggless'],
    // "VendorAddress":nearestV

    setState((){
      if(mySelectdVendors.isNotEmpty){
        vendorID = mySelectdVendors[0]['VendorId'];
        vendorModId = mySelectdVendors[0]['VendorModId'];
        vendorName = mySelectdVendors[0]['VendorName'];
        vendorPhone = mySelectdVendors[0]['VendorPhone'];
        vendorAddress = mySelectdVendors[0]['VendorAddress'];
      }
    });

    return Scaffold(
        resizeToAvoidBottomInset: false,
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
                          Icon(Icons.location_on,color: Colors.red,),
                          SizedBox(width: 5,),
                          Text('Delivery to',style: TextStyle(color: Colors.black54,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,fontFamily: "Poppins"),)
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(left: 8),
                      alignment: Alignment.centerLeft,
                      child: Text('$userCurLocation',style:TextStyle(fontFamily: "Poppins",fontSize: 15,color: darkBlue,fontWeight: FontWeight.bold),),
                    ),
                  ],
                ),
              ),
              //Main widgets....
              Container(
                height: MediaQuery.of(context).size.height*0.82,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text("What Makes Yours Tastier Than The Rest? Customize To Your Heart's",
                          style: TextStyle(color: darkBlue,fontSize: 15,fontFamily: "Poppins",fontWeight: FontWeight.bold),
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
                              activeColor: Colors.green,
                            ),
                          ),
                          Text(egglesSwitch?'Eggless':'Egg',style: TextStyle(color: darkBlue,
                              fontWeight: FontWeight.bold,fontFamily: "Poppins" ,fontSize: 13),),
                        ],
                      ),

                      //Category Text
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text("Select Category",
                          style: TextStyle(color: darkBlue,fontSize: 14,fontFamily: "Poppins",),
                        ),
                      ),

                      //Category stacks ()....
                      Container(
                          height: 80,
                          padding: EdgeInsets.all(10),
                          child: ListView.builder(
                              shrinkWrap: true,
                              controller: cateListScrollCtrl,
                              itemCount: categories.length,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context , index){
                                return Stack(
                                  children: [
                                    GestureDetector(
                                      onTap:(){

                                        if(categories[index].toString().contains("Others")){
                                          print('Yes...');
                                          showOthersCateDialog();
                                        }

                                        setState((){
                                          currentIndex = index;
                                          fixedCategory = categories[currentIndex];
                                        });
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(5),
                                        child: Container(
                                          padding: EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                              border: Border.all(color: lightPink,width: 1),
                                              borderRadius: BorderRadius.circular(8)
                                          ),
                                          child:
                                          categories[index]=="Others"?
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.add_circle_outline,color: lightPink,),
                                              SizedBox(width: 10,),
                                              Text('${categories[index]}',style: TextStyle(
                                                  fontFamily: "Poppins",
                                                  color: darkBlue
                                              ),),
                                              SizedBox(width: 10,),
                                            ],
                                          ):
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.cake_outlined,color: lightPink,),
                                              SizedBox(width: 10,),
                                              Text('${categories[index]}',style: TextStyle(
                                                  fontFamily: "Poppins",
                                                  color: darkBlue
                                              ),),
                                              SizedBox(width: 10,),
                                            ],
                                          )
                                        ),
                                      ),
                                    ),
                                    currentIndex == index?
                                    Positioned(
                                        right: 0,
                                        child:Container(
                                            alignment: Alignment.center,
                                            height: 20,
                                            width: 20,
                                            decoration: BoxDecoration(
                                                color:Colors.green,
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
                              }
                          )
                      ),

                      //Shapes....flav...toppings
                      Container(
                          margin:const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              color:Colors.red[50],
                              borderRadius: BorderRadius.circular(12)
                          ),
                          child:Column(
                              children:[
                                ExpansionTile(
                                  title: Text('Shapes',style: TextStyle(
                                      fontFamily: "Poppins",fontSize: 13,color: Colors.grey
                                  ),),
                                  subtitle:Text('$fixedShape',style: TextStyle(
                                      fontFamily: "Poppins",fontSize: 15,fontWeight: FontWeight.w900,
                                      color: darkBlue
                                  ),),
                                  trailing: Container(
                                    alignment: Alignment.center,
                                    height: 25,
                                    width: 25,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle ,
                                    ),
                                    child: Icon(Icons.keyboard_arrow_down_rounded , color: darkBlue,size: 25,),
                                  ),
                                  children: [
                                    Container(
                                      color:Colors.white,
                                      child:ListView.builder(
                                          physics: NeverScrollableScrollPhysics(),
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
                                                          fontWeight: FontWeight.bold
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
                                                          fontWeight: FontWeight.bold
                                                      ),
                                                    ),)
                                                  ],
                                                )
                                              ),
                                            );
                                          }),
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
                                  subtitle:Text(fixedFlavList.isEmpty&&flavTempList.isEmpty?'$fixedFlavour':
                                  '${fixedFlavList.length+flavTempList.length} Selected Flavours',style: TextStyle(
                                      fontFamily: "Poppins",fontSize: 15,fontWeight: FontWeight.w900,
                                      color: darkBlue
                                  ),),
                                  trailing: Container(
                                    alignment: Alignment.center,
                                    height: 25,
                                    width: 25,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle ,
                                    ),
                                    child: Icon(Icons.keyboard_arrow_down_rounded , color: darkBlue,size: 25,),
                                  ),
                                  children: [
                                    Container(
                                      color:Colors.white,
                                      child:Column(
                                        children: [
                                          ListView.builder(
                                              physics: NeverScrollableScrollPhysics(),
                                              itemCount: flavourList.length,
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
                                                              fontWeight: FontWeight.bold
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
                                                //
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
                                          Container(),

                                        ],
                                      ),
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
                          style: TextStyle(color: darkBlue,fontSize: 14,fontFamily: "Poppins",),
                        ),
                      ),
                      Container(
                          height: MediaQuery.of(context).size.height * 0.06,
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
                                      isFixedWeight = index;
                                      fixedWeight = weight[index].toString();
                                      print(fixedWeight);
                                    });

                                  },
                                  child:Container(
                                    width: 70,
                                    alignment: Alignment.center,
                                    margin: EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(18),
                                        border: Border.all(
                                          color: lightPink,
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
                              })),

                      SizedBox(height:10),



                      Padding(
                        padding: const EdgeInsets.only(left :15.0 , top:15),
                        child: Text(
                          'Enter Weight',
                          style: TextStyle(
                              fontFamily: poppins, color: darkBlue),
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
                                    FilteringTextInputFormatter.allow(new RegExp('[1-9.]'))
                                  ],
                                  style:TextStyle(fontFamily: 'Poppins' ,
                                      fontSize: 13
                                  ),
                                  onChanged: (String text){
                                    if(text.isNotEmpty){
                                      setState((){
                                        isFixedWeight = -1;
                                        fixedWeight = text+"kg";
                                      });
                                    }else{
                                      isFixedWeight = 0;
                                      fixedWeight = weight[0];
                                    }
                                  },
                                  onSubmitted:(String text){
                                    if(text.isNotEmpty){
                                      sendOtherToApi("Weight", text+"kg");
                                    }
                                  },
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.all(0.0),
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
                                        PopupMenuItem(onTap:(){
                                          setState((){
                                            selectedDropWeight = "Ib";
                                          });
                                        },child:Text('Pounds')),
                                        PopupMenuItem(onTap:(){
                                          setState((){
                                            selectedDropWeight = "G";
                                          });
                                        },child:Text('Gram')),
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

                      Container(
                        //margin
                          margin: EdgeInsets.all(10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(' Message on the cake',
                                style: TextStyle(color: darkBlue,fontSize: 14,fontFamily: "Poppins",),
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

                              //Articlessss
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Text(
                                  ' Articles',
                                  style: TextStyle(color: darkBlue,fontSize: 14,fontFamily: "Poppins"),
                                ),
                              ),

                              Container(
                                  child:ListView.builder(
                                    shrinkWrap : true,
                                    physics : NeverScrollableScrollPhysics(),
                                    itemCount:articals.length < 5?articals.length:5,
                                    itemBuilder: (context , index){
                                      return InkWell(
                                        onTap:(){
                                          setState(() {
                                            if(articals[index].toString().contains('Others')){

                                              if(articGroupVal==index){
                                                articGroupVal = -1;
                                                addOtherArticle = false;
                                              }else{
                                                addOtherArticle = true;
                                                articGroupVal = index;
                                              }

                                            }else{
                                              if(articGroupVal==index){
                                                fixedCakeArticle = 'None';
                                                articGroupVal = -1;
                                                addOtherArticle = false;
                                              }else{
                                                articGroupVal = index;
                                                fixedCakeArticle = articals[index].toString();
                                                addOtherArticle = false;
                                              }
                                            }

                                          });
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(5),
                                          child: Row(
                                              children:[
                                                articGroupVal!=index?
                                                Icon(Icons.radio_button_unchecked_rounded, color:Colors.black):
                                                Icon(Icons.check_circle_rounded, color:Colors.green),
                                                SizedBox(width:5),
                                                Expanded(
                                                  child:Text.rich(
                                                      TextSpan(
                                                          text: "",
                                                          children: <InlineSpan>[
                                                            TextSpan(
                                                              text:"${articals[index]} ",
                                                              style: TextStyle(
                                                                  fontFamily: poppins, color:Colors.black54 , fontSize: 13
                                                              ),),
                                                          ]
                                                      )
                                                  ),
                                                ),
                                              ]
                                          ),
                                        ),
                                      );
                                    },
                                  )
                              ),

                              AnimatedSwitcher(
                                  switchInCurve: Curves.ease,
                                  switchOutCurve: Curves.ease,
                                  duration: Duration(seconds: 1),
                                  child: addOtherArticle?
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(' Add Your Article On Cake',
                                        style: TextStyle(color: darkBlue,fontSize: 14,fontFamily: "Poppins",),
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
                                  style: TextStyle(color: darkBlue,fontSize: 14,fontFamily: "Poppins"),
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
                                  margin: EdgeInsets.symmetric(horizontal: 10),
                                  child: Divider(
                                    color: Colors.pink[100],
                                  )),
                              Padding(
                                padding: EdgeInsets.only(top: 10 , left: 10),
                                child: Text(
                                  'Delivery Information',
                                  style: TextStyle(
                                    fontFamily: poppins, color: darkBlue , fontSize: 14 ,
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
                                                Icon(Icons.check_circle_rounded, color:Colors.green),
                                                SizedBox(width:6),
                                                Text('${picOrDeliver[index]}',style: TextStyle(
                                                    fontFamily: poppins, color:Colors.black54 , fontSize: 14
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
                              padding: EdgeInsets.only(top: 10 , left: 10, bottom:5),
                              child: Text(
                                'Delivery Details',
                                style: TextStyle(
                                  fontFamily: poppins, color: darkBlue , fontSize: 14,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap : () async {
                                FocusScope.of(context).unfocus();
                                DateTime? SelDate = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  lastDate: DateTime(2100),
                                  firstDate: DateTime.now()
                                      .subtract(Duration(days: 0)),
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
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey,
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
                                                20)),
                                        title: Text(
                                            "Select delivery session",
                                            style: TextStyle(
                                              color: lightPink,
                                              fontFamily: "Poppins",
                                              fontSize: 16,
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
                                                      child: Text('Morning 8 - 9'),
                                                      onTap:(){
                                                        setState((){
                                                          fixedSession = 'Morning 8 - 9';
                                                        });
                                                      }
                                                  ),
                                                  PopupMenuItem(
                                                      child: Text('Morning 9 - 10'),
                                                      onTap:(){
                                                        setState((){
                                                          fixedSession = 'Morning 9 - 10';
                                                        });
                                                      }
                                                  ),
                                                  PopupMenuItem(
                                                      child: Text('Morning 10 - 11'),
                                                      onTap:(){
                                                        setState((){
                                                          fixedSession = 'Morning 10 - 11';
                                                        });
                                                      }
                                                  ),
                                                  PopupMenuItem(
                                                      child: Text('Morning 11 - 12'),
                                                      onTap:(){
                                                        setState((){
                                                          fixedSession = 'Morning 11 - 12';
                                                        });
                                                      }
                                                  ),
                                                  PopupMenuItem(
                                                      child: Text('Afternoon 12 - 1'),
                                                      onTap:(){
                                                        setState((){
                                                          fixedSession = 'Afternoon 12 - 1';
                                                        });
                                                      }
                                                  ),
                                                  PopupMenuItem(
                                                      child: Text('Afternoon 1 - 2'),
                                                      onTap:(){
                                                        setState((){
                                                          fixedSession = 'Afternoon 1 - 9';
                                                        });
                                                      }
                                                  ),
                                                  PopupMenuItem(
                                                      child: Text('Afternoon 2 - 3'),
                                                      onTap:(){
                                                        setState((){
                                                          fixedSession = 'Afternoon 8 - 9';
                                                        });
                                                      }
                                                  ),
                                                  PopupMenuItem(
                                                      child: Text('Afternoon 3 - 4'),
                                                      onTap:(){
                                                        setState((){
                                                          fixedSession = 'Afternoon 3 - 4';
                                                        });
                                                      }
                                                  ),
                                                  PopupMenuItem(
                                                      child: Text('Afternoon 4 - 5'),
                                                      onTap:(){
                                                        setState((){
                                                          fixedSession = 'Afternoon 4 - 5';
                                                        });
                                                      }
                                                  ),
                                                  PopupMenuItem(
                                                      child: Text('Evening 5 - 6'),
                                                      onTap:(){
                                                        setState((){
                                                          fixedSession = 'Evening 5 - 6';
                                                        });
                                                      }
                                                  ),
                                                  PopupMenuItem(
                                                      child: Text('Evening 6 - 7'),
                                                      onTap:(){
                                                        setState((){
                                                          fixedSession = 'Evening 6 - 7';
                                                        });
                                                      }
                                                  ),
                                                  PopupMenuItem(
                                                      child: Text('Evening 7 - 8'),
                                                      onTap:(){
                                                        setState((){
                                                          fixedSession = 'Evening 7 - 8';
                                                        });
                                                      }
                                                  ),
                                                  PopupMenuItem(
                                                      child: Text('Evening 8 - 9'),
                                                      onTap:(){
                                                        setState((){
                                                          fixedSession = 'Evening 8 - 9';
                                                        });
                                                      }
                                                  ),
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
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey,
                                              fontSize: 13
                                          ),
                                        ),
                                        Icon(Icons.keyboard_arrow_down,
                                            color: darkBlue)
                                      ]
                                  )
                              ),
                            ),
                          ],
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: Text(' Address',
                          style: TextStyle(color: darkBlue,fontSize: 14,fontFamily: "Poppins"),
                        ),
                      ),
                      Container(
                        padding:EdgeInsets.only(left:15 , right:15,top:3),
                        child:Row(
                            crossAxisAlignment:CrossAxisAlignment.center,
                            children:[
                              Expanded(
                                child:Text('$deliverAddress',
                                  style: TextStyle(fontFamily: poppins,color: Colors.grey,fontSize: 13),
                                ),
                              ),
                              Icon(Icons.check_circle,color: Colors.green,size: 25,),
                            ]
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 10),
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                            onPressed: (){
                              // showAddAddressAlert();
                              Navigator.push(context, MaterialPageRoute(builder: (context)=>AddressScreen()));
                            },
                            child: const Text('add new address',style: const TextStyle(
                                color: Colors.orange,fontFamily: "Poppins",decoration: TextDecoration.underline
                            ),)
                        ),
                      ),

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
                                  Icon(Icons.image_rounded , color: Colors.blueAccent,size: 40,),
                                  Text('Pick Your Image',
                                    style: TextStyle(color: darkBlue,fontSize: 16,fontFamily: "Poppins",fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ):Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.all(10),
                              width: MediaQuery.of(context).size.width,
                              height: 160,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    height: 150,
                                    width: 200,
                                    child: Image.file(file),
                                  ),
                                  TextButton(
                                    onPressed: (){
                                      setState(() {
                                        file = new fil.File('');
                                      });
                                    },
                                    child: Text('Remove' , style: TextStyle(
                                        fontFamily: "Poppins"
                                    ),),
                                  )
                                ],
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
                                double.parse(fixedWeight.replaceAll("kg", ''))<6.0?
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
                                      onTap:(){
                                        // setState((){
                                        //   selVendorIndex = -1;
                                        // });
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
                                            mySelectdVendors[0]['VendorProfile']!=null?
                                            Container(
                                              width:90,
                                              height:100,
                                              decoration: BoxDecoration(
                                                  color:Colors.red ,
                                                  borderRadius:BorderRadius.circular(10) ,
                                                  image:DecorationImage(
                                                      image:NetworkImage(mySelectdVendors[0]['VendorProfile'].toString()),
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
                                                                Text(' 4.5',style: TextStyle(
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

                                                  Text(mySelectdVendors[0]['VendorDesc']!=null||
                                                      mySelectdVendors[0]['VendorDesc']!='null'?
                                                  "${mySelectdVendors[0]['VendorDesc']}":"No Description",
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
                                                          Text(mySelectdVendors[0]['VendorEgg']=='Both'?
                                                          'Includes eggless':'${mySelectdVendors[0]['VendorEgg']}',
                                                            style:TextStyle(
                                                              fontSize:11,
                                                              fontFamily: "Poppins" ,
                                                              color:darkBlue,
                                                            ),maxLines: 1,),
                                                          SizedBox(height:3),
                                                          Text(mySelectdVendors[0]['VendorDelCharge']=='0'||
                                                              mySelectdVendors[0]['VendorDelCharge']==null?
                                                          "DELIVERY FREE":'Delivery Fee Rs.${mySelectdVendors[0]['VendorDelCharge']}',
                                                            style:TextStyle(
                                                              fontSize:10,
                                                              fontFamily: "Poppins" ,
                                                              color:Colors.orange,
                                                            ),maxLines: 1,),
                                                        ],
                                                      ),
                                                      Container(
                                                        width: 100,
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.end,
                                                          children: [
                                                            InkWell(
                                                              onTap: (){
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
                                                                child:const Icon(Icons.phone,color: Colors.blueAccent,),
                                                              ),
                                                            ),
                                                            const SizedBox(width: 10,),
                                                            InkWell(
                                                              onTap: (){
                                                                print('whatsapp : ');
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
                                        height: 200,
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
                                                      selVendorIndex = index;

                                                      vendorID = nearestVendors[index]['_id'];
                                                      vendorModId = nearestVendors[index]['Id'];
                                                      vendorName = nearestVendors[index]['VendorName'];
                                                      vendorPhone = nearestVendors[index]['PhoneNumber1'];
                                                      vendorAddress = nearestVendors[index]['Address']['FullAddress'];

                                                      context.read<ContextData>().addMyVendor(true);
                                                      context.read<ContextData>().setMyVendors(
                                                          [
                                                            {
                                                              "VendorId":nearestVendors[index]['_id'],
                                                              "VendorModId":nearestVendors[index]['Id'],
                                                              "VendorName":nearestVendors[index]['VendorName'],
                                                              "VendorDesc":nearestVendors[index]['Description'],
                                                              "VendorProfile":nearestVendors[index]['ProfileImage'],
                                                              "VendorPhone":nearestVendors[index]['PhoneNumber1'],
                                                              "VendorDelCharge":nearestVendors[index]['DeliveryCharge'],
                                                              "VendorEgg":nearestVendors[index]['EggOrEggless'],
                                                              "VendorAddress":nearestVendors[index]['Address']['FullAddress'],
                                                            }
                                                          ]
                                                      );

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
                                                                          Text(' 4.5',style: TextStyle(
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
                                                          height: 0.5,
                                                          color: Colors.black26,
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
                                                                Text(nearestVendors[index]['DeliveryCharge'].toString()=='null'||
                                                                    nearestVendors[index]['DeliveryCharge'].toString()=='0'||
                                                                    nearestVendors[index]['DeliveryCharge'].toString()==null
                                                                    ?
                                                                'DELIVERY FREE':'Delivery Charge ₹${nearestVendors[index]['DeliveryCharge'].toString()}',style: TextStyle(
                                                                    color: Colors.orange,
                                                                    fontSize: 10 ,
                                                                    fontFamily: "Poppins"
                                                                ),),
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
                                                  color:Colors.orange,fontFamily: "Poppins",fontSize:18
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
                                              color:Colors.orange,fontFamily: "Poppins",fontSize:18
                                          ))
                                        ]
                                    )
                                ),
                              ],
                            ),
                            SizedBox(height: 15,),

                            Center(
                              child: Container(
                                height: 50,
                                width: 200,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(25)
                                ),
                                child: RaisedButton(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25)
                                  ),
                                  onPressed: (){

                                    if(newRegUser==true){
                                      showDpUpdtaeDialog();
                                    }else{

                                      if(mySelectdVendors.isNotEmpty){

                                        if(fixedWeight.isEmpty||fixedDelliverMethod.isEmpty||
                                            fixedDate=="Not Yet Select"||fixedSession=="Not Yet Select"){

                                          ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('Please Select : Cake Weight , Deliver Date,Session & Deliver Type.!'),
                                                behavior: SnackBarBehavior.floating,
                                                // backgroundColor: Colors.red[300],
                                                duration: Duration(minutes: 1),
                                                action: SnackBarAction(
                                                  textColor: Colors.red,
                                                  onPressed: (){
                                                  },
                                                  label: 'Close',
                                                ),
                                              )
                                          );

                                        }
                                        else if(deliverAddress.isEmpty||deliverAddress=="null"||deliverAddress==null){
                                          ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('Please Change Your Address!'),
                                                behavior: SnackBarBehavior.floating,
                                                // backgroundColor: Colors.red[300],
                                                duration: Duration(minutes: 1),
                                                action: SnackBarAction(
                                                  textColor: Colors.red,
                                                  onPressed: (){
                                                  },
                                                  label: 'Close',
                                                ),
                                              )
                                          );
                                        }
                                        else{
                                          setState((){
                                            vendorName = mySelectdVendors[0]['VendorName'];
                                            vendorID = mySelectdVendors[0]['VendorId'];
                                            vendorPhone = mySelectdVendors[0]['VendorPhone'];
                                            vendorModId = mySelectdVendors[0]['VendorModId'];
                                            vendorAddress = mySelectdVendors[0]['VendorAddress'];

                                            print(vendorName + vendorID + vendorPhone + vendorModId + vendorAddress);
                                          });
                                          showConfirmOrder();
                                        }

                                      }else{
                                        if(fixedWeight.isEmpty||fixedDelliverMethod.isEmpty||
                                            fixedDate=="Not Yet Select"||fixedSession=="Not Yet Select"){

                                          ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('Please Select : Cake Weight , Deliver Date,Session & Deliver Type.!'),
                                                behavior: SnackBarBehavior.floating,
                                                // backgroundColor: Colors.red[300],
                                                duration: Duration(minutes: 1),
                                                action: SnackBarAction(
                                                  textColor: Colors.red,
                                                  onPressed: (){
                                                  },
                                                  label: 'Close',
                                                ),
                                              )
                                          );

                                        }
                                        // else if(selVendorIndex==-1){
                                        //
                                        //   ScaffoldMessenger.of(context).showSnackBar(
                                        //       SnackBar(
                                        //         content: Text('Please Select : Vendor!'),
                                        //         behavior: SnackBarBehavior.floating,
                                        //         // backgroundColor: Colors.red[300],
                                        //         // duration: Duration(minutes: 1),
                                        //         action: SnackBarAction(
                                        //           textColor: Colors.red,
                                        //           onPressed: (){
                                        //           },
                                        //           label: 'Close',
                                        //         ),
                                        //       )
                                        //   );
                                        //
                                        // }
                                        else if(deliverAddress.isEmpty||deliverAddress=="null"||deliverAddress==null){
                                          ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('Please Change Your Address!'),
                                                behavior: SnackBarBehavior.floating,
                                                // backgroundColor: Colors.red[300],
                                                duration: Duration(minutes: 1),
                                                action: SnackBarAction(
                                                  textColor: Colors.red,
                                                  onPressed: (){
                                                  },
                                                  label: 'Close',
                                                ),
                                              )
                                          );
                                        }
                                        else{
                                          showConfirmOrder();
                                        }
                                      }

                                    }



                                    // nearestVendors[0].addEntries([
                                    //   MapEntry('latitude', "000.000"),
                                    //   MapEntry('longitude', "111.000"),
                                    // ]);

                                    // print(nearestVendors[0]);

                                  },
                                  color: lightPink,
                                  child: Text("ORDER NOW",style: TextStyle(
                                      color: Colors.white,fontWeight: FontWeight.bold
                                  ),),
                                ),
                              ),
                            ),
                            SizedBox(height: 15,),
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
