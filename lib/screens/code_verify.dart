import 'package:cakey/screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  String verificationId = "";
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Color lightPink = Color(0xffFE8416D);

  //region Sending code to number......

  Future<void> verifyPhoneCode() async{
    showAlertDialog();
    await _auth.verifyPhoneNumber(
        phoneNumber: phonenumber,
        verificationCompleted: _onVerificationCompleted,
        verificationFailed: _onVerificationFailed,
        codeSent: _onCodeSent,
        codeAutoRetrievalTimeout: _onCodeTimeout
    );
  }
  _onVerificationCompleted(PhoneAuthCredential authCredential) async {
    Navigator.pop(context);
    await _auth.signInWithCredential(authCredential);
  }

  _onVerificationFailed(FirebaseAuthException exception) {
    print(exception);
    Navigator.pop(context);
    if (exception.code == 'invalid-phone-number') {
      Navigator.pop(context);
      print("The phone number entered is invalid!");
    }
  }

  _onCodeSent(String verificationID, int? forceResendingToken) async {
    setState(() {
      verificationId = verificationID;
    });
    print(forceResendingToken);
    Navigator.pop(context);
    print("code sent");
  }

  _onCodeTimeout(String timeout) {
    Navigator.pop(context);
    print(timeout);
    return null;
  }
 //endregion

  Future<void> verify() async{
    showAlertDialog();
    try{
      PhoneAuthCredential phoneAuthCredential = PhoneAuthProvider.credential(
          verificationId: verificationId, smsCode: otpControl.text.toString()
      );
      final signIn = await _auth.signInWithCredential(phoneAuthCredential);
      if(signIn.user!=null){
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (context)=>HomeScreen()));
      }else{
        Navigator.pop(context);
        print('auth failed...');
      }
    }on FirebaseAuthException catch(e){
      Navigator.pop(context);
      print(e);
    }
  }

  void showAlertDialog(){
    showDialog(
        context: context,
        builder: (context){
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
                  SizedBox(height: 13,),
                  Text('Please Wait...',style: TextStyle(
                      color: Colors.black,
                      fontFamily: 'Poppins',
                  ),)
                ],
              ),
            ),
          );
        }
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration.zero,() async{
      verifyPhoneCode();
    });
  }

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
                        controller: otpControl,
                        onChanged:(String? changed){
                          if(changed!.length==6){
                            setState(() {
                              verifyPhoneCode();
                            });
                          }
                        },
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
                    child: RaisedButton(onPressed:() async{
                      FocusScope.of(context).unfocus();
                      showAlertDialog();
                      // verify();
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
