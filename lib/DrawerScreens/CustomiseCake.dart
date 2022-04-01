import 'package:cakey/DrawerScreens/VendorsList.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class CustomiseCake extends StatefulWidget {
  const CustomiseCake({Key? key}) : super(key: key);

  @override
  State<CustomiseCake> createState() => _CustomiseCakeState();
}

class _CustomiseCakeState extends State<CustomiseCake> {

  //Colors code
  Color lightGrey = Color(0xffF5F5F5);
  Color darkBlue = Color(0xffF213959);
  Color lightPink = Color(0xffFE8416D);

  //Font family
  String poppins = "Poppins";

  //main variables
  bool egglesSwitch = true;

  var weight = [
    "1.5Kg",
    "2 Kg",
    "3 Kg",
    "5 Kg"
  ];

  var cakeTowers = ["2","3","5","8"];

  List<bool> selwIndex = [];

  List<bool> selCakeTower = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body:SingleChildScrollView(
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
                          Text('Delivery to',style: TextStyle(color: Colors.black54,
                              fontWeight: FontWeight.bold,fontFamily: "Poppins"),)
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
              //Main widgets....
               Container(
                 height: MediaQuery.of(context).size.height*0.8,
                 child: SingleChildScrollView(
                    child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Text("What Makes Yours Tastier Than The Rest? Customize To Your Heart's",
                                style: TextStyle(color: darkBlue,fontSize: 17,fontFamily: "Poppins",fontWeight: FontWeight.bold),
                              ),
                            ),

                            //Egg Eggless switch
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
                                    fontWeight: FontWeight.bold,fontFamily: "Poppins"),),
                              ],
                            ),

                            //Category Text
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Text("Select Category",
                                style: TextStyle(color: darkBlue,fontSize: 14,fontFamily: "Poppins",fontWeight: FontWeight.bold),
                              ),
                            ),

                            //Category stacks ()....
                            Container(
                              padding: EdgeInsets.all(10),
                              child: Wrap(
                                runSpacing: 5.0,
                                spacing: 5.0,
                                children: [
                                  Stack(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(5),
                                        child: Container(
                                          padding: EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                              border: Border.all(color: lightPink,width: 1),
                                              borderRadius: BorderRadius.circular(8)
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.cake_outlined,color: lightPink,),
                                              SizedBox(width: 10,),
                                              Text('Others',style: TextStyle(
                                                  fontFamily: "Poppins",
                                                  color: Colors.black26
                                              ),)
                                            ],
                                          ),
                                        ),
                                      ),
                                      // Positioned(
                                      //   right: 0,
                                      //   child: Icon(Icons.check_circle,color: Colors.green,),
                                      // )
                                    ],
                                  ),
                                  Stack(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(5),
                                        child: Container(
                                          padding: EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                              border: Border.all(color: lightPink,width: 1),
                                              borderRadius: BorderRadius.circular(8)
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.cake_outlined,color: lightPink,),
                                              SizedBox(width: 10,),
                                              Text('Birthday',style: TextStyle(
                                                  fontFamily: "Poppins",
                                                  color: Colors.black26
                                              ),)
                                            ],
                                          ),
                                        ),
                                      ),
                                      // Positioned(
                                      //   right: 0,
                                      //   child: Icon(Icons.check_circle,color: Colors.green,),
                                      // )
                                    ],
                                  ),
                                  Stack(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(5),
                                        child: Container(
                                          padding: EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                              border: Border.all(color: lightPink,width: 1),
                                              borderRadius: BorderRadius.circular(8)
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.cake_outlined,color: lightPink,),
                                              SizedBox(width: 10,),
                                              Text('Wedding',style: TextStyle(
                                                  fontFamily: "Poppins",
                                                  color: Colors.black26
                                              ),)
                                            ],
                                          ),
                                        ),
                                      ),
                                      // Positioned(
                                      //   right: 0,
                                      //   child: Icon(Icons.check_circle,color: Colors.green,),
                                      // )
                                    ],
                                  ),
                                  Stack(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(5),
                                        child: Container(
                                          padding: EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                              border: Border.all(color: lightPink,width: 1),
                                              borderRadius: BorderRadius.circular(8)
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.cake_outlined,color: lightPink,),
                                              SizedBox(width: 10,),
                                              Text('Party',style: TextStyle(
                                                  fontFamily: "Poppins",
                                                  color: Colors.black26
                                              ),)
                                            ],
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        right: 0,
                                        child: Icon(Icons.check_circle,color: Colors.green,),
                                      )
                                    ],
                                  ),
                                  Stack(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(5),
                                        child: Container(
                                          padding: EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                              border: Border.all(color: lightPink,width: 1),
                                              borderRadius: BorderRadius.circular(8)
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.cake_outlined,color: lightPink,),
                                              SizedBox(width: 10,),
                                              Text('Farewell',style: TextStyle(
                                                  fontFamily: "Poppins",
                                                  color: Colors.black26
                                              ),)
                                            ],
                                          ),
                                        ),
                                      ),
                                      // Positioned(
                                      //   right: 0,
                                      //   child: Icon(Icons.check_circle,color: Colors.green,),
                                      // )
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            //Shapes....flav...toppings
                            ExpansionTile(
                              title: Text('Shapes',style: TextStyle(
                                  fontFamily: "Poppins",fontSize: 13,fontWeight: FontWeight.bold
                              ),),
                              subtitle:Text('Selected shape',style: TextStyle(
                                  fontFamily: "Poppins",fontSize: 15,fontWeight: FontWeight.w500
                              ),),
                              children: [
                                Text('Shapes.....',style: TextStyle(
                                    fontFamily: "Poppins",fontSize: 13,fontWeight: FontWeight.bold
                                ),),
                              ],
                            ),
                            Container(
                              margin: EdgeInsets.only(left: 8,right: 8),
                              height: 0.5,
                              color: Colors.black26,
                            ),
                            ExpansionTile(
                              title: Text('Flavours',style: TextStyle(
                                  fontFamily: "Poppins",fontSize: 13,fontWeight: FontWeight.bold
                              ),),
                              subtitle:Text('Selected Flavours',style: TextStyle(
                                  fontFamily: "Poppins",fontSize: 15,fontWeight: FontWeight.w500
                              ),),
                              children: [
                                Text('Flavours.....',style: TextStyle(
                                    fontFamily: "Poppins",fontSize: 13,fontWeight: FontWeight.bold
                                ),),
                              ],
                            ),
                            Container(
                              margin: EdgeInsets.only(left: 8,right: 8),
                              height: 0.5,
                              color: Colors.black26,
                            ),
                            ExpansionTile(
                              title: Text('Toppings',style: TextStyle(
                                  fontFamily: "Poppins",fontSize: 13,fontWeight: FontWeight.bold
                              ),),
                              subtitle:Text('Selected Toppings',style: TextStyle(
                                  fontFamily: "Poppins",fontSize: 15,fontWeight: FontWeight.w500
                              ),),
                              children: [
                                Text('Toppings.....',style: TextStyle(
                                    fontFamily: "Poppins",fontSize: 13,fontWeight: FontWeight.bold
                                ),),
                              ],
                            ),
                            Container(
                              margin: EdgeInsets.only(left: 8,right: 8),
                              height: 0.5,
                              color: Colors.black26,
                            ),

                            //Weight...
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Text("Weight",
                                style: TextStyle(color: darkBlue,fontSize: 14,fontFamily: "Poppins",fontWeight: FontWeight.bold),
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
                                                fontFamily: "Poppins",color: selwIndex[index]?Colors.white:darkBlue
                                            ),
                                          ),
                                        ),
                                      );
                                    })),

                            //Tower...
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Text("Cake Tower",
                                style: TextStyle(color: darkBlue,fontSize: 14,fontFamily: "Poppins",fontWeight: FontWeight.bold),
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
                                      selCakeTower.add(false);
                                      return InkWell(
                                        onTap: () {
                                          setState(() {
                                            for (int i = 0; i < selCakeTower.length; i++) {
                                              if (i == index) {
                                                selCakeTower[i] = true;
                                              } else {
                                                selCakeTower[i] = false;
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
                                              color: selCakeTower[index]
                                                  ? Colors.pink
                                                  : Colors.white),
                                          child:
                                          Text(
                                            cakeTowers[index],
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontFamily: "Poppins",color: selCakeTower[index]?Colors.white:darkBlue
                                            ),
                                          ),
                                        ),
                                      );
                                    })),

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
                                      onPressed: (){},
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
            ],
          ),
      ),
    );
  }
}
