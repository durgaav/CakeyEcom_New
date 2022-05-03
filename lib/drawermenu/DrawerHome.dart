import 'package:cakey/ContextData.dart';
import 'package:cakey/DrawerScreens/CakeTypes.dart';
import 'package:cakey/DrawerScreens/CustomiseCake.dart';
import 'package:cakey/DrawerScreens/VendorsList.dart';
import 'package:cakey/screens/Profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../DrawerScreens/HomeScreen.dart';
import '../DrawerScreens/Notifications.dart';
import '../screens/SingleVendor.dart';
import '../screens/WelcomeScreen.dart';
import 'package:provider/provider.dart';

class DrawerHome extends StatefulWidget {
  const DrawerHome({Key? key}) : super(key: key);

  @override
  State<DrawerHome> createState() => _DrawerHomeState();
}

class _DrawerHomeState extends State<DrawerHome> {

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  //colors
  Color lightGrey = Color(0xffF5F5F5);
  Color darkBlue = Color(0xffF213959);
  Color lightPink = Color(0xffFE8416D);

  //booleans
  bool egglesSwitch = true;

  //Strings
  String poppins = "Poppins";
  String profileUrl = '';
  String userName = '';

  int selectedIndex = 0;

  var DrawerScreens = [
    HomeScreen(),
    CakeTypes(),
    CustomiseCake(),
    VendorsList(),
    SingleVendor(),
  ];

  var titleText = [
    "HOME",
    "TYPES OF CAKES",
    "FULLY CUSTOMIZATION",
    "VENDORS",
    "VENDORS",
  ];

  //region Alerts

