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

class CheckOut extends StatefulWidget {

  List artic , flavs ;
  CheckOut(this.artic, this.flavs);

  @override
  State<CheckOut> createState() => _CheckOutState(artic: artic,flavs: flavs);
}

class _CheckOutState extends State<CheckOut> {

  List artic , flavs ;
  _CheckOutState({required this.artic, required this.flavs});

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
  double topperPrice = 0.0;
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
  String vendorLat = "";
  String vendorLong = "";
  double finalTotal = 0;


  List<String> toppings = [];
  bool expanded = false;

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

  GlobalKey key = GlobalKey();
  var controller = ScrollController();


  var couponCtrl = new TextEditingController();

  var _razorpay = Razorpay();


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
            content: Text('Are You Sure? Your Order Will Be Placed!' , style: TextStyle(
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
                    if(paymentType.toLowerCase()=="online payment"){
                      _handleOrder();
                    }else{
                      orderFromCustom=="yes"?
                      confirmCustomOrder():
                      confirmOrder();
                    }
                  },
                  child: Text('Order Now')
              ),
            ],
          ),
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

    if(orderFromCustom!="yes"){
      amount = double.parse(
          ((counts * (
              double.parse(cakePrice)*
                  double.parse(weight.toLowerCase().replaceAll('kg', ""))+
                  (extraCharges*double.parse(weight.toLowerCase().replaceAll('kg', "")))
          ) + double.parse((tempTax).toString())+
              deliveryCharge)
              - tempDiscountPrice+topperPrice).toStringAsFixed(2)
      );
    }else{
      amount = double.parse(
          ((counts *
              ((double.parse(cakePrice)*
                  double.parse(weight.replaceAll("kg", "")))+
                  (extraCharges))+
              sgstPrice+gstPrice+deliveryCharge)-tempDiscountPrice).toStringAsFixed(2)
      );
    }

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

    var amount = 0.0;

    if(orderFromCustom!="no"){
      amount = double.parse(
          ((((double.parse(cakePrice)*
              double.parse(weight.toLowerCase().replaceAll("kg", "")))+
              extraCharges)+(double.parse(gstPrice.toString())+
              double.parse(sgstPrice.toString())))-
              tempDiscountPrice+topperPrice).toStringAsFixed(2)
      );
    }else{
      amount = double.parse(
          ((counts *
              ((double.parse(cakePrice)*
                  double.parse(weight.replaceAll("kg", "")))+
                  (extraCharges))+
              sgstPrice+gstPrice+deliveryCharge)-tempDiscountPrice).toStringAsFixed(2)
      );
    }


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
          tempDiscountPrice+topperPrice).toInt();
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

    setState(() {

      //UI Views variables...
      //Strings
      orderFromCustom = prefs.getString("orderFromCustom")??'no';
      premiumVendor = prefs.getString("orderCakeNearestIsEmpty")??'no';
      authToken = prefs.getString("authToken")??'no';
      userLatitude = prefs.getString('userLatitute')??'Not Found';
      userLongtitude = prefs.getString('userLongtitude')??'Not Found';
      //delivery charge
      adminDeliveryCharge = prefs.getInt("todayDeliveryCharge")??0;
      adminDeliveryChargeKm = prefs.getInt("todayDeliveryKm")??0;
    });

    setState((){
      if(orderFromCustom=="yes"){

        cakeName = prefs.getString("customCakeName")??'My Custom Cake';
        cakeImage = "null";
        cakePrice = prefs.getString("customCakePrice")??'0';
        vendorName = prefs.getString('customCakeVendor')??'null';
        cakeType = "Customized Cake";
        userAddress = prefs.getString('customCakeUserAdd')??'null';
        vendorPhone1 = prefs.getString('customCakeVenPhn1')??'null';
        vendorPhone2 = prefs.getString('customCakeVenPhn2')??'null';
        weight = prefs.getString('customCakeWeight')??'1.0';
        sgstPrice = double.parse(prefs.getString('customCakeSgst')??'0');
        gstPrice = double.parse(prefs.getString('customCakeGst')??'0');
        bilTotal = double.parse(prefs.getString('customCakeTotal')??'0');
        extraCharges = double.parse(prefs.getString('customCakeExtra')??'0');
        discountPrice = double.parse(prefs.getString('customCakeDisc')??'0');
        counts = 1;
        cakeID = prefs.getString('customCakeId')??'null';
        shape = prefs.getString('customCakeShape')??"None";
        vendorModId = prefs.getString('customCakeVenModId')??"None";
        vendorID = prefs.getString('customCakeVenId')??"None";
        vendorAddress = prefs.getString('customCakeVenAddrss')??"None";
        deliverType = prefs.getString('customCakePickOrDel')??"None";
        vendorLat = prefs.getString('customCakeVendLat')??"None";
        vendorLong = prefs.getString('customCakeVendLong')??"None";
        taxes = prefs.getInt("customCakeTaxes")??0;

        deliveryChargeCustomer = (((adminDeliveryCharge/adminDeliveryChargeKm)*
            calculateDistance(
              double.parse(userLatitude),
              double.parse(userLongtitude),
              double.parse(vendorLat),
              double.parse(vendorLong),
            )).toStringAsFixed(2)).toString();
        
        if(deliverType.toString().toLowerCase()=="pickup"){
          setState((){
            deliveryCharge = 0;
          });
        }else{
          setState((){
            deliveryCharge = double.parse(deliveryChargeCustomer);
          });
        }

        print("deelele : $deliveryChargeCustomer");

       // getTaxDetails();


      }
      else{
        cakeName = prefs.getString("orderCakeName")??"My Cake Name";
        cakePrice = prefs.getString("orderCakePrice")!;
        topperPrice = prefs.getDouble('orderCakeTopperPrice')??0.0;
        cakeType = prefs.getString("orderCakeType")??'Cakes';
        if(cakeType.isEmpty){
          cakeType = "Cakes";
        }
        weight = prefs.getString("orderCakeWeight")!;
        cakeImage = prefs.getString("orderCakeImages")!;
        userAddress = prefs.getString("orderCakeDeliverAddress")!;
        vendorName = prefs.getString("orderCakeVendorName")!;
        shape = prefs.getString("orderCakeShape")!;

        //ints
        counts = prefs.getInt('orderCakeItemCount')!;
        bilTotal = prefs.getDouble('orderCakeBillTotal')!;
        itemsTotal = prefs.getDouble('orderCakeItemTotal')!;
        gstPrice = prefs.getDouble('orderCakeGst')!;
        sgstPrice = prefs.getDouble('orderCakeSGst')!;
        discountPrice = prefs.getDouble('orderCakeDiscountedPrice')!;
        discount = prefs.getInt('orderCakeDiscount')!;
        extraCharges = prefs.getDouble('orderCakePaymentExtra')!;
        taxes = prefs.getInt('orderCakeTaxperc')!;
        deliveryCharge = prefs.getDouble('orderCakeDelCharge')!;

        /*Order Variables Load...*/
        cakeID = prefs.getString("orderCakeID")!;
        cakeModId = prefs.getString("orderCakeModID")!;
        cakeCommonName = prefs.getString("orderCakeCommonName")!;
        cakeSubType = prefs.getString("orderCakeSubType")!;
        eggOreggless = prefs.getString("orderCakeEggOrEggless")!;
        cakeMessage = prefs.getString("orderCakeMessage")!;
        cakeDesc = prefs.getString("orderCakeDescription")!;
        cakeSplReq = prefs.getString("orderCakeRequest")!;
        deliverType = prefs.getString("orderCakeDeliverType")!;
        deliverSession = prefs.getString("orderCakeDeliverSession")!;
        deliverDate = prefs.getString("orderCakeDeliverDate")!;
        themeName = prefs.getString("orderCakeTheme")!;
        themeFileName = prefs.getString("orderCakeThemeImage")!;

        //vendor details...
        vendorAddress = prefs.getString("orderCakeVendorAddress")!;
        vendorPhone1 = prefs.getString("orderCakeVendorPh1")!;
        vendorPhone2 = prefs.getString("orderCakeVendorPh2")!;
        vendorID = prefs.getString("orderCakeVendorId")!;
        vendorModId = prefs.getString("orderCakeVendorModId")!;
        vendorLat = prefs.getString('orderCakeVenLat')??"None";
        vendorLong = prefs.getString('orderCakeVenLong')??"None";

        //user details...
        userAddress = prefs.getString("orderCakeDeliverAddress")!;
        userName = prefs.getString("orderCakeUserName")!;
        userID = prefs.getString("orderCakeUserID")!;
        userModId = prefs.getString("orderCakeUserModID")!;
        userPhone = prefs.getString("orderCakeUserNum")!;

        //get tier
        cakeTier = prefs.getString("orderCakeTier")??'null';
        tierCakeWeight = prefs.getString("orderCakeTierWeight")??'null';

        //toppers
        topperId = prefs.getString("orderCakeTopperid")??'null';
        topperName = prefs.getString("orderCakeTopperName")!;
        topperImg= prefs.getString("orderCakeTopperImg")!;
        //topperPrice = prefs.getInt("orderCakeTopperPrice")!;

        print('Tier $cakeTier');

        tempDiscountPrice = 0.0;
        tempDiscount = 0;
        tempPrice = ((counts*(double.parse(cakePrice.toString())+extraCharges))*
            double.parse(weight.toLowerCase().replaceAll("kg", "").toString())+topperPrice);
        print(tempPrice);
        tempTax = tempPrice * (double.parse(taxes.toString())/100);
        print(tempTax);
        finalTotal = counts *
            (double.parse(cakePrice)*
            double.parse(weight.replaceAll("kg", "")))+
            (extraCharges *
                double.parse(weight.replaceAll("kg", "")));

      }
    });

    getVendorsList();

  }

  Future<void> getTaxDetails() async{

    var pref = await SharedPreferences.getInstance();

    showAlertDialog();

    double myTax = 0;
    double myPrice = double.parse(
        ((double.parse(cakePrice)*changeWeight(weight))
        +(extraCharges)+topperPrice).toStringAsFixed(2)
    );

    print(myPrice);

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

          pref.setDouble('orderCakeGst', gstPrice);
          pref.setDouble('orderCakeSGst', sgstPrice);
          pref.setInt('orderCakeTaxperc', taxes??0);

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

          pref.setDouble('orderCakeGst', gstPrice);
          pref.setDouble('orderCakeSGst', sgstPrice);
          pref.setInt('orderCakeTaxperc', taxes??0);
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

        pref.setDouble('orderCakeGst', gstPrice);
        pref.setDouble('orderCakeSGst', sgstPrice);
        pref.setInt('orderCakeTaxperc', taxes??0);
      });
    }

  }

  Future<void> confirmCustomOrder() async{

    double mainPrice = (double.parse(cakePrice)*double.parse(weight.toLowerCase().replaceAll('kg', '')))
        +(extraCharges);

    double diss = (mainPrice * discountPrice)/100;

    double finalDiss = mainPrice - diss;

    double discountPr = couponCtrl.text.toLowerCase()=="bbq12m"?double.parse(discountPrice.toString()):0;

    String billTot = ((double.parse(mainPrice.toString())+deliveryCharge+gstPrice+sgstPrice)-discountPr).toString();

    print(discountPr);

    showAlertDialog();

    var headers = {
      'Content-Type': 'application/json'
    };

    var request = http.Request('POST',
        Uri.parse('http://sugitechnologies.com/cakey/api/customize/cake/order/new/$cakeID'));
    request.body = json.encode({
      "PaymentType": "$paymentType",
      "PaymentStatus":paymentType.toLowerCase()=="online payment"?"Paid":'Cash On Delivery',
      "DeliveryCharge": "$deliveryCharge",
      "Total": billTot.toString(),
      "Discount": discountPr.toString(),
      "Gst": gstPrice.toString(),
      "Sgst": sgstPrice.toString(),
      "ExtraCharges": extraCharges.toString(),
      "Tax":taxes.toString()
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {

      var map = jsonDecode(await response.stream.bytesToString());

      sendNotificationToVendor(notificationTid);

      Navigator.pop(context);
      Navigator.pop(context);
      Navigator.pop(context);
      // print();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(map['message']),
            behavior: SnackBarBehavior.floating
        ));

        // NotificationService().showNotifications("Order Placed", "Your Customized Cake Ordered.Thank You!");
    }
    else {
      Navigator.pop(context);
      print(response.reasonPhrase);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(response.reasonPhrase.toString()),
          behavior: SnackBarBehavior.floating
      ));
    }
  }

  Future<void> getVendorsList() async{
    print(vendorModId);
    showAlertDialog();
    var list = [];
    var headers = {
      'Authorization': '$authToken'
    };
    var request = http.Request('GET', Uri.parse('http://sugitechnologies.com/cakey/api/vendors/list'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      list = jsonDecode(await response.stream.bytesToString());
      print(list);
      List basedOnVenId = list.where((element) => element["Id"].toString().toLowerCase()==vendorModId.toLowerCase()).toList();
      notificationTid = basedOnVenId[0]['Notification_Id'];
      print(notificationTid);
      Navigator.pop(context);
    }
    else {
      print(response.reasonPhrase);
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
  Future<void> confirmOrder() async {

    showAlertDialog();

    print(premiumVendor);

    List tempFlavList = [];

    double price = (counts*(double.parse(cakePrice.toString())+extraCharges))*
        double.parse(weight.toLowerCase().replaceAll("kg", "").toString())+topperPrice;

    tempPrice = (counts * (double.parse(cakePrice)+extraCharges))*
        double.parse(weight.toLowerCase().replaceAll("kg", "").toString())-tempDiscountPrice+topperPrice;
    print(tempPrice);
    tempTax = tempPrice * (double.parse(taxes.toString())/100);


    String billTot = ((counts * (
        double.parse(cakePrice)*
            double.parse(weight.toLowerCase().replaceAll('kg', ""))+
            (extraCharges*double.parse(weight.toLowerCase().replaceAll('kg', "")))
    ) + double.parse((tempTax).toString()) +
        deliveryCharge)
        - tempDiscountPrice+topperPrice).toString();

    print(billTot);

    setState((){
      for (var i = 0 ; i<flavs.length ; i++){
        tempFlavList.add(flavs[i]);
      }
    });

    var extra = double.parse(extraCharges.toString())*
        double.parse(weight.toLowerCase().replaceAll("kg", ""));

    var tempShapeList = jsonDecode(shape);

    print(tempShapeList);
    print(tempFlavList);

    Map topperField = {};

    if(topperPrice==0.0){
      topperField = {};
    }else{
      topperField = {
        "TopperId":topperId,
        "TopperName":topperName,
        "TopperImage":topperImg,
        "TopperPrice":'$topperPrice',
      };
    }

    try {
        var data = {
          "CakeID": cakeID,
          "Cake_ID": cakeModId,
          "CakeName": cakeName,
          "CakeCommonName": cakeCommonName,
          // "CakeType": cakeType,
          // "CakeSubType": cakeSubType,
          "Image": cakeImage,
          "EggOrEggless": eggOreggless,
          "Flavour": tempFlavList,
          "Shape": tempShapeList,
          cakeTier!="null"||cakeTier!=null?
          "Tier":cakeTier:null,
          "Weight": tierCakeWeight=="null"?
          weight.toLowerCase().replaceAll("kg", "")+"kg":
          tierCakeWeight.toLowerCase().replaceAll("kg", "")+"kg",
          "Description": cakeDesc,
          "PaymentStatus": paymentType.toLowerCase()=="cash on delivery"?"Cash On Delivery":"Paid",
          "PaymentType": paymentType,
          "Total": billTot.toString(),
          "Sgst": (tempTax/2).toString(),
          "Gst": (tempTax/2).toString(),
          "DeliveryCharge": deliveryCharge.toString(),
          "ExtraCharges": extra.toString(),
          "Discount": couponCtrl.text.toLowerCase()=="bbq12m"?double.parse(discountPrice.toString()):0,
          "ItemCount": counts,
          "Price": cakePrice.toString(),
          "DeliverySession": deliverSession,
          "DeliveryDate": deliverDate,
          "UserPhoneNumber": userPhone,
          "UserName": userName,
          "UserID": userID,
          "User_ID": userModId,
          "Tax":taxes.toString(),
          "DeliveryInformation": deliverType,
          "DeliveryAddress": userAddress,
          "PremiumVendor":premiumVendor=="no"?"n":'y',
          "VendorName":vendorName,
          "VendorID":vendorID,
          "Vendor_ID":vendorModId,
          "VendorPhoneNumber1":vendorPhone1,
          "VendorPhoneNumber2":vendorPhone2,
          "VendorAddress":vendorAddress,
          "GoogleLocation":{"Latitude":vendorLat , "Longitude":vendorLong},
          "MessageOnTheCake":cakeMessage,
          "SpecialRequest":cakeSplReq,
          "TopperId":topperId,
          "TopperName":topperName,
          "TopperImage":topperImg,
          "TopperPrice":'$topperPrice',
        };

        var premiumData = {
          "CakeID": cakeID,
          "Cake_ID": cakeModId,
          "CakeName": cakeName,
          "CakeCommonName": cakeCommonName,
          "Image": cakeImage,
          "EggOrEggless": eggOreggless,
          "Flavour": tempFlavList,
          "Shape": tempShapeList,
          cakeTier!="null"||cakeTier!=null?
          "Tier":cakeTier:null,
          "Weight": tierCakeWeight=="null"?
          weight.toLowerCase().replaceAll("kg", "")+"kg":
          tierCakeWeight.toLowerCase().replaceAll("kg", "")+"kg",
          "Description": cakeDesc,
          "PaymentStatus": paymentType.toLowerCase()=="cash on delivery"?"Cash On Delivery":"Paid",
          "PaymentType": paymentType,
          "Total": billTot.toString(),
          "Sgst": (tempTax/2).toString(),
          "Gst": (tempTax/2).toString(),
          "DeliveryCharge": deliveryCharge.toString(),
          "ExtraCharges": extra.toString(),
          "Discount": couponCtrl.text.toLowerCase()=="bbq12m"?double.parse(discountPrice.toString()):0,
          "ItemCount": counts,
          "Price": cakePrice.toString(),
          "DeliverySession": deliverSession,
          "DeliveryDate": deliverDate,
          "UserPhoneNumber": userPhone,
          "UserName": userName,
          "UserID": userID,
          "User_ID": userModId,
          "Tax":taxes.toString(),
          "DeliveryInformation": deliverType,
          "DeliveryAddress": userAddress,
          "PremiumVendor":premiumVendor=="no"?"n":'y',
          "MessageOnTheCake":cakeMessage,
          "SpecialRequest":cakeSplReq,
          "TopperId":topperId,
          "TopperName":topperName,
          "TopperImage":topperImg,
          "TopperPrice":'$topperPrice',
        };

        var body = jsonEncode('object');

        if(premiumVendor == 'yes'){
          body = jsonEncode(premiumData);
        }else{
          body = jsonEncode(data);
        }


        print(body);

        //http://sugitechnologies.com:88

        var response = await http.post(Uri.parse("http://sugitechnologies.com/cakey/api/order/new"),
            headers: {"Content-Type": "application/json"},
            body: body
        );

        print("${response.statusCode}");
        print("${response.body}");
        var map = jsonDecode(response.body);

        if(response.statusCode == 200){

          Navigator.pop(context);

          if(map['statusCode'].toString()=="200"){

            showOrderCompleteSheet();

            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(map['message']),
                behavior: SnackBarBehavior.floating
            ));

            NotificationService().showNotifications(map['message'], "Your $cakeName Ordered.Thank You!");

          }



        }else{

          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(map['message']),
              behavior: SnackBarBehavior.floating
          ));
          Navigator.pop(context);

        }


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

  //payment handlers...
  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    // Do something when payment succeeds
    print("Pay success : "+response.paymentId.toString());
    // _capturePayment(response.paymentId.toString());
    orderFromCustom=="yes"?
    confirmCustomOrder():
    confirmOrder();
    // showPaymentDoneAlert("done");
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    // Do something when payment fails
    print("Pay error : "+response.toString());
    showPaymentDoneAlert("failed");
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // Do something when an external wallet is selected
    print("wallet : "+response.walletName!);
    showPaymentDoneAlert("failed");
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
          key: key,
          width: double.infinity,
          margin: EdgeInsets.all(15),
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Colors.black26, width: 1)),
          child: SingleChildScrollView(
            controller: controller,
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
                            Text('(Shape - ${shape.replaceAll("Name", "").replaceAll("Price", "")
                                .replaceAll("{", "").replaceAll("}", "").replaceAll('"', '').replaceAll(":", "")
                                .replaceAll(",", "").replaceAll("0", "").replaceAll('"', "")})',style: TextStyle(
                                fontSize: 11,fontFamily: "Poppins",color: Colors.grey[500]
                            ),overflow: TextOverflow.ellipsis,maxLines: 10),
                            // SizedBox(height: 5,),
                            Wrap(
                              children: [
                                for(var i in flavs)
                                  Text("(Flavour - ${i['Name']}) "
                                    // "Price - Rs.${i['Price']})"
                                    ,style: TextStyle(
                                        fontSize:10.5,fontFamily: "Poppins",
                                        color: Colors.grey[500]
                                    ),),
                              ],
                            ),
                            Text.rich(
                                TextSpan(
                                    text: orderFromCustom!="yes"?
                                    '₹ ${(counts * (double.parse(cakePrice.toString()) +
                                        double.parse(extraCharges.toString()))*double.parse(weight.toLowerCase().replaceAll('kg', ""))+topperPrice)
                                        .toStringAsFixed(2)}':
                                     "${
                                      ((double.parse(cakePrice)*
                                          double.parse(weight.toLowerCase().replaceAll("kg", "")))+
                                          extraCharges).toStringAsFixed(2)
                                     }",
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
                          '${vendorName}',style: TextStyle(
                            fontSize: 13,fontFamily: "Poppins",
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
                                 // PhoneDialog().showPhoneDialog(context, vendorPhone1, vendorPhone2 , true);
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
                            Text('$cakeType',style: TextStyle(
                                fontSize: 13,fontFamily: "Poppins",
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

                                      print(double.parse(cakePrice.toString())*double.parse(weight.toLowerCase().replaceAll("kg", "").toString()));
                                      print(taxes);
                                      print(discountPrice);

                                      setState((){
                                        tempPrice = (counts * (double.parse(cakePrice)+extraCharges))*
                                            double.parse(weight.toLowerCase().replaceAll("kg", "").toString())-discountPrice;
                                        print(tempPrice);
                                        tempTax = tempPrice * (double.parse(taxes.toString())/100);
                                        print(tempTax);
                                      });
                                      tempDiscountPrice = discountPrice;
                                      tempDiscount = discount;
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                            content: Text('Discount Applied.!'),
                                            backgroundColor: Colors.green,
                                        )
                                      );
                                    }else{
                                      setState((){
                                        tempDiscountPrice = 0.0;
                                        tempDiscount = 0;
                                        tempPrice = (counts * (double.parse(cakePrice)+extraCharges))*
                                            double.parse(weight.toLowerCase().replaceAll("kg", "").toString())-tempDiscountPrice;
                                        print(tempPrice);
                                        tempTax = tempPrice * (double.parse(taxes.toString())/100);
                                        print(tempTax);
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
                              child: orderFromCustom!="yes"?
                              Text('₹ ${(counts * (double.parse(cakePrice.toString()) +
                                  double.parse(extraCharges.toString()))*
                                  double.parse(weight.toLowerCase().replaceAll('kg', ""))+topperPrice).toStringAsFixed(2)}'
                                ,style: const TextStyle(fontWeight: FontWeight.bold),):
                              Text('₹ ${((double.parse(cakePrice)*
                                  double.parse(weight.toLowerCase().replaceAll("kg", "")))+
                                  extraCharges).toStringAsFixed(2)}'
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
                                  Text('₹ ${tempDiscountPrice.toStringAsFixed(2)}',style: const TextStyle(fontWeight: FontWeight.bold),),
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
                                  orderFromCustom!="yes"?
                                  Text('₹ ${(gstPrice).toStringAsFixed(2)}',style: const TextStyle(fontWeight: FontWeight.bold),):
                                  Text('₹ ${(gstPrice).toStringAsFixed(2)}',style: const TextStyle(fontWeight: FontWeight.bold),),
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
                                  orderFromCustom!="yes"?
                                  Text('₹ ${(sgstPrice).toStringAsFixed(2)}',style: const TextStyle(fontWeight: FontWeight.bold),):
                                  Text('₹ ${(sgstPrice).toStringAsFixed(2)}',style: const TextStyle(fontWeight: FontWeight.bold),),
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
                            orderFromCustom!="yes"?
                            Text('₹ ${
                                ((counts * (
                                    double.parse(cakePrice)*
                                        double.parse(weight.toLowerCase().replaceAll('kg', ""))+
                                        (extraCharges*double.parse(weight.toLowerCase().replaceAll('kg', "")))
                                ) + double.parse((tempTax).toString()) +
                                    deliveryCharge+topperPrice)
                                - tempDiscountPrice).toStringAsFixed(2)
                            }',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17),):
                            Text('₹ ${((counts *
                                ((double.parse(cakePrice)*
                                    double.parse(weight.replaceAll("kg", "")))+
                                    (extraCharges))+
                                sgstPrice+gstPrice+deliveryCharge)-tempDiscountPrice).toStringAsFixed(2)}'
                              ,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17),),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                GestureDetector(
                  child: ExpansionTile(
                    onExpansionChanged: (e){
                      setState((){
                        print(controller.position.maxScrollExtent);
                        expanded = e;
                        if(e==true){
                          //controller.jumpTo(controller.position.minScrollExtent);

                          // RenderBox box = key.currentContext!.findRenderObject() as RenderBox;
                          // Offset position = box.localToGlobal(Offset.zero); //this is global position
                          // double y = position.dx;
                          //
                          // print(y);

                        controller.animateTo(
                          306,
                          duration: Duration(seconds: 1),
                          curve: Curves.fastOutSlowIn,
                        );

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
                        color: Colors.red[100],
                        shape: BoxShape.circle ,
                      ),
                      child: Icon(Icons.keyboard_arrow_down_rounded , color: darkBlue,size: 25,),
                    ):
                    Container(
                      alignment: Alignment.center,
                      height: 25,
                      width: 25,
                      decoration: BoxDecoration(
                        color: Colors.red[100],
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
                              fontWeight: FontWeight.bold
                          ),
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
                Container(
                  margin: EdgeInsets.only(top: 3,bottom: 3),
                  color: lightPink,
                  height: 0.3,
                ),
                paymentType == "Credit Card"
                    ? Container(
                  padding: EdgeInsets.all(10),
                  margin: EdgeInsets.only(top: 10),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[200]),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Name on card" , style: TextStyle(
                        fontFamily: "Poppins",color: Colors.black54
                      ),),
                      TextField(
                        style: TextStyle(
                          color: darkBlue,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                            hintText: "Type Name Here",
                            hintStyle: TextStyle(
                              fontFamily: "Poppins",
                              fontSize: 13.5
                            ),
                            prefixIcon: Icon(Icons.account_circle,color: Colors.grey[400])),
                      ),
                      SizedBox(height: 7,),
                      Text("Card number" , style: TextStyle(
                          fontFamily: "Poppins",color: Colors.black54
                      ),),
                      TextField(
                        style: TextStyle(
                          color: darkBlue,
                          fontWeight: FontWeight.bold,
                        ),
                        inputFormatters: [
                          MaskedTextInputFormatter(
                            mask: 'xxxx-xxxx-xxxx-xxxx',
                            separator: "-"
                          )
                        ],
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                            hintText: "Card number",
                            hintStyle: TextStyle(
                                fontFamily: "Poppins",
                                fontSize: 13.5
                            ),
                            prefixIcon: Icon(Icons.credit_card_outlined,color: Colors.grey[400],)),
                      ),

                      SizedBox(height: 10,),

                      GridView(
                        shrinkWrap: true,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisExtent: 80,
                          crossAxisSpacing: 5,
                          // mainAxisSpacing: 5
                        ),
                        children: [
                          Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text("Card expiry" , style: TextStyle(
                                    fontFamily: "Poppins",color: Colors.black54
                                ),),
                                TextField(
                                  style: TextStyle(
                                    color: darkBlue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  inputFormatters: [
                                    CardExpirationFormatter()
                                  ],
                                  maxLength: 7,
                                  keyboardType: TextInputType.phone,
                                  decoration: InputDecoration(
                                    hintText: "MM/YYYY",
                                    hintStyle: TextStyle(
                                        fontFamily: "Poppins",
                                        fontSize: 13.5
                                    ),
                                    counterText: ""
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text("CVV" , style: TextStyle(
                                    fontFamily: "Poppins",color: Colors.black54
                                ),),
                                TextField(
                                  style: TextStyle(
                                    color: darkBlue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  obscureText: true,
                                  obscuringCharacter: "*",
                                  maxLength: 3,
                                  keyboardType: TextInputType.text,
                                  decoration: InputDecoration(
                                    hintText: "CVV",
                                    hintStyle: TextStyle(
                                        fontFamily: "Poppins",
                                        fontSize: 13.5
                                    ),
                                    counterText: "",
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                    ],
                  ),
                )
                    : Container(),
                
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