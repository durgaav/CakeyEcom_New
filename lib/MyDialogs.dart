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

}