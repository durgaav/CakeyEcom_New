import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyDialogs{

  void showConfirmDialog(BuildContext context , String msg , function1 , function2 , [String okBtn = "OK" , String cancellBtn = "CANCEL"]){
    showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius:BorderRadius.circular(15)
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 7,),
                Text(msg , style: TextStyle(
                    color: Colors.black,
                    fontFamily: "Poppins"
                ),),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: (){
                    Navigator.pop(context);
                    function1();
                  },
                  child: Text(cancellBtn , style: TextStyle(
                      color: Colors.pink,
                      fontFamily: "Poppins"
                  ),),
              ),
              TextButton(
                onPressed: (){
                  Navigator.pop(context);
                  function2();
                },
                child: Text(okBtn , style: TextStyle(
                    color: Colors.pink,
                    fontFamily: "Poppins"
                ),),
              ),
            ],
          );
        }
    );
  }

  void showTheLoader(BuildContext context){

    Color lightPink = Color(0xffFE8416D);

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
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
                  SizedBox(
                    height: 13,
                  ),
                  Text(
                    'Please Wait...',
                    style: TextStyle(
                      color: Colors.black,
                      fontFamily: 'Poppins',
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }

}