  void showlogoutDialog() {
    showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            title: Text('Cakey'
            ,style: TextStyle(color: lightPink,fontWeight: FontWeight.bold,fontFamily: "Poppins"),
            ),
            content: Text('Are you sure? you will be logged out!',
            style: TextStyle(color: darkBlue,fontWeight: FontWeight.bold,fontFamily: "Poppins"),
            ),
            actions: [
              FlatButton(
                onPressed: (){
                  Navigator.pop(context);
                },
                child: Text('Cancel',
                  style: TextStyle(color: Colors.green,fontWeight: FontWeight.bold,fontFamily: "Poppins"),
                ),
              ),
              FlatButton(
                  onPressed: (){
                    Navigator.pop(context);
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
                    style: TextStyle(color: Colors.deepPurple,fontWeight: FontWeight.bold,fontFamily: "Poppins"),
                  ),
              ),
            ],
          );
        }
    );
  }

  void showExitDialog() {
    showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            title: Text('Cakey'
              ,style: TextStyle(color: lightPink,fontWeight: FontWeight.bold,fontFamily: "Poppins"),
            ),
            content: Text('Do you want to exit now?',
              style: TextStyle(color: darkBlue,fontWeight: FontWeight.bold,fontFamily: "Poppins"),
            ),
            actions: [
              FlatButton(
                onPressed: (){
                  Navigator.pop(context);
                },
                child: Text('Cancel',
                  style: TextStyle(color: Colors.green,fontWeight: FontWeight.bold,fontFamily: "Poppins"),
                ),
              ),
              FlatButton(
                onPressed: (){
                  SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                },
                child: Text('Yes',
                  style: TextStyle(color: Colors.deepPurple,fontWeight: FontWeight.bold,fontFamily: "Poppins"),
                ),
              ),
            ],
          );
        }
    );
  }

  //endregion

  //region Functions...

  //remove sel vendor prefs
  Future<void> removeMyVendorPref() async{

    var pref = await SharedPreferences.getInstance();

    pref.remove('myVendorId');
    pref.remove('myVendorName');
    pref.remove('myVendorPhone');
    pref.remove('myVendorDesc');
    pref.remove('myVendorProfile');
    pref.remove('myVendorDeliverChrg');
    pref.remove('iamYourVendor');

    //remove homescreen caketypes
    pref.remove('homeCakeType');
    pref.remove('homeCTindex');
    pref.remove('isHomeCake');

  }

  //endregion

  //region Navigation drawer.......
  Widget DrawerContainer(){
    print(profileUrl);
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
                    boxShadow: [BoxShadow(blurRadius: 3, color: Colors.black, spreadRadius: 1)],
                  ),
                  child: profileUrl!="null"?CircleAvatar(
                    radius: 37,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 35,
                      backgroundImage:
                      NetworkImage('$profileUrl'),
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
                    Container(
                      height: 30,
                      width: 90,
                      child: RaisedButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25)
                          ),
                          color:lightPink,
                          onPressed: (){
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
                          child: Text('PROFILE',
                            style: TextStyle(color:Colors.white,fontFamily: "Poppins",fontSize: 13),
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
                setState(() {
                  selectedIndex=0;
                });
                context.read<ContextData>().setCurrentIndex(selectedIndex);
                Navigator.pop(context);
              },
              leading: CircleAvatar(
                backgroundColor: Colors.pink[100],
                child: Icon(Icons.home_outlined,color:lightPink,),
              ),
              title: Container(
                width: 180,
                child: Text('Home',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: darkBlue,fontWeight: FontWeight.bold,fontFamily: "Poppins",fontSize: 16),
                ),
              ),
            ),
            ListTile(
              onTap: (){
                setState(() {
                  selectedIndex=1;
                });
                context.read<ContextData>().setCurrentIndex(selectedIndex);
                Navigator.pop(context);
              },
              leading: CircleAvatar(
                backgroundColor: Colors.pink[100],
                child: Icon(Icons.cake_outlined,color:lightPink,),
              ),
              title: Container(
                width: 180,
                child: Text('Types Of Cakes',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: darkBlue,fontWeight: FontWeight.bold,fontFamily: "Poppins",fontSize: 16),
                ),
              ),
            ),
            ListTile(
              onTap: (){
                setState(() {
                  selectedIndex=2;
                });
                context.read<ContextData>().setCurrentIndex(selectedIndex);
                Navigator.pop(context);
              },
              leading: CircleAvatar(
                backgroundColor: Colors.pink[100],
                child: Icon(Icons.edit_outlined,color:lightPink,),
              ),
              title: Container(
                child: Text('Fully Customise Cake',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: darkBlue,fontWeight: FontWeight.bold,fontFamily: "Poppins",fontSize: 16),
                ),
              ),
            ),
            ListTile(
              onTap: (){
                setState(() {
                  selectedIndex=3;
                });
                context.read<ContextData>().setCurrentIndex(selectedIndex);
                Navigator.pop(context);
              },
              leading: CircleAvatar(
                backgroundColor: Colors.pink[100],
                child: Icon(Icons.account_circle_outlined,color:lightPink,),
              ),
              title: Container(
                width: 180,
                child: Text('Vendors List',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: darkBlue,fontWeight: FontWeight.bold,fontFamily: "Poppins",fontSize: 16),
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
                backgroundColor: Colors.pink[100],
                child: Icon(Icons.shopping_bag_outlined,color:lightPink,),
              ),
              title: Container(
                width: 180,
                child: Text('Order History',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: darkBlue,fontWeight: FontWeight.bold,fontFamily: "Poppins",fontSize: 16),
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
                backgroundColor: Colors.pink[100],
                child: Icon(Icons.notifications_outlined,color:lightPink,),
              ),
              title: Container(
                width: 180,
                child: Text('Notifications',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: darkBlue,fontWeight: FontWeight.bold,fontFamily: "Poppins",fontSize: 16),
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
                        style: TextStyle(color: darkBlue,fontWeight: FontWeight.bold,fontFamily: "Poppins",fontSize: 16),
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
  //endregion

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    Future.delayed(Duration.zero , () async{
      removeMyVendorPref();
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    profileUrl = context.watch<ContextData>().getProfileUrl();
    userName = context.watch<ContextData>().getUserName();
    selectedIndex = context.watch<ContextData>().getCurrentIndex();
    return WillPopScope(
      onWillPop: () async{
        showExitDialog();
        return false;
      },
      child: Scaffold(
        drawer: DrawerContainer(),
        key: _scaffoldKey,
        appBar: AppBar(
          leading: InkWell(
            onTap: () {
               FocusScope.of(context).unfocus();
              _scaffoldKey.currentState!.openDrawer();
            },
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 6,
                        backgroundColor: darkBlue,
                      ),
                      SizedBox(width: 3,),
                      CircleAvatar(
                        radius: 6,
                        backgroundColor: darkBlue,
                      ),
                    ],
                  ),
                  SizedBox(height: 3,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 6,
                        backgroundColor: darkBlue,
                      ),
                      SizedBox(width: 3,),
                      CircleAvatar(
                        radius: 6,
                        backgroundColor: Colors.red,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          title: Text(titleText[selectedIndex],
              style: TextStyle(color: darkBlue,fontWeight: FontWeight.bold,fontFamily: poppins,
                fontSize: 15
              )),
          elevation: 0.0,
          backgroundColor:lightGrey,
          actions: [
            Stack(
              alignment: Alignment.center,
              children: [
                InkWell(
                  onTap: () {
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
                  child: Container(
                    padding: EdgeInsets.all(3),
                    decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8)),
                    child: Icon(
                      Icons.notifications_none,
                      color: darkBlue,
                    ),
                  ),
                ),
                Positioned(
                  left: 15,
                  top: 18,
                  child: CircleAvatar(
                    radius: 4.5,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 3.5,
                      backgroundColor: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(width: 10,),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(blurRadius: 3, color: Colors.black, spreadRadius: 0)],
              ),
              child: InkWell(
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
                child: profileUrl!="null"?CircleAvatar(
                  radius: 17.5,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: 16,
                    backgroundImage:NetworkImage("$profileUrl")
                  ),
                ):CircleAvatar(
                radius: 17.5,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                    radius: 16,
                    backgroundImage:AssetImage("assets/images/user.png")
                ),
              ),
              ),
            ),
            SizedBox(width: 10,),
          ],
        ),
        body: DrawerScreens[selectedIndex],
      ),
    );
  }
}
