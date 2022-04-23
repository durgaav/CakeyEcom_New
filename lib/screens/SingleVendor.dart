import 'dart:convert';

import 'package:cakey/DrawerScreens/CakeTypes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../ContextData.dart';
import 'package:http/http.dart' as http;
import '../DrawerScreens/Notifications.dart';
import 'Profile.dart';

class SingleVendor extends StatefulWidget {
  const SingleVendor({Key? key}) : super(key: key);
  @override
  State<SingleVendor> createState() => _SingleVendorState();
}

class _SingleVendorState extends State<SingleVendor> {

  //region Global
  //Colors
  Color lightGrey = Color(0xffF5F5F5);
  Color darkBlue = Color(0xffF213959);
  Color lightPink = Color(0xffFE8416D);

  String poppins = "Poppins";
  String profileUrl = "";
  String userCurLocation = 'Searching...';

  String description = "";
  String vendorID = '';
  String vendorName = '';
  String vendorPhone = '';
  String vendorLocalAddres = '';
  String deliverCharge = '';
  String profileImage = '';
  String vendorEggOrEggless = '';


  bool ordersNull = false;

  List<bool> isExpands = [];
  List vendorOrders = [];
  
  //endregion

  //region Alerts

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

  //endregion

  //region Functions

  //loadPrefs
  Future<void> loadPrefs() async{
    var pref = await SharedPreferences.getInstance();
    setState(() {
      userCurLocation = pref.getString('userCurrentLocation')??'Not Found';
    });
  }

  //get datas
  Future<void> receiveDataFromScreen() async{
    var pref = await SharedPreferences.getInstance();

    setState(() {

      vendorID = pref.getString('singleVendorID')??'';
      vendorName = pref.getString('singleVendorName')??'No name';
      description = pref.getString('singleVendorDesc')??'No Description';
      vendorPhone = pref.getString('singleVendorPhone')??'0000000000';
      deliverCharge = pref.getString('singleVendorDelivery')??'';
      profileImage = pref.getString('singleVendorDpImage')??'';
      vendorLocalAddres = pref.getString('singleVendorAddress')??'';
      vendorEggOrEggless = pref.getString('singleVendorEggs')??'';

      getOrdersByVendorId();
    });
  }

  //getting oreders by id
  Future<void> getOrdersByVendorId() async{
    showAlertDialog();

    try{
      var res = await http.get(Uri.parse('https://cakey-database.vercel.app/api/order/listbyvendorid/$vendorID'));

      if(res.statusCode==200){

        print(jsonDecode(res.body));

        setState(() {
          vendorOrders = jsonDecode(res.body);
          vendorOrders = vendorOrders.reversed.toList();
          print(vendorOrders);

          Navigator.pop(context);
        });

      }else{
        print(res.statusCode);
        Navigator.pop(context);
      }
    }catch (error){
      print(error);
      Navigator.pop(context);
    }


  }

  //load select Vendor data to CakeTypeScreen
  Future<void> loadSelVendorDataToCTscreen() async{



    var pref = await SharedPreferences.getInstance();

    pref.setString('myVendorId', vendorID);
    pref.setString('myVendorName', vendorName);
    pref.setString('myVendorPhone', vendorPhone);
    pref.setString('myVendorDesc', description);
    pref.setString('myVendorProfile', profileImage);
    pref.setString('myVendorDeliverChrg', deliverCharge);
    pref.setString('myVendorAddress', deliverCharge);
    pref.setString('myVendorEggs', vendorEggOrEggless);
    pref.setBool('iamYourVendor', true);

    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => CakeTypes(),
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


  }

  //endregion

