import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
  var dateTime = ["Mar 4th 2022","Mar 2nd 2022","Mar 1st 2022"];
  int i =0 ;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // Full date and time
    final result1 = simplyFormat(time: currentTime);
    print(result1);

    Timer(Duration(seconds: 5),() async{
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
      appBar:AppBar(
        elevation: 0,
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
        backgroundColor: lightGrey,
        title: Text(
          'NOTIFICATIONS',
          style: TextStyle(
            color: darkBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          child: i==0?
          ListView.builder(
                itemCount: 10,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (count,index){
                  return Shimmer.fromColors(
                    baseColor:Colors.grey,
                    highlightColor: Colors.black26,
                    child: Container(
                      padding: EdgeInsets.all(10),
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
                          ),
                          SizedBox(width: 10,),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 275,
                                height: 50,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    color: Colors.grey
                                ),
                              ),
                              SizedBox(height: 10,),
                              Container(
                                width: 100,
                                height: 20,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    color: Colors.grey
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                }
            ):
          ListView.builder(
              itemCount: 3,
              shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context , index) {
                  return Container(
                    padding: EdgeInsets.all(10),
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
                          child: Icon(Icons.notifications_none,size: 45,),
                        ),
                        SizedBox(width: 10,),
                        Column(
                          children: [
                            Container(
                              width: 270,
                              child: Text('Hi your chocolate cup cakes are arriving '
                                  'today stay connected and get latest notifications',
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.black54,fontFamily: "Poppins",fontSize: 13
                              ),
                              ),
                            ),
                            SizedBox(width: 10,),
                            Container(
                              width: 270,
                              child:
                                // Text(dateTime[index]==result2?'Today':'${dateTime[index]}',
                                Text('${dateTime[index]}',
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: darkBlue,
                                    fontFamily: "Poppins",fontSize: 14,fontWeight: FontWeight.bold
                                ),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  );
                }
            ),
          ),
        ),
      );
  }
}

String simplyFormat({required DateTime time, bool dateOnly = false}) {

  List months = [
    {"month":'Jan',"number":1},
    {"month":'Feb',"number":2},
    {"month":'Mar',"number":3},
    {"month":'Apr',"number":4},
    {"month":'May',"number":5},
    {"month":'Jun',"number":6},
    {"month":'Jul',"number":7},
    {"month":'Aug',"number":8},
    {"month":'Sep',"number":9},
    {"month":'Oct',"number":10},
    {"month":'Nav',"number":11},
    {"month":'Dec',"number":12},
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

  List mon = months.where((element) => element['number']==int.parse(month)).toList();

  print(mon);

  // If you only want year, month, and date
  return "${mon[0]['month']} ${day}nd $year";
}


