import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  //colors...
  String poppins = "Poppins";
  Color darkBlue = Color(0xffF213959);
  Color lightPink = Color(0xffFE8416D);
  Color lightGrey = Color(0xffF5F5F5);

  //chat my id
  var myId = 2;

  var messageCtrl = new TextEditingController();

  List chatList = [
    {"message": 'Hi how are you', "senderId": 1, "on": "12-08-2022 10:02 AM"},
    {"message": 'Iam fine.You?', "senderId": 2, "on": "12-08-2022 10:02 AM"},
    {"message": 'Iam also fine', "senderId": 1, "on": "12-08-2022 10:02 AM"},
    {"message": 'Ohh nice', "senderId": 2, "on": "12-08-2022 10:02 AM"},
  ];

  ScrollController _scrollController = ScrollController();

  _scrollToBottom() {
    setState(() {
      _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 100,
          duration: const Duration(milliseconds: 400),
          curve: Curves.fastOutSlowIn);
    });
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
        title: Text(
          "Surya Cakes",
          style: TextStyle(color: darkBlue, fontFamily: poppins, fontSize: 14),
        ),
      ),
      body: Stack(
        children: [
          //messages
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/splash.png"),
                fit: BoxFit.cover,
              )
            ),
            child: ListView.builder(
                controller: _scrollController,
                shrinkWrap: true,
                itemCount: chatList.length,
                padding: EdgeInsets.only(bottom: 60),
                itemBuilder: (c, i) {
                  return Container(
                    padding: EdgeInsets.only(left: 14,right: 14,top: 10,bottom: 10),
                    child: Align(
                      alignment: (chatList[i]['senderId']==1?Alignment.topLeft:Alignment.topRight),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: (chatList[i]['senderId']==1?Colors.grey.shade200:Colors.red[50]),
                        ),
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: chatList[i]['senderId']==1?CrossAxisAlignment.start:CrossAxisAlignment.end,
                          children: [
                            Text(chatList[i]['message'],
                              textAlign: chatList[i]['senderId']==1?TextAlign.left:TextAlign.right,
                              style: TextStyle(fontSize: 14 , fontFamily: poppins),),
                            SizedBox(height: 4,),
                            Text(chatList[i]['on'], style: TextStyle(fontSize: 10 , fontFamily: poppins),),
                          ],
                        ),
                      ),
                    ),
                  );


                }),
          ),

          //message type and send
          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              padding: EdgeInsets.all(5),
              height: 60,
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                      child: TextField(
                    decoration: InputDecoration(
                        hintText: "Type message...",
                        hintStyle: TextStyle(fontFamily: poppins, fontSize: 14),
                        border: OutlineInputBorder(borderSide: BorderSide.none),
                        isDense: true,
                        contentPadding: EdgeInsets.all(10)),
                    controller: messageCtrl,
                  )),
                  IconButton(
                      onPressed: () {
                        if (messageCtrl.text.isNotEmpty) {
                          setState(() {
                            chatList.add(
                              {
                                "message": '${messageCtrl.text}',
                                "senderId": 1,
                                "on": "12-08-2022 10:02 AM"
                              },
                            );
                            messageCtrl.text = "";
                            _scrollToBottom();
                          });
                        }
                      },
                      icon: Icon(
                        Icons.send,
                        size: 25,
                        color: lightPink,
                      ))
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
