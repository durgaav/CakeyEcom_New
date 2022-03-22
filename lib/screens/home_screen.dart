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

  @override
  Widget build(BuildContext context) {
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
        title: Text('HOME',style: TextStyle(color: darkBlue,fontWeight: FontWeight.bold)),
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
                },
                child: CircleAvatar(
                  radius: 19.5,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: 18,
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
                padding: EdgeInsets.all(15),
                color: lightGrey,
                child: Column(
                  children: [
                    Container(
                      child: Row(
                        children: [
                          Icon(Icons.location_on,color: Colors.red,),
                          SizedBox(width: 8,),
                          Text('Delivery to',style: TextStyle(color: Colors.black54,fontWeight: FontWeight.bold),)
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(left: 13),
                      alignment: Alignment.centerLeft,
                      child: Text('Thekkalur',style:TextStyle(fontSize: 18,color: darkBlue,fontWeight: FontWeight.bold),),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 15),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 270,
                            height: 50,
                            child: TextField(
                              decoration: InputDecoration(
                                  hintText: "Search cake, vendor, etc...",
                                  prefixIcon: Icon(Icons.search),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8)
                                  ),
                                  contentPadding: EdgeInsets.all(5),
                              ),
                            ),
                          ),
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: lightPink,
                              borderRadius: BorderRadius.circular(8)
                            ),
                            child:IconButton(
                                splashColor: Colors.black26,
                                onPressed:(){
                                  print('hii');
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
                height: MediaQuery.of(context).size.height*0.7,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      //List views and orders...
                      Container(
                        height: 510,
                        decoration: const BoxDecoration(
                            image: DecorationImage(
                                image:Svg('assets/images/splash.svg'),
                                fit: BoxFit.cover
                            ),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: EdgeInsets.all(15),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Type of Cakes',style: TextStyle(fontSize:18,color: darkBlue,fontWeight: FontWeight.bold),),
                                  InkWell(
                                    onTap: (){
                                      print('see more..');
                                    },
                                    child: Row(
                                      children: [
                                        Text('See All',style: TextStyle(color: lightPink,fontWeight: FontWeight.bold),),
                                        Icon(Icons.keyboard_arrow_right,color: lightPink,)
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Card(
                              child: Container(
                                height:175,
                                child: ListView.builder(
                                    shrinkWrap: true,
                                    scrollDirection: Axis.horizontal,
                                    itemCount: 20,
                                    itemBuilder: (context , index){
                                      return Container(
                                        width: 150,
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
                                            Text("Cake name",style:TextStyle(color: darkBlue,fontWeight: FontWeight.bold),
                                              textAlign: TextAlign.center,)
                                          ],
                                        ),
                                      );
                                    }
                                ),
                              ),
                            ),
                            Container(
                                padding: EdgeInsets.all(10),
                                width: double.infinity,
                                alignment: Alignment.centerLeft,
                                child: Text('Recent Ordered',style: TextStyle(
                                    color: darkBlue,fontWeight: FontWeight.bold,fontSize: 18
                                ),)
                            ),
                            Container(
                              height: 220,
                              child: ListView.builder(
                                  itemCount: 4,
                                  scrollDirection: Axis.horizontal,
                                  itemBuilder: (context,index){
                                    return Container(
                                      margin: EdgeInsets.all(6),
                                      child: Stack(
                                        alignment: Alignment.topCenter,
                                        children: [
                                          Container(
                                            height:130,
                                            width: 170,
                                            decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(15),
                                                image: DecorationImage(
                                                    fit: BoxFit.cover,
                                                    image: NetworkImage('https://image.shutterstock.com/image-photo/chocolate-cake-berries-260nw-394680466.jpg')
                                                )
                                            ),
                                          ),
                                          Positioned(
                                            top: 75,
                                            child: Card(
                                              elevation: 7,
                                              child: Container(
                                                padding: EdgeInsets.all(4),
                                                width: 150,
                                                height: 100,
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Container(
                                                        alignment: Alignment.centerLeft,
                                                        child: Container(
                                                          width: 150,
                                                          child: Text('Strawberry cake',style: TextStyle(color: darkBlue
                                                              ,fontWeight: FontWeight.bold
                                                          ),),
                                                        )
                                                    ),
                                                    Row(
                                                      children: [
                                                        CircleAvatar(
                                                          radius:16,
                                                          child: Icon(Icons.account_circle),
                                                        ),
                                                        Container(
                                                          width: 105,
                                                            child: Text(' Surya prakash hhh',style: TextStyle(color: Colors.black54),maxLines: 1,))
                                                      ],
                                                    ),
                                                    Container(
                                                      height: 1,
                                                      color: Colors.black54,
                                                      margin: EdgeInsets.only(left: 5,right: 5),
                                                    ),
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Text("₹ 450",style: TextStyle(color: lightPink,fontWeight: FontWeight.bold),maxLines: 1,),
                                                        Text("Delivered",style: TextStyle(color: Colors.green,fontWeight: FontWeight.bold),),
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
                                Text('Vendors list',style: TextStyle(fontSize:18,color: darkBlue,fontWeight: FontWeight.bold),),
                                Text('  (10km radius)',style: TextStyle(color: Colors.black45),),
                              ],
                            ),
                            InkWell(
                              onTap: (){
                                print('see more..');
                              },
                              child: Row(
                                children: [
                                  Text('See All',style: TextStyle(color: lightPink,fontWeight: FontWeight.bold),),
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
                            padding: EdgeInsets.only(left: 15,right: 15),
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
                                      Text('Eggless ',style: TextStyle(color: darkBlue,fontWeight: FontWeight.bold),),
                                      CupertinoSwitch(
                                        value: egglesSwitch,
                                        onChanged: (bool? val){
                                          setState(() {
                                            egglesSwitch = val!;
                                            
                                          });
                                        },
                                        activeColor: Colors.green,
                                      )
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
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15)
                                    ),
                                    child: Container(
                                      margin: EdgeInsets.all(5),
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
                                                image: NetworkImage("https://cutewallpaper.org/21/happy-birthday-cake-image-hd/Birthday-Cake-Pictures-Download-Besttextmsgs.com.jpg"),
                                              )
                                            ),
                                          ),
                                          Container(
                                            padding: EdgeInsets.only(left: 10),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                                              children: [
                                                Text('Surya prakash',style: TextStyle(
                                                    color: darkBlue,fontWeight: FontWeight.bold,fontSize: 18
                                                ),),
                                                Row(
                                                  children: [
                                                    RatingBar.builder(
                                                        initialRating: 4.1,
                                                        minRating: 1,
                                                        direction: Axis.horizontal,
                                                        allowHalfRating: true,
                                                        itemCount: 5,
                                                        itemSize: 18,
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
                                                        color: darkBlue,fontWeight: FontWeight.bold,fontSize: 16
                                                    ),)
                                                  ],
                                                ),
                                                Container(
                                                  width: 220,
                                                  child: Text("Special velvet chocolate cake",style: TextStyle(
                                                      color: Colors.black54
                                                  ),maxLines: 1,),
                                                ),
                                                Container(
                                                  height: 1,
                                                  width: 220,
                                                  color: Colors.black26,
                                                ),
                                                Container(
                                                  width: 220,
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text('DELIVERY FREE',style: TextStyle(
                                                          color: Colors.orange,fontSize: 11
                                                      ),),
                                                      Text('Only eggless cake',style: TextStyle(
                                                          color: Colors.black,fontSize: 11,fontWeight: FontWeight.bold
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
