import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:cakey/screens/SingleVendor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../ContextData.dart';
import '../Dialogs.dart';
import '../drawermenu/NavDrawer.dart';
import '../screens/Profile.dart';
import 'package:http/http.dart' as http;
import 'CakeTypes.dart';
import 'HomeScreen.dart';
import 'Notifications.dart';

class VendorsList extends StatefulWidget {
  const VendorsList({Key? key}) : super(key: key);

  @override
  State<VendorsList> createState() => _VendorsListState();
}

class _VendorsListState extends State<VendorsList> {

  //region Variables

  //key
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  DateTime? currentBackPressTime;
  //Colors
  Color lightGrey = Color(0xffF5F5F5);
  Color darkBlue = Color(0xffF213959);
  Color lightPink = Color(0xffFE8416D);

  //Strings
  String poppins = "Poppins";
  String profileUrl = '';
  String userCurLocation = 'Searching...';
  String userMainLocation = '';
  String searchLocation = '';
  String authToken = "";
  String cakeTypeFromCD = "";
  String currentValue='';

  //booleans
  bool isSearching = false;
  int currentIndex = 0;

  //Lists
  List locations = ["Tirupur","Avinashi","Avinashi",'Coimbatore','Neelambur','Thekkalur','Chennai'];
  List locationBySearch = [];
  List nearestVendors = [];
  List vendorsList = [];
  List myCakeList = [];
  List cakeList = [];

  var iamFromCustom = false;
  var selectedVendor = false;
  List selvendorList = [];

  //delivery
  int adminDeliveryCharge = 0;
  int adminDeliveryChargeKm = 0;
  String userLatitude = "";
  String userLongtitude = "";

  TextEditingController searchCtrl = new TextEditingController();

  //endregion

  //region Alerts

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

  //endregion

  //region Functions

