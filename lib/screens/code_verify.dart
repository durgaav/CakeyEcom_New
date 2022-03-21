import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

//Code Verify screen.....
class CodeVerify extends StatefulWidget {
  String phonenumber = '';
  CodeVerify({required this.phonenumber});
  @override
  State<CodeVerify> createState() => _CodeVerifyState(phonenumber: phonenumber);
}

class _CodeVerifyState extends State<CodeVerify> {
  String phonenumber = '';
  _CodeVerifyState({required this.phonenumber});
  TextEditingController otpControl = new TextEditingController();
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
                  Text('OTP',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                  Text("Code is sent to $phonenumber",textAlign: TextAlign.center,),
                  SizedBox(height: 100,),
                  Container(
                    margin: EdgeInsets.only(left: 20, right: 20),
                    child: PinCodeTextField(
                        keyboardType: TextInputType.phone,
                        appContext: context,
                        length: 6,
                        onChanged:(String? changed){},
                        pinTheme: PinTheme(
                          inactiveColor: Colors.black54,
                          activeColor: Colors.green,
                          borderWidth: 2,
                          borderRadius: BorderRadius.circular(6),
                          shape:PinCodeFieldShape.box
                        ),
                    ),
                  ),
                  SizedBox(height: 50,),
                  Text("Don't recieve code?",textAlign: TextAlign.center,),
                  TextButton(
                      onPressed: (){},
                      child: Text("Request Again",textAlign: TextAlign.center,style: TextStyle(
                          decoration: TextDecoration.underline,color: Colors.orange,
                          fontWeight: FontWeight.bold
                      ),),
                  ),
                  SizedBox(height: 100,),
                  Container(
                    height: 55,
                    width: 175,
                    child: RaisedButton(onPressed:(){
                      FocusScope.of(context).unfocus();
                      print("+91${otpControl.text.toString()}");
                    },
                      child:Text("DONE",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
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
