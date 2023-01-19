import 'dart:async';
import 'dart:convert';

import 'package:cakey/MyDialogs.dart';
import 'package:cakey/functions.dart';
import 'package:cakey/screens/ChatScreen.dart';
import 'package:cakey/screens/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ChatsList extends StatefulWidget {
  const ChatsList({Key? key}) : super(key: key);

  @override
  State<ChatsList> createState() => _ChatsListState();
}

class _ChatsListState extends State<ChatsList> {

  List chatList = [];
  List onLineMembers = [];
  late Timer timer;
  String reciverName = "";
  bool online = false;

  //region LOGICS ***

  //create conversation
  Future<void> createConversation(String receiverId) async {

    var pr = await SharedPreferences.getInstance();
    var phone = pr.getString("phoneNumber")??'';
    var tok = pr.getString("authToken")??'';

    MyDialogs().showTheLoader(context);

    try{

      http.Response response = await http.post(
        Uri.parse("${API_URL}api/conv/add"),
        headers: {"Authorization": "$tok"},
        body:jsonEncode(<String , dynamic>{
          "senderId":int.parse(phone.toString().replaceAll("+", "")),
          "receiverId":receiverId,
          "Created_By":int.parse(phone.toString().replaceAll("+", "")),
        })
      );

      print(response.body);

      var data = jsonDecode(response.body);

      if(response.statusCode==200){
        if(data['statusCode']==400){
          print("400");
          getConversationByReciverId(receiverId , phone.toString().replaceAll("+", ""));
        }else{
          getConversation(receiverId);
        }
        Navigator.pop(context);
      }else{
        Navigator.pop(context);
      }

    }catch(e){
      Navigator.pop(context);
    }

  }

