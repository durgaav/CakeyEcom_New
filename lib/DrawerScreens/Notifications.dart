import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cakey/Notification/Notification.dart';
import 'package:cakey/main.dart';
import 'package:cakey/screens/CheckOut.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import '../Dialogs.dart';
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

  // String data = 'new';
  List OrderList = [];
  List CustomizeList = [];
  List mainList=[];
  List ImageList=[];
  var fixedFlavList = [];
  List ordersList = [];
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
    var headers = {
      'Authorization': '$authToken'
    };
    var request = http.Request('GET',
        Uri.parse('https://cakey-database.vercel.app/api/customize/cake/listbyuserid/$userId'));

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

  }

  //show custom cake order view
  void showCustomCakeDetailsDialog(String orderId){

    print(orderId);

    List myList = ordersList.where((element) => element['_id']==orderId).toList();

    print(myList[0]["Status"]);

    var opac = 1.0;
    var timer = new Timer(Duration(seconds: 2), () {setState((){opac = 1.0;});});
    timer;

    print(myList);

      myList.isNotEmpty&&myList[0]['Status'].toString().toLowerCase()=='sent'?
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
                                      'Rs.${myList[0]['Total'].toString().characters.take(6)}', style:TextStyle(
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
                                      '${myList[0]['Status']}', style:TextStyle(
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

  //region Functions

  //get notifications
  Future<void> fetchNotifications() async {
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
          print(res.body);
          mainList = jsonDecode(res.body);
          print("length : ${mainList.length}");
          isLoading = false;
        });
      }else{
        checkNetwork();
        setState((){
          isLoading = false;
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error Occurred!'))
          );
        });
      }
    } catch (e) {
      print(e);
      setState((){
        isLoading = false;
        checkNetwork();
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error Occurred!'),behavior: SnackBarBehavior.floating,)
        );
      });
    }
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
                            fontSize: 17),
                      ),
                    ),
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
                          ?ListView.builder(
                            itemCount: mainList.length,
                            shrinkWrap: true,
                            // physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: (){
                                  if(mainList[index]['CustomizedCake']=="y"){
                                    showCustomCakeDetailsDialog(mainList[index]['CustomizedCakeID']);
                                  }
                                },
                                child: Container(
                                  padding: EdgeInsets.all(15),
                                  child: Row(
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
                                                  child:
                                                  ((mainList[index]['Status'].toString().toLowerCase()=='delivered')?
                                                  Text(
                                                    "Hi ${mainList[index]['UserName']} your ${mainList[index]['CakeName']==null?"Customise cake":mainList[index]['CakeName']} delivered on "
                                                        "${mainList[index]['Status_Updated_On']} Thank you for purchase.Keep shop.",
                                                    maxLines: 3,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontFamily: "Poppins",
                                                        fontSize: 13,
                                                    ),
                                                  ):(mainList[index]['Status'].toString().toLowerCase()=='preparing')?
                                                  Text(
                                                    "Hi ${mainList[index]['UserName']} your ${mainList[index]['CakeName']==null?"Customise cake":mainList[index]['CakeName']} "
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
                                                    "Hi ${mainList[index]['UserName']} your ${mainList[index]['CakeName']==null?"Customise cake":mainList[index]['CakeName']} "
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
                                                    "Hi ${mainList[index]['UserName']}, kindly check the invoice details for your ${mainList[index]["CakeName"]} "
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
                                                    "Hi ${mainList[index]['UserName']} your ${mainList[index]['CakeName']} is ordered.We will notify status soon as possible",
                                                    maxLines: 3,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                        color:Colors.black,
                                                        fontFamily: "Poppins",
                                                        fontSize: 13
                                                    ),
                                                  ):(mainList[index]['Status'].toString().toLowerCase()=='assigned')?
                                                  Text(
                                                    "Hi ${mainList[index]['UserName']} Your ${mainList[index]['CakeName']==null?"Customise cake":mainList[index]['CakeName']}"
                                                        "is assigned to Vendor ${mainList[index]['VendorName']}",
                                                    maxLines: 3,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                        color:Colors.black,
                                                        fontFamily: "Poppins",
                                                        fontSize: 13
                                                    ),
                                                  ):Text(
                                                    "Hi ${mainList[index]['UserName']} Your ${mainList[index]['CakeName']==null?"Customise cake":mainList[index]['CakeName']}"
                                                        " is order cancelled.",
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