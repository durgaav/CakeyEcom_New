import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PhoneDialog{

  void showPhoneDialog(BuildContext context , String phn1 , String phn2 , [bool isWhatsapp = false]){
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
                        launchWhatsapp(context, phn1);
                      },
                      child: Text("$phn1")
                  ),
                  PopupMenuItem(
                      onTap: (){
                        !isWhatsapp?
                        launchPhone(context, phn2):
                        launchWhatsapp(context, phn2);
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

  void launchWhatsapp(BuildContext context , String num) async{
    print('whatsapp');
    String whatsapp = num;
    var whatsappURl_android = "whatsapp://send?phone="+whatsapp+"&text=hello";
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
                  child: RaisedButton(
                      onPressed: ()=>Navigator.of(context).pop(),
                      child: Text("Close" , style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.5,
                      ),),
                      color: Colors.pink,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)
                      ),
                  ),
                )
              ],
            ),
          ),
        )
    );
  }
}