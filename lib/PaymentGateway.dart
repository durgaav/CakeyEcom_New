import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:cakey/ContextData.dart';
import 'package:cakey/Dialogs.dart';
import 'package:cakey/DrawerScreens/CakeTypes.dart';
import 'package:cakey/DrawerScreens/HomeScreen.dart';
import 'package:cakey/Notification/Notification.dart';
import 'package:cakey/functions.dart';
import 'package:cakey/screens/coupon_codes_list.dart';
import 'package:cakey/screens/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../DrawerScreens/Notifications.dart';
import 'package:path/path.dart' as Path;
import 'package:http_parser/http_parser.dart';

class PaymentGateway extends StatefulWidget {

  var paymentObjs = {};
  PaymentGateway({required this.paymentObjs});

  @override
  State<PaymentGateway> createState() => _PaymentGatewayState(paymentObjs: paymentObjs);
}

class _PaymentGatewayState extends State<PaymentGateway> {

  var paymentObjs = {};
  _PaymentGatewayState({required this.paymentObjs});

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
  String hamTitle = "";


  List<String> toppings = [];
  List<String> productContains = [];
  bool expanded = true;
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

  //delivery
  int adminDeliveryCharge = 0;
  int adminDeliveryChargeKm = 0;
  String userLatitude = "";
  String userLongtitude = "";
  String deliveryChargeCustomer = "";

  var itemTotal = 0.0;
  var deliveryTotal = 0.0;
  var discountTotal = 0.0;
  var gstTotal = 0.0;
  var sgstTotal = 0.0;
  var totalBillAmount = 0.0;
  var tempBillTotal = 0.0;
  double sharePercentage = 0.0;


  var couponCtrl = new TextEditingController();

  var _razorpay = Razorpay();

