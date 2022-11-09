import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:cakey/Dialogs.dart';
import 'package:cakey/DrawerScreens/HomeScreen.dart';
import 'package:cakey/Notification/Notification.dart';
import 'package:cakey/OtherProducts/OtherDetails.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../DrawerScreens/Notifications.dart';
import 'package:path/path.dart' as Path;
import 'package:http_parser/http_parser.dart';

class OtherCheckout extends StatefulWidget {

  List artic , flavs ;
  OtherCheckout(this.artic, this.flavs);

  @override
  State<OtherCheckout> createState() => _OtherCheckoutState(artic: artic,flavs: flavs);
}

class _OtherCheckoutState extends State<OtherCheckout> {

  List artic , flavs ;
  _OtherCheckoutState({required this.artic, required this.flavs});

  //Colors
  Color lightGrey = Color(0xffF5F5F5);
  Color darkBlue = Color(0xffF213959);
  Color lightPink = Color(0xffFE8416D);

  String poppins = "Poppins";
  List<bool> isExpands = [];

  String paymentType = "Online Payment";
  bool isExpand = false;
  var paymentIndex = 0;

  //Strings
  String cakeName = '';
  String cakeCommonName = '';
  String cakeID = '';
  String cakeModId = '';
  String shape = '';
  String flavour = '';
  String weight = '1';
  String cakeImage = '';
  String cakeDesc = '';
  String cakePrice = '1';
  String cakeType = '';
  String cakeSubType = '';
  String eggOreggless = '';
  String deliverDate = '';
  String deliverSession = '';
  String cakeMessage = '';
  String cakeSplReq = '';
  String cakeArticle = '';
  String deliverType = '';
  double extraCharges = 0;
  String orderFromCustom = 'no';
  String premiumVendor = 'no';
  String themeName = "My Theme";
  String themeFileName = "";
  int tierPrice = 0;
  String tierCkWeight = "";
  String tierCakeWeight = "0";
  String cakeTier = "";
  String topperId = "";
  String topperName = '';
  String topperImg= '';
  String authToken= '';
  int topperPrice = 0;
  String vendorLat = "";
  String vendorLong = "";
  double finalTotal = 0;
  String otherType = "";
  String pricePerKg = "";


  List<String> toppings = [];

  //HYVOOB9SJFHMFA8L

  //vendor
  String vendorName = '';
  String vendorModId = '';
  String vendorMobile = '';
  String vendorID = '';
  String vendorAddress = '';
  String vendorPhone1= '';
  String vendorPhone2 = '';
  String notificationTid = "";

  //User
  String userAddress = '';
  String userName = '';
  String userModId = '';
  String userID = '';
  String userPhone = '';

  //int
  //int
  double itemsTotal = 0;
  int counts = 1;
  double deliveryCharge = 0;
  int discount = 0;
  int tempDiscount = 0;
  int taxes = 0;
  double bilTotal = 0;

  double gstPrice = 0;
  double sgstPrice = 0;
  double discountPrice = 0;
  double tempDiscountPrice = 0;

  double tempPrice = 0;
  double tempTax = 0;

  var expanded = true;

  //delivery
  int adminDeliveryCharge = 0;
  int adminDeliveryChargeKm = 0;
  String userLatitude = "";
  String userLongtitude = "";
  String deliveryChargeCustomer = "";

  var couponCtrl = new TextEditingController();

  var _razorpay = Razorpay();


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

