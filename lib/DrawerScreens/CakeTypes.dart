import 'package:cakey/screens/CakeDetails.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class CakeTypes extends StatefulWidget {
  const CakeTypes({Key? key}) : super(key: key);

  @override
  State<CakeTypes> createState() => _CakeTypesState();
}

class _CakeTypesState extends State<CakeTypes> {
  //key....
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  //colors...
  Color lightGrey = Color(0xffF5F5F5);
  Color darkBlue = Color(0xffF213959);
  Color lightPink = Color(0xffFE8416D);
  String poppins = "Poppins";

  //variables
  bool egglesSwitch = true;
  bool _show = true;
  var cakeCate = [
    "Birthday",
    "Anniversary",
    "Trending",
  ];


  List<bool> selIndex = [];
  RangeValues rangeValues = RangeValues(10, 30);

  //region Dialogs

  //filter bottom.....
  void showFilterBottom(){
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(topRight: Radius.circular(20),topLeft: Radius.circular(20)),
        ),
        isScrollControlled: true,
        context: context,
        builder: (context){
          return StatefulBuilder(
              builder: (BuildContext context,
                  void Function(void Function()) setState){
                return Container(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: Container(
                    padding: EdgeInsets.all(15),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(height: 8,),
                          //Title text...
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('FILTER',style: TextStyle(color: darkBlue,fontSize: 18,
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
                          SizedBox(height: 8,),
                          Container(
                            height: 1.0,
                            color: Colors.black26,
                          ),
                          SizedBox(height: 8,),
                          //Price Slider...
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text('Price Range',style: TextStyle(color: darkBlue,fontSize: 18,
                                fontWeight: FontWeight.bold,fontFamily: "Poppins"),),
                          ),
                          SizedBox(height: 4,),
                          //Price range slider .....
                          RangeSlider(
                              values:rangeValues,
                              max: 100,
                              min: 0,
                              divisions: 10,
                              labels: RangeLabels(
                                rangeValues.start.round().toString(),
                                rangeValues.end.round().toString(),
                              ),
                              onChanged: (RangeValues values){
                                setState((){
                                  rangeValues = values;
                                });
                                print(values);
                              }
                          ),
                          SizedBox(height: 8,),
                          Container(
                            height: 1.0,
                            color: Colors.black26,
                          ),
                          ExpansionTile(
                              title: Text('Flavours',style: TextStyle(fontFamily: "Poppins",
                                  fontWeight: FontWeight.bold),),
                            subtitle: Text('Flavours',style: TextStyle(fontFamily: "Poppins",),),
                            children: [
                              Text("hello")
                            ],
                          ),
                          Container(
                            height: 1.0,
                            color: Colors.black26,
                          ),
                          ExpansionTile(
                            title: Text('Shapes',style: TextStyle(fontFamily: "Poppins",
                                fontWeight: FontWeight.bold),),
                            subtitle: Text('Flavours',style: TextStyle(fontFamily: "Poppins",),),
                            children: [
                              Text("hello")
                            ],
                          ),
                          Container(
                            height: 1.0,
                            color: Colors.black26,
                          ),
                          ExpansionTile(
                            title: Text('Cake Toppings',style: TextStyle(fontFamily: "Poppins",
                                fontWeight: FontWeight.bold),),
                            subtitle: Text('Flavours',style: TextStyle(fontFamily: "Poppins",),),
                            children: [
                              Text("hello")
                            ],
                          ),
                          Container(
                            height: 1.0,
                            color: Colors.black26,
                          ),

                          SizedBox(height: 10,),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                height: 45,
                                width: 120,
                                child: RaisedButton(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  color: lightPink,
                                  onPressed: (){
                                    Navigator.pop(context);
                                  },
                                  child: Text("FILTER",style: TextStyle(
                                      color: Colors.white,fontWeight: FontWeight.bold,fontFamily: "Poppins"
                                  ),),
                                ),
                              ),
                              TextButton(
                                  onPressed: (){},
                                  child:  Text("CLEAR",style: TextStyle(
                                      color: lightPink,fontWeight: FontWeight.bold,fontFamily: "Poppins",
                                      decoration: TextDecoration.underline
                                  ),),
                              )
                            ],
                          )

                        ],
                      ),
                    ),
                  ),
                );
              }
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
        bottomSheet:_show?BottomSheet(
          onClosing: () {
          },
          builder: (BuildContext context) {
            return Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(15),
                  height: 100,
                  color: Colors.white,
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        color: Colors.red[100]
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('DO YOU WANT A THEME CAKE?',style: TextStyle(
                            color: lightPink,fontWeight: FontWeight.bold,fontFamily: poppins
                        ),),
                        Icon(Icons.cake,color: lightPink,size: 50,)
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: width*0.86,
                  top: -6,
                  child: IconButton(
                      onPressed: (){
                        setState(() {
                          _show = false;
                        });
                      },
                      icon: Icon(Icons.cancel_rounded,color: Colors.red,size: 30,)
                  ),
                )
              ],
            );
          },
        ):null,
        resizeToAvoidBottomInset: true,
        key: _scaffoldKey,
        appBar: AppBar(
          leading:IconButton(
            icon:  Icon(
              Icons.arrow_back_ios,
              color: lightPink,
            ),
            onPressed: (){
              Navigator.pop(context);
            },
          ),
          title: Text('TYPES OF CAKES',
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
        body: Column(
          children: [
            Container(
              padding: EdgeInsets.only(left: 10, top: 8, bottom: 15),
              color: lightGrey,
              child: Column(
                children: [
                  Container(
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: Colors.red,
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        Text(
                          'Delivery to',
                          style: TextStyle(
                              color: Colors.black54,
                              fontWeight: FontWeight.bold,
                              fontFamily: poppins),
                        )
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 8),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'California',
                      style: TextStyle(
                          fontFamily: poppins,
                          fontSize: 15,
                          color: darkBlue,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: height * 0.79,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: Svg("assets/images/splash.svg"), fit: BoxFit.cover)),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    //Title text
                    Container(
                      padding: EdgeInsets.all(10),
                      width: width,
                      child: Text(
                        'Find And Order Your\nFavourite Cakes ',
                        style: TextStyle(
                            color: darkBlue,
                            fontWeight: FontWeight.bold,
                            fontSize: 18),
                      ),
                    ),
                    //search bar
                    Container(
                      padding: EdgeInsets.all(10),
                      alignment: Alignment.center,
                      child: Row(
                        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: width * 0.79,
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
                          SizedBox(
                            width: 5,
                          ),
                          Container(
                            width: width * 0.13,
                            height: 50,
                            decoration: BoxDecoration(
                                color: lightPink,
                                borderRadius: BorderRadius.circular(8)
                            ),
                            child: IconButton(
                                splashColor: Colors.black26,
                                onPressed: () {
                                  print(MediaQuery.of(context).size.width * 0.13);
                                  FocusScope.of(context).unfocus();
                                  setState(() {
                                    _show = true;
                                  });
                                  showFilterBottom();
                                },
                                icon: Icon(
                                  Icons.tune,
                                  color: Colors.white,
                                )),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Transform.scale(
                                scale: 0.7,
                                child: CupertinoSwitch(
                                  thumbColor: Colors.white,
                                  value: egglesSwitch,
                                  onChanged: (bool? val) {
                                    setState(() {
                                      egglesSwitch = val!;
                                    });
                                  },
                                  activeColor: Colors.green,
                                ),
                              ),
                              Text(
                                egglesSwitch ? 'Eggless' : 'Egg',
                                style: TextStyle(
                                    color: darkBlue,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: poppins),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(Icons.favorite_border, color: lightPink),
                              Text(
                                ' Shapes',
                                style: TextStyle(
                                    color: darkBlue,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: poppins),
                              ),
                              SizedBox(
                                width: 10,
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                        height: height * 0.08,
                        width: width,
                        child: ListView.builder(
                            itemCount: cakeCate.length,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, index) {
                              selIndex.add(false);
                              return InkWell(
                                onTap: () {
                                  setState(() {
                                    for (int i = 0; i < selIndex.length; i++) {
                                      if (i == index) {
                                        selIndex[i] = true;
                                      } else {
                                        selIndex[i] = false;
                                      }
                                    }
                                  });
                                },
                                child: Container(
                                  padding: EdgeInsets.only(
                                      left: 20, right: 20, top: 6, bottom: 6),
                                  margin: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: lightPink,
                                        width: 1.5,
                                      ),
                                      color: selIndex[index]
                                          ? Colors.red[100]
                                          : Colors.white),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.cake_outlined,
                                        color: lightPink,
                                      ),
                                      Text(
                                        " " + cakeCate[index],
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontFamily: poppins),
                                      )
                                    ],
                                  ),
                                ),
                              );
                            })),

                    StaggeredGridView.countBuilder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.all(12.0),
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 12,
                      itemCount: 20,
                      itemBuilder: (BuildContext context, int index) {
                        return
                          index==0?GestureDetector(
                            onTap: (){
                              Navigator.of(context).push(
                                PageRouteBuilder(
                                  pageBuilder: (context, animation, secondaryAnimation) => CakeDetails(),
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
                            child: Column(
                              children: [
                                Text('Found\n55 Items',style: TextStyle(
                                    color: darkBlue,fontWeight: FontWeight.bold,fontSize: 16
                                )),
                                SizedBox(height: 20,),
                                Container(
                                  height:height*0.3,
                                  padding:EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14),
                                    color: Colors.white,
                                    boxShadow: [BoxShadow(blurRadius: 2, color:Colors.black26, spreadRadius: 2)],
                                  ),
                                  child:Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      CircleAvatar(
                                        radius: 45,
                                        backgroundImage:NetworkImage("https://w0.peakpx.com/wallpaper/863/651/HD-wallpaper-red-cake-pastries-desserts-cakes-strawberry-cake-berry-cake.jpg"),
                                      ),
                                      Text('Choco Toppings Cake cake cake cake',maxLines: 2,overflow:TextOverflow.ellipsis,style: TextStyle(
                                          color: darkBlue,fontWeight: FontWeight.bold,fontSize: 15
                                      )),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('₹ 800',style: TextStyle(
                                              color: lightPink,fontWeight: FontWeight.bold,fontSize: 14
                                          )),
                                          Container(
                                            padding: EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                                color: Colors.black26,
                                                borderRadius: BorderRadius.circular(8)
                                            ),
                                            child: Text('1.5 Kg',style: TextStyle(
                                                color: Colors.black,fontWeight: FontWeight.bold,fontSize: 12
                                            )),
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ):
                          GestureDetector(
                            onTap: (){
                              Navigator.of(context).push(
                                PageRouteBuilder(
                                  pageBuilder: (context, animation, secondaryAnimation) => CakeDetails(),
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
                            child: Column(
                              children: [
                                Container(
                                  margin: EdgeInsets.only(top: 10),
                                  height:height*0.3,
                                  padding:EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14),
                                    color: Colors.white,
                                    boxShadow: [BoxShadow(blurRadius: 2, color:Colors.black26, spreadRadius: 2)],
                                  ),
                                  child:Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      CircleAvatar(
                                        radius: 45,
                                        backgroundImage:NetworkImage("https://w0.peakpx.com/wallpaper/863/651/HD-wallpaper-red-cake-pastries-desserts-cakes-strawberry-cake-berry-cake.jpg"),
                                      ),
                                      Text('Choco Toppings Cake cake cake cake',maxLines: 2,overflow:TextOverflow.ellipsis,style: TextStyle(
                                          color: darkBlue,fontWeight: FontWeight.bold,fontSize: 15
                                      )),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('₹ 800',style: TextStyle(
                                              color: lightPink,fontWeight: FontWeight.bold,fontSize: 14
                                          )),
                                          Container(
                                            padding: EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                                color: Colors.black26,
                                                borderRadius: BorderRadius.circular(8)
                                            ),
                                            child: Text('1.5 Kg',style: TextStyle(
                                                color: Colors.black,fontWeight: FontWeight.bold,fontSize: 12
                                            )),
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          );
                      },
                      staggeredTileBuilder: (int index) => StaggeredTile.fit(1),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
  }
}
