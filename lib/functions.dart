import 'dart:convert';
import 'dart:io';

import 'package:cakey/DrawerScreens/HomeScreen.dart';
import 'package:cakey/MyDialogs.dart';
import 'package:cakey/screens/ChatScreen.dart';
import 'package:cakey/screens/utils.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Functions{

  Color lightGrey = Color(0xffF5F5F5);
  Color darkBlue = Color(0xffF213959);
  Color lightPink = Color(0xffFE8416D);

  Future<void> handleChatWithVendors(BuildContext context,String receiverId , String name) async {

    var pr = await SharedPreferences.getInstance();
    var phone = pr.getString("phoneNumber")??'';
    var tok = pr.getString("authToken")??'';

    MyDialogs().showTheLoader(context);

    String number = int.parse(phone.replaceAll("+", "")).toString();

    try{

      var headers = {
        'Authorization': '$tok',
        'Content-Type': 'application/json'
      };
      var request = http.Request('POST', Uri.parse('${API_URL}api/conv/add'));
      request.body = json.encode({
        "senderId":number,
        "receiverId":receiverId,
        "Created_By":number
      });
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      var data = jsonDecode(await response.stream.bytesToString());

      if(response.statusCode==200){
        if(data['statusCode']==400){
          print("400");
          getConversationByReciverId(context,receiverId , number , name);
        }else{
          getConversation(context,receiverId,name);
        }
        Navigator.pop(context);
      }else{
        Navigator.pop(context);
      }

    }catch(e){
      Navigator.pop(context);
    }

  }

  Future<void> getConversationByReciverId(BuildContext context , String reciver , var num , String name) async{

    var pr = await SharedPreferences.getInstance();
    var phone = pr.getString("phoneNumber")??'';
    var tok = pr.getString("authToken")??'';

    print(num);

    try{
      print(" Dat 1");
      http.Response response = await http.get(
        Uri.parse("${API_URL}api/conv/byId/$reciver"),
        headers: {"Authorization": "$tok"},
      );

      var data = jsonDecode(response.body);

      print("The data $num");

      if(data!=null && data.isNotEmpty){
        List bodyData = data;
        var wantedData = bodyData.where((e)=>e['Members'].toList().contains(reciver) && e['Members'].toList().contains(num)).toList();
        print(wantedData);
        wantedData.isNotEmpty?
        Navigator.push(context,MaterialPageRoute(builder: (builder)=>ChatScreen(
          reciver , wantedData[0]['_id'] , name , online: true,
        ))):null;
      }else{
        print(data);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Unable to get messages..."))
        );
      }

    }catch(e){
      print(e);
    }

  }

  Future<void> getConversation(BuildContext context , String receiverEmail , String name) async {

    var pr = await SharedPreferences.getInstance();
    var phone = pr.getString("phoneNumber")??'';
    var tok = pr.getString("authToken")??'';

    print(receiverEmail);

    String number = int.parse(phone.replaceAll("+", "")).toString();

    try{

      http.Response response = await http.get(
        Uri.parse("${API_URL}api/conv/byId/${number}"),
        headers: {"Authorization": "$tok"},
      );

      print(response.body);

      var data = jsonDecode(response.body);

      if(data!=null && data.isNotEmpty){
        List bodyData = data;
        var wantedData = bodyData.where((e)=>e['Members'].toList().contains(receiverEmail) && e['Members'].toList().contains(number)).toList();
        print(wantedData);
        wantedData.isNotEmpty?
        Navigator.push(context,MaterialPageRoute(builder: (builder)=>ChatScreen(
          receiverEmail , wantedData[0]['_id'] , name , online: true,
        ))):null;
      }else{
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Unable to get messages..."))
        );
      }

    }catch(e){

    }

  }

  Future<void> deleteCouponCode(String couponID) async {

    try{

      var res = await http.delete(
        Uri.parse("${API_URL}api/couponCode/delete/$couponID"),
      );

      var data = res.body;

      if(res.statusCode==200){
        print(data);
      }else{
        print(data);
      }

    }catch(e){
      print("Delete the coupon code $e");
    }

  }

  Future<void> deleteNotification(String id) async {

    try{

      var res = await http.delete(
        Uri.parse("${API_URL}api/users/notification/removeOne/$id"),
      );

      var data = res.body;

      if(res.statusCode==200){
        print(data);
      }else{
        print(data);
      }

    }catch(e){
      print("Delete the noti $e");
    }

  }

  //push notifications
  Future<void> sendThePushMsg(String msg , String title , String noId) async {

    try{

      var headers = {
        'Authorization': 'Bearer $FCM_TOK',
        'Content-Type': 'application/json'
      };
      var request = http.Request('POST', Uri.parse('https://fcm.googleapis.com/fcm/send'));
      request.body = json.encode({
        "registration_ids": [noId],
        "notification": {
          "title": title,
          "body":msg
        },
        "data": {
          "msgId": "msg_12342"
        }
      });
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      print(response.statusCode);

      if (response.statusCode == 200) {
        print(await response.stream.bytesToString());
      }
      else {
        print(response.reasonPhrase);
      }
    }catch(e){

    }

  }

  void showOrderCompleteSheet(BuildContext context){
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(20),
              topLeft: Radius.circular(20),
            )),
        context: context,
        isDismissible:false,
        builder: (context) {
          return Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 15,
                ),
                Container(
                  height: 150,
                  width: 150,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                          image: AssetImage('assets/images/chefdoll.jpg'),
                          fit: BoxFit.cover)),
                ),
                SizedBox(
                  height: 15,
                ),
                Text('THANK YOU',
                    style: TextStyle(
                        color: Colors.deepPurple,
                        fontFamily: "Poppins",
                        fontSize: 23,
                        fontWeight: FontWeight.bold)),
                Text('for your order',
                    style: TextStyle(
                        color: Colors.deepPurple,
                        fontFamily: "Poppins",
                        fontSize: 13,
                        fontWeight: FontWeight.bold)),
                SizedBox(
                  height: 15,
                ),
                Center(
                  child: Text(
                    'Your order is now being processed.'
                        '\nWe will let you know once the order is picked \nfrom the outlet.',
                    style: TextStyle(
                        color: Colors.grey,
                        fontFamily: "Poppins",
                        fontSize: 13,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => HomeScreen()),
                        ModalRoute.withName('/HomeScreen')
                    );
                  },
                  child: Center(
                      child: Text(
                        'BACK TO HOME',
                        style: TextStyle(
                            color: lightPink,
                            fontFamily: "Poppins",
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline
                        ),
                        textAlign: TextAlign.center,
                      )),
                ),
              ],
            ),
          );
        });
  }

  void showSnackMsg(BuildContext context , String msg , bool error){
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          Icon(Icons.info,color:Colors.white,),
          SizedBox(width:7,),
          Expanded(
            child: Text(msg,style:TextStyle(
              fontFamily:"Poppins",
            ),),
          ),
        ],),
      backgroundColor:Colors.grey[800],
      behavior:SnackBarBehavior.floating,
      )
    );
  }

  Future<Map> getUserData() async {
    Map data = {};

    var prefs = await SharedPreferences.getInstance();
    var phoneNumber = prefs.getString('phoneNumber')??"";
    var authToken = prefs.getString('authToken')??"";

    try{
      //http://sugitechnologies.com/cakey/ http://sugitechnologies.com/cakey/
      http.Response response = await http.get(Uri.parse("${API_URL}api/users/list/${int.parse(phoneNumber)}"),
          headers: {"Authorization":authToken}
      );

      List myList = jsonDecode(response.body);

      if(response.statusCode==200){
        //UserName _id Id

        data = myList[0];

      }else{

      }
    }catch(e){

    }


    return data;
  }

  Future<Map> handleOrderCalculations(String orderType , Map<String , dynamic> map) async {

    Map data = {};

    print("given map $map");

    try{

      http.Response response = await http.post(
        Uri.parse("${API_URL}api/orders/invoiceCalculation/$orderType"),
        headers:{'Content-Type': 'application/json'},
        body:jsonEncode(map)
      );

      print("Final calu..... ${response.body}");

      data = jsonDecode(response.body);

      if(response.statusCode==200){

      }else{

      }

    }catch(e){

    }


    return data;
  }

  double getFileSizeInMB(String filePath) {
    final file = File(filePath);
    int sizeInBytes = file.lengthSync();
    double sizeInMb = sizeInBytes / (1024 * 1024);
    // if (sizeInMb > 10){
    //   // This file is Longer the
    // }
    return sizeInMb;
  }

  void showCustomisePriceAlertBox(BuildContext context , String orderId , function1 , function2){
    showDialog(
        context: context,
        builder:(c){
          return AlertDialog(
            contentPadding:EdgeInsets.zero,
            shape:RoundedRectangleBorder(
                borderRadius:BorderRadius.all(Radius.circular(15))
            ),
            content:Column(
              mainAxisSize:MainAxisSize.min,
              children: [
                ListTile(
                  title:Text("Choose option",style:TextStyle(
                      fontFamily:"Poppins"
                  ),),
                ),
                ListTile(
                  onTap: (){
                    function1();
                  },
                  title:Text("Pay now",style:TextStyle(
                      fontFamily:"Poppins"
                  ),),
                  leading:Icon(Icons.payment_outlined , color:Colors.pink,),
                ),
                ListTile(
                  onTap: (){
                    function2();
                  },
                  title:Text("Cancel order",style:TextStyle(
                      fontFamily:"Poppins"
                  ),),
                  leading:Icon(Icons.cancel , color:Colors.pink,),
                ),
              ],
            ),
          );
        }
    );
  }

}