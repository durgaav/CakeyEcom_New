import 'dart:convert';
import 'dart:math';
import 'package:cakey/OtherProducts/OtherCheckout.dart';
import 'package:cakey/functions.dart';
import 'package:cakey/screens/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../ContextData.dart';
import '../Dialogs.dart';
import '../DrawerScreens/Notifications.dart';
import '../ShowToFarDialog.dart';
import '../screens/AddressScreen.dart';
import '../screens/CakeDetails.dart';
import '../screens/Profile.dart';

class OthersDetails extends StatefulWidget {
  List weight;
  var data = {};
  OthersDetails({required this.weight , required this.data});

  @override
  State<OthersDetails> createState() => _OthersDetailsState(weight: weight,data:data);
}

class _OthersDetailsState extends State<OthersDetails> {
  List weight;
  var data = {};
  _OthersDetailsState({required this.weight , required this.data});

  //colors.....
  String poppins = "Poppins";
  Color darkBlue = Color(0xffF213959);
  Color lightPink = Color(0xffFE8416D);
  Color lightGrey = Color(0xffF5F5F5);

  //string
  String otherSubType = "";
  String otherComName = "";
  String otherName = "";
  String otherType = "";
  String otherEggOr = "";
  String otherMinDel = "";
  String otherBestUse = "";
  String otherStoredIn = "";
  String otherKeepInRoom = "";
  String otherDescrip = "";
  String otherRatings = "";
  String otherVendorAddress = "";
  String otherVenMainId = "";
  String otherVenModId = "";
  String otherVenName = "";
  String otherVenPhn1 = "";
  String otherVenPhn2 = "";
  String selectedDropWeight = "Kg";
  String selectedWeight = "";
  String otherShape = "";
  String otherMainID = "";
  String otherModId = "";
  String otherDiscount = "";
  String minimumDeliTime = "";
  List vendorList = [];

  String vendrorName = "";
  String vendrorEgg = "";
  String vendrorSpecial = "";
  String vendrorLat = "0.0";
  String vendrorLong = "0.0";
  String vendrorRating = "";
  String vendrorPhone1 = "";
  String vendrorPhonr2 = "";
  String vendrorMail= "";
  String vendorProfile = "";
  String vendorId = "";
  String vendor_Id = "";
  String vendorAddress = "";
  String notiId = '';

  //user
  String userId = "";
  String user_ID = "";
  String userName = "";
  String userPhone = "";

  String authToken = "";
  String userLatitude = "0.0";
  String userLongtitude = "0.0";
  String deliveryAddress = "";

  double myPrice = 0.0;
  int counter = 1;

  List<String> cakeImages = [];
  List<String> flavours = [];

  bool tooFar = false;

  String selectedFlav = "";

  var counterCtrl = TextEditingController();

  var picOrDeliver = ['Pickup', 'Delivery'];
  var picOrDel = [true, false];
  var fixedDelliverMethod = "Pickup";
  String deliverDate = "Select delivery date";
  String deliverSession = "Select delivery time";

  int pageViewCurIndex = 0;
  int selectedFlavIndex = 0;
  int selectedWeightIndex = 0;

  var customweightCtrl = new TextEditingController();

  int adminDeliveryCharge = 0;
  int adminDeliveryChargeKm = 0;
  int counts = 1;
  int deliveryCharge = 0;
  int amount = 0;

  List<String> deliverAddress = [];
  var deliverAddressIndex = 0;
  String originalWeight = "";

  //toppers...
  List toppersList = [];
  int topperIndex = -1;
  double topperPrice = 0.0;
  String topperName = "";
  String topperId = "";
  String topperImage = "";

  //Distance calculator
  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  @override
  void initState() {
    //TODO:
    Future.delayed(Duration.zero, () async {
      getDetails();
    });
    super.initState();
  }

