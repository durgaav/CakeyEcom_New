import 'package:cakey/DrawerScreens/CakeTypes.dart';
import 'package:cakey/DrawerScreens/CustomiseCake.dart';
import 'package:cakey/DrawerScreens/HomeScreen.dart';
import 'package:cakey/DrawerScreens/VendorsList.dart';
import 'package:cakey/screens/ChatsList.dart';
import 'package:cakey/screens/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../ContextData.dart';
import '../DrawerScreens/Notifications.dart';
import '../screens/Profile.dart';
import '../screens/WelcomeScreen.dart';

class NavDrawer extends StatefulWidget {

  String screenName;
  NavDrawer({required this.screenName});

  @override
  State<NavDrawer> createState() => _NavDrawerState(screenName: screenName);
}

class _NavDrawerState extends State<NavDrawer> {

  String screenName = "";
  _NavDrawerState({required this.screenName});

  Color lightGrey = Color(0xffF5F5F5);
  Color darkBlue = Color(0xffF213959);
  Color lightPink = Color(0xffFE8416D);

  String poppins = "Poppins";
  String profileUrl = '';
  String userName = '';

  int currentActivity = 0;
  //sockets
  IO.Socket? socket;

  //socket init
  initSocket(BuildContext context) {

    //let data = socket?.emit("adduser", { Email: token?.result?.Email, type: token?.result?.TypeOfUser, _id: token?.result?._id, Id: token?.result?.Id, Name: token?.result?.Name })

    print("Socket connecting...");
    //AlertsAndColors().showLoader(context);
    //IO.Socket socket = IO.io('https://cakey-backend.herokuapp.com');
    //socket = IO.io("http://sugitechnologies.com:3001", <String, dynamic>{
    socket = IO.io("${SOCKET_URL}", <String, dynamic>{
      'autoConnect': true,
      'transports': ['websocket'],
    });
    // socket!.connect();
    // socket!.onConnect((e) {
    //   print('Connection established. $e');
    //   //Navigator.pop(context);
    // });
    // socket!.onDisconnect((e){
    //   print('Connection Disconnected $e');
    //   //Navigator.pop(context);
    // });
    // socket!.onConnectError((err) {
    //   print(err);
    //   //Navigator.pop(context);
    // });
    // socket!.onError((err) => print(err));

    //socket?.emit("adduser", { Email: token?.result?.Email, type: "helpDeskv" })

    // socket.on('getMessage', (newMessage) {
    //   //chatList.add(MessageModel.fromJson(data));
    //   print(newMessage);
    // });
    //
    // socket.emit("adduser", { "Email": "surya@mindmade.in", "type": "vendor" });
  }

