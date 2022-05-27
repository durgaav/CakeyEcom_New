import 'dart:async';
import 'dart:convert';
import 'package:cakey/screens/CheckOut.dart';
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

  DateTime currentTime = DateTime.now();
  var result2 = '';
  // var dateTime = ["Mar 4th 2022","Mar 2nd 2022","Mar 1st 2022","May 2nd 2022","May 14th 2022","May 24th 2022","May 24th 2022"];
  int i = 0;

  // String data = 'new';
  List OrderList = [];
  List CustomizeList = [];
  List MainList=[];
  List ImageList=[];
  var fixedFlavList = [];

  String cakeId='';
  String userId='';

  int pageViewCurIndex = 0;

  String authToken = "";

  Future<void> notifyData() async {
    MainList.clear();
    try {
      var res = await http.get(Uri.parse(
          "https://cakey-database.vercel.app/api/users/notification/$userId"),headers: {"Authorization":"$authToken"});
      print(res.statusCode);
      if (res.statusCode == 200) {
        setState(() {
          List a = jsonDecode(res.body)['CustomizeCakesList'];
          List b = jsonDecode(res.body)['OrdersList'];

          MainList = a.where((element) => element['Notification'].toString().toLowerCase()!='new').toList()+ b.toList();
          print(MainList);
          print(MainList.length);
        });
      }
    } catch (e) {
      print(e);
      print('list data not be accepted');
      print(userId);
    }
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

  Future<void> PriceInfo(index) async{
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title:  Text(MainList[index]['_id'],style: TextStyle(fontFamily: "Poppins")),
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
                  Text(MainList[index]['DeliveryDate'],style: TextStyle(fontFamily: "Poppins",fontSize: 12),),
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
                  Text(MainList[index]['DeliverySession'],style: TextStyle(fontFamily: "Poppins",fontSize: 12),),
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
                  Text(MainList[index]['DeliveryDate'],style: TextStyle(fontFamily: "Poppins",fontSize: 12),),
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
                  Text(MainList[index]['Weight'],style: TextStyle(fontFamily: "Poppins",fontSize: 12),),
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
                  (MainList[index]['Price']==null)?Text('NAN'):Text('Rs. '+ MainList[index]['Price'],style: TextStyle(fontFamily: "Poppins",fontSize: 12),),

                  // Text('Rs. '+ MainList[index]['Price'],style: TextStyle(fontFamily: "Poppins",fontSize: 12),),
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
                  (MainList[index]['ExtraCharges']==null)?Text('NAN'):Text('Rs. '+ MainList[index]['ExtraCharges'],style: TextStyle(fontFamily: "Poppins",fontSize: 12),),

                  // Text('Rs. '+ MainList[index]['ExtraCharges'],style: TextStyle(fontFamily: "Poppins",fontSize: 12),),
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
                  (MainList[index]['Gst']==null)?Text('NAN'):Text('Rs. '+ MainList[index]['Gst'],style: TextStyle(fontFamily: "Poppins",fontSize: 12),),

                  // Text('Rs. '+ MainList[index]['Gst'],style: TextStyle(fontFamily: "Poppins",fontSize: 12),),
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
                  (MainList[index]['Sgst']== null)?Text('NAN'):Text('Rs. '+ MainList[index]['Sgst'],style: TextStyle(fontFamily: "Poppins",fontSize: 12),),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Extra Charges',style: TextStyle(fontFamily: "Poppins",fontSize: 12,fontWeight: FontWeight.bold),),
                  Text('-',style: TextStyle(fontFamily: "Poppins"),),
                  Text('Rs. '+ MainList[index]['ExtraCharges'],style: TextStyle(fontFamily: "Poppins",fontSize: 12),),
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
                  (MainList[index]['Total']== null)?Text('NAN'):Text('Rs. '+ MainList[index]['Total'],style: TextStyle(fontFamily: "Poppins",fontSize: 12),),

                  // Text('Rs. '+ MainList[index]['Total'],style: TextStyle(fontFamily: "Poppins",fontSize: 12),),
                ],
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: (){
              print('move data to next screen');
              // sendDetailstoScreen(index);
            },
            child: const Text('PAY NOW'),
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
          height: MediaQuery.of(context).size.height*0.34,
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
                  Text(MainList[index]['DeliveryDate'],style: TextStyle(fontFamily: "Poppins",fontSize: 12),),
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
                  Text(MainList[index]['DeliverySession'],style: TextStyle(fontFamily: "Poppins",fontSize: 12),),
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
                  Text(MainList[index]['DeliveryInformation'],style: TextStyle(fontFamily: "Poppins",fontSize: 12),),
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
                  Text(MainList[index]['Status'],style: TextStyle(fontFamily: "Poppins",fontSize: 12),),
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
                  Text(MainList[index]['Weight'],style: TextStyle(fontFamily: "Poppins",fontSize: 12),),
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
          height: MediaQuery.of(context).size.height*0.4,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.only(bottom: 10),
                child: Center(
                    child: (MainList[index]['Images']!=null)?CircleAvatar(
                        radius: 50,
                        backgroundImage:
                        NetworkImage(MainList[index]['Images'].toString())
                    )
                        :CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.blue,
                    )
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Delivery Date',style: TextStyle(fontFamily: "Poppins",fontSize: 12,fontWeight: FontWeight.bold),),
                  Text('-',style: TextStyle(fontFamily: "Poppins"),),
                  Text(MainList[index]['DeliveryDate'],style: TextStyle(fontFamily: "Poppins",fontSize: 12),),
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
                  Text(MainList[index]['DeliverySession'],style: TextStyle(fontFamily: "Poppins",fontSize: 12),),
                ],
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Delivery Mode',style: TextStyle(fontFamily: "Poppins",fontSize: 12,fontWeight: FontWeight.bold),),
                  Text('-',style: TextStyle(fontFamily: "Poppins"),),
                  Text(MainList[index]['DeliveryInformation'],style: TextStyle(fontFamily: "Poppins",fontSize: 12),),
                ],
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Status',style: TextStyle(fontFamily: "Poppins",fontSize: 12,fontWeight: FontWeight.bold),),
                  Text('-',style: TextStyle(fontFamily: "Poppins"),),
                  Text(MainList[index]['Status'],style: TextStyle(fontFamily: "Poppins",fontSize: 12),),
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
                  Text(MainList[index]['Weight'],style: TextStyle(fontFamily: "Poppins",fontSize: 12),),
                ],
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Payment Type',style: TextStyle(fontFamily: "Poppins",fontSize: 12,fontWeight: FontWeight.bold),),
                  Text('-',style: TextStyle(fontFamily: "Poppins"),),
                  Text(MainList[index]['PaymentType'],style: TextStyle(fontFamily: "Poppins",fontSize: 12),),
                ],
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total Price',style: TextStyle(fontFamily: "Poppins",fontSize: 12,fontWeight: FontWeight.bold),),
                  Text('-',style: TextStyle(fontFamily: "Poppins"),),
                  Text('Rs. '+ MainList[index]['Total'],style: TextStyle(fontFamily: "Poppins",fontSize: 12),),
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
      prefs.setString('orderCakeModID', MainList[index]['Id'].toString());
      prefs.setString('orderCakeName', 'My Customized Cake');
      // prefs.setString('orderCakeDescription', cakeDescription);
      prefs.setString(
          'orderCakeType', MainList[index]['TypeOfCake'].toString()
      );
      // prefs.setString('orderCakeImages', ImageList[0].toString());
      prefs.setString(
          'orderCakeEggOrEggless', MainList[index]['EggOrEggless'].toString()
      );
      prefs.setString('orderCakePrice',MainList[index]['Price']);

      // prefs.setString('orderCakeFlavour',MainList[index]['EggOrEggless'].split("-").first.toString());

      prefs.setString('orderCakeShape',MainList[index]['Shape'].toString());
      prefs.setString('orderCakeWeight',MainList[index]['Weight'].toString());

      if(MainList[index]['MessageOnTheCake'].toString().isNotEmpty){
        prefs.setString('orderCakeMessage',MainList[index]['MessageOnTheCake'].toString());
      }else{
        prefs.setString('orderCakeMessage','No message');
      }

      if(MainList[index]['SpecialRequest'].toString().isNotEmpty){
        prefs.setString('orderCakeRequest',MainList[index]['SpecialRequest'].toString());
      }else{
        prefs.setString('orderCakeRequest','No special requests');
      }


      // prefs.setString('orderCakeWeight', MainList[index]['Weight'].toString());

      //vendor..
      prefs.setString('orderCakeVendorId', MainList[index]['VendorID'].toString());
      prefs.setString('orderCakeVendorModId', MainList[index]['Vendor_ID '].toString());
      prefs.setString('orderCakeVendorName', MainList[index]['VendorName'].toString());
      prefs.setString('orderCakeVendorNum', MainList[index]['VendorPhoneNumber'].toString());
      prefs.setString('orderCakeVendorAddress', MainList[index]['VendorAddress'].toString());

      //user...
      prefs.setString('orderCakeUserName', MainList[index]['UserName'].toString());
      prefs.setString('orderCakeUserID', MainList[index]['UserID'].toString());
      prefs.setString('userModId', MainList[index]['User_ID'].toString());
      prefs.setString('orderCakeUserNum', MainList[index]['UserPhoneNumber'].toString());
      prefs.setString('orderCakeDeliverAddress', MainList[index]['DeliveryAddress'].toString());
      prefs.setString('orderCakeDeliverDate', MainList[index]['DeliveryDate'].toString());
      prefs.setString('orderCakeDeliverSession', MainList[index]['DeliverySession'].toString());
      prefs.setString('orderCakeDeliveryInformation', MainList[index]['DeliveryInformation'].toString());

      // prefs.setString('orderCakeArticle',fixedArticle);


      //for delivery...
      prefs.setInt('orderCakeItemCount', 1);
      // prefs.setInt('orderCakePrice', int.parse(MainList[index]['Price'].toString()));
      prefs.setInt('orderCakeTotalAmt', int.parse(MainList[index]['Total'].toString()));
      prefs.setString('orderCakePaymentExtra', MainList[index]['ExtraCharges'].toString());
      // prefs.setInt('orderCakeDeliverAmt',fixedDelliverMethod=="Pickup"?0:50);
      prefs.setInt('orderCakeDiscount', MainList[index]['Discount']);
      prefs.setInt('orderCakeTaxes',int.parse(MainList[index]['Sgst'])+int.parse(MainList[index]['Sgst']));
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

    print(int.parse(MainList[index]['Sgst'])+int.parse(MainList[index]['Sgst']));

    // prefs.setString('orderCakeVendorNum', MainList[index]['VendorPhoneNumber'].toString());

    Navigator.push(context, MaterialPageRoute(builder: (context)=> CheckOut(
        MainList[index]['Flavour'].toList(),
        [
          {
            "Name": MainList[index]['Article']['Name'].toString(),
            "Price": MainList[index]['Article']['Price'].toString(),
          }
        ]
    ),));


  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration.zero, () async {
      var prefs = await SharedPreferences.getInstance();
      userId = prefs.getString('userID').toString();
      authToken = prefs.getString('authToken').toString();
      // print('user id.....   $userId');
      notifyData();
      // updateStatus();
    });
    // Full date and time
    final result1 = simplyFormat(time: currentTime);
    print(result1);

    Timer(Duration(seconds: 5), () async {
      setState(() {
        i = 1;
      });
    });

    // Date only
  }

  @override
  Widget build(BuildContext context) {
    result2 = simplyFormat(time: currentTime, dateOnly: true);
    print(result2);
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: Container(
            color: lightGrey,
            padding: EdgeInsets.only(left: 15, top: 25, right: 10),
            child: Row(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 15),
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
        ),

        body: RefreshIndicator(
          onRefresh: () async {
            setState(() {
              notifyData();
            });
          },
          child: SingleChildScrollView(
              child: Container(
                  child: i == 0
                      ? ListView.builder(
                      itemCount: 10,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (count, index) {
                        return Shimmer.fromColors(
                          baseColor: Colors.grey,
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
                                    color: Colors.grey,
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
                                          // width: 120,
                                          height: 20,
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
                      : (MainList.length != 0)
                      ? ListView.builder(
                      itemCount: MainList.length,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: (){
                            print(MainList[index]['Notification']);
                            if(MainList[index]['Notification']!=null) {
                              if (MainList[index]['Notification'] == 'seen') {
                                setState(() {
                                  CustomListPopup(index);
                                  // print(ImageList);
                                });
                              }else  if(MainList[index]['Notification']=='unseen'){
                                setState(() {
                                  PriceInfo(index);
                                  cakeId = MainList[index]['_id'];
                                  print(cakeId);
                                  // print(ImageList);
                                  updateStatus(index);
                                });
                              }
                            }else {
                              setState(() {
                                // mainIndex = MainList;
                                // if(mainIndex[index] == MainList[index]){
                                OrderListPopup(index);
                                // viewstate = true;
                                // print(mainIndex);
                                // print(index);
                                // print(viewstate);
                                // }
                              });
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.all(15),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 55,
                                  width: 55,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.grey,
                                  ),
                                  child: Icon(
                                    Icons.notifications_none,
                                    size: 45,color: Colors.black87,
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
                                            ((MainList[index]['Notification']=='unseen')?Text(
                                              'Hi ' + MainList[index]['UserName'] + " your Chocolate cake's Price and more info"
                                                  " has been sended by admin kindly check "
                                                  'and pay your bill.',
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontFamily: "Poppins",
                                                  fontSize: 13,fontWeight: FontWeight.bold),
                                            ):(MainList[index]['Notification']=='seen')?
                                            Text(
                                              'Hi ' + MainList[index]['UserName'] + ' your Customized Chocolate layer cake Order has been placed successfully.',
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  color:Colors.black38,
                                                  fontFamily: "Poppins",
                                                  fontSize: 13,fontWeight: FontWeight.bold),
                                            ):
                                            (MainList[index]['Notification'] == null)?Text(
                                              'Hi '+ MainList[index]['UserName']  + ' your Order chocolate cake order has been placed successfully.',
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                // color:(viewstate==false)?Colors.black:Colors.black45,
                                                  color:Colors.black,
                                                  fontFamily: "Poppins",
                                                  fontSize: 13,fontWeight: FontWeight.bold),
                                            ):Text('durgadevi')
                                            )
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Container(
                                          // width: 270,
                                          child:
                                          // Text(dateTime[index]==result2?'Today':'${dateTime[index]}',
                                          Text(
                                            MainList[index]
                                            ['Created_On'],
                                            maxLines: 3,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                color: darkBlue,
                                                fontFamily: "Poppins",
                                                fontSize: 14,
                                                fontWeight:
                                                FontWeight.bold),
                                          ),
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
                      : Container(
                    margin: EdgeInsets.only(top:10),
                    child: Center(
                      child: Text('Loading Please wait....'),
                    ),
                  ))),
        ));
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



