import 'dart:convert';
import 'dart:io';
import 'package:cakey/Notification/Notification.dart';
import 'package:cakey/drawermenu/DrawerHome.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../DrawerScreens/Notifications.dart';

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

  String paymentType = "UPI";
  bool isExpand = false;
  var paymentIndex = 0;

  //Strings
  String cakeName = '';
  String cakeID = '';
  String cakeModId = '';
  String shape = '';
  String flavour = '';
  String weight = '';
  String cakeImage = '';
  String cakeDesc = '';
  String cakePrice = '';
  String cakeType = '';
  String eggOreggless = '';
  String deliverDate = '';
  String deliverSession = '';
  String cakeMessage = '';
  String cakeSplReq = '';
  String cakeArticle = '';
  String deliverType = '';
  String extraCharges = '0';
  String orderFromCustom = 'no';

  List<String> toppings = [];

  //HYVOOB9SJFHMFA8L

  //vendor
  String vendorName = '';
  String vendorModId = '';
  String vendorMobile = '';
  String vendorID = '';
  String vendorAddress = '';

  //User
  String userAddress = '';
  String userName = '';
  String userModId = '';
  String userID = '';
  String userPhone = '';

  //int
  //int
  int itemsTotal = 0;
  int counts = 1;
  int deliveryCharge = 0;
  int discount = 0;
  int taxes = 0;
  int bilTotal = 0;

  double gstPrice = 0;
  double sgstPrice = 0;
  int discountPrice = 0;



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
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => DrawerHome()),
                        ModalRoute.withName('/DrawerHome')
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

  //region Functions

  //getting order detailssss...
  Future<void> recieveDetailsFromScreen() async{

    var prefs = await SharedPreferences.getInstance();

    setState(() {

      cakeImage = prefs.getString('orderCakeImages')
          ??'https://cdn4.vectorstock.com/i/1000x1000/25/63/cake-icon-set-of-great-flat-icons-with-style-vector-24172563.jpg';
      cakeName = prefs.getString('orderCakeName')??'';
      cakeDesc = prefs.getString('orderCakeDescription')??'';
      cakePrice = prefs.getString('orderCakePrice')??'';
      cakeModId = prefs.getString('orderCakeModID')??'';
      cakeType = prefs.getString('orderCakeType')??'';
      orderFromCustom = prefs.getString('orderFromCustom')??'';

      //user orderCakeDeliverAddress
      userAddress = prefs.getString('orderCakeDeliverAddress')??'';

      //vendors
      vendorName = prefs.getString('orderCakeVendorName')??'';
      vendorMobile = prefs.getString('orderCakeVendorNum')??'';

      //costs
      // itemTotal = prefs.getInt('orderCakeItemCount')??0;
      deliveryCharge = prefs.getInt('orderCakeDeliverAmt')??0;
      extraCharges = prefs.getString('orderCakePaymentExtra')??'0.0';
      discount = prefs.getInt('orderCakeDiscount')??0;
      taxes = prefs.getInt('orderCakeTaxes')??0;
      bilTotal = prefs.getInt('orderCakeTotalAmt')??0;

    });


    setState(() {

      cakeID = prefs.getString('orderCakeID')!;
      shape = prefs.getString('orderCakeShape')!;
      weight = prefs.getString('orderCakeWeight')!;
      // flavour = prefs.getString('orderCakeFlavour')!;
      eggOreggless = prefs.getString('orderCakeEggOrEggless')!;
      // toppings = prefs.getStringList('orderCakeTopings')!;

      userID = prefs.getString('orderCakeUserID')!;
      userModId = prefs.getString('orderCakeModID')!;
      userName = prefs.getString('orderCakeUserName')!;
      userPhone = prefs.getString('orderCakeUserNum')!;

      vendorID = prefs.getString('orderCakeVendorId')!;
      vendorModId = prefs.getString('orderCakeVendorModId')!;
      vendorAddress = prefs.getString('orderCakeVendorAddress')!;


      deliverSession = prefs.getString('orderCakeDeliverSession')!;
      deliverDate = prefs.getString('orderCakeDeliverDate')!;

      cakeMessage = prefs.getString('orderCakeMessage')!;
      cakeSplReq = prefs.getString('orderCakeRequest')!;
      deliverType = prefs.getString('orderCakeDeliveryInformation')!;


      counts = prefs.getInt('orderCakeItemCount')!;

      calculatedCountsAndPrice();

      print(userModId);

      // cakeArticle = prefs.getString('orderCakeArticle')!;

      // counts = prefs.getInt('orderCakeCounts')!;

    });

  }

  //price calculators...
  void calculatedCountsAndPrice(){

    print('Extra Charges : $extraCharges');

    // int cakesOrginalPrice = int.parse(cakePrice);

    double itemTotal = 0;
    int cakesOrginalPrice = int.parse("$cakePrice");
    int priceAfterDiscount = 0;
    int discountedPrice = 0;
    int totalTax = 0;
    double gstAmt = 0;
    double sgstAmt = 0;
    int extraCharge= int.parse(extraCharges, onError: (e)=>0);

    print("Extra crg : $extraCharge");

    if(orderFromCustom=='no'){
      setState((){

        priceAfterDiscount = cakesOrginalPrice-(cakesOrginalPrice*discount/100).toInt();

        print('Price After dis : $priceAfterDiscount');

        discountedPrice = cakesOrginalPrice - priceAfterDiscount;

        print('Price After dis : $discountedPrice');

        totalTax = ((priceAfterDiscount*taxes)/100).toInt();

        gstAmt = (totalTax/2);
        sgstAmt = totalTax/2;

        itemTotal = (counts*priceAfterDiscount)+double.parse(extraCharges);
        bilTotal = (itemTotal+deliveryCharge+gstAmt+sgstAmt+extraCharge).toInt();

        print("item tot : $itemTotal");
        print("Del chrg : $deliveryCharge");
        print("item discount : $discountedPrice");
        print("item gst : $gstAmt");
        print("item sgst : $sgstAmt");
        print("item bil tot : $bilTotal");



        discountPrice = discountedPrice;
        itemsTotal = itemTotal.toInt();
        gstPrice = gstAmt;
        sgstPrice = sgstAmt;


        // sgstAmt = ((priceAfterDiscount*12)/100).toInt();

      });
    }else{
      setState((){
        discountPrice = discount;
        gstPrice = (taxes/2).toDouble();
        sgstPrice = (taxes/2).toDouble();
      });

    }

    print(priceAfterDiscount);
    print(discountedPrice);


  }


  Future<void> confirmCustomOrder() async{
    showAlertDialog();
    var headers = {
      'Content-Type': 'application/json'
    };
    var request = http.Request('POST',
        Uri.parse('https://cakey-database.vercel.app/api/customize/cake/order/new/$cakeID'));
    request.body = json.encode({
      "PaymentType": "$paymentType",
      "PaymentStatus": paymentType=="Cash On Delivery"?"Cash On Delivery":'Paid',
      "DeliveryCharge": "$deliveryCharge",
      "Total": "$bilTotal"
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      Navigator.pop(context);
      // print();

      if(jsonDecode(await response.stream.bytesToString())['message']=="Order Placed Successfully"){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Order Posted!'),
            behavior: SnackBarBehavior.floating
        ));

        NotificationService().showNotifications("Order Placed", "Your Customized Cake Ordered.Thank You!");


      }else{
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
            content: Text(await response.stream.bytesToString()),
            behavior: SnackBarBehavior.floating
        ));
      }

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


  //confirm order
  Future<void> confirmOrder() async {

    showAlertDialog();

    try {
      if (double.parse(weight.replaceAll("kg", "")) < 6.0) {
        print('Weight is below 5 : $weight');

        var headers = {'Content-Type': 'application/json'};
        var request = http.Request(
            'POST',
            Uri.parse('https://cakey-database.vercel.app/api/order/new'));
        request.body = json.encode({

          "CakeID": cakeID,
          "Cake_ID": cakeModId,
          "Title": cakeName,
          "Description": cakeDesc,
          "TypeOfCake": cakeType,
          "Images": cakeImage,
          "EggOrEggless": eggOreggless,
          "Price": cakePrice,
          "Flavour": flavs,
          "Shape": shape,
          "Article": artic[0],
          "MessageOnTheCake": cakeMessage,
          "SpecialRequest": cakeSplReq,
          "Weight": weight,
          "VendorID": vendorID,
          "Vendor_ID": vendorModId,
          "VendorName": vendorName,
          "VendorPhoneNumber": vendorMobile,
          "UserID": userID,
          "User_ID": userModId,
          "UserName": userName,
          "UserPhoneNumber": userPhone,
          "DeliveryAddress": userAddress,
          "DeliveryDate": deliverDate,
          "DeliverySession": deliverSession,
          "VendorAddress": vendorAddress,
          "ItemCount": counts,
          "Discount": discount,
          "Total": bilTotal,
          "DeliveryCharge": deliveryCharge,
          "PaymentType": paymentType,
          "PaymentStatus": paymentType.toLowerCase() == "cash on delivery"
              ? "Cash On Delivery"
              : 'Paid',
          "DeliveryInformation": deliverType,
          "Gst": gstPrice.toString(),
          "Sgst": sgstPrice.toString(),
          "ExtraCharges": extraCharges.toString(),

        });

        request.headers.addAll(headers);

        http.StreamedResponse response = await request.send();

        print(response.statusCode);

        if (response.statusCode == 200) {
          // print(await response.stream.bytesToString());

          if(json.decode(await response.stream.bytesToString())['statusCode'].toString()=="200"){
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Order Placed!'),
                behavior: SnackBarBehavior.floating
            ));

            Navigator.pop(context);

            NotificationService().showNotifications("Order Placed", "Your $cakeName Ordered.Thank You!");

            showOrderCompleteSheet();
          }else{
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Unable to Place Your Order'),
                behavior: SnackBarBehavior.floating
            ));
          }

        } else {
          print(response.reasonPhrase);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Error Occurred : ${response.reasonPhrase}'),
              behavior: SnackBarBehavior.floating
          ));
          Navigator.pop(context);
        }
      }
      else {
        print('Weight is above 5 : $weight');

        var headers = {'Content-Type': 'application/json'};
        var request = http.Request(
            'POST',
            Uri.parse('https://cakey-database.vercel.app/api/order/new'));

        request.body = json.encode({
          "CakeID": cakeID,
          "Cake_ID": cakeModId,
          "Title": cakeName,
          "Description": cakeDesc,
          "TypeOfCake": cakeType,
          "Images": cakeImage,
          "EggOrEggless": eggOreggless,
          "Price": cakePrice.toString(),
          "Flavour": flavs,
          "Shape": shape,
          "Theme": "Ben 10",
          "Article": artic[0],
          "MessageOnTheCake": cakeMessage,
          "SpecialRequest": cakeSplReq,
          "Weight": weight,
          "UserID": userID,
          "User_ID": userModId,
          "UserName": userName,
          "UserPhoneNumber": userPhone,
          "DeliveryAddress": userAddress,
          "DeliveryDate": deliverDate,
          "DeliverySession": deliverSession,
          "ItemCount": counts,
          "Discount": discount.toString(),
          "Total": bilTotal.toString(),
          "DeliveryCharge": deliveryCharge.toString(),
          "PaymentType": paymentType,
          "PaymentStatus": paymentType.toLowerCase() == "cash on delivery"
              ? "Cash On Delivery"
              : 'Paid',
          "DeliveryInformation": deliverType,
          "Gst": gstPrice.toString(),
          "Sgst": sgstPrice.toString(),
          "ExtraCharges": extraCharges.toString(),
          // "Above5KG":"y",
          // "Created_On":simplyFormat(time: DateTime.now())
        });

        request.headers.addAll(headers);

        http.StreamedResponse response = await request.send();

        if (response.statusCode == 200) {
          // print(await response.stream.bytesToString());

          if(json.decode(await response.stream.bytesToString())['statusCode'].toString()=="200"){
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Order Placed!'),
                behavior: SnackBarBehavior.floating
            ));
            Navigator.pop(context);
            NotificationService().showNotifications("Order Placed", "Your $cakeName Ordered.Thank You!");
            showOrderCompleteSheet();
          }else{
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Unable to Place Your Order'),
                behavior: SnackBarBehavior.floating
            ));
          }

        } else {
          print(response.reasonPhrase);

          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Error Occurred : ${response.reasonPhrase}'),
              behavior: SnackBarBehavior.floating
          ));

          Navigator.pop(context);
        }
      }
    }catch(e){
      print(e);
    }

  }


  //endregion

  @override
  void initState() {
    // TODO: implement initState
    recieveDetailsFromScreen();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(
          leading: Container(
            margin: const EdgeInsets.all(10),
            child: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                  decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10)),
                  alignment: Alignment.center,
                  height: 20,
                  width: 20,
                  child: Icon(
                    Icons.chevron_left,
                    color: lightPink,
                    size: 35,
                  )),
            ),
          ),
          title: Text('CHECKOUT',
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    cakeImage.isEmpty||!cakeImage.startsWith("http")?
                    Container(
                      height: 90,
                      width: 75,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          image: DecorationImage(
                              image: AssetImage('assets/images/customcake.png'),
                              fit: BoxFit.cover)
                      ),
                    ):
                    Container(
                      height: 90,
                      width: 75,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          image: DecorationImage(
                              image: NetworkImage('$cakeImage'),
                              fit: BoxFit.cover)
                      ),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Expanded(
                        child: Column(
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  child: Text('${cakeName} (Rs.$cakePrice) × $counts',style: TextStyle(
                                      fontSize: 12,fontFamily: "Poppins",fontWeight: FontWeight.bold
                                  ),overflow: TextOverflow.ellipsis,maxLines: 10,),
                                ),
                                SizedBox(height: 5,),
                                Text('(Flavour - ${flavs[0]['Name']}) + (Shape - ${shape}) + '
                                    '(Article - ${artic[0]['Name']}) = Rs.$extraCharges',style: TextStyle(
                                    fontSize: 11,fontFamily: "Poppins",color: Colors.grey[500]
                                ),overflow: TextOverflow.ellipsis,maxLines: 10),
                                Wrap(
                                  children: [
                                    for(var i in flavs)
                                      Text("(Flavour - ${i['Name']} Price - Rs.${i['Price']})",style: TextStyle(
                                          fontSize:10.5,fontFamily: "Poppins",
                                          color: Colors.black26
                                      ),),

                                    Text(" = Rs.$extraCharges",style: TextStyle(
                                        fontSize:10.5,fontFamily: "Poppins",
                                        color: Colors.black26
                                    ),)

                                  ],
                                ),
                                Text('₹ ${counts * int.parse(cakePrice) + double.parse(extraCharges)}',style: TextStyle(
                                    fontSize: 15,color: lightPink,fontWeight: FontWeight.bold,
                                    fontFamily: "Poppins"
                                ),
                                  overflow: TextOverflow.ellipsis,maxLines: 2,
                                ),
                              ],
                            )
                          ],
                        ))
                  ],
                ),
                SizedBox(
                  height: 15,
                ),
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(15),
                          bottomLeft: Radius.circular(15)),
                      color: Colors.black12),
                  child: Column(
                    children: [
                      ListTile(
                        title: const Text(
                          'Vendor',
                          style: const TextStyle(
                              fontSize: 11, fontFamily: "Poppins"),
                        ),
                        subtitle: Text(double.parse(weight.replaceAll("kg", ""))<6.0?
                          '${vendorName}':'Premium Vendor',
                          style: TextStyle(
                              fontSize: 14,
                              fontFamily: "Poppins",
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),
                        trailing: Container(
                          width: 100,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              InkWell(
                                onTap: () async{
                                  print('phone..');
                                  try{
                                    await launchUrl(Uri.parse("tel://$vendorMobile"));
                                  }catch(e){
                                    print('uri er : $e');
                                  }
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  height: 35,
                                  width: 35,
                                  decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white),
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
                                onTap: () async{
                                  print('whatsapp');
                                  String whatsapp = vendorMobile;
                                  var whatsappURl_android = "whatsapp://send?phone="+whatsapp+"&text=hello";
                                  var whatappURL_ios ="https://wa.me/$whatsapp?text=${Uri.parse("hello")}";
                                  if(Platform.isIOS){
                                    // for iOS phone only
                                    if( await canLaunch(whatappURL_ios)){
                                      await launch(whatappURL_ios, forceSafariVC: false);
                                    }else{
                                      ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: new Text("whatsapp no installed")));
                                    }
                                  }else{
                                    // android , web
                                    if( await canLaunch(whatsappURl_android)){
                                      await launch(whatsappURl_android);
                                    }else{
                                      ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: new Text("whatsapp no installed")));
                                    }
                                  }
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  height: 35,
                                  width: 35,
                                  decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white),
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
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.only(left: 15, bottom: 10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Cake Type',
                              style: TextStyle(
                                  fontSize: 11, fontFamily: "Poppins"),
                            ),
                            Text(
                              '${cakeType}',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: "Poppins",
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 10, right: 10),
                        color: Colors.black26,
                        height: 1,
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            width: 8,
                          ),
                          const Icon(
                            Icons.location_on,
                            color: Colors.red,
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          Container(
                              width: 260,
                              child: Text(
                                "$userAddress",
                                style: TextStyle(
                                    fontFamily: "Poppins",
                                    color: Colors.black54,
                                    fontSize: 13),
                              )),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      )
                    ],
                  ),
                ),
                Container(
                    margin: EdgeInsets.only(bottom: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          width:310,
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Text(
                            "Apply Coupon",
                            style: TextStyle(
                                fontFamily: "Poppins",
                                color: Colors.black54,
                                fontSize: 12),
                          ),
                        ),
                        Container(
                          height: 40,
                          width: MediaQuery.of(context).size.width,
                          child: TextField(
                            // onChanged: (){},
                              decoration: InputDecoration(

                                contentPadding: EdgeInsets.all(5),
                                border: OutlineInputBorder(),
                              )
                          ),
                        )
                      ],
                    )),
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(7)),
                      color: Colors.black12
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text('Item Total',style: TextStyle(
                              fontFamily: "Poppins",
                              color: Colors.black54,
                            ),),
                            Tooltip(
                              margin: EdgeInsets.only(left: 15,right: 15),
                              padding: EdgeInsets.all(15),
                              message: "Item total depends on itemcount/selected shape,flavour,article,weight",
                              child: Text('₹ ${(counts*int.parse(cakePrice, onError: (e)=>0) )+
                                  double.tryParse(extraCharges)!}',style: const TextStyle(fontWeight: FontWeight.bold),),
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
                            Text('₹ ${deliveryCharge}',style: const TextStyle(fontWeight: FontWeight.bold),),
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
                                      padding:EdgeInsets.only(right:10),
                                      child: orderFromCustom!="yes"?
                                      Text('${discount} %',style: const TextStyle(fontSize:10.5,),):null
                                  ),
                                  Text('₹ $discountPrice',style: const TextStyle(fontWeight: FontWeight.bold),),
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
                                      padding:EdgeInsets.only(right:10),
                                      child: orderFromCustom!="yes"?
                                      Text('${taxes} %',style: const TextStyle(fontSize:10.5,),):null
                                  ),
                                  Text('₹ ${gstPrice}',style: const TextStyle(fontWeight: FontWeight.bold),),
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
                                      padding:EdgeInsets.only(right:10),
                                      child: orderFromCustom!="yes"?
                                      Text('${taxes} %',style: const TextStyle(fontSize:10.5,),):null,
                                  ),
                                  Text('₹ ${sgstPrice}',style: const TextStyle(fontWeight: FontWeight.bold),),
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
                            Text('₹ ${bilTotal}',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17),),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),


                ExpansionTile(
                  maintainState: true,
                  initiallyExpanded: isExpand,
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
                  trailing: Container(
                    alignment: Alignment.center,
                    height: 25,
                    width: 25,
                    decoration: BoxDecoration(
                      color: Colors.red[100],
                      shape: BoxShape.circle ,
                    ),
                    child: Icon(Icons.keyboard_arrow_down_rounded , color: darkBlue,size: 25,),
                  ),
                  children: [
                    ListTile(
                      onTap: () {
                        setState(() {
                          paymentType = "UPI";
                          paymentIndex = 0;
                        });
                      },
                      leading: paymentIndex!=0?
                      Icon(Icons.radio_button_unchecked_rounded , color: Colors.green,):
                      Icon(Icons.check_circle , color: Colors.green,),
                      title: Text(
                        'UPI',
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
                    ListTile(
                      onTap: () {
                        setState(() {
                          paymentType = "Credit Card";
                          paymentIndex = 2;
                        });
                      },
                      leading: paymentIndex!=2?
                      Icon(Icons.radio_button_unchecked_rounded , color: Colors.green,):
                      Icon(Icons.check_circle , color: Colors.green,),
                      title: Text(
                        'Credit Card',
                        style: TextStyle(
                            color: darkBlue,
                            fontFamily: "Poppins",
                            fontSize: 14,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
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
                      orderFromCustom=="yes"?
                      confirmCustomOrder():
                      confirmOrder();
                    },
                    color: lightPink,
                    child: Text(
                      "PROCEED TO PAY",
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