import 'package:cakey/screens/phone_verify.dart';
import 'package:flutter/material.dart';

//Welcome screen (Page View).....
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {

  PageController controll = new PageController(viewportFraction: 1, keepPage: true);
  int currentindex=0;
  List title = [ "Customize Your cake", "Select Your vendor","On Time Delivery"];
  List desc = ["Lorem Ipsum is simply dummy text of the printing and "
                "typesetting industry. Lorem Ipsum has been the industry's "
                    "standard dummy text ever since the 1500s, when an unknown printer ",
  "Lorem Ipsum is simply dummy text of the printing and "
      "typesetting industry. Lorem Ipsum has been the industry's "
      "standard dummy text ever since the 1500s, when an unknown printer ",
  "Lorem Ipsum is simply dummy text of the printing and "
      "typesetting industry. Lorem Ipsum has been the industry's "
      "standard dummy text ever since the 1500s, when an unknown printer "];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          child:
          // Stack(
          //   children: [
              PageView.builder(
               controller: controll,
                itemCount:3,
                itemBuilder: (context, index){
                  currentindex=index;
                  return Center(
                    child: Column(
                      children: [
                          Container(
                            margin:EdgeInsets.only(top:60),
                              child: Text('${title[index]}',style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold),)
                          ),
                        Container(
                          alignment:Alignment.center,
                          margin:EdgeInsets.all(20),
                          padding:EdgeInsets.only(top:10,bottom: 30),
                          child: Text('${desc[index]}',style: TextStyle(fontSize: 15,letterSpacing: 1,),
                          textAlign:TextAlign.center),
                        ),

                        Container(
                          width:300,
                          height:250,
                          decoration: BoxDecoration(
                          image: DecorationImage(
                          image: AssetImage('assets/images/phoneverify.png'),
                          ),
                          ),
                        ),
                        SizedBox(height: 100,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 4,
                              backgroundColor: index==0?Colors.blueGrey:Colors.black12,
                            ),
                            SizedBox(
                              width: 23,
                            ),
                            CircleAvatar(
                              radius: 4,
                              backgroundColor: index==1?Colors.blueGrey:Colors.black12,
                            ),
                            SizedBox(
                              width: 23,
                            ),
                            CircleAvatar(
                              radius: 4,
                              backgroundColor: index==2?Colors.blueGrey:Colors.black12,
                            ),
                          ],
                        ),
                        Container(
                          margin: EdgeInsets.only(top:40),
                          child: index !=2 ?Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(onPressed: (){
                                Navigator.push(context, MaterialPageRoute(builder: (context)=>PhoneVerify()));
                              }, child: Text('SKIP',style: TextStyle(fontSize: 21),)),
                              SizedBox(width: 60,),
                              Container(
                                decoration:BoxDecoration(
                                    borderRadius: BorderRadius.circular(100),
                                  color: Colors.lightGreen
                                 ),
                                  child: IconButton(onPressed: (){
                                    setState(() {
                                      if(index==0){
                                        controll.jumpToPage(1);
                                      }else{
                                        controll.jumpToPage(2);
                                      }
                                    });
                                  }, icon: Icon(Icons.navigate_next),color: Colors.white,iconSize: 40,)
                              ),
                              SizedBox(width: 30,),
                            ],
                          )
                              :Container(
                            width:160,
                              height:50,
                                child: RaisedButton(
                                  color:Colors.lightGreen,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(35)),
                                  onPressed: (){},
                                  child: Text('Done',style: TextStyle(fontSize: 18,color: Colors.white,fontWeight: FontWeight.bold),),
                          ),
                              )
                        )
                      ],
                    ),
                  );
                },)
          //   ],
          // ),
        ),
      )
    );
  }
}