  @override
  void initState() {
    // TODO: implement initState
    Future.delayed(Duration.zero , () async{
      receiveDataFromScreen();
      loadPrefs();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    profileUrl = context.watch<ContextData>().getProfileUrl();
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
                    color: Colors.black26,
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
        title: Text('$vendorName',
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
                      color: Colors.black26,
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
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(blurRadius: 3, color: Colors.black, spreadRadius: 0)
              ],
            ),
            child: InkWell(
              onTap: () {
                print('hello surya....');
                Navigator.of(context).push(
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => Profile(defindex: 0,),
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
              child: profileUrl!="null"?CircleAvatar(
                radius: 17.5,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                    radius: 16,
                    backgroundImage:NetworkImage("$profileUrl")
                ),
              ):CircleAvatar(
                radius: 17.5,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                    radius: 16,
                    backgroundImage:AssetImage("assets/images/user.png")
                ),
              ),
            ),
          ),
          SizedBox(
            width: 10,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.only(left:10,top: 8,bottom: 15),
              color: lightGrey,
              child: Column(
                children: [
                  Container(
                    child: Row(
                      children: [
                        Icon(Icons.location_on,color: Colors.red,),
                        SizedBox(width: 8,),
                        Text('Delivery to',style: TextStyle(color: Colors.black54,fontWeight: FontWeight.bold,
                            fontFamily: "Poppins"),)
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 8),
                    alignment: Alignment.centerLeft,
                    child: Text('$userCurLocation',style:TextStyle(fontFamily: "Poppins",fontSize: 18,color: darkBlue,fontWeight: FontWeight.bold),),
                  ),
                ],
              ),
            ),
            //Vendor name details......
            Container(
              padding: EdgeInsets.all(15),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //Vendor name and whatsapp...
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('$vendorName',style: TextStyle(
                            color: darkBlue,fontFamily:"Poppins",
                            fontSize: 16,fontWeight: FontWeight.bold
                          ),),
                          Row(
                            children: [
                              RatingBar.builder(
                                initialRating: 4.1,
                                minRating: 1,
                                direction: Axis.horizontal,
                                allowHalfRating: true,
                                itemCount: 5,
                                itemSize: 14,
                                itemPadding: EdgeInsets.symmetric(horizontal: 1.0),
                                itemBuilder: (context, _) => Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                ),
                                onRatingUpdate: (rating) {
                                  print(rating);
                                },
                              ),
                              Text(' 4.5',style: TextStyle(
                                  color: Colors.black54,fontWeight: FontWeight.bold,fontSize: 13,fontFamily: poppins
                              ),)
                            ],
                          ),
                        ],
                      ),