  //goto checkout
  Future<void> gotoCheckout() async {
    var prefs = await SharedPreferences.getInstance();
    try{
      prefs.setString("otherOrdName", otherName);
      prefs.setString("otherOrdCommonName", otherComName);
      prefs.setString("otherOrdShape", otherShape);
      prefs.setString("otherOrdMainId", otherMainID);
      prefs.setString("otherOrdModID", otherModId);
      prefs.setString("otherOrdDescrip", otherDescrip);
      prefs.setString("otherOrdImage", cakeImages[0].toString());
      prefs.setString("otherOrdEgg", otherEggOr);

      print("selectedWeight .. $selectedWeight");

      //weight //price
      if (otherType == "Kg") {
        prefs.setString("otherOrdWeight", selectedWeight);
        prefs.setString(
            "otherOrdPrice",
            ((myPrice * changeWeight(selectedWeight)) * counter)
                .toStringAsFixed(2));
        prefs.setString("otherOrdPricePerKg", myPrice.toString());
      } else if (otherType == "Unit") {
        prefs.setString("otherOrdWeight", selectedWeight);
        prefs.setString("otherOrdPrice", (myPrice * counter).toStringAsFixed(2));
        prefs.setString("otherOrdPricePerKg", myPrice.toString());
      } else {
        prefs.setString("otherOrdWeight", selectedWeight);
        prefs.setString("otherOrdPrice", (myPrice * counter).toStringAsFixed(2));
        prefs.setString("otherOrdPricePerKg", myPrice.toString());
      }

      prefs.setString("otherOrdVenName", vendrorName);
      prefs.setString("otherOrdVenMainID", vendor_Id);
      prefs.setString("otherOrdVenModId", vendorId);
      prefs.setString("otherOrdVenAddress", vendorAddress);
      prefs.setString("otherOrdVenPhn1", vendrorPhone1);
      prefs.setString("otherOrdVenPhn2", vendrorPhonr2);
      prefs.setString("otherOrdVenMail", vendrorMail);
      prefs.setString("otherOrdVenLat", vendrorLat);
      prefs.setString("otherOrdVenLong", vendrorLong);
      prefs.setString("otherOrdVenNotiID", notiId);

      prefs.setInt("otherOrdCounter", counter);

      var topperData = {
        "name":topperName,
        "id":topperId,
        "image":topperImage,
        "topperPrice":topperPrice
      };

      prefs.setString("others_topper_data",jsonEncode(topperData));
      prefs.setString("others_original_weight",originalWeight);

      if (fixedDelliverMethod == "Pickup") {
        prefs.setString("otherOrdDeliveryCharge", "0");
      } else {
        prefs.setString(
            "otherOrdDeliveryCharge",
            ((adminDeliveryCharge / adminDeliveryChargeKm) *
                (calculateDistance(
                    double.parse(userLatitude , (e)=>0.0),
                    double.parse(userLongtitude,(e)=>0.0),
                    double.parse(vendrorLat.toString(),(e)=>0.0),
                    double.parse(vendrorLong,(e)=>0.0))))
                .toStringAsFixed(1)
        );
      }

      prefs.setString("otherOrdDeliDate", deliverDate);
      prefs.setString("otherOrdDiscount", otherDiscount);
      prefs.setString("otherOrdPickOrDel", fixedDelliverMethod);
      prefs.setString("otherOrdDeliveryAdrs", deliverAddress[deliverAddressIndex]);
      prefs.setString("otherOrdDeliSession", deliverSession);
      prefs.setString("otherOrdKgType", otherType);
      prefs.setString("otherOrdSubTypee", otherSubType);

      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => OtherCheckout([], [selectedFlav]))
      );
    }catch(e){
       print(e);
    }
  }

  Future<void> getDetails() async {
    var prefs = await SharedPreferences.getInstance();

    setState(() {
      authToken = prefs.getString("authToken") ?? '';
      userLatitude = prefs.getString("userLatitute") ?? '';
      userLongtitude = prefs.getString("userLongtitude") ?? '';
      adminDeliveryCharge = prefs.getInt("todayDeliveryCharge") ?? 0;
      adminDeliveryChargeKm = prefs.getInt("todayDeliveryKm") ?? 0;
      userId = prefs.getString("userID") ?? '';
      user_ID = prefs.getString("userModId") ?? '';
      otherMainID = prefs.getString("otherMainId") ?? '';
      otherModId = prefs.getString("otherModID") ?? '';
      userName = prefs.getString("userName") ?? '';
      userPhone = prefs.getString("phoneNumber") ?? '';
      deliveryAddress = prefs.getString("userCurrentLocation") ?? 'null';
      deliverAddress = prefs.getStringList('addressList')??[deliveryAddress.trim()];
      otherSubType = prefs.getString("otherSubType") ?? "";
      otherComName = prefs.getString("otherComName") ?? "";
      otherName = prefs.getString("otherName") ?? "";
      otherType = prefs.getString("otherType") ?? "";
      otherEggOr = prefs.getString("otherEggOr") ?? "";
      otherMinDel = prefs.getString("otherMinDel") ?? "";
      otherBestUse = prefs.getString("otherBestUse") ?? "";
      otherStoredIn = prefs.getString("otherStoredIn") ?? "";
      otherKeepInRoom = prefs.getString("otherKeepInRoom") ?? "";
      otherDescrip = prefs.getString("otherDescrip") ?? "";
      otherRatings = prefs.getString("otherRatings") ?? "";
      otherVendorAddress = prefs.getString("otherVendorAddress") ?? "";
      otherVenMainId = prefs.getString("otherVenMainId") ?? "";
      otherVenModId = prefs.getString("otherVenModId") ?? "";
      otherVenName = prefs.getString("otherVenName") ?? "";
      otherVenPhn1 = prefs.getString("otherVenPhn1") ?? "";
      otherVenPhn2 = prefs.getString("otherVenPhn2") ?? "";
      vendorId = prefs.getString("otherVendorId") ?? "";
      otherDiscount = prefs.getString("otherDiscound") ?? "";
      otherShape = prefs.getString("otherShape") ?? "";
      minimumDeliTime = prefs.getString("otherMiniDeliTime") ?? "";

      flavours = prefs.getStringList('otherFlavs') ?? [];
      cakeImages = prefs.getStringList('otherImages') ?? [];

      if (flavours.isNotEmpty) {
        selectedFlav = flavours[0].toString();
      } else {
        selectedFlav = "None";
      }

      if (otherType == "Kg") {
        myPrice = double.parse(weight[0]['PricePerKg'].toString());
        selectedWeight = weight[0]['Weight'].toString();
      } else if (otherType == "Unit") {
        myPrice = double.parse(weight[0]['PricePerUnit'].toString());
        selectedWeight =
            changeWeight(weight[0]['Weight'].toString()).toString();
        counter = int.parse(weight[0]['MinCount'].toString());
        if (counter < 10) {
          counterCtrl.text = "0" + counter.toString();
        } else {
          counterCtrl.text = counter.toString();
        }
      } else {
        myPrice = double.parse(weight[0]['PricePerBox'].toString());
        selectedWeight = weight[0]['Piece'].toString();
        counter = int.parse(weight[0]['MinCount'].toString());
        if (counter < 10) {
          counterCtrl.text = "0" + counter.toString();
        } else {
          counterCtrl.text = counter.toString();
        }
      }

      originalWeight = selectedWeight;

    });
    fetchToppersById(vendorId);
    getVendor(vendorId);
  }

  //Default loader dialog
  void showAlertDialog() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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

  //geting vendor
  Future<void> getVendor(String id) async {
    showAlertDialog();
    print(id);

    List forFilter = [];

    try {
      var headers = {'Authorization': '$authToken'};
      var request = http.Request('GET',
          Uri.parse('${API_URL}api/vendors/list'));

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        forFilter = jsonDecode(await response.stream.bytesToString());

        setState(() {
          vendorList = forFilter
              .where((element) =>
                  element['_id'].toString().toLowerCase() ==
                  id.toString().toLowerCase())
              .toList();

          if (vendorList.isNotEmpty) {
            vendrorName = vendorList[0]['VendorName'].toString();
            vendrorEgg = vendorList[0]['EggOrEggless'].toString();
            vendorProfile = vendorList[0]['ProfileImage'].toString();
            vendrorSpecial = vendorList[0]['YourSpecialityCakes']
                .toString()
                .replaceAll("[", "")
                .replaceAll("]", "");
            vendrorLat = vendorList[0]['GoogleLocation']['Latitude'].toString();
            vendrorLong =
                vendorList[0]['GoogleLocation']['Longitude'].toString();
            vendrorRating = vendorList[0]['Ratings'].toString();
            vendrorPhone1 = vendorList[0]['PhoneNumber1'].toString();
            vendrorPhonr2 = vendorList[0]['PhoneNumber2'].toString();
            vendrorMail = vendorList[0]['Email'].toString();
            vendorId = vendorList[0]['Id'].toString();
            notiId = vendorList[0]['Notification_Id'].toString();
            vendor_Id = vendorList[0]['_id'].toString();
            vendorAddress = vendorList[0]['Address'].toString();
            deliveryCharge = ((adminDeliveryCharge / adminDeliveryChargeKm) *
                    (calculateDistance(
                        double.parse(userLatitude),
                        double.parse(userLongtitude),
                        double.parse(vendrorLat.toString()),
                        double.parse(vendrorLong))))
                .toInt();
          }
        });

        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response.reasonPhrase.toString())));
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("error occurred")));
      Navigator.pop(context);
    }
  }

  //Buliding the dots by image length
  List<Widget> _buildPageIndicator() {
    List<Widget> list = [];
    for (int i = 0; i < cakeImages.length; i++) {
      list.add(i == pageViewCurIndex ? _indicator(true) : _indicator(false));
    }
    return list;
  }

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

  //cake topper sheet
  void showCakeTopperSheet(String nam){
    String name = nam,id = "" , image = '';
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

                    Center(
                      child: Container(
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
                            setTheTopperData(price , name , image , id);
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

  void setTheTopperData(price , name , image , id) {

    if(name.isEmpty){
      setState((){
        topperPrice = 0.0;
        topperName = name;
        topperId = id;
        topperImage = image;
      });
    }else{
      setState((){
        topperPrice = double.parse(price.toString());
        topperName = name;
        topperId = id;
        topperImage = image;
      });
    }



  }

  @override
  Widget build(BuildContext context) {
    if (context.watch<ContextData>().getAddressList().isNotEmpty) {
      deliverAddress = context.watch<ContextData>().getAddressList();
    }

    return Scaffold(
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                title: innerBoxIsScrolled
                    ? Text(
                        "$otherName",
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
                                              fit: BoxFit.fill)),
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
            child: Container(
              padding: EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //rate & eggless
                  Container(
                    margin: EdgeInsets.only(top: 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            RatingBar.builder(
                              initialRating:
                                  double.parse(otherRatings, (e) => 1.5),
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
                              child: (otherRatings != null)
                                  ? (otherRatings != 'null')
                                      ? Text(
                                          ' $otherRatings',
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
                                  : Text(otherRatings),
                            )
                          ],
                        ),
                        GestureDetector(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Transform.rotate(
                                angle: 120,
                                child: Icon(
                                  Icons.egg_outlined,
                                  color: otherEggOr.toLowerCase() == "eggless"
                                      ? Colors.green
                                      : Color(0xff8D2729),
                                ),
                              ),
                              Text(
                                '$otherEggOr',
                                style: TextStyle(
                                    color: otherEggOr.toLowerCase() == "eggless"
                                        ? Colors.green
                                        : Color(0xff8D2729),
                                    fontFamily: poppins,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
                      margin: EdgeInsets.symmetric(horizontal: 0),
                      child: Divider(
                        color: Colors.pink[100],
                      )),
                  //name
                  Container(
                    child: Text(
                      '${otherName}',
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
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
                                otherType.toLowerCase() == "kg"
                                    ? Text(
                                        "${((myPrice * changeWeight(selectedWeight)) * counter).toStringAsFixed(2)}",
                                        style: TextStyle(
                                          color: lightPink,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 23,
                                        ),
                                      )
                                    : otherType.toLowerCase() == "unit"
                                        ? Text(
                                            "${(myPrice * counter).toStringAsFixed(2)}",
                                            style: TextStyle(
                                              color: lightPink,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 23,
                                            ),
                                          )
                                        : Text(
                                            "${(myPrice * counter).toStringAsFixed(2)}",
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
                                  if (otherType == "Unit") {
                                    if (counter >
                                        int.parse(weight[selectedWeightIndex]
                                                ['MinCount']
                                            .toString())) {
                                      setState(() {
                                        counter = counter - 1;
                                      });
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                              content: Text(
                                                  "Minimum unit is ${weight[selectedWeightIndex]['MinCount']}!")));
                                    }
                                  } else if (otherType == "Box") {
                                    if (counter >
                                        int.parse(weight[selectedWeightIndex]
                                                ['MinCount']
                                            .toString())) {
                                      setState(() {
                                        counter = counter - 1;
                                      });
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                              content: Text(
                                                  "Minimum unit is ${weight[selectedWeightIndex]['MinCount']}!")));
                                    }
                                  } else {
                                    if (counter > 1) {
                                      setState(() {
                                        counter = counter - 1;
                                        counterCtrl.text = (counter).toString();
                                      });
                                    }
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
                                  // Container(
                                  //   width: 30,
                                  //   child: TextField(
                                  //     keyboardType: TextInputType.number,
                                  //     controller: counterCtrl,
                                  //     style: TextStyle(
                                  //       color: lightPink,
                                  //       fontWeight: FontWeight.bold,
                                  //       fontFamily: "Poppins",
                                  //       fontSize: 20,
                                  //     ),
                                  //     onChanged: (e){
                                  //       setState(() {
                                  //         counter = int.parse(e);
                                  //       });
                                  //     },
                                  //     decoration: InputDecoration(
                                  //       isDense: true,
                                  //       border: InputBorder.none
                                  //     ),
                                  //   ),
                                  // ),
                                  GestureDetector(
                                    onTap: () {
                                      var theCtrl = TextEditingController(
                                        text: "$counter",
                                      );
                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(20)
                                              ),
                                              content: TextField(
                                                keyboardType: TextInputType.number,
                                                controller: theCtrl,
                                                style: TextStyle(
                                                    color: darkBlue,
                                                    fontFamily: "Poppins",
                                                    fontSize: 13
                                                ),
                                                decoration: InputDecoration(
                                                  hintText: "Enter Custom Unit",
                                                ),
                                              ),
                                              actions: [
                                                TextButton(
                                                    onPressed: ()=>Navigator.pop(context),
                                                    child: Text('Cancel',style:TextStyle(
                                                        color: Colors.purple,
                                                        fontFamily: "Poppins",
                                                        fontSize: 13
                                                    ),)
                                                ),
                                                TextButton(
                                                    onPressed: (){
                                                      Navigator.pop(context);
                                                      if (otherType == "Unit") {
                                                        if (int.parse(theCtrl.text) >
                                                            int.parse(weight[selectedWeightIndex]
                                                            ['MinCount']
                                                                .toString())) {
                                                          setState(() {
                                                            counter = int.parse(theCtrl.text);
                                                          });
                                                        } else {
                                                          ScaffoldMessenger.of(context)
                                                              .showSnackBar(SnackBar(
                                                              content: Text(
                                                                  "Minimum unit is ${weight[selectedWeightIndex]['MinCount']}!")));
                                                        }
                                                      } else if (otherType == "Box") {
                                                        if (int.parse(theCtrl.text) >
                                                            int.parse(weight[selectedWeightIndex]
                                                            ['MinCount']
                                                                .toString())) {
                                                          setState(() {
                                                            counter = int.parse(theCtrl.text);
                                                          });
                                                        } else {
                                                          ScaffoldMessenger.of(context)
                                                              .showSnackBar(SnackBar(
                                                              content: Text(
                                                                  "Minimum unit is ${weight[selectedWeightIndex]['MinCount']}!")));
                                                        }
                                                      } else {
                                                        if(theCtrl.text.isNotEmpty){
                                                          setState((){
                                                            counter = int.parse(theCtrl.text);
                                                          });
                                                        }
                                                      }
                                                    },
                                                    child: Text('Ok',style:TextStyle(
                                                        color: Colors.purple,
                                                        fontFamily: "Poppins",
                                                        fontSize: 13
                                                    ),)
                                                ),
                                              ],
                                            );
                                          });
                                    },
                                    child: Text(
                                      counter < 10
                                          ? '0${counter}'
                                          : "${counter}",
                                      style: TextStyle(
                                        color: lightPink,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: "Poppins",
                                        fontSize: 20,
                                      ),
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
                                    counter = counter+1;
                                    counterCtrl.text = counter.toString();
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
                                    child: Icon(Icons.add, color: darkBlue)),
                              ),
                            ])
                          ])),
                  //desc
                  Container(
                      margin: EdgeInsets.all(10),
                      child: ExpandableText(
                        "$otherDescrip",
                        expandText: "",
                        collapseText: "collapse",
                        expandOnTextTap: true,
                        collapseOnTextTap: true,
                        style: TextStyle(
                            color: Colors.grey, fontFamily: "Poppins"),
                      )),
                  Container(
                      margin: EdgeInsets.symmetric(horizontal: 0),
                      child: Divider(
                        color: Colors.pink[100],
                      )),

                  //flav and shape...
                  Text(
                    "Shape",
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 14.5,
                        color: darkBlue,
                        fontWeight: FontWeight.w600),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    "$otherShape",
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 13.5,
                        color: Colors.grey[400],
                        fontWeight: FontWeight.w600),
                  ),

                  SizedBox(
                    height: 5,
                  ),

                  Text(
                    "Flavours",
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 14.5,
                        color: darkBlue,
                        fontWeight: FontWeight.w600),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: flavours.map((e) {
                      return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedFlavIndex = flavours
                                  .indexWhere((element) => element == e);
                              selectedFlav = e;
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.all(7),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                selectedFlavIndex ==
                                        flavours.indexWhere(
                                            (element) => element == e)
                                    ? Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                      )
                                    : Icon(
                                        Icons.radio_button_unchecked,
                                        color: Colors.grey[400],
                                      ),
                                SizedBox(
                                  width: 6,
                                ),
                                Expanded(
                                    child: Text(
                                  e.toString(),
                                  style: TextStyle(
                                      color: Colors.grey[400],
                                      fontFamily: "Poppins"),
                                ))
                              ],
                            ),
                          ));
                    }).toList(),
                  ),
                  Container(
                      margin: EdgeInsets.symmetric(horizontal: 0),
                      child: Divider(
                        color: Colors.pink[100],
                      )),

                  //weight...
                  SizedBox(
                    height: 5,
                  ),

                  data['CakeSubType'].toString().toLowerCase()=="brownie"?
                  GestureDetector(
                    onTap: (){
                      showCakeTopperSheet(topperName);
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width-30,
                      height:45,
                      decoration: BoxDecoration(
                        color: Color(0xffffe9df),
                        borderRadius: BorderRadius.circular(10)
                      ),
                      child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            topperPrice==0.0?
                            Icon(Icons.add_circle , color:darkBlue):Icon(Icons.check_circle , color:Colors.green),
                            SizedBox(width: 8,),
                            Text("Add Topper" , style: TextStyle(
                                color:darkBlue,
                              fontFamily: "Poppins"
                            ),),
                          ],
                      ),
                    ),
                  ):Container(),

                  data['CakeSubType'].toString().toLowerCase()=="brownie"?
                  SizedBox(
                    height: 10,
                  ):Container(),


                  Text(
                    otherType.toLowerCase() == "kg"
                        ? "Weight"
                        : otherType.toLowerCase() == "unit"
                            ? "Unit"
                            : "Piece",
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 14.5,
                        color: darkBlue,
                        fontWeight: FontWeight.w600),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  otherType.toLowerCase() == "kg"
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 45,
                              width: double.infinity,
                              child: ListView.builder(
                                  shrinkWrap: true,
                                  scrollDirection: Axis.horizontal,
                                  itemCount: weight.length,
                                  itemBuilder: (c, pos) {
                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          selectedWeightIndex = pos;
                                          selectedWeight =
                                              weight[pos]['Weight'].toString();
                                          originalWeight = weight[pos]['Weight'].toString();
                                          customweightCtrl.text = "";
                                        });
                                      },
                                      child: Container(
                                        margin: EdgeInsets.all(5),
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                            color: selectedWeightIndex == pos
                                                ? lightPink
                                                : Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            border: Border.all(
                                                color: lightPink, width: 0.5)),
                                        width: 50,
                                        child: Text(
                                          weight[pos]['Weight'],
                                          style: TextStyle(
                                            color: selectedWeightIndex == pos
                                                ? Colors.white
                                                : lightPink,
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                              "Enter Weight",
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontFamily: "Poppins",
                                  fontSize: 14.5,
                                  color: darkBlue,
                                  fontWeight: FontWeight.w600),
                            ),
                            Container(
                              margin: EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.scale_outlined,
                                    color: lightPink,
                                  ),
                                  Expanded(
                                    child: Container(
                                      margin:
                                          EdgeInsets.symmetric(horizontal: 10),
                                      child: TextField(
                                        keyboardType: TextInputType.number,
                                        textInputAction: TextInputAction.next,
                                        controller: customweightCtrl,
                                        style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 13),
                                        inputFormatters: <TextInputFormatter>[
                                          FilteringTextInputFormatter.allow(
                                              new RegExp('[0-9.]')),
                                          FilteringTextInputFormatter.allow(
                                              RegExp(r'^(\d+)?\.?\d{0,2}')),
                                          FilteringTextInputFormatter.allow(
                                              RegExp(r'^\d+\.?\d*')),
                                          FilteringTextInputFormatter.allow(
                                              RegExp(r'^\d+\.?\d*'))!,
                                        ],
                                        onChanged: (String text) {
                                          print(text + selectedDropWeight);
                                          setState(() {
                                            if (customweightCtrl
                                                .text.isNotEmpty) {
                                              selectedWeightIndex = -1;
                                              selectedWeight =
                                                  text + selectedDropWeight;
                                              changeWeight(selectedWeight);
                                              print(
                                                  "weight is ${selectedWeight + selectedDropWeight}");
                                            } else {
                                              selectedWeightIndex = 0;
                                              selectedWeight = weight[0]
                                                      ['Weight']
                                                  .toString();
                                              changeWeight(selectedWeight);
                                            }
                                          });
                                        },
                                        decoration: InputDecoration(
                                          contentPadding: EdgeInsets.all(0.0),
                                          isDense: true,
                                          constraints:
                                              BoxConstraints(minHeight: 5),
                                          hintText: 'Type here..',
                                          border: InputBorder.none,
                                          hintStyle: TextStyle(
                                              fontFamily: 'Poppins',
                                              fontSize: 13),
                                          // border: InputBorder.none
                                        ),
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    child: Container(
                                        padding: EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                            color: Colors.grey[300]!,
                                            borderRadius:
                                                BorderRadius.circular(5)),
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
                                                          if (customweightCtrl
                                                              .text
                                                              .isNotEmpty) {
                                                            selectedDropWeight =
                                                                "Kg";
                                                            selectedWeight =
                                                                customweightCtrl
                                                                        .text +
                                                                    "kg";
                                                          }
                                                        });
                                                      },
                                                      child: Text(
                                                        'Kilo Gram',
                                                        style: TextStyle(
                                                            fontFamily:
                                                                "Poppins"),
                                                      )),
                                                  PopupMenuItem(
                                                      onTap: () {
                                                        setState(() {
                                                          if (customweightCtrl
                                                              .text
                                                              .isNotEmpty) {
                                                            selectedDropWeight =
                                                                "G";
                                                            selectedWeight =
                                                                customweightCtrl
                                                                        .text +
                                                                    "g";
                                                          }
                                                        });
                                                      },
                                                      child: Text(
                                                        'Gram',
                                                        style: TextStyle(
                                                            fontFamily:
                                                                "Poppins"),
                                                      )),
                                                ])),
                                  )
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                          ],
                        )
                      : otherType.toLowerCase() == "unit"
                          ? Container(
                              child: Container(
                                height: 45,
                                width: double.infinity,
                                child: ListView.builder(
                                    shrinkWrap: true,
                                    scrollDirection: Axis.horizontal,
                                    itemCount: weight.length,
                                    itemBuilder: (c, pos) {
                                      return GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            selectedWeightIndex = pos;
                                            selectedWeight = weight[pos]['Weight'].toString();
                                            originalWeight = weight[pos]['Weight'].toString();
                                            myPrice = double.parse(weight[pos]
                                                    ['PricePerUnit']
                                                .toString());
                                            counter = int.parse(weight[pos]
                                                    ['MinCount']
                                                .toString());
                                          });
                                        },
                                        child: Container(
                                          margin: EdgeInsets.all(5),
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                              color: selectedWeightIndex == pos
                                                  ? lightPink
                                                  : Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                  color: lightPink,
                                                  width: 0.5)),
                                          width: 50,
                                          child: Text(
                                            weight[pos]['Weight'],
                                            style: TextStyle(
                                              color: selectedWeightIndex == pos
                                                  ? Colors.white
                                                  : lightPink,
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                              ),
                            )
                          : otherType.toLowerCase() == "box"
                              ? Container(
                                  child: Container(
                                    height: 45,
                                    width: double.infinity,
                                    child: ListView.builder(
                                        shrinkWrap: true,
                                        scrollDirection: Axis.horizontal,
                                        itemCount: weight.length,
                                        itemBuilder: (c, pos) {
                                          return GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                selectedWeightIndex = pos;
                                                selectedWeight = weight[pos]
                                                        ['Piece']
                                                    .toString();
                                                originalWeight = weight[pos]['Piece'].toString();
                                                myPrice = double.parse(
                                                    weight[pos]['PricePerBox']
                                                        .toString());
                                                counter = int.parse(weight[pos]
                                                        ['MinCount']
                                                    .toString());
                                              });
                                            },
                                            child: Container(
                                              margin: EdgeInsets.all(5),
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                  color:
                                                      selectedWeightIndex == pos
                                                          ? lightPink
                                                          : Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  border: Border.all(
                                                      color: lightPink,
                                                      width: 0.5)),
                                              width: 65,
                                              child: Text(
                                                weight[pos]['Piece'] + " Pcs",
                                                style: TextStyle(
                                                  color:
                                                      selectedWeightIndex == pos
                                                          ? Colors.white
                                                          : lightPink,
                                                ),
                                              ),
                                            ),
                                          );
                                        }),
                                  ),
                                )
                              : Container(),

                  SizedBox(
                    height: 8,
                  ),
                  Text(
                    "Delivery Information",
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 14.5,
                        color: darkBlue,
                        fontWeight: FontWeight.w600),
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
                              tooFar = false;
                              deliverAddressIndex = 0;
                            }
                            for (int i = 0; i < picOrDel.length; i++) {
                              if (i == index) {
                                fixedDelliverMethod = picOrDeliver[i];
                                picOrDel[i] = true;
                              } else {
                                picOrDel[i] = false;
                              }
                            }
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.only(top: 5, bottom: 5, left: 8),
                          child: Row(children: [
                            picOrDel[index] == false
                                ? Icon(Icons.radio_button_unchecked_rounded,
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

                  SizedBox(
                    height: 5,
                  ),

                  Text(
                    "Delivery Details",
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 14.5,
                        color: darkBlue,
                        fontWeight: FontWeight.w600),
                  ),

                  GestureDetector(
                    onTap: () async {
                      print(minimumDeliTime);

                      String deliTime = "";

                      if (minimumDeliTime.isNotEmpty) {
                        deliTime = dayMinConverter(minimumDeliTime);
                      }

                      DateTime? SelDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime(
                            DateTime.now().year,
                            DateTime.now().month,
                            DateTime.now().day + int.parse(deliTime),
                          ),
                          lastDate: DateTime(2100),
                          firstDate: DateTime(
                            DateTime.now().year,
                            DateTime.now().month,
                            DateTime.now().day + int.parse(deliTime),
                          ),
                          helpText: "Min Delivery Time $minimumDeliTime",
                          builder: (c, child) {
                            return Theme(
                                data: ThemeData(
                                    dialogTheme: DialogTheme(
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10))),
                                    colorScheme: ColorScheme.light(
                                        onPrimary: Colors.white,
                                        onSurface: Colors.pink,
                                        primary: Colors.pink),
                                    textTheme: const TextTheme(
                                        headline5: TextStyle(
                                            fontSize: 17,
                                            fontFamily: "Poppins",
                                            fontWeight: FontWeight.bold),
                                        headline4: TextStyle(
                                            fontSize: 17,
                                            fontFamily: "Poppins",
                                            fontWeight: FontWeight.bold),
                                        overline: TextStyle(
                                            fontSize: 14,
                                            fontFamily: "Poppins",
                                            fontWeight: FontWeight.bold))),
                                child: child!);
                          });

                      setState(() {
                        deliverDate =
                            simplyFormat(time: SelDate, dateOnly: true);
                      });

                      // print(cakeMindeltime.replaceAll(RegExp('[^0-9]'), ''));

                      // print(SelDate.toString());
                      // print(DateTime.now().subtract(Duration(days: 0)));
                    },
                    child: Container(
                        margin: EdgeInsets.all(5),
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: Colors.grey[400]!, width: 0.5)),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '$deliverDate',
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 13,
                                    fontFamily: "Poppins"),
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
                                  borderRadius: BorderRadius.circular(20)),
                              title: Text("Select delivery session",
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
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        PopupMenuItem(
                                            child: Text(
                                              'Morning 8 AM - 9 AM',
                                              style: TextStyle(
                                                  fontFamily: "Poppins"),
                                            ),
                                            onTap: () {
                                              setState(() {
                                                deliverSession =
                                                    'Morning 8 AM - 9 AM';
                                              });
                                            }),
                                        PopupMenuItem(
                                            child: Text(
                                              'Morning 9 AM - 10 AM',
                                              style: TextStyle(
                                                  fontFamily: "Poppins"),
                                            ),
                                            onTap: () {
                                              setState(() {
                                                deliverSession =
                                                    'Morning 9 AM - 10 AM';
                                              });
                                            }),
                                        PopupMenuItem(
                                            child: Text(
                                              'Morning 10 AM - 11 AM',
                                              style: TextStyle(
                                                  fontFamily: "Poppins"),
                                            ),
                                            onTap: () {
                                              setState(() {
                                                deliverSession =
                                                    'Morning 10 AM - 11 AM';
                                              });
                                            }),
                                        PopupMenuItem(
                                            child: Text(
                                              'Morning 11 AM - 12 PM',
                                              style: TextStyle(
                                                  fontFamily: "Poppins"),
                                            ),
                                            onTap: () {
                                              setState(() {
                                                deliverSession =
                                                    'Morning 11 PM - 12 PM';
                                              });
                                            }),
                                        PopupMenuItem(
                                            child: Text(
                                              'Afternoon 12 PM - 1 PM',
                                              style: TextStyle(
                                                  fontFamily: "Poppins"),
                                            ),
                                            onTap: () {
                                              setState(() {
                                                deliverSession =
                                                    'Afternoon 12 PM - 1 PM';
                                              });
                                            }),
                                        PopupMenuItem(
                                            child: Text(
                                              'Afternoon 1 PM - 2 PM',
                                              style: TextStyle(
                                                  fontFamily: "Poppins"),
                                            ),
                                            onTap: () {
                                              setState(() {
                                                deliverSession =
                                                    'Afternoon 1 PM - 9 PM';
                                              });
                                            }),
                                        PopupMenuItem(
                                            child: Text(
                                              'Afternoon 2 PM - 3 PM',
                                              style: TextStyle(
                                                  fontFamily: "Poppins"),
                                            ),
                                            onTap: () {
                                              setState(() {
                                                deliverSession =
                                                    'Afternoon 8 PM - 9 PM';
                                              });
                                            }),
                                        PopupMenuItem(
                                            child: Text(
                                              'Afternoon 3 PM - 4 PM',
                                              style: TextStyle(
                                                  fontFamily: "Poppins"),
                                            ),
                                            onTap: () {
                                              setState(() {
                                                deliverSession =
                                                    'Afternoon 3 PM - 4 PM';
                                              });
                                            }),
                                        PopupMenuItem(
                                            child: Text(
                                              'Afternoon 4 PM - 5 PM',
                                              style: TextStyle(
                                                  fontFamily: "Poppins"),
                                            ),
                                            onTap: () {
                                              setState(() {
                                                deliverSession =
                                                    'Afternoon 4 PM - 5 PM';
                                              });
                                            }),
                                        PopupMenuItem(
                                            child: Text(
                                              'Evening 5 PM - 6 PM',
                                              style: TextStyle(
                                                  fontFamily: "Poppins"),
                                            ),
                                            onTap: () {
                                              setState(() {
                                                deliverSession =
                                                    'Evening 5 PM - 6 PM';
                                              });
                                            }),
                                        PopupMenuItem(
                                            child: Text(
                                              'Evening 6 PM - 7 PM',
                                              style: TextStyle(
                                                  fontFamily: "Poppins"),
                                            ),
                                            onTap: () {
                                              setState(() {
                                                deliverSession =
                                                    'Evening 6 PM - 7 PM';
                                              });
                                            }),
                                        PopupMenuItem(
                                            child: Text(
                                              'Evening 7 PM - 8 PM',
                                              style: TextStyle(
                                                  fontFamily: "Poppins"),
                                            ),
                                            onTap: () {
                                              setState(() {
                                                deliverSession =
                                                    'Evening 7 PM - 8 PM';
                                              });
                                            }),
                                        PopupMenuItem(
                                            child: Text(
                                              'Evening 8 PM - 9 PM',
                                              style: TextStyle(
                                                  fontFamily: "Poppins"),
                                            ),
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
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: Colors.grey[400]!, width: 0.5)),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '$deliverSession',
                                style: TextStyle(
                                    fontFamily: "Poppins",
                                    color: Colors.grey,
                                    fontSize: 13),
                              ),
                              Icon(CupertinoIcons.clock, color: darkBlue)
                            ])),
                  ),

                  SizedBox(
                    height: 4,
                  ),

                  fixedDelliverMethod.toLowerCase() == "delivery"
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Address",
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontFamily: "Poppins",
                                  fontSize: 14.5,
                                  color: darkBlue,
                                  fontWeight: FontWeight.w600),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // ListTile(
                                //   onTap: (){
                                //     setState(() {
                                //       // deliveryAddress = deliverAddress.trim();
                                //       // deliverAddressIndex = deliverAddress.indexWhere((element) => element==e);
                                //     });
                                //   },
                                //   title: Text(
                                //     '${deliveryAddress.trim()}',
                                //     style: TextStyle(
                                //         fontFamily: poppins,
                                //         color: Colors.grey,
                                //         fontSize: 13),
                                //   ),
                                //   trailing:
                                //   //deliverAddressIndex==deliverAddress.indexWhere((element) => element==e)?
                                //   Icon(Icons.check_circle, color: Colors.green ,size: 25,)
                                //   //     :
                                //   // Container(height:0,width:0),
                                // ),
                                Column(
                                  children:deliverAddress.map((e){
                                    return ListTile(
                                      onTap: () async{
                                        // setState(() {
                                        //   deliveryAddress = e.trim();
                                        //   deliverAddressIndex = deliverAddress.indexWhere((element) => element==e);
                                        // });
                                        showAlertDialog();
                                        try {
                                          List<Location> locat =
                                              await locationFromAddress(e.toString().trim());
                                          List<Location> venLocation = await locationFromAddress(vendorAddress.trim());
                                          print(locat);
                                          setState(() {
                                            deliveryAddress = e.trim();
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
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                AddressScreen()));
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 0),
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
                        )
                      : Container(),

                  SizedBox(
                    height: 5,
                  ),

                  Text(
                    "Selected Vendor  ",
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 14.5,
                        color: darkBlue,
                        fontWeight: FontWeight.w600),
                  ),

                  GestureDetector(
                    onTap: () async {},
                    child: Card(
                      margin: EdgeInsets.only(left: 10, right: 10, top: 5),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10)),
                        child: Row(
                          children: [
                            vendorProfile.length < 7
                                ? Container(
                                    width: 90,
                                    height: 100,
                                    decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(10),
                                        image: DecorationImage(
                                            image: AssetImage(
                                                "assets/images/vendorimage.jpeg"),
                                            fit: BoxFit.cover)),
                                  )
                                : Container(
                                    width: 90,
                                    height: 100,
                                    decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(10),
                                        image: DecorationImage(
                                            image: NetworkImage(vendorProfile),
                                            fit: BoxFit.cover)),
                                  ),
                            SizedBox(
                              width: 8,
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 155,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              child: Text(
                                                '$vendrorName',
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
                                                  initialRating: vendrorRating
                                                              .isEmpty ||
                                                          vendrorRating == null
                                                      ? 1.0
                                                      : double.parse(
                                                          vendrorRating
                                                              .replaceAll(
                                                                  RegExp(
                                                                      '[^0-9]'),
                                                                  '')),
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
                                                  onRatingUpdate: (rating) {
                                                    print(rating);
                                                  },
                                                ),
                                                Text(
                                                  '$vendrorRating',
                                                  style: TextStyle(
                                                      color: Colors.black54,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 13,
                                                      fontFamily: poppins),
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(Icons.check_circle,
                                          color: Colors.green),
                                    ],
                                  ),
                                  Text(
                                    "Speciality in ${vendrorSpecial} ",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontFamily: "Poppins",
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                  ),
                                  SizedBox(
                                    height: 6,
                                  ),
                                  Container(
                                    height: 1,
                                    color: Colors.grey,
                                    // margin: EdgeInsets.only(left:6,right:6),
                                  ),
                                  SizedBox(
                                    height: 6,
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "${vendrorEgg}",
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontFamily: "Poppins",
                                              color: darkBlue,
                                            ),
                                            maxLines: 1,
                                          ),
                                          SizedBox(height: 3),
                                          ((adminDeliveryCharge /
                                                              adminDeliveryChargeKm) *
                                                          (calculateDistance(
                                                              double.parse(
                                                                  userLatitude),
                                                              double.parse(
                                                                  userLongtitude),
                                                              double.parse(
                                                                  vendrorLat
                                                                      .toString()),
                                                              double.parse(
                                                                  vendrorLong))))
                                                      .toStringAsFixed(1) ==
                                                  "0.0"
                                              ? Text(
                                                  "DELIVERY FREE",
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontFamily: "Poppins",
                                                    color: Colors.orange,
                                                  ),
                                                  maxLines: 1,
                                                )
                                              : Text(
                                                  "${(calculateDistance(double.parse(userLatitude), double.parse(userLongtitude), double.parse(vendrorLat.toString()), double.parse(vendrorLong))).toStringAsFixed(1)} "
                                                  "KM Charge Rs.${((adminDeliveryCharge / adminDeliveryChargeKm) * (calculateDistance(double.parse(userLatitude), double.parse(userLongtitude), double.parse(vendrorLat.toString()), double.parse(vendrorLong)))).toStringAsFixed(1)}",
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontFamily: "Poppins",
                                                    color: Colors.orange,
                                                  ),
                                                  maxLines: 1,
                                                ),
                                        ],
                                      ),
                                      Expanded(
                                        child: Container(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              InkWell(
                                                onTap: () {
                                                  print('phone..');
                                                  PhoneDialog().showPhoneDialog(
                                                    context,
                                                    "$vendrorPhone1",
                                                    "$vendrorPhonr2",
                                                  );
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
                                                  Functions().handleChatWithVendors(context, vendorList[0]['Email'], vendorList[0]['VendorName']);
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
                  ),

                  SizedBox(
                    height: 15,
                  ),

                  tooFar?
                  Container():
                  Center(
                    child: Container(
                      height: 50,
                      width: 200,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25)),
                      child: RaisedButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25)),
                        onPressed: () async {
                          FocusScope.of(context).unfocus();
                          // if(fixedDelliverMethod.isEmpty){
                          //   ScaffoldMessenger.of(context).showSnackBar(
                          //       SnackBar(
                          //           content:
                          //           Text("Please select pickup or delivery")));
                          // }else
                            if (otherType == "Kg") {
                            if (changeWeight(selectedWeight) <
                                changeWeight(weight[0]['Weight'])) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  content: Text(
                                      "Minimum weight is ${weight[0]['Weight']}!")));
                            } else if (deliverDate.toLowerCase() ==
                                "select delivery date") {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                          Text("Please select deliver date")));
                            } else if (deliverSession.toLowerCase() ==
                                "select delivery time") {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          "Please select deliver session")));
                            } else if (fixedDelliverMethod.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          "Please select pickup or delivery")));
                            } else {
                              gotoCheckout();
                            }
                          } else if (otherType == "Unit") {
                            if (deliverDate.toLowerCase() ==
                                "select delivery date") {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                          Text("Please select deliver date")));
                            } else if (deliverSession.toLowerCase() ==
                                "select delivery time") {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          "Please select deliver session")));
                            } else if (fixedDelliverMethod.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          "Please select pickup or delivery")));
                            } else {
                              gotoCheckout();
                            }
                          } else {
                            if (deliverDate.toLowerCase() ==
                                "select delivery date") {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                          Text("Please select deliver date")));
                            } else if (deliverSession.toLowerCase() ==
                                "select delivery time") {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          "Please select deliver session")));
                            } else if (fixedDelliverMethod.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          "Please select pickup or delivery")));
                            } else {
                              gotoCheckout();
                            }
                          }
                        },
                        color: lightPink,
                        child: Text(
                          "ORDER NOW",
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(
                    height: 15,
                  ),
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

  if (givenWeight.toLowerCase().endsWith("kg")) {
    givenWeight = givenWeight.toLowerCase().replaceAll("kg", "");
    converetedWeight = double.parse(givenWeight);
  } else {
    givenWeight = givenWeight.toLowerCase().replaceAll("g", "");
    converetedWeight = double.parse(givenWeight) / 1000;
  }

  print("Converted : $converetedWeight");

  return converetedWeight;
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
