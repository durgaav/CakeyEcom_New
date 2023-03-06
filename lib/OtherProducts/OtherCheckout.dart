import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:cakey/ContextData.dart';
import 'package:cakey/Dialogs.dart';
import 'package:cakey/DrawerScreens/HomeScreen.dart';
import 'package:cakey/Notification/Notification.dart';
import 'package:cakey/OtherProducts/OtherDetails.dart';
import 'package:cakey/drawermenu/CustomAppBars.dart';
import 'package:cakey/functions.dart';
import 'package:cakey/raised_button_utils.dart';
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
  String codeID = "";
  double sharePercentage = 0.0;
  String contextType = "";


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
  var tempBillTotal = 0.0;

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

  var topperData = {};
  String originalWeight = "";

  double protoProductTotal = 0;
  double protoDeliveryTotal = 0;
  double protoDiscountTotal = 0;
  double protoGstTotal = 0;
  double protoSGstTotal = 0;
  double protoBillTotal = 0;
  double prevValue = 0;
  double totalPriceTaxCalc = 0;

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
    Functions().showOrderCompleteSheet(context);
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
              TextButton(
                onPressed: (){
                  Navigator.pop(context);
                },
                child: Text('Cancel',
                  style: TextStyle(color: Colors.deepPurple,fontFamily: "Poppins"),
                ),
              ),
              TextButton(
                onPressed: (){
                  Navigator.pop(context);
                  if(paymentType.toLowerCase()=="online payment"){
                    _handleOrder();
                  }else{
                    handleOrderKgs();
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

  //handle razor pay order here...
  void _handleOrder() async{

    showAlertDialog();

    var amount = 0.0;

    amount = tempBillTotal!=0.0?tempBillTotal:protoBillTotal;

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Basic ${base64Encode(utf8.encode('${PAY_TOK}:${PAY_KEY}'))}'
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
      Functions().showSnackMsg(context, "Payment Error!", true);
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

    var amount = 0.0;

    amount = tempBillTotal!=0.0?tempBillTotal:protoBillTotal;

    var options = {
      'key': '${PAY_TOK}',
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

    var amount = 0.0;

    amount = tempBillTotal!=0.0?tempBillTotal:protoBillTotal;

    var headers = {
      'Authorization': 'Basic ${base64Encode(utf8.encode('${PAY_TOK}:${PAY_KEY}'))}',
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
      //userID = prefs.getString("userID") ?? '';
      authToken = prefs.getString("authToken") ?? '';
      // userModId = prefs.getString("userModId") ?? '';
      // userName = prefs.getString("userName") ?? '';
      // userPhone = prefs.getString("phoneNumber") ?? '';
      // userAddress = prefs.getString("otherOrdDeliveryAdrs") ?? 'null';

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

      print("Other weight : $weight");


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

      topperData = jsonDecode(prefs.getString("others_topper_data")??'');
      originalWeight = prefs.getString("others_original_weight")??'';

    });

    getTaxDetails();
    getSharePercentage();
  }

  Future<void> getTaxDetails() async{

    var pref = await SharedPreferences.getInstance();

    List tempFlavs = [];

    flavs.forEach((element) {
      tempFlavs.add(
        {
          "Name":element,
          "Price":"0"
        }
      );
    });

    showAlertDialog();

    double myTax = 0;
    double myPrice = double.parse(cakePrice);

    //prefs.setDouble('orderCakeGst', gst);
    //prefs.setDouble('orderCakeSGst', sgst);
    //prefs.setInt('orderCakeTaxperc', taxes??0);OPO


    Map<String , dynamic> passData = {
      "Type":otherType,
      "Price":pricePerKg,
      "ItemCount":"$counts",
      "Weight":"$weight",
      "Discount":"$discount",
      "DeliveryCharge":"$deliveryCharge",
      "Flavour":tempFlavs,
      "Shape":{
        "Name":shape,
        "Price":"0"
      }
    };

    if(topperData['TopperPrice']>0 || topperData['TopperPrice']>0.0){
      passData.addAll({
        "Toppers":{
          "TopperId":"${topperData['TopperId']}",
          "TopperName":"${topperData['TopperName']}",
          "TopperImage":"${topperData['TopperImage']}",
          "TopperPrice":"${topperData['TopperPrice']}",
        }
      });
    }


    try{
      var headers = {
        'Authorization': '$authToken'
      };
      var request = http.Request('GET', Uri.parse('${API_URL}api/tax/list'));

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

          passData.addAll({
            "Tax":"${int.parse(map[0]['Total_GST'])}"
          });

          Functions().handleOrderCalculations("OPO", passData).then((value){
            handleCalculations(value);
          });

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

  void handleCalculations(var data) {

    print("handle Calckk... $data");

    //{ItemTotal: 24, ItemCount: 1, DeliveryCharge: 145.4, DiscountPercentage: 0,
    // DiscountPrice: 0, TaxPercentage: 10, Gst: 8.47, Sgst: 8.47, Total: 186.34}

    setState(() {
      protoProductTotal = double.parse("${data['ItemTotal']}");
      protoDeliveryTotal = double.parse("${data['DeliveryCharge']}");
      protoDiscountTotal = double.parse("${data['DiscountPrice']}");
      protoGstTotal = double.parse("${data['Gst']}");
      protoSGstTotal = double.parse("${data['Sgst']}");
      protoBillTotal = double.parse("${data['Total']}");
    });
  }

  Future<void> sendNotificationToVendor(String? NoId) async{
    context.read<ContextData>().setNotiCount(1);
    Functions().sendThePushMsg("Hi $vendorName , you got a new order from $userName",'New order received!',NoId.toString());
  }

  //confirm order
  Future<void> orderTypeKg() async{

    double couponVal = 0;
    double gstVal = 0;
    double sgstVal = 0;

    if(prevValue > 0 && couponCtrl.text.toLowerCase()!="coupon is not applicable"){
      gstVal = totalPriceTaxCalc/2;
      sgstVal = totalPriceTaxCalc/2;
    }else{
      gstVal = protoGstTotal;
      sgstVal = protoSGstTotal;
    }

    if(couponCtrl.text!="Coupon is not applicable" || couponCtrl.text.isNotEmpty){
      if(contextType=="amount"){
        couponVal = prevValue;
      }else{
        couponVal = (protoProductTotal*prevValue)/100;
      }
    }else{
      couponVal = 0;
    }

    showAlertDialog();

    try{

      var amount = tempBillTotal>0.0?tempBillTotal:protoBillTotal.toStringAsFixed(2);

      var data = {
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
        "Discount": discountPrice,
        "DeliveryCharge":deliveryCharge,
        "Total": amount,
        "Gst":gstVal,
        "Sgst":sgstVal,
        "Tax":taxes,
        "PaymentType": paymentType,
        "PaymentStatus": paymentType=="Online Payment"?"Paid":'Cash On Delivery',
        "SharePercentage":sharePercentage,
        "CouponValue":'$couponVal',
      };

      if( cakeSubType.toLowerCase()=="brownie" && topperData['price']!=0.0){
        data.addAll({
          "TopperId":topperData['id'],
          "TopperName":topperData['name'],
          "TopperImage":topperData['image'],
          "TopperPrice":topperData['topperPrice'],
        });
      }

      http.Response response = await http.post(
          Uri.parse("${API_URL}api/otherproduct/order/new"),
          body:jsonEncode(data),
          headers:{'Content-Type':'application/json'}
      );


      var map = jsonDecode(response.body);

      print(map);

      if (response.statusCode == 200) {

        Navigator.pop(context);

        if(map['statusCode']==200){
          Functions().deleteCouponCode(codeID);
          Functions().showSnackMsg(context, "${map['message']}", false);
          sendNotificationToVendor(notificationTid);
          NotificationService().showNotifications("Hoorey! Your $cakeName order is placed successfully", "Our executive will contact you soon.");
          showOrderCompleteSheet();
        }else{
          Functions().showSnackMsg(context, "${map['message']}", true);
        }
      }
      else {
        Navigator.pop(context);
        Functions().showSnackMsg(context, "Unable to place the order!", false);
      }
      context.read<ContextData>().setCodeData({});
    }catch(e){
      Navigator.pop(context);
      print(e);
      Functions().showSnackMsg(context, "Unable to place the order!", false);
    }

  }

  //confirm unit order
  Future<void> confirmUnitOrd() async{

    double couponVal = 0;
    double gstVal = 0;
    double sgstVal = 0;

    if(prevValue > 0 && couponCtrl.text.toLowerCase()!="coupon is not applicable"){
      gstVal = totalPriceTaxCalc/2;
      sgstVal = totalPriceTaxCalc/2;
    }else{
      gstVal = protoGstTotal;
      sgstVal = protoSGstTotal;
    }
    if(couponCtrl.text!="Coupon is not applicable" || couponCtrl.text.isNotEmpty){
      if(contextType=="amount"){
        couponVal = prevValue;
      }else{
        couponVal = (protoProductTotal*prevValue)/100;
      }
    }else{
      couponVal = 0;
    }

    try {
      showAlertDialog();

      var amount = tempBillTotal > 0.0 ? tempBillTotal : protoBillTotal.toStringAsFixed(2);

      var headers = {
        'Content-Type': 'application/json'
      };
      var request = http.Request(
          'POST', Uri.parse('${API_URL}api/otherproduct/order/new'));
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
          "PricePerUnit":pricePerKg
        },
        "Description": cakeDesc,
        "VendorID": vendorID,
        "Vendor_ID": vendorModId,
        "VendorName": vendorName,
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
        "Discount": discountPrice,
        "DeliveryCharge": deliveryCharge,
        "Gst": gstVal,
        "Sgst": sgstVal,
        "Tax": taxes,
        "Total": amount,
        "PaymentType": paymentType,
        "PaymentStatus": paymentType == "Online Payment"
            ? "Paid"
            : 'Cash On Delivery',
        "SharePercentage": sharePercentage,
        "CouponValue":'$couponVal',
      });
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        Navigator.pop(context);

        var map = jsonDecode(await response.stream.bytesToString());
        if (map['statusCode'] == 200) {
          Functions().deleteCouponCode(codeID);
          Functions().showSnackMsg(context, "${map['message']}", false);
          sendNotificationToVendor(notificationTid);
          NotificationService().showNotifications("Hoorey! Your $cakeName order is placed successfully", "Our executive will contact you soon.");
          showOrderCompleteSheet();
        } else {
          Functions().showSnackMsg(context, "${map['message']}", false);
        }
      }
      else {
        Navigator.pop(context);
        print(response.reasonPhrase);
        Functions().showSnackMsg(context, "Unable to place the order!", false);
      }
      context.read<ContextData>().setCodeData({});
    }catch(e){
      print('error...');
      print(e);
      Functions().showSnackMsg(context, "Unable to place the order!", false);
      Navigator.pop(context);
    }

  }

  //confirm unit order
  Future<void> confirmBoxOrd() async{

    double couponVal = 0;
    double gstVal = 0;
    double sgstVal = 0;

    if(prevValue > 0 && couponCtrl.text.toLowerCase()!="coupon is not applicable"){
      gstVal = totalPriceTaxCalc/2;
      sgstVal = totalPriceTaxCalc/2;
    }else{
      gstVal = protoGstTotal;
      sgstVal = protoSGstTotal;
    }
    if(couponCtrl.text!="Coupon is not applicable" || couponCtrl.text.isNotEmpty){
      if(contextType=="amount"){
        couponVal = prevValue;
      }else{
        couponVal = (protoProductTotal*prevValue)/100;
      }
    }else{
      couponVal = 0;
    }

    showAlertDialog();

    try {
      var amount = tempBillTotal > 0.0 ? tempBillTotal : protoBillTotal.toStringAsFixed(2);

      var headers = {
        'Content-Type': 'application/json'
      };
      var request = http.Request(
          'POST', Uri.parse('${API_URL}api/otherproduct/order/new'));
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
          "Piece": weight,
          "ProductCount": counts,
          "PricePerBox": pricePerKg
        },
        "Description": cakeDesc,
        "VendorID": vendorID,
        "Vendor_ID": vendorModId,
        "VendorName": vendorName,
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
        "Discount":discountPrice,
        "DeliveryCharge": deliveryCharge,
        "Gst": gstVal,
        "Sgst": sgstVal,
        "Tax": taxes,
        "Total": amount,
        "PaymentType": paymentType,
        "PaymentStatus": paymentType == "Online Payment"
            ? "Paid"
            : 'Cash On Delivery',
        "SharePercentage": sharePercentage,
        "CouponValue":'$couponVal',
      });
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        Navigator.pop(context);

        var map = jsonDecode(await response.stream.bytesToString());

        print(map);

        if (map['statusCode'] == 200) {
          Functions().deleteCouponCode(codeID);
          sendNotificationToVendor(notificationTid);
          NotificationService().showNotifications("Hoorey! Your $cakeName order is placed successfully", "Our executive will contact you soon.");
          showOrderCompleteSheet();
        } else {
          Functions().showSnackMsg(context, "${map['message']}", false);
        }
      }
      else {
        Navigator.pop(context);
        print(response.reasonPhrase);
        Functions().showSnackMsg(context, "${response.reasonPhrase.toString()}", false);
      }
      context.read<ContextData>().setCodeData({});
    }catch(e){
      print('error...');
      print(e);
      Functions().showSnackMsg(context, "Unable to place the order!", false);
      Navigator.pop(context);
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
          sharePercentage = double.parse(jsonDecode(res.body)[0]['Percentage'].toString());
        });

      }else{
        print("Share ${res.body}");
      }

    }catch(e){
      print("Share $e");
    }

  }

  //endregion

  @override
  void initState() {
    // TODO: implement initState
    Future.delayed(Duration.zero , () async{
      recieveDetailsFromScreen();
    });
    Functions().getUserData().then((value){
      if(value.isNotEmpty){
        print(value);
        userID = value['_id'];
        userModId = value['Id'];
        userName = value['UserName'];
        userPhone = value['PhoneNumber'].toString();
        userAddress = value['Address'];
      }
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

    discountPrice = (double.parse(cakePrice)*discount)/100;
    tempDiscount = discount;

    if(context.watch<ContextData>().getCodeDetails()=={}){

    }else{
      if(context.watch<ContextData>().getCodeDetails()['value']!=null){
        tempBillTotal = 0.0;
        codeID = context.watch<ContextData>().getCodeDetails()['id'];
        prevValue = double.parse(context.watch<ContextData>().getCodeDetails()['value']);
        totalPriceTaxCalc = 0;
        contextType = context.watch<ContextData>().getCodeDetails()['type'].toString().toLowerCase();
        if(context.watch<ContextData>().getCodeDetails()['type'].toString().toLowerCase()=="amount"){
          // print("prev value $prevValue");
          // if(prevValue <= tempBillTotal){
          //   tempBillTotal = tempBillTotal-prevValue;
          //   couponCtrl.text = context.watch<ContextData>().getCodeDetails()['code'];
          // }else{
          //   couponCtrl.text = "Coupon is not applicable";
          // }
          print("prev value $prevValue");
          if(prevValue <= protoProductTotal){
            totalPriceTaxCalc = (((protoProductTotal-prevValue)+protoDeliveryTotal-protoDiscountTotal)*taxes)/100;
            // protoGstTotal = totalPriceTaxCalc/2;
            // protoSGstTotal = totalPriceTaxCalc/2;
            print("The Tax $totalPriceTaxCalc");
            tempBillTotal = ((protoProductTotal - prevValue)+protoDeliveryTotal-protoDiscountTotal)+totalPriceTaxCalc;
            couponCtrl.text = context.watch<ContextData>().getCodeDetails()['code'];
          }else{
            couponCtrl.text = "Coupon is not applicable";
          }

        }else{
          // double discountAmount = (tempBillTotal*prevValue)/100;
          // tempBillTotal = tempBillTotal-discountAmount;
          // couponCtrl.text = context.watch<ContextData>().getCodeDetails()['code'];
          // print("Context ----> $tempBillTotal");

          double totalDisPrice = (protoProductTotal*prevValue)/100;
          if(totalDisPrice <= protoProductTotal){
            totalPriceTaxCalc = (((protoProductTotal-totalDisPrice)+protoDeliveryTotal-protoDiscountTotal)*taxes)/100;
            print("The Tax $totalPriceTaxCalc");
            print("The Tax $totalDisPrice");
            tempBillTotal = ((protoProductTotal - totalDisPrice)+protoDeliveryTotal-protoDiscountTotal)+totalPriceTaxCalc;
            // protoGstTotal = totalPriceTaxCalc/2;
            // protoSGstTotal = totalPriceTaxCalc/2;
            couponCtrl.text = context.watch<ContextData>().getCodeDetails()['code'];
            print("Context ----> $tempBillTotal");
          }else{
            couponCtrl.text = "Coupon is not applicable";
          }

        }
      }else{

      }
    }



    // if(context.watch<ContextData>().getCodeDetails()=={}){
    //
    // }else{
    //   if(context.watch<ContextData>().getCodeDetails()['value']!=null){
    //     tempBillTotal = 0.0;
    //     codeID = context.watch<ContextData>().getCodeDetails()['id'];
    //     if(context.watch<ContextData>().getCodeDetails()['type']=="amount"){
    //       tempBillTotal = ( ((
    //           double.parse(cakePrice) + deliveryCharge
    //       ) - tempDiscountPrice) - discountPrice + sgstPrice+gstPrice)-double.parse(context.watch<ContextData>().getCodeDetails()['value']);
    //       couponCtrl.text = context.watch<ContextData>().getCodeDetails()['code'];
    //     }else{
    //       double discountAmount = (( ((
    //           double.parse(cakePrice) + deliveryCharge
    //       ) - tempDiscountPrice) - discountPrice + sgstPrice+gstPrice)*double.parse(context.watch<ContextData>().getCodeDetails()['value']))/100;
    //       tempBillTotal = ( ((
    //           double.parse(cakePrice) + deliveryCharge
    //       ) - tempDiscountPrice) - discountPrice + sgstPrice+gstPrice)-discountAmount;
    //       couponCtrl.text = context.watch<ContextData>().getCodeDetails()['code'];
    //       print("Context ----> $tempBillTotal");
    //     }
    //   }else{
    //
    //   }
    // }

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
              MyCustomAppBars(title:"profile"),
              SizedBox(width:15,),
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
                                      text:'₹ $protoProductTotal',
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
                                    var pr = await SharedPreferences.getInstance();
                                    //PhoneDialog().showPhoneDialog(context, vendorPhone1, vendorPhone2 , true);
                                    Functions().handleChatWithVendors(context,pr.getString("otherOrdVenMail")??"", vendorName);
                                  },
                                  child: Container(
                                    alignment: Alignment.center,
                                    height: 35,
                                    width: 35,
                                    decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white
                                    ),
                                    child:const Icon(Icons.chat,color: Colors.pink,),
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
                              InkWell(
                                onTap:(){
                                  FocusScope.of(context).unfocus();
                                  context.read<ContextData>().setCodeData({});
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (c)=>CouponsList(userID)));
                                },
                                child: Container(
                                  margin: EdgeInsets.only(left: 7,right: 7),
                                  height: 40,
                                  width:MediaQuery.of(context).size.width,
                                  padding:EdgeInsets.symmetric(horizontal:10),
                                  alignment:Alignment.centerLeft,
                                  decoration:BoxDecoration(
                                      borderRadius:BorderRadius.circular(10),
                                      border:Border.all(
                                          width:1,
                                          color:Colors.grey
                                      )
                                  ),
                                  child:Text(couponCtrl.text.isEmpty?"Coupon code":couponCtrl.text, style:TextStyle(
                                      color:couponCtrl.text.toLowerCase()=="coupon is not applicable"?Colors.red:darkBlue,
                                      fontSize:13,
                                      fontFamily:"Poppins"
                                  ),),
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
                                  Text('₹ ${protoProductTotal.toStringAsFixed(2)}'
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
                              Text('₹ ${protoDeliveryTotal.toStringAsFixed(2)}',style: const TextStyle(fontWeight: FontWeight.bold),),
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
                                    Text('₹ ${protoDiscountTotal.toStringAsFixed(2)}',style: const TextStyle(fontWeight: FontWeight.bold),),
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
                                        child: Text('${(taxes/2).toStringAsFixed(1)} %',style: const TextStyle(fontSize:10.5,),)
                                    ),
                                    prevValue > 0 && couponCtrl.text.toLowerCase()!="coupon is not applicable"?
                                    Text('₹ ${(totalPriceTaxCalc/2).toStringAsFixed(2)}',style: const TextStyle(fontWeight: FontWeight.bold),):
                                    Text('₹ ${protoGstTotal.toStringAsFixed(2)}',style: const TextStyle(fontWeight: FontWeight.bold),),
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
                                        child: Text('${(taxes/2).toStringAsFixed(1)} %',style: const TextStyle(fontSize:10.5,),)
                                    ),
                                    prevValue > 0 && couponCtrl.text.toLowerCase()!="coupon is not applicable"?
                                    Text('₹ ${(totalPriceTaxCalc/2).toStringAsFixed(2)}',style: const TextStyle(fontWeight: FontWeight.bold),):
                                    Text('₹ ${protoSGstTotal.toStringAsFixed(2)}',style: const TextStyle(fontWeight: FontWeight.bold),),
                                  ]
                              )
                            ],
                          ),
                        ),
                        couponCtrl.text!="Coupon is not applicable"&&prevValue>0?
                        Container(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text('Coupon',style: const TextStyle(
                                fontFamily: "Poppins",
                                color: Colors.black54,
                              ),),
                              Row(
                                  children:[
                                    Container(
                                        padding:EdgeInsets.only(right:5),
                                        child: Text('',style: const TextStyle(fontSize:10.5,),)
                                    ),
                                    prevValue>0 && context.watch<ContextData>().getCodeDetails()['type'].toString().toLowerCase()=="amount"?
                                    Text('₹ ${prevValue.toStringAsFixed(2)}',style: const TextStyle(fontWeight: FontWeight.bold),):
                                    Text('₹ ${((protoProductTotal*prevValue)/100).toStringAsFixed(2)}',style: const TextStyle(fontWeight: FontWeight.bold),),
                                  ]
                              )
                            ],
                          ),
                        ):Container(),
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

                              Text('₹ ${
                                  tempBillTotal!=0.0?
                                  tempBillTotal.toStringAsFixed(2):
                                  protoBillTotal.toStringAsFixed(2)
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
                    child: CustomRaisedButton(
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