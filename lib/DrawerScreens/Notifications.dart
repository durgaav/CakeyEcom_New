import 'dart:async';
import 'dart:convert';
import 'package:cakey/Notification/Notification.dart';
import 'package:cakey/main.dart';
import 'package:cakey/screens/CheckOut.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class Notifications extends StatefulWidget {
  const Notifications({Key? key}) : super(key: key);

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {

  //Colors
  Color lightGrey = const Color(0xffF5F5F5);
  Color darkBlue = const Color(0xffF213959);
  Color lightPink = const Color(0xffFE8416D);

  var dateTime = DateTime.now();

  var months = [
    {"num":"01","mon":'Jan'},
    {"num":"02","mon":'Feb'},
    {"num":"03","mon":'Mar'},
    {"num":"04","mon":'Apr'},
    {"num":"05","mon":'May'},
    {"num":"06","mon":'Jun'},
    {"num":"07","mon":'Jul'},
    {"num":"08","mon":'Aug'},
    {"num":"09","mon":'Sep'},
    {"num":"10","mon":'Oct'},
    {"num":"11","mon":'Nav'},
    {"num":"12","mon":'Dec'},
  ];

  DateTime currentTime = DateTime.now();
  var result2 = '';
  // var dateTime = ["Mar 4th 2022","Mar 2nd 2022","Mar 1st 2022","May 2nd 2022","May 14th 2022","May 24th 2022","May 24th 2022"];
  int i = 0;

  // String data = 'new';
  List OrderList = [];
  List CustomizeList = [];
  List mainList=[];
  List ImageList=[];
  var fixedFlavList = [];

  String cakeId='';
  String userId='';

  int pageViewCurIndex = 0;

  String authToken = "";
  bool isLoading = true;

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


  //Buliding the dots by image length
  List<Widget> _buildPageIndicator() {
    List<Widget> list = [];
    for (int i = 0; i < ImageList.length; i++) {
      list.add(i == pageViewCurIndex ? _indicator(true) : _indicator(false));
    }
    return list;
  }

  Future<void> PriceInfo(index) async{
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title:  Text("Order Info",style: TextStyle(fontFamily: "Poppins")),
        content: Container(
          // height: MediaQuery.of(context).size.height*0.50,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                height: 100,
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.only(bottom: 10),
                child: Center(
                  child:  ImageList.length != 0
                      ? StatefulBuilder(
                      builder:(BuildContext context , void Function(void Function()) setState){
                        return Stack(
                            children:[
                              PageView.builder(
                                  itemCount: ImageList.length,
                                  onPageChanged: (int i){
                                    setState((){
                                      pageViewCurIndex = i;
                                    });
                                  },
                                  itemBuilder: (context, index) {
                                    return
                                      Container(
                                        decoration: BoxDecoration(
                                            borderRadius:
                                            BorderRadius.circular(20),
                                            color: Colors.black12,
                                            image: DecorationImage(
                                                image: NetworkImage(
                                                    "${ImageList[index]}"
                                                ),
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

                            ]
                        );
                      }
                  ) : Container(
                    height: 100,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage("assets/images/customcake.png")
                        )
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Delivery Date',style: TextStyle(fontFamily: "Poppins",fontSize: 12,fontWeight: FontWeight.bold),),
                  Text('-',style: TextStyle(fontFamily: "Poppins"),),
                  Text(mainList[index]['DeliveryDate'],style: TextStyle(fontFamily: "Poppins",fontSize: 12),),
                ],
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Delivery Time',style: TextStyle(fontFamily: "Poppins",fontSize: 12,fontWeight: FontWeight.bold),),
                  Text('-',style: TextStyle(fontFamily: "Poppins"),),
                  Text(mainList[index]['DeliverySession'],style: TextStyle(fontFamily: "Poppins",fontSize: 12),),
                ],
              ),

              SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Delivery Date',style: TextStyle(fontFamily: "Poppins",fontSize: 12,fontWeight: FontWeight.bold),),
                  Text('-',style: TextStyle(fontFamily: "Poppins"),),
                  Text(mainList[index]['DeliveryDate'],style: TextStyle(fontFamily: "Poppins",fontSize: 12),),
                ],
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Weight',style: TextStyle(fontFamily: "Poppins",fontSize: 12,fontWeight: FontWeight.bold),),
                  Text('-',style: TextStyle(fontFamily: "Poppins"),),
                  Text(mainList[index]['Weight'],style: TextStyle(fontFamily: "Poppins",fontSize: 12),),
                ],
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Price',style: TextStyle(fontFamily: "Poppins",fontSize: 12,fontWeight: FontWeight.bold),),
                  Text('-',style: TextStyle(fontFamily: "Poppins"),),
                  (mainList[index]['Price']==null)?Text('NAN'):Text('Rs. '+ mainList[index]['Price'],style: TextStyle(fontFamily: "Poppins",fontSize: 12),),

                  // Text('Rs. '+ mainList[index]['Price'],style: TextStyle(fontFamily: "Poppins",fontSize: 12),),
                ],
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Discount',style: TextStyle(fontFamily: "Poppins",fontSize: 12,fontWeight: FontWeight.bold),),
                  Text('-',style: TextStyle(fontFamily: "Poppins"),),
                  (mainList[index]['ExtraCharges']==null)?Text('NAN'):Text('Rs. '+ mainList[index]['ExtraCharges'],style: TextStyle(fontFamily: "Poppins",fontSize: 12),),

                  // Text('Rs. '+ mainList[index]['ExtraCharges'],style: TextStyle(fontFamily: "Poppins",fontSize: 12),),
                ],
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('GST',style: TextStyle(fontFamily: "Poppins",fontSize: 12,fontWeight: FontWeight.bold),),
                  Text('-',style: TextStyle(fontFamily: "Poppins"),),
                  (mainList[index]['Gst']==null)?Text('NAN'):Text('Rs. '+ mainList[index]['Gst'],style: TextStyle(fontFamily: "Poppins",fontSize: 12),),

                  // Text('Rs. '+ mainList[index]['Gst'],style: TextStyle(fontFamily: "Poppins",fontSize: 12),),
                ],
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('SGST',style: TextStyle(fontFamily: "Poppins",fontSize: 12,fontWeight: FontWeight.bold),),
                  Text('-',style: TextStyle(fontFamily: "Poppins"),),
                  (mainList[index]['Sgst']== null)?Text('NAN'):Text('Rs. '+ mainList[index]['Sgst'],style: TextStyle(fontFamily: "Poppins",fontSize: 12),),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Extra Charges',style: TextStyle(fontFamily: "Poppins",fontSize: 12,fontWeight: FontWeight.bold),),
                  Text('-',style: TextStyle(fontFamily: "Poppins"),),
                  Text('Rs. '+ mainList[index]['ExtraCharges'],style: TextStyle(fontFamily: "Poppins",fontSize: 12),),
                ],
              ),
              SizedBox(
                height: 5,
              ),
              Container(
                height: 1,
                width: MediaQuery.of(context).size.width,
                color: Colors.grey[200],
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total',style: TextStyle(fontFamily: "Poppins",fontSize: 12,fontWeight: FontWeight.bold),),
                  Text('-',style: TextStyle(fontFamily: "Poppins"),),
                  (mainList[index]['Total']== null)?Text('N/A'):Text('Rs. '+ mainList[index]['Total'],style: TextStyle(fontFamily: "Poppins",fontSize: 12),),

                  // Text('Rs. '+ mainList[index]['Total'],style: TextStyle(fontFamily: "Poppins",fontSize: 12),),
                ],
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: (){
              sendDetailstoScreen(index);
            },
            child: const Text('GO TO PAYMENT'),
          ),
        ],
      ),
    );
  }

  Future<void> CustomListPopup(index) async{
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title:  Text('Order Info',style: TextStyle(fontFamily: "Poppins")),
        content: Container(
          // height: MediaQuery.of(context).size.height*0.34,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                height: 100,
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.only(bottom: 10),
                child: Center(
                  child:  ImageList.length != 0
                      ? StatefulBuilder(
                      builder:(BuildContext context , void Function(void Function()) setState){
                        return Stack(
                            children:[
                              PageView.builder(
                                  itemCount: ImageList.length,
                                  onPageChanged: (int i){
                                    setState((){
                                      pageViewCurIndex = i;
                                    });
                                  },
                                  itemBuilder: (context, index) {
                                    return
                                      Container(
                                        decoration: BoxDecoration(
                                            borderRadius:
                                            BorderRadius.circular(20),
                                            color: Colors.black12,
                                            image: DecorationImage(
                                                image: NetworkImage(
                                                    "${ImageList[index]}"
                                                ),
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

                            ]
                        );
                      }
                  ) : Container(
                    height: 100,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: NetworkImage("https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT0jLPYNyRkX-mTp_5xlc0UbtIAlCOE8WJt3g&usqp=CAU")
                        )
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Delivery Date',style: TextStyle(fontFamily: "Poppins",fontSize: 12,fontWeight: FontWeight.bold),),
                  Text('-',style: TextStyle(fontFamily: "Poppins"),),
                  Text(mainList[index]['DeliveryDate'],style: TextStyle(fontFamily: "Poppins",fontSize: 12),),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Delivery Time',style: TextStyle(fontFamily: "Poppins",fontSize: 12,fontWeight: FontWeight.bold),),
                  Text('-',style: TextStyle(fontFamily: "Poppins"),),
                  Text(mainList[index]['DeliverySession'],style: TextStyle(fontFamily: "Poppins",fontSize: 12),),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Delivery Mode',style: TextStyle(fontFamily: "Poppins",fontSize: 12,fontWeight: FontWeight.bold),),
                  Text('-',style: TextStyle(fontFamily: "Poppins"),),
                  Text(mainList[index]['DeliveryInformation'],style: TextStyle(fontFamily: "Poppins",fontSize: 12),),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Status',style: TextStyle(fontFamily: "Poppins",fontSize: 12,fontWeight: FontWeight.bold),),
                  Text('-',style: TextStyle(fontFamily: "Poppins"),),
                  Text(mainList[index]['Status'],style: TextStyle(fontFamily: "Poppins",fontSize: 12),),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Weight',style: TextStyle(fontFamily: "Poppins",fontSize: 12,fontWeight: FontWeight.bold),),
                  Text('-',style: TextStyle(fontFamily: "Poppins"),),
                  Text(mainList[index]['Weight'],style: TextStyle(fontFamily: "Poppins",fontSize: 12),),
                ],
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future <void> OrderListPopup(index) async{
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title:  Text('Order Info',style: TextStyle(fontFamily: "Poppins")),
        content: Container(
          // height: MediaQuery.of(context).size.height*0.4,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.only(bottom: 10),
                child: Center(
                    child: (mainList[index]['Images']!=null)?
                    CircleAvatar(
                        radius: 50,
                        backgroundImage:
                        NetworkImage(mainList[index]['Images'].toString())
                    )
                        :CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.blue,
                      backgroundImage: AssetImage('assets/images/customcake.png'),
                    )
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Delivery Date',style: TextStyle(fontFamily: "Poppins",fontSize: 12,fontWeight: FontWeight.bold),),
                  // Text('-',style: TextStyle(fontFamily: "Poppins"),),
                  Text(mainList[index]['DeliveryDate'],style: TextStyle(fontFamily: "Poppins",fontSize: 12),),
                ],
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Delivery Time',style: TextStyle(fontFamily: "Poppins",fontSize: 12,fontWeight: FontWeight.bold),),
                  // Text('-',style: TextStyle(fontFamily: "Poppins"),),
                  Text(mainList[index]['DeliverySession'],style: TextStyle(fontFamily: "Poppins",fontSize: 12),),
                ],
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Delivery Mode',style: TextStyle(fontFamily: "Poppins",fontSize: 12,fontWeight: FontWeight.bold),),
                  // Text('-',style: TextStyle(fontFamily: "Poppins"),),
                  Text(mainList[index]['DeliveryInformation'],style: TextStyle(fontFamily: "Poppins",fontSize: 12),),
                ],
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Status',style: TextStyle(fontFamily: "Poppins",fontSize: 12,fontWeight: FontWeight.bold),),
                  // Text('-',style: TextStyle(fontFamily: "Poppins"),),
                  Text(mainList[index]['Status'],style: TextStyle(fontFamily: "Poppins",fontSize: 12),),
                ],
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Weight',style: TextStyle(fontFamily: "Poppins",fontSize: 12,fontWeight: FontWeight.bold),),
                  // Text('-',style: TextStyle(fontFamily: "Poppins"),),
                  Text(mainList[index]['Weight'],style: TextStyle(fontFamily: "Poppins",fontSize: 12),),
                ],
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Payment Type',style: TextStyle(fontFamily: "Poppins",fontSize: 12,fontWeight: FontWeight.bold),),
                  // Text('-',style: TextStyle(fontFamily: "Poppins"),),
                  Text(mainList[index]['PaymentType'],style: TextStyle(fontFamily: "Poppins",fontSize: 12),),
                ],
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total Price',style: TextStyle(fontFamily: "Poppins",fontSize: 12,fontWeight: FontWeight.bold),),
                  // Text('-',style: TextStyle(fontFamily: "Poppins"),),
                  Text('Rs. '+ mainList[index]['Total'],style: TextStyle(fontFamily: "Poppins",fontSize: 12),),
                ],
              ),



            ],
          ),
        ),
        actions: <Widget>[
          mainList[index]['Status'].toString().toLowerCase()=="new"?
          TextButton(
            onPressed: (){
              //cancel order
              cancelOrder(mainList[index]['_id'],mainList[index]['UserID'] ,mainList[index]['Title'] );
            },
            child: const Text('Cancel Order'),
          ):Text(""),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future <void> sendDetailstoScreen(index) async{

    var prefs = await SharedPreferences.getInstance();

    //region Remove Prefs

    print('*****removing....');

    prefs.remove('orderCakeID');
    prefs.remove('orderCakeModID');
    prefs.remove('orderCakeName');
    prefs.remove('orderCakeDescription');
    prefs.remove('orderCakeType');
    prefs.remove('orderCakeImages');
    prefs.remove('orderCakeEggOrEggless');
    prefs.remove('orderCakePrice');

    // prefs.remove('orderCakeFlavour',fixflavour.split("-").first.toString());

    prefs.remove('orderCakeShape');
    prefs.remove('orderCakeWeight');
    prefs.remove('orderCakeMessage');
    prefs.remove('orderCakeRequest');

    prefs.remove('orderCakeWeight');

    //vendor..
    prefs.remove('orderCakeVendorId');
    prefs.remove('orderCakeVendorModId');
    prefs.remove('orderCakeVendorName');
    prefs.remove('orderCakeVendorNum');
    prefs.remove('orderCakeVendorAddress');

    //user...
    prefs.remove('orderCakeUserName');
    prefs.remove('orderCakeUserID');
    prefs.remove('orderCakeUserModID');
    prefs.remove('orderCakeUserNum');
    prefs.remove('orderCakeDeliverAddress');
    prefs.remove('orderCakeDeliverDate');
    prefs.remove('orderCakeDeliverSession');
    prefs.remove('orderCakeDeliveryInformation');

    // prefs.remove('orderCakeArticle',fixedArticle);


    //for delivery...
    prefs.remove('orderCakeItemCount');
    prefs.remove('orderFromCustom');
    prefs.remove('orderCakeTotalAmt');
    prefs.remove('orderCakeDeliverAmt');
    prefs.remove('orderCakeDiscount');
    prefs.remove('orderCakeTaxes');
    prefs.remove('orderCakePaymentType');
    prefs.remove('orderCakePaymentStatus');
    prefs.remove('orderCakePaymentExtra');

    print('.....removed****');


    //endregion

    print(fixedFlavList);
    double flavCharge = 0.0;

    setState(() {
      if (fixedFlavList.isEmpty) {
        fixedFlavList = [
          {
            "Name": "Default Flavour",
            "Price": "0"
          }
        ];
      } else {
        fixedFlavList = fixedFlavList.toSet().toList();
      }


      print('Loading....');

      prefs.setString('orderCakeID', cakeId[index]);
      prefs.setString('orderFromCustom', "yes");
      prefs.setString('orderCakeModID', mainList[index]['Id'].toString());
      prefs.setString('orderCakeName', 'My Customized Cake');
      // prefs.setString('orderCakeDescription', cakeDescription);
      prefs.setString(
          'orderCakeType', mainList[index]['TypeOfCake'].toString()
      );
      // prefs.setString('orderCakeImages', ImageList[0].toString());
      prefs.setString(
          'orderCakeEggOrEggless', mainList[index]['EggOrEggless'].toString()
      );
      prefs.setString('orderCakePrice',mainList[index]['Price']);

      // prefs.setString('orderCakeFlavour',mainList[index]['EggOrEggless'].split("-").first.toString());

      prefs.setString('orderCakeShape',mainList[index]['Shape'].toString());
      prefs.setString('orderCakeWeight',mainList[index]['Weight'].toString());

      if(mainList[index]['MessageOnTheCake'].toString().isNotEmpty){
        prefs.setString('orderCakeMessage',mainList[index]['MessageOnTheCake'].toString());
      }else{
        prefs.setString('orderCakeMessage','No message');
      }

      if(mainList[index]['SpecialRequest'].toString().isNotEmpty){
        prefs.setString('orderCakeRequest',mainList[index]['SpecialRequest'].toString());
      }else{
        prefs.setString('orderCakeRequest','No special requests');
      }


      // prefs.setString('orderCakeWeight', mainList[index]['Weight'].toString());

      //vendor..
      prefs.setString('orderCakeVendorId', mainList[index]['VendorID'].toString());
      prefs.setString('orderCakeVendorModId', mainList[index]['Vendor_ID '].toString());
      prefs.setString('orderCakeVendorName', mainList[index]['VendorName'].toString());
      prefs.setString('orderCakeVendorNum', mainList[index]['VendorPhoneNumber'].toString());
      prefs.setString('orderCakeVendorAddress', mainList[index]['VendorAddress'].toString());

      //user...
      prefs.setString('orderCakeUserName', mainList[index]['UserName'].toString());
      prefs.setString('orderCakeUserID', mainList[index]['UserID'].toString());
      prefs.setString('userModId', mainList[index]['User_ID'].toString());
      prefs.setString('orderCakeUserNum', mainList[index]['UserPhoneNumber'].toString());
      prefs.setString('orderCakeDeliverAddress', mainList[index]['DeliveryAddress'].toString());
      prefs.setString('orderCakeDeliverDate', mainList[index]['DeliveryDate'].toString());
      prefs.setString('orderCakeDeliverSession', mainList[index]['DeliverySession'].toString());
      prefs.setString('orderCakeDeliveryInformation', mainList[index]['DeliveryInformation'].toString());

      // prefs.setString('orderCakeArticle',fixedArticle);


      //for delivery...
      prefs.setInt('orderCakeItemCount', 1);
      // prefs.setInt('orderCakePrice', int.parse(mainList[index]['Price'].toString()));
      prefs.setInt('orderCakeTotalAmt', int.parse(mainList[index]['Total'].toString()));
      prefs.setString('orderCakePaymentExtra', mainList[index]['ExtraCharges'].toString());
      // prefs.setInt('orderCakeDeliverAmt',fixedDelliverMethod=="Pickup"?0:50);
      prefs.setInt('orderCakeDiscount', mainList[index]['Discount']);
      prefs.setInt('orderCakeTaxes',int.parse(mainList[index]['Sgst'])+int.parse(mainList[index]['Sgst']));
      prefs.setString('orderCakePaymentType', 'none');
      prefs.setString('orderCakePaymentStatus', 'none');

      //
      // print(fixedWeight);
      //
      // if(fixedFlavList.isNotEmpty) {
      //   for (int i = 0; i < fixedFlavList.length; i++) {
      //     setState(() {
      //       flavCharge =
      //           double.parse(fixedWeight.replaceAll(new RegExp(r'[^0-9]'), ""))
      //               * (flavCharge + double.parse('${fixedFlavList[i]['Price']}'));
      //     });
      //   }
      //
      //   print(double.parse(fixedWeight.replaceAll(new RegExp(r'[^0-9]'), "")));
      //   print('flav charge :  $flavCharge');
      //
      //
      //   if (flavCharge == 0.0 && articleExtraCharge == 0) {
      //     prefs.setString('orderCakePaymentExtra', "0.0");
      //   } else {
      //     prefs.setString(
      //         'orderCakePaymentExtra', "${(flavCharge + articleExtraCharge)}");
      //   }
      // }
    });

    print(int.parse(mainList[index]['Sgst'])+int.parse(mainList[index]['Sgst']));

    // prefs.setString('orderCakeVendorNum', mainList[index]['VendorPhoneNumber'].toString());

    Navigator.push(context, MaterialPageRoute(builder: (context)=> CheckOut(
        mainList[index]['Flavour'].toList(),
        [
          {
            "Name": mainList[index]['Article']['Name'].toString(),
            "Price": mainList[index]['Article']['Price'].toString(),
          }
        ]
    ),));


  }

  //Show normal cake order Details View
  void showOrderDetailsDialog(int index){
    print(i);
    showModalBottomSheet(
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(10),
              topLeft: Radius.circular(10)
          ),
        ),
        context: context,
        builder: (context)=>StatefulBuilder(
            builder: (context,  void Function(void Function()) setState)=>
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(10),
                        topLeft: Radius.circular(10)
                    ),
                    color: Colors.grey[300],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      //cake image..
                      Container(
                        child:mainList[i]['Images'].toString().isNotEmpty?
                         Container(
                           // height: 85,
                           // width: 85,
                           // decoration: BoxDecoration(
                           //   shape: BoxShape.circle,
                           //   image: DecorationImage(
                           //     image: NetworkImage(mainList[i]['Images'].toString()),
                           //     fit: BoxFit.cover,
                           //   )
                           // ),
                         ):
                         Container()
                          // CircleAvatar(
                          //   backgroundImage:AssetImage("assets/images/customcake.png"),
                          //   radius: 35,
                          // )
                      ),
                      SizedBox(height: 10,),
                      //cake ID
                      Text(mainList[index]['Id'].toString() , style:TextStyle(
                        fontFamily: "Poppins",color:darkBlue,fontWeight: FontWeight.bold
                      ),),

                      SizedBox(height: 10,),
                      //Name and Price
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10)
                        ),
                        padding: EdgeInsets.all(8),
                        child:Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            mainList[index]['Title']!=null?
                              Text(mainList[index]['Title'].toString() , style:TextStyle(
                                fontFamily: "Poppins",color: lightPink,fontWeight: FontWeight.bold
                            ),):
                            Text("Customize Cake "+mainList[index]['Id'] , style:TextStyle(
                                fontFamily: "Poppins",color:lightPink,fontWeight: FontWeight.bold
                            ),),
                            SizedBox(height: 6,),

                            //item total
                            Row(
                              children: [
                                Text('Item Total', style:TextStyle(
                                    fontFamily: "Poppins",color:darkBlue,fontWeight: FontWeight.bold
                                )),
                                Expanded(child:Container(
                                  alignment: Alignment.centerRight,
                                  child: Text(mainList[index]['Total']==null?'N/A':
                                  'Rs.${mainList[index]['Total']}', style:TextStyle(
                                      fontFamily: "Poppins",color:darkBlue,fontWeight: FontWeight.normal
                                  )),
                                ))
                              ],
                            ),

                            SizedBox(height: 6,),

                            Row(
                              children: [
                                Text('Cake Type', style:TextStyle(
                                    fontFamily: "Poppins",color:darkBlue,fontWeight: FontWeight.bold
                                )),
                                Expanded(child:Container(
                                  alignment: Alignment.centerRight,
                                  child: Text(mainList[index]['TypeOfCake']==null?'N/A':
                                  '${mainList[index]['TypeOfCake']}', style:TextStyle(
                                      fontFamily: "Poppins",color:darkBlue,fontWeight: FontWeight.normal
                                  )),
                                ))
                              ],
                            ),

                            SizedBox(height: 6,),

                            Row(
                              children: [
                                Text('Updated On', style:TextStyle(
                                    fontFamily: "Poppins",color:darkBlue,fontWeight: FontWeight.bold
                                )),
                                Expanded(child:Container(
                                  alignment: Alignment.centerRight,
                                  child: Text(mainList[index]['Created_On']==null?'N/A':
                                  '${mainList[index]['Created_On']}', style:TextStyle(
                                      fontFamily: "Poppins",color:darkBlue,fontWeight: FontWeight.normal
                                  )),
                                ))
                              ],
                            ),

                            SizedBox(height: 6,),

                            Row(
                              children: [
                                Text('Deliver Date', style:TextStyle(
                                    fontFamily: "Poppins",color:darkBlue,fontWeight: FontWeight.bold
                                )),
                                Expanded(child:Container(
                                  alignment: Alignment.centerRight,
                                  child: Text(mainList[index]['DeliveryDate']==null?'N/A':
                                  '${mainList[index]['DeliveryDate']}', style:TextStyle(
                                      fontFamily: "Poppins",color:darkBlue,fontWeight: FontWeight.normal
                                  )),
                                ))
                              ],
                            ),

                            SizedBox(height: 6,),

                            Row(
                              children: [
                                Text('Status', style:TextStyle(
                                    fontFamily: "Poppins",color:darkBlue,fontWeight: FontWeight.bold
                                )),
                                Expanded(child:Container(
                                  alignment: Alignment.centerRight,
                                  child: Text(mainList[index]['Status']==null?'N/A':
                                  '${mainList[index]['Status']}', style:TextStyle(
                                      fontFamily: "Poppins",
                                      color:mainList[index]['Status'].toString().toLowerCase()=="new"?
                                      Colors.red:
                                      mainList[index]['Status'].toString().toLowerCase()=="preparing"?
                                      Colors.blue:
                                      mainList[index]['Status'].toString().toLowerCase()=="delivered"?
                                      Colors.green:darkBlue,
                                      fontWeight: FontWeight.normal
                                  )),
                                ))
                              ],
                            ),

                            SizedBox(height: 6,),

                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Deliver Address', style:TextStyle(
                                    fontFamily: "Poppins",color:darkBlue,fontWeight: FontWeight.bold
                                )),
                                SizedBox(width: 4,),
                                Expanded(child:Container(
                                  alignment: Alignment.centerRight,
                                  child: Text(mainList[index]['DeliveryAddress']==null?'N/A':
                                  '${mainList[index]['DeliveryAddress']}', textAlign: TextAlign.end,style:TextStyle(
                                      fontFamily: "Poppins",
                                      color:darkBlue,
                                      fontWeight: FontWeight.normal
                                  )),
                                ))
                              ],
                            ),

                            SizedBox(height: 6,),


                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Payment Status', style:TextStyle(
                                    fontFamily: "Poppins",color:darkBlue,fontWeight: FontWeight.bold
                                )),
                                SizedBox(width: 4,),
                                Expanded(child:Container(
                                  alignment: Alignment.centerRight,
                                  child: Text(mainList[index]['PaymentStatus']==null?'N/A':
                                  '${mainList[index]['PaymentStatus']}', textAlign: TextAlign.end,style:TextStyle(
                                      fontFamily: "Poppins",
                                      color:mainList[index]['PaymentStatus'].toString().toLowerCase()=="paid"?
                                      Colors.green:Colors.red,
                                      fontWeight: FontWeight.normal
                                  )),
                                ))
                              ],
                            ),

                            SizedBox(height: 6,),


                          ],
                        )
                      ),

                      Container(
                        child:Row(
                          children: [
                            // Expanded(child:
                            //  mainList[index]['PaymentStatus'].toString().toLowerCase()=='cash on delivery'||
                            //      mainList[index]['PaymentStatus']==null?
                            //  Container(
                            //   margin: EdgeInsets.all(5),
                            //   child: RaisedButton(
                            //     onPressed: (){
                            //
                            //     },
                            //     child: Text('PAY NOW' , style: TextStyle(
                            //       color: Colors.white, fontWeight: FontWeight.bold, fontFamily: "Poppins"
                            //     ),),
                            //     color: darkBlue,
                            //     shape: RoundedRectangleBorder(
                            //       borderRadius: BorderRadius.circular(13)
                            //     ),
                            //   ),
                            // ):
                            //  Container(
                            //    margin: EdgeInsets.all(5),
                            //    child: RaisedButton(
                            //      onPressed: (){
                            //
                            //      },
                            //      child: Text('CONTACT VENDOR' , style: TextStyle(
                            //          color: Colors.white, fontWeight: FontWeight.bold, fontFamily: "Poppins"
                            //      ),),
                            //      color: darkBlue,
                            //      shape: RoundedRectangleBorder(
                            //          borderRadius: BorderRadius.circular(13)
                            //      ),
                            //    ),
                            //  )
                            // ),
                            Expanded(child: Container(
                              margin: EdgeInsets.all(5),
                              child: RaisedButton(
                                onPressed: ()=>Navigator.pop(context),
                                child: Text('CLOSE' , style: TextStyle(
                                    color: Colors.white, fontWeight: FontWeight.bold, fontFamily: "Poppins"
                                ),),
                                color: darkBlue,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(13)
                                ),
                              ),
                            )),
                          ],
                        ),
                      )

                    ],
                  ),
                ),
        )
    );
  }

  //show custom cake order view
  void showCustomCakeDetailsDialog(int index){
    var opac = 1.0;
    var timer = new Timer(Duration(seconds: 2), () {setState((){opac = 1.0;});});
    timer;
    showModalBottomSheet(
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(10),
              topLeft: Radius.circular(10)
          ),
        ),
        context: context,
        builder: (context)=>StatefulBuilder(
          builder: (context,  void Function(void Function()) setState)=>
              AnimatedOpacity(
                duration: Duration(microseconds: 400),
                opacity: opac,
                curve: Curves.ease,
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(10),
                        topLeft: Radius.circular(10)
                    ),
                    color: Colors.pink[300],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      //cake image..
                      Container(
                          child:mainList[i]['Images'].toString().isNotEmpty?
                          Container(
                            // height: 85,
                            // width: 85,
                            // decoration: BoxDecoration(
                            //   shape: BoxShape.circle,
                            //   image: DecorationImage(
                            //     image: NetworkImage(mainList[i]['Images'].toString()),
                            //     fit: BoxFit.cover,
                            //   )
                            // ),
                          ):
                          Container()
                        // CircleAvatar(
                        //   backgroundImage:AssetImage("assets/images/customcake.png"),
                        //   radius: 35,
                        // )
                      ),
                      SizedBox(height: 10,),
                      //cake ID
                      Text(mainList[index]['Id'].toString() , style:TextStyle(
                          fontFamily: "Poppins",color: Colors.white,fontWeight: FontWeight.bold
                      ),),

                      SizedBox(height: 10,),
                      //Name and Price
                      Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10)
                          ),
                          padding: EdgeInsets.all(8),
                          child:Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              mainList[index]['Title']!=null?
                              Text(mainList[index]['Title'].toString() , style:TextStyle(
                                  fontFamily: "Poppins",color: lightPink,fontWeight: FontWeight.bold
                              ),):
                              Text("Customize Cake "+mainList[index]['Id'] , style:TextStyle(
                                  fontFamily: "Poppins",color:lightPink,fontWeight: FontWeight.bold
                              ),),
                              SizedBox(height: 6,),

                              //item total
                              Row(
                                children: [
                                  Text('Item Total', style:TextStyle(
                                      fontFamily: "Poppins",color:darkBlue,fontWeight: FontWeight.bold
                                  )),
                                  Expanded(child:Container(
                                    alignment: Alignment.centerRight,
                                    child: Text(mainList[index]['Total']==null?'N/A':
                                    'Rs.${mainList[index]['Total']}', style:TextStyle(
                                        fontFamily: "Poppins",color:darkBlue,fontWeight: FontWeight.normal
                                    )),
                                  ))
                                ],
                              ),

                              SizedBox(height: 6,),

                              Row(
                                children: [
                                  Text('Cake Type', style:TextStyle(
                                      fontFamily: "Poppins",color:darkBlue,fontWeight: FontWeight.bold
                                  )),
                                  Expanded(child:Container(
                                    alignment: Alignment.centerRight,
                                    child: Text(mainList[index]['TypeOfCake']==null?'N/A':
                                    '${mainList[index]['TypeOfCake']}', style:TextStyle(
                                        fontFamily: "Poppins",color:darkBlue,fontWeight: FontWeight.normal
                                    )),
                                  ))
                                ],
                              ),

                              SizedBox(height: 6,),

                              Row(
                                children: [
                                  Text('Ordered On', style:TextStyle(
                                      fontFamily: "Poppins",color:darkBlue,fontWeight: FontWeight.bold
                                  )),
                                  Expanded(child:Container(
                                    alignment: Alignment.centerRight,
                                    child: Text(mainList[index]['Created_On']==null?'N/A':
                                    '${mainList[index]['Created_On']}', style:TextStyle(
                                        fontFamily: "Poppins",color:darkBlue,fontWeight: FontWeight.normal
                                    )),
                                  ))
                                ],
                              ),

                              SizedBox(height: 6,),

                              Row(
                                children: [
                                  Text('Deliver Date', style:TextStyle(
                                      fontFamily: "Poppins",color:darkBlue,fontWeight: FontWeight.bold
                                  )),
                                  Expanded(child:Container(
                                    alignment: Alignment.centerRight,
                                    child: Text(mainList[index]['DeliveryDate']==null?'N/A':
                                    '${mainList[index]['DeliveryDate']}', style:TextStyle(
                                        fontFamily: "Poppins",color:darkBlue,fontWeight: FontWeight.normal
                                    )),
                                  ))
                                ],
                              ),

                              SizedBox(height: 6,),

                              Row(
                                children: [
                                  Text('Status', style:TextStyle(
                                      fontFamily: "Poppins",color:darkBlue,fontWeight: FontWeight.bold
                                  )),
                                  Expanded(child:Container(
                                    alignment: Alignment.centerRight,
                                    child: Text(mainList[index]['Status']==null?'N/A':
                                    '${mainList[index]['Status']}', style:TextStyle(
                                        fontFamily: "Poppins",
                                        color:mainList[index]['Status'].toString().toLowerCase()=="new"?
                                        Colors.red:
                                        mainList[index]['Status'].toString().toLowerCase()=="preparing"?
                                        Colors.blue:
                                        mainList[index]['Status'].toString().toLowerCase()=="delivered"?
                                        Colors.green:darkBlue,
                                        fontWeight: FontWeight.normal
                                    )),
                                  ))
                                ],
                              ),

                              SizedBox(height: 6,),

                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Deliver Address', style:TextStyle(
                                      fontFamily: "Poppins",color:darkBlue,fontWeight: FontWeight.bold
                                  )),
                                  SizedBox(width: 4,),
                                  Expanded(child:Container(
                                    alignment: Alignment.centerRight,
                                    child: Text(mainList[index]['DeliveryAddress']==null?'N/A':
                                    '${mainList[index]['DeliveryAddress']}', textAlign: TextAlign.end,style:TextStyle(
                                        fontFamily: "Poppins",
                                        color:darkBlue,
                                        fontWeight: FontWeight.normal
                                    )),
                                  ))
                                ],
                              ),

                              SizedBox(height: 6,),


                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Payment Status', style:TextStyle(
                                      fontFamily: "Poppins",color:darkBlue,fontWeight: FontWeight.bold
                                  )),
                                  SizedBox(width: 4,),
                                  Expanded(child:Container(
                                    alignment: Alignment.centerRight,
                                    child: Text(mainList[index]['PaymentStatus']==null?'N/A':
                                    '${mainList[index]['PaymentStatus']}', textAlign: TextAlign.end,style:TextStyle(
                                        fontFamily: "Poppins",
                                        color:mainList[index]['PaymentStatus'].toString().toLowerCase()=="paid"?
                                        Colors.green:Colors.red,
                                        fontWeight: FontWeight.normal
                                    )),
                                  ))
                                ],
                              ),

                              SizedBox(height: 6,),


                            ],
                          )
                      ),

                      Container(
                        child:Row(
                          children: [
                            Expanded(child:
                            mainList[index]['PaymentStatus'].toString().toLowerCase()=='cash on delivery'||
                                mainList[index]['PaymentStatus']==null?
                            Container(
                              margin: EdgeInsets.all(5),
                              child: RaisedButton(
                                onPressed: (){},
                                child: Text('PAY NOW' , style: TextStyle(
                                    color: Colors.white, fontWeight: FontWeight.bold, fontFamily: "Poppins"
                                ),),
                                color: darkBlue,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(13)
                                ),
                              ),
                            ):
                            Container(
                              margin: EdgeInsets.all(5),
                              child: RaisedButton(
                                onPressed: (){},
                                child: Text('CONTACT VENDOR' , style: TextStyle(
                                    color: Colors.white, fontWeight: FontWeight.bold, fontFamily: "Poppins"
                                ),),
                                color: darkBlue,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(13)
                                ),
                              ),
                            )
                            ),
                            Expanded(child: Container(
                              margin: EdgeInsets.all(5),
                              child: RaisedButton(
                                onPressed: ()=>Navigator.pop(context),
                                child: Text('CLOSE' , style: TextStyle(
                                    color: Colors.white, fontWeight: FontWeight.bold, fontFamily: "Poppins"
                                ),),
                                color: darkBlue,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(13)
                                ),
                              ),
                            )),
                          ],
                        ),
                      )

                    ],
                  ),
                ),
              ),
        )
    );
  }


  //region Functions

  //get notifications
  Future<void> fetchNotifications() async {
    List statusOn = [];
    List createOn = [];
    mainList.clear();
    setState((){
      isLoading = true;
    });
    try {
      var res = await http.get(Uri.parse(
          "https://cakey-database.vercel.app/api/users/notification/$userId"),
          headers: {"Authorization":"$authToken"});
      print(res.statusCode);
      if (res.statusCode == 200) {
        setState(() {

          List a = jsonDecode(res.body)['CustomizeCakesList'];
          List b = jsonDecode(res.body)['OrdersList'];

          // b.sort((a, b)=>a['Created_On'].toString().compareTo('${dateTime}'));

          // b.sort((a,b){
          //   if(a['Status_Updated_On']==null){
          //     return a['Created_On'].toString().compareTo('${dateTime}');
          //   }else{
          //     return a['Status_Updated_On'].toString().compareTo('${dateTime}');
          //   }
          // });

          mainList = a.toList() + b.reversed.toList();


          for(int i=0; i<mainList.length;i++){
            if(mainList[i]['Status_Updated_On']==null){
              createOn.add(mainList[i]);
            }else{
              statusOn.add(mainList[i]);
            }
          }

          print(statusOn.length);
          print(createOn.length);

          // createOn.sort((a,b)=>a['Created_On'].toString().compareTo("${dateTime}"));
          // statusOn.sort((a,b)=>a['Status_Updated_On'].toString().compareTo("${dateTime}"));

          mainList = createOn.reversed.toList() + statusOn;

          mainList = mainList.reversed.toList();


          for(int i = 0 ; i < mainList.length ; i++){
            if(mainList[i]['Status_Updated_On']!=null){
              setState(() {
                mainList[i]['Created_On'] =  mainList[i]['Status_Updated_On'];
              });
            }
          }

          mainList.sort((a,b)=>a['Created_On'].toString().compareTo(b['Created_On'].toString()));
          // mainList.sort((a,b)=>a['Status_Updated_On'].toString().compareTo(b['Status_Updated_On'].toString()));


          // mainList.sort((a,b)=>a['Created_On'].toString().compareTo("${dateTime}"));

          mainList = mainList.reversed.toList();

          for(int i=0 ; i<mainList.length ; i++){
            print('create');
            print(mainList[i]['Created_On']);

            print('update');
            print(mainList[i]['Status_Updated_On']);
          }

          isLoading = false;
          print(mainList.length);

        });
      }else{
        setState((){
          isLoading = true;
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error Occurred!'))
          );
        });
      }
    } catch (e) {
      print(e);
      setState((){
        isLoading = false;
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error Occurred!'),behavior: SnackBarBehavior.floating,)
        );
      });
    }
  }

  //Order Cancellations
  Future<void> cancelOrder(String id , String byId, String title) async{
    Navigator.pop(context);
    showAlertDialog();
    var headers = {
      'Content-Type': 'application/json'
    };
    var request = http.Request('PUT', Uri.parse('https://cakey-database.vercel.app/api/order/updatestatus/$id'));
    request.body = json.encode({
      "Status": "Cancelled",
      "Status_Updated_By": "$byId"
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order is canceled!'))
      );
      setState((){
        fetchNotifications();
      });
      NotificationService().showNotifications("Order Cancelled", "Your $title order is cancelled.");
      Navigator.pop(context);
    }
    else {
      print(response.reasonPhrase);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error Occurred!'))
      );
      Navigator.pop(context);
    }
  }

  //Status Updating
  Future <void> updateStatus(index) async{
    try{
      var url = Uri.parse('https://cakey-database.vercel.app/api/customize/cake/update/notification/${cakeId}');
      var response = await http.put(url, body: {'Notification':'seen'});
      print('Response body: ${response.body}');
      print(cakeId);
    }catch(e){
      print(e);
    }
  }

  //endregion

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration.zero, () async {
      var prefs = await SharedPreferences.getInstance();
      userId = prefs.getString('userID').toString();
      authToken = prefs.getString('authToken').toString();
      // print('user id.....   $userId');
      fetchNotifications();
      // updateStatus();
    });
    // Full date and time
    final result1 = simplyFormat(time: currentTime);
  }

  @override
  Widget build(BuildContext context) {
    result2 = simplyFormat(time: currentTime, dateOnly: true);
    print(result2);
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          fetchNotifications();
        });
      },
      child: Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(50),
            child:SafeArea(
              child: Container(
                padding: EdgeInsets.only(left: 15),
                height: 50,
                color:lightGrey,
                child:Row(
                  children: [
                    Container(
                      // margin: const EdgeInsets.only(top: 10,bottom: 15),
                      child: InkWell(
                        onTap: (){
                          Navigator.pop(context);
                        },
                        child: Container(
                          height: 30,
                          decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(7)
                          ),
                          alignment: Alignment.center,
                          child: Icon(Icons.chevron_left,size: 30,color: lightPink,),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 15),
                      child: Text(
                        'NOTIFICATION',
                        style: TextStyle(
                            color: darkBlue,
                            fontWeight: FontWeight.bold,
                            fontSize: 17),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ),
          body:SingleChildScrollView(
                child: Container(
                    height: MediaQuery.of(context).size.height*0.95,
                    child:isLoading
                        ? ListView.builder(
                        itemCount: 10,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemBuilder: (count, index) {
                          return Shimmer.fromColors(
                            baseColor: Colors.grey[400]!,
                            highlightColor: Colors.grey[300]!,
                            child: Container(
                              padding: EdgeInsets.all(10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    height: 70,
                                    width: 70,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    child: Container(
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            // width: 260,
                                            height: 70,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                BorderRadius.circular(15),
                                                color: Colors.grey),
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Container(
                                            width: 130,
                                            height: 15,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                BorderRadius.circular(15),
                                                color: Colors.grey),
                                          )
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        })
                        : (mainList.length > 0)
                        ? ListView.builder(
                        itemCount: mainList.length,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: (){
                              // //
                              // // print(mainList[index]['Notification']);
                              // if(mainList[index]['Notification']!=null)
                              // {
                              //   if (mainList[index]['Notification'] == 'seen') {
                              //     setState(() {
                              //       CustomListPopup(index);
                              //     });
                              //   }else  if(mainList[index]['Notification']=='unseen'){
                              //     setState(() {
                              //       PriceInfo(index);
                              //       cakeId = mainList[index]['_id'];
                              //       print(cakeId);
                              //       updateStatus(index);
                              //     });
                              //   }
                              // }
                              // else {
                              //   setState(() {
                              //     OrderListPopup(index);
                              //   });
                              // }

                              if(mainList[index]['CustomizeCake']=='n'){
                                showOrderDetailsDialog(index);
                              }else if(mainList[index]['CustomizeCake']==null){
                                showCustomCakeDetailsDialog(index);
                              }

                            },
                            child: Container(
                              padding: EdgeInsets.all(15),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  mainList[index]['Images']==null||
                                  mainList[index]['Images'].toString().isEmpty||
                                  !mainList[index]['Images'].toString().startsWith("http")?
                                  Container(
                                    height: 55,
                                    width: 55,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.grey[300],
                                    ),
                                    child: Icon(
                                      CupertinoIcons.photo,
                                      size: 35,color:Colors.grey,
                                    ),
                                  ):
                                  Container(
                                    height: 55,
                                    width: 55,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.grey[350],
                                      image: DecorationImage(
                                        fit: BoxFit.cover,
                                        image: NetworkImage(mainList[index]['Images'].toString()),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    child: Container(
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            // width: 270,
                                              child:
                                              ((mainList[index]['Status'].toString().toLowerCase()=='delivered')?
                                              Text(
                                                "Hi ${mainList[index]['UserName']} your ${mainList[index]['Title']==null?"Customise cake":mainList[index]['Title']} delivered on "
                                                    "${mainList[index]['Status_Updated_On']} Thank you for purchase.Keep shop and enjoy.",
                                                maxLines: 3,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontFamily: "Poppins",
                                                    fontSize: 13,
                                                ),
                                              ):(mainList[index]['Status'].toString().toLowerCase()=='preparing')?
                                              Text(
                                                "Hi ${mainList[index]['UserName']} your ${mainList[index]['Title']==null?"Customise cake":mainList[index]['Title']} "
                                                    "is being prepared and it will be delivered soon , thank you.",
                                                maxLines: 3,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    color:Colors.black,
                                                    fontFamily: "Poppins",
                                                    fontSize: 13,
                                                ),
                                              ):
                                              (mainList[index]['Status'].toString().toLowerCase()=='new')?
                                              Text(
                                                "Hi ${mainList[index]['UserName']} your ${mainList[index]['Title']==null?"Customise cake":mainList[index]['Title']} "
                                                    "order is placed.We will notify status soon as possible",
                                                maxLines: 3,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    color:Colors.black,
                                                    fontFamily: "Poppins",
                                                    fontSize: 13
                                                ),
                                              ):(mainList[index]['Status'].toString().toLowerCase()=='sent')?
                                              Text(
                                                "Hi ${mainList[index]['UserName']}, kindly check the invoice details for your Custom Cake "
                                                    ", Then continue your payment processes.Thank You.",
                                                maxLines: 3,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    color:Colors.black,
                                                    fontFamily: "Poppins",
                                                    fontSize: 13
                                                ),
                                              ):(mainList[index]['Status'].toString().toLowerCase()=='ordered')?
                                              Text(
                                                "Hi ${mainList[index]['UserName']} your Customised Cake is ordered.We will notify status soon as possible",
                                                maxLines: 3,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    color:Colors.black,
                                                    fontFamily: "Poppins",
                                                    fontSize: 13
                                                ),
                                              ):(mainList[index]['Status'].toString().toLowerCase()=='assigned')?
                                              Text(
                                                "Hi ${mainList[index]['UserName']} Your ${mainList[index]['Title']==null?"Customise cake":mainList[index]['Title']}"
                                                    "is assigned to Vendor ${mainList[index]['VendorName']}",
                                                maxLines: 3,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    color:Colors.black,
                                                    fontFamily: "Poppins",
                                                    fontSize: 13
                                                ),
                                              ):Text(
                                                "Hi ${mainList[index]['UserName']} Your ${mainList[index]['Title']==null?"Customise cake":mainList[index]['Title']}"
                                                    "is order cancelled.",
                                                maxLines: 3,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    color:Colors.black,
                                                    fontFamily: "Poppins",
                                                    fontSize: 13
                                                ),
                                              )
                                              )
                                          ),
                                          SizedBox(
                                            height: 7,
                                          ),
                                          mainList[index]['Status_Updated_On']!=null?
                                          Container(
                                            // width: 270,
                                              child:
                                              // Text(dateTime[index]==result2?'Today':'${dateTime[index]}',
                                              ( mainList[index]['Status_Updated_On'] != null)&&
                                                  dateTime.day.toString().padLeft(2,"0")+"-"+dateTime.month.toString().padLeft(2,"0")+"-"+
                                                      dateTime.year.toString()==mainList[index]['Status_Updated_On'].toString().split(" ").first ?
                                              Text("Today",overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      color: darkBlue,
                                                      fontFamily: "Poppins",
                                                      fontSize: 12.5,
                                                      fontWeight:
                                                      FontWeight.bold
                                                  )):
                                              DateTime.now().day.toString().length==2&&
                                                  DateTime.now().day.toString()==mainList[index]['Status_Updated_On'].toString().split("-").first?
                                              Text("Today",overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      color: darkBlue,
                                                      fontFamily: "Poppins",
                                                      fontSize: 12.5,
                                                      fontWeight:
                                                      FontWeight.bold
                                                  )):
                                              Text("${months[months.indexWhere((element) => element['num']==
                                                  mainList[index]['Status_Updated_On'].toString().split("-")[1])]['mon']} ${mainList[index]['Status_Updated_On'].toString().split('-').first} "
                                                  "${mainList[index]['Status_Updated_On'].toString().replaceAll(" ", "").
                                              split("-").last.substring(0,4)}",
                                                maxLines: 3,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    color: darkBlue,
                                                    fontFamily: "Poppins",
                                                    fontSize: 12.5,
                                                    fontWeight:
                                                    FontWeight.bold
                                                ),
                                              )
                                          ):
                                          Container(
                                            // width: 270,
                                              child:
                                              // Text(dateTime[index]==result2?'Today':'${dateTime[index]}',
                                              ( mainList[index]['Created_On'] != null)&&
                                                  dateTime.day.toString().padLeft(2,"0")+"-"+dateTime.month.toString().padLeft(2,"0")+"-"+
                                                      dateTime.year.toString()==mainList[index]['Created_On'].toString().split(" ").first ?
                                              Text("Today",overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      color: darkBlue,
                                                      fontFamily: "Poppins",
                                                      fontSize: 12.5,
                                                      fontWeight:
                                                      FontWeight.bold
                                                  )):
                                              DateTime.now().day.toString().length==2&&
                                                  DateTime.now().day.toString()==mainList[index]['Created_On'].toString().split("-").first?
                                              Text("Today",overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      color: darkBlue,
                                                      fontFamily: "Poppins",
                                                      fontSize: 12.5,
                                                      fontWeight:
                                                      FontWeight.bold
                                                  )):
                                               Text("${months[months.indexWhere((element) => element['num']==
                                                    mainList[index]['Created_On'].toString().split("-")[1])]['mon']} ${mainList[index]['Created_On'].toString().split('-').first} "
                                                    "${mainList[index]['Created_On'].toString().replaceAll(" ", "").
                                                split("-").last.substring(0,4)}",
                                                maxLines: 3,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    color: darkBlue,
                                                    fontFamily: "Poppins",
                                                    fontSize: 12.5,
                                                    fontWeight:
                                                    FontWeight.bold
                                                ),
                                              )
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        })
                        : Container(
                            margin: EdgeInsets.only(top:25),
                            child: Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.notifications_active_outlined,size: 35,),
                                Text(' No Notifications!',style: TextStyle(
                                    color: lightPink,fontFamily: "Poppins",
                                    fontSize: 18,fontWeight: FontWeight.bold
                                ),),
                              ],
                            )
                      ),
                    )
                )
            ),),
    );
  }
}

