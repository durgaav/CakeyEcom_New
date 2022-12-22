import 'dart:convert';
import 'dart:math';
import 'package:cakey/PaymentGateway.dart';
import 'package:cakey/ShowToFarDialog.dart';
import 'package:cakey/screens/HamperCheckout.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../ContextData.dart';
import '../Dialogs.dart';
import '../DrawerScreens/CustomiseCake.dart';
import 'AddressScreen.dart';

class HamperDetails extends StatefulWidget {
  var data = {};
  HamperDetails({required this.data});

  @override
  State<HamperDetails> createState() => _HamperDetailsState(data: data);
}

class _HamperDetailsState extends State<HamperDetails> {
  var data = {};
  _HamperDetailsState({required this.data});

  //colors...
  String poppins = "Poppins";
  Color darkBlue = Color(0xffF213959);
  Color lightPink = Color(0xffFE8416D);
  Color lightGrey = Color(0xffF5F5F5);

  //Pick Or Deliver
  var picOrDeliver = ['Pickup', 'Delivery'];
  var picOrDel = [true, false];

  String fixedDelliverMethod = "Pickup";
  String deliverDate = "Select delivery date";
  String deliverSession = "Select delivery time";

  String paymentMethod = "online payment";
  var _razorpay = Razorpay();

  String hamperImage = "";
  String hamperName = "";
  String hamper_id = "";
  String hampeModid = "";
  String hamperPrice = "0.0";
  String hamperDescription = "";
  String hampVen_Id = "";
  String hampVenId = "";
  String hampVenName = "";
  String hampVenPhn1 = "";
  String hampVenPhn2 = "";
  String hampVenAddres = "";
  String hamTitle = "";
  String hamWeight = "";
  String authToken = "";
  String userLatitude = "0.0";
  String userLongtitude = "0.0";
  String deliveryAddress = "";

  int pageViewCurIndex = 0;

  List<String> productContains = [];
  List vendorList = [];
  List<String> hamImages = [];
  String eggOregless = "";

  var expanded = true;

  String vendrorName = "";
  String vendrorEgg = "";
  String vendrorSpecial = "";
  String vendrorLat = "0.0";
  String vendrorLong = "0.0";
  String vendrorRating = "";
  String vendrorPhone1 = "";
  String vendrorPhonr2 = "";
  String vendorProfile = "";
  String vendorId = "";
  String vendor_Id = "";
  String vendorAddress = "";
  String noId = "";
  String cakeRatings = "";

  //user
  String userId = "";
  String user_ID = "";
  String userName = "";
  String userPhone = "";

  String startDate = "";
  String endDate = "";
  String deliStartDate = "";
  String deliEndDate = "";

  int adminDeliveryCharge = 0;
  int adminDeliveryChargeKm = 0;
  int counts = 1;
  double deliveryCharge = 0;
  int amount = 0;

  List<String> deliverAddress = [];
  var deliverAddressIndex = -1;

  var tooFar = false;

  //Distance calculator
  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
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

