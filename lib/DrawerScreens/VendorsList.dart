import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:cakey/screens/SingleVendor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:geocoding/geocoding.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../ContextData.dart';
import '../Dialogs.dart';
import '../drawermenu/NavDrawer.dart';
import '../drawermenu/app_bar.dart';
import '../screens/Profile.dart';
import 'package:http/http.dart' as http;
import 'CakeTypes.dart';
import 'HomeScreen.dart';
import 'Notifications.dart';
import 'package:google_maps_webservice/places.dart' as wbservice;

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

  int notiCount = 0;

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

      var res = await http.get(Uri.parse("http://sugitechnologies.com/cakey/api/activevendors/list"),
          headers: {"Authorization":"$authToken"}
      );

      if(res.statusCode==200){
        if(cakeTypeFromCD!="null"){
          setState(() {
            List venList = jsonDecode(res.body);

            List temp = [];

            List ctypesList = cakeList.where((element) => element['CakeName'].toString().toLowerCase()
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
            locationBySearch = temp.where((element) =>
            calculateDistance(double.parse(userLatitude), double.parse(userLongtitude),
                element['GoogleLocation']['Latitude'],element['GoogleLocation']['Longitude'])<=10
            ).toList();
            locationBySearch = locationBySearch.toSet().toList();

            locationBySearch.sort((a,b)=>calculateDistance(
                double.parse(userLatitude), double.parse(userLongtitude),
                a['GoogleLocation']['Latitude'],
                a['GoogleLocation']['Longitude']).toStringAsFixed(1).compareTo(calculateDistance(
                double.parse(userLatitude), double.parse(userLongtitude),
                b['GoogleLocation']['Latitude'],
                b['GoogleLocation']['Longitude']).toStringAsFixed(1)));

            Navigator.pop(context);

          });
        }else{
          setState(() {
            nearestVendors = jsonDecode(res.body);

            print(nearestVendors.length);

            locationBySearch = nearestVendors.where((element) =>
            calculateDistance(double.parse(userLatitude), double.parse(userLongtitude),
                element['GoogleLocation']['Latitude'],element['GoogleLocation']['Longitude'])<=10
            ).toList();


            locationBySearch.sort((a,b)=>calculateDistance(
                double.parse(userLatitude), double.parse(userLongtitude),
                a['GoogleLocation']['Latitude'],
                a['GoogleLocation']['Longitude']).toStringAsFixed(1).compareTo(calculateDistance(
                double.parse(userLatitude), double.parse(userLongtitude),
                b['GoogleLocation']['Latitude'],
                b['GoogleLocation']['Longitude']).toStringAsFixed(1)));

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
      // ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(content: Text('Error Occurred'),
      //       backgroundColor: Colors.amber,
      //       duration: Duration(seconds: 5),
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

  //getCakesList
  Future<void> getCakeList() async{
    try{
      print("enter");
      var res = await http.get(
          Uri.parse('http://sugitechnologies.com/cakey/api/cake/list'),
          headers: {"Authorization": "$authToken"});

      if (res.statusCode == 200) {
        print(res.body);

        if(res.body.length<50){

        }else{
          setState(() {
            myCakeList = jsonDecode(res.body);
            cakeList = myCakeList
                .where((element) =>
                element['CakeName'].toString().toLowerCase().contains(cakeTypeFromCD.toLowerCase().toString()))
                .toList();
            print(cakeList.length);
          });
        }

      } else {

      }
    }catch(e){
      
    }

    getVendorsList();
  }

  //load select Vendor data to CakeTypeScreen
  Future<void> loadSelVendorDataToCTscreen(int index,[String amount="0.0", String km = "0.0"]) async{
    print(index);

    var pref = await SharedPreferences.getInstance();

    pref.remove('firstVenDelCharge');
    pref.remove('firstVenIndex');

    if(index == 0 && double.parse(km)<2.0 || index == 1 && double.parse(km)<2.0){
      amount = "0.0";
      pref.setString('firstVenDelCharge', amount ?? 'null');
      pref.setString('firstVenIndex', index.toString() ?? 'null');
    }else{
      pref.setString('firstVenDelCharge', amount ?? 'null');
      pref.setString('firstVenIndex', "2" ?? 'null');
    }

    pref.setString('myVendorId', locationBySearch[index]['_id']);
    pref.setStringList('activeVendorsIds',[locationBySearch[index]['_id'].toString()]);
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
    context.read<ContextData>().setMyVendors([
      locationBySearch[index]
    ]);

   Navigator.push(context,MaterialPageRoute(builder: (context)=>CakeTypes()));

  }

  Future<void> sendDataToScreen(int index,[String amount="0.0", String km = "0.0"]) async{

    var pref = await SharedPreferences.getInstance();

    print(amount);
    print(km);

    pref.remove('singleVendorID');
    pref.remove('firstVenDelCharge');
    pref.remove('firstVenIndex');
    pref.remove('singleVendorFromCd');
    pref.remove('singleVendorRate');
    pref.remove('singleVendorName');
    pref.remove('singleVendorDesc');
    pref.remove('singleVendorPhone1');
    pref.remove('singleVendorPhone2');
    pref.remove('singleVendorDpImage');
    pref.remove('singleVendorAddress');
    pref.remove('singleVendorSpeciality');

    //store 1st two vendor deliver charge
    if(index == 0 && double.parse(km)<2.0 || index == 1 && double.parse(km)<2.0){
      amount = "0.0";
      pref.setString('firstVenDelCharge', amount ?? 'null');
      pref.setString('firstVenIndex', index.toString() ?? 'null');
    }else{
      pref.setString('firstVenDelCharge', amount ?? 'null');
      pref.setString('firstVenIndex', "2" ?? 'null');
    }

    //common keyword single****
    pref.setString('singleVendorID', locationBySearch[index]['_id'] ?? 'null');
    pref.setBool('singleVendorFromCd', false);
    pref.setString('singleVendorRate',
        locationBySearch[index]['Ratings'].toString() ?? '0.0');
    pref.setString('singleVendorName',
        locationBySearch[index]['PreferredNameOnTheApp'] ?? 'null');
    pref.setString(
        'singleVendorDesc', locationBySearch[index]['Description'] ?? 'null');
    pref.setString(
        'singleVendorPhone1', locationBySearch[index]['PhoneNumber1'] ?? 'null');
    pref.setString(
        'singleVendorPhone2', locationBySearch[index]['PhoneNumber2'] ?? 'null');
    pref.setString(
        'singleVendorDpImage', locationBySearch[index]['ProfileImage'] ?? 'null');
    pref.setString(
        'singleVendorAddress', locationBySearch[index]['Address'] ?? 'null');
    pref.setString('singleVendorSpecial',
        locationBySearch[index]['YourSpecialityCakes'].toString());

    print(locationBySearch[index]['YourSpecialityCakes']);

    Navigator.push(
        context, MaterialPageRoute(builder: (context) => SingleVendor()));

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

    // if(searchLocation.isNotEmpty){
    //   setState(() {
    //     isSearching = false;
    //     locationBySearch =
    //         vendorsList.where((element) => element['Address'].toString().toLowerCase()
    //             .contains(searchLocation.toLowerCase())).toList();
    //   });
    // }else{
    //   setState(() {
    //     isSearching = true;
    //     locationBySearch = vendorsList.toList();
    //   });
    // }

    profileUrl = context.watch<ContextData>().getProfileUrl();
    notiCount = context.watch<ContextData>().getNotiCount();
    selectedVendor = context.watch<ContextData>().getAddedMyVendor();
    selvendorList = context.watch<ContextData>().getMyVendorsList();
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return WillPopScope(
      onWillPop: () async{
        
        !iamFromCustom?
        Navigator.pop(context):
       // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>HomeScreen())):
        Navigator.pop(context);
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
                          onTap: () async{
                            FocusScope.of(context).unfocus();
                            _scaffoldKey.currentState!.openDrawer();
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
                        Text(iamFromCustom?"Select Vendors":"VENDORS",
                            style: TextStyle(color: darkBlue,fontWeight: FontWeight.bold,fontFamily: poppins,
                                fontSize: 16
                            )),
                      ],
                    ),

                    iamFromCustom?
                    Container():
                    CustomAppBars().CustomAppBar(context, "", notiCount, profileUrl)
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
                            Icon(Icons.location_on,color: Colors.red,size: 18,),
                            SizedBox(width: 3,),
                            Text('Delivery to',style: TextStyle(color: Colors.black54,fontWeight: FontWeight.bold,
                                fontSize: 13,
                                fontFamily: "Poppins"),)
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(left: 8),
                        alignment: Alignment.centerLeft,
                        child: Text('$userCurLocation',maxLines:1,
                          style:TextStyle(fontFamily: "Poppins",fontSize: 13.5,color: darkBlue,fontWeight: FontWeight.bold),),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () async{
                    var pref = await SharedPreferences.getInstance();
                    FocusScope.of(context).unfocus();
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
                      List<Location> location =
                      await locationFromAddress(placeResult!.description.toString());
                      print(location);
                      setState(() {
                        // userLat = location[0].latitude;
                        // userLong = location[0].longitude;
                        // pref.setString("userCurrentLocation", deliverToCtrl.text);
                        userCurLocation = placeResult!.description.toString();
                        userLatitude = location[0].latitude.toString();
                        userLongtitude = location[0].longitude.toString();
                        pref.setString('userLatitute', "$userLatitude");
                        pref.setString('userLongtitude', "$userLongtitude");
                        pref.setString("userCurrentLocation", placeResult!.description.toString());
                        getVendorsList();
                      });
                    }
                  },
                  child: Container(
                    height: 45,
                    margin: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        color: Colors.grey[400]!,
                        width: 1
                      )
                    ),
                    child: Row(
                      children: [
                        SizedBox(width: 5,),
                        Icon(Icons.location_on , color: Colors.grey[400],),
                        SizedBox(width: 5,),
                        Text("Search Location" , style:TextStyle(
                          color: Colors.grey[300],fontFamily: "Poppins",
                          fontWeight: FontWeight.bold,
                          fontSize: 13
                        ))
                      ],
                    ),
                  ),
                ),

                Container(
                  // child: (searchLocation.isEmpty)?
                   /**Search is empty....**/
                  child:Container(
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

                                    var deliverCharge = double.parse("${((adminDeliveryCharge / adminDeliveryChargeKm) *
                                        (calculateDistance(double.parse(userLatitude),
                                            double.parse(userLongtitude), locationBySearch[index]['GoogleLocation']['Latitude'],
                                            locationBySearch[index]['GoogleLocation']['Longitude'])))}").toStringAsFixed(1);
                                    var betweenKm = (calculateDistance(double.parse(userLatitude),
                                        double.parse(userLongtitude),locationBySearch[index]['GoogleLocation']['Latitude'],
                                        locationBySearch[index]['GoogleLocation']['Longitude'])).toStringAsFixed(1);

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
                                          loadSelVendorDataToCTscreen(index , deliverCharge,betweenKm);
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
                                                                  loadSelVendorDataToCTscreen(index , deliverCharge,betweenKm);
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
                                                            index==1&&double.parse(betweenKm)<2.0||index==0&&double.parse(betweenKm)<2.0||
                                                                double.parse(deliverCharge).toStringAsFixed(1)=="0.0"?
                                                            Text('DELIVERY FREE',style: TextStyle(
                                                                color: Colors.orange,fontSize: 10,fontFamily: poppins
                                                            ),):
                                                            Text('${betweenKm} KM Delivery Fee Rs.${deliverCharge}'
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
                                                                    loadSelVendorDataToCTscreen(index , deliverCharge,betweenKm);
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
                  )
                )
              ],
            ),
          )
      ),
    );
  }
}


