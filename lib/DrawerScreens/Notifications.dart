import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cakey/MyDialogs.dart';
import 'package:cakey/Notification/Notification.dart';
import 'package:cakey/main.dart';
import 'package:cakey/screens/CheckOut.dart';
import 'package:cakey/screens/Profile.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import '../ContextData.dart';
import '../Dialogs.dart';
import '../OtherProducts/OtherDetails.dart';
import '../screens/OrderConfirm.dart';

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
  DateTime currentTime = DateTime.now();

  var result2 = '';
  int i = 0;

  var tempData = {};
  String customPaymentType = "";

  // String data = 'new';
  List OrderList = [];
  List CustomizeList = [];
  List mainList=[];
  List ImageList=[];
  var fixedFlavList = [];
  List ordersList = [];
  String cakeId='';
  String userId='';

  //on list longpres
  List<bool> selectedTiles = [];
  List selectedNotiIds = [];

  int pageViewCurIndex = 0;

  String authToken = "";
  bool isLoading = true;

  var publicTax = 0;

  var _razorpay = Razorpay();

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
                          Text(status=="done"?'Your payment was successful.'
                              :"Your payment  was unsuccessful.",style: TextStyle(
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

  //ticket dialog
  void showTicketDialog(var data) {
    showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            title: Text("Message",style: TextStyle(
                fontFamily: "Poppins"
            ),),
            content:Text("${data['For_Display']}",style: TextStyle(
                fontFamily: "Poppins"
            ),),
            actions: [
              Column(
                children: [
                  TextButton(onPressed: (){Navigator.pop(context);}, child: Text("CLOSE")),
                  TextButton(onPressed: (){
                    Navigator.pop(context);
                    updateTheTickets(data, "disagree");
                  }, child: Text("DISAGREE")),
                  TextButton(onPressed: (){
                    Navigator.pop(context);
                    showOkOrNotDialog(data);
                  }, child: Text("AGREE")),
                ],
              )
            ],
          );
        }
    );
  }

  //custom cake invoice details
  void showCustomCakeInvoices(String orderId , var data) {

    print("Entered...");

    print(orderId);
    List myList = ordersList.where((element) => element['_id']==orderId).toList();

    var selectedIndex = 0;
    List item = ["Cash on delivery","Online payment"];

    String cancelReason = "No reason";

    print(myList);

    showDialog(
        context: context,
        builder: (c){
          return StatefulBuilder(
            builder: (cc,setState){
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius:BorderRadius.circular(15),
                ),
                contentPadding: EdgeInsets.all(8),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Text("INVOICE DETAILS",style: TextStyle(
                                fontFamily: "Poppins",
                                fontWeight: FontWeight.bold,
                                fontSize: 16
                            ),),
                            Expanded(child:GestureDetector(
                              onTap: (){
                                Navigator.pop(context);
                              },
                              child: Container(
                                  alignment: Alignment.centerRight,
                                  child:Icon(Icons.cancel,color: Colors.red,)
                              ),
                            ))
                          ],
                        ),
                      ),
                      SizedBox(height: 8,),
                      Container(
                        width:MediaQuery.of(context).size.width,
                        margin: EdgeInsets.symmetric(vertical: 8,horizontal: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Price per KG",style: TextStyle(
                              fontFamily: "Poppins",
                            ),),
                            Text("Rs.${double.parse(myList[0]['Price'].toString()).toStringAsFixed(2)}",style: TextStyle(
                              fontFamily: "Poppins",
                            ),),
                          ],
                        ),
                      ),
                      Container(
                        width:MediaQuery.of(context).size.width,
                        margin: EdgeInsets.symmetric(vertical: 8,horizontal: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Weight",style: TextStyle(
                              fontFamily: "Poppins",
                            ),),
                            Text("${myList[0]['Weight'].toString()}",style: TextStyle(
                              fontFamily: "Poppins",
                            ),),
                          ],
                        ),
                      ),Container(
                        width:MediaQuery.of(context).size.width,
                        margin: EdgeInsets.symmetric(vertical: 8,horizontal: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("GST",style: TextStyle(
                              fontFamily: "Poppins",
                            ),),
                            Text("Rs.${double.parse(myList[0]['Gst'].toString()).toStringAsFixed(2)}",style: TextStyle(
                              fontFamily: "Poppins",
                            ),),
                          ],
                        ),
                      ),
                      Container(
                        width:MediaQuery.of(context).size.width,
                        margin: EdgeInsets.symmetric(vertical: 8,horizontal: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("SGST",style: TextStyle(
                              fontFamily: "Poppins",
                            ),),
                            Text("Rs.${double.parse(myList[0]['Sgst'].toString()).toStringAsFixed(2)}",style: TextStyle(
                              fontFamily: "Poppins",
                            ),),
                          ],
                        ),
                      ),
                      Container(
                        width:MediaQuery.of(context).size.width,
                        margin: EdgeInsets.symmetric(vertical: 8,horizontal: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Extra Charge",style: TextStyle(
                              fontFamily: "Poppins",
                            ),),
                            Text("Rs.${double.parse(myList[0]['ExtraCharges'].toString()).toStringAsFixed(2)}",style: TextStyle(
                              fontFamily: "Poppins",
                            ),),
                          ],
                        ),
                      ),
                      Container(
                        width:MediaQuery.of(context).size.width,
                        margin: EdgeInsets.symmetric(vertical: 8,horizontal: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Delivery Charge",style: TextStyle(
                              fontFamily: "Poppins",
                            ),),
                            Text("Rs.${double.parse(myList[0]['DeliveryCharge'].toString()).toStringAsFixed(2)}",style: TextStyle(
                              fontFamily: "Poppins",
                            ),),
                          ],
                        ),
                      ),
                      Container(
                        width:MediaQuery.of(context).size.width,
                        margin: EdgeInsets.symmetric(vertical: 8,horizontal: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Discount",style: TextStyle(
                              fontFamily: "Poppins",
                            ),),
                            Text("Rs.${double.parse(myList[0]['Discount'].toString()).toStringAsFixed(2)}",style: TextStyle(
                              fontFamily: "Poppins",
                            ),),
                          ],
                        ),
                      ),
                      Container(
                        width:MediaQuery.of(context).size.width,
                        margin: EdgeInsets.symmetric(vertical: 8,horizontal: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Total",style: TextStyle(
                                fontFamily: "Poppins",
                                fontWeight: FontWeight.bold
                            ),),
                            Text("Rs.${double.parse(myList[0]['Total'].toString()).toStringAsFixed(2)}",style: TextStyle(
                                fontFamily: "Poppins",
                                fontWeight: FontWeight.bold
                            ),),
                          ],
                        ),
                      ),
                      Container(
                        width:MediaQuery.of(context).size.width,
                        margin: EdgeInsets.symmetric(vertical: 8,horizontal: 8),
                        child:Column(
                          children:item.map((e){
                            return GestureDetector(
                              onTap:(){
                                setState((){
                                  selectedIndex=item.indexWhere((ele)=>ele==e);
                                });
                              },
                              child: Container(
                                padding:EdgeInsets.all(5),
                                child: Row(
                                  children: [
                                    selectedIndex==item.indexWhere((ele)=>ele==e)?
                                    Icon(Icons.check_circle , color: Colors.green,):
                                    Icon(Icons.radio_button_off , color: Colors.green,),
                                    SizedBox(width:5),
                                    Text(e),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        )
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                      onPressed: (){
                        Navigator.pop(context);
                        showEditTextDialog(data , item[selectedIndex]);
                      },
                      child: Text("CANCEL ORDER")
                  ),
                  // TextButton(
                  //     onPressed: (){
                  //       Navigator.pop(context);
                  //     },
                  //     child: Text("CANCEL")
                  // ),
                  TextButton(
                      onPressed: (){
                        Navigator.pop(context);
                        if(item[selectedIndex].toString().toLowerCase()=="cash on delivery"){
                          customPaymentType = item[selectedIndex];
                          MyDialogs().showConfirmDialog(context, "Do you want to proceed?", (){}, ()=>handleCustomiseCakeUpdate(data, item[selectedIndex], "agree",""));
                        }else{
                          makeOrderId(data, double.parse(myList[0]['Total'].toString()).toStringAsFixed(2));
                        }
                      },
                      child: Text("PROCEED")
                  ),
                ],
              );
            },
          );
        }
    );
  }

  //custom cake order cancel reason
  void showEditTextDialog(var data , String paymetType) {

    String reason = "";

    showDialog(
      context: context,
      builder:(context){
        return StatefulBuilder(builder: (c , setState){
          return AlertDialog(
            content: TextField(
              onChanged: (e){
                setState((){
                  reason = e.toString();
                });
              },
              decoration: InputDecoration(
                hintText: "Enter the reason for the cancellation",
                border: OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(
              onPressed: (){
                Navigator.pop(context);
                if(reason==""){
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please enter the reason for cancellation.")));
                }else{
                  MyDialogs().showConfirmDialog(context, "Do you want to proceed?", (){}, ()=>handleCustomiseCakeUpdate(data, paymetType, "disagree",reason));
                }
              },
              child: Text("SUBMIT")
              ),
            ],
          );
        });
      }
    );


  }

  //Show normal cake order Details View
  void showOrderDetailsDialog(int index){

    //mins calculate

    print(mainList[index]['Created_On'].toString());

    int year = int.parse(mainList[index]['Created_On'].toString().split(" ")
        .first.split("-").last);
    int month = int.parse(mainList[index]['Created_On'].toString().split(" ")
        .first.split("-")[1]);
    int day = int.parse(mainList[index]['Created_On'].toString().split(" ")
        .first.split("-").first);
    int hour = int.parse(mainList[index]['Created_On'].toString().split(" ")[1]
        .split("")[1].split(":").first);
    int min = int.parse(mainList[index]['Created_On'].toString().split(" ")
    [1].split(":").last);

    DateTime a = DateTime(year,month,day,hour,min);

    print("a $a");

    DateTime b = DateTime.now();

    Duration difference = b.difference(a);

    print(difference);

    int days = difference.inDays;
    int hours = difference.inHours % 24;
    int minutes = difference.inMinutes % 60;
    int seconds = difference.inSeconds % 60;

    print("$days day(s) $hours hour(s) $minutes minute(s) $seconds second(s).");

    print("min : $minutes");

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
                        child:mainList[i]['Image'].toString().isNotEmpty?
                         Container(
                         ):
                         Container()
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
                            mainList[index]['CakeName']!=null?
                              Text(mainList[index]['CakeName'].toString() , style:TextStyle(
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
                                  'Rs.${mainList[index]['Total'].toString().characters.take(5)}', style:TextStyle(
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
                                  child: Text(mainList[index]['CakeType']==null?'N/A':
                                  '${mainList[index]['CakeType']}', style:TextStyle(
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

  void NoVendor(){
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No phone number Found"))
    );
  }

  Future<void> getOrdersList() async{
    //http://sugitechnologies.com/cakey/api/customize/cake/listbyuserid
    try{
      var headers = {
        'Authorization': '$authToken'
      };
      var request = http.Request('GET',
          Uri.parse('http://sugitechnologies.com/cakey//api/customize/cake/listbyuserid/$userId'));

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        List map = jsonDecode(await response.stream.bytesToString());

        setState((){
          if(map[0]['message']=="No Orders"){

          }else{
            ordersList = map;
          }

          print(ordersList);

        });
      }
      else {
        print(response.reasonPhrase);
      }
    }catch(e){

    }

  }

  //show custom cake order view
  void showCustomCakeDetailsDialog(String orderId){

    print("Entered...");

    print(orderId);

    List myList = ordersList.where((element) => element['_id']==orderId).toList();

    print(myList[0]["Status"]);

    var opac = 1.0;
    var timer = new Timer(Duration(seconds: 2), () {setState((){opac = 1.0;});});
    timer;

    print(myList);

      myList.isNotEmpty&&myList[0]['Status'].toString().toLowerCase()=='price approved'?
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
                        SizedBox(height: 10,),
                        //cake ID
                        Text(myList[0]['Id'].toString() , style:TextStyle(
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
                                myList[0]['CakeName']!=null?
                                Text(myList[0]['CakeName'].toString() , style:TextStyle(
                                    fontFamily: "Poppins",color: lightPink,fontWeight: FontWeight.bold
                                ),):
                                Text("Customize Cake "+myList[0]['Id'] , style:TextStyle(
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
                                      child: Text(myList[0]['Total']==null?'N/A':
                                      'Rs.${
                                      (double.parse(myList[0]['Total'].toString())-double.parse(myList[0]['Gst'].toString())-
                                          double.parse(myList[0]['Sgst'].toString())+double.parse(myList[0]['Discount'].toString())).toStringAsFixed(2)
                                      }', style:TextStyle(
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
                                      child: Text(myList[0]['CakeType']==null?'N/A':
                                      '${myList[0]['CakeType']}', style:TextStyle(
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
                                      child: Text(myList[0]['Created_On']==null?'N/A':
                                      '${myList[0]['Created_On']}', style:TextStyle(
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
                                      child: Text(myList[0]['DeliveryDate']==null?'N/A':
                                      '${myList[0]['DeliveryDate']}', style:TextStyle(
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
                                      child: Text(myList[0]['Status']==null?'N/A':
                                      'Sent', style:TextStyle(
                                          fontFamily: "Poppins",
                                          color:myList[0]['Status'].toString().toLowerCase()=="new"?
                                          Colors.red:
                                          myList[0]['Status'].toString().toLowerCase()=="preparing"?
                                          Colors.blue:
                                          myList[0]['Status'].toString().toLowerCase()=="delivered"?
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
                                      child: Text(myList[0]['DeliveryAddress']==null?'N/A':
                                      '${myList[0]['DeliveryAddress']}', textAlign: TextAlign.end,style:TextStyle(
                                          fontFamily: "Poppins",
                                          color:darkBlue,
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
                              myList[0]['Status'].toString().toLowerCase()=="sent"?
                              Expanded(child:
                              Container(
                                margin: EdgeInsets.all(5),
                                child: RaisedButton(
                                  onPressed: (){
                                    sendDetailstoScreen(myList);
                                  },
                                  child: Text('PAY NOW' , style: TextStyle(
                                      color: Colors.white, fontWeight: FontWeight.bold, fontFamily: "Poppins"
                                  ),),
                                  color: darkBlue,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(13)
                                  ),
                                ),
                              )
                              ):Container(),
                              Expanded(child:Container(
                                margin: EdgeInsets.all(5),
                                child: RaisedButton(
                                  onPressed: (){
                                    myList[0]['VendorPhoneNumber1']!=null?
                                    PhoneDialog().showPhoneDialog(
                                        context,
                                        myList[0]['VendorPhoneNumber1'].toString(),
                                        myList[0]['VendorPhoneNumber2'].toString()
                                    ):NoVendor();
                                  },
                                  child: Text('CONTACT VENDOR' , style: TextStyle(
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
      ):null;


  }

  void showOrderDeleteAllDialog(){
    showDialog(
        context: context,
        builder: (context)=>
            AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)
              ),
              title: Text("Delete Notifications!" , style: TextStyle(
                  color: darkBlue , fontFamily: "Poppins",
                  fontWeight: FontWeight.bold
              ),),
              content:Text(
                  "Are you sure? do you want to delete all notifications?", style: TextStyle(
                color: Colors.black , fontFamily: "Poppins",
              )
              ),
              actions: [
                FlatButton(
                  onPressed: ()=>Navigator.pop(context),
                  child: Text('Cancel', style: TextStyle(
                    color: Colors.purple , fontFamily: "Poppins",
                  )),
                ),
                FlatButton(
                  onPressed: (){
                    Navigator.pop(context);
                    deleteAllNotifications();
                  },
                  child: Text('Delete All', style: TextStyle(
                    color: Colors.purple , fontFamily: "Poppins",
                  )),
                ),

              ],
            )
    );
  }

  //region Functions

  Future<void> sendDetailstoScreen(List myList) async{

    print(myList[0]['Flavour']);

    var prefs = await SharedPreferences.getInstance();

    prefs.setString('orderFromCustom', "yes");
    prefs.setString('customCakeName', myList[0]['CakeName'].toString());
    prefs.setString('customCakePrice', myList[0]['Price'].toString());
    prefs.setString('customCakeShape', myList[0]['Shape'].toString());
    prefs.setString('customCakeVendor', myList[0]['VendorName'].toString());
    prefs.setString('customCakeType', myList[0]['CakeType'].toString());
    prefs.setString('customCakeUserAdd', myList[0]['DeliveryAddress'].toString());
    prefs.setString('customCakeVenPhn1', myList[0]['VendorPhoneNumber1'].toString());
    prefs.setString('customCakeVenPhn2', myList[0]['VendorPhoneNumber2'].toString());
    prefs.setString('customCakeVenModId', myList[0]['Vendor_ID'].toString());
    prefs.setString('customCakeVenId', myList[0]['VendorID'].toString());
    prefs.setString('customCakeVenAddrss', myList[0]['VendorAddress'].toString());
    prefs.setString('customCakeExtra', myList[0]['ExtraCharges'].toString());
    prefs.setString('customCakeGst', myList[0]['Gst'].toString());
    prefs.setString('customCakeSgst', myList[0]['Sgst'].toString());
    prefs.setString('customCakeTotal', myList[0]['Total'].toString());
    //prefs.setInt('customCakeTaxes', int.parse(myList[0]['Tax']));
    prefs.setString('customCakeDisc', myList[0]['Discount'].toString());
    prefs.setString('customCakeWeight', myList[0]['Weight'].toString());
    prefs.setString('customCakeId', myList[0]['_id'].toString());
    prefs.setString('customCakeVendLat', myList[0]['GoogleLocation']['Latitude'].toString().toString());
    prefs.setString('customCakeVendLong', myList[0]['GoogleLocation']['Longitude'].toString().toString());
    prefs.setString('customCakePickOrDel', myList[0]['DeliveryInformation'].toString().toString());


    print( myList[0]['Discount'].toString());
    print( myList[0]['ExtraCharges'].toString());
    print( myList[0]['Price'].toString());
    print( myList[0]['Gst'].toString());
    print( myList[0]['Sgst'].toString());
    print( myList[0]['Total'].toString());
    print( myList[0]['Weight'].toString());


    Navigator.push(
        context,
        MaterialPageRoute(builder: (context)=> CheckOut([],myList[0]['Flavour']))
    );

    print('Loaded....');

  }

  //get taxes
  Future<void> fetchTax() async{

    var pref = await SharedPreferences.getInstance();

    var auth = pref.getString("authToken")??'';

    //prefs.setDouble('orderCakeGst', gst);
    //prefs.setDouble('orderCakeSGst', sgst);
    //prefs.setInt('orderCakeTaxperc', taxes??0);

    try{
      var headers = {
        'Authorization': '$auth'
      };
      var request = http.Request('GET', Uri.parse('http://sugitechnologies.com/cakey/api/tax/list'));

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        List map = jsonDecode(await response.stream.bytesToString());
        print(map);
        setState(() {
          if(map[0]['Total_GST']!=null){
            publicTax = int.parse(map[0]['Total_GST'].toString());
          }
        });
      }
      else {
        print(response.reasonPhrase);
      }
    }catch(e){

    }

  }

  //create the order id
  Future<void> makeOrderId(var data , var amt) async{
    showAlertDialog();
    tempData = data;
    try{

      var amount = amt.toString();

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

    }catch(e){
      print(e);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Payment Failed")));
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
      'description': '',
      'timeout': 300, // in seconds
      'prefill': {
        'contact': '',
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

  //update tickets..
  Future<void> updateTheTickets(var data , String type) async{

    print(data);

    showAlertDialog();

    var shape = {};
    var flavour = [];

    if(data['Shape']!=null){
      shape = data['Shape'];
    }

    if(data['Flavour']!=null){
      flavour = data['Flavour'];
    }

    var theData = {
      "TicketID": data['TicketID'],
      "Change_Request_Price": data['Difference_In_Price'],
      "Change_Request_Payment_Status":data['PaymentType'].toString().toLowerCase()=="cash on delivery"?"Pending":"Paid",
      "Customer_Approved_Status": "Approved",
      "Customer_Paid_Status":data['PaymentType'].toString().toLowerCase()=="cash on delivery"?"Pending":"Paid",
      "Total_GST": "$publicTax",
      "Last_Intimate": ["HelpdeskC"],
      "Flavour":flavour,
      "Shape":shape
    };

    if(type=="disagree"){
      theData = {
        "Customer_Paid_Status": "Cancelled",
        "Customer_Approved_Status": "Not Approved",
        "Last_Intimate": ["HelpdeskC"],
      };
    }

    try{

      http.Response res = await http.put(
        Uri.parse('http://sugitechnologies.com/cakey//api/tickets/changeRequest/Approve/${data['OrderID']}'),
        body:jsonEncode(theData),
        headers: {
          "Content-Type":"application/json"
        }
      );

      if(res.statusCode == 200){
        print(res.body);
        Navigator.pop(context);
        if(jsonDecode(res.body)['statusCode']==200){
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Ticket Updated Successfully!"))
          );
          fetchNotifications();
          getOrdersList();
        }else{
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Ticket Updated Failed!"))
          );
        }
      }else{
        Navigator.pop(context);
        print(res.body);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Ticket Updated Failed!"))
        );
      }

    }catch(e){
      Navigator.pop(context);
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Ticket Update Facing Some Errors...!"))
      );
    }

  }

  //get notifications
  Future<void> fetchNotifications() async {
    mainList.clear();
    setState((){
      isLoading = true;
    });

    //http://sugitechnologies.com/cakey/ http://sugitechnologies.com/cakey http://sugitechnologies.com/cakey//api/users/notification/

    try {
      var res = await http.get(Uri.parse(
          "http://sugitechnologies.com/cakey//api/users/notification/6333e3439e05797c3a35a973"),
          headers: {"Authorization":"$authToken"});
      print(res.statusCode);
      if (res.statusCode == 200) {
        setState(() {
          print(res.body);
          mainList = jsonDecode(res.body);
          print("length : ${mainList.length}");
          isLoading = false;
        });
        context.read<ContextData>().setNotiCount(mainList.length);
      }else{
        checkNetwork();
        setState((){
          isLoading = false;
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error Occurred!'))
          );
        });
        context.read<ContextData>().setNotiCount(0);
      }
    } catch (e) {
      print(e);
      setState((){
        isLoading = false;
        checkNetwork();
      });
      context.read<ContextData>().setNotiCount(0);
    }
    fetchTax();
  }

  //network check
  Future<void> checkNetwork() async{
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('connected');
      }
    } on SocketException catch (_) {
      NetworkDialog().showNoNetworkAlert(context);
      print('not connected');
    }
  }

  //Order Cancellations
  Future<void> cancelOrder(String id , String byId, String title) async{

    //checkNetwork();
    Navigator.pop(context);
    showAlertDialog();

    try{

      var headers = {
        'Content-Type': 'application/json'
      };
      var request = http.Request('PUT', Uri.parse('http://sugitechnologies.com/cakey/api/order/updatestatus/$id'));
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
        checkNetwork();
        print(response.reasonPhrase);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error Occurred!'))
        );
        Navigator.pop(context);
      }

    }catch(e){
      checkNetwork();
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error Occurred!'))
      );
      Navigator.pop(context);
    }

  }

  //delete all notifications
  Future<void> deleteAllNotifications() async{
    showAlertDialog();
    var request = http.Request('DELETE',
        Uri.parse('http://sugitechnologies.com/cakey/api/users/deletenotification/$userId'));


    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
      Navigator.pop(context);
      fetchNotifications();
    }
    else {
      Navigator.pop(context);
      print(response.reasonPhrase);
    }
  }

  //payment handlers...
  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    // Do something when payment succeeds
    print("Pay success : "+response.paymentId.toString());
    if(tempData['CustomizedCakeID']!=null && tempData['Status'].toString().toLowerCase()=="sent"){
      handleCustomiseCakeUpdate(tempData, customPaymentType, "agree", "");
    }else{
      updateTheTickets(tempData, "agree");
    }
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

  void showOkOrNotDialog(var data){
    showDialog(
        context: context,
        builder: (c){
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15)
            ),
            content:Text("Do you want to proceed the cost change?",style: TextStyle(
              fontFamily: "Poppins",
            ),),
            actions: [
              TextButton(
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  child: Text("CANCEL")
              ),
              TextButton(
                  onPressed: (){
                    Navigator.pop(context);
                    if(data['PaymentType'].toString().toLowerCase()=="cash on delivery"){
                      updateTheTickets(data , "agree");
                    }else{
                      makeOrderId(data,data['Difference_In_Price']);
                    }
                  },
                  child: Text("PROCEED")
              ),
            ],
          );
        }
    );
  }

  //handle customise cake api update
  Future<void> handleCustomiseCakeUpdate(var data , String paymentType , String aggreeOrDis , String cancelReason) async{
    showAlertDialog();
    //{
    //         "_id": "63a3da501379ff574cc7493b",
    //         "CustomizedCakeID": "63a29df4cf3425fcc2d4714c",
    //         "CustomizedCake_ID": "CKYCCO-15",
    //         "CakeName": "My Customized Cake",
    //         "Status": "Sent",
    //         "Status_Updated_On": "22-12-2022 09:47 AM",
    //         "UserID": "6333e3439e05797c3a35a973",
    //         "User_ID": "CKYCUS-4",
    //         "UserName": "Naveen Surya",
    //         "CustomizedCake": "y",
    //         "For_Display": "You received your Customized Cake order's Price Invoice",
    //         "TicketID": "63a2a128bbedd4597136f381",
    //         "Flavour": [],
    //         "__v": 0
    //     },

    var pass = {
      "TicketID": data['TicketID'], //TicketID
      "Customer_Approved_Status": "Approved", //Approved
      "Customer_Paid_Status": paymentType.toLowerCase()=="cash on delivery"?"Pending":"Paid", //Paid or Pending
      "Last_Intimate": ["HelpdeskC"], //Static
      "PaymentType": paymentType, //Cash on delivery or payment method
      "PaymentStatus": paymentType.toLowerCase()=="cash on delivery"?"Cash on delivery":"Paid" //Paid Status
    };

    if(aggreeOrDis=="disagree"){
      pass = {
        "TicketID": data['TicketID'], //TicketID
        "Customer_Approved_Status": "NotApproved", //Not Approved
        "Customer_Paid_Status": "Cancelled", //Cancelled
        "Last_Intimate": ["HelpdeskC"], //Static
        "ReasonForCancel": cancelReason, //inputs from customer
      };
    }

    print(pass);

    try{

      http.Response res = await http.put(
          Uri.parse('http://sugitechnologies.com/cakey//api/tickets/customizedCake/confirmOrder/${data['CustomizedCakeID']}'),
          body:jsonEncode(pass),
          headers: {
            "Content-Type":"application/json"
          }
      );

      if(res.statusCode == 200) {
        print(res.body);
        Navigator.pop(context);
        if (jsonDecode(res.body)['statusCode'] == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Cake Details Updated Successfully!"))
          );
          fetchNotifications();
          getOrdersList();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Cake Details Updated Failed!"))
          );
        }
      }

    }catch(e){

      Navigator.pop(context);
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Cake Details Update Facing Some Errors...!"))
      );

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
      getOrdersList();
      print(userId);
    });
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    // Full date and time
    final result1 = simplyFormat(time: currentTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                            fontSize: 18),
                      ),
                    ),
                    Expanded(
                        child: Align(
                            alignment: Alignment.centerRight,
                            child: mainList.isNotEmpty?IconButton(
                              onPressed: ()=>showOrderDeleteAllDialog(),
                              icon: Icon(Icons.delete_outline_outlined , color: Colors.red,),
                            ):null)
                    )
                  ],
                ),
              ),
            )
          ),
          body:SingleChildScrollView(
                child: RefreshIndicator(
                  onRefresh: () async{
                    fetchNotifications();
                    getOrdersList();
                  },
                  child: Container(
                      height: MediaQuery.of(context).size.height*0.9,
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
                          ?ListView.separated(
                            itemCount: mainList.length,
                            shrinkWrap: true,
                            // physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {

                              var mainStatus = mainList[index]['Status'].toString().toLowerCase();
                              var status = "";
                              var name = mainList[index]['UserName'].toString().toLowerCase();
                              var cakename = mainList[index]['CakeName'].toString().toLowerCase();

                              if(mainStatus.toLowerCase()=="new"){
                                status = "Hi $name your $cakename order is placed successfully thank you.";
                              }else if(mainStatus.toLowerCase()=="accepted"){
                                status = "Hi $name your $cakename order is accepted.";
                              }else if(mainStatus.toLowerCase()=="preparing"){
                                status = "Hi $name your $cakename order is now being prepared";
                              }else if(mainStatus.toLowerCase()=="ready"){
                                status = "Hi $name your $cakename order is now ready.";
                              }else if(mainStatus.toLowerCase()=="out for delivery"){
                                status = "Hi $name your $cakename order is now out for delivery.";
                              }else if(mainStatus.toLowerCase()=="delivered"){
                                status = "Hi $name your $cakename order is delivered successfully thank you.";
                              }else if(mainStatus.toLowerCase()=="sent"){
                                status = "Hi $name your $cakename invoice details is here kindly check and continue your payment.";
                              }else if(mainStatus.toLowerCase()=="cancelled"){
                                status = "Hi $name your $cakename order is cancelled";
                              }else if(mainStatus.toLowerCase()=="rejected"||mainStatus.toLowerCase()=="assigned"){
                                status = "Hi $name your $cakename order is accepted.";
                              }

                              print(mainStatus);
                              //

                              selectedTiles.add(false);
                              return GestureDetector(
                                onTap: (){
                                  if(mainList[index]['TicketID']!=null && mainList[index]['OrderID']!=null){
                                      showTicketDialog(mainList[index]);
                                  }else if(mainList[index]['CustomizedCakeID']!=null && mainList[index]['Status'].toString().toLowerCase()=="sent"){
                                    print("log");
                                    //showCustomCakeDetailsDialog(mainList[index]['CustomizedCakeID']);
                                    showCustomCakeInvoices(mainList[index]['CustomizedCakeID'] , mainList[index] );
                                  }
                                },
                                child: Container(
                                  padding: EdgeInsets.all(15),
                                  child: Column(
                                    children: [
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          mainList[index]['Image']==null||
                                          mainList[index]['Image'].toString().isEmpty||
                                          !mainList[index]['Image'].toString().startsWith("http")?
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
                                                image: NetworkImage(mainList[index]['Image'].toString()),
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
                                                      child: Text(
                                                          simplyFormat(time: DateTime.now(),dateOnly: true)==
                                                              mainList[index]['Status_Updated_On'].toString().split(" ").first?
                                                          "Today":formateToDay( mainList[index]['Status_Updated_On'].toString().split(" ").first)
                                                          ,overflow: TextOverflow.ellipsis,
                                                          style: TextStyle(
                                                              color: darkBlue,
                                                              fontFamily: "Poppins",
                                                              fontSize: 12.5,
                                                              fontWeight:
                                                              FontWeight.bold
                                                          ))
                                                  ),
                                                  SizedBox(height: 6,),
                                                  Container(
                                                    // width: 270,
                                                      child:Text(
                                                        "${mainList[index]['For_Display']}",
                                                        maxLines: 3,
                                                        overflow: TextOverflow.ellipsis,
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontFamily: "Poppins",
                                                            fontSize: 13,
                                                        ),
                                                      )),
                                                  SizedBox(
                                                    height: 5,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          selectedTiles[index]==true?
                                          Icon(Icons.check_box , color: Colors.green,):Container()
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                        separatorBuilder: (c,it){
                           return simplyFormat(time: DateTime.now(),dateOnly: true)==
                               mainList[it]['Status_Updated_On'].toString().split(" ").first?
                           Container():
                           Container(
                             height: 0.5,
                             color: darkBlue,
                           );
                        },
                      )
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
                  ),
                )
            ),);

  }
}

String simplyFormat({required DateTime time, bool dateOnly = false}) {

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

  // If you only want year, month, and date
  return "$day-$month-$year";
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

String formateToDay(String date){

  String day = date.split("-").first;
  String month = date.split("-")[1];
  String year = date.split("-").last;

  List months = [
    {"month": 'Jan', "number": 01},
    {"month": 'Feb', "number": 02},
    {"month": 'Mar', "number": 03},
    {"month": 'Apr', "number": 04},
    {"month": 'May', "number": 05},
    {"month": 'Jun', "number": 06},
    {"month": 'Jul', "number": 07},
    {"month": 'Aug', "number": 08},
    {"month": 'Sep', "number": 09},
    {"month": 'Oct', "number": 10},
    {"month": 'Nav', "number": 11},
    {"month": 'Dec', "number": 12},
  ];

  List Month = months.where((element) => element['number']==int.parse(month)).toList();
  String formateMonth = Month[0]["month"];

  String formatedDate = formateMonth+" $day " + year;

  return formatedDate;
}