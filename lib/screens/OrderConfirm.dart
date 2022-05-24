import 'dart:convert';
import 'package:cakey/drawermenu/DrawerHome.dart';
import 'package:cakey/screens/CheckOut.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../DrawerScreens/Notifications.dart';

class OrderConfirm extends StatefulWidget {

  List flav , artic ;
  OrderConfirm({required this.flav, required this.artic});

  @override
  State<OrderConfirm> createState() => _OrderConfirmState(flav: flav , artic: artic);
}

class _OrderConfirmState extends State<OrderConfirm> {

  List flav , artic ;
  _OrderConfirmState({required this.flav, required this.artic});

  //Colors
  Color lightGrey = Color(0xffF5F5F5);
  Color darkBlue = Color(0xffF213959);
  Color lightPink = Color(0xffFE8416D);

  String poppins = "Poppins";

  List<bool> isExpands = [];

  String paymentType = "UPI";
  bool isExpand = false;

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

  List<String> toppings = [];


  //HYVOOB9SJFHMFA8L

  //vendor
  String vendorName = '';
  String vendorMobile = '';
  String vendorID = '';
  String vendorModId = '';
  String vendorAddress = '';

  //User
  String userAddress = '';
  String userName = '';
  String userID = '';
  String userModId = '';
  String userPhone = '';

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


  //region Functions

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

  void showOrderCompleteSheet(){
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(20),
              topLeft: Radius.circular(20),
            )
        ),
        context: context,
        builder: (context){
          return Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 15,),
                Container(
                  height: 150,
                  width: 150,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                          image: AssetImage('assets/images/chefdoll.jpg'),
                          fit: BoxFit.cover
                      )
                  ),
                ),
                SizedBox(height: 15,),
                Text('THANK YOU' , style:TextStyle(
                    color: Colors.deepPurple , fontFamily: "Poppins",
                    fontSize: 23 , fontWeight: FontWeight.bold
                )),Text('for your order' , style:TextStyle(
                    color: Colors.deepPurple , fontFamily: "Poppins",
                    fontSize: 13 , fontWeight: FontWeight.bold
                )),
                SizedBox(height: 15,),
                Center(
                  child: Text('Your order is now being processed.'
                      '\nWe will let you know once the order is picked \nfrom the outlet.' , style:TextStyle(
                      color: Colors.grey , fontFamily: "Poppins",
                      fontSize: 13 , fontWeight: FontWeight.bold
                  ) , textAlign: TextAlign.center,),
                ),
                SizedBox(height: 20,),
                GestureDetector(
                  onTap: (){
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DrawerHome()
                        ),
                        ModalRoute.withName('/DrawerHome')
                    );
                  },
                  child: Center(
                      child: Text('BACK TO HOME' , style:TextStyle(
                          color: lightPink , fontFamily: "Poppins",
                          fontSize: 13 , fontWeight: FontWeight.bold , decoration:TextDecoration.underline
                      ), textAlign: TextAlign.center,)
                  ),
                ),

              ],
            ),
          );
        }
    );
  }

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

    print(priceAfterDiscount);
    print(discountedPrice);


  }


  //endregion


  @override
  void initState() {
    // TODO: implement initState
    recieveDetailsFromScreen();
    print(flav);
    print(artic);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading:Container(
            margin: const EdgeInsets.all(10),
            child: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                  decoration: BoxDecoration(
                      color:Colors.grey[300],
                      borderRadius: BorderRadius.circular(10)
                  ),
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
          title: Text('ORDER CONFIRM',
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
          // height: MediaQuery.of(context).size.height,
          width: double.infinity,
          margin: EdgeInsets.all(15),
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Colors.black26,width: 1)
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
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
                    ),
                    Expanded(child: Column(
                      children: [
                        SizedBox(width: 5,),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 210,
                              child: Text('${cakeName}',style: TextStyle(
                                  fontSize: 12,fontFamily: "Poppins",fontWeight: FontWeight.bold
                              ),overflow: TextOverflow.ellipsis,maxLines: 2,),
                            ),
                            SizedBox(height: 5,),
                            Container(
                              width: 210,
                              child: Text('(Flavour - ${flav[0]['Name']}) + (Shape - ${shape})',style: TextStyle(
                                  fontSize: 11,fontFamily: "Poppins",color: Colors.grey[500]
                              ),overflow: TextOverflow.ellipsis,maxLines: 2,),
                            ),
                            SizedBox(height: 5,),
                            Text('₹ ${cakePrice}',style: TextStyle(
                                fontSize: 17,color: lightPink,fontWeight: FontWeight.bold
                            ),
                              overflow: TextOverflow.ellipsis,maxLines: 2,
                            ),
                          ],
                        )
                      ],
                    ))
                  ],
                ),
                SizedBox(height: 15,),
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(bottomRight: Radius.circular(25)
                          ,bottomLeft:  Radius.circular(15)
                      ),
                      color: Colors.black12
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        title: const Text('Vendor',style: const TextStyle(
                            fontSize: 11,fontFamily: "Poppins"
                        ),),
                        subtitle: Text('${vendorName}',style: TextStyle(
                            fontSize: 14,fontFamily: "Poppins",
                            fontWeight: FontWeight.bold,color: Colors.black
                        ),),
                        trailing: Container(
                          width: 100,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              InkWell(
                                onTap: (){
                                  print('phone..');
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
                                onTap: (){
                                  print('whatsapp');
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
                            Text('${cakeType}',style: TextStyle(
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
                        margin : EdgeInsets.all(5),
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
                                  "${userAddress}",
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
                      SizedBox(height: 15,),
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
                                      child: Text('${discount} %',style: const TextStyle(fontSize:10.5,),)
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
                                      child: Text('${taxes} %',style: const TextStyle(fontSize:10.5,),)
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
                                      child: Text('${taxes} %',style: const TextStyle(fontSize:10.5,),)
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

                SizedBox(height: 15,),
                Container(
                  height: 50,
                  width: 200,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25)
                  ),
                  child: RaisedButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25)
                    ),
                    onPressed: () async{
                      // calculatedCountsAndPrice();

                      Navigator.push(context, MaterialPageRoute(builder:(contex)=>CheckOut(artic.toList() , flav.toList())));
                    },
                    color: lightPink,
                    child: Text("CONFIRM YOUR ORDER",style: TextStyle(
                        color: Colors.white,fontWeight: FontWeight.bold
                    ),),
                  ),
                )
              ],
            ),
          ),
        )
    );
  }
}


