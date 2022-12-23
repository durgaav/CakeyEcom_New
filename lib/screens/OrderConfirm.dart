import 'dart:convert';
import 'package:cakey/PaymentGateway.dart';
import 'package:cakey/screens/CheckOut.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Dialogs.dart';
import '../DrawerScreens/Notifications.dart';
import 'package:http/http.dart' as http;

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
  String cakePrice = '0.0';
  double topperPrice = 0.0;
  String cakeType = '';
  String eggOreggless = '';
  String deliverDate = '';
  String deliverSession = '';
  String cakeMessage = '';
  String cakeSplReq = '';
  String cakeArticle = '';
  String deliverType = '';
  double extraCharges = 0;
  int tierPrice = 0;
  String tierCakeWeight = "0";
  String cakeTier = "";
  List<String> toppings = [];

  //HYVOOB9SJFHMFA8L

  //vendor
  String vendorName = '';
  String vendorMobile = '';
  String vendorID = '';
  String vendorModId = '';
  String vendorAddress = '';
  String authToken = "";

  String vendorPhone1 = "";
  String vendorPhone2 = "";

  //User
  String userAddress = '';
  String userName = '';
  String userID = '';
  String userModId = '';
  String userPhone = '';

  String deiverDate = "";

  //int
  double itemsTotal = 0;
  int counts = 1;
  double deliveryCharge = 0;
  int discount = 0;
  int taxes = 0;
  double bilTotal = 0;

  double gstPrice = 0;
  double sgstPrice = 0;
  double discountPrice = 0;

  var topperName = "";
  var topperImage = "";
  var topperId = "";

  var premiumCake = "";

  var data = {};


  //region Functions

  //Default loader dialog
  void showAlertDialog(){
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context){
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


  Future<void> recieveDetailsFromScreen() async{

    //'orderCakeTopperid',
    // 'orderCakeTopperName'
    // 'orderCakeTopperImg',

    var prefs = await SharedPreferences.getInstance();

    try{
      //UI Views variables...
      setState(() {

        //Strings
        cakeName = prefs.getString("orderCakeName")!;
        topperName = prefs.getString("orderCakeTopperName")!;
        topperImage = prefs.getString("orderCakeTopperImg")!;
        topperId = prefs.getString("orderCakeTopperid")!;
        premiumCake = prefs.getString("orderCakeisPremium")!;
        cakeName = prefs.getString("orderCakeName")!;
        authToken = prefs.getString("authToken")!;
        cakePrice = prefs.getString("orderCakePrice")??'0';
        topperPrice = prefs.getDouble('orderCakeTopperPrice')??0.0;
        tierCakeWeight = prefs.getString('orderCakeTierWeight')??"0.0";
        // var addedToper = double.parse(cakePrice)+topperPrice;
        // cakePrice = addedToper.toString();
        cakeType = prefs.getString("orderCakeType")??'Cakes';
        if(cakeType.isEmpty){
          cakeType = "Cakes";
        }
        //cakeType = "Cakes";
        weight = prefs.getString("orderCakeWeight")!;
        eggOreggless = prefs.getString("orderCakeEggOrEggless")!;
        cakeImage = prefs.getString("orderCakeImages")!;
        userAddress = prefs.getString("orderCakeDeliverAddress")!;
        vendorName = prefs.getString("orderCakeVendorName")!;
        shape = prefs.getString("orderCakeShape")!;
        vendorPhone1 = prefs.getString("cakeVendorPhone1")!;
        vendorPhone2 = prefs.getString("cakeVendorPhone2")!;
        shape = prefs.getString("orderCakeShape")!;
        deliverType = prefs.getString('orderCakeDeliverType')??"None";

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
        deliverDate = prefs.getString('orderCakeDeliverDate')!;

        //get tier
        cakeTier = prefs.getString("orderCakeTier")!;

        //getTopper


        print('Tier $cakeTier');
        print('sgst $sgstPrice');
        print('sgst $gstPrice');
        print('--------------');

      });
    }catch(e){
      print(e);
    }

    getTaxDetails();

  }

  Future<void> getTaxDetails() async{

    var pref = await SharedPreferences.getInstance();

    showAlertDialog();

    double myTax = 0;
    double myPrice = double.parse((counts * (double.parse(cakePrice.toString())+
        double.parse(extraCharges.toString()))*
        double.parse(weight.toLowerCase().replaceAll('kg', ""))+topperPrice).toStringAsFixed(2));

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

  //endregion


  @override
  void initState() {
    // TODO: implement initState
    Future.delayed(Duration.zero , () async {
      recieveDetailsFromScreen();
      var pr = await SharedPreferences.getInstance();
      data = jsonDecode(pr.getString('theMainCakeDetails')??'');
      print("Maindata drom ... $data");
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading:Container(
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
                            SizedBox(height: 8,),
                            Text('(Shape - ${shape.replaceAll("Name", "").replaceAll("Price", "")
                                .replaceAll("{", "").replaceAll("}", "").replaceAll('"', '').replaceAll(":", "")
                                .replaceAll(",", "").replaceAll("0", "").replaceAll('"', "")})',style: TextStyle(
                                  fontSize: 11,fontFamily: "Poppins",color: Colors.grey[500]
                              ),overflow: TextOverflow.ellipsis,maxLines: 10),
                            // SizedBox(height: 5,),
                            Wrap(
                              children: [
                                for(var i in flav)
                                  Text("(Flavour - ${i['Name']}) "
                                      // "Price - Rs.${i['Price']})"
                                    ,style: TextStyle(
                                      fontSize:10.5,fontFamily: "Poppins",
                                      color: Colors.grey[500]
                                  ),),

                                // Text(" = Rs.$extraCharges",style: TextStyle(
                                //     fontSize:10.5,fontFamily: "Poppins",
                                //     color: Colors.black26
                                // ),)

                              ],
                            ),
                            Text.rich(
                              TextSpan(
                                text: '₹ ${(counts * (double.parse(cakePrice.toString()) +
                                    double.parse(extraCharges.toString()))*
                                    double.parse(weight.toLowerCase().replaceAll('kg', ""))+topperPrice).toStringAsFixed(2)}',
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
                        '${double.parse(weight.toLowerCase().replaceAll('kg', ""))>5.0?"Premium Vendor":vendorName}',style: TextStyle(
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
                                  print('phone..');
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
                            Text('${cakeType}',style: TextStyle(
                                fontSize: 13,fontFamily: "Poppins",
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
                                  "${userAddress.trim()}":"Pickuping by you.",
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
                              child: Text('₹ ${(counts * (double.parse(cakePrice.toString()) +
                                  double.parse(extraCharges.toString()))*
                                  double.parse(weight.toLowerCase().replaceAll('kg', ""))+topperPrice).toStringAsFixed(2)}',style: const TextStyle(fontWeight: FontWeight.bold),),
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
                      // Container(
                      //   padding: const EdgeInsets.all(10),
                      //   child: Row(
                      //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //     crossAxisAlignment: CrossAxisAlignment.center,
                      //     children: [
                      //       const Text('Discounts',style: const TextStyle(
                      //         fontFamily: "Poppins",
                      //         color: Colors.black54,
                      //       ),),
                      //       Row(
                      //           //${discount} % $discountPrice
                      //           children:[
                      //             Container(
                      //                 padding:EdgeInsets.only(right:5),
                      //                 child: Text('0 %',style: const TextStyle(fontSize:10.5,),)
                      //             ),
                      //             Text('₹ ${double.parse(discountPrice.toString()).toStringAsFixed(1)}',style: const TextStyle(fontWeight: FontWeight.bold),),
                      //           ]
                      //       )
                      //     ],
                      //   ),
                      // ),
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
                                      child: Text('${(taxes/2).toStringAsFixed(1)} %',style: const TextStyle(fontSize:10.5,),)
                                  ),
                                  Text('₹ ${sgstPrice.toStringAsFixed(2)}',style: const TextStyle(fontWeight: FontWeight.bold),),
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
                            Text('₹ ${
                                  ((counts * (
                                      double.parse(cakePrice)*
                                          double.parse(weight.toLowerCase().replaceAll('kg', ""))+
                                          (extraCharges*double.parse(weight.toLowerCase().replaceAll('kg', "")))
                                  ) + double.parse(gstPrice.toString()) + double.parse(sgstPrice.toString()) +
                                      deliveryCharge+topperPrice)
                                  ).toStringAsFixed(2)
                               }',
                              style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17),),
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
                      var pref = await SharedPreferences.getInstance();
                      pref.setString("orderFromCustom", "no");
                      //calculatedCountsAndPrice();
                      var paymentObj = {
                        "img": data['MainCakeImage'],
                        "name": data['CakeName'],
                        "egg":eggOreggless,
                        "price": (counts * (double.parse(cakePrice.toString()) +
                            double.parse(extraCharges.toString()))*
                            double.parse(weight.toLowerCase().replaceAll('kg', ""))+topperPrice).toStringAsFixed(2),
                        "count":counts,
                        "vendor": data['VendorName'],
                        "type":"Cakes",
                        "details": data,
                        "deliverType": deliverType,
                        "deliveryAddress": userAddress,
                        "deliverDate":deliverDate,
                        "deliverSession":deliverSession,
                        "deliverCharge":deliverType.toLowerCase()=="pickup"?0:deliveryCharge,
                        "discount":data['Discount'],
                        "extra_charges":extraCharges,
                        "weight":weight,
                        "flavours":flav,
                        "shapes":shape,
                        "tier":cakeTier,
                        "topper_price":topperPrice,
                        "topper_name":topperName,
                        "topper_image":topperImage,
                        "topper_id":topperId,
                        "msg_on_cake":cakeMessage,
                        "spl_req":cakeSplReq,
                        "premium_vendor":premiumCake,
                        "vendor_id":vendorID,
                        "cake_price":cakePrice.toString()
                      };

                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (c) => PaymentGateway(
                                paymentObjs: paymentObj,
                              )
                          )
                      );
                      //Navigator.push(context, MaterialPageRoute(builder:(contex)=>CheckOut(artic.toList() , flav.toList())));
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