String simplyFormat({required DateTime time, bool dateOnly = false}) {
  List months = [
    {"month": 'Jan', "number": 1},
    {"month": 'Feb', "number": 2},
    {"month": 'Mar', "number": 3},
    {"month": 'Apr', "number": 4},
    {"month": 'May', "number": 5},
    {"month": 'Jun', "number": 6},
    {"month": 'Jul', "number": 7},
    {"month": 'Aug', "number": 8},
    {"month": 'Sep', "number": 9},
    {"month": 'Oct', "number": 10},
    {"month": 'Nav', "number": 11},
    {"month": 'Dec', "number": 12},
  ];

  String year = time.year.toString();

  // Add "0" on the left if month is from 1 to 9
  String month = time.month.toString().padLeft(2, '0');

  // Add "0" on the left if day is from 1 to 9
  String day = time.day.toString().padLeft(2, '0');

  // Add "0" on the left if hour is from 1 to 9
  String hour = time.hour.toString().padLeft(2, '0');

  // Add "0" on the left if minute is from 1 to 9
  String minute = time.minute.toString().padLeft(2, '0');

  // Add "0" on the left if second is from 1 to 9
  String second = time.second.toString();

  // return the "yyyy-MM-dd HH:mm:ss" format
  if (dateOnly == false) {
    return "$day-$month-$year $hour:$minute:$second";
  }

  List mon =
  months.where((element) => element['number'] == int.parse(month)).toList();

  print(mon);

  // If you only want year, month, and date
  return "${mon[0]['month']} ${day}nd $year";
}

String hourFormater(String time) {
  int h = int.parse(time
      .split(":")
      .first);
  int m = int.parse(time
      .split(":")
      .last
      .split(" ")
      .first);
  String send = "";
  if (h > 12) {
    var temp = h - 12;
    send =
        "0$temp:${m
            .toString()
            .length == 1 ? "0" + m.toString() : m.toString()} " +
            "PM";
  } else {
    send =
        "$h:${m
            .toString()
            .length == 1 ? "0" + m.toString() : m.toString()}  " +
            "AM";
  }

  return send;
}