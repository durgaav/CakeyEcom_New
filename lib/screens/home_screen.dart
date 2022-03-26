import 'package:cakey/screens/cktypes_screen.dart';
import 'package:cakey/screens/welcome_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
//This is home screen.........
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  Color lightGrey = Color(0xffF5F5F5);
  Color darkBlue = Color(0xffF213959);
  Color lightPink = Color(0xffFE8416D);
  bool egglesSwitch = true;
  String poppins = "Poppins";

  User authUser = FirebaseAuth.instance.currentUser!;

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

    //Filter Bottomsheet
    void showFilterBottom(){
     showModalBottomSheet(
         context: context, builder: (context){
           return Container(
             height: 250,
           );
         }
     );
    }

  //endregion


  @override
  Widget build(BuildContext context) {

    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      drawer: Container(color: Colors.white,width: 300,),
      key: _scaffoldKey,
      appBar: AppBar(
        leading: InkWell(
          onTap: () => _scaffoldKey.currentState!.openDrawer(),
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
        title: Text('HOME',style: TextStyle(color: darkBlue,fontWeight: FontWeight.bold,fontFamily: poppins)),
        elevation: 0.0,
        backgroundColor:lightGrey,
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                  onPressed: (){},
                  icon: Icon(Icons.notifications_none),
                  color: darkBlue,
                  iconSize: 33,
              ),
              Positioned(
                left: 25,
                top: 18,
                child: CircleAvatar(
                  radius: 5.5,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: 4.5,
                    backgroundColor: Colors.red,
                  ),
                ),
              ),
            ],
          ),
          Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(blurRadius: 3, color: Colors.black, spreadRadius: 0)],
              ),
              child: InkWell(
                onTap: (){
                  print('hello surya....');
                  // FirebaseAuth.instance.signOut();
                  // Navigator.pop(context);
                  // Navigator.push(context, MaterialPageRoute(builder: (context)=>WelcomeScreen()));
                },
                child: CircleAvatar(
                  radius: 17.5,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: 16,
                    backgroundImage: NetworkImage("https://yt3.ggpht.com/1ezlnMBACv7Aa5TVu7OVumYrvIFQSsVtmKxKN102PV1vrZIoqIzHCO-XY_ZsWuGHzIgksOv__9o=s900-c-k-c0x00ffffff-no-rj"),
                  ),
                ),
              ),
            ),
          SizedBox(width: 10,),
        ],
      ),
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
                                  print(MediaQuery.of(context).size.width*0.13);
                                  FocusScope.of(context).unfocus();
                                  showFilterBottom();
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
                                            // Navigator.push(context, MaterialPageRoute(
                                            //     builder: (context)=>CktypesScreen()
                                            // ));
                                            Navigator.of(context).push(
                                                PageRouteBuilder(
                                                  pageBuilder: (context, animation, secondaryAnimation) => CktypesScreen(),
                                                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                                    const begin = Offset(1.0, 1.0);
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
                                                          child: Icon(Icons.account_circle),
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
                                                        Text("Delivered",style: TextStyle(color: Colors.green,
                                                            fontWeight: FontWeight.bold,fontFamily: poppins),),
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
                                                                color: darkBlue,fontWeight: FontWeight.bold,fontSize: 16,fontFamily: poppins
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
                                                      color: Colors.black54,fontFamily: poppins
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
