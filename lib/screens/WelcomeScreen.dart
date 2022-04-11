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
  List desc = ["Lorem Ipsum is simply dummy text of the printing and "
      "typesetting industry. Lorem Ipsum has been the industry's "
      "standard dummy text ever since the 1500s, when an unknown printer ",
    "Lorem Ipsum is simply dummy text of the printing and "
        "typesetting industry. Lorem Ipsum has been the industry's "
        "standard dummy text ever since the 1500s, when an unknown printer ",
    "Lorem Ipsum is simply dummy text of the printing and "
        "typesetting industry. Lorem Ipsum has been the industry's "
        "standard dummy text ever since the 1500s, when an unknown printer "];

  //this is svg
  var pics = [
    "assets/images/picone.svg",
    "assets/images/pictwo.svg",
    "assets/images/picthree.svg",
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
              PageView.builder(
                controller: controll,
                itemCount:3,
                itemBuilder: (context, index){
                  precacheImage(Svg(pics[index]), context);
                  currentindex=index;
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        //color: Colors.red,
                        height: MediaQuery.of(context).size.height*0.2,
                        child:Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children:[
                              Text('${title[index]}',style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold),),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child:
                                Text('${desc[index]}',style: TextStyle(fontSize: 15,letterSpacing: 1,),
                                    textAlign:TextAlign.center),
                              ),
                            ]
                        ),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height*0.4,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image:Svg(pics[index]),
                          ),
                        ),
                      ),
                      Container(
                        height:MediaQuery.of(context).size.height*0.2,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 4,
                                  backgroundColor: index==0?Colors.blueGrey:Colors.black12,
                                ),
                                SizedBox(width: 23,),
                                CircleAvatar(
                                  radius: 4,
                                  backgroundColor: index==1?Colors.blueGrey:Colors.black12,
                                ),
                                SizedBox(width: 23,),
                                CircleAvatar(
                                  radius: 4,
                                  backgroundColor: index==2?Colors.blueGrey:Colors.black12,
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                    padding: EdgeInsets.symmetric(horizontal: 20),
                                    width: MediaQuery.of(context).size.width*0.6,
                                    child: index !=2 ?Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        TextButton(onPressed: (){
                                          Navigator.pop(context);
                                          Navigator.push(context, MaterialPageRoute(builder: (context)=>PhoneVerify()));
                                        }, child: Text('SKIP',style: TextStyle(fontSize: 21),)),
                                        Container(
                                            decoration:BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: lightPink
                                            ),
                                            child: IconButton(onPressed: (){
                                              setState(() {
                                                if(index==0){
                                                  controll.animateToPage(1, curve: Curves.ease ,duration: Duration(milliseconds: 700));
                                                }else{
                                                  controll.animateToPage(2, curve: Curves.ease ,duration: Duration(milliseconds: 700));
                                                }
                                              });
                                            }, icon: Icon(Icons.arrow_forward ),color: Colors.white,iconSize: 28,)
                                        ),
                                      ],
                                    )
                                        :Container(
                                      width: MediaQuery.of(context).size.width*0.2,
                                      height: MediaQuery.of(context).size.height*0.07,
                                      child: RaisedButton(
                                        color:lightPink,
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(35)),
                                        onPressed: (){
                                          Navigator.pop(context);
                                          Navigator.push(context, MaterialPageRoute(builder: (context)=>PhoneVerify()));
                                        },
                                        child: Text('Done',style: TextStyle(fontSize: 18,color: Colors.white,fontWeight: FontWeight.bold),),
                                      ),
                                    )
                                ),
                              ],
                            )
                          ],
                        ),
                      )
                    ],
                  );
                },)
          ),
        )
    );
  }
}