  String codeID = "";

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
                    // proceedOrder(amount);
                    if(paymentObjs['type'].toString().toLowerCase()=="hamper"){
                      handleHamperOrder();
                    }else if(paymentObjs['type'].toString().toLowerCase()=="cakes"){
                      handleCakeOrder();
                    }else if(paymentObjs['type'].toString().toLowerCase()=="other"){

                    }else{

                    }
                  }
                },
                child: Text('Order',
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

  //get share percentage...
  Future<void> getSharePercentage() async {

    //[{"_id":"63be89afe7d77c715dc2108d","Percentage":"10","Modified_On":"11-01-2023 03:34 PM","__v":0}]

    try{

      var res = await http.get(
        Uri.parse("${API_URL}api/ProductSharePercentage/list"),
        headers: {'Authorization': authToken}
      );

      if(res.statusCode==200){
        print("Share ${res.body}");

        setState((){
          if(jsonDecode(res.body)['Percentage']!=null && jsonDecode(res.body)['Percentage']!="0"){
            sharePercentage = double.parse(jsonDecode(res.body)['Percentage'].toString());
          }
        });

      }else{
        print("Share ${res.body}");
      }

    }catch(e){
      print("Share $e");
    }

  }

  //calculations
  Future<void> handleCalculations(int tax,var data) async{

    var productPriceUI = data['price'];
    var deliveryChargeUI = data['deliverCharge'];
    var discountsUI = data['discount'];
    var countUI = data['count'];
    var extraChargeUI = data['count'];

    print('Del charge $deliveryChargeUI');

    if(data['type'].toString().toLowerCase()=="hamper"){
      //price + counts
      var initialPrice = double.parse(productPriceUI)*double.parse(countUI.toString());

      //initial + deliver charge
      var secondCalculatePrice = double.parse(initialPrice.toString())+double.parse(deliveryChargeUI.toString());

      //gstAmt = second * tax/100
      var thirdCalculateTax = (double.parse(secondCalculatePrice.toString())*tax)/100;

      //discount = secondCalculate + thirdCalculateTax * discount / 100
      var fourthCalculateDiscount = ((double.parse(secondCalculatePrice.toString())+double.parse(thirdCalculateTax.toString()))*
      double.parse(discountsUI.toString()))/100;

      // print("Calculations....");
      // print(initialPrice);
      // print(secondCalculatePrice);
      // print(thirdCalculateTax);
      // print(fourthCalculateDiscount);
      //
      // print("FinalPrice...${(secondCalculatePrice+thirdCalculateTax-fourthCalculateDiscount).toStringAsFixed(2)}");
      //
      // print("Calculations****");

      setState(() {
        itemTotal = initialPrice;
        deliveryTotal = double.parse(deliveryChargeUI.toString());
        discountTotal = double.parse(fourthCalculateDiscount.toString());
        taxes = (tax).toInt();
        gstTotal = thirdCalculateTax/2;
        sgstTotal = thirdCalculateTax/2;
        totalBillAmount = secondCalculatePrice+thirdCalculateTax-fourthCalculateDiscount;
      });
    }else if(data['type'].toString().toLowerCase()=="cakes"){
      //price + counts
      var initialPrice = double.parse(productPriceUI);

      //initial + deliver charge
      var secondCalculatePrice = double.parse(initialPrice.toString())+double.parse(deliveryChargeUI.toString());

      //gstAmt = second * tax/100
      var thirdCalculateTax = (double.parse(secondCalculatePrice.toString())*tax)/100;

      //discount = secondCalculate + thirdCalculateTax * discount / 100
      var fourthCalculateDiscount = ((double.parse(secondCalculatePrice.toString())+double.parse(thirdCalculateTax.toString()))*
          double.parse(discountsUI.toString()))/100;

      // print("Calculations....");
      // print(initialPrice);
      // print(secondCalculatePrice);
      // print(thirdCalculateTax);
      // print(fourthCalculateDiscount);
      //
      // print("FinalPrice...${(secondCalculatePrice+thirdCalculateTax-fourthCalculateDiscount).toStringAsFixed(2)}");
      //
      // print("Calculations****");

      setState(() {
        itemTotal = initialPrice;
        deliveryTotal = double.parse(deliveryChargeUI.toString());
        discountTotal = double.parse(fourthCalculateDiscount.toString());
        taxes = (tax).toInt();
        gstTotal = thirdCalculateTax/2;
        sgstTotal = thirdCalculateTax/2;
        totalBillAmount = secondCalculatePrice+thirdCalculateTax-fourthCalculateDiscount;
      });
    }

  }

  //handle razor pay order here...
  void _handleOrder() async{

    showAlertDialog();
    var amount = 0.0;
    if(tempBillTotal!=0.0){
      amount = tempBillTotal;
    }else{
      amount = totalBillAmount;
    }


    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Basic ${base64Encode(utf8.encode('rzp_test_b42mo2s6NVrs7t:jjM2u9klomw1v6FAQLG1Anc8'))}'
    };
    var request = http.Request('POST', Uri.parse('https://api.razorpay.com/v1/orders'));
    request.body = json.encode({
      "amount": double.parse(amount.toString())*100,
      "currency": "INR",
      "receipt": "Receipt",
      "notes": {
        "notes_key_1": "Order for cakey",
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

  }

  //handle razorpay payment here...
  void _handleFinalPayment(String amt , String orderId){

    print("Test ord id : $orderId");

    //var amount = Bill.toStringAsFixed(2);

    var options = {
      'key': 'rzp_test_b42mo2s6NVrs7t',
      'amount': double.parse(amt.toString())*100, //in the smallest currency sub-unit.
      'name': 'Surya Prakash',
      'order_id': orderId, // Generate order_id using Orders API
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
      'Authorization': 'Basic ${base64Encode(utf8.encode('rzp_test_b42mo2s6NVrs7t:jjM2u9klomw1v6FAQLG1Anc8'))}',
      'Content-Type': 'application/json'
    };
    var request = http.Request('POST', Uri.parse('https://api.razorpay.com/v1/payments/$payId/capture'));
    request.body = json.encode({
      "amount": int.parse(amount.toString())*100,
      "currency": "INR",
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
      userID = prefs.getString("hampOrdDeliUserId") ?? '';
      authToken = prefs.getString("authToken") ?? '';
      userModId = prefs.getString("hampOrdDeliUserModId") ?? '';
      userName = prefs.getString("hampOrdDeliUser") ?? '';
      userPhone = prefs.getString("hampOrdDeliPhone") ?? '';
      userAddress = prefs.getString("hampOrdDeliAddress") ?? 'null';

      //product
      cakeName = prefs.getString("hampOrdName")??"";
      cakeID = prefs.getString("hampOrdId")??"";
      cakeModId = prefs.getString("hampOrdModId")??"";
      cakeDesc = prefs.getString("hamOrdDescription")??"";
      cakeImage = prefs.getString("hamOrdImage")??"";
      cakePrice = prefs.getString("hamOrdPrice")??"";
      eggOreggless = prefs.getString("hamOrdEggorEggless")??"";
      productContains = prefs.getStringList("hamOrdProducts")??[];
      weight = prefs.getString("hamOrdWeight")??"";
      hamTitle = prefs.getString("hamOrdTitle")??"";


      //vendor
      vendorName = prefs.getString("hampOrdVenName")??"";
      vendorID = prefs.getString("hampOrdVenId")??"";
      vendorModId = prefs.getString("hampOrdVenModId")??"";
      vendorAddress = prefs.getString("hampOrdVenAddress")??"";
      vendorPhone1 = prefs.getString("hampOrdVenPhone1")??"";
      vendorPhone2 = prefs.getString("hampOrdVenPhone2")??"";
      vendorLat = prefs.getString("hampOrdVenLatt")??"";
      vendorLong = prefs.getString("hampOrdVenLong")??"";
      notificationTid = prefs.getString("hampOrdVenNotId")??"";


      deliverDate = prefs.getString("hampOrdDeliDate")??"";
      deliverType = prefs.getString("hampOrdDeliType")??"";
      deliverSession = prefs.getString("hampOrdDeliSession")??"";
      counts = prefs.getInt("hamOrdCount")??1;
      deliveryCharge = prefs.getDouble("hamOrdDeliCharge")??0.0;

      // prefs.setInt("hamOrdCount", counts);
      //     prefs.setDouble("hamOrdDeliCharge", charge);
      //     prefs.setDouble("hamOrdTotal", charge);

      // discount = int.parse(prefs.getString("otherOrdDiscount")??"0");
      // otherType =  prefs.getString("otherOrdKgType")??"";
      // cakeSubType =  prefs.getString("otherOrdSubTypee")??"";

    });

    getSharePercentage();
  }

  Future<void> getTaxDetails() async{

    var pref = await SharedPreferences.getInstance();

    setState(() {
      userModId = pref.getString("userModId") ?? '';
      userID = pref.getString("userID") ?? '';
      userName = pref.getString("userName") ?? '';
      userPhone = pref.getString("phoneNumber") ?? '';
      authToken = pref.getString("authToken") ?? '';
    });

    showAlertDialog();

    try{
      var headers = {
        'Authorization': '$authToken'
      };
      var request = http.Request('GET', Uri.parse('${API_URL}api/tax/list'));

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      List map = jsonDecode(await response.stream.bytesToString());

      print("Tax-----> $map");

      if (response.statusCode == 200) {

        Navigator.pop(context);
        setState(() {
          // taxes = int.parse(map[0]['Total_GST']);
          // myTax = (myPrice * taxes)/100;
          // gstPrice = myTax/2;
          // sgstPrice = myTax/2;
          // pref.setDouble('orderCakeGst', gstPrice);
          // pref.setDouble('orderCakeSGst', sgstPrice);
          // pref.setInt('orderCakeTaxperc', taxes??0);
          handleCalculations(int.parse(map[0]['Total_GST']), paymentObjs);
        });
        print(map);
      }
      else {
        print(map);
        Navigator.pop(context);
        setState(() {
          handleCalculations(0, paymentObjs);
          // taxes = int.parse("0");
          // myTax = (myPrice * taxes)/100;
          // gstPrice = myTax/2;
          // sgstPrice = myTax/2;

          // pref.setDouble('orderCakeGst', gstPrice);
          // pref.setDouble('orderCakeSGst', sgstPrice);
          // pref.setInt('orderCakeTaxperc', taxes??0);
        });
        print(response.reasonPhrase);
      }
    }catch(e){
      print(e);
      Navigator.pop(context);
      setState(() {
        handleCalculations(0, paymentObjs);
        // taxes = int.parse("0");
        // myTax = (myPrice * taxes)/100;
        // gstPrice = myTax/2;
        // sgstPrice = myTax/2;
        // pref.setDouble('orderCakeGst', gstPrice);
        // pref.setDouble('orderCakeSGst', sgstPrice);
        // pref.setInt('orderCakeTaxperc', taxes??0);
      });
    }

    getVendorDetails();

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

  //payment handlers...
  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    // Do something when payment succeeds
    print("Pay success : "+response.paymentId.toString());
    // _capturePayment(response.paymentId.toString());
    // var amount = ( ((
    //     (double.parse(cakePrice)*counts) + deliveryCharge
    // ) - tempDiscountPrice) - discountPrice + gstPrice + sgstPrice).toStringAsFixed(2);
    // proceedOrder(amount);

    if(paymentObjs['type'].toString().toLowerCase()=="hamper"){
      handleHamperOrder();
    }else if(paymentObjs['type'].toString().toLowerCase()=="cakes"){
      handleCakeOrder();
    }else if(paymentObjs['type'].toString().toLowerCase()=="others"){

    }else{

    }

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

  //make hamper order
  Future<void> handleHamperOrder() async{
    var obj = paymentObjs['details'];

    var totalValue = 0.0;
    if(tempBillTotal!=0.0){
      totalValue = tempBillTotal;
    }else{
      totalValue = totalBillAmount;
    }

    showAlertDialog();
    try{
      var headers = {
        'Content-Type': 'application/json'
      };
      var request = http.Request('POST', Uri.parse('${API_URL}api/hamperorder/new'));
      request.body = json.encode({
        "HamperID":obj['_id'],
        "Hamper_ID":obj['Id'],
        "HampersName": obj['HampersName'],
        "Product_Contains":obj['Product_Contains'],
        "HamperImage": obj['HamperImage'],
        "Description":obj['Description'],
        "VendorID": obj['VendorID'],
        "Vendor_ID": obj['Vendor_ID'],
        "VendorName": obj['VendorName'],
        "EggOrEggless": obj['EggOrEggless'],
        "VendorPhoneNumber1": obj['VendorPhoneNumber1'],
        "VendorPhoneNumber2": obj['VendorPhoneNumber2'].toString(),
        "VendorAddress":obj['VendorAddress'],
        "GoogleLocation": {
          "Latitude": obj['GoogleLocation']['Latitude'],
          "Longitude": obj['GoogleLocation']['Longitude']
        },
        "UserID":userID,
        "User_ID":userModId,
        "UserName":userName,
        "UserPhoneNumber":userPhone,
        "DeliveryAddress":paymentObjs['deliveryAddress'],
        "DeliveryDate": paymentObjs['deliverDate'],
        "DeliverySession": paymentObjs['deliverSession'],
        "DeliveryInformation":paymentObjs['deliverType'],
        "Discount":discountTotal,
        "Price":itemTotal,
        "ItemCount":paymentObjs['count'],
        "DeliveryCharge":deliveryTotal,
        "Gst":gstTotal,
        "Sgst":sgstTotal,
        "Tax":taxes.toString(),
        "Total":"${totalValue.toStringAsFixed(2)}",
        "Weight": obj['Weight'],
        "Title": obj['Title'],
        "PaymentType": paymentType,
        "PaymentStatus":paymentType.toLowerCase()=="cash on delivery"?"Cash On Delivery":'Paid',
        "SharePercentage":sharePercentage,
      });
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        Navigator.pop(context);
        var map = jsonDecode(await response.stream.bytesToString());
        if(map['statusCode']==200){
          //Navigator.pop(context);
          showOrderCompleteSheet();
          sendNotificationToVendor(notificationTid);

          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(map['message'].toString()+" Our executive will contact you soon"),
              behavior: SnackBarBehavior.floating
          ));

          Functions().deleteCouponCode(codeID);
        }

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
      context.read<ContextData>().setCodeData({});
    }catch(e){
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error occurred"),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
          ));
    }

  }

  //make cake order
  Future<void> handleCakeOrder() async{
    var obj = paymentObjs['details'];
    topperPrice = int.parse(paymentObjs['topper_price'].toString());
    var totalValue = 0.0;
    if(tempBillTotal!=0.0){
      totalValue = tempBillTotal;
    }else{
      totalValue = totalBillAmount;
    }

    showAlertDialog();

     try{

      var data = {
        "CakeID": obj['_id'],
        "Cake_ID": obj['Id'],
        "CakeName": obj['CakeName'],
        "CakeCommonName": obj['CakeCommonName'],
        "Image": obj['MainCakeImage'],
        "EggOrEggless": paymentObjs['egg'],
        "Flavour":paymentObjs['flavours'],
        "Shape":paymentObjs['shapes'],
        //"Tier":'',
        "Weight":paymentObjs['weight'],
        "Description": obj['Description'],
        "PaymentStatus": paymentType.toLowerCase()=="cash on delivery"?"Cash On Delivery":"Paid",
        "PaymentType": paymentType,
        "Total": "${totalValue.toStringAsFixed(2)}",
        "Sgst": sgstTotal.toString(),
        "Gst": gstTotal.toString(),
        "DeliveryCharge": paymentObjs['deliverCharge'].toString(),
        "ExtraCharges": paymentObjs['extra_charges'].toString(),
        "Discount":discountTotal,
        "ItemCount": paymentObjs['count'],
        "Price": paymentObjs['cake_price'],
        "DeliverySession": paymentObjs['deliverSession'],
        "DeliveryDate": paymentObjs['deliverDate'],
        "UserPhoneNumber": userPhone,
        "UserName": userName,
        "UserID": userID,
        "User_ID": userModId,
        "Tax":taxes.toString(),
        "DeliveryInformation": paymentObjs['deliverType'],
        "DeliveryAddress": userAddress,
        "PremiumVendor":"n",
        "VendorName":obj['VendorName'],
        "VendorID":obj['VendorID'],
        "Vendor_ID":obj['Vendor_ID'],
        "VendorPhoneNumber1":obj['VendorPhoneNumber1'],
        "VendorPhoneNumber2":obj['VendorPhoneNumber2'].toString(),
        "VendorAddress":obj['VendorAddress'],
        "GoogleLocation":{
          "Latitude":obj['GoogleLocation']['Latitude'],
          "Longitude":obj['GoogleLocation']['Longitude']
        },
        "MessageOnTheCake":paymentObjs['msg_on_cake'],
        "SpecialRequest":paymentObjs['spl_req'],
        "SharePercentage":sharePercentage,
      };

      if(topperPrice!=0){
        data.addAll({
          "TopperId":paymentObjs['topper_id'],
          "TopperName":paymentObjs['topper_name'],
          "TopperImage":paymentObjs['topper_image'],
          "TopperPrice":paymentObjs['topper_price'],
        });
      }



      var body = jsonEncode('object');

      // if(premiumVendor == 'yes'){
      //   body = jsonEncode(premiumData);
      // }else{
      body = jsonEncode(data);
      //}

      print(body);

      //http://sugitechnologies.com:88

      var response = await http.post(Uri.parse("${API_URL}api/order/new"),
          headers: {"Content-Type": "application/json"},
          body:body
      );

      var map = jsonDecode(response.body);
    //
      if(response.statusCode == 200){

        if(map['statusCode']==200){
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(map['message'].toString()+" Our executive will contact you soon"),
              behavior: SnackBarBehavior.floating
          ));

          Functions().deleteCouponCode(codeID);
          NotificationService().showNotifications(map['message'], "Your $cakeName Ordered.Thank You!");
          showOrderCompleteSheet();
        }else{
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(map['message']),
              behavior: SnackBarBehavior.floating
          ));
        }

      }else{

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(map['message']),
            behavior: SnackBarBehavior.floating
        ));
        Navigator.pop(context);

      }
      context.read<ContextData>().setCodeData({});
    } catch(e){
      print('error...');
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Unable to place order!"),
          behavior: SnackBarBehavior.floating
      ));
      Navigator.pop(context);
    }

  }

  ///make the order
  Future<void> proceedOrder(amount) async{

    showAlertDialog();

    double delCharge = 0.0;

    if(deliverType.toLowerCase() == "delivery"){
      delCharge = double.parse(
          ((adminDeliveryCharge / adminDeliveryChargeKm) *
              (calculateDistance(double.parse(userLatitude), double.parse(userLongtitude),
                  double.parse(vendorLat.toString()), double.parse(vendorLong)))).toStringAsFixed(1)
      );
    }else{
      delCharge = 0;
    }

    print(amount);

    var headers = {
      'Content-Type': 'application/json'
    };
    var request = http.Request('POST', Uri.parse('${API_URL}api/hamperorder/new'));
    request.body = json.encode({
      "HamperID": "$cakeID",
      "Hamper_ID": "$cakeModId",
      "HampersName": "$cakeName",
      "Product_Contains": productContains,
      "HamperImage": "${cakeImage}",
      "Description": "$cakeDesc",
      "VendorID": "$vendorID",
      "Vendor_ID": "$vendorModId",
      "VendorName": "$vendorName",
      "EggOrEggless": "$eggOreggless",
      "VendorPhoneNumber1": "$vendorPhone1",
      "VendorPhoneNumber2": "$vendorPhone2",
      "VendorAddress": "$vendorAddress",
      "GoogleLocation": {
        "Latitude": "$vendorLat",
        "Longitude": "$vendorLong"
      },
      "UserID": "$userID",
      "User_ID": "$userModId",
      "UserName": "$userName",
      "UserPhoneNumber": "$userPhone",
      "DeliveryAddress": "$userAddress",
      "DeliveryDate": "$deliverDate",
      "DeliverySession": "$deliverSession",
      "DeliveryInformation": "$deliverType",
      "Discount": "$tempDiscountPrice",
      "Price": "$cakePrice",
      "ItemCount": "$counts",
      "DeliveryCharge": "$delCharge",
      "Gst":gstPrice,
      "Sgst":sgstPrice,
      "Tax":taxes,
      "Total": "$amount",
      "Weight": "$weight",
      "Title": "$hamTitle",
      "PaymentType": "$paymentType",
      "PaymentStatus":paymentType.toLowerCase()=="cash on delivery"?"Cash On Delivery":'Paid'
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {

      var map = jsonDecode(await response.stream.bytesToString());

      if(map['statusCode']==200){
        //Navigator.pop(context);
        showOrderCompleteSheet();
        sendNotificationToVendor(notificationTid);
      }

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(map['message'].toString()),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
          )
      );

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


  Future<void> getVendorDetails() async {

    try{

      var headers = {
        'Authorization': '$authToken'
      };
      var request = http.Request('GET', Uri.parse('${API_URL}api/vendors/list'));

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      List map = jsonDecode(await response.stream.bytesToString());

      if(response.statusCode == 200){

        Map filtered = map.where((element) => element['_id'].toString().toLowerCase()==paymentObjs['vendor_id'].toString().toLowerCase()).toList()[0];

        print("filltered... $filtered");

        setState(() {
          vendorModId = filtered['Id'].toString();
          vendorName = filtered['VendorName'].toString();
          vendorAddress = filtered['Address'].toString();
          vendorLong = filtered['GoogleLocation']['Longitude'].toString();
          vendorLat = filtered['GoogleLocation']['Latitude'].toString();
          vendorPhone1 = filtered['PhoneNumber1'].toString();
          vendorPhone2 = filtered['PhoneNumber2'].toString();
        });

      }else{

      }

    }catch(e){

    }

  }

  //endregion

  @override
  void initState() {
    // TODO: implement initState
    Future.delayed(Duration.zero , () async{
      recieveDetailsFromScreen();
      getTaxDetails();
      context.read<ContextData>().setCodeData({});
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

    if(context.watch<ContextData>().getCodeDetails()=={}){

    }else{
       if(context.watch<ContextData>().getCodeDetails()['value']!=null){
         tempBillTotal = 0.0;
         codeID = context.watch<ContextData>().getCodeDetails()['id'];
         if(context.watch<ContextData>().getCodeDetails()['type']=="amount"){
           tempBillTotal = totalBillAmount-double.parse(context.watch<ContextData>().getCodeDetails()['value']);
           couponCtrl.text = context.watch<ContextData>().getCodeDetails()['code'];
         }else{
           double discountAmount = (totalBillAmount*double.parse(context.watch<ContextData>().getCodeDetails()['value']))/100;
           tempBillTotal = totalBillAmount-discountAmount;
           couponCtrl.text = context.watch<ContextData>().getCodeDetails()['code'];
           print("Context ----> $tempBillTotal");
         }
       }else{

       }
    }

    return WillPopScope(
      onWillPop:() async {
        context.read<ContextData>().setCodeData({});
        return true;
      },
      child: Scaffold(
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
                border: Border.all(color: Colors.black26, width: 1)
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      cakeImage!="null"?
                      Container(
                        height: 75,
                        width: 75,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            image: DecorationImage(
                                image:NetworkImage("${paymentObjs['img']}"),
                                fit: BoxFit.cover
                            )
                        ),
                      ):
                      Container(
                        height: 75,
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
                                child: Text('${paymentObjs['name']}'
                                  // '(Rs.$cakePrice) x $counts'
                                  ,style: TextStyle(
                                      fontSize: 12,fontFamily: "Poppins",fontWeight: FontWeight.bold
                                  ),overflow: TextOverflow.ellipsis,maxLines: 10,),
                              ),
                              SizedBox(height: 5,),
                              Text('${paymentObjs['egg']}',
                                  style: TextStyle(
                                      fontSize: 11,fontFamily: "Poppins",color: Colors.grey[500]
                                  ),
                                  overflow: TextOverflow.ellipsis,maxLines: 10
                              ),
                              // SizedBox(height: 5,),
                              // Text('Shape - None Flavour - None',
                              //     style: TextStyle(
                              //         fontSize: 11,fontFamily: "Poppins",color: Colors.grey[500]
                              //     ),
                              //     overflow: TextOverflow.ellipsis,maxLines: 10
                              // ),
                              // SizedBox(height: 5,),
                              // Wrap(
                              //   children: [
                              //     for(var i in flavs)
                              //       Text("(Flavour - ${i}) "
                              //         // "Price - Rs.${i['Price']})"
                              //         ,style: TextStyle(
                              //             fontSize:10.5,fontFamily: "Poppins",
                              //             color: Colors.grey[500]
                              //         ),),
                              //   ],
                              // ),
                              SizedBox(height: 5,),
                              Text.rich(
                                  TextSpan(
                                      text:'₹ ${itemTotal.toStringAsFixed(2)}',
                                      style: TextStyle(
                                          fontSize: 15,color: lightPink,fontWeight: FontWeight.bold,
                                          fontFamily: "Poppins"),
                                      children: [
                                        TextSpan(
                                          text: " *(includes selected weight,flavours,shape,toppers.)",
                                          style: TextStyle(
                                              fontSize: 8,color: darkBlue,
                                              fontFamily: "Poppins"),
                                        )
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
                              paymentObjs['weight']!=null && changeWeight(paymentObjs['weight'])>5.0?"Premium Vendor":
                            '${paymentObjs['vendor']}',style: TextStyle(
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
                                    Functions().handleChatWithVendors(context, paymentObjs['vendor_mail'], paymentObjs['vendor']);
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
                              Text('${paymentObjs['type']}',style: TextStyle(
                                  fontSize: 14,fontFamily: "Poppins",
                                  fontWeight: FontWeight.bold,color: Colors.black
                              ),),
                            ],
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(left: 10,right: 10),
                          color: Colors.grey[400],
                          height: 0.8,
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
                                    paymentObjs['deliverType'].toLowerCase()=="delivery"?
                                    "${paymentObjs['deliveryAddress'].trim()}":'Pickuping by you.',
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
                          color: Colors.grey[400],
                          height: 0.8,
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
                                  onTap:(){
                                    FocusScope.of(context).unfocus();
                                    context.read<ContextData>().setCodeData({});
                                    Navigator.push(context,
                                    MaterialPageRoute(builder: (c)=>CouponsList(userID)));
                                  },
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
                                  message: "Item total depends on item count/selected shape,flavour,article,weight",
                                  child:
                                  Text('₹ ${itemTotal.toStringAsFixed(2)}'
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
                              Text('₹ ${deliveryTotal.toStringAsFixed(2)}',style: const TextStyle(fontWeight: FontWeight.bold),),
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
                                        child: Text('${paymentObjs['discount']} %',style: const TextStyle(fontSize:10.5,),)
                                    ),
                                    Text('₹ ${discountTotal.toStringAsFixed(2)}',style: const TextStyle(fontWeight: FontWeight.bold),),
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
                              const Text('GST',style: const TextStyle(
                                fontFamily: "Poppins",
                                color: Colors.black54,
                              ),),
                              Row(
                                  children:[
                                    Container(
                                        padding:EdgeInsets.only(right:5),
                                        child: Text('${(taxes).toString()} %',style: const TextStyle(fontSize:10.5,),)
                                    ),
                                    Text('₹ ${gstTotal.toStringAsFixed(2)}',style: const TextStyle(fontWeight: FontWeight.bold),),
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
                                        child: Text('${(taxes).toString()} %',style: const TextStyle(fontSize:10.5,),)
                                    ),
                                    Text('₹ ${sgstTotal.toStringAsFixed(2)}',style: const TextStyle(fontWeight: FontWeight.bold),),
                                  ]
                              )
                            ],
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(left: 10,right: 10),
                          color: Colors.grey[400],
                          height: 0.8,
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

                              Text('₹ ${tempBillTotal!=0.0?tempBillTotal.toStringAsFixed(2):
                              totalBillAmount.toStringAsFixed(2)}',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17),)
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  ExpansionTile(
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
                    maintainState: true,
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
          )),
    );
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


