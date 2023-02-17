import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../DrawerScreens/Notifications.dart';
import '../screens/Profile.dart';

class CustomAppBars{

  //Colors....
  Color lightGrey = Color(0xffF5F5F5);
  Color darkBlue = Color(0xffF213959);
  Color lightPink = Color(0xffFE8416D);
  ValueNotifier<int> notifier = ValueNotifier(0);

  Widget CustomAppBar(BuildContext context , String title ,int notiCount ,String profileUrl,[function]){
    return Container(
      child: Row(
        children: [
          InkWell(
            onTap: () {
              function();
            },
            child: Container(
              padding: EdgeInsets.all(3),
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(6)),
              child: Icon(
                Icons.refresh,
                color: darkBlue,
                size: 22,
              ),
            ),
          ),
          SizedBox(width:8,),
          Stack(
            alignment: Alignment.center,
            children: [
              InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      pageBuilder: (context, animation,
                          secondaryAnimation) =>
                          Notifications(),
                      transitionsBuilder: (context, animation,
                          secondaryAnimation, child) {
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
                      borderRadius: BorderRadius.circular(6)),
                  child: Icon(
                    Icons.notifications_none,
                    color: darkBlue,
                    size: 22,
                  ),
                ),
              ),
              notiCount>0?
              Positioned(
                left: 15,
                top: 6,
                child: CircleAvatar(
                  radius: 3.7,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: 2.7,
                    backgroundColor: Colors.red,
                  ),
                ),
              ):
              Positioned(
                left: 15,
                top: 6,
                child: Container(height: 0,width: 0,),
              )
            ],
          ),
          SizedBox(
            width: 10,
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    blurRadius: 3,
                    color: Colors.black,
                    spreadRadius: 0)
              ],
            ),
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(
                  PageRouteBuilder(
                    pageBuilder:
                        (context, animation, secondaryAnimation) =>
                        Profile(
                          defindex: 0,
                        ),
                    transitionsBuilder: (context, animation,
                        secondaryAnimation, child) {
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
              child: profileUrl != "null"
                  ? Container(
                  height:27,width:27,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:Colors.red,
                      image: DecorationImage(
                          image: NetworkImage("${profileUrl}"),
                          fit: BoxFit.fill
                      )
                  )
              )
                  : CircleAvatar(
                radius: 14.7,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                    radius: 13,
                    backgroundImage:
                    AssetImage("assets/images/user.png")),
              ),
            ),
          ),
        ],
      ),
    );
  }

}
