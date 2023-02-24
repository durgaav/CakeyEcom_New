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
  String routeName = "";
  ChatsList({required this.routeName});
  @override
  State<ChatsList> createState() => _ChatsListState(routeName:routeName);
}

class _ChatsListState extends State<ChatsList> {
  String routeName = "";
  _ChatsListState({required this.routeName});

  List chatList = [];
  List filterList = [];
  List onLineMembers = [];
  List currentUserConvList = [];
  late Timer timer;
  String reciverName = "";
  bool online = false;
  bool showAppBarField = false;
  var searchCtrl = TextEditingController();

  //region LOGICS ***
  
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

  Future<void> getConversation() async {

    MyDialogs().showTheLoader(context);

    var pr = await SharedPreferences.getInstance();
    var phone = pr.getString("phoneNumber")??'';
    var tok = pr.getString("authToken")??'';

    try{

      http.Response response = await http.get(
          Uri.parse("${API_URL}api/conv/byId/${int.parse(phone.toString().replaceAll("+", ""))}"),
          headers: {"Authorization": "$tok"},
      );

      print(response.body);

      var data = jsonDecode(response.body);

      if(response.statusCode==200){
        setState(() {
          currentUserConvList = data;

          if(routeName=="support"){
            getHelpDeskMembers();
            // timer = Timer.periodic(Duration(seconds: 3), (timer) {
            //   getHelpDeskMembers();
            // });
          }else{
            getVendors();
            // timer = Timer.periodic(Duration(seconds: 3), (timer) {
            //   getVendorCustomerConversation();
            // });
          }

        });
        Navigator.pop(context);
      }else{
        Navigator.pop(context);
      }

      // if(data!=null && data.isNotEmpty){
      //   List bodyData = data;
      //   var wantedData = bodyData.where((e)=>e['Members'].contains(receiverEmail) && e['Members'].contains(int.parse(phone.toString().replaceAll("+", "")).toString())).toList();
      //   print(wantedData);
      //   wantedData.isNotEmpty?
      //   Navigator.push(context,MaterialPageRoute(builder: (builder)=>ChatScreen(
      //       receiverEmail , wantedData[0]['_id'] , reciverName , online: online,
      //   ))):null;
      // }else{
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(content: Text("Unable to get messages..."))
      //   );
      // }

    }catch(e){
      Navigator.pop(context);
    }

  }

  Future<void> getVendors() async {

    var pr = await SharedPreferences.getInstance();
    var phone = pr.getString("phoneNumber")??'';
    var tok = pr.getString("authToken")??'';
    List finalList = [];

    http.Response response = await http.get(Uri.parse("${API_URL}api/vendors/list"),
        headers:{'Authorization': '$tok'}
    );

    List map = jsonDecode(response.body);

    if(response.statusCode==200){
      if(map.isNotEmpty){
        setState(() {

          map.forEach((element) {
            //print(element);
            if(currentUserConvList.any((e)=>e['Members'].contains(element['Email'].toString()))){
              finalList.add({
                "Email":element['Email'],
                "Name":element['VendorName']
              });
            }
          });

          print("Final $finalList");

          chatList = finalList.toSet().toList();
        });
      }
    }else{

    }



    try{

    }catch(e){

    }

  }


  //endregion

