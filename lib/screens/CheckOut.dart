import 'dart:convert';
import 'package:cakey/drawermenu/DrawerHome.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../DrawerScreens/Notifications.dart';

class CheckOut extends StatefulWidget {
  const CheckOut({Key? key}) : super(key: key);
  @override
  State<CheckOut> createState() => _CheckOutState();
}

class _CheckOutState extends State<CheckOut> {

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

  List<String> toppings = [];


  //HYVOOB9SJFHMFA8L

  //vendor
  String vendorName = '';
  String vendorMobile = '';
  String vendorID = '';
  String vendorAddress = '';

  //User
  String userAddress = '';
  String userName = '';
  String userID = '';
  String userPhone = '';

  //int
  int itemTotal = 0;
  int counts = 1;
  int deliveryCharge = 0;
  int discount = 0;
  int taxes = 0;
  int bilTotal = 0;


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

  
  //confirm order
  Future<void> confirmOrder() async{
    showAlertDialog();
    String payStatus = '';
    if(paymentType.toLowerCase()=="cash on delivery"){
      setState(() {
        payStatus = paymentType;
      });
    }else{
      setState(() {
        payStatus = 'Paid';
      });
    }

    var headers = {
      'Content-Type': 'application/json'
    };
    var request = http.Request('POST', Uri.parse('https://cakey-database.vercel.app/api/order/new'));
    request.body = json.encode({

      "CakeID": "$cakeID",
      "Title": "$cakeName",
      "Description": "$cakeDesc",
      "TypeOfCake": "$cakeType",
      "Images": "$cakeImage",
      "EggOrEggless": "$eggOreggless",
      "Price": "$cakePrice",
      "Flavour": "$flavour",
      "Shape": "$shape",
      "CakeToppings": toppings,
      "MessageOnTheCake": "$cakeMessage",
      "SpecialRequest": "$cakeSplReq",
      "Weight": "$weight",
      "VendorID": "$vendorID",
      "VendorName": "$vendorName",
      "VendorPhoneNumber": "$vendorMobile",
      "UserID": "$userID",
      "UserName": "$userName",
      "UserPhoneNumber": "$userPhone",
      "DeliveryAddress": "$userAddress",
      "DeliveryDate": "$deliverDate",
      "DeliverySession": "$deliverSession",
      "VendorAddress": "$vendorAddress",
      "ItemCount": counts,
      "Discount": "$discount",
      "Total": "$bilTotal",
      "DeliveryCharge": "$deliveryCharge",
      "PaymentType": "$paymentType",
      "PaymentStatus": "$payStatus",
      "DeliveryInformation": "$deliverType",
      "Articles": "$cakeArticle",
      "Tax": "$taxes",
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
      Navigator.pop(context);
      showOrderCompleteSheet();
    }
    else {
      print(response.reasonPhrase);
      Navigator.pop(context);
    }
  }
  
  
  //order data
  Future<void> receiveOrderDetails() async{
    var prefs = await SharedPreferences.getInstance();

    setState(() {

      cakeID = prefs.getString('orderCakeID')!;
      shape = prefs.getString('orderCakeShape')!;
      weight = prefs.getString('orderCakeWeight')!;
      flavour = prefs.getString('orderCakeFlavour')!;
      eggOreggless = prefs.getString('orderCakeEggOrEggless')!;
      toppings = prefs.getStringList('orderCakeTopings')!;

      userID = prefs.getString('orderCakeUserID')!;
      userName = prefs.getString('orderCakeUserName')!;
      userPhone = prefs.getString('orderCakeUserNum')!;
      
      vendorID = prefs.getString('orderCakeVendorId')!;
      vendorAddress = prefs.getString('orderCakeVendorAddress')!;


      deliverSession = prefs.getString('orderCakeDeliverSession')!;
      deliverDate = prefs.getString('orderCakeDeliverDate')!;
      
      cakeMessage = prefs.getString('orderCakeMessage')!;
      cakeSplReq = prefs.getString('orderCakeRequest')!;
      deliverType = prefs.getString('orderCakeDeliveryInformation')!;
      cakeArticle = prefs.getString('orderCakeArticle')!;

      counts = prefs.getInt('orderCakeCounts')!;

      print(prefs.getString('orderCakeEggOrEggless'));
      print(prefs.getString('orderCakeFlavour'));
      print(prefs.getString('orderCakeShape'));
      print(prefs.getString('orderCakeWeight'));
      print(prefs.getStringList('orderCakeTopings'));
      print("ven id : "+prefs.getString('orderCakeID')!);
      print("ven"+vendorMobile);
      print("User id : "+prefs.getString('orderCakeUserID')!);
      print(prefs.getString('orderCakeUserName'));
      print(prefs.getString('orderCakeUserNum'));
      print(userAddress);
      print("ven"+vendorName);

      print(prefs.getString('orderCakeDeliverDate'));
      print(prefs.getString('orderCakeDeliverSession'));
      print("ven"+prefs.getString('orderCakeVendorAddress').toString());
      print(prefs.getInt('orderCakeCounts'));
      print(prefs.getInt('orderCakeDeliverAmt'));
    });

  }

  //prev screen data
  Future<void> recieveDetailsFromScreen() async{

    var prefs = await SharedPreferences.getInstance();

    setState(() {

      cakeImage = prefs.getString('orderCakeImages')
          ??'https://cdn4.vectorstock.com/i/1000x1000/25/63/cake-icon-set-of-great-flat-icons-with-style-vector-24172563.jpg';
      cakeName = prefs.getString('orderCakeName')??'';
      cakeDesc = prefs.getString('orderCakeDescription')??'';
      cakePrice = prefs.getString('orderCakePrice')??'';
      cakeType = prefs.getString('orderCakeType')??'';

      //user orderCakeDeliverAddress
      userAddress = prefs.getString('orderCakeDeliverAddress')??'';

      //vendors
      vendorName = prefs.getString('orderCakeVendorName')??'';
      vendorMobile = prefs.getString('orderCakeVendorNum')??'';

      //costs
      itemTotal = prefs.getInt('orderCakeItemCount')??0;
      deliveryCharge = prefs.getInt('orderCakeDeliverAmt')??0;
      discount = prefs.getInt('orderCakeDiscount')??0;
      taxes = prefs.getInt('orderCakeTaxes')??0;
      bilTotal = prefs.getInt('orderCakeTotalAmt')??0;

    });

  }

  //endregion


  @override
  void initState() {
    // TODO: implement initState
    recieveDetailsFromScreen();
    receiveOrderDetails();
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
          height: MediaQuery.of(context).size.height,
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
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                          child: Text('${cakeDesc}',style: TextStyle(
                              fontSize: 10,fontFamily: "Poppins",color: Colors.black26
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
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(width: 8,),
                          const Icon(
                            Icons.location_on,
                            color: Colors.red,
                          ),
                          const SizedBox(width: 8,),
                          Container(
                              width: 260,
                              child: Text(
                                "$userAddress",
                                style: TextStyle(
                                    fontFamily: "Poppins",
                                    color: Colors.black54,
                                    fontSize: 13
                                ),
                              )
                          ),
                        ],
                      ),
                      const SizedBox(height: 15,),
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
                            Text('₹${itemTotal}',style: const TextStyle(fontWeight: FontWeight.bold),),
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
                            Text('₹${deliveryCharge}',style: const TextStyle(fontWeight: FontWeight.bold),),
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
                            Text('${discount} %',style: const TextStyle(fontWeight: FontWeight.bold),),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text('Taxes',style: const TextStyle(
                              fontFamily: "Poppins",
                              color: Colors.black54,
                            ),),
                             Text('${taxes} %',style: const TextStyle(fontWeight: FontWeight.bold),),
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
                            Text('₹${bilTotal}',style: TextStyle(fontWeight: FontWeight.bold),),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                ExpansionTile(

                  title: Text('Payment type',style: TextStyle(
                    color: Colors.black26,fontFamily: "Poppins",fontSize: 12
                  ),),
                  subtitle: Text('$paymentType',style: TextStyle(
                      color: darkBlue,fontFamily: "Poppins",fontSize: 14,
                      fontWeight: FontWeight.bold
                  ),),
                  children: [
                    ListTile(
                      onTap: (){
                        setState(() {
                          paymentType = "UPI";
                        });
                      },
                      title:Text('UPI',style: TextStyle(
                          color: darkBlue,fontFamily: "Poppins",fontSize: 14,
                          fontWeight: FontWeight.bold
                      ),),
                    ),
                    ListTile(
                      onTap: (){
                        setState(() {
                          paymentType = "Cash on delivery";
                        });
                      },
                      title:Text('Cash On Delivery',style: TextStyle(
                          color: darkBlue,fontFamily: "Poppins",fontSize: 14,
                          fontWeight: FontWeight.bold
                      ),),
                    ),
                    ListTile(
                      onTap: (){
                        setState(() {
                          paymentType = "Credit Card";
                        });
                      },
                      title:Text('Credit Card',style: TextStyle(
                          color: darkBlue,fontFamily: "Poppins",fontSize: 14,
                          fontWeight: FontWeight.bold
                      ),),
                    ),
                  ],
                ),
                paymentType=="Credit Card"?
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.black12
                  ),
                  child: Column(
                    children: [
                      TextField(
                        decoration: InputDecoration(
                            label: Text('Name on card'),
                            hintText: "Name on card",
                            prefixIcon: Icon(Icons.account_circle)
                        ),
                      ),
                      TextField(
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                            label: Text('Card number'),
                            hintText: "Card number",
                            prefixIcon: Icon(Icons.credit_card_outlined)
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Container(
                            width: 130,
                            child: TextField(
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                  label: Text('Card Expiry'),
                                  hintText: "Card Expiry",
                              ),
                            ),
                          ),
                          Container(
                            width: 130,
                            child: TextField(
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                  label: Text('CVV'),
                                  hintText: "CVV",
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ) ,
                ):
                Container(),
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
                    onPressed: (){
                       confirmOrder();
                    },
                    color: lightPink,
                    child: Text("PROCEED TO PAY",style: TextStyle(
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

