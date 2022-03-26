import 'dart:convert';
import 'package:cakey/drawermenu/DrawerHome.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:http/http.dart' as http;

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
        codeAutoRetrievalTimeout: _onCodeTimeout,
    );
  }
  _onVerificationCompleted(PhoneAuthCredential authCredential) async {
    Navigator.pop(context);
    await _auth.signInWithCredential(authCredential);
  }

  _onVerificationFailed(FirebaseAuthException exception) {
    print(exception);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Something went wrong!"),
          backgroundColor: Colors.red,
        )
    );
    if (exception.code == 'invalid-phone-number') {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Invalid phone number!"),
            backgroundColor: Colors.red,
          )
      );
      print("The phone number entered is invalid!");
    }
  }

  _onCodeSent(String verificationID, int? forceResendingToken) async {
    setState(() {
      verificationId = verificationID;
    });
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text("Code sent to $phonenumber"),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
      )
    );
    print("code sent");
  }

  _onCodeTimeout(String timeout) {
    // Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        elevation: 20,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: EdgeInsets.all(15),
        content: Text('Verification time out! try to resend code',textAlign: TextAlign.center,style: TextStyle(
            color: Colors.white,fontWeight: FontWeight.bold
        ),),
        backgroundColor: lightPink,
        behavior: SnackBarBehavior.floating,
      ),
    );
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
        setState(() {
          addUsertoDb();
        });
      }else{
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            elevation: 20,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            margin: EdgeInsets.all(15),
            content: Text('Code is incorrect! try to resend',textAlign: TextAlign.center,style: TextStyle(
                color: Colors.white,fontWeight: FontWeight.bold
            ),),
            backgroundColor: lightPink,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
        print('auth failed...');
      }
    }on FirebaseAuthException catch(e){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          elevation: 20,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          margin: EdgeInsets.all(15),
          content: Text('Code is incorrect!',textAlign: TextAlign.center,style: TextStyle(
              color: Colors.white,fontWeight: FontWeight.bold
          ),),
          backgroundColor: lightPink,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
      print(e);
    }
  }

  //Alert Dialog....
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

  //Adding user to db (API)
  Future<void> addUsertoDb() async{

    print(phonenumber);
    print(phonenumber.replaceAll("+91", ""));

    //posting the value.....
    try{
      http.Response response = await http.post(
        Uri.parse("https://cakey-database.vercel.app/api/users/validate"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(<String , dynamic>{
          "PhoneNumber": int.parse(phonenumber)
        }),
      );
      //check status code...
      if(response.statusCode==200){
        Map<String,dynamic> map = new Map<String , dynamic>.from(jsonDecode(response.body));
        print(jsonDecode(response.body));
        print(map['message']);

        //Checking status msg....
        if(map['message']=="registered Successfully"||map['message']=="Login Succeed"){
          Navigator.pop(context);
          Navigator.pop(context);
          Navigator.pop(context);
          Navigator.push(context, MaterialPageRoute(builder: (context)=>DrawerHome()));
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(map['message']),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              )
          );
        }else{
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Login failed!"),
                backgroundColor: Colors.red,
              )
          );
        }

        //Status code..
      }else{
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Something went wrong!"),
              backgroundColor: Colors.red,
            )
        );
      }
      //check network error....
    }catch(error){
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.wifi_outlined,color: Colors.white,),
                Text(" Check your connection!"),
              ],
            ),
            backgroundColor: Colors.red,
          )
      );
    }

    // {statusCode: 200, message: registered Successfully}
    // {"statusCode": 200,"message": "Login Succeed"}
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
      resizeToAvoidBottomInset: true,
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
                  Text('OTP',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,fontFamily: "Poppins"),),
                  Text("Code is sent to $phonenumber",textAlign: TextAlign.center,style: TextStyle(fontFamily: "Poppins"),),
                  SizedBox(height: 100,),
                  Container(
                    margin: EdgeInsets.only(left: 20, right: 20),
                    child: PinCodeTextField(
                        keyboardType: TextInputType.phone,
                        appContext: context,
                        length: 6,
                        controller: otpControl,
                        onChanged:(String? changed){
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
                  Text("Don't recieve code?",textAlign: TextAlign.center,
                  style: TextStyle(fontFamily: "Poppins"),
                  ),
                  TextButton(
                      onPressed: (){
                        setState(() {
                          verifyPhoneCode();
                        });
                      },
                      child: Text("Request Again",textAlign: TextAlign.center,style: TextStyle(
                          decoration: TextDecoration.underline,color: Colors.orange,
                          fontWeight: FontWeight.bold,fontFamily: "Poppins"
                      ),),
                  ),
                  SizedBox(height: 100,),
                  Container(
                    height: 55,
                    width: 175,
                    child: RaisedButton(onPressed:() async{
                      FocusScope.of(context).unfocus();
                      if(otpControl.text.isEmpty||otpControl.text.length<6){
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            elevation: 20,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            margin: EdgeInsets.all(15),
                            content: Text('Code is incorrect!',textAlign: TextAlign.center,style: TextStyle(
                                color: Colors.white,fontWeight: FontWeight.bold
                            ),),
                            backgroundColor: lightPink,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }else{
                        verify();
                      }
                    },
                      child:Text("DONE",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontFamily: "Poppins"),),
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