import 'dart:io';

import 'package:cakey/CountryCode.dart';
import 'package:cakey/Dialogs.dart';
import 'package:cakey/functions.dart';
import 'package:cakey/screens/CodeVerify.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';

//Phone Verify screen.....
//For Login
class PhoneVerify extends StatefulWidget {
  const PhoneVerify({Key? key}) : super(key: key);

  @override
  State<PhoneVerify> createState() => _PhoneVerifyState();
}

class _PhoneVerifyState extends State<PhoneVerify> {
  TextEditingController phoneControl = new TextEditingController();
  String length = "";
  Color lightPink = Color(0xffFE8416D);
  Color lightGrey = Color(0xffF5F5F5);
  Color darkBlue = Color(0xffF213959);

  var countryCodes = CountryCodes().list;
  var selectedCode = "91";

  //network check
  void checkNetwork() async{
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('connected');
        print("Perform Actions Here");
        Navigator.push(context, MaterialPageRoute(builder: (context)=>CodeVerify(
          phonenumber: "+$selectedCode"+phoneControl.text.toString(),
        )));
      }
    } on SocketException catch (_) {
      print('not connected');
      NetworkDialog().showNoNetworkAlert(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Container(
            height: MediaQuery.of(context).size.height,
            padding: EdgeInsets.only(bottom: 20),
            width: double.infinity,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 40,),
                  Text('LOGIN',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,fontFamily: "Poppins"),),
                  Container(
                    height: 230,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("assets/images/phone.png"),
                      )
                    ),
                  ),
                  Text("You'll receive a 6 digit code \nfor verification",textAlign: TextAlign.center,
                  style: TextStyle(fontFamily: "Poppins",color: Color(0xffbac4c8),fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 35,),
                  Container(
                    alignment: Alignment.centerLeft,
                    margin: EdgeInsets.only(left: 15),
                    padding: EdgeInsets.all(5),
                    width: double.infinity,
                    child: Text('Country',style: TextStyle(fontFamily: "Poppins",color:Color(0xffbac4c8),fontWeight: FontWeight.bold),),
                  ),
                  SizedBox(height: 7,),
                  Container(
                    decoration: BoxDecoration(
                      // border: Border.all(
                      //   color: Colors.grey[400]!,
                      //   width: 1
                      // ),
                      // borderRadius: BorderRadius.circular(15)
                    ),
                    margin: EdgeInsets.only(left: 15,right: 15),
                    padding: EdgeInsets.all(0),
                    child:  DropdownButton(
                      menuMaxHeight: 300,
                      items: countryCodes.map<DropdownMenuItem<String>>((e){
                        return DropdownMenuItem(
                          child: Text("+"+e['code'].toString()+"  "+e['country'].toString(),style: TextStyle(
                            color: Colors.black,fontFamily: "Poppins"
                          ),),
                          value: e['code'],
                        );
                      }).toList(),
                      isExpanded: true,
                      underline: Container(
                        height: 1,color: Colors.grey[400],
                      ),
                      onChanged: (e){
                        setState(() {
                          selectedCode = e.toString();
                        });
                      },
                      value: selectedCode,
                    ),
                  ),
                  SizedBox(height: 7,),
                  Container(
                    alignment: Alignment.centerLeft,
                    margin: EdgeInsets.only(left: 15),
                    padding: EdgeInsets.all(5),
                    width: double.infinity,
                    child: Text('Phone Number',style: TextStyle(fontFamily: "Poppins",color:Color(0xffbac4c8),fontWeight: FontWeight.bold),),
                  ),
                  SizedBox(height: 7,),
                  Container(
                    margin: EdgeInsets.only(left: 15,right: 15),
                    child: TextField(
                            onChanged: (String? textLen){
                              setState(() {
                                length = textLen!;
                                if(textLen==10){
                                  FocusScope.of(context).unfocus();
                                }
                              });
                            },
                            controller: phoneControl,
                            maxLines: 1,
                            maxLength: 10,
                            keyboardType: TextInputType.phone,
                            style: TextStyle(color: darkBlue,fontWeight: FontWeight.bold),
                            decoration: InputDecoration(
                                suffixIcon: Visibility(
                                  visible: length.length>0?true:false,
                                  child: IconButton(
                                    onPressed: (){
                                      FocusScope.of(context).unfocus();
                                      setState(() {
                                        phoneControl.text = "";
                                        length = "";
                                      });
                                    },
                                    icon: Icon(Icons.close_rounded),
                                    iconSize: 18,
                                  ),
                                ),
                                hintText: 'Phone Number',
                                border: InputBorder.none,
                                counterText: "",
                                hintStyle: TextStyle(fontFamily: "Poppins",color: Color(0xffbac4c8)),
                                prefixIcon:Container(
                                  margin: EdgeInsets.all(6),
                                  height: 25,
                                  width: 25,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: lightGrey,
                                    shape: BoxShape.circle
                                  ),
                                  child: Icon(Icons.phone , color: darkBlue,size: 20,),
                                ),

                            ),
                          ),
                  ),
                  Container(
                    height: 1,color: Colors.grey[400],
                    margin: EdgeInsets.only(left: 12,right: 12,top: 7),
                  ),
                  SizedBox(height: 40,),
                  Container(
                    height: 55,
                    width: 200,
                    child: RaisedButton(onPressed:(){
                      FocusScope.of(context).unfocus();
                      if(phoneControl.text.isEmpty||phoneControl.text.length<10){
                        Functions().showSnackMsg(context, "Please enter the valid mobile number!", true);
                      }else{
                        checkNetwork();
                      }
                      print("+91${phoneControl.text.toString()}");
                    },
                      child:Text("CONTINUE",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontFamily: "Poppins"),),
                      shape: RoundedRectangleBorder(
                          borderRadius:BorderRadius.circular(30)
                      ),
                      color: lightPink,
                    ),
                  )
                ],
              ),
            ),
          ),
        )
    );
  }
}