  void showlogoutDialog() {
    showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)
            ),
            title: Text('Logout'
              ,style: TextStyle(color: darkBlue,fontWeight: FontWeight.bold,fontFamily: "Poppins"),
            ),
            content: Text('Are you sure? you will be logged out!',
              style: TextStyle(color: Colors.black,fontWeight: FontWeight.normal,fontFamily: "Poppins"),
            ),
            actions: [
              TextButton(
                onPressed: (){
                  Navigator.pop(context);
                },
                child: Text('Cancel',
                  style: TextStyle(color: Colors.deepPurple,fontFamily: "Poppins"),
                ),
              ),
              TextButton(
                onPressed: (){
                  Navigator.pop(context);
                  Future.delayed(Duration.zero,() async{
                    var pr = await SharedPreferences.getInstance();
                    pr.setString("showMoreVendor", "null");
                    pr.remove("socketMessages");
                    pr.remove("socketTyping");
                    pr.remove("socketActiveMembers");
                    pr.remove("chatListener");
                    socket!.disconnect();
                    socket!.close();
                    socket!.destroy();
                  });
                  FirebaseAuth.instance.signOut();
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => WelcomeScreen()
                      ),
                      ModalRoute.withName('/WelcomeScreen')
                  );
                },
                child: Text('Logout',
                  style: TextStyle(color: Colors.deepPurple,fontFamily: "Poppins"),
                ),
              ),
            ],
          );
        }
    );
  }


  @override
  void initState() {
    // TODO: implement initState
    Future.delayed(Duration.zero,() async{
      initSocket(context);
      var prefs = await SharedPreferences.getInstance();
      prefs.setBool('iamYourVendor', false);
      prefs.setBool('vendorCakeMode',false);
      context.read<ContextData>().setMyVendors([]);
      context.read<ContextData>().addMyVendor(false);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    profileUrl = context.watch<ContextData>().getProfileUrl();
    userName = context.watch<ContextData>().getUserName();
    return SafeArea(
      child: Container(
        padding: EdgeInsets.all(15),
        width: 310,
        decoration: BoxDecoration(
            image: DecorationImage(
              image: Svg('assets/images/splash.svg'),
              fit: BoxFit.cover,
            ),
            color: Colors.white,
            borderRadius: BorderRadius.only(topRight:Radius.circular(25),bottomRight: Radius.circular(25))
        ),
        child: Column(
          children: [
            //Profile content...
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(blurRadius: 12, color: Color(0xffcccccc), spreadRadius: 1)],
                    ),
                    child: profileUrl!="null"?
                    Container(
                      height: 65,
                      width: 65,
                      decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              image: NetworkImage('$profileUrl'),
                              fit: BoxFit.fill
                          )
                      ),
                    ):CircleAvatar(
                      radius: 37,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                          radius: 35,
                          backgroundImage:AssetImage('assets/images/user.png')
                      ),
                    )
                ),
                SizedBox(width: 15,),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 180,
                      child: Text(userName!="null"?'$userName':'No name',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: darkBlue,fontWeight: FontWeight.bold,fontFamily: "Poppins",fontSize: 15),
                      ),
                    ),
                    SizedBox(height: 7,),
                    GestureDetector(
                      onTap: (){
                        Navigator.of(context).push(
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) => Profile(defindex: 0,),
                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                              const begin = Offset(1.0, 0.0);
                              const end = Offset.zero;
                              const curve = Curves.ease;

                              final tween = Tween(begin: begin, end: end);
                              final curvedAnimation = CurvedAnimation(
                                parent: animation,
                                curve: curve,
                              );

                              return SlideTransition(
                                position: tween.animate(curvedAnimation),
                                child: child,
                              );
                            },
                          ),
                        );
                      },
                      child: Container(
                        height: 30,
                        width: 90,
                        alignment: Alignment.center,
                        child:Text("PROFILE",style: TextStyle(
                          fontFamily: "Poppins",
                          fontSize:13,
                          color:Colors.white
                        ),),
                        decoration:BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            color:lightPink,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
            Container(
              margin: EdgeInsets.only(top: 20),
              height: 0.5,
              color: lightPink,
            ),
            SizedBox(height: 25,),
            ListTile(
              onTap: (){

                if(screenName == "home"){
                  Navigator.pop(context);
                }else {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen()));
                }
              },
              leading: CircleAvatar(
                backgroundColor: Colors.red[50],
                child: Icon(Icons.home_outlined,color:lightPink,),
              ),
              title: Container(
                width: 180,
                child: Text('Home',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: darkBlue,fontFamily: "Poppins",fontSize: 16),
                ),
              ),
            ),
            ListTile(
              onTap: (){
                if(screenName == "ctype"){
                  Navigator.pop(context);
                }else {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => CakeTypes()));
                }
              },
              leading: CircleAvatar(
                backgroundColor: Colors.red[50],
                child: Icon(Icons.cake_outlined,color:lightPink,),
              ),
              title: Container(
                width: 180,
                child: Text('Types Of Cakes',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: darkBlue,fontFamily: "Poppins",fontSize: 16),
                ),
              ),
            ),
            ListTile(
              onTap: (){
                if(screenName == "custom"){
                  Navigator.pop(context);
                }else {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => CustomiseCake()));
                }
              },
              leading: CircleAvatar(
                backgroundColor: Colors.red[50],
                child: Icon(Icons.edit_outlined,color:lightPink,),
              ),
              title: Container(
                child: Text('Fully Customise Cake',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: darkBlue,fontFamily: "Poppins",fontSize: 16),
                ),
              ),
            ),
            ListTile(
              onTap: (){
                if(screenName == "vendor"){
                  Navigator.pop(context);
                }else {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => VendorsList()));
                }
              },
              leading: CircleAvatar(
                backgroundColor: Colors.red[50],
                child: Icon(Icons.account_circle_outlined,color:lightPink,),
              ),
              title: Container(
                width: 180,
                child: Text('Vendors List',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: darkBlue,fontFamily: "Poppins",fontSize: 16),
                ),
              ),
            ),
            ListTile(
              onTap: (){
                Navigator.of(context).push(
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => Profile(defindex: 1,),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      const begin = Offset(1.0, 0.0);
                      const end = Offset.zero;
                      const curve = Curves.ease;

                      final tween = Tween(begin: begin, end: end);
                      final curvedAnimation = CurvedAnimation(
                        parent: animation,
                        curve: curve,
                      );

                      return SlideTransition(
                        position: tween.animate(curvedAnimation),
                        child: child,
                      );
                    },
                  ),
                );
              },
              leading: CircleAvatar(
                backgroundColor: Colors.red[50],
                child: Icon(Icons.shopping_bag_outlined,color:lightPink,),
              ),
              title: Container(
                width: 180,
                child: Text('Order History',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: darkBlue,fontFamily: "Poppins",fontSize: 16),
                ),
              ),
            ),
            ListTile(
              onTap: (){
                Navigator.of(context).push(
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => Notifications(),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      const begin = Offset(1.0, 0.0);
                      const end = Offset.zero;
                      const curve = Curves.ease;

                      final tween = Tween(begin: begin, end: end);
                      final curvedAnimation = CurvedAnimation(
                        parent: animation,
                        curve: curve,
                      );
                      return SlideTransition(
                        position: tween.animate(curvedAnimation),
                        child: child,
                      );
                    },
                  ),
                );
              },
              leading: CircleAvatar(
                backgroundColor: Colors.red[50],
                child: Icon(Icons.notifications_outlined,color:lightPink,),
              ),
              title: Container(
                width: 180,
                child: Text('Notifications',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: darkBlue,fontFamily: "Poppins",fontSize: 16),
                ),
              ),
            ),
            ListTile(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>ChatsList()));
              },
              leading: CircleAvatar(
                backgroundColor: Colors.red[50],
                child: Icon(Icons.support_agent,color:lightPink,),
              ),
              title: Container(
                width: 180,
                child: Text('Support',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: darkBlue,fontFamily: "Poppins",fontSize: 16),
                ),
              ),
            ),
            Expanded(
                child: Container(
                  alignment: Alignment.bottomLeft,
                  child:ListTile(
                    onTap: (){
                      Navigator.pop(context);
                      showlogoutDialog();
                    },
                    leading:Icon(
                      Icons.logout_sharp,
                      color: lightPink,
                      size: 30,
                    ),
                    title: Container(
                      width: 180,
                      child: Text('Logout',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: darkBlue,fontFamily: "Poppins",fontSize: 16),
                      ),
                    ),
                  ),
                )
            ),
          ],
        ),
      ),
    );
  }
}
