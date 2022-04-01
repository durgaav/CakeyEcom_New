
import 'package:cakey/DrawerScreens/CakeTypes.dart';
import 'package:cakey/DrawerScreens/VendorsList.dart';
import 'package:cakey/screens/WelcomeScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../screens/Profile.dart';
//This is home screen.........
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  //region Vari..
  //Scaff Key..
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  //Colors....
  Color lightGrey = Color(0xffF5F5F5);
  Color darkBlue = Color(0xffF213959);
  Color lightPink = Color(0xffFE8416D);

  //main variables
  bool egglesSwitch = true;
  String poppins = "Poppins";
  User authUser = FirebaseAuth.instance.currentUser!;

  //pref values
  bool profileRemainder = false;
  String phoneNumber = '';

  //TextFields controls for search....
  var cakeCategoryCtrl = new TextEditingController();
  var cakeSubCategoryCtrl = new TextEditingController();
  var cakeVendorCtrl = new TextEditingController();
  var cakeLocationCtrl = new TextEditingController();

  //endregion

  //region Alerts

  //Default loader dialog
  void showAlertDialog(){
    showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            content: Container(
              height: 75,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // CircularProgressIndicator(),
                  CupertinoActivityIndicator(
                    radius: 17,
                    color: lightPink,
                  ),
                  SizedBox(height: 13,),
                  Text('Please Wait...',style: TextStyle(
                    color: Colors.black,
                    fontFamily: 'Poppins',
                  ),)
                ],
              ),
            ),
          );
        }
    );
  }

  //Filter Bottom sheet(**important...)
  void showFilterBottom(){
      showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(topRight: Radius.circular(20),topLeft: Radius.circular(20)),
      ),
      context: context,
      isScrollControlled: true,
      builder: (context){
       return Container(
         // padding: EdgeInsets.all(15),
         padding: EdgeInsets.only(
           bottom: MediaQuery.of(context).viewInsets.bottom,
         ),
        child:SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 8,),
                  //Title text...
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('SEARCH',style: TextStyle(color: darkBlue,fontSize: 18,
                            fontWeight: FontWeight.bold,fontFamily: "Poppins"),),
                        GestureDetector(
                          onTap: ()=>Navigator.pop(context),
                          child: Container(
                              width: 35,
                              height: 35,
                              decoration: BoxDecoration(
                                  color: Colors.black12,
                                  borderRadius: BorderRadius.circular(10)
                              ),
                              alignment: Alignment.center,
                              child: Icon(Icons.close_outlined,color: lightPink,)
                          ),
                        ),
                      ],
                    ),
                  SizedBox(
                    height: 15,
                  ),
                  //Edit texts...
                  Container(
                    height: 45,
                    child: TextField(
                      controller: cakeCategoryCtrl,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(5),
                        hintText: "Category",
                        hintStyle: TextStyle(fontFamily: "Poppins"),
                        prefixIcon: Icon(Icons.search_outlined),
                        border: OutlineInputBorder()
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Container(
                    height: 45,
                    child: TextField(
                      controller: cakeSubCategoryCtrl,
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(5),
                          hintText: "Sub Category",
                          hintStyle: TextStyle(fontFamily: "Poppins"),
                          prefixIcon: Icon(Icons.search_outlined),
                          border: OutlineInputBorder()
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Container(
                    height: 45,
                    child: TextField(
                      controller: cakeVendorCtrl,
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(5),
                          hintText: "Vendors",
                          hintStyle: TextStyle(fontFamily: "Poppins"),
                          prefixIcon: Icon(Icons.account_circle),
                          border: OutlineInputBorder()
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Container(
                    height: 45,
                    child: TextField(
                      controller: cakeLocationCtrl,
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(5),
                          hintText: "Location",
                          hintStyle: TextStyle(fontFamily: "Poppins"),
                          prefixIcon: Icon(Icons.location_on),
                          suffixIcon: IconButton(
                            onPressed: (){},
                            icon: Icon(Icons.my_location),
                          ),
                          border: OutlineInputBorder()
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  //kilo meter radius buttons.........
                  Wrap(
                    runSpacing: 5.0,
                    spacing: 5.0,
                      children: [
                        OutlinedButton(
                          onPressed: (){},
                          child: Text('5 KM',style: TextStyle(color: darkBlue,fontFamily: "Poppins"),),
                        ),
                        OutlinedButton(
                          onPressed: (){},
                          child: Text('10 KM',style: TextStyle(color: darkBlue,fontFamily: "Poppins"),),
                        ),
                        OutlinedButton(
                          onPressed: (){},
                          child: Text('15 KM',style: TextStyle(color: darkBlue,fontFamily: "Poppins"),),
                        ),
                        OutlinedButton(
                          onPressed: (){},
                          child: Text('20 KM',style: TextStyle(color: darkBlue,fontFamily: "Poppins"),),
                        ),
                        OutlinedButton(
                          onPressed: (){},
                          child: Text('25 KM',style: TextStyle(color: darkBlue,fontFamily: "Poppins"),),
                        ),
                      ],

                  ),
                  SizedBox(height: 8,),
                  Container(
                    height: 1.0,
                    color: Colors.black26,
                  ),
                  //cake types....
                  SizedBox(height: 8,),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Types',style: TextStyle(color: darkBlue,fontSize: 16,
                        fontWeight: FontWeight.bold,fontFamily: "Poppins"),),
                  ),
                  SizedBox(height: 10,),

                  //types of cakes btn...
                  Wrap(
                    runSpacing: 5.0,
                    spacing: 5.0,
                    children: [
                      OutlinedButton(
                        onPressed: (){},
                        child: Text('Normal cakes',style: TextStyle(fontSize: 12,color: darkBlue,fontFamily: "Poppins"),),
                      ),
                      OutlinedButton(
                        onPressed: (){},
                        child: Text('Basic Customize cake',style: TextStyle(fontSize: 12,color: darkBlue,fontFamily: "Poppins"),),
                      ),
                      OutlinedButton(
                        onPressed: (){},
                        child: Text('Fully Customize cake',style: TextStyle(fontSize: 12,color: darkBlue,fontFamily: "Poppins"),),
                      ),
                    ],
                  ),

                  SizedBox(height: 10,),
                  //Search button...
                  Container(
                    height: 55,
                    width: 200,
                    child: RaisedButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        color: lightPink,
                        onPressed: (){
                          Navigator.pop(context);
                          showDpUpdtaeDialog();
                        },
                        child: Text("SEARCH",style: TextStyle(
                          color: Colors.white,fontWeight: FontWeight.bold,fontFamily: "Poppins"
                        ),),
                    ),
                  )

                ],
              ),
          ),
        ),
      );
    }
    );
  }

  //Profile update remainder dialog
  void showDpUpdtaeDialog(){
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context){
          return Align(
            alignment: Alignment.topCenter,
            child: Container(
              height: 90,
              decoration: BoxDecoration(
                  color: Colors.white,
                   border: Border.all(color: lightPink,width: 1.5,style: BorderStyle.solid),
                   borderRadius: BorderRadius.only(bottomLeft: Radius.circular(14),
                   bottomRight: Radius.circular(14),
                  )
              ),
              padding: EdgeInsets.all(5),
             child: Row(
               crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(10)
                      ),
                      alignment: Alignment.center,
                      child: Icon(Icons.volume_up_rounded,color: darkBlue,)
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        child: Text('Complete Your Profile & Easy To Take\nYour Order',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: TextStyle(color: darkBlue,fontWeight: FontWeight.bold,
                              fontFamily: "Poppins",fontSize: 12),
                        ),
                      ),
                      SizedBox(height: 5,),
                      Container(
                        height: 25,
                        width: 80,
                        child: RaisedButton(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25)
                          ),
                          color:lightPink,
                          onPressed: (){
                            Navigator.of(context).push(
                              PageRouteBuilder(
                                pageBuilder: (context, animation, secondaryAnimation) => Profile(
                                  defindex: 0,
                                ),
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
                            style: TextStyle(color:Colors.white,fontFamily: "Poppins",fontSize: 10),
                          ),
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: ()=>Navigator.pop(context),
                    child: Container(
                        width: 35,
                        height: 35,
                        decoration: BoxDecoration(
                            color: Colors.black12,
                            borderRadius: BorderRadius.circular(10)
                        ),
                        alignment: Alignment.center,
                        child: Icon(Icons.close_outlined,color: darkBlue,)
                    ),
                  ),
                ],
              ),
            ),
          );
        }
    );
  }

  //endregion

  //region Functions
  Future<void> loadPrefs() async{
    print("Prefs loading...");
    var prefs = await SharedPreferences.getInstance();
    setState(() {
      profileRemainder = prefs.getBool("profileUpdated")??false;
      phoneNumber = prefs.getString("phoneNumber")??"";
    });
  }
  //endregion

  //onStart
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration.zero ,() async{
      loadPrefs();
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      key: _scaffoldKey,
      body: SingleChildScrollView(
        child: Column(
          children: [
            //Location and search....
            Container(
              padding: EdgeInsets.only(left:10,top: 8,bottom: 15),
              color: lightGrey,
              child: Column(
                children: [
                  Container(
                    child: Row(
                      children: [
                        Icon(Icons.location_on,color: Colors.red,),
                        SizedBox(width: 8,),
                        Text('Delivery to',style: TextStyle(color: Colors.black54,fontWeight: FontWeight.bold,fontFamily: poppins),)
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 8),
                    alignment: Alignment.centerLeft,
                    child: Text('California',style:TextStyle(fontFamily: poppins,fontSize: 18,color: darkBlue,fontWeight: FontWeight.bold),),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 15),
                    padding: EdgeInsets.only(right: 10),
                    alignment: Alignment.center,
                    child: Row(
                      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: width*0.79,
                          height: 50,
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: "Search cake, vendor, etc...",
                              hintStyle: TextStyle(fontFamily: poppins),
                              prefixIcon: Icon(Icons.search),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8)
                              ),
                              contentPadding: EdgeInsets.all(5),
                            ),
                          ),
                        ),
                        SizedBox(width: 5,),
                        Container(
                          width: width*0.13,
                          height: 50,
                          decoration: BoxDecoration(
                              color: lightPink,
                              borderRadius: BorderRadius.circular(8)
                          ),
                          child:IconButton(
                              splashColor: Colors.black26,
                              onPressed:(){
                                print(MediaQuery.of(context).viewInsets.bottom);
                                FocusScope.of(context).unfocus();
                                showFilterBottom();
                                // showDpUpdtaeDialog();
                              },
                              icon: Icon(Icons.tune,color:Colors.white,)
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              color: lightGrey,
              height: height*0.71,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    //List views and orders...
                    Container(
                      height: 510,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                            image:Svg('assets/images/splash.svg'),
                            fit: BoxFit.cover,
                            colorFilter:ColorFilter.mode(Colors.white70,BlendMode.darken)
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.all(15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Type of Cakes',style: TextStyle(fontFamily: poppins,fontSize:18,color: darkBlue,fontWeight: FontWeight.bold),),
                                InkWell(
                                  onTap: (){
                                    print('see more..');
                                    print(width);
                                    Navigator.of(context).push(
                                      PageRouteBuilder(
                                        pageBuilder: (context, animation, secondaryAnimation) => CakeTypes(),
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
                                    print(height);
                                  },
                                  child: Row(
                                    children: [
                                      Text('See All',style: TextStyle(color: lightPink,fontFamily: poppins,fontWeight: FontWeight.bold),),
                                      Icon(Icons.keyboard_arrow_right,color: lightPink,)
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            height:175,
                            child: ListView.builder(
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                itemCount: 20,
                                itemBuilder: (context , index){
                                  return Container(
                                    width: 150,
                                    child: InkWell(
                                      onTap: (){
                                        FocusScope.of(context).unfocus();
                                      },
                                      child: Column(
                                        children: [
                                          Container(
                                            height: 120,
                                            width: 130,
                                            decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(20),
                                                border: Border.all(color: Colors.white,width: 2),
                                                image: DecorationImage(
                                                    image: NetworkImage('https://w0.peakpx.com/wallpaper/863/651/HD-wallpaper-red-cake-pastries-desserts-cakes-strawberry-cake-berry-cake.jpg'),
                                                    fit: BoxFit.cover
                                                )
                                            ),
                                          ),
                                          Text("Cake name",style:TextStyle(color: darkBlue,
                                              fontWeight: FontWeight.bold,fontFamily: poppins),
                                            textAlign: TextAlign.center,)
                                        ],
                                      ),
                                    ),
                                  );
                                }
                            ),
                          ),
                          Container(
                            height: 0.5,
                            width: double.infinity,
                            margin: EdgeInsets.only(left: 10,right: 10),
                            color: Colors.black26,
                          ),
                          Container(
                              padding: EdgeInsets.all(10),
                              width: double.infinity,
                              alignment: Alignment.centerLeft,
                              child: Text('Recent Ordered',style: TextStyle(
                                  color: darkBlue,fontWeight: FontWeight.bold,fontSize: 18,fontFamily: poppins
                              ),)
                          ),
                          Container(
                            height: 220,
                            child: ListView.builder(
                                itemCount: 4,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (context,index){
                                  return Container(
                                    margin: EdgeInsets.only(left: 10,right: 10),
                                    child: Stack(
                                      alignment: Alignment.topCenter,
                                      children: [
                                        Container(
                                          height:140,
                                          width: 200,
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(15),
                                              image: DecorationImage(
                                                  fit: BoxFit.cover,
                                                  image: NetworkImage('https://image.shutterstock.com/image-photo/chocolate-cake-berries-260nw-394680466.jpg')
                                              )
                                          ),
                                        ),
                                        Positioned(
                                          top: 100,
                                          child: Card(
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10)
                                            ),
                                            elevation: 7,
                                            child: Container(
                                              padding: EdgeInsets.all(8),
                                              width: 190,
                                              height: 100,
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Container(
                                                      alignment: Alignment.centerLeft,
                                                      child: Container(
                                                        width: 150,
                                                        child: Text('Strawberry cake',style: TextStyle(color: darkBlue
                                                            ,fontWeight: FontWeight.bold,fontFamily: poppins
                                                        ),),
                                                      )
                                                  ),
                                                  Row(
                                                    children: [
                                                      CircleAvatar(
                                                        radius:14,
                                                        child: Icon(Icons.account_circle,),
                                                      ),
                                                      Container(
                                                          width: 105,
                                                          child: Text(' Surya prakash',
                                                            overflow: TextOverflow.ellipsis,style: TextStyle(
                                                                color: Colors.black54,fontFamily: poppins),maxLines: 1,))
                                                    ],
                                                  ),
                                                  Container(
                                                    height: 0.5,
                                                    color: Colors.black54,
                                                    margin: EdgeInsets.only(left: 5,right: 5),
                                                  ),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text("₹ 450",style: TextStyle(color: lightPink,
                                                          fontWeight: FontWeight.bold,fontFamily: poppins),maxLines: 1,),
                                                      index/1==1?
                                                      Text("Delivered",style: TextStyle(color: Colors.green,
                                                      fontWeight: FontWeight.bold,fontFamily: poppins,fontSize: 12),)
                                                          :
                                                      Text("Preparing",style: TextStyle(color: Colors.blueAccent,
                                                          fontWeight: FontWeight.bold,fontFamily: poppins,fontSize: 12),)
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                            ),
                          ),
                        ],
                      ),
                    ),
                    //Vendors........
                    Container(
                      padding: EdgeInsets.all(15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text('Vendors list',style: TextStyle(fontSize:18,
                                  color: darkBlue,fontWeight: FontWeight.bold,fontFamily: poppins),),
                              Text('  (10km radius)',style: TextStyle(color: Colors.black45,fontFamily: poppins),),
                            ],
                          ),
                          InkWell(
                            onTap: (){
                              print('see more..');
                              Navigator.of(context).push(
                                PageRouteBuilder(
                                  pageBuilder: (context, animation, secondaryAnimation) => VendorsList(),
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
                            child: Row(
                              children: [
                                Text('See All',style: TextStyle(color: lightPink,fontWeight: FontWeight.bold,fontFamily: poppins),),
                                Icon(Icons.keyboard_arrow_right,color: lightPink,)
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        Container(
                          padding: EdgeInsets.only(left: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Container(
                              //   child: RaisedButton(
                              //     color:Colors.white,
                              //     shape: RoundedRectangleBorder(
                              //       borderRadius: BorderRadius.circular(25)
                              //     ),
                              //     onPressed: (){},
                              //     child: Row(
                              //       children: [
                              //         Icon(Icons.filter_list,color: lightPink,),
                              //         Text(' Filter',style: TextStyle(color: darkBlue,fontWeight: FontWeight.bold))
                              //       ],
                              //     ),
                              //   ),
                              // ),
                              Row(
                                children: [
                                  Transform.scale(
                                    scale: 0.7,
                                    child: CupertinoSwitch(
                                      thumbColor: Colors.white,
                                      value: egglesSwitch,
                                      onChanged: (bool? val){
                                        setState(() {
                                          egglesSwitch = val!;
                                        });
                                      },
                                      activeColor: Colors.green,
                                    ),
                                  ),
                                  Text(egglesSwitch?'Eggless':'Egg',style: TextStyle(color: darkBlue,
                                      fontWeight: FontWeight.bold,fontFamily: poppins),),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          child: ListView.builder(
                              itemCount: 5,
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemBuilder: (context,index){
                                return Card(
                                  margin: EdgeInsets.only(left: 10,right: 10,top: 10,bottom: 5),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15)
                                  ),
                                  child: Container(
                                    // margin: EdgeInsets.all(5),
                                    padding: EdgeInsets.all(6),
                                    height: 130,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15)
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          height: 120,
                                          width: 90,
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(15),
                                              image: DecorationImage(
                                                fit: BoxFit.cover,
                                                image: NetworkImage("https://www.teahub.io/photos/full/335-3350221_birthday-cake-wallpaper-for-desktop-happy-birthday-image.jpg"),
                                              )
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.only(left: 10),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                                            children: [
                                              Container(
                                                width:width*0.63,
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Container(
                                                          width:width*0.5,
                                                          child: Text('Surya prakash',overflow: TextOverflow.ellipsis,style: TextStyle(
                                                              color: darkBlue,fontWeight: FontWeight.bold,fontSize: 14,fontFamily: poppins
                                                          ),),
                                                        ),
                                                        Row(
                                                          children: [
                                                            RatingBar.builder(
                                                              initialRating: 4.1,
                                                              minRating: 1,
                                                              direction: Axis.horizontal,
                                                              allowHalfRating: true,
                                                              itemCount: 5,
                                                              itemSize: 14,
                                                              itemPadding: EdgeInsets.symmetric(horizontal: 1.0),
                                                              itemBuilder: (context, _) => Icon(
                                                                Icons.star,
                                                                color: Colors.amber,
                                                              ),
                                                              onRatingUpdate: (rating) {
                                                                print(rating);
                                                              },
                                                            ),
                                                            Text(' 4.5',style: TextStyle(
                                                                color: Colors.black54,fontWeight: FontWeight.bold,fontSize: 13,fontFamily: poppins
                                                            ),)
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                    InkWell(
                                                      onTap: (){},
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                            color: lightGrey,
                                                            shape: BoxShape.circle
                                                        ),
                                                        padding: EdgeInsets.all(4),
                                                        height: 35,
                                                        width: 35,
                                                        child: Icon(Icons.keyboard_arrow_right,color: lightPink,),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                width: width*0.63,
                                                child: Text("Special velvet chocolate cakeeee",overflow: TextOverflow.ellipsis,style: TextStyle(
                                                    color: Colors.black54,fontFamily: poppins,fontSize: 13
                                                ),maxLines: 1,),
                                              ),
                                              Container(
                                                height: 1,
                                                width: width*0.63,
                                                color: Colors.black26,
                                              ),
                                              Container(
                                                width: width*0.63,
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text('DELIVERY FREE',style: TextStyle(
                                                        color: Colors.orange,fontSize: 10,fontFamily: poppins
                                                    ),),
                                                    Text('Includs eggless cake',style: TextStyle(
                                                        color: Colors.black,fontSize: 11,fontWeight: FontWeight.bold,fontFamily: poppins
                                                    ),),
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              }
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