  //load initial prefs
  Future<void> loadPrefs() async{
    var pref = await SharedPreferences.getInstance();
    setState(() {

      userLatitude = pref.getString('userLatitute')??'Not Found';
      userLongtitude = pref.getString('userLongtitude')??'Not Found';
      //delivery charge
      adminDeliveryCharge = pref.getInt("todayDeliveryCharge")??0;
      adminDeliveryChargeKm = pref.getInt("todayDeliveryKm")??0;

      iamFromCustom = pref.getBool('iamFromCustomise')??false;
      userCurLocation = pref.getString('userCurrentLocation')??'Not Found';
      cakeTypeFromCD = pref.getString('passCakeType')??'null';
      userMainLocation = pref.getString('userMainLocation')??'Not Found';
      authToken = pref.getString("authToken")?? 'no auth';

      getCakeList();

      print(userLatitude+"  "+userLongtitude);

    });
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

  //geting the vendors list
  Future<void> getVendorsList() async{

    nearestVendors.clear();
    vendorsList.clear();
    showAlertDialog();

    try{

      var res = await http.get(Uri.parse("https://cakey-database.vercel.app/api/vendors/list"),
          headers: {"Authorization":"$authToken"}
      );

      if(res.statusCode==200){
        if(cakeTypeFromCD!="null"){
          setState(() {
            List venList = jsonDecode(res.body);

            List temp = [];

            List ctypesList = cakeList.where((element) => element['CakeType'].toString().toLowerCase()
                ==cakeTypeFromCD.toLowerCase()).toList();

            print(ctypesList);

            print(ctypesList.length);

            for(int i = 0 ; i<ctypesList.length;i++){
              print(ctypesList[i]['VendorID']);

              temp = temp + venList.where((element) =>
              element['_id'].toString().toLowerCase()==ctypesList[i]['VendorID'].toString().toLowerCase()
              ).toList();

            }

            vendorsList = temp;
            vendorsList = temp.where((element) =>
            calculateDistance(double.parse(userLatitude), double.parse(userLongtitude),
                element['GoogleLocation']['Latitude'],element['GoogleLocation']['Longitude'])<=10
            ).toList();
            vendorsList = vendorsList.toSet().toList();

            Navigator.pop(context);

          });
        }else{
          setState(() {
            nearestVendors = jsonDecode(res.body);

            print(nearestVendors.length);

            vendorsList = nearestVendors.where((element) =>
            calculateDistance(double.parse(userLatitude), double.parse(userLongtitude),
                element['GoogleLocation']['Latitude'],element['GoogleLocation']['Longitude'])<=10
            ).toList();

            Navigator.pop(context);
          });
        }

      }else{
        checkNetwork();
        Navigator.pop(context);
      }

    }catch(e){
      print(e);
      Navigator.pop(context);
      checkNetwork();
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error Occurred'),
            backgroundColor: Colors.amber,
            duration: Duration(seconds: 5),
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

  //getCakesList
  Future<void> getCakeList() async{

    print("enter");
    var res = await http.get(
        Uri.parse('https://cakey-database.vercel.app/api/cake/list'),
        headers: {"Authorization": "$authToken"});

    if (res.statusCode == 200) {
      print(res.body);

      if(res.body.length<50){

      }else{
        setState(() {
          myCakeList = jsonDecode(res.body);
          cakeList = myCakeList
              .where((element) =>
              element['CakeType'].toString().toLowerCase().contains(cakeTypeFromCD.toLowerCase().toString()))
              .toList();
          print(cakeList.length);
          getVendorsList();
        });
      }

    } else {

    }
  }

  //load select Vendor data to CakeTypeScreen
  Future<void> loadSelVendorDataToCTscreen(int index) async{

    var pref = await SharedPreferences.getInstance();

    pref.setString('myVendorId', locationBySearch[index]['_id']);
    pref.setBool('iamYourVendor', true);
    pref.setString('myVendorName', locationBySearch[index]['VendorName']);
    pref.setString('myVendorPhone1', locationBySearch[index]['PhoneNumber1']??'null');
    pref.setString('myVendorPhone2', locationBySearch[index]['PhoneNumber2']??'null');
    pref.setString('myVendorDesc', locationBySearch[index]['Description']??'null');
    pref.setString('myVendorProfile',locationBySearch[index]['ProfileImage']??'null');
    pref.setString('myVendorDeliverChrg', locationBySearch[index]['DeliveryCharge']??'null');
    pref.setString('myVendorEggs', locationBySearch[index]['EggOrEggless']??'null');
    pref.setString('myVendorAddress',locationBySearch[index]['Address']??'null');
    pref.setBool('vendorCakeMode',true);

    context.read<ContextData>().addMyVendor(true);
    context.read<ContextData>().setMyVendors(
        [
          {
            "VendorId":locationBySearch[index]['_id'],
            "VendorModId":locationBySearch[index]['Id'],
            "VendorName":locationBySearch[index]['VendorName'],
            "VendorDesc":locationBySearch[index]['Description'],
            "VendorProfile":locationBySearch[index]['ProfileImage'],
            "VendorPhone":locationBySearch[index]['PhoneNumber1'],
            "VendorDelCharge":locationBySearch[index]['DeliveryCharge'],
            "VendorEgg":locationBySearch[index]['EggOrEggless'],
            "VendorAddress":locationBySearch[index]['Address'],
          }
        ]
    );

    print(locationBySearch[index]['VendorName']);
    print(locationBySearch[index]['Address']);
    print(locationBySearch[index]['_id']);
    print(locationBySearch[index]['Id']);
    print(locationBySearch[index]['Description']);
    print(locationBySearch[index]['ProfileImage']);
    print(locationBySearch[index]['PhoneNumber1']);
    print(locationBySearch[index]['DeliveryCharge']);
    print(locationBySearch[index]['EggOrEggless']);


   Navigator.push(context,MaterialPageRoute(builder: (context)=>CakeTypes()));

  }


  //send nearest vendor details.
  Future<void> sendNearVendorDataToScreen(int index) async{

    String address = "${nearestVendors[index]['Address']['Street']} , "
        "${nearestVendors[index]['Address']['City']} , "
        "${nearestVendors[index]['Address']['District']} , "
        "${nearestVendors[index]['Address']['Pincode']} , ";


    var pref = await SharedPreferences.getInstance();

    //common keyword single****
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
    pref.setString('singleVendorID', nearestVendors[index]['_id']??'null');
    pref.setBool('singleVendorFromCd', true);
    pref.setString('singleVendorRate', nearestVendors[index]['Ratings'].toString()??'null');
    pref.setString('singleVendorName', nearestVendors[index]['VendorName']??'null');
    pref.setString('singleVendorDesc', nearestVendors[index]['Description']??'null');
    pref.setString('singleVendorPhone1', nearestVendors[index]['PhoneNumber1']??'null');
    pref.setString('singleVendorPhone2', nearestVendors[index]['PhoneNumber2']??'null');
    pref.setString('singleVendorDpImage', nearestVendors[index]['ProfileImage']??'null');
    pref.setString('singleVendorAddress', nearestVendors[index]['Address']['FullAddress']??'null');
    pref.setString('singleVendorSpeciality', nearestVendors[index]['YourSpecialityCakes'].toString()??'null');

    Navigator.push(context, MaterialPageRoute(builder: (context)=>SingleVendor()));
  }


  Future<void> sendDataToScreen(int index) async{

    String address = "${locationBySearch[index]['Address']}";

    var pref = await SharedPreferences.getInstance();

    //common keyword single****
    pref.setString('singleVendorID', locationBySearch[index]['_id']);
    pref.setString('singleVendorName', locationBySearch[index]['PreferredNameOnTheApp']??
        '${locationBySearch[index]['VendorName']}');
    pref.setString('singleVendorDesc', locationBySearch[index]['Description']??'No Description');
    pref.setString('singleVendorPhone', locationBySearch[index]['PhoneNumber']??'0000000000');
    pref.setString('singleVendorDpImage', locationBySearch[index]['ProfileImage']??'null');
    pref.setString('singleVendorDelivery', locationBySearch[index]['DeliveryCharge']??'null');
    pref.setString('singleVendorEggs', locationBySearch[index]['EggOrEggless']??'null');
    pref.setString('singleVendorAddress', address??'null');
    pref.setString('singleVendorSpecial', locationBySearch[index]['YourSpecialityCakes'].toString());
    pref.setString('singleVendorRate', locationBySearch[index]['Ratings'].toString()??'null');
    pref.setString('ventosingleven', 'yes');

    print(locationBySearch[index]['YourSpecialityCakes']);

    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => SingleVendor(),
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

    // Navigator.push(context, MaterialPageRoute(builder: (context)=>SingleVendor()));

  }

  //endregion


  @override
  void dispose() {
    // TODO: implement dispose
    Future.delayed(Duration.zero,() async{
      var prefs = await SharedPreferences.getInstance();
      prefs.remove('iamFromCustomise');
      prefs.remove('passCakeType');
    });
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    Future.delayed(Duration.zero , () async{
      loadPrefs();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    if(searchLocation.isNotEmpty){
      setState(() {
        isSearching = false;
        locationBySearch =
            vendorsList.where((element) => element['Address'].toString().toLowerCase()
                .contains(searchLocation.toLowerCase())).toList();
      });
    }else{
      setState(() {
        isSearching = true;
        locationBySearch = vendorsList.toList();
      });
    }

    profileUrl = context.watch<ContextData>().getProfileUrl();
    selectedVendor = context.watch<ContextData>().getAddedMyVendor();
    selvendorList = context.watch<ContextData>().getMyVendorsList();
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return WillPopScope(
      onWillPop: () async{
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>HomeScreen()));
        //Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>HomeScreen()));
        return Future.value(true);
      },
      child: Scaffold(
          key: _scaffoldKey,
          drawer: NavDrawer(screenName: "vendor",),
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
                        iamFromCustom?
                        Container(
                          // margin: const EdgeInsets.only(top: 10,bottom: 15),
                          child: InkWell(
                            onTap: (){
                              Navigator.pop(context);
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
                        ):
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
                        Text(iamFromCustom?"Select Vendors":"VENDORS",
                            style: TextStyle(color: darkBlue,fontWeight: FontWeight.bold,fontFamily: poppins,
                                fontSize: 16
                            )),
                      ],
                    ),

                    iamFromCustom?
                    Container():
                    Row(
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.of(context).push(
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation, secondaryAnimation) => Notifications(),
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
                        SizedBox(width: 10,),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(blurRadius: 3, color: Colors.black, spreadRadius: 0)],
                          ),
                          child: InkWell(
                            onTap: (){

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
                              radius: 14.7,
                              backgroundColor: Colors.white,
                              child: CircleAvatar(
                                  radius: 13,
                                  backgroundImage:NetworkImage("$profileUrl")
                              ),
                            ):CircleAvatar(
                              radius: 14.7,
                              backgroundColor: Colors.white,
                              child: CircleAvatar(
                                  radius: 13,
                                  backgroundImage:AssetImage("assets/images/user.png")
                              ),
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
          body: SingleChildScrollView(
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
                            Text('Delivery to',style: TextStyle(color: Colors.black54,fontWeight: FontWeight.bold,
                                fontSize: 13,
                                fontFamily: "Poppins"),)
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
                //Search bar...
                Container(
                  margin: EdgeInsets.all(10),
                  height: 50,
                  child: TextField(
                    style:TextStyle(fontFamily: "Poppins" , fontSize: 13),
                    controller: searchCtrl,
                    onChanged: (String? text){
                      setState(() {
                        searchLocation = text!;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: "Search location",
                      hintStyle: TextStyle(fontFamily: "Poppins" , fontSize: 13 ),
                      prefixIcon: Icon(Icons.location_on),
                      suffixIcon:IconButton(
                        onPressed: (){
                          FocusScope.of(context).unfocus();
                          setState(() {
                            searchLocation = "";
                            searchCtrl = new TextEditingController(text: "");
                          });
                        },
                        icon: Icon(Icons.close,size: 20,),
                      ),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5)
                      ),
                      contentPadding: EdgeInsets.all(5),
                    ),
                  ),
                ),

                Container(
                  child: (searchLocation.isEmpty)?
                   /**Search is empty....**/
                  Container(
                    height: height*0.71,
                    child: RefreshIndicator(
                      onRefresh: () async{
                        setState(() {
                          loadPrefs();
                        });
                      },
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            //Other vendor title...
                            Padding(
                                padding: const EdgeInsets.all(10),
                                child:Text("10 Km Radius",
                                  style: TextStyle(color: Colors.grey,fontSize: 12.5,fontFamily: "Poppins",fontWeight: FontWeight.bold),)
                            ),

                            //Other vendors list....
                            Container(
                              padding: EdgeInsets.only(bottom: 8),
                              child: ListView.builder(
                                  itemCount: locationBySearch.length,
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemBuilder: (context,index){
                                    return GestureDetector(
                                      onTap: (){
                                        if(iamFromCustom==true){
                                          context.read<ContextData>().addMyVendor(true);
                                          context.read<ContextData>().setMyVendors([locationBySearch[index]]);
                                          Navigator.pop(context);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content:Text('Selected Vendor : ${locationBySearch[index]
                                              ['VendorName']}'))
                                          );
                                        }else{
                                          sendDataToScreen(index);
                                        }

                                        print(locationBySearch[index]['PreferredNameOnTheApp']);

                                      },
                                      child: Card(
                                        margin: EdgeInsets.only(left: 10,right: 10,top: 10,bottom: 5),
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(15)
                                        ),
                                        child: Container(
                                          // margin: EdgeInsets.all(5),
                                          padding: EdgeInsets.all(6),
                                          height: 130,
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(15)
                                          ),
                                          child: Row(
                                            children: [
                                              locationBySearch[index]['ProfileImage']!=null?
                                              Container(
                                                height: 120,
                                                width: 90,
                                                decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(15),
                                                    image: DecorationImage(
                                                        fit: BoxFit.cover,
                                                        image: NetworkImage('${locationBySearch[index]['ProfileImage']}')
                                                    )
                                                ),
                                              ):
                                              Container(
                                                height: 120,
                                                width: 90,
                                                decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(15),
                                                    image: DecorationImage(
                                                        fit: BoxFit.cover,
                                                        image: AssetImage('assets/images/vendorimage.jpeg')
                                                    )
                                                ),
                                              ),
                                              SizedBox(width: 8,),
                                              Expanded(
                                                child: Container(
                                                  // padding: EdgeInsets.all(8),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Container(
                                                        // width:width*0.63,
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                Container(
                                                                  // width:width*0.5,
                                                                  child: Text(locationBySearch[index]['PreferredNameOnTheApp'].toString().isEmpty||
                                                                      locationBySearch[index]['PreferredNameOnTheApp']==null
                                                                      ?
                                                                  '${locationBySearch[index]['VendorName'][0].toString().toUpperCase()+
                                                                      locationBySearch[index]['VendorName'].toString().substring(1).toLowerCase()
                                                                  }'
                                                                      :'${locationBySearch[index]['PreferredNameOnTheApp'][0].toString().toUpperCase()+
                                                                      locationBySearch[index]['PreferredNameOnTheApp'].toString().substring(1).toLowerCase()
                                                                  }'
                                                                    ,overflow: TextOverflow.ellipsis,style: TextStyle(
                                                                        color: darkBlue,fontWeight: FontWeight.bold,fontSize: 14,fontFamily: poppins
                                                                    ),),
                                                                ),
                                                                Row(
                                                                  children: [
                                                                    RatingBar.builder(
                                                                      initialRating: double.parse(locationBySearch[index]['Ratings'].toString()),
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
                                                                    Text(' ${double.parse(locationBySearch[index]['Ratings'].toString())}',style: TextStyle(
                                                                        color: Colors.black54,fontWeight: FontWeight.bold,fontSize: 13,fontFamily: poppins
                                                                    ),)
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                            InkWell(
                                                              onTap: (){
                                                                if(iamFromCustom==true){
                                                                  context.read<ContextData>().addMyVendor(true);
                                                                  context.read<ContextData>().setMyVendors([locationBySearch[index]]);
                                                                  Navigator.pop(context);
                                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                                      SnackBar(content:Text('Selected Vendor : ${locationBySearch[index]
                                                                      ['VendorName']}'))
                                                                  );

                                                                }else{
                                                                  sendDataToScreen(index);
                                                                }
                                                              },
                                                              child: Container(
                                                                decoration: BoxDecoration(
                                                                    color: lightGrey,
                                                                    shape: BoxShape.circle
                                                                ),
                                                                padding: EdgeInsets.all(4),
                                                                height: 35,
                                                                width: 35,
                                                                child: Icon(Icons.keyboard_arrow_right,color: lightPink,),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      SizedBox(height: 4,),
                                                      Container(
                                                        // width: width*0.63,
                                                        child: Text("Speciality in "+locationBySearch[index]['YourSpecialityCakes'].toString().
                                                        replaceAll("[", "").replaceAll("]", "")
                                                          ,overflow: TextOverflow.ellipsis,style: TextStyle(
                                                              color: Colors.black54,fontFamily: poppins,fontSize: 13
                                                          ),maxLines: 1,),
                                                      ),
                                                      SizedBox(height: 4,),
                                                      Container(
                                                        height: 1,
                                                        // width: width*0.63,
                                                        color: Color(0xffeeeeee)
                                                      ),
                                                      SizedBox(height: 4,),
                                                      Container(
                                                        // width: width*0.63,
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            //index==0?
                                                            // Text('DELIVERY FREE',style: TextStyle(
                                                            //     color: Colors.orange,fontSize: 10,fontFamily: poppins
                                                            // ),):
                                                            Text('${
                                                                (calculateDistance(double.parse(userLatitude),
                                                                    double.parse(userLongtitude),
                                                                    locationBySearch[index]['GoogleLocation']['Latitude'],
                                                                    locationBySearch[index]['GoogleLocation']['Longitude'])).toInt()
                                                            } KM Delivery Fee Rs.${
                                                                (adminDeliveryCharge/adminDeliveryChargeKm)*
                                                                    (calculateDistance(double.parse(userLatitude),
                                                                        double.parse(userLongtitude),
                                                                    locationBySearch[index]['GoogleLocation']['Latitude'],
                                                                    locationBySearch[index]['GoogleLocation']['Longitude'])).toInt()
                                                            }'
                                                              ,style: TextStyle(
                                                                  color: darkBlue,fontSize: 10,fontFamily: poppins
                                                              ),),
                                                            // currentIndex==index?
                                                            InkWell(
                                                                onTap: () async{

                                                                  if(iamFromCustom==true){

                                                                    context.read<ContextData>().addMyVendor(true);
                                                                    context.read<ContextData>().setMyVendors([locationBySearch[index]]);

                                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                                        SnackBar(content:Text('Selected Vendor : ${locationBySearch[index]
                                                                        ['VendorName']}'))
                                                                    );

                                                                    Navigator.pop(context);

                                                                  }else{
                                                                    loadSelVendorDataToCTscreen(index);
                                                                  }

                                                                },
                                                                child: Padding(
                                                                  padding: EdgeInsets.all(3),
                                                                  child: Text('Select',style: TextStyle(
                                                                      color: Colors.black,fontSize: 10,fontWeight:
                                                                  FontWeight.bold,fontFamily: poppins,
                                                                      decoration: TextDecoration.underline
                                                                  ),),
                                                                ),
                                                              ),

                                                            // :Icon(Icons.check_circle,color: Colors.green,)
                                                          ],
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                              ),
                            ),

                          ],
                        ),
                      ),
                    ),
                  ):
                  /**Search text not empt....**/
                  Container(
                    height: height*0.71,
                    child: RefreshIndicator(
                      onRefresh: () async{
                        print(height);
                        print(height*0.73);
                        setState(() {
                          loadPrefs();
                        });
                      },
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            //Other vendor title...
                            Padding(
                                padding: const EdgeInsets.all(10),
                                child:Text("Search Result : ${searchLocation}",
                                  style: TextStyle(color: Colors.grey,fontSize: 12,fontFamily: "Poppins",fontWeight: FontWeight.bold),
                                )
                            ),
                            //Other vendors list....
                            Container(
                              padding: EdgeInsets.only(bottom: 8),
                              child: ListView.builder(
                                  itemCount: locationBySearch.length,
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemBuilder: (context,index){
                                    return GestureDetector(
                                      onTap: (){
                                        if(iamFromCustom==true){

                                          context.read<ContextData>().addMyVendor(true);
                                          context.read<ContextData>().setMyVendors([locationBySearch[index]]);

                                          ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content:Text('Selected Vendor : ${locationBySearch[index]
                                              ['VendorName']}'))
                                          );

                                        }else{
                                          sendDataToScreen(index);
                                        }
                                        },
                                      child: Card(
                                        margin: EdgeInsets.only(left: 10,right: 10,top: 10,bottom: 5),
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(15)
                                        ),
                                        child: Container(
                                          // margin: EdgeInsets.all(5),
                                          padding: EdgeInsets.all(6),
                                          height: 130,
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(15)
                                          ),
                                          child: Row(
                                            children: [
                                              locationBySearch[index]['ProfileImage']!=null?
                                              Container(
                                                height: 120,
                                                width: 90,
                                                decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(15),
                                                    image: DecorationImage(
                                                        fit: BoxFit.cover,
                                                        image: NetworkImage('${locationBySearch[index]['ProfileImage']}')
                                                    )
                                                ),
                                              ):
                                              Container(
                                                height: 120,
                                                width: 90,
                                                decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(15),
                                                    image: DecorationImage(
                                                        fit: BoxFit.cover,
                                                        image: AssetImage('assets/images/vendorimage.jpeg')
                                                    )
                                                ),
                                              ),
                                              SizedBox(width: 8,),
                                              Expanded(
                                                child: Container(
                                                  // padding: EdgeInsets.all(8),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                    children: [
                                                      Container(
                                                        // width:width*0.63,
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                Container(
                                                                  // width:width*0.5,
                                                                  child: Text(locationBySearch[index]['VendorName'].toString().isEmpty||
                                                                      locationBySearch[index]['VendorName']==null
                                                                      ?
                                                                  'Un name':'${locationBySearch[index]['VendorName'][0].toString().toUpperCase()+
                                                                      locationBySearch[index]['VendorName'].toString().substring(1).toLowerCase()
                                                                  }'
                                                                    ,overflow: TextOverflow.ellipsis,style: TextStyle(
                                                                        color: darkBlue,fontWeight: FontWeight.bold,fontSize: 14,fontFamily: poppins
                                                                    ),),
                                                                ),
                                                                Row(
                                                                  children: [
                                                                    RatingBar.builder(
                                                                      initialRating:double.parse(locationBySearch[index]['Ratings'].toString()),
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
                                                                    Text(' ${double.parse(locationBySearch[index]['Ratings'].toString())}',style: TextStyle(
                                                                        color: Colors.black54,fontWeight: FontWeight.bold,fontSize: 13,fontFamily: poppins
                                                                    ),)
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                            (locationBySearch[index]['_id']==currentValue)?
                                                            Container(
                                                                margin: EdgeInsets.only(right: 10),
                                                                alignment: Alignment.center,
                                                                height: 20,
                                                                width: 20,
                                                                decoration: BoxDecoration(
                                                                    color:Colors.green,
                                                                    shape: BoxShape.circle
                                                                ),
                                                                child:Icon(Icons.done_sharp , color:Colors.white , size: 12,)
                                                            )
                                                                : TextButton(
                                                              onPressed: () async{
                                                                setState(() {
                                                                  // selectVendor = true;
                                                                  // currentIndex = index;
                                                                  currentValue = locationBySearch[index]['_id'];
                                                                  print('indexx value... $currentIndex');
                                                                  if(iamFromCustom==true){

                                                                    context.read<ContextData>().addMyVendor(true);
                                                                    context.read<ContextData>().setMyVendors(
                                                                        [locationBySearch[index]]
                                                                    );

                                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                                        SnackBar(content:Text('Selected Vendor : ${locationBySearch[index]
                                                                        ['VendorName']}'))
                                                                    );
                                                                  }
                                                                  print(locationBySearch[index]['_id']);
                                                                  loadSelVendorDataToCTscreen(index);
                                                                });
                                                              },
                                                              child:Text('Select',style: TextStyle(
                                                                  color: Colors.black,fontSize: 10,fontWeight:
                                                              FontWeight.bold,fontFamily: poppins,
                                                                  decoration: TextDecoration.underline
                                                              ),),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                      Container(
                                                        // width: width*0.63,
                                                        child: Text("Speciality in "+nearestVendors[index]['YourSpecialityCakes'].toString().
                                                        replaceAll("[", "").replaceAll("]", "")
                                                          ,overflow: TextOverflow.ellipsis,style: TextStyle(
                                                              color: Colors.black54,fontFamily: poppins,fontSize: 13
                                                          ),maxLines: 1,),
                                                      ),
                                                      Container(
                                                        height: 1,
                                                        // width: width*0.63,
                                                        color: Color(0xffeeeeee),
                                                      ),
                                                      Container(
                                                        // width: width*0.63,
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            index==0?
                                                            Text('DELIVERY FREE',style: TextStyle(
                                                                color: Colors.orange,fontSize: 10,fontFamily: poppins
                                                            ),):Text('${
                                                                (calculateDistance(double.parse(userLatitude),
                                                                    double.parse(userLongtitude),
                                                                    locationBySearch[index]['GoogleLocation']['Latitude'],
                                                                    locationBySearch[index]['GoogleLocation']['Longitude'])).toInt()
                                                            } KM Delivery Fee Rs.${
                                                                (adminDeliveryCharge/adminDeliveryChargeKm)*
                                                                    (calculateDistance(double.parse(userLatitude),
                                                                        double.parse(userLongtitude),
                                                                        locationBySearch[index]['GoogleLocation']['Latitude'],
                                                                        locationBySearch[index]['GoogleLocation']['Longitude'])).toInt()
                                                            }'
                                                              ,style: TextStyle(
                                                                  color: darkBlue,fontSize: 10,fontFamily: poppins
                                                              ),),
                                                            // currentIndex==index?

                                                            // :Icon(Icons.check_circle,color: Colors.green,)
                                                          ],
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          )
      ),
    );
  }
}


