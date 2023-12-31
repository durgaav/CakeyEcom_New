import 'dart:io';
import 'package:cakey/raised_button_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PhoneDialog{

  Color lightGrey = Color(0xffF5F5F5);
  Color darkBlue = Color(0xffF213959);
  Color lightPink = Color(0xffFE8416D);

  void showModalDialog(BuildContext context){
    showDialog(
        context: context,
        barrierDismissible: false,
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

  void showPhoneDialog(BuildContext context , String phn1 , String phn2 , [bool isWhatsapp = false,String msg="hello"]){
    showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)
            ),
            title:Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                isWhatsapp?Icon(Icons.whatsapp_outlined , color: Colors.green,size: 30,):
                Icon(Icons.phone_outlined , color: Colors.blue,size: 30),
                SizedBox(width: 6,),
                Text(
                    !isWhatsapp?"Phone Helper":"Whatsapp Helper"
                ),
              ],
            ),
            content: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PopupMenuItem(
                      onTap: (){
                        !isWhatsapp?
                        launchPhone(context, phn1):
                        launchWhatsapp(context, phn1,msg);
                      },
                      child: Text("$phn1")
                  ),
                  PopupMenuItem(
                      onTap: (){
                        !isWhatsapp?
                        launchPhone(context, phn2):
                        launchWhatsapp(context, phn2,msg);
                      },
                      child: Text("$phn2")
                  ),
                ],
              ),
            ),
          );
        }
    );

  }


  void launchPhone(BuildContext context , String num) async{
    try{
      await launchUrl(Uri.parse("tel://${num}"));
    }catch(e){
      print('uri er : $e');
    }

  }

  void launchWhatsapp(BuildContext context , String num,[String msg="hello"]) async{
    print('whatsapp');
    String whatsapp = num;
    var whatsappURl_android = "whatsapp://send?phone="+whatsapp+"&text=${msg}";
    var whatappURL_ios ="https://wa.me/$whatsapp?text=${Uri.parse("hello")}";
    if(Platform.isIOS){
      // for iOS phone only
      if( await canLaunch(whatappURL_ios)){
        await launch(whatappURL_ios, forceSafariVC: false);
      }else{
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: new Text("Whatsapp not found.")));
      }
    }else{
      // android , web
      if( await canLaunch(whatsappURl_android)){
        await launch(whatsappURl_android);
      }else{
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: new Text("Whatsapp not found.")));
      }
    }
  }

}

class NetworkDialog{
  void showNoNetworkAlert(BuildContext context){
    showDialog(
        context: context,
        builder: (context)=>AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)
          ),
          content: Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.wifi_off , color: Colors.pink, size: 40,),
                SizedBox(height: 10,),
                Text("Whoops!" , style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),),
                SizedBox(height: 10,),
                Text('No Internet Connection Found!\nPlease Check Your Connection' , style: TextStyle(
                  color: Colors.grey,
                  fontSize: 13.5,
                ),
                textAlign: TextAlign.center,
                ),
                SizedBox(height: 10,),
                Container(
                  width: double.infinity,
                  height:40,
                  child: CustomRaisedButton(
                      onPressed: ()=>Navigator.of(context).pop(),
                      child: Text("Close" , style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.5,
                      ),),
                      color: Colors.pink,
                  ),
                )
              ],
            ),
          ),
        )
    );
  }
}