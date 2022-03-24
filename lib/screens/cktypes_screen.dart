import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CktypesScreen extends StatefulWidget {
  const CktypesScreen({Key? key}) : super(key: key);

  @override
  State<CktypesScreen> createState() => _CktypesScreenState();
}

class _CktypesScreenState extends State<CktypesScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  Color lightGrey = Color(0xffF5F5F5);
  Color darkBlue = Color(0xffF213959);
  Color lightPink = Color(0xffFE8416D);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading:IconButton(
          onPressed: (){
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios,color: lightPink,),
          highlightColor: Colors.black26,
        ),
        title: Text('TYPES OF CAKES',style: TextStyle(color: darkBlue,fontWeight: FontWeight.bold,fontSize: 15)),
        elevation: 0.0,
        backgroundColor:lightGrey,
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              InkWell(
                onTap: ()=>print("hii"),
                child: Container(
                  padding: EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(8)
                  ),
                  child:Icon(Icons.notifications_none,color: darkBlue,),
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
          SizedBox(width: 10,),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(blurRadius: 3, color: Colors.black, spreadRadius: 0)],
            ),
            child: InkWell(
              onTap: (){
                print('hello surya....');
              },
              child: CircleAvatar(
                radius: 19.5,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 18,
                  backgroundImage: NetworkImage("https://yt3.ggpht.com/1ezlnMBACv7Aa5TVu7OVumYrvIFQSsVtmKxKN102PV1vrZIoqIzHCO-XY_ZsWuGHzIgksOv__9o=s900-c-k-c0x00ffffff-no-rj"),
                ),
              ),
            ),
          ),
          SizedBox(width: 10,),
        ],
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [

        ],
      ),
    );
  }
}
