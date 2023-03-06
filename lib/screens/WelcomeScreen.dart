import 'dart:async';
import 'package:cakey/raised_button_utils.dart';
import 'package:cakey/screens/PhoneVerify.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:flutter/material.dart';

//Welcome screen (Page View).....
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {


  //colors...
  Color lightGrey = Color(0xffF5F5F5);
  Color darkBlue = Color(0xffF213959);
  Color lightPink = Color(0xffFE8416D);

  PageController controll = new PageController(viewportFraction: 1, keepPage: true);
  int currentindex = 0;
  List title = [ "Customize Your cake", "Select Your vendor","On Time Delivery"];
  List desc =
  [
    "Easily make your customize favourite cakes from your imagination.\n",
    "You can choose your favourite vendor from your nearest location.\n",
    "We giving you a great delivery at time.\n"
  ];

  //this is svg
  var pics = [
    "assets/images/picone.png",
    "assets/images/pictwo.png",
    "assets/images/picthree.png",
  ];


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
          child: Container(
              child:
              Stack(
                children: [
                  PageView.builder(
                    controller: controll,
                    physics: BouncingScrollPhysics(),
                    itemCount:3,
                    onPageChanged: (int i){
                      setState(() {
                        currentindex = i;
                      });
                      print('ci : $currentindex');
                    },
                    itemBuilder: (context, index){
                      precacheImage(AssetImage(pics[index]), context);
                      currentindex=index;
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height*0.06,
                          ),
                          Container(
                            //color: Colors.red,
                            height: MediaQuery.of(context).size.height*0.2,
                            child:Column(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children:[
                                  Text('${title[index]}',style: TextStyle(fontFamily:"Poppins",fontSize: 20,fontWeight: FontWeight.bold),),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 20),
                                    child:
                                    Text('${desc[index]}',style: TextStyle(fontSize: 12.7,letterSpacing: 1,fontFamily: "Poppins",
                                    color: Color(0xff8c9ca4)),
                                        textAlign:TextAlign.center ),
                                  ),
                                ]
                            ),
                          ),
                          Container(
                            height: MediaQuery.of(context).size.height*0.4,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image:AssetImage(pics[index]),
                              ),
                            ),
                          ),
                        ],
                      );
                    },),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      margin: EdgeInsets.only(bottom: 40),
                      height:MediaQuery.of(context).size.height*0.2,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 4,
                                backgroundColor: currentindex==0?Colors.blueGrey:Colors.black12,
                              ),
                              SizedBox(width: 23,),
                              CircleAvatar(
                                radius: 4,
                                backgroundColor: currentindex==1?Colors.blueGrey:Colors.black12,
                              ),
                              SizedBox(width: 23,),
                              CircleAvatar(
                                radius: 4,
                                backgroundColor: currentindex==2?Colors.blueGrey:Colors.black12,
                              ),
                            ],
                          ),
                          currentindex!=2?
                          Container(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                width: MediaQuery.of(context).size.width,
                                child:
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Expanded(child: Container()),
                                    Align(
                                      alignment: Alignment.center,
                                      child: TextButton(onPressed: (){
                                        // Navigator.pop(context);
                                        Navigator.push(context, MaterialPageRoute(builder: (context)=>PhoneVerify()));
                                      },
                                          child: Text('SKIP',style: TextStyle(fontSize: 18, color:Color(0xff8c9ca4),fontFamily: "Poppins"),)
                                      ),
                                    ),
                                    Expanded(child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Container(
                                          height: 50,width: 50,
                                          alignment: Alignment.center,
                                          decoration:BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: lightPink
                                          ),
                                          child: IconButton(onPressed: (){
                                            if(controll.page==0){
                                              controll.animateToPage(1,curve: Curves.ease ,duration: Duration(milliseconds: 500));
                                            }else if(controll.page==1){
                                              controll.animateToPage(2,curve: Curves.ease ,duration: Duration(milliseconds: 500));
                                            }
                                          },
                                            icon: Icon(Icons.arrow_forward ),color: Colors.white,iconSize: 28,)
                                      ),
                                    ),),
                                  ],
                                ),
                            ):
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            width: MediaQuery.of(context).size.width*0.6,
                            height: MediaQuery.of(context).size.height*0.07,
                            child:CustomRaisedButton(
                              onPressed: (){
                                Navigator.pop(context);
                                Navigator.push(context, MaterialPageRoute(builder: (context)=>PhoneVerify()));
                              },
                              child:Text('DONE',style: TextStyle(fontSize: 18,color: Colors.white,),),
                              color:lightPink,
                            )
                          )
                        ],
                      ),
                    ),
                  )
                ],
              )
          ),
        )
    );
  }
}
