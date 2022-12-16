import 'package:cakey/DrawerScreens/HomeScreen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TooFarDialog{

  Future<void> showTooFarDialog(BuildContext context , String address) async{

    var pr = await SharedPreferences.getInstance();
    pr.setString("showMoreVendor", address);

    showDialog(
      context: context,
      builder: (c){
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)
          ),
          content: Text("Your delivery location is too far , please select nearby address or choose vendors from selected delivery address.",style: TextStyle(
            color: Colors.black,
            fontFamily: "Poppins",
          ),),
          actions: [
            TextButton(onPressed:(){
              Navigator.pop(context);
            }, child: Text("CANCEL",style: TextStyle(color: Colors.deepPurple),)),
            TextButton(onPressed:(){
              Navigator.pop(context);
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (c)=>HomeScreen()), (route) => false);
            }, child: Text("SHOW VENDORS",style: TextStyle(color: Colors.deepPurple),)),
          ],
        );
      }
    );

  }

}