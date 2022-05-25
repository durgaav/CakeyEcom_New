import 'dart:async';
import 'dart:convert';
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
  String cakeId='';
  String userId='';
  String status='unseen';

  bool viewData = false;

  Future <void> updateStatus() async{
    try{
      var url = Uri.parse('https://cakey-database.vercel.app/api/customize/cake/update/notification/$cakeId');
      var response = await http.put(url, body: {'Notification':'seen'});
      print('Response body: ${response.body}');
      print(cakeId);
    }catch(e){
      print(e);
    }
  }

  Future<void> notifyData() async {
    CustomizeList.clear();
    print(userId);
    try {
      var res = await http.get(Uri.parse(
          "https://cakey-database.vercel.app/api/users/notification/$userId"));
      print(res);
      print(res.statusCode);
      if (res.statusCode == 200) {
        Map<String, dynamic> custommap = json.decode(res.body);
        List<dynamic> Customize = custommap["CustomizeCakesList"];
        print(Customize.length);
        for (int i = 0; i < Customize.length; i++) {
          // print('found .... $i');
          print(Customize[i]["VendorName"]);
          CustomizeList.add(Customize[i]);
          cakeId = Customize[i]['_id'];
          print('cake id..... $cakeId');
          // print(CustomizeList.length);
          // print('list length,,,,,,');
          // print(CustomizeList);
        }

        // Map<String, dynamic> ordermap = json.decode(res.body);
        List<dynamic> Order = custommap["OrdersList"];
        print(Order.length);
        for (int i = 0; i < Order.length; i++) {
          // print('found .... $i');
          // print(Order[i]["VendorName"]);
          OrderList.add(Order[i]);
          // print(OrderList);
        }

        MainList =CustomizeList.toList() + OrderList.toList();
        MainList.reversed.toList();
        print(MainList);
      }
    } catch (e) {
      print(e);
    }
  }


  Future<void> CustomListPopup(index) async{
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title:  Text('Order Info',style: TextStyle(fontFamily: "Poppins")),
        content: Container(
          height: 340,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.only(bottom: 10),
                child: Center(
                    child: (MainList[index]['Images']!=null)?CircleAvatar(
                        radius: 50,
                        backgroundImage:
                        NetworkImage(MainList[index]['Images'])
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
                  Text('Payment Type',style: TextStyle(fontFamily: "Poppins",fontSize: 12,fontWeight: FontWeight.bold),),
                  Text('-',style: TextStyle(fontFamily: "Poppins"),),
                  Text(MainList[index]['PaymentType'],style: TextStyle(fontFamily: "Poppins",fontSize: 12),),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total Price',style: TextStyle(fontFamily: "Poppins",fontSize: 12,fontWeight: FontWeight.bold),),
                  Text('-',style: TextStyle(fontFamily: "Poppins"),),
                  Text('Rs. '+ MainList[index]['Total'],style: TextStyle(fontFamily: "Poppins",fontSize: 12),),
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
            child: const Text('Cancel'),
          ),
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
          height: 340,
          child: Column(
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
                  Text('Payment Type',style: TextStyle(fontFamily: "Poppins",fontSize: 12,fontWeight: FontWeight.bold),),
                  Text('-',style: TextStyle(fontFamily: "Poppins"),),
                  Text(MainList[index]['PaymentType'],style: TextStyle(fontFamily: "Poppins",fontSize: 12),),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total Price',style: TextStyle(fontFamily: "Poppins",fontSize: 12,fontWeight: FontWeight.bold),),
                  Text('-',style: TextStyle(fontFamily: "Poppins"),),
                  Text('Rs. '+ MainList[index]['Total'],style: TextStyle(fontFamily: "Poppins",fontSize: 12),),
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
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration.zero, () async {
      var prefs = await SharedPreferences.getInstance();
      userId = prefs.getString('userID').toString();
      print('user id.....   $userId');
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
        // appBar:AppBar(
        //   elevation: 0,
        //   leading:Container(
        //     margin: const EdgeInsets.all(10),
        //     child: InkWell(
        //       onTap: () {
        //         Navigator.pop(context);
        //       },
        //       child: Container(
        //           decoration: BoxDecoration(
        //               color: Colors.grey[300],
        //               borderRadius: BorderRadius.circular(10)),
        //           alignment: Alignment.center,
        //           height: 20,
        //           width: 20,
        //           child: Icon(
        //             Icons.chevron_left,
        //             color: lightPink,
        //             size: 35,
        //           )),
        //     ),
        //   ),
        //   backgroundColor: lightGrey,
        //   title: Text(
        //     'NOTIFICATIONS',
        //     style: TextStyle(
        //       color: darkBlue,
        //       fontWeight: FontWeight.bold,
        //     ),
        //   ),
        // ),
        body: RefreshIndicator(
          onRefresh: () async {
            notifyData();
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
                            if(MainList[index]['Notification']!=null){
                              if(MainList[index]['Notification']=='unseen'){
                                setState(() {
                                  viewData = true;
                                  print(viewData);
                                  CustomListPopup(index);
                                  updateStatus();
                                });
                              }
                            }else {
                              setState(() {
                                viewData= true;
                                print(viewData);
                                print('Notification data...');
                                print(MainList[index]['Notification']);
                                print(MainList[index]['_id']);
                                print(MainList[index]['UserName']);
                                OrderListPopup(index);
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
                                            child:(viewData == false)?
                                            (
                                                (MainList[index]['Notification']=='unseen')?Text(
                                                  'Hi ' + MainList[index]['UserName'] + ' your Customized Chocolate layer cake Order has been placed successfully.',
                                                  maxLines: 3,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontFamily: "Poppins",
                                                      fontSize: 13,fontWeight: FontWeight.bold),
                                                ):(MainList[index]['Notification'] == 'seen')?Text(
                                                  'Hi ' + MainList[index]['UserName'] + ' your Customized Chocolate layer cake Order has been placed successfully.',
                                                  maxLines: 3,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      color: Colors.black54,
                                                      fontFamily: "Poppins",
                                                      fontSize: 13,fontWeight: FontWeight.bold),
                                                ):Text(
                                                  'Hi '+ MainList[index]['UserName']  + ' your Order chocolate cake order placed.',
                                                  maxLines: 3,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontFamily: "Poppins",
                                                      fontSize: 13,fontWeight: FontWeight.bold),
                                                )
                                            ):
                                            (
                                                (MainList[index]['Notification']=='unseen')?Text(
                                                  'Hi ' + MainList[index]['UserName'] + ' your Customized Chocolate layer cake Order has been placed successfully.',
                                                  maxLines: 3,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      color: Colors.black54,
                                                      fontFamily: "Poppins",
                                                      fontSize: 13,fontWeight: FontWeight.bold),
                                                ):(MainList[index]['Notification'] == 'seen')?Text(
                                                  'Hi ' + MainList[index]['UserName'] + ' your Customized Chocolate layer cake Order has been placed successfully.',
                                                  maxLines: 3,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      color: Colors.black54,
                                                      fontFamily: "Poppins",
                                                      fontSize: 13,fontWeight: FontWeight.bold),
                                                ):Text(
                                                  'Hi '+ MainList[index]['UserName']  + ' your Order chocolate cake order placed.',
                                                  maxLines: 3,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      color: Colors.black54,
                                                      fontFamily: "Poppins",
                                                      fontSize: 13,fontWeight: FontWeight.bold),
                                                )
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
                  // : (OrderList.length != 0)
                  //     ? ListView.builder(
                  //         itemCount: OrderList.length,
                  //         shrinkWrap: true,
                  //         physics: NeverScrollableScrollPhysics(),
                  //         itemBuilder: (context, index) {
                  //           return Container(
                  //             padding: EdgeInsets.all(10),
                  //             child: Row(
                  //               crossAxisAlignment:
                  //                   CrossAxisAlignment.start,
                  //               children: [
                  //                 Container(
                  //                   height: 55,
                  //                   width: 55,
                  //                   decoration: BoxDecoration(
                  //                     shape: BoxShape.circle,
                  //                     color: Colors.grey,
                  //                   ),
                  //                   child: Icon(
                  //                     Icons.notifications_none,
                  //                     size: 45,
                  //                   ),
                  //                 ),
                  //                 SizedBox(
                  //                   width: 10,
                  //                 ),
                  //                 Expanded(
                  //                   child: Container(
                  //                     child: Column(
                  //                       crossAxisAlignment:
                  //                           CrossAxisAlignment.start,
                  //                       children: [
                  //                         Container(
                  //                           // width: 270,
                  //                           child: Text(
                  //                             'Hi your  chocolate cup cakes are arriving '
                  //                             'today stay connected and get latest notifications',
                  //                             maxLines: 3,
                  //                             overflow:
                  //                                 TextOverflow.ellipsis,
                  //                             style: TextStyle(
                  //                                 color: Colors.black54,
                  //                                 fontFamily: "Poppins",
                  //                                 fontSize: 13),
                  //                           ),
                  //                         ),
                  //                         SizedBox(
                  //                           width: 10,
                  //                         ),
                  //                         Container(
                  //                           // width: 270,
                  //                           child:
                  //                               // Text(dateTime[index]==result2?'Today':'${dateTime[index]}',
                  //                               Text(
                  //                             OrderList[index]
                  //                                 ['Created_On'],
                  //                             maxLines: 3,
                  //                             overflow:
                  //                                 TextOverflow.ellipsis,
                  //                             style: TextStyle(
                  //                                 color: darkBlue,
                  //                                 fontFamily: "Poppins",
                  //                                 fontSize: 14,
                  //                                 fontWeight:
                  //                                     FontWeight.bold),
                  //                           ),
                  //                         )
                  //                       ],
                  //                     ),
                  //                   ),
                  //                 )
                  //               ],
                  //             ),
                  //           );
                  //         })
                      : Container(
                    child: Text('no data found....'),
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

