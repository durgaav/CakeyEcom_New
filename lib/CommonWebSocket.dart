import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class CommonWebSocket{

  //init socket
  IO.Socket? socket;

  initSocket(BuildContext context) {

    //let data = socket?.emit("adduser", { Email: token?.result?.Email, type: token?.result?.TypeOfUser, _id: token?.result?._id, Id: token?.result?.Id, Name: token?.result?.Name })

    print("Socket connecting...");
    //AlertsAndColors().showLoader(context);
    //IO.Socket socket = IO.io('https://cakey-backend.herokuapp.com');
    socket = IO.io("http://sugitechnologies.com:3001", <String, dynamic>{
      'autoConnect': true,
      'transports': ['websocket'],
    });
    socket!.connect();
    socket!.onConnect((e) {
      print('Connection established. $e');
      //Navigator.pop(context);
    });
    socket!.onDisconnect((e){
      print('Connection Disconnected $e');
      //Navigator.pop(context);
    });
    socket!.onConnectError((err) {
      print(err);
      //Navigator.pop(context);
    });
    socket!.onError((err) => print(err));

    //socket?.emit("adduser", { Email: token?.result?.Email, type: "helpDeskv" })

    // socket.on('getMessage', (newMessage) {
    //   //chatList.add(MessageModel.fromJson(data));
    //   print(newMessage);
    // });
    //
    // socket.emit("adduser", { "Email": "surya@mindmade.in", "type": "vendor" });
  }

  IO.Socket? getSocket()=>socket;

}