                      Container(
                        width: 100,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            InkWell(
                              onTap: (){
                                print('phone.. $vendorPhone');
                              },
                              child: Container(
                                alignment: Alignment.center,
                                height: 35,
                                width: 35,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: lightGrey,
                                ),
                                child:const Icon(Icons.phone,color: Colors.blueAccent,),
                              ),
                            ),
                            const SizedBox(width: 10,),
                            InkWell(
                              onTap: (){
                                print('whatsapp : $vendorPhone');
                              },
                              child: Container(
                                alignment: Alignment.center,
                                height: 35,
                                width: 35,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: lightGrey
                                ),
                                child:const Icon(Icons.whatsapp_rounded,color: Colors.green,),
                              ),
                            ),
                            const SizedBox(width: 10,),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10,),
                  Text('$vendorLocalAddres', style:TextStyle(
                    fontFamily: "Poppins",
                  )),
                  SizedBox(height: 10,),
                  //Sel button
                  InkWell(
                    splashColor: Colors.red[200],
                    onTap: ()=>loadSelVendorDataToCTscreen(),
                    child: Container(
                      height: 30,
                      width: 80,
                      alignment: Alignment.center,
                      padding: EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: darkBlue,width: 0.5)
                      ),
                      child: Text('SELECT',style: TextStyle(color: darkBlue,fontSize: 12),)
                    ),
                  ),
                  SizedBox(height: 10,),
                  //Theme text
                  Text('${description}',
                    style: TextStyle(color: darkBlue,
                      fontWeight: FontWeight.bold,),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 10,),
                  ExpandableText(
                      "$description",
                      expandText: "",
                      collapseText: "collapse",
                      expandOnTextTap: true,
                      collapseOnTextTap: true,
                      style: TextStyle(
                        color: Colors.grey,fontFamily: "Poppins"
                      ),
                  ),
                ],
              ),
            ),

            //Vendors recent orders....
            Padding(
              padding: const EdgeInsets.all(10),
              child: Text("History",
                style: TextStyle(color: darkBlue,fontSize: 14,fontFamily: "Poppins",fontWeight: FontWeight.bold),
              ),
            ),

            vendorOrders.isNotEmpty?
            Container(
              margin: EdgeInsets.all(10),
              child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: vendorOrders.length,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context,index){
                    isExpands.add(false);
                    return Card(
                        elevation: 6.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)
                        ),
                        child: Container(
                          padding: EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap:(){
                                  setState(() {
                                    if(isExpands[index]==false){
                                      isExpands[index]=true;
                                    }else{
                                      isExpands[index]=false;
                                    }
                                  });
                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(3),
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(20),
                                          color: Colors.black26
                                      ),
                                      child:Text('Order ID # ${vendorOrders[index]["_id"]}',style: const TextStyle(
                                          fontSize: 10,fontFamily: "Poppins",color: Colors.black
                                      ),),
                                    ),
                                    SizedBox(height: 6,),
                                    //Theme text
                                    Text('${vendorOrders[index]['Title']}',
                                      style: TextStyle(color: darkBlue,
                                          fontWeight: FontWeight.bold,fontSize: 13
                                      ),
                                      maxLines: 2,
                                    ),
                                    SizedBox(height: 6,),
                                    ExpandableText(
                                      '${vendorOrders[index]['Description']}',
                                      style: TextStyle(
                                          color: Colors.grey,fontFamily: "Poppins",fontSize: 12
                                      ),
                                      expandText: '',
                                      collapseText: 'collapse',
                                      maxLines: 3,
                                      collapseOnTextTap: true,
                                      expandOnTextTap: true,
                                    ),
                                    SizedBox(height: 3,),
                                    Container(
                                      height: 1,
                                      color: Colors.black26,
                                    ),SizedBox(height: 3,),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            RatingBar.builder(
                                              initialRating: 4.1,
                                              minRating: 1,
                                              direction: Axis.horizontal,
                                              allowHalfRating: true,
                                              itemCount: 5,
                                              itemSize: 14,
                                              itemPadding: EdgeInsets.symmetric(horizontal: 1.0),
                                              itemBuilder: (context, _) => Icon(
                                                Icons.star,
                                                color: Colors.amber,
                                              ),
                                              onRatingUpdate: (rating) {
                                                print(rating);
                                              },
                                            ),
                                            Text(' 4.5',style: TextStyle(
                                                color: Colors.black54,fontWeight: FontWeight.bold,fontSize: 13,fontFamily: poppins
                                            ),)
                                          ],
                                        ),
                                        vendorOrders[index]['Status'].toString().toLowerCase().contains('delivered')?
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text("Delivered ",style: TextStyle(color: Colors.green,
                                                    fontWeight: FontWeight.bold,fontFamily: "Poppins",fontSize: 11),),
                                                Icon(Icons.verified_rounded,color: Colors.green,size: 12,)
                                              ],
                                            ),
                                            SizedBox(width: 5,),
                                            Text("${vendorOrders[index]['Status_Updated_On'].toString().split(" ").first}",style: TextStyle(color: Colors.black26,
                                                fontFamily: "Poppins",fontSize: 10,fontWeight: FontWeight.bold),),
                                          ],
                                        ):
                                        Text('${vendorOrders[index]['Status'].toString()}',style: TextStyle(
                                            color: vendorOrders[index]['Status'].toString().toLowerCase().contains('cancelled')?
                                            Colors.red:Colors.blueAccent,
                                            fontWeight: FontWeight.bold,fontFamily: poppins,fontSize: 10),)
                                      ],
                                    ),
                                    SizedBox(height: 3,),
                                    Container(
                                      height: 1,
                                      color: Colors.black26,
                                    ),
                                    ListTile(
                                      title: Text('Customer',style: TextStyle(
                                          fontSize: 12,color: Colors.grey,fontFamily: "Poppins"
                                      ),),
                                      subtitle: Text('${vendorOrders[index]['UserName']}',style: TextStyle(
                                          fontSize: 13,color:darkBlue,fontFamily: "Poppins",
                                          fontWeight: FontWeight.bold
                                      ),),
                                    ),
                                  ],
                                ),
                              ),
                              Visibility(
                                visible:isExpands[index],
                                child: AnimatedContainer(
                                  duration: const Duration(seconds: 3),
                                  curve: Curves.elasticInOut,
                                  decoration: BoxDecoration(
                                    color: Colors.black12,
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(15),
                                      bottomRight: Radius.circular(15),
                                    )
                                  ),
                                  child: Column(
                                    children: [
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
                                                "${vendorOrders[index]['DeliveryAddress']}",
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
                                             Text('₹${vendorOrders[index]['Total']}',style: const TextStyle(fontWeight: FontWeight.bold),),
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
                                            Text(vendorOrders[index]['DeliveryCharge'].toString()!="null"?
                                              '₹${vendorOrders[index]['DeliveryCharge']}':'₹0',style: const TextStyle(fontWeight: FontWeight.bold),)
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
                                            Text(vendorOrders[index]['DeliveryCharge'].toString()!="null"?
                                            '₹${vendorOrders[index]['Discount']}':'₹0',style: const TextStyle(fontWeight: FontWeight.bold),),
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
                                            Text('₹0',style: const TextStyle(fontWeight: FontWeight.bold),),
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
                                             Text('₹${vendorOrders[index]['Total']}',style: TextStyle(fontWeight: FontWeight.bold),),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Text('Paid via : ${vendorOrders[index]['PaymentType']}',style: TextStyle(
                                              fontFamily: "Poppins",
                                              color: Colors.black54,
                                            ),),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                  }
              ),
            ):
            Center(
              child: Padding(
                padding:EdgeInsets.all(8.0),
                child: Text('No Orders Found!' , style: TextStyle(
                  color: darkBlue , fontFamily: "Poppins" ,
                  fontSize: 17 , fontWeight: FontWeight.bold
                ),),
              ),
            )
          ],
        ),
      )
    );
  }
}

