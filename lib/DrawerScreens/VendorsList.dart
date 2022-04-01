import 'package:cakey/screens/SingleVendor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class VendorsList extends StatefulWidget {
  const VendorsList({Key? key}) : super(key: key);

  @override
  State<VendorsList> createState() => _VendorsListState();
}

class _VendorsListState extends State<VendorsList> {

  //Colors
  Color lightGrey = Color(0xffF5F5F5);
  Color darkBlue = Color(0xffF213959);
  Color lightPink = Color(0xffFE8416D);

  String poppins = "Poppins";

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        leading:Container(
          margin: const EdgeInsets.all(10),
          child: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
                decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(10)),
                alignment: Alignment.center,
                height: 20,
                width: 20,
                child: Icon(
                  Icons.chevron_left,
                  color: lightPink,
                  size: 35,
                )),
          ),
        ),
        title: Text('VENDORS',
            style: TextStyle(
                color: darkBlue, fontWeight: FontWeight.bold, fontSize: 15)),
        elevation: 0.0,
        backgroundColor: lightGrey,
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              InkWell(
                onTap: () => print("hii"),
                child: Container(
                  padding: EdgeInsets.all(3),
                  decoration: BoxDecoration(
                      color: Colors.black26,
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
          SizedBox(
            width: 10,
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(blurRadius: 3, color: Colors.black, spreadRadius: 0)
              ],
            ),
            child: InkWell(
              onTap: () {
                print('hello surya....');
              },
              child: CircleAvatar(
                radius: 19.5,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 18,
                  backgroundImage: NetworkImage(
                      "https://yt3.ggpht.com/1ezlnMBACv7Aa5TVu7OVumYrvIFQSsVtmKxKN102PV1vrZIoqIzHCO-XY_ZsWuGHzIgksOv__9o=s900-c-k-c0x00ffffff-no-rj"),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 10,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //Location name...
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
                        Text('Delivery to',style: TextStyle(color: Colors.black54,fontWeight: FontWeight.bold,
                            fontFamily: "Poppins"),)
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 8),
                    alignment: Alignment.centerLeft,
                    child: Text('California',style:TextStyle(fontFamily: "Poppins",fontSize: 18,color: darkBlue,fontWeight: FontWeight.bold),),
                  ),
                ],
              ),
            ),
            //Search bar...
            Container(
              margin: EdgeInsets.all(10),
              height: 50,
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search location",
                  hintStyle: TextStyle(fontFamily: "Poppins"),
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5)
                  ),
                  contentPadding: EdgeInsets.all(5),
                ),
              ),
            ),

            Container(
              height: height*0.7,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //Vendor list text
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text("Nearest Vendors",
                        style: TextStyle(color: darkBlue,fontSize: 14,fontFamily: "Poppins",fontWeight: FontWeight.bold),
                      ),
                    ),
                    //Vendors list..
                    Container(
                      padding: EdgeInsets.all(8),
                      child: Container(
                        height: 200,
                        child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            shrinkWrap: true,
                            itemCount: 4,
                            itemBuilder: (context , index){
                              return Card(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)
                                ),
                                child: Container(
                                  padding: EdgeInsets.all(10),
                                  width: 250,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          CircleAvatar(
                                            radius:32,
                                            backgroundColor: Colors.white,
                                            child: CircleAvatar(
                                              radius:30,
                                              backgroundImage: NetworkImage(
                                                  "https://www.areinfotech.com/services/android-app-development-in-ahmedabad.png"
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 8,),
                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                width:155,
                                                child: Text('Vendor name',style: TextStyle(
                                                    color: darkBlue,fontWeight: FontWeight.bold,
                                                    fontFamily: "Poppins"
                                                ),overflow: TextOverflow.ellipsis,),
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
                                                      color: Colors.black54,fontWeight: FontWeight.bold,fontSize: 13,
                                                      fontFamily: "Poppins"
                                                  ),)
                                                ],
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                      Text('the vendors description goes here it may come long',
                                        style: TextStyle(color: Colors.black54,fontFamily: "Poppins"),
                                        overflow: TextOverflow.ellipsis,maxLines: 2,),
                                      Container(
                                        margin:EdgeInsets.only(top: 10),
                                        height: 0.5,
                                        color: Colors.black26,
                                      ),
                                      SizedBox(height: 15,),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('Includes eggless',style: TextStyle(
                                                  color: darkBlue,
                                                  fontSize: 13
                                              ),),
                                              Text('Delivery fee goes here',style: TextStyle(
                                                  color: Colors.orange,
                                                  fontSize: 12
                                              ),),
                                            ],
                                          ),
                                          Icon(Icons.check_circle,color: Colors.green,)
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              );
                            }
                        ),
                      ),
                    ),

                    //Other vendor title...
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text("Other Vendors",
                        style: TextStyle(color: darkBlue,fontSize: 14,fontFamily: "Poppins",fontWeight: FontWeight.bold),
                      ),
                    ),

                    //Other vendors list....
                    Container(
                      child: ListView.builder(
                          itemCount: 5,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context,index){
                            return GestureDetector(
                              onTap: (){
                                Navigator.of(context).push(
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation, secondaryAnimation) => SingleVendor(),
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
                              child: Card(
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
                                                    onTap: (){
                                                      Navigator.of(context).push(
                                                        PageRouteBuilder(
                                                          pageBuilder: (context, animation, secondaryAnimation) => SingleVendor(),
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
                                                  index/1==0?Text('DELIVERY FREE',style: TextStyle(
                                                      color: Colors.orange,fontSize: 10,fontFamily: poppins
                                                  ),):Text('10 Km Delivery fee ₹ 49',style: TextStyle(
                                                      color: darkBlue,fontSize: 12,fontFamily: poppins
                                                  ),),
                                                  TextButton(
                                                    onPressed: (){},
                                                    child:Text('Select',style: TextStyle(
                                                        color: Colors.black,fontSize: 10,fontWeight:
                                                    FontWeight.bold,fontFamily: poppins,
                                                        decoration: TextDecoration.underline
                                                    ),),
                                                  ),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      )
    );
  }
}