  void navigateToCheckout() async {

    var paymentObj = {
      "img": data['HamperImage'],
      "name": data['HampersName'],
      "egg": data['EggOrEggless'],
      "price": data['Price'],
      "count":counts,
      "vendor": data['VendorName'],
      "type": "Hamper",
      "details": data,
      "deliverType": fixedDelliverMethod,
      "deliveryAddress": deliveryAddress,
      "deliverDate":deliverDate,
      "deliverSession":deliverSession,
      "deliverCharge":fixedDelliverMethod.toLowerCase()=="pickup"?0:((adminDeliveryCharge / adminDeliveryChargeKm)*(calculateDistance(double.parse(userLatitude), double.parse(userLongtitude),
          double.parse(vendrorLat.toString()), double.parse(vendrorLong)))),
      "discount":0,
      "vendor_id":vendor_Id,
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

  //prev screen details
  Future<void> getDetails() async {
    //prefs.setString("userCurrentLocation", userLocalityAdr);
    //prefs.setString("userMainLocation", place.locality.toString());

    var pref = await SharedPreferences.getInstance();

    setState(() {
      authToken = pref.getString("authToken") ?? '';
      userLatitude = pref.getString("userLatitute") ?? '';
      userLongtitude = pref.getString("userLongtitude") ?? '';
      adminDeliveryCharge = pref.getInt("todayDeliveryCharge") ?? 0;
      adminDeliveryChargeKm = pref.getInt("todayDeliveryKm") ?? 0;
      hamImages = pref.getStringList("hamperImages") ?? [];
      userId = pref.getString("userID") ?? '';
      user_ID = pref.getString("userModId") ?? '';
      userName = pref.getString("userName") ?? '';
      userPhone = pref.getString("phoneNumber") ?? '';
      //deliveryAddress = pref.getString("userCurrentLocation") ?? 'null';
      deliverAddress =
          pref.getStringList('addressList') ?? [deliveryAddress.trim()];
      cakeRatings = pref.getString("userAddress") ?? 'null';
      //hamperImage = pref.getString("hamperImage") ?? '';
      hamperName = pref.getString("hamperName") ?? '';
      hamper_id = pref.getString("hamper_ID") ?? '';
      hampeModid = pref.getString("hamperModID") ?? '';
      hamperPrice = pref.getString("hamperPrice") ?? '';
      hamperDescription = pref.getString("hamperDescription") ?? '';
      hampVen_Id = pref.getString("hamperVendor_ID") ?? '';
      hampVenId = pref.getString("hamperVendorID") ?? '';
      hampVenName = pref.getString("hamperVendorName") ?? '';
      hampVenPhn1 = pref.getString("hamperVendorPhn1") ?? '';
      hampVenPhn2 = pref.getString("hamperVendorPhn2") ?? '';
      hamTitle = pref.getString("hamperTitle") ?? '';
      hamWeight = pref.getString("hamperWeight") ?? '';
      startDate = pref.getString("hamperStartDate") ?? '';
      endDate = pref.getString("hamperEndDate") ?? '';
      deliStartDate = pref.getString("hamperDeliStartDate") ?? '';
      deliEndDate = pref.getString("hamperDeliEndDate") ?? '';
      eggOregless = pref.getString("hamperEggreggless") ?? '';

      productContains = pref.getStringList('hamperProducts') ?? ['No Products'];
    });

    getVendor(data['VendorID'].toString());

  }

  //geting vendor
  Future<void> getVendor(String id) async {
    showAlertDialog();
    print(id);

    List forFilter = [];

    try {
      var headers = {'Authorization': '$authToken'};
      var request = http.Request('GET',
          Uri.parse('http://sugitechnologies.com/cakey/api/vendors/list'));

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

          print("Vendor list $vendorList");

          if (vendorList.isNotEmpty) {
            vendrorName = vendorList[0]['VendorName'].toString();
            vendrorEgg = vendorList[0]['EggOrEggless'].toString();
            noId = vendorList[0]['Notification_Id'].toString();
            vendorProfile = vendorList[0]['ProfileImage'].toString();
            vendrorSpecial = vendorList[0]['YourSpecialityCakes']
                .toString()
                .replaceAll("[", "")
                .replaceAll("]", "");
            vendrorLat = vendorList[0]['GoogleLocation']['Latitude'].toString();
            vendrorLong = vendorList[0]['GoogleLocation']['Longitude'].toString();
            vendrorRating = vendorList[0]['Ratings'].toString();
            vendrorPhone1 = vendorList[0]['PhoneNumber1'].toString();
            vendrorPhonr2 = vendorList[0]['PhoneNumber2'].toString();
            vendorId = vendorList[0]['Id'].toString();
            vendor_Id = vendorList[0]['_id'].toString();
            vendorAddress = vendorList[0]['Address'].toString();
            deliveryCharge = double.parse(
                ((adminDeliveryCharge / adminDeliveryChargeKm) *
                        (calculateDistance(
                            double.parse(userLatitude),
                            double.parse(userLongtitude),
                            double.parse(vendrorLat.toString()),
                            double.parse(vendrorLong))))
                    .toStringAsFixed(1));

            print("Deliver charge : $deliveryCharge");

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
    for (int i = 0; i < hamImages.length; i++) {
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

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      getDetails();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print(data);

    if (context.watch<ContextData>().getAddressList().isNotEmpty) {
      deliverAddress = context.watch<ContextData>().getAddressList();
    }

    print(hamImages);

    return Scaffold(
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                expandedHeight: 270.0,
                title: innerBoxIsScrolled == true
                    ? Text(
                        "$hamperName",
                        style:
                            TextStyle(color: darkBlue, fontFamily: "Poppins"),
                      )
                    : Text(""),
                pinned: true,
                floating: true,
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
                backgroundColor: lightGrey,
                flexibleSpace: FlexibleSpaceBar(
                  background: hamImages.isNotEmpty
                      ? Stack(
                          children: [
                            PageView.builder(
                                onPageChanged: (int i) {
                                  setState(() {
                                    pageViewCurIndex = i;
                                  });
                                },
                                itemCount: hamImages.length,
                                itemBuilder: (c, i) {
                                  var imageUrl = hamImages[i]
                                      .toString()
                                      .replaceAll("[", "")
                                      .replaceAll("]", "");
                                  return Container(
                                    margin: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(10),
                                            bottomRight: Radius.circular(10)),
                                        image: DecorationImage(
                                            image: NetworkImage("${imageUrl}"),
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
                          ],
                        )
                      : Container(
                          alignment: Alignment.center,
                          margin: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(
                            'No Image!',
                            style: TextStyle(
                                color: darkBlue,
                                fontFamily: "Poppins",
                                fontSize: 20),
                          ),
                        ),
                ),
              ),
            ];
          },
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //name
                  Container(
                    margin: EdgeInsets.only(left: 10, right: 10, top: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Row(
                        //   children: [
                        //     RatingBar.builder(
                        //       initialRating:
                        //       double.parse(cakeRatings, (e) => 1.5),
                        //       minRating: 1,
                        //       direction: Axis.horizontal,
                        //       allowHalfRating: true,
                        //       itemCount: 5,
                        //       itemSize: 15,
                        //       itemPadding:
                        //       EdgeInsets.symmetric(horizontal: 1.0),
                        //       itemBuilder: (context, _) => Icon(
                        //         Icons.star,
                        //         color: Colors.amber,
                        //       ),
                        //       onRatingUpdate: (rating) {
                        //         print(rating);
                        //       },
                        //     ),
                        //     Container(
                        //       padding: EdgeInsets.only(left: 5),
                        //       child: (cakeRatings != null)
                        //           ? (cakeRatings != 'null')
                        //           ? Text(
                        //         ' $cakeRatings',
                        //         style: TextStyle(
                        //             color: Colors.black54,
                        //             fontWeight: FontWeight.bold,
                        //             fontSize: 13,
                        //             fontFamily: poppins),
                        //       )
                        //           : Text('3.5',
                        //           style: TextStyle(
                        //               color: Colors.black54,
                        //               fontWeight: FontWeight.bold,
                        //               fontSize: 13,
                        //               fontFamily: poppins))
                        //           : Text(cakeRatings),
                        //     )
                        //   ],
                        // ),
                        Expanded(
                          child: Text(
                            '$hamperName',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontFamily: "Poppins",
                                fontSize: 18,
                                color: darkBlue,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                        GestureDetector(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Transform.rotate(
                                angle: 120,
                                child: Icon(
                                  Icons.egg_outlined,
                                  color: eggOregless.toLowerCase() == "eggless"
                                      ? Colors.green
                                      : eggOregless.toLowerCase() == "egg"
                                          ? Color(0xff8D2729)
                                          : Colors.white,
                                ),
                              ),
                              Text(
                                '$eggOregless',
                                style: TextStyle(
                                    color:
                                        eggOregless.toLowerCase() == "eggless"
                                            ? Colors.green
                                            : eggOregless.toLowerCase() == "egg"
                                                ? Color(0xff8D2729)
                                                : Colors.white,
                                    fontFamily: poppins,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  // Container(
                  //   padding: EdgeInsets.only(left: 10, right: 10),
                  //   child: Text(
                  //     '$hamperName',
                  //     overflow: TextOverflow.ellipsis,
                  //     style: TextStyle(
                  //         fontFamily: "Poppins",
                  //         fontSize: 18,
                  //         color: darkBlue,
                  //         fontWeight: FontWeight.w600),
                  //   ),
                  // ),

                  //price counts
                  Container(
                      padding: EdgeInsets.only(left: 10, right: 10),
                      alignment: Alignment.bottomLeft,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                  " ${double.parse(hamperPrice) * counts}",
                                  style: TextStyle(
                                    color: lightPink,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 23,
                                  ),
                                )
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
                                    counts < 10 ? '0$counts' : '$counts',
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
                                    child: Icon(Icons.add, color: darkBlue)),
                              ),
                            ])
                          ])),

                  //description
                  Container(
                      margin: EdgeInsets.all(10),
                      child: ExpandableText(
                        "$hamperDescription",
                        expandText: "",
                        collapseText: "collapse",
                        expandOnTextTap: true,
                        collapseOnTextTap: true,
                        style: TextStyle(
                            color: Colors.grey, fontFamily: "Poppins"),
                      )),

                  Container(
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Booking Start',
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                      fontFamily: "Poppins"),
                                ),
                                SizedBox(
                                  height: 2,
                                ),
                                // fixedFlavList.isEmpty
                                //     ?
                                Text(
                                  "$startDate",
                                  style: TextStyle(
                                      fontFamily: "Poppins",
                                      color: darkBlue,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600),
                                )
                              ],
                            ),
                          ),
                        ),
                        Container(
                          height: 45,
                          width: 1,
                          color: Colors.pink[100],
                        ),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.only(left: 15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Booking End',
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
                                Text(
                                  "$endDate",
                                  style: TextStyle(
                                      color: darkBlue,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: "Poppins"),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  //product contains
                  Padding(
                    padding: EdgeInsets.only(top: 5, left: 6),
                    child: Text(
                      'Product Contains',
                      style: TextStyle(
                          fontFamily: poppins, color: darkBlue, fontSize: 15),
                    ),
                  ),

                  SizedBox(
                    height: 8,
                  ),

                  //product contains
                  Padding(
                      padding: EdgeInsets.only(left: 10, right: 10),
                      child: Container(
                        decoration: BoxDecoration(
                            color: Color(0xffffe9df),
                            borderRadius: BorderRadius.circular(10)),
                        child: Theme(
                          data: ThemeData()
                              .copyWith(dividerColor: Colors.transparent),
                          child: ExpansionTile(
                            onExpansionChanged: (e) {
                              setState(() {
                                expanded = e;
                                if (e == true) {
                                  //controller.jumpTo(controller.position.minScrollExtent);

                                  // RenderBox box = key.currentContext!.findRenderObject() as RenderBox;
                                  // Offset position = box.localToGlobal(Offset.zero); //this is global position
                                  // double y = position.dx;
                                  //
                                  // print(y);

                                  // controller.animateTo(
                                  //   306,
                                  //   duration: Duration(seconds: 1),
                                  //   curve: Curves.fastOutSlowIn,
                                  // );

                                }
                              });
                              print(e);
                            },
                            initiallyExpanded: true,
                            title: Text(
                              'Products',
                              style: TextStyle(
                                  color: darkBlue, fontFamily: "Poppins"),
                            ),
                            trailing: !expanded
                                ? Container(
                                    alignment: Alignment.center,
                                    height: 25,
                                    width: 25,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      color: darkBlue,
                                      size: 25,
                                    ),
                                  )
                                : Container(
                                    alignment: Alignment.center,
                                    height: 25,
                                    width: 25,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.keyboard_arrow_up,
                                      color: darkBlue,
                                      size: 25,
                                    ),
                                  ),
                            children: productContains.map((e) {
                              return Container(
                                alignment: Alignment.centerLeft,
                                padding: EdgeInsets.all(10),
                                child: Text(
                                  (productContains.indexWhere(
                                                  (element) => element == e) +
                                              1)
                                          .toString() +
                                      ") $e",
                                  style: TextStyle(
                                    color: darkBlue,
                                    fontFamily: "Poppins",
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      )),

                  //deliver infos
                  Container(
                      margin: EdgeInsets.symmetric(horizontal: 15),
                      child: Divider(
                        color: Colors.pink[100],
                      )),

                  Padding(
                    padding: EdgeInsets.only(top: 10, left: 6),
                    child: Text(
                      'Delivery Information',
                      style: TextStyle(
                          fontFamily: poppins, color: darkBlue, fontSize: 15),
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
                            for (int i = 0; i < picOrDel.length; i++) {
                              if (i == index) {
                                fixedDelliverMethod = picOrDeliver[i];
                                if (fixedDelliverMethod.toLowerCase() ==
                                    "pickup") {
                                  tooFar = false;
                                } else {
                                  tooFar = true;
                                  deliverAddressIndex = -1;
                                }
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

                  Container(
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Delivery Start',
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                      fontFamily: "Poppins"),
                                ),
                                SizedBox(
                                  height: 2,
                                ),
                                // fixedFlavList.isEmpty
                                //     ?
                                Text(
                                  "$deliStartDate",
                                  style: TextStyle(
                                      fontFamily: "Poppins",
                                      color: darkBlue,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600),
                                )
                              ],
                            ),
                          ),
                        ),
                        Container(
                          height: 45,
                          width: 1,
                          color: Colors.pink[100],
                        ),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.only(left: 15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Delivery End',
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
                                Text(
                                  "$deliEndDate",
                                  style: TextStyle(
                                      color: darkBlue,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: "Poppins"),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.only(top: 10, left: 6, bottom: 5),
                    child: Text(
                      'Delivery Details',
                      style: TextStyle(
                          fontFamily: "Poppins", color: darkBlue, fontSize: 15),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      print(deliStartDate);
                      print(deliEndDate);

                      DateTime? SelDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime(
                            int.parse(deliStartDate.split("-").last),
                            int.parse(deliStartDate.split("-")[1]),
                            int.parse(deliStartDate.split("-").first),
                          ),
                          lastDate: DateTime(
                            int.parse(deliEndDate.split("-").last),
                            int.parse(deliEndDate.split("-")[1]),
                            int.parse(deliEndDate.split("-").first),
                          ),
                          firstDate: DateTime(
                            int.parse(deliStartDate.split("-").last),
                            int.parse(deliStartDate.split("-")[1]),
                            int.parse(deliStartDate.split("-").first),
                          ),
                          helpText: "Select Deliver Date",
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

                      // print(SelDate.toString());
                      // print(DateTime.now().subtract(Duration(days: 0)));
                    },
                    child: Container(
                        margin: EdgeInsets.all(5),
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(7),
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
                                  borderRadius: BorderRadius.circular(10)),
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
                            borderRadius: BorderRadius.circular(7),
                            border: Border.all(
                                color: Colors.grey[400]!, width: 0.5)),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '$deliverSession',
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 13,
                                    fontFamily: "Poppins"),
                              ),
                              Icon(CupertinoIcons.clock, color: darkBlue)
                            ])),
                  ),

                  fixedDelliverMethod.toLowerCase() == "delivery"
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(top: 5, left: 10),
                              child: Text(
                                'Address',
                                style: TextStyle(
                                    fontFamily: poppins,
                                    color: darkBlue,
                                    fontSize: 15),
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                //deliverAddress
                                // ListTile(
                                //   onTap: (){
                                //     setState(() {
                                //       // deliveryAddress = e.trim();
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
                                  children: deliverAddress.map((e) {
                                    return ListTile(
                                      onTap: () async {
                                        showAlertDialog();
                                        try {
                                          List<Location> locat =
                                              await locationFromAddress(
                                                  e.toString().trim());
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
                                            TooFarDialog()
                                                .showTooFarDialog(context, e);
                                            //showTooFarDialog();
                                          }
                                        } catch (e) {
                                          print("Error... $e");
                                          Navigator.pop(context);
                                        }
                                        // setState(() {
                                        //   deliveryAddress = e.trim();
                                        //   deliverAddressIndex = deliverAddress.indexWhere((element) => element==e);
                                        // });
                                      },
                                      title: Text(
                                        '${e.trim()}',
                                        style: TextStyle(
                                            fontFamily: poppins,
                                            color: Colors.grey,
                                            fontSize: 13),
                                      ),
                                      trailing: deliverAddressIndex ==
                                              deliverAddress.indexWhere(
                                                  (element) => element == e)
                                          ? Icon(
                                              Icons.check_circle,
                                              color: Colors.green,
                                              size: 25,
                                            )
                                          : Container(height: 0, width: 0),
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
                        )
                      : Container(),

                  Padding(
                    padding: EdgeInsets.only(top: 15, left: 10),
                    child: Text(
                      'Selected Vendor',
                      style: TextStyle(
                          fontFamily: poppins, color: darkBlue, fontSize: 15),
                    ),
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
                                          Text(
                                            "${(calculateDistance(double.parse(userLatitude), double.parse(userLongtitude), double.parse(vendrorLat.toString()), double.parse(vendrorLong))).toStringAsFixed(1)} KM Charge Rs.${((adminDeliveryCharge / adminDeliveryChargeKm) *
                                                (calculateDistance(
                                                    double.parse(userLatitude),
                                                    double.parse(userLongtitude),
                                                    double.parse(vendrorLat.toString()),
                                                    double.parse(vendrorLong)))).toStringAsFixed(1)}",
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
                                                      "$hampVenPhn1",
                                                      "$hampVenPhn2"
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
                                                  // print('whatsapp : ');
                                                  // PhoneDialog().showPhoneDialog(
                                                  //     context,
                                                  //     "$hampVenPhn1",
                                                  //     "$hampVenPhn2",
                                                  //     true);
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
                    height: 30,
                  ),

                  tooFar
                      ? Container()
                      :
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
                                var charge = 0.0;
                                //deliverAddressIndex
                                if(fixedDelliverMethod.toLowerCase()=="delivery"){
                                  charge = deliveryCharge;
                                }else{
                                  charge = 0;
                                }

                                print('total...... $charge');

                                amount = ((int.parse(hamperPrice) * counts) + charge).toInt();

                                print("Final $amount");

                                if(deliverDate.toLowerCase()=="select delivery date" ||
                                    deliverSession.toLowerCase()=="select delivery time")
                                {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text("Please Select Deliver Date / Deliver Session"),
                                          behavior: SnackBarBehavior.floating,
                                      ));
                                } else if(deliverAddressIndex == -1){
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("Please Select Deliver Address"),
                                        behavior: SnackBarBehavior.floating,
                                      ));
                                } else{
                                  navigateToCheckout();
                                }

                                //navigateToCheckout();
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
                        ),

                  SizedBox(
                    height: 30,
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
