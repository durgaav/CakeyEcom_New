import 'dart:async';
import 'dart:convert';
import 'package:cakey/DrawerScreens/Notifications.dart';
import 'package:cakey/screens/utils.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:cakey/MyDialogs.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatScreen extends StatefulWidget {
  var reciverId = "" , conversationId = "" , receiverName = "";
  bool online;
  ChatScreen(this.reciverId, this.conversationId  , this.receiverName, {required this.online});

  @override
  State<ChatScreen> createState() => _ChatScreenState(
    reciverId , conversationId , receiverName , online:online
  );
}

class _ChatScreenState extends State<ChatScreen> {

  var reciverId = "" , conversationId = "" , receiverName = "";
  bool online;
  _ChatScreenState(this.reciverId, this.conversationId  , this.receiverName, {required this.online});

  //colors...
  String poppins = "Poppins";
  Color darkBlue = Color(0xffF213959);
  Color lightPink = Color(0xffFE8416D);
  Color lightGrey = Color(0xffF5F5F5);

  //chat my id
  var myId = 2;

  var messageCtrl = new TextEditingController();
  int paginateNumber = 10;
  bool topReached = false;
  late IO.Socket socket;
  String currentUserId = "";

  String appBarStatus = "offline";

  List messageList = [];
  late Timer timer;

  ScrollController _scrollController = ScrollController();



  //region LOGICS ***


