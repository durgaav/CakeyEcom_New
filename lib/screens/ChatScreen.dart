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
    {
      "message":'Hi how are you',
      "senderId":1,
      "on":"12-08-2022 10:02 AM"
    },
    {
      "message":'Iam fine.You?',
      "senderId":2,
      "on":"12-08-2022 10:02 AM"
    },
    {
      "message":'Iam also fine',
      "senderId":1,
      "on":"12-08-2022 10:02 AM"
    },
    {
      "message":'Ohh nice',
      "senderId":2,
      "on":"12-08-2022 10:02 AM"
    },
  ];

  ScrollController _scrollController = ScrollController();

  _scrollToBottom() {

    setState((){
      _scrollController.animateTo(
          _scrollController.position.maxScrollExtent+60,
          duration: const Duration(milliseconds: 400),
          curve: Curves.fastOutSlowIn);
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  borderRadius: BorderRadius.circular(7)
              ),
              alignment: Alignment.center,
              child: Icon(Icons.chevron_left,size: 30,color: lightPink,),
            ),
          ),
        ),
        title: Text("Surya Cakes" ,style: TextStyle(
          color: darkBlue,fontFamily: poppins , fontSize: 14
        ),),
      ),
      body: Stack(
        children: [

          //messages
          Container(
            padding: EdgeInsets.only(bottom: 60),
            child: ListView.builder(
                controller: _scrollController,
                shrinkWrap: true,
                itemCount: chatList.length,
                itemBuilder: (c,i){
                  return chatList[i]['senderId']==myId?
                  Container(
                    alignment: Alignment.centerRight,
                    margin: EdgeInsets.all(8),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(0),
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                        bottomLeft: Radius.circular(15)
                      )
                        
                    ),
                    child: Text(chatList[i]["message"].toString()),
                  ):Container(
                    margin: EdgeInsets.all(8),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(15),
                            topLeft: Radius.circular(15),
                            topRight: Radius.circular(15),
                            bottomLeft: Radius.circular(0)
                        )
                    ),
                    child: Text(chatList[i]["message"]),
                  );
                }
            ),
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
                  Expanded(child: TextField(
                    decoration: InputDecoration(
                        hintText: "Type message",
                        hintStyle: TextStyle(
                            fontFamily: poppins,
                            fontSize: 14
                        ),
                        border: OutlineInputBorder(
                            borderSide: BorderSide.none
                        ),
                        isDense: true,
                        contentPadding: EdgeInsets.all(10)
                    ),
                    controller: messageCtrl,
                  )),
                  IconButton(
                      onPressed: (){
                        setState((){
                          chatList.add({
                            "message":'${messageCtrl.text}',
                            "senderId":2,
                            "on":"12-08-2022 10:02 AM"
                          },);
                          messageCtrl.text = "";
                          _scrollToBottom();
                        });
                      },
                      icon: Icon(Icons.send ,size: 25, color: lightPink,)
                  )
                ],
              ),
            ),
          )

        ],
      ),
    );
  }
}
