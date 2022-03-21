import 'package:cakey/screens/code_verify.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Container(
            padding: EdgeInsets.only(bottom: 20),
            width: double.infinity,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 20,),
                  Text('LOGIN',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                  Image(
                    height: 230,
                    image: AssetImage("assets/images/phone.png"),
                  ),
                  Text("You'll receive a 6 digit code to \nverify next",textAlign: TextAlign.center,),
                  SizedBox(height: 35,),
                  Container(
                    alignment: Alignment.centerLeft,
                    margin: EdgeInsets.only(left: 15),
                    padding: EdgeInsets.all(5),
                    width: double.infinity,
                    child: Text('Phone Number',style: TextStyle(color: Colors.black),),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 15,right: 15),
                    child: TextField(
                      onChanged: (String? textLen){
                        setState(() {
                          length = textLen!;
                        });
                      },
                      controller: phoneControl,
                      maxLines: 1,
                      maxLength: 10,
                      keyboardType: TextInputType.phone,
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
                              color: Colors.lightGreen,
                            ),
                          ),
                          hintText: 'Phone Number',
                          prefixIcon: Icon(CupertinoIcons.phone_circle , color: Colors.black,size: 35,)
                      ),
                    ),
                  ),
                  SizedBox(height: 20,),
                  Container(
                    height: 55,
                    width: 200,
                    child: RaisedButton(onPressed:(){
                      FocusScope.of(context).unfocus();
                      if(phoneControl.text.isEmpty||phoneControl.text.length<10){
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            elevation: 20,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            margin: EdgeInsets.all(15),
                            content: Text('Enter Correct Number!',textAlign: TextAlign.center,style: TextStyle(
                                color: Colors.white,fontWeight: FontWeight.bold
                            ),),
                            backgroundColor: Colors.deepPurpleAccent[400],
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }else{
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>CodeVerify(
                          phonenumber: "+91"+phoneControl.text.toString(),
                        )));
                      }
                      print("+91${phoneControl.text.toString()}");
                    },
                      child:Text("CONTINUE",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
                      shape: RoundedRectangleBorder(
                          borderRadius:BorderRadius.circular(30)
                      ),
                      color: Colors.green,
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