  _scrollToBottom() {
    setState(() {
      _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 100,
          duration: const Duration(milliseconds: 400),
          curve: Curves.fastOutSlowIn);
    });
  }

  //getting conversations
  Future<void> getChatConversations([bool getOldData = false]) async {

    var pr = await SharedPreferences.getInstance();
    var phone = pr.getString("phoneNumber")??'';
    var tok = pr.getString("authToken")??'';

    setState(() {
      currentUserId = "${int.parse(phone.toString().replaceAll("+", ""))}";
    });

    MyDialogs().showTheLoader(context);

    print("$conversationId");
    print("$reciverId");

    try{

      var headers = {
        'Authorization': '$tok'
      };
      var request = http.Request('GET', Uri.parse('${API_URL}api/messages/$conversationId/$paginateNumber'));

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      var data = jsonDecode(await response.stream.bytesToString());

      print("messages : $data");

      if (response.statusCode == 200) {
        setState(() {
          if(data!=null && data.isNotEmpty){
            messageList = data;
          }
        });
        Navigator.pop(context);
        getOldData==true?
        (){}:
        _scrollToBottom();
      }
      else {
        print(response.reasonPhrase);
        Navigator.pop(context);
      }

    }catch(e){
      print(e);
      Navigator.pop(context);
    }

  }

  //handle chat listner
  Future<void> handleChatListner(Map chatData) async {

    // print("Listner....... $chatData");
    //chatListener
    try{
      // var pr = await SharedPreferences.getInstance();
      // var phone = pr.getString("phoneNumber")??'';
      // var tok = pr.getString("authToken")??'';

      //var chatData = jsonDecode(pr.getString("chatListener").toString()??'{}');

      if(chatData!=null && chatData!={}){

        if(chatData['Sent_By_Id']==reciverId){
          setState(() {
            messageList.add(chatData);
            _scrollToBottom();
          });
        }

        //pr.remove("chatListener");
      }
    }catch(e){

    }

  }

  //send msg
  Future<void> sendMessage(String msg) async {

    var pr = await SharedPreferences.getInstance();
    var phone = pr.getString("phoneNumber")??'';

    try{

      socket.emit("sendMessage",{
        "Consersation_Id":conversationId,
        "Sent_By_Id":"${int.parse(phone.toString().replaceAll("+", ""))}",
        "receiverId":reciverId,
        "Message": msg.toString(),
        "Created_By":"${int.parse(phone.toString().replaceAll("+", ""))}"
      });

      setState(() {
        messageCtrl.text = "";
        socket.emit("isTyping",
            {
              "Sent_By_Id":currentUserId,
              "receiverId":reciverId,
              "typing": false,
            }
        );
        messageList.add({
          "Sent_By_Id": "${int.parse(phone.toString().replaceAll("+", ""))}",
          "Message":msg.toString(),
          "Created_By":"${int.parse(phone.toString().replaceAll("+", ""))}",
          "Created_On":simplyFormat(time: DateTime.now() , dateOnly: false),
        });
        _scrollToBottom();
      });

    }catch(e){

    }

  }

  //endregion


  @override
  void initState() {
    // TODO: implement initState
    socket = IO.io("${SOCKET_URL}", <String, dynamic>{
      'autoConnect': true,
      'transports': ['websocket'],
    });

    timer = Timer.periodic(Duration(seconds:2), (timer) async{

      var pr = await SharedPreferences.getInstance();
      var getMsg = jsonDecode(pr.getString('socketMessages')??"{}");
      var getTyping = jsonDecode(pr.getString('socketTyping')??"{}");
      var getUsers = jsonDecode(pr.getString('socketActiveMembers')??"[]");

      List user = [];

      if(getUsers.isNotEmpty){
         user = getUsers;
      }

      if(getMsg!={}){
        handleChatListner(getMsg);
      }

      if(getTyping!={} && getTyping['Sent_By_Id']==reciverId && getTyping['typing']==true){
          setState(() {
            appBarStatus = "typing...";
          });
      }else if(getTyping!={} && getTyping['Sent_By_Id']==reciverId && getTyping['typing']==false || user.any((element) => element['userId']==reciverId)){
          setState(() {
            appBarStatus = "online";
          });
      }else{
        setState(() {
          appBarStatus = "offline";
        });
      }

      pr.remove("socketMessages");
      //pr.remove("socketTyping");
      //pr.remove("socketActiveMembers");

      // socket.on("getMessage", (data){
      //   var emitedData = data;
      //   handleChatListner(data);
      //   //{Consersation_Id: 63b94547ec778dc1a89bd163, Sent_By_Id: helpdeskC@gmail.com, Message: super,
      //   // Created_By: helpdeskC@gmail.com, Created_On: 07-01-2023 04:17 PM}
      // });

      // socket.on("Typing",(data){
      //   print(data);
      //   if(data != null && data['Sent_By_Id']==reciverId && data['typing']==true){
      //     setState(() {
      //       appBarStatus = "typing...";
      //     });
      //   }else{
      //     setState(() {
      //       appBarStatus = "online";
      //     });
      //   }
      // });

      // socket.on("getUser", (data){
      //   List user = data;
      //   print("online user $data");
      //   if(user.any((element) => element['userId']==reciverId)){
      //     setState(() {
      //       online = true;
      //     });
      //   }else{
      //     setState(() {
      //       online = false;
      //     });
      //   }
      // });
    });

    Future.delayed(Duration.zero , () async {
      getChatConversations();
    });

    _scrollController.addListener(() {
      if (_scrollController.position.atEdge) {
        // Reach the top of the list
        if (_scrollController.position.pixels == 0) {
          print("scroll top");
          setState(() {
            topReached = true;
          });
        }else {
          setState(() {
            topReached = false;
          });
        }
      }else{
        setState(() {
          topReached = false;
        });
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: lightGrey,
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
                color: lightPink,
              ),
            ),
          ),
        ),
        title:Column(
          crossAxisAlignment:CrossAxisAlignment.start,
          children: [
            Text(
              "$receiverName",
              style: TextStyle(color: darkBlue, fontFamily: poppins, fontWeight: FontWeight.bold),
            ),
            Text(
              appBarStatus.toString(),
              style: TextStyle(color:lightPink, fontFamily: poppins, fontSize: 13),
            ),
          ],
        )
      ),
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/splash.png"),
              fit: BoxFit.cover,
            )
        ),
        height:MediaQuery.of(context).size.height,
        width:MediaQuery.of(context).size.width,
        child: Stack(
          alignment:Alignment.topCenter,
          children: [
            //messages
            Container(
              child:Scrollbar(
                thickness:1.5,
                thumbVisibility: true,
                child: ListView.builder(
                      controller: _scrollController,
                      shrinkWrap: true,
                      itemCount: messageList.length,
                      padding: EdgeInsets.only(bottom: 60),
                      itemBuilder: (c, i) {
                        return Container(
                          padding: EdgeInsets.only(left: 14,right: 14,top: 10,bottom: 10),
                          child: Align(
                            alignment: (messageList[i]['Sent_By_Id']==reciverId?Alignment.topLeft:Alignment.topRight),
                            child: Container(
                              constraints: BoxConstraints(
                                  maxWidth:MediaQuery.of(context).size.width*0.6
                              ),
                              decoration: BoxDecoration(
                                borderRadius:
                                messageList[i]['Sent_By_Id']==reciverId?
                                BorderRadius.only(
                                  topRight:Radius.circular(15),
                                  bottomLeft:Radius.circular(15),
                                  bottomRight:Radius.circular(15),
                                ):
                                BorderRadius.only(
                                  topLeft:Radius.circular(15),
                                  bottomLeft:Radius.circular(15),
                                  bottomRight:Radius.circular(15),
                                ),
                                color: (messageList[i]['Sent_By_Id']==reciverId?Colors.grey.shade200:Colors.red[50]),
                              ),
                              padding: EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: messageList[i]['Sent_By_Id']==reciverId?CrossAxisAlignment.start:CrossAxisAlignment.end,
                                children: [
                                  Text(messageList[i]['Message'].toString(),
                                    textAlign: messageList[i]['Sent_By_Id']==reciverId?TextAlign.left:TextAlign.right,
                                    style: TextStyle(fontSize: 14 , fontFamily: poppins),),
                                  SizedBox(height: 4,),
                                  Text(messageList[i]['Created_On'], style: TextStyle(fontSize: 10 , fontFamily: poppins),),
                                ],
                              ),
                            ),
                          ),
                        );


                      }),
              ),
            ),

            //message type and send
            Align(
              alignment: Alignment.bottomLeft,
              child: Container(
                padding: EdgeInsets.all(5),
                height: 60,
                child: Row(
                  children: [
                    Expanded(
                        child: Container(
                          padding:EdgeInsets.symmetric(vertical:5),
                          decoration:BoxDecoration(
                            borderRadius:BorderRadius.circular(20),
                            color:Colors.white,
                            border:Border.all(
                              color:Colors.grey[300]!,
                              width:1
                            )
                          ),
                          child: TextField(
                      decoration: InputDecoration(
                            hintText: "Type message...",
                            hintStyle: TextStyle(fontFamily: poppins, fontSize: 14),
                            border: OutlineInputBorder(borderSide: BorderSide.none),
                            isDense: true,
                            contentPadding: EdgeInsets.all(10)),
                      controller: messageCtrl,
                      onChanged:(e){
                          setState(() {
                            messageCtrl.text;
                          });
                          if(e.isNotEmpty){
                            socket.emit("isTyping",
                                {
                                  "Sent_By_Id":currentUserId,
                                  "receiverId":reciverId,
                                  "typing": true,
                                }
                            );
                          }else{
                            socket.emit("isTyping",
                                {
                                  "Sent_By_Id":currentUserId,
                                  "receiverId":reciverId,
                                  "typing": false,
                                }
                            );
                          }
                      },
                    ),
                        )),
                    SizedBox(width:5 ,),
                    GestureDetector(
                      onTap: (){
                        if (messageCtrl.text.isNotEmpty) {
                          sendMessage(messageCtrl.text);
                        }
                      },
                      child:Container(
                        height:50,
                        width:50,
                        alignment:Alignment.center,
                        decoration:BoxDecoration(
                          shape:BoxShape.circle,
                          color:messageCtrl.text.isNotEmpty?lightPink:Colors.grey[400]
                        ),
                        child: Icon(
                          Icons.send,
                          size: 25,
                          color:Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            topReached?
            Positioned(
             top:5,
             child: GestureDetector(
               onTap: (){
                 setState(() {
                   paginateNumber = paginateNumber + 10;
                 });
                 getChatConversations(true);
               },
               child: Container(
                alignment:Alignment.center,
                padding: EdgeInsets.symmetric(
                  vertical:10,
                  horizontal:10
                ),
                decoration:BoxDecoration(
                  color:Colors.pink,
                  border:Border.all(
                    width:0.5,
                    color:Colors.white
                  ),
                  borderRadius:BorderRadius.circular(5)
                ),
                child:Text("Load Old Messages...",style:TextStyle(
                  color:Colors.white,
                  fontFamily:"Poppins",
                  fontSize:12
                ),),
            ),
             )):Positioned(child: Container(height:0,width:0,))
          ],
        ),
      ),
    );
  }
}