  Future<void> getConversationByReciverId(String reciver , String num) async{

    var pr = await SharedPreferences.getInstance();
    var phone = pr.getString("phoneNumber")??'';
    var tok = pr.getString("authToken")??'';

    print(num);

    try{
      print(" Dat 1");
      http.Response response = await http.get(
        Uri.parse("${API_URL}api/conv/byId/${reciver}"),
        headers: {"Authorization": "$tok"},
      );

      var data = jsonDecode(response.body);
      print("The data $data");

      if(data!=null && data.isNotEmpty){
        List bodyData = data;
        var wantedData = bodyData.where((e)=>e['Members'].contains(reciver.toString()) && e['Members'].contains(num)).toList();
        print(wantedData);
        wantedData.isNotEmpty?
        Navigator.push(context,MaterialPageRoute(builder: (builder)=>ChatScreen(
            reciver , wantedData[0]['_id'] , reciverName , online: online,
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

  Future<void> getConversation(String receiverEmail) async {

    var pr = await SharedPreferences.getInstance();
    var phone = pr.getString("phoneNumber")??'';
    var tok = pr.getString("authToken")??'';

    print(receiverEmail);

    try{

      http.Response response = await http.get(
          Uri.parse("${API_URL}api/conv/byId/${int.parse(phone.toString().replaceAll("+", ""))}"),
          headers: {"Authorization": "$tok"},
      );

      print(response.body);

      var data = jsonDecode(response.body);

      if(data!=null && data.isNotEmpty){
        List bodyData = data;
        var wantedData = bodyData.where((e)=>e['Members'].contains(receiverEmail) && e['Members'].contains(int.parse(phone.toString().replaceAll("+", "")).toString())).toList();
        print(wantedData);
        wantedData.isNotEmpty?
        Navigator.push(context,MaterialPageRoute(builder: (builder)=>ChatScreen(
            receiverEmail , wantedData[0]['_id'] , reciverName , online: online,
        ))):null;
      }else{
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Unable to get messages..."))
        );
      }

    }catch(e){

    }

  }

  //endregion

  Future<void> getChatsList() async {

    var pr = await SharedPreferences.getInstance();
    List actMem = jsonDecode(pr.getString("socketActiveMembers")??"[]");

    setState(() {
      onLineMembers = actMem.where((e)=>e['type'].toString().toLowerCase()=="helpdesk c").toList();
    });

    // print(onLineMembers);

    try{

      http.Response response = await http.get(Uri.parse("${API_URL}api/internalUsers/helpdeskC/list"),);

      //print(response.body);

      var map = jsonDecode(response.body);

      if(map['result']!=null && map['result'].isNotEmpty){
        setState(() {
          chatList = map['result'];
        });
      }

    }catch(e){

    }

  }

  @override
  void dispose() {
    // TODO: implement dispose
    timer.cancel();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    Future.delayed(Duration.zero , () async {
      getChatsList();
      timer = Timer.periodic(Duration(seconds: 3), (timer) {
        getChatsList();
      });
    });
    super.initState();
  }

  Color lightGrey = Color(0xffF5F5F5);
  Color darkBlue = Color(0xffF213959);
  Color lightPink = Color(0xffFE8416D);

  @override
  Widget build(BuildContext context) {

    var media = MediaQuery.of(context).size;

    //{"_id":"6375f622ba42a4ce0746e814","Name":"karthick raja","Mobilenumber":9750877583,
    // "Email":"karthickdurai583@gmail.com","Password":"1UbQlofk8z",
    // "TypeOfUser":"Helpdesk C","Created_On":"17-11-2022 02:21 PM","Id":"CKYCUS-4","__v":0},

    return SafeArea(child:Scaffold(
      backgroundColor:Colors.white,
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(50),
          child:SafeArea(
            child: Container(
              padding: EdgeInsets.only(left: 15),
              height: 50,
              color:lightGrey,
              child:Row(
                children: [
                  Container(
                    // margin: const EdgeInsets.only(top: 10,bottom: 15),
                    child: InkWell(
                      onTap: (){
                        Navigator.pop(context);
                      },
                      child: Container(
                        height: 30,
                        decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(7)
                        ),
                        alignment: Alignment.center,
                        child: Icon(Icons.chevron_left,size: 30,color: lightPink,),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 15),
                    child: Text(
                      'SUPPORT',
                      style: TextStyle(
                          color: darkBlue,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
          )
      ),
      body:Container(
        height:media.height,
        width:media.width,
        decoration:BoxDecoration(
          image:DecorationImage(
            image:AssetImage("assets/images/splash.png"),
            fit:BoxFit.cover
          )
        ),
        child:ListView.separated(
          itemCount:chatList.length,
          shrinkWrap:true,
          physics:BouncingScrollPhysics(),
          itemBuilder:( c , i ){
            return InkWell(
              splashColor:Colors.transparent,
              onTap: (){
                setState(() {
                  reciverName = chatList[i]['Name'].toString();
                  if(onLineMembers.any((element) => element['userId'].toString().toLowerCase()==chatList[i]['Email'].toString().toLowerCase())){
                    online = true;
                  }else{
                    online = false;
                  }
                });
                Functions().handleChatWithVendors(context, chatList[i]['Email'].toString(), chatList[i]['Name'].toString());
                //createConversation(chatList[i]['Email'].toString());
                //Navigator.push(context, MaterialPageRoute(builder: (builder)=>ChatScreen()));
              },
              child: Container(
                padding:EdgeInsets.all(8),
                child:Row(
                  children: [
                    Container(
                      child:Stack(
                        children: [
                          Container(
                            height:62,
                            width:62,
                            decoration:BoxDecoration(
                              shape:BoxShape.circle,
                              color:Colors.grey[400],
                              border: Border.all(
                                 color:Colors.white,
                                 width:0.5
                              )
                            ),
                            child:Icon(Icons.person ,color:Colors.white ,size:35,),
                          ),
                          onLineMembers.any((element) => element['userId'].toString().toLowerCase()==chatList[i]['Email'].toString().toLowerCase())?
                          Positioned(
                            bottom:3,
                            right:3,
                            child: Container(
                            height:15,
                            width:15,
                            decoration:BoxDecoration(
                                shape:BoxShape.circle,
                                color:Colors.green,
                                border: Border.all(
                                  color:Colors.white,
                                  width:0.5
                                )
                            ),
                          )):
                          Positioned(
                              bottom:3,
                              right:3,
                              child: Container(
                                height:15,
                                width:15,
                                decoration:BoxDecoration(
                                    shape:BoxShape.circle,
                                    color:Colors.blueGrey,
                                    border: Border.all(
                                        color:Colors.white,
                                        width:0.5
                                    )
                                ),
                              ))
                        ],
                      ),
                    ),
                    SizedBox(width:8,),
                    Expanded(child: Column(
                      crossAxisAlignment:CrossAxisAlignment.start,
                      children: [
                        Text("${chatList[i]['Name']}" ,style:TextStyle(
                          fontFamily:"Poppins",
                          color:Colors.black,
                          fontSize:16,
                          fontWeight:FontWeight.bold
                        ),),
                        Text("${chatList[i]['Email']}" ,style:TextStyle(
                            fontFamily:"Poppins",
                            color:Colors.black,
                            fontSize:13,
                        ),),
                      ],
                    )),
                  ],
                ),
              ),
            );
          },
          separatorBuilder:(d , j){
            return Container(
              height:0.4,
              color:Colors.black,
            );
          },
        ),
      ),
    ));
  }
}
