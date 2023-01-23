import 'dart:convert';
import 'dart:io';
import 'package:cakey/DrawerScreens/HomeScreen.dart';
import 'package:cakey/functions.dart';
import 'package:cakey/screens/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../Dialogs.dart';

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
  FirebaseAuth _auth = FirebaseAuth.instance;
  Color lightPink = Color(0xffFE8416D);
  int token = 0 ;

  bool connected = false;

  //region Sending code to number......
  Future<void> verifyPhoneCode() async{
    showAlertDialog();

    try{
      await _auth.verifyPhoneNumber(
        phoneNumber: phonenumber,
        verificationCompleted: _onVerificationCompleted,
        verificationFailed: _onVerificationFailed,
        codeSent: _onCodeSent,
        codeAutoRetrievalTimeout: _onCodeTimeout,
      );
    }catch(e){
      checkNetwork();
    }


  }

  _onVerificationCompleted(PhoneAuthCredential authCredential) async {

      print('Auth code : ${authCredential.smsCode}');
      
      setState(() {
        otpControl.text = authCredential.smsCode!;
      });

      if(authCredential.smsCode != null){
        await _auth.signInWithCredential(authCredential).then((value){

          print(value);

          setState(() {
            addUsertoDb();
          });

        }).catchError((error){
          checkNetwork();
          Navigator.pop(context);
        });
      }


  }

  _onVerificationFailed(FirebaseAuthException exception) async{
    print(" Firebase error : $exception");
    // Navigator.pop(context);
    Functions().showSnackMsg(context, "$exception", true);
    if (exception.code == 'invalid-phone-number') {
      Navigator.pop(context);
      Functions().showSnackMsg(context, "Invalid phone number!", true);
      print("The phone number entered is invalid!");
    }
  }

  _onCodeSent(String verificationID, int? forceResendingToken) async {
    
    setState(() {
      verificationId = verificationID;
      token = forceResendingToken!;
    });

    Navigator.pop(context);

    // initSmsListener();
    Functions().showSnackMsg(context, "OTP code is sent to $phonenumber", true);
    print("code sent");
  }

  _onCodeTimeout(String timeout) async{
    setState(() {
      verificationId = timeout;
    });
    print("time out : $timeout");
    return null;
  }

 //endregion


  @override
  void dispose() {
    super.dispose();
  }

  //Code verify.........
  Future<void> verify(String verId , String otpCode) async{

    print(otpControl.text);

    PhoneAuthCredential phoneAuthCredential = PhoneAuthProvider.credential(
        verificationId: verId,
        smsCode: otpCode,
    );


    await _auth.signInWithCredential(phoneAuthCredential).then((value){

      setState(() {
        addUsertoDb();
      });

    }).catchError((error){
      // Navigator.pop(context);
      Functions().showSnackMsg(context, "$error", true);
    });

  }

  //Alert Dialog....
  void showAlertDialog(){
    showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)
            ),
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
    print('add phone.....');
    var prefs = await SharedPreferences.getInstance();
    String num = phonenumber.replaceAll("+", "");
    //posting the value.....
    try{
      http.Response response = await http.post(
        Uri.parse("${API_URL}api/userslogin/validate"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(<String , dynamic>{
          "PhoneNumber": int.parse(num)
        }),
      );
      //check status code...
      if(response.statusCode==200){
        var map = jsonDecode(response.body);
        //Checking msg....(reg / login)
        if(map['message'].toString().toLowerCase()=="registered successfully"){

          onTimeLogin(num);

        }else if(map['message']=="Login Succeed"){

          print(map);

          prefs.setBool("newRegUser", false);
          prefs.setString("authToken", map['token'].toString());
          prefs.setString("phoneNumber", num);

          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) => HomeScreen()
              ),
              ModalRoute.withName('/HomeScreen')
          );
        }else{
          Functions().showSnackMsg(context, "Login failed!", true);
        }
        //Status code..
      }else{
        print(response.statusCode);
        Functions().showSnackMsg(context, "Login failed!", true);
      }
      //check network error....
    }catch(error){

    }

    // {statusCode: 200, message: registered Successfully}
    // {"statusCode": 200,"message": "Login Succeed"}
  }

  //on time logged in...
  Future<void> onTimeLogin(String phonenumber) async{

    var prefs = await SharedPreferences.getInstance();

    try{

      http.Response response = await http.post(
        Uri.parse("${API_URL}api/userslogin/validate"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(<String , dynamic>{
          "PhoneNumber": int.parse(phonenumber)
        }),
      );

      var map = jsonDecode(response.body);
      print(map);

      if(response.statusCode==200){

        if(map['message']=="Login Succeed"){

          prefs.setBool("newRegUser", true);
          prefs.setString("phoneNumber", phonenumber);
          prefs.setString("authToken", map['token'].toString());

          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) => HomeScreen()
              ),
              ModalRoute.withName('/HomeScreen')
          );

        }else{
          Functions().showSnackMsg(context, "Login failed!", true);
        }

      }

    }catch(e){

    }

  }

  //network check
  void checkNetwork() async{
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('connected');
      }
    } on SocketException catch (_) {
      print('not connected');
      NetworkDialog().showNoNetworkAlert(context);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration.zero , () async{
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
                  SizedBox(height: 40,),
                  Text('OTP',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,fontFamily: "Poppins"),),
                  Text("Sent to $phonenumber",textAlign: TextAlign.center,style: TextStyle(fontFamily: "Poppins"),),
                  SizedBox(height: 100,),
                  Container(
                    margin: EdgeInsets.only(left: 20, right: 20),
                    child: PinCodeTextField(
                        enablePinAutofill: true,
                        useExternalAutoFillGroup: true,
                        keyboardType: TextInputType.phone,
                        appContext: context,
                        length: 6,
                        controller: otpControl,
                        onChanged:(String? changed){

                        },
                        pinTheme: PinTheme(
                          inactiveColor: Colors.black54,
                          activeColor: lightPink,

                          borderWidth: 1,
                          borderRadius: BorderRadius.circular(6),
                          shape:PinCodeFieldShape.box
                        ),
                    ),
                  ),
                  SizedBox(height: 50,),
                  Text("Didn't receive OTP?",textAlign: TextAlign.center,
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
                        Functions().showSnackMsg(context, "Invalid OTP Code!", true);
                      }else{
                        verify(verificationId , otpControl.text);
                      }
                    },
                      child:Text("DONE",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontFamily: "Poppins"),),
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