  void showOrderCompleteSheet() {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(20),
              topLeft: Radius.circular(20),
            )),
        context: context,
        builder: (context) {
          return Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 15,
                ),
                Container(
                  height: 150,
                  width: 150,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                          image: AssetImage('assets/images/chefdoll.jpg'),
                          fit: BoxFit.cover)),
                ),
                SizedBox(
                  height: 15,
                ),
                Text('THANK YOU',
                    style: TextStyle(
                        color: Colors.deepPurple,
                        fontFamily: "Poppins",
                        fontSize: 23,
                        fontWeight: FontWeight.bold)),
                Text('for your order',
                    style: TextStyle(
                        color: Colors.deepPurple,
                        fontFamily: "Poppins",
                        fontSize: 13,
                        fontWeight: FontWeight.bold)),
                SizedBox(
                  height: 15,
                ),
                Center(
                  child: Text(
                    'Your order is now being processed.'
                        '\nWe will let you know once the order is picked \nfrom the outlet.',
                    style: TextStyle(
                        color: Colors.grey,
                        fontFamily: "Poppins",
                        fontSize: 13,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => HomeScreen()),
                        ModalRoute.withName('/HomeScreen')
                    );
                  },
                  child: Center(
                      child: Text(
                        'BACK TO HOME',
                        style: TextStyle(
                            color: lightPink,
                            fontFamily: "Poppins",
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline
                        ),
                        textAlign: TextAlign.center,
                      )),
                ),
              ],
            ),
          );
        });
  }

  //Confirm order
  void showConfirmOrder(){
    showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)
            ),
            title: Text('Order'
              ,style: TextStyle(color: darkBlue,fontWeight: FontWeight.bold,fontFamily: "Poppins"),
            ),
            content: Text('Your Order Will Be Placed.',
              style: TextStyle(color: Colors.black,fontWeight: FontWeight.normal,fontFamily: "Poppins"),
            ),
            actions: [
              FlatButton(
                onPressed: (){
                  Navigator.pop(context);
                },
                child: Text('Cancel',
                  style: TextStyle(color: Colors.deepPurple,fontFamily: "Poppins"),
                ),
              ),
              FlatButton(
                onPressed: (){
                  Navigator.pop(context);
                  if(paymentType.toLowerCase()=="online payment"){
                    _handleOrder();
                  }else{
                    handleOrderKgs();
                  }
                },
                child: Text('Ok',
                  style: TextStyle(color: Colors.deepPurple,fontFamily: "Poppins"),
                ),
              ),
            ],
          );
        }
    );
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
                          Text(status=="done"?'Your payment for $cakeName was successful.'
                              :"Your payment for $cakeName was unsuccessful.",style: TextStyle(
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

  //region Functions

  //handle razor pay order here...
  void _handleOrder() async{

    showAlertDialog();

    var amount = ( ((
        double.parse(cakePrice) + deliveryCharge
    ) - tempDiscountPrice) - discountPrice + sgstPrice+gstPrice).toStringAsFixed(2);

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Basic ${base64Encode(utf8.encode('rzp_live_rmfBgI2OrqZR4j:sMcew08MYYxPwnksKmDLpKsj'))}'
    };
    var request = http.Request('POST', Uri.parse('https://api.razorpay.com/v1/orders'));
    request.body = json.encode({
      "amount": double.parse(amount.toString())*100,
      "currency": "INR",
      "receipt": "Receipt",
      "notes": {
        "notes_key_1": "Order for $cakeName",
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

  //handle razorpay payment here...
  void _handleFinalPayment(String amt , String orderId){

    print("Test ord id : $orderId");

    var amount = ( ((
        double.parse(cakePrice) + deliveryCharge
    ) - tempDiscountPrice) - discountPrice + sgstPrice+gstPrice).toStringAsFixed(2);

    var options = {
      'key': 'rzp_live_rmfBgI2OrqZR4j',
      'amount': double.parse(amount.toString())*100, //in the smallest currency sub-unit.
      'name': 'Surya Prakash',
      'order_id': "$orderId", // Generate order_id using Orders API
      'description': '$cakeName',
      'timeout': 300, // in seconds
      'prefill': {
        'contact': '$userPhone',
        // 'email': '$userName',
        'email': '',
      },
      "theme":{
        "color":'#E8416D'
      },
      // "method": {
      //   "netbanking": false,
      //   "card": true,
      //   "upi": true,
      //   "wallet": false,
      //   "emi": false,
      //   "paylater": false
      // },
    };

    print(options);

    _razorpay.open(options);
  }

  //capture the payment....
  void _capturePayment(String payId) async {

    var amount = 0;

    if(orderFromCustom!="no"){
      amount = ((((double.parse(cakePrice)*
          double.parse(weight.toLowerCase().replaceAll("kg", "")))+
          extraCharges)+(double.parse(gstPrice.toString())+double.parse(sgstPrice.toString())))-
          tempDiscountPrice).toInt();
    }else{
      amount = ((counts *
          ((double.parse(cakePrice)*
              double.parse(weight.replaceAll("kg", "")))+
              (extraCharges))+
          sgstPrice+gstPrice+deliveryCharge)-tempDiscountPrice).toInt();
    }

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

  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  //getting order prefs...
  Future<void> recieveDetailsFromScreen() async{

    var prefs = await SharedPreferences.getInstance();


    setState((){
      //user
      userID = prefs.getString("userID") ?? '';
      authToken = prefs.getString("authToken") ?? '';
      userModId = prefs.getString("userModId") ?? '';
      userName = prefs.getString("userName") ?? '';
      userPhone = prefs.getString("phoneNumber") ?? '';
      userAddress = prefs.getString("otherOrdDeliveryAdrs") ?? 'null';

      cakeName = prefs.getString("otherOrdName")??"";
      pricePerKg = prefs.getString("otherOrdPricePerKg")??"";
      cakeCommonName = prefs.getString("otherOrdCommonName")??"";
      shape = prefs.getString("otherOrdShape")??"";
      cakeID = prefs.getString("otherOrdMainId")??"";
      cakeModId = prefs.getString("otherOrdModID")??"";
      cakeDesc = prefs.getString("otherOrdDescrip")??"";
      cakeImage = prefs.getString("otherOrdImage")??"";
      cakePrice = prefs.getString("otherOrdPrice")??"";
      eggOreggless = prefs.getString("otherOrdEgg")??"";
      weight = prefs.getString("otherOrdWeight")??"";


      //vendor
      vendorName = prefs.getString("otherOrdVenName")??"";
      vendorID = prefs.getString("otherOrdVenMainID")??"";
      vendorModId = prefs.getString("otherOrdVenModId")??"";
      vendorAddress = prefs.getString("otherOrdVenAddress")??"";
      vendorPhone1 = prefs.getString("otherOrdVenPhn1")??"";
      vendorPhone2 = prefs.getString("otherOrdVenPhn2")??"";
      vendorLat = prefs.getString("otherOrdVenLat")??"";
      vendorLong = prefs.getString("otherOrdVenLong")??"";
      notificationTid = prefs.getString("otherOrdVenNotiID")??"";


      deliverDate = prefs.getString("otherOrdDeliDate")??"";
      deliverType = prefs.getString("otherOrdPickOrDel")??"";
      deliverSession = prefs.getString("otherOrdDeliSession")??"";
      counts = prefs.getInt("otherOrdCounter")??1;
      deliveryCharge = double.parse(prefs.getString("otherOrdDeliveryCharge")??"0.0");

      discount = int.parse(prefs.getString("otherOrdDiscount")??"0");
      otherType =  prefs.getString("otherOrdKgType")??"";
      cakeSubType =  prefs.getString("otherOrdSubTypee")??"";

    });

    getTaxDetails();

  }

  Future<void> getTaxDetails() async{

    var pref = await SharedPreferences.getInstance();

    showAlertDialog();

    double myTax = 0;
    double myPrice = double.parse(cakePrice);

    //prefs.setDouble('orderCakeGst', gst);
    //prefs.setDouble('orderCakeSGst', sgst);
    //prefs.setInt('orderCakeTaxperc', taxes??0);

    try{
      var headers = {
        'Authorization': '$authToken'
      };
      var request = http.Request('GET', Uri.parse('http://sugitechnologies.com/cakey/api/tax/list'));

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {

        List map = jsonDecode(await response.stream.bytesToString());

        Navigator.pop(context);
        setState(() {
          taxes = int.parse(map[0]['Total_GST']);
          myTax = (myPrice * taxes)/100;
          gstPrice = myTax/2;
          sgstPrice = myTax/2;

          // pref.setDouble('orderCakeGst', gstPrice);
          // pref.setDouble('orderCakeSGst', sgstPrice);
          // pref.setInt('orderCakeTaxperc', taxes??0);

        });
        print(map);
      }
      else {
        Navigator.pop(context);
        setState(() {
          taxes = int.parse("0");
          myTax = (myPrice * taxes)/100;
          gstPrice = myTax/2;
          sgstPrice = myTax/2;

          // pref.setDouble('orderCakeGst', gstPrice);
          // pref.setDouble('orderCakeSGst', sgstPrice);
          // pref.setInt('orderCakeTaxperc', taxes??0);
        });
        print(response.reasonPhrase);
      }
    }catch(e){
      Navigator.pop(context);
      setState(() {
        taxes = int.parse("0");
        myTax = (myPrice * taxes)/100;
        gstPrice = myTax/2;
        sgstPrice = myTax/2;

        // pref.setDouble('orderCakeGst', gstPrice);
        // pref.setDouble('orderCakeSGst', sgstPrice);
        // pref.setInt('orderCakeTaxperc', taxes??0);
      });
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
        "body": "Hi $vendorName , $cakeName is just Ordered By $userName."
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

  //confirm order
  Future<void> orderTypeKg() async{

    showAlertDialog();

    var amount = ( ((
        double.parse(cakePrice) + deliveryCharge
    ) - tempDiscountPrice) - discountPrice + sgstPrice+gstPrice).toStringAsFixed(2);


    var headers = {
      'Content-Type': 'application/json'
    };
    var request = http.Request('POST',
        Uri.parse('http://sugitechnologies.com/cakey/api/otherproduct/order/new'));
    request.body = json.encode({
      "Other_ProductID": cakeID,
      "Other_Product_ID": cakeModId,
      "ProductName": cakeName,
      "ProductCommonName": cakeCommonName,
      "CakeType": "Others",
      "CakeSubType": cakeSubType,
      "Image": cakeImage,
      "EggOrEggless": eggOreggless,
      "Flavour": flavs,
      "Shape": shape,
      "ProductMinWeightPerKg": {
        "Weight": weight,
        "PricePerKg": pricePerKg
      },
      "Description": cakeDesc,
      "VendorID": vendorID,
      "Vendor_ID": vendorModId,
      "VendorName":vendorName,
      "VendorPhoneNumber1": vendorPhone1,
      "VendorPhoneNumber2": vendorPhone2,
      "VendorAddress": vendorAddress,
      "GoogleLocation": {
        "Latitude": vendorLat,
        "Longitude": vendorLong
      },
      "UserID": userID,
      "User_ID": userModId,
      "UserName": userName,
      "UserPhoneNumber": userPhone,
      "DeliveryAddress": userAddress,
      "DeliveryDate": deliverDate,
      "DeliverySession": deliverSession,
      "DeliveryInformation": deliverType,
      "ItemCount": counts,
      "Discount": tempDiscountPrice,
      "DeliveryCharge": deliveryCharge,
      "Total": amount,
      "Gst":gstPrice,
      "Sgst":sgstPrice,
      "Tax":taxes,
      "PaymentType": paymentType,
      "PaymentStatus": paymentType=="Online Payment"?"Paid":'Cash On Delivery'
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {

      Navigator.pop(context);

      var map = jsonDecode(await response.stream.bytesToString());

      print(map);

      if(map['statusCode']==200){
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(map['message']),
              backgroundColor: Colors.black,
              behavior: SnackBarBehavior.floating,
            )
        );

        sendNotificationToVendor(notificationTid);
        Navigator.pop(context);
        showOrderCompleteSheet();
      }else{
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(map['message']),
              backgroundColor: Colors.black,
              behavior: SnackBarBehavior.floating,
            )
        );
      }
    }
    else {
      Navigator.pop(context);
      print(response.reasonPhrase);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.reasonPhrase.toString()),
            backgroundColor: Colors.black,
            behavior: SnackBarBehavior.floating,
          )
      );
    }

  }

  //confirm unit order
  Future<void> confirmUnitOrd() async{

    showAlertDialog();

    var amount = ( ((
        double.parse(cakePrice) + deliveryCharge
    ) - tempDiscountPrice) - discountPrice + sgstPrice+gstPrice).toStringAsFixed(2);

    var headers = {
      'Content-Type': 'application/json'
    };
    var request = http.Request('POST', Uri.parse('http://sugitechnologies.com/cakey/api/otherproduct/order/new'));
    request.body = json.encode({
      "Other_ProductID": cakeID,
      "Other_Product_ID": cakeModId,
      "ProductName": cakeName,
      "ProductCommonName": cakeCommonName,
      "CakeType": "Others",
      "CakeSubType": cakeSubType,
      "Image": cakeImage,
      "EggOrEggless": eggOreggless,
      "Flavour": flavs,
      "Shape": shape,
      "ProductMinWeightPerUnit": {
        "Weight": weight,
        "ProductCount": counts,
        "PricePerUnit": pricePerKg
      },
      "Description": cakeDesc,
      "VendorID": vendorID,
      "Vendor_ID": vendorModId,
      "VendorName":vendorName,
      "VendorPhoneNumber1": vendorPhone1,
      "VendorPhoneNumber2": vendorPhone2,
      "VendorAddress": vendorAddress,
      "GoogleLocation": {
        "Latitude": vendorLat,
        "Longitude": vendorLong
      },
      "UserID": userID,
      "User_ID": userModId,
      "UserName": userName,
      "UserPhoneNumber": userPhone,
      "DeliveryAddress": userAddress,
      "DeliveryDate": deliverDate,
      "DeliverySession": deliverSession,
      "DeliveryInformation": deliverType,
      "Discount": tempDiscountPrice,
      "DeliveryCharge": deliveryCharge,
      "Gst":gstPrice,
      "Sgst":sgstPrice,
      "Tax":taxes,
      "Total": amount,
      "PaymentType": paymentType,
      "PaymentStatus": paymentType=="Online Payment"?"Paid":'Cash On Delivery'
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {

      Navigator.pop(context);

      var map = jsonDecode(await response.stream.bytesToString());

      print(map);

      if(map['statusCode']==200){
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(map['message']),
              backgroundColor: Colors.black,
              behavior: SnackBarBehavior.floating,
            )
        );
        sendNotificationToVendor(notificationTid);
        Navigator.pop(context);
        showOrderCompleteSheet();
      }else{
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(map['message']),
              backgroundColor: Colors.black,
              behavior: SnackBarBehavior.floating,
            )
        );
      }
    }
    else {
      Navigator.pop(context);
      print(response.reasonPhrase);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.reasonPhrase.toString()),
            backgroundColor: Colors.black,
            behavior: SnackBarBehavior.floating,
          )
      );
    }

  }

  //confirm unit order
  Future<void> confirmBoxOrd() async{

    showAlertDialog();

    var amount = ( ((
        double.parse(cakePrice) + deliveryCharge
    ) - tempDiscountPrice) - discountPrice + sgstPrice+gstPrice).toStringAsFixed(2);

    var headers = {
      'Content-Type': 'application/json'
    };
    var request = http.Request('POST', Uri.parse('http://sugitechnologies.com/cakey/api/otherproduct/order/new'));
    request.body = json.encode({
      "Other_ProductID": cakeID,
      "Other_Product_ID": cakeModId,
      "ProductName": cakeName,
      "ProductCommonName": cakeCommonName,
      "CakeType": "Others",
      "CakeSubType": cakeSubType,
      "Image": cakeImage,
      "EggOrEggless": eggOreggless,
      "Flavour": flavs,
      "Shape": shape,
      "ProductMinWeightPerBox": {
        "Piece":weight,
        "ProductCount":counts,
        "PricePerBox":pricePerKg
      },
      "Description": cakeDesc,
      "VendorID": vendorID,
      "Vendor_ID": vendorModId,
      "VendorName":vendorName,
      "VendorPhoneNumber1": vendorPhone1,
      "VendorPhoneNumber2": vendorPhone2,
      "VendorAddress": vendorAddress,
      "GoogleLocation": {
        "Latitude": vendorLat,
        "Longitude": vendorLong
      },
      "UserID": userID,
      "User_ID": userModId,
      "UserName": userName,
      "UserPhoneNumber": userPhone,
      "DeliveryAddress": userAddress,
      "DeliveryDate": deliverDate,
      "DeliverySession": deliverSession,
      "DeliveryInformation": deliverType,
      "Discount": tempDiscountPrice,
      "DeliveryCharge": deliveryCharge,
      "Gst":gstPrice,
      "Sgst":sgstPrice,
      "Tax":taxes,
      "Total": amount,
      "PaymentType": paymentType,
      "PaymentStatus": paymentType=="Online Payment"?"Paid":'Cash On Delivery'
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {

      Navigator.pop(context);

      var map = jsonDecode(await response.stream.bytesToString());

      print(map);

      if(map['statusCode']==200){
        sendNotificationToVendor(notificationTid);
        Navigator.pop(context);
        showOrderCompleteSheet();
      }else{
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(map['message']),
              backgroundColor: Colors.black,
              behavior: SnackBarBehavior.floating,
            )
        );
      }
    }
    else {
      Navigator.pop(context);
      print(response.reasonPhrase);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.reasonPhrase.toString()),
            backgroundColor: Colors.black,
            behavior: SnackBarBehavior.floating,
          )
      );
    }

  }

  //confirm
  handleOrderKgs() {
    if(otherType=="Kg"){
      orderTypeKg();
    }else if(otherType=="Unit"){
      confirmUnitOrd();
    }else{
      confirmBoxOrd();
    }
  }

  //payment handlers...
  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    // Do something when payment succeeds
    print("Pay success : "+response.paymentId.toString());
    // _capturePayment(response.paymentId.toString());
    handleOrderKgs();
    // showPaymentDoneAlert("done");
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    // Do something when payment fails
    print("Pay error : "+response.toString());
    showPaymentDoneAlert("failed");
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // Do something when an external wallet is selected
    print("wallet : "+response.toString());
    // showPaymentDoneAlert("failed");
  }

  //endregion

  @override
  void initState() {
    // TODO: implement initState
    Future.delayed(Duration.zero , () async{
      recieveDetailsFromScreen();
    });
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    super.initState();
  }

  @override
  void dispose(){
    _razorpay.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: Container(
            margin: EdgeInsets.all(12),
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
          title: Text(
              'CHECKOUT',
              style: TextStyle(
                  color: darkBlue, fontWeight: FontWeight.bold, fontSize: 15)),
          elevation: 0.0,
          backgroundColor: lightGrey,
          actions: [
            Stack(
              alignment: Alignment.center,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            Notifications(),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
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
                        borderRadius: BorderRadius.circular(8)),
                    child: Icon(
                      Icons.notifications_none,
                      color: darkBlue,
                    ),
                  ),
                ),
                Positioned(
                  left: 15,
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
          ],
        ),
        body: Container(
          width: double.infinity,
          margin: EdgeInsets.all(15),
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Colors.black26, width: 1)),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    cakeImage!="null"?
                    Container(
                      height: 90,
                      width: 75,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          image: DecorationImage(
                              image:NetworkImage("${cakeImage}"),
                              fit: BoxFit.cover
                          )
                      ),
                    ):
                    Container(
                      height: 90,
                      width: 75,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          image: DecorationImage(
                              image:AssetImage("assets/images/chefdoll.jpg"),
                              fit: BoxFit.cover
                          )
                      ),
                    ),
                    SizedBox(
                      width: 7,
                    ),
                    Expanded(
                        child:
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              child: Text('${cakeName} '
                                // '(Rs.$cakePrice) x $counts'
                                ,style: TextStyle(
                                    fontSize: 12,fontFamily: "Poppins",fontWeight: FontWeight.bold
                                ),overflow: TextOverflow.ellipsis,maxLines: 10,),
                            ),
                            SizedBox(height: 5,),
                            Text('(Shape - $shape)',style: TextStyle(
                                fontSize: 11,fontFamily: "Poppins",color: Colors.grey[500]
                            ),overflow: TextOverflow.ellipsis,maxLines: 10),
                            // SizedBox(height: 5,),
                            Wrap(
                              children: [
                                for(var i in flavs)
                                  Text("(Flavour - ${i}) "
                                    // "Price - Rs.${i['Price']})"
                                    ,style: TextStyle(
                                        fontSize:10.5,fontFamily: "Poppins",
                                        color: Colors.grey[500]
                                    ),),
                              ],
                            ),
                            Text.rich(
                                TextSpan(
                                    text:'₹ $cakePrice',
                                    style: TextStyle(
                                        fontSize: 15,color: lightPink,fontWeight: FontWeight.bold,
                                        fontFamily: "Poppins"),
                                    children: [

                                    ]
                                )
                            ),
                          ],
                        )
                    )
                  ],
                ),
                SizedBox(height: 15,),
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(bottomRight: Radius.circular(25)
                          ,bottomLeft:  Radius.circular(15)
                      ),
                      color: Colors.grey[200]
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        title: const Text('Vendor',style: const TextStyle(
                            fontSize: 11,fontFamily: "Poppins"
                        ),),
                        subtitle: Text(
                          '${vendorName}',style: TextStyle(
                            fontSize: 14,fontFamily: "Poppins",
                            fontWeight: FontWeight.bold,color: Colors.black
                        ),),
                        trailing: Container(
                          width: 100,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              InkWell(
                                onTap: () async{
                                  PhoneDialog().showPhoneDialog(context, vendorPhone1, vendorPhone2);
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  height: 35,
                                  width: 35,
                                  decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white
                                  ),
                                  child:const Icon(Icons.phone,color: Colors.blueAccent,),
                                ),
                              ),
                              const SizedBox(width: 10,),
                              InkWell(
                                onTap: () async{
                                  //PhoneDialog().showPhoneDialog(context, vendorPhone1, vendorPhone2 , true);
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  height: 35,
                                  width: 35,
                                  decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white
                                  ),
                                  child:const Icon(Icons.whatsapp_rounded,color: Colors.green,),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.only(left: 15,bottom: 10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Cake Type',style: TextStyle(
                                fontSize: 11,fontFamily: "Poppins"
                            ),),
                            Text('Other Products',style: TextStyle(
                                fontSize: 14,fontFamily: "Poppins",
                                fontWeight: FontWeight.bold,color: Colors.black
                            ),),
                          ],
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 10,right: 10),
                        color: Colors.black26,
                        height: 1,
                      ),
                      const SizedBox(height: 15,),
                      Container(
                        // color: Colors.green,
                        margin : EdgeInsets.only(left: 5),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.location_on,
                              color: Colors.red,
                            ),
                            SizedBox(width: 5,),
                            Expanded(
                                child: Text(
                                  deliverType.toLowerCase()=="delivery"?
                                  "${userAddress.trim()}":'Pickuping by you.',
                                  style: TextStyle(
                                    fontFamily: "Poppins",
                                    color: Colors.black54,
                                    fontSize: 13,
                                  ),
                                )
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 7,),

                      Container(
                        margin: const EdgeInsets.only(left: 10,right: 10),
                        color: Colors.black26,
                        height: 1,
                      ),

                      Container(
                        padding: EdgeInsets.only(top: 10,bottom: 10),
                        width: double.infinity,
                        color: Colors.white,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding:EdgeInsets.only(left: 5),
                              child: Text("Apply Coupon",
                                style: TextStyle(
                                    color: darkBlue,
                                    fontFamily: "Poppins",
                                    fontSize: 12
                                ),),
                            ),
                            SizedBox(height: 6,),
                            Container(
                              margin: EdgeInsets.only(left: 7,right: 7),
                              height: 40,
                              child: TextField(
                                style: TextStyle(
                                    fontFamily: "Poppins",
                                    fontSize: 13,
                                    color:darkBlue
                                ),
                                controller: couponCtrl,
                                onChanged: (text){
                                  setState((){
                                    if(couponCtrl.text.toLowerCase()=="bbq12m"){

                                      setState((){
                                        discountPrice = (double.parse(cakePrice)*discount)/100;
                                        tempDiscount = discount;
                                      });

                                      ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Discount Applied.!'),
                                            backgroundColor: Colors.green,
                                          )
                                      );
                                    }else{

                                      setState((){
                                        discountPrice = 0;
                                        tempDiscount = 0;
                                      });

                                    }
                                  });
                                },
                                maxLines: 1,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.all(5),
                                  hintStyle: TextStyle(
                                      fontFamily: "Poppins",fontSize: 13
                                  ),
                                  hintText: "Coupon code",
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),

                      Container(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text('Product Total',style: TextStyle(
                              fontFamily: "Poppins",
                              color: Colors.black54,
                            ),),
                            Tooltip(
                                margin: EdgeInsets.only(left: 15,right: 15),
                                padding: EdgeInsets.all(15),
                                message: "Item total depends on itemcount/selected shape,flavour,article,weight",
                                child:
                                Text('₹ ${double.parse(cakePrice).toStringAsFixed(2)}'
                                  ,style: const TextStyle(fontWeight: FontWeight.bold),)

                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text('Delivery charge',style: const TextStyle(
                              fontFamily: "Poppins",
                              color: Colors.black54,
                            ),),
                            Text('₹ ${deliveryCharge.toStringAsFixed(2)}',style: const TextStyle(fontWeight: FontWeight.bold),),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text('Discounts',style: const TextStyle(
                              fontFamily: "Poppins",
                              color: Colors.black54,
                            ),),
                            Row(
                                children:[
                                  Container(
                                      padding:EdgeInsets.only(right:5),
                                      child: Text('${tempDiscount} %',style: const TextStyle(fontSize:10.5,),)
                                  ),
                                  Text('₹ ${discountPrice.toStringAsFixed(2)}',style: const TextStyle(fontWeight: FontWeight.bold),),
                                ]
                            )
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text('CGST',style: const TextStyle(
                              fontFamily: "Poppins",
                              color: Colors.black54,
                            ),),
                            Row(
                                children:[
                                  Container(
                                      padding:EdgeInsets.only(right:5),
                                      child: Text('${taxes} %',style: const TextStyle(fontSize:10.5,),)
                                  ),
                                  Text('₹ ${gstPrice.toStringAsFixed(2)}',style: const TextStyle(fontWeight: FontWeight.bold),),
                                ]
                            )
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text('SGST',style: const TextStyle(
                              fontFamily: "Poppins",
                              color: Colors.black54,
                            ),),
                            Row(
                                children:[
                                  Container(
                                      padding:EdgeInsets.only(right:5),
                                      child: Text('${taxes} %',style: const TextStyle(fontSize:10.5,),)
                                  ),
                                  Text('₹ ${sgstPrice.toStringAsFixed(2)}',style: const TextStyle(fontWeight: FontWeight.bold),),
                                ]
                            )
                          ],
                        ),
                      ),

                      Container(
                        margin: const EdgeInsets.only(left: 10,right: 10),
                        color: Colors.black26,
                        height: 1,
                      ),
                      Container(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text('Bill Total',style: TextStyle(
                                fontFamily: "Poppins",
                                color: Colors.black,
                                fontWeight: FontWeight.bold
                            ),),

                            Text('₹ ${
                                ( ((
                                    double.parse(cakePrice) + deliveryCharge
                                ) - tempDiscountPrice) - discountPrice + sgstPrice+gstPrice).toStringAsFixed(2)
                            }',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17),)
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: EdgeInsets.zero,
                  child: Theme(
                    data: ThemeData().copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      maintainState: true,
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
                        'Payment type',
                        style: TextStyle(
                            color: Colors.grey[400],
                            fontFamily: "Poppins",
                            fontSize: 13),
                      ),
                      subtitle: Text(
                        '$paymentType',
                        style: TextStyle(
                            color: darkBlue,
                            fontFamily: "Poppins",
                            fontSize: 14,
                            fontWeight: FontWeight.bold),
                      ),
                      trailing: !expanded?
                      Container(
                        alignment: Alignment.center,
                        height: 25,
                        width: 25,
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          shape: BoxShape.circle ,
                        ),
                        child: Icon(Icons.keyboard_arrow_down_rounded , color: darkBlue,size: 25,),
                      ):
                      Container(
                        alignment: Alignment.center,
                        height: 25,
                        width: 25,
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          shape: BoxShape.circle ,
                        ),
                        child: Icon(Icons.keyboard_arrow_up , color: darkBlue,size: 25,),
                      ),
                      children: [
                        ListTile(
                          onTap: () {
                            setState(() {
                              paymentType = "Online Payment";
                              paymentIndex = 0;
                            });
                          },
                          leading: paymentIndex!=0?
                          Icon(Icons.radio_button_unchecked_rounded , color: Colors.green,):
                          Icon(Icons.check_circle , color: Colors.green,),
                          title: Text(
                            'Online Payment',
                            style: TextStyle(
                                color: darkBlue,
                                fontFamily: "Poppins",
                                fontSize: 14,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        ListTile(
                          onTap: () {
                            setState(() {
                              paymentType = "Cash on delivery";
                              paymentIndex = 1;
                            });
                          },
                          leading: paymentIndex!=1?
                          Icon(Icons.radio_button_unchecked_rounded , color: Colors.green,):
                          Icon(Icons.check_circle , color: Colors.green,),
                          title: Text(
                            'Cash On Delivery',
                            style: TextStyle(
                                color: darkBlue,
                                fontFamily: "Poppins",
                                fontSize: 14,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        // ListTile(
                        //   onTap: () {
                        //     setState(() {
                        //       paymentType = "Credit Card";
                        //       paymentIndex = 2;
                        //     });
                        //   },
                        //   leading: paymentIndex!=2?
                        //   Icon(Icons.radio_button_unchecked_rounded , color: Colors.green,):
                        //   Icon(Icons.check_circle , color: Colors.green,),
                        //   title: Text(
                        //     'Credit Card',
                        //     style: TextStyle(
                        //         color: darkBlue,
                        //         fontFamily: "Poppins",
                        //         fontSize: 14,
                        //         fontWeight: FontWeight.bold),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 3,bottom: 3),
                  color: lightPink,
                  height: 0.3,
                ),

                SizedBox(
                  height: 15,
                ),
                Container(
                  height: 50,
                  width: 200,
                  decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(25)),
                  child: RaisedButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25)),
                    onPressed: () {
                      // _handleOrder();
                      showConfirmOrder();
                      // sendNotificationToVendor(notificationTid);
                    },
                    color: lightPink,
                    child: Text(
                      paymentType.toLowerCase()=="cash on delivery"?
                      "ORDER NOW":'PROCEED TO PAY',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                )
              ],
            ),
          ),
        ));
  }
}

class CardExpirationFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final newValueString = newValue.text;
    String valueToReturn = '';

    for (int i = 0; i < newValueString.length; i++) {
      if (newValueString[i] != '/') valueToReturn += newValueString[i];
      var nonZeroIndex = i + 1;
      final contains = valueToReturn.contains(RegExp(r'\/'));
      if (nonZeroIndex % 2 == 0 &&
          nonZeroIndex != newValueString.length &&
          !(contains)) {
        valueToReturn += '/';
      }
    }
    return newValue.copyWith(
      text: valueToReturn,
      selection: TextSelection.fromPosition(
        TextPosition(offset: valueToReturn.length),
      ),
    );
  }
}


class MaskedTextInputFormatter extends TextInputFormatter {
  final String mask;
  final String separator;

  MaskedTextInputFormatter({
    required this.mask,
    required this.separator,
  }) { assert(mask != null); assert (separator != null); }

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if(newValue.text.length > 0) {
      if(newValue.text.length > oldValue.text.length) {
        if(newValue.text.length > mask.length) return oldValue;
        if(newValue.text.length < mask.length && mask[newValue.text.length - 1] == separator) {
          return TextEditingValue(
            text: '${oldValue.text}$separator${newValue.text.substring(newValue.text.length-1)}',
            selection: TextSelection.collapsed(
              offset: newValue.selection.end + 1,
            ),
          );
        }
      }
    }
    return newValue;
  }
}