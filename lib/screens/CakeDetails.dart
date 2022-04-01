import 'package:cakey/DrawerScreens/VendorsList.dart';
import 'package:cakey/screens/CheckOut.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class CakeDetails extends StatefulWidget {
  const CakeDetails({Key? key}) : super(key: key);

  @override
  State<CakeDetails> createState() => _CakeDetailsState();
}

class _CakeDetailsState extends State<CakeDetails> {

  //colors.....
  String poppins = "Poppins";
  Color darkBlue = Color(0xffF213959);
  Color lightPink = Color(0xffFE8416D);
  Color lightGrey = Color(0xffF5F5F5);

  List shapes = ['Circle','Rectangle',];
  List flavour = ['Chocolate','Strawberry','Vennila','Blueberry'];
  List topings = ['Chocolate','Strawberry','Fruits',''];

  var weight = [
    "1.5Kg",
    "2 Kg",
    "3 Kg",
    "5 Kg"
  ];

  List<bool> selwIndex = [];

  //cake name or title......
  String cakeName = "Sweet creamy cup cake";

  //region Functions

  //theme select bottom sheet......
  void themesBottomSheet() async{
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
        ),
        context: context,
        builder: (BuildContext context){
          return Container(
            height: MediaQuery.of(context).size.height*0.5,
            margin: EdgeInsets.only(top: 20),
            child: Column(
              children: [
                ListTile(
                  title: Text('CAKE  TOPPINGS',style: TextStyle(fontWeight: FontWeight.bold,color: darkBlue,fontSize: 20),),
                  trailing: Container(
                      width: 30,
                      height: 30,alignment: Alignment.center,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),color: Colors.grey[400]),
                      child: IconButton(onPressed: (){Navigator.pop(context);}, icon: Icon(Icons.close,size: 16,color: lightPink,))
                  ),
                ),
                ListTile(
                  title: Text('Theme'),
                ),
              ],
            ),
          );
        }

    );
  }



  //endregion

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:SafeArea(
        child: NestedScrollView(
            headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled){
              return <Widget>[
                SliverAppBar(
                  title: innerBoxIsScrolled?Text("$cakeName",style: TextStyle(
                    fontSize: 13,color: darkBlue
                  ),):
                      Text(""),
                  expandedHeight: 300.0,
                  leading: Container(
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
                  // forceElevated: innerBoxIsScrolled,
                  //floating: true,
                  pinned: true,
                  floating: true,
                  actions: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        InkWell(
                          onTap: () {
                            print("Scrolled $innerBoxIsScrolled");
                         } ,
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
                    SizedBox(width: 10,),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(blurRadius: 3, color: Colors.black, spreadRadius: 0)],
                      ),
                      child: InkWell(
                        onTap: (){

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
                  backgroundColor: lightGrey,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      margin: EdgeInsets.all(7),
                      height: 250,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.black12,
                            image: DecorationImage(
                                image:NetworkImage( "https://newcastlebeach.org/images/mousse-9.jpg"),fit: BoxFit.cover
                            )
                        ),
                      width: double.infinity,
                    ),
                  ),
                ),
              ];
            },
          body: SingleChildScrollView(
            child:  SafeArea(
              child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                RatingBar.builder(
                                  initialRating: 4.1,
                                  minRating: 1,
                                  direction: Axis.horizontal,
                                  allowHalfRating: true,
                                  itemCount: 5,
                                  itemSize: 15,
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
                            Row(
                              children: [
                                Icon(Icons.egg,color: Colors.amber,),
                                Text('Eggless',style: TextStyle(color: Colors.amber,fontFamily: poppins),)
                              ],
                            )
                          ],
                        ),
                      ),
                      Container(
                          margin:EdgeInsets.symmetric(horizontal: 15),
                          child: Divider(color: Colors.grey,)
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              child: Text('$cakeName',
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 18,color: darkBlue,
                                    fontWeight:FontWeight.w600),),
                            ),
                            Container(
                              child: Text('₹ 720',style: TextStyle(fontSize: 20,
                                  color: lightPink,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: "Poppins"
                              ),),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.all(10),
                        child: Text("Context as to why/how it works. This can help future users learn and eventually apply "
                            "that knowledge to their own code. You are also likely to have positive feedback/upvotes from users, when the code is explained.",style: TextStyle(color: Colors.grey),),
                      ),
                      Container(margin:EdgeInsets.symmetric(horizontal: 15),child: Divider(color: Colors.pink[100],)),

                      IntrinsicHeight(
                        child: Container(
                          margin: EdgeInsets.all(10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Flavours',style: TextStyle(fontSize: 14,color: Colors.grey),),
                                    Text('Chocolate',style: TextStyle(color: darkBlue,fontSize: 16,fontWeight: FontWeight.w600),)
                                  ],
                                ),
                              ),
                              VerticalDivider(color: Colors.pink[100],),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Shapes',style: TextStyle(fontSize: 14,color: Colors.grey),),
                                    Text('Round',style: TextStyle(color: darkBlue,fontSize: 16,fontWeight: FontWeight.w600),)
                                  ],
                                ),
                              ),
                              VerticalDivider(color: Colors.pink[100],),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Cake Toppings',style: TextStyle(fontSize: 14,color: Colors.grey),),
                                    Text('Strawberry',style: TextStyle(color: darkBlue,fontSize: 16,fontWeight: FontWeight.w600),)
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 15,vertical: 10),
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                            color: Colors.pink[100],
                            borderRadius: BorderRadius.circular(10)
                        ),
                        child: Column(
                          children: [
                            ListTile(
                              leading: Text('Theme',style: TextStyle(fontFamily: "Poppins"),),
                              trailing: Container(
                                width: 30,
                                height: 30,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                  boxShadow: [BoxShadow(blurRadius: 3, color:Colors.black26, spreadRadius: 1)],
                                ),
                                child: Icon(Icons.add,color: darkBlue,),
                              ),
                            ),
                            ListTile(
                              leading: Text('Flavours',style: TextStyle(fontFamily: "Poppins"),),
                              trailing: Container(
                                width: 30,
                                height: 30,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [BoxShadow(blurRadius: 3, color:Colors.black26, spreadRadius: 1)],
                                    color: Colors.white
                                ),
                                child: Icon(Icons.add,color: darkBlue,),
                              ),
                            ),
                            ListTile(
                              leading: Text('Shapes',style: TextStyle(fontFamily: "Poppins"),),
                              trailing: Container(
                                width: 30,
                                height: 30,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    boxShadow: [BoxShadow(blurRadius: 3, color:Colors.black26, spreadRadius: 1)],
                                    shape: BoxShape.circle,
                                    color: Colors.white
                                ),
                                child: Icon(Icons.add,color: darkBlue,),
                              ),
                            ),
                            ListTile(
                              leading: Text('Cake Toppings',style: TextStyle(fontFamily: "Poppins"),),
                              trailing: Container(
                                width: 30,
                                height: 30,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                    boxShadow: [BoxShadow(blurRadius: 3, color:Colors.black26, spreadRadius: 1)],
                                ),
                                child: Icon(Icons.add,color: darkBlue,),
                              ),
                            )
                          ],
                        ),
                      ),
                      Container(
                          height: MediaQuery.of(context).size.height * 0.07,
                          width: MediaQuery.of(context).size.width,
                          margin: EdgeInsets.symmetric(horizontal: 10),
                          //  color: Colors.grey,
                          child: ListView.builder(
                              itemCount: weight.length,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) {
                                selwIndex.add(false);
                                return InkWell(
                                  onTap: () {
                                    setState(() {
                                      for (int i = 0; i < selwIndex.length; i++) {
                                        if (i == index) {
                                          selwIndex[i] = true;
                                        } else {
                                          selwIndex[i] = false;
                                        }
                                      }
                                    });
                                  },
                                  child:Container(
                                    width: 60,
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.all(10),
                                    margin: EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: lightPink,
                                          width: 1,
                                        ),
                                        color: selwIndex[index]
                                            ? Colors.pink
                                            : Colors.white),
                                    child:
                                    Text(
                                      weight[index],
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontFamily: poppins,color: selwIndex[index]?Colors.white:darkBlue
                                      ),
                                    ),
                                  ),
                                );
                              })),

                      Container(margin:EdgeInsets.symmetric(horizontal: 15),child: Divider(color: Colors.pink[100],)),

                      Container(
                        //margin
                          margin: EdgeInsets.all(10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(' Message on the cake',style: TextStyle(fontFamily: poppins,color: Colors.grey),),
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: 10),
                                child: TextField(
                                  decoration: InputDecoration(
                                    hintText: 'Type here..',
                                    prefixIcon: Icon(Icons.message_outlined,color: lightPink,)
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top:10),
                                child: Text(' Special request to bakers',style: TextStyle(fontFamily: poppins,color: Colors.grey),),
                              ),
                              Container(
                                margin: EdgeInsets.all(10),
                                child: TextField(
                                  decoration: InputDecoration(
                                      filled: true,
                                      fillColor:Colors.black12,
                                      hintText: 'Type here..',
                                      border: OutlineInputBorder(
                                          borderSide: BorderSide.none,
                                          borderRadius: BorderRadius.circular(8)
                                      ),
                                  ),
                                  maxLines: 8,
                                  minLines: 5,
                                ),
                              ),
                              Row(
                                children: [
                                  SizedBox(width: 8,),
                                  Text('Delivery Date',style: TextStyle(
                                      color: Colors.grey,
                                      fontFamily: "Poppins"
                                  ),),
                                  SizedBox(width: 65,),
                                  Text('Delivery Session',style: TextStyle(
                                      color: Colors.grey,
                                      fontFamily: "Poppins"
                                  ),)
                                ],
                              ),
                              Row(
                                children: [
                                  SizedBox(width: 5,),
                                  OutlinedButton(
                                    onPressed: (){
                                      showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now(),
                                        lastDate: DateTime(2050),
                                        firstDate:DateTime(2022),
                                      );
                                    },
                                    child: Row(
                                      children: [
                                        Text('31-03-2022',style: TextStyle(
                                            fontWeight: FontWeight.bold,color: Colors.grey,
                                            fontSize: 13
                                        ),),
                                        SizedBox(width: 10,),
                                        Icon(Icons.date_range_outlined,color:darkBlue)
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 30,),
                                  OutlinedButton(
                                    onPressed: (){
                                      showDialog(
                                          context: context,
                                          builder: (context){
                                            return AlertDialog(
                                              title: Text("Select delivery session",style: TextStyle(
                                                color: darkBlue,fontFamily: "Poppins",fontSize: 16,)),
                                              content:Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  ListTile(
                                                    title: Text('Morning',style: TextStyle(
                                                      color: darkBlue,fontFamily: "Poppins")),
                                                  ),
                                                  ListTile(
                                                    title: Text('Afternoon',style: TextStyle(
                                                        color: darkBlue,fontFamily: "Poppins")),
                                                  ),
                                                  ListTile(
                                                    title: Text('Evening',style: TextStyle(
                                                        color: darkBlue,fontFamily: "Poppins")),
                                                  ),
                                                  ListTile(
                                                    title: Text('Night',style: TextStyle(
                                                        color: darkBlue,fontFamily: "Poppins")),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }
                                      );
                                    },
                                    child: Row(
                                      children: [
                                        Text('Morning',style: TextStyle(
                                            fontWeight: FontWeight.bold,color: Colors.grey,
                                            fontSize: 13
                                        ),),
                                        SizedBox(width: 10,),
                                        Icon(Icons.keyboard_arrow_down,color:darkBlue)
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          )),

                      Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: Text(' Address',style: TextStyle(fontFamily: poppins,color: Colors.grey),),
                      ),

                      ListTile(
                        title: Text('1/4 vellandipalaym , thekkalur , 641654  ',
                          style: TextStyle(fontFamily: poppins,color: Colors.grey,fontSize: 13),
                        ),
                        trailing: Icon(Icons.verified_rounded,color: Colors.green),
                      ),

                      Container(
                        margin: EdgeInsets.only(left: 10),
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                            onPressed: (){},
                            child: const Text('add new address',style: const TextStyle(
                                color: Colors.orange,fontFamily: "Poppins",decoration: TextDecoration.underline
                            ),)
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(10.0),
                        color: Colors.black12,
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text('Select Vendors',style: TextStyle(fontSize:18,
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
                            Container(
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
                                                            color: Colors.black54,fontWeight: FontWeight.bold,fontSize: 13,fontFamily: poppins
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
                            SizedBox(height: 15,),
                            Container(
                              height: 50,
                              width: 200,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25)
                              ),
                              child: RaisedButton(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25)
                                  ),
                                  onPressed: (){
                                    Navigator.of(context).push(
                                      PageRouteBuilder(
                                        pageBuilder: (context, animation, secondaryAnimation) => CheckOut(),
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
                                  color: lightPink,
                                  child: Text("ORDER NOW",style: TextStyle(
                                    color: Colors.white,fontWeight: FontWeight.bold
                                  ),),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ),
          )
        ),
      ),
    );
    // );
    //  );
  }
}