  Future<void> getHelpDeskMembers() async {

    var pr = await SharedPreferences.getInstance();
    List actMem = jsonDecode(pr.getString("socketActiveMembers")??"[]");

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
      //getHelpDeskMembers();
      getConversation();
      timer = Timer.periodic(Duration(seconds: 2), (timer) async {
        var pr = await SharedPreferences.getInstance();
        var getMsg = jsonDecode(pr.getString('socketMessages')??"{}");
        var getTyping = jsonDecode(pr.getString('socketTyping')??"{}");
        var getUsers = jsonDecode(pr.getString('socketActiveMembers')??"[]");

        List user = [];

        if(getUsers.isNotEmpty){
          user = getUsers;
        }

        setState(() {
          onLineMembers = user;
        });
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

    if(searchCtrl.text.isNotEmpty){
      setState(() {
        filterList = chatList.where((element) => element['Email'].toString().toLowerCase().contains(searchCtrl.text.toLowerCase())||element['Name'].toString().toLowerCase().contains(searchCtrl.text.toLowerCase())).toList();
      });
    }else{
      setState(() {
        filterList = chatList;
      });
    }

    //{"_id":"6375f622ba42a4ce0746e814","Name":"karthick raja","Mobilenumber":9750877583,
    // "Email":"karthickdurai583@gmail.com","Password":"1UbQlofk8z",
    // "TypeOfUser":"Helpdesk C","Created_On":"17-11-2022 02:21 PM","Id":"CKYCUS-4","__v":0},

    return SafeArea(child:Scaffold(
      backgroundColor:Colors.white,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor:lightGrey,
        leading: Container(
          margin: EdgeInsets.all(12),
          child: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              height: 30,
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(7)),
              alignment: Alignment.center,
              child: Icon(
                Icons.chevron_left,
                size: 30,
                color:lightPink,
              ),
            ),
          ),
        ),
        title:
        showAppBarField?
        TextField(
          controller:searchCtrl,
          onChanged: (e){
            setState(() {
              searchCtrl.text;
            });
          },
          decoration:InputDecoration(
            hintText:"Search...",
            isDense:true,
            contentPadding:EdgeInsets.zero,
            border:InputBorder.none,
          ),
        ):
        Text(
          "CHATS",
          style: TextStyle(color: darkBlue, fontFamily: "Poppins", fontSize: 18),
        ),
        actions:[
          showAppBarField?
          IconButton(onPressed: (){
            setState(() {
              showAppBarField = !showAppBarField;
              searchCtrl.text = "";
            });
          }, icon:Icon(Icons.cancel,color:Colors.pink,)):
          IconButton(onPressed: (){
            setState(() {
              showAppBarField = !showAppBarField;
            });
          }, icon:Icon(Icons.search,color:Colors.pink,))
        ],
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
        child:
        filterList.isEmpty?
        Center(
          child:Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.chat_rounded,color:Colors.black,),
              SizedBox(width:8,),
              Text("NO DATA FOUND!",style: TextStyle(
                  fontWeight:FontWeight.bold
              ),)
            ],
          ),
        ):
        ListView.separated(
          itemCount:filterList.length,
          shrinkWrap:true,
          physics:BouncingScrollPhysics(),
          itemBuilder:( c , i ){
            return InkWell(
              splashColor:Colors.transparent,
              onTap: (){
                setState(() {
                  reciverName = filterList[i]['Name'].toString();
                  if(onLineMembers.any((element) => element['userId'].toString().toLowerCase()==filterList[i]['Email'].toString().toLowerCase())){
                    online = true;
                  }else{
                    online = false;
                  }
                });
                Functions().handleChatWithVendors(context, filterList[i]['Email'].toString(), filterList[i]['Name'].toString());
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
                            height:52,
                            width:52,
                            decoration:BoxDecoration(
                              shape:BoxShape.circle,
                                color:Colors.pink.withOpacity(0.8),
                              border: Border.all(
                                 color:Colors.white,
                                 width:0.5
                              )
                            ),
                            child:Center(
                              child:Text(filterList[i]['Name'].toString()[0].toUpperCase(),style:TextStyle(
                                  fontSize:media.height*0.035,
                                  fontWeight:FontWeight.bold,
                                  color:Colors.white
                              ),),
                            ),
                          ),
                          onLineMembers.any((element) => element['userId'].toString().toLowerCase()==filterList[i]['Email'].toString().toLowerCase())?
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
                                height:0,
                                width:0,
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
                        Text("${filterList[i]['Name']}" ,style:TextStyle(
                          fontFamily:"Poppins",
                          color:Colors.black,
                          fontSize:16,
                          fontWeight:FontWeight.bold
                        ),),
                        Text("${filterList[i]['Email']}" ,style:TextStyle(
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
