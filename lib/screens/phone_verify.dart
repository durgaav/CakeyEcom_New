import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

//Phone Verify screen.....
class PhoneVerify extends StatefulWidget {
  const PhoneVerify({Key? key}) : super(key: key);

  @override
  State<PhoneVerify> createState() => _PhoneVerifyState();
}

class _PhoneVerifyState extends State<PhoneVerify> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20,),
              Text('LOGIN',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
              Image(
                height: 200,
                width: 200,
                image: AssetImage("assets/images/phoneverify.png"),
              ),
              Text("You'll receive a 4 digit code to \nverify next",textAlign: TextAlign.center,),
              SizedBox(height: 30,),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Phone Number',
                  prefixIcon: Icon(CupertinoIcons.phone_circle , color: Colors.black,size: 35,)
                ),
              ),
            ],
          ),
        ),
      )
    );
  }
}
