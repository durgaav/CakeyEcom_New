import 'dart:convert';

import 'package:cakey/MyDialogs.dart';
import 'package:cakey/screens/ChatScreen.dart';
import 'package:cakey/screens/utils.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Functions{

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

}