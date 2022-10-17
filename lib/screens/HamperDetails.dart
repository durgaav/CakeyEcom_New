import 'dart:convert';
import 'dart:math';
import 'package:cakey/screens/HamperCheckout.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:http/http.dart' as http;
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../ContextData.dart';
import '../Dialogs.dart';
import '../DrawerScreens/CustomiseCake.dart';
import 'AddressScreen.dart';

class HamperDetails extends StatefulWidget {
  const HamperDetails({Key? key}) : super(key: key);

  @override
  State<HamperDetails> createState() => _HamperDetailsState();
}

class _HamperDetailsState extends State<HamperDetails> {
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
      hamImages = pref.getStringList("hamperImages")??[];
      userId = pref.getString("userID") ?? '';
      user_ID = pref.getString("userModId") ?? '';
      userName = pref.getString("userName") ?? '';
      userPhone = pref.getString("phoneNumber") ?? '';
      deliveryAddress = pref.getString("userAddress") ?? 'null';
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

    getVendor(hampVenId);

    print(hamImages.length);


  }

  //geting vendor
  Future<void> getVendor(String id) async {
    showAlertDialog();
    print(id);

    List forFilter = [];

    try{
      var headers = {'Authorization': '$authToken'};
      var request = http.Request(
          'GET', Uri.parse('http://sugitechnologies.com/cakey/api/vendors/list'));

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
                    (calculateDistance(double.parse(userLatitude), double.parse(userLongtitude),
                        double.parse(vendrorLat.toString()), double.parse(vendrorLong)))).toStringAsFixed(1)
            );
          }
        });

        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.reasonPhrase.toString()))
        );
        Navigator.pop(context);
      }
    }catch(e){
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("error occurred"))
      );
      Navigator.pop(context);
    }

  }

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
                Text('Order Confirmation' , style: TextStyle(
                    color:darkBlue , fontSize: 14.5 , fontFamily: "Poppins",
                    fontWeight: FontWeight.bold
                ),),
              ],
            ),
            content: Text('This Process Cannot Be Undone! Do You Want To Proceed Checkout ?' , style: TextStyle(
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
                    showCheckoutSheet();
                  },
                  child: Text('Proceed')
              ),
            ],
          ),
    );
  }

  //showcheckout
  void showCheckoutSheet() {

    int index = 0;
    var payType = "Online Payment";
    double delCharge = 0.0;

    if(fixedDelliverMethod.toLowerCase()=="pickup"){
      delCharge = 0.0;
    }else{
      delCharge = double.parse(
          ((adminDeliveryCharge / adminDeliveryChargeKm) *
      (calculateDistance(double.parse(userLatitude),
      double.parse(userLongtitude), double.parse(vendrorLat.toString()), double.parse(vendrorLong)))).toStringAsFixed(1)
      );
    }


    showModalBottomSheet(
      isScrollControlled: true,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
          topRight: Radius.circular(15),
          topLeft: Radius.circular(15),
        )),
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                  topRight: Radius.circular(20),
                  topLeft: Radius.circular(20),
                )),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 8,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'CHECKOUT',
                          style: TextStyle(
                              color: darkBlue,
                              fontFamily: "Poppins",
                              fontWeight: FontWeight.bold,
                              fontSize: 18
                          ),
                        ),
                        Container(
                          child: InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                              height: 30,
                              width: 30,
                              decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(7)),
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.close,
                                size: 25,
                                color: lightPink,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 0, right: 0),
                      height: 0.4,
                      color: Colors.black,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      hamperName,
                      style: TextStyle(color: darkBlue, fontFamily: "Poppins" ,fontSize: 16),
                    ),
                    SizedBox(height: 10,),
                    Container(
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
                                  " ${(double.parse(hamperPrice)+delCharge) * counts}",
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
                                  setState(() {
                                    if (counts > 1) {
                                      counts = counts - 1;
                                    }
                                  });
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
                                    counts<10?
                                    '0$counts':
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
                          ]),
                    ),
                    SizedBox(height: 10,),
                    GridView(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisExtent: 115,
                          crossAxisSpacing: 6,
                          mainAxisSpacing: 6
                      ),
                      children: [
                        Card(
                          elevation: 2.0,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.calendar_month,
                                color: darkBlue,
                                size: 35,
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Text(
                                deliverDate,
                                style: TextStyle(
                                    color: lightPink, fontFamily: "Poppins"),
                              )
                            ],
                          ),
                        ),
                        Card(
                          elevation: 2.0,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.access_alarm_sharp,
                                color: darkBlue,
                                size: 35,
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Text(
                                deliverSession,
                                style: TextStyle(
                                    color: lightPink, fontFamily: "Poppins"),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10,),

                    Card(
                      elevation: 2.0,
                      child:Container(
                        padding: EdgeInsets.all(10),
                        child: Row(
                          children: [
                            Icon(Icons.delivery_dining , color: lightPink,size: 30,),
                            SizedBox(width: 6,),
                            Expanded(child: Text(
                              fixedDelliverMethod.toLowerCase()=="delivery"?
                              deliveryAddress.trim():'Pickup by you', style: TextStyle(
                              color: darkBlue , fontFamily: "Poppins"
                            ),
                            ))
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 10,),

                    GestureDetector(
                      onTap: ()=>setState((){
                        index = 0;
                        paymentMethod = "Online Payment";
                        payType = "Online Payment";
                      }),
                      child: Container(
                        padding:EdgeInsets.all(8),
                        child: Row(
                          children: [
                            index==0?
                            Icon(Icons.radio_button_checked , color: Colors.green, size: 26,):
                            Icon(Icons.radio_button_unchecked_rounded , color: Colors.grey, size: 26,),
                            SizedBox(width: 6,),
                            Expanded(child: Text(
                              'Online Payment' ,
                              style: TextStyle(
                                color: darkBlue ,
                                fontWeight: FontWeight.bold,
                                fontFamily: "Poppins"
                              ),
                            ))
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 6,),
                    GestureDetector(
                      onTap: ()=>setState((){
                        index = 1;
                        paymentMethod = "Cash On Delivery";
                        payType = "Cash On Delivery";
                      }),
                      child: Container(
                        padding:EdgeInsets.all(8),
                        child: Row(
                          children: [
                            index==1?
                            Icon(Icons.radio_button_checked , color: Colors.green, size: 26,):
                            Icon(Icons.radio_button_unchecked_rounded , color: Colors.grey, size: 26,),
                            SizedBox(width: 6,),
                            Expanded(child: Text(
                              'Cash On $fixedDelliverMethod' ,
                              style: TextStyle(
                                color: darkBlue ,
                                fontWeight: FontWeight.bold,
                                fontFamily: "Poppins"
                              ),
                            ))
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 10,),

                    Center(
                      child: Container(
                        height: 50,
                        width: 220,
                        child: RaisedButton(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          color: Colors.pink,
                          onPressed: () {

                            // int charge = 0;
                            //
                            // if(fixedDelliverMethod.toLowerCase()=="delivery"){
                            //   charge = deliveryCharge;
                            // }else{
                            //   charge = 0;
                            // }

                            // print('total...... $charge');

                            // print(
                            //     ((int.parse(hamperPrice) * counts) + charge).toInt().toString()
                            // );

                            Navigator.pop(context);

                            // if(payType.toLowerCase()=="cash on delivery"){
                            //   proceedOrder((((int.parse(hamperPrice)+delCharge) * counts) + charge).toInt().toString());
                            // }else{
                            //   _handleOrder((((int.parse(hamperPrice)+delCharge) * counts) + charge).toInt().toString());
                            // }

                          },
                          child: Text(
                            "PROCEED",
                            style: TextStyle(
                                color: Colors.white, fontFamily: "Poppins",fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10,),

                    //end
                  ],
                ),
              );
            },
          );
        });
  }

  //handle razor pay order here...
  void _handleOrder(var amount) async{

    showAlertDialog();

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Basic ${base64Encode(utf8.encode('rzp_live_rmfBgI2OrqZR4j:sMcew08MYYxPwnksKmDLpKsj'))}'
    };
    var request = http.Request('POST', Uri.parse('https://api.razorpay.com/v1/orders'));
    request.body = json.encode({
      "amount": int.parse(amount.toString())*100,
      "currency": "INR",
      "receipt": "Receipt",
      "notes": {
        "notes_key_1": "Order for $hamperName",
        // "notes_key_2": "Order for $cakeName"
      }
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var res = jsonDecode(await response.stream.bytesToString());
      print(res);
      _handleFinalPayment(res['amount'].toString() , res['id']);
      Navigator.pop(context);
    }
    else {
      // print();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Payment Error : "
          +response.reasonPhrase.toString())));
    }

    //{id: order_K1RKAn7G9lnanu, entity: order, amount: "700", amount_paid: "0",
    // amount_due: "700", currency: INR, receipt: Receipt, offer_id: null, status: created,
    // attempts: "0", notes: {notes_key_1: Order for Vanilla Cake}, created_at: "1659590700"}


    // var amount = 0.0;
    //
    // if(orderFromCustom!="no"){
    //   amount = ((((double.parse(cakePrice)*
    //       double.parse(weight.toLowerCase().replaceAll("kg", "")))+
    //       extraCharges)+(double.parse(gstPrice.toString())+double.parse(sgstPrice.toString())))-
    //       tempDiscountPrice);
    // }else{
    //   amount = ((counts * (
    //       double.parse(cakePrice)*
    //           double.parse(weight.toLowerCase().replaceAll('kg', ""))+
    //           (extraCharges*double.parse(weight.toLowerCase().replaceAll('kg', "")))
    //   ) + double.parse((tempTax).toString()) +
    //       deliveryCharge)
    //       - tempDiscountPrice);
    // }
    //

  }

  void _capturePayment(String payId) async {

    var amount = 0;

    var headers = {
      'Authorization': 'Basic ${base64Encode(utf8.encode('rzp_live_rmfBgI2OrqZR4j:sMcew08MYYxPwnksKmDLpKsj'))}',
      'Content-Type': 'application/json'
    };
    var request = http.Request('POST', Uri.parse('https://api.razorpay.com/v1/payments/$payId/capture'));
    request.body = json.encode({
      "amount": int.parse(amount.toString())*100,
      "currency": "INR"
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

  //handle razorpay payment here...
  void _handleFinalPayment(String amt , String orderId){

    print("Test ord id : $orderId");

    var amount = 0;

    var options = {
      'key': 'rzp_live_rmfBgI2OrqZR4j',
      'amount': int.parse(amount.toString())*100, //in the smallest currency sub-unit.
      'name': 'Surya Prakash',
      'order_id': "$orderId", // Generate order_id using Orders API
      'description': '$hamperName',
      'timeout': 300, // in seconds
      'prefill': {
        'contact': '',
        // 'email': '$userName',
        'email': 'test@gmail.com',
      },
      "theme":{
        "color":'#E8416D'
      },
    };

    print(options);

    _razorpay.open(options);
  }

  //payment done alert
  void showPaymentDoneAlert(String status){
    showDialog(
        context: context,
        builder: (context){
          return Dialog(
            child: Container(
                height: 85,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12)
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 6,
                      decoration: BoxDecoration(
                        color: status=="done"?Colors.green:Colors.red,
                        // borderRadius:BorderRadius.only(
                        //   topLeft: Radius.circular(12),
                        //   bottomLeft: Radius.circular(12),
                        // )
                      ),
                    ),
                    SizedBox(width: 10,),
                    Icon(
                      status=="done"?Icons.check_circle_rounded:Icons.cancel,
                      color: status=="done"?Colors.green:Colors.red,
                      size: 45,
                    ),
                    SizedBox(width: 10,),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(status=="done"?"Payment Complete":"Payment Not Complete",style: TextStyle(
                            color: Colors.black,
                            fontFamily: "Poppins",
                            fontWeight: FontWeight.bold,
                          ),),
                          Text(status=="done"?'Your payment for $hamperName was successful.'
                              :"Your payment for $hamperName was unsuccessful.",style: TextStyle(
                              color: Colors.black,
                              fontFamily: "Poppins",
                              fontSize: 12
                          ),)
                        ],
                      ),
                    )
                  ],
                )
            ),
          );
        }
    );
  }

  //payment handlers...
  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    // Do something when payment succeeds
    print("Pay success : "+response.paymentId.toString());
    proceedOrder(amount);
    // _capturePayment(response.paymentId.toString());
    // showPaymentDoneAlert("done");
  }

  ///make the order
  Future<void> proceedOrder(amount) async{

    showAlertDialog();

    double delCharge = 0.0;

    if(fixedDelliverMethod.toLowerCase() == "delivery"){
      delCharge = double.parse(
          ((adminDeliveryCharge / adminDeliveryChargeKm) *
              (calculateDistance(double.parse(userLatitude), double.parse(userLongtitude),
                  double.parse(vendrorLat.toString()), double.parse(vendrorLong)))).toStringAsFixed(1)
      );
    }else{
      delCharge = 0;
    }


    var headers = {
      'Content-Type': 'application/json'
    };
    var request = http.Request('POST', Uri.parse('http://sugitechnologies.com/cakey/api/hamperorder/new'));
    request.body = json.encode({
      "HamperID": "$hamper_id",
      "Hamper_ID": "$hampeModid",
      "HampersName": "$hamperName",
      "Product_Contains": productContains,
      "HamperImage": "${hamImages[0]}",
      "Description": "$hamperDescription",
      "VendorID": "$vendor_Id",
      "Vendor_ID": "$vendorId",
      "VendorName": "$vendrorName",
      "EggOrEggless": "$eggOregless",
      "VendorPhoneNumber1": "$vendrorPhone1",
      "VendorPhoneNumber2": "$vendrorPhonr2",
      "VendorAddress": "$vendorAddress",
      "GoogleLocation": {
        "Latitude": "$vendrorLat",
        "Longitude": "$vendrorLong"
      },
      "UserID": "$userId",
      "User_ID": "$user_ID",
      "UserName": "$userName",
      "UserPhoneNumber": "$userPhone",
      "DeliveryAddress": "$deliveryAddress",
      "DeliveryDate": "$deliverDate",
      "DeliverySession": "$deliverSession",
      "DeliveryInformation": "$fixedDelliverMethod",
      "Price": "$hamperPrice",
      "ItemCount": "$counts",
      "DeliveryCharge": "$delCharge",
      "Total": "$amount",
      "Weight": "$hamWeight",
      "Title": "$hamTitle",
      "PaymentType": "$paymentMethod",
      "PaymentStatus":paymentMethod.toLowerCase()=="cash on delivery"?"Cash On Delivery":'Paid'
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {

      var map = jsonDecode(await response.stream.bytesToString());

      if(map['statusCode']==200){
        sendNotificationToVendor(noId);
      }

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(map['message'].toString()),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
          ));

    }
    else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.reasonPhrase.toString()),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
          ));
      Navigator.pop(context);
    }

  }

  Future<void> sendNotificationToVendor(String? NoId) async{

    // NoId = "e8q8xT7QT8KdOJC6yuCvrq:APA91bG4-TMDV4jziIvirbC4JYxFPyZHReJJIuKwo4i9QKwedMP35ohnFo1_F53JuJruAlDHl02ux3qt6gUpqj1b3UMjg0b6zqSTO1jB14cXz7Zw7kKz25Q_3_p1CJx-8bwPjFq5lnwR";

    // NoId = "cIGDQG_OR-6RRd5rPRhtIe:APA91bFo_G99mVRJzsrki-G_A6zYRe3SU8WR7Q-U29DL7Th7yngUcKU2fnXz-OFFu24qLkbopgO2chyQRlMjLBZU6uupSY31gIDa0qDNKB9yqQarVBX0LtkzT73JIpQ-6xlxYpic9Yt8";

    var headers = {
      'Authorization': 'Bearer AAAAVEy30Xg:APA91bF5xyWHGwKu-u1N5lxeKd6f9RMbg-R5y3i7fVdy6zNjdloAM6B69P6hXa_g2dlgNxVtwx3tszzKrHq-ql2Kytgv7HvkfA36RiV5PntCdzz_Jve0ElPJRM0kfCKicfxl1vFyudtm',
      'Content-Type': 'application/json'
    };
    var request = http.Request('POST', Uri.parse('https://fcm.googleapis.com/fcm/send'));
    request.body = json.encode({
      "registration_ids": [
        "$NoId",
      ],
      "notification": {
        "title": "New Order Is Here!",
        "body": "Hi $vendrorName , $hamperName is just Ordered By $userName."
      },
      "data": {
        "msgId": "msg_12342"
      }
    });
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    print(response.statusCode);

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
    }
    else {
      print(response.reasonPhrase);
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    // Do something when payment fails
    print("Pay error : "+response.toString());
    showPaymentDoneAlert("failed");
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // Do something when an external wallet is selected
    print("wallet : "+response.toString());
    showPaymentDoneAlert("failed");
  }

  Future<void> passToCheckout() async{

    print(user_ID);
    print(productContains);

    double charge = 0.0;
    double total = 0.0;

    if(fixedDelliverMethod.toLowerCase()=="delivery"){
      charge = double.parse(deliveryCharge.toString());
    }else{
      charge = 0;
    }

    total = double.parse(((double.parse(hamperPrice) * counts) + charge).toStringAsFixed(1));

    var prefs = await SharedPreferences.getInstance();

    //hampers...
    prefs.setString("hampOrdName", hamperName);
    prefs.setString("hampOrdId", hamper_id);
    prefs.setString("hampOrdModId", hampeModid);
    prefs.setString("hamOrdPrice", hamperPrice);
    prefs.setString("hamOrdImage", hamImages[0]);
    prefs.setString("hamOrdDescription", hamperDescription);
    prefs.setStringList("hamOrdProducts", productContains);
    prefs.setString("hamOrdEggorEggless", eggOregless);
    prefs.setString("hamOrdWeight", hamWeight);
    prefs.setString("hamOrdTitle", hamTitle);

    //vendor...
    prefs.setString("hampOrdVenName", vendrorName);
    prefs.setString("hampOrdVenId", vendor_Id);
    prefs.setString("hampOrdVenModId", vendorId);
    prefs.setString("hampOrdVenAddress", vendorAddress);
    prefs.setString("hampOrdVenPhone1", vendrorPhone1);
    prefs.setString("hampOrdVenPhone2", vendrorPhonr2);
    prefs.setString("hampOrdVenLatt", vendrorLat);
    prefs.setString("hampOrdVenLong", vendrorLong);
    prefs.setString("hampOrdVenNotId", noId);

    //deliver user...
    prefs.setString("hampOrdDeliDate", deliverDate);
    prefs.setString("hampOrdDeliSession", deliverSession);
    prefs.setString("hampOrdDeliAddress", deliveryAddress);
    prefs.setString("hampOrdDeliType", fixedDelliverMethod);
    prefs.setString("hampOrdDeliUser", userName);
    prefs.setString("hampOrdDeliPhone", userPhone);
    prefs.setString("hampOrdDeliUserId", userId);
    prefs.setString("hampOrdDeliUserModId", user_ID);

    //for calculations...
    prefs.setInt("hamOrdCount", counts);
    prefs.setDouble("hamOrdDeliCharge", charge);
    prefs.setDouble("hamOrdTotal", total);

    Navigator.push(context, MaterialPageRoute(builder: (context) => HamperCheckout([], [])));

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
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (context.watch<ContextData>().getAddress().isNotEmpty) {
      deliveryAddress = context.watch<ContextData>().getAddress();
    } else {
      deliveryAddress = deliveryAddress;
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
                            itemBuilder: (c,i){
                            var imageUrl = hamImages[i].toString().replaceAll("[", "")
                                .replaceAll("]", "");
                            return Container(
                              margin: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15),
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
                      Expanded(child: Text(
                        '$hamperName',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontFamily: "Poppins",
                            fontSize: 18,
                            color: darkBlue,
                            fontWeight: FontWeight.w600),
                      ),),
                      GestureDetector(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Transform.rotate(
                              angle: 120,
                              child: Icon(
                                Icons.egg_outlined,
                                color: eggOregless.toLowerCase()=="eggless"?
                                Colors.green:
                                eggOregless.toLowerCase()=="egg"?
                                Color(0xff8D2729):Colors.white,
                              ),
                            ),
                            Text(
                              '$eggOregless',
                              style: TextStyle(
                                  color: eggOregless.toLowerCase()=="eggless"?
                                  Colors.green:
                                  eggOregless.toLowerCase()=="egg"?
                                  Color(0xff8D2729):Colors.white,
                                  fontFamily: poppins,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10,),
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
                                  counts<10?
                                  '0$counts':
                                  '$counts',
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
                      style:
                          TextStyle(color: Colors.grey, fontFamily: "Poppins"),
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
                              'Booking Start',
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
                            Text("$startDate",
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
                              'Booking End',
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
                            Text("$endDate",
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
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(14)),
                      child: ExpansionTile(
                        onExpansionChanged: (e){
                          setState((){
                            expanded = e;
                            if(e==true){
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
                          style:
                          TextStyle(color: darkBlue, fontFamily: "Poppins"),
                        ),
                        trailing: !expanded?
                        Container(
                          alignment: Alignment.center,
                          height: 25,
                          width: 25,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle ,
                          ),
                          child: Icon(Icons.keyboard_arrow_down_rounded , color: darkBlue,size: 25,),
                        ):
                        Container(
                          alignment: Alignment.center,
                          height: 25,
                          width: 25,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle ,
                          ),
                          child: Icon(Icons.keyboard_arrow_up , color: darkBlue,size: 25,),
                        ),
                        children: productContains.map((e) {
                          return Container(
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.all(10),
                            child: Text((productContains.indexWhere((element) => element==e)+1).toString()+") $e",
                            style: TextStyle(
                              color: darkBlue,
                              fontFamily: "Poppins",
                            ),),
                          );
                        }).toList(),
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
                      Expanded(child:Container(
                        padding: EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Delivery Start',
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
                            Text("$deliStartDate",
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
                              'Delivery End',
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
                            Text("$deliEndDate",
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
                        builder: (c,child){
                          return Theme(
                              data:ThemeData(
                                  dialogTheme: DialogTheme(
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20)
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
                      deliverDate = simplyFormat(time: SelDate, dateOnly: true);
                    });

                    // print(SelDate.toString());
                    // print(DateTime.now().subtract(Duration(days: 0)));
                  },
                  child: Container(
                      margin: EdgeInsets.all(5),
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border:
                              Border.all(color: Colors.grey[400]!, width: 0.5)),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '$deliverDate',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 13 ,fontFamily: "Poppins"),
                            ),
                            Icon(Icons.edit_calendar_outlined, color: darkBlue)
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
                          borderRadius: BorderRadius.circular(8),
                          border:
                              Border.all(color: Colors.grey[400]!, width: 0.5)),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '$deliverSession',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 13,fontFamily: "Poppins"),
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
                              ListTile(
                                title: Text(
                                  '${deliveryAddress}',
                                  style: TextStyle(
                                      fontFamily: poppins,
                                      color: Colors.grey,
                                      fontSize: 13),
                                ),
                                trailing: Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: 25,
                                ),
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
                  padding: EdgeInsets.only(top:15, left: 10),
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                                    : double.parse(vendrorRating
                                                        .replaceAll(
                                                            RegExp('[^0-9]'),
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
                                                    fontWeight: FontWeight.bold,
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
                                        ((adminDeliveryCharge / adminDeliveryChargeKm) *
                                            (calculateDistance(double.parse(userLatitude),
                                                double.parse(userLongtitude), double.parse(vendrorLat.toString()), double.parse(vendrorLong))))
                                                    .toStringAsFixed(1) == "0.0"

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
                                                "${(calculateDistance(double.parse(userLatitude), double.parse(userLongtitude), double.parse(vendrorLat.toString()),
                                                    double.parse(vendrorLong))).toStringAsFixed(1)} KM Charge Rs.${((adminDeliveryCharge / adminDeliveryChargeKm) *
                                                    (calculateDistance(double.parse(userLatitude),
                                                        double.parse(userLongtitude), double.parse(vendrorLat.toString()), double.parse(vendrorLong)))).toStringAsFixed(1)}",
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
                                                    "$hampVenPhn2");
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

                Center(
                  child: Container(
                    height: 50,
                    width: 200,
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(25)),
                    child: RaisedButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25)),
                      onPressed: () async {
                        FocusScope.of(context).unfocus();

                        // int charge = 0;
                        //
                        // if(fixedDelliverMethod.toLowerCase()=="delivery"){
                        //   charge = deliveryCharge;
                        // }else{
                        //   charge = 0;
                        // }
                        //
                        // print('total...... $charge');
                        //
                        // amount = ((int.parse(hamperPrice) * counts) + charge).toInt();
                        //
                        // print("Final $amount");

                        if(deliverDate.toLowerCase()=="select delivery date" ||
                            deliverSession.toLowerCase()=="select delivery time")
                        {
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text("Please Select Deliver Date / Deliver Session"),
                                  behavior: SnackBarBehavior.floating,
                              ));
                        }else{
                          passToCheckout();
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
                  height: 30,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
