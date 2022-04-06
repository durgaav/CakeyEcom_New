import 'package:cakey/DrawerScreens/VendorsList.dart';
import 'package:cakey/screens/CheckOut.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import '../ContextData.dart';
import 'Profile.dart';

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

  //Lists...
  List shapes = ['Circle','Rectangle','heart','square','octagan'];
  List flavour = ['Chocolate','Strawberry','Vennila','Blueberry','Oreo','New mango flav'];
  List topings = ['Chocolate drops','Padham nuts','Fruit nuts','Choco nuts','Sugar powder','Small Candies'];
  var weight = ["1.5Kg", "2 Kg", "3 Kg", "5 Kg"];
  List<bool> selwIndex = [];
  List<bool> toppingsVal = [];
  List<int> flavVal = [];
  List<String> fixedToppings = [];

  //Strings......
  String cakeName = "Sweet creamy cup cake";
  String profileUrl = "";
  String deliverDate = '00-00-0000';
  String deliverSession = 'Morning';
  String fixedFlavour = '';
  String fixedShape = '';

  //ints
  int flavGrpValue = 0;
  int shapeGrpValue = 0;

  //region Alerts

  //theme select bottom sheet......
  void showThemeBottomSheet() async{
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)
          ),
        ),
        context: context,
        builder: (BuildContext context){
          return Container(
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                SizedBox(height: 8,),
                //Title text...
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('THEMES',style: TextStyle(color: darkBlue,fontSize: 18,
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
                    child: Text("ADD",style: TextStyle(
                        color: Colors.white,fontWeight: FontWeight.bold,fontFamily: "Poppins"
                    ),),
                  ),
                ),
              ],
            ),
          );
        }
    );
  }

  //cake toppings bottom sheet...
  void showCakeToppingsSheet(){
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
        ),
        context: context,
        builder: (BuildContext context){
          return StatefulBuilder(
              builder: (BuildContext context,void Function(void Function()) setState)
              {
                return Container(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 8,),
                      //Title text...
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('CAKE TOPPINGS',style: TextStyle(color: darkBlue,fontSize: 18,
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

                      Container(
                        height: 300,
                        child: Scrollbar(
                          child: ListView.builder(
                              itemCount: topings.length,
                              shrinkWrap: true,
                              itemBuilder: (context,index){
                                toppingsVal.add(false);
                                return ListTile(
                                  onTap: (){
                                    setState((){
                                      if(toppingsVal[index]==false){
                                        toppingsVal[index]=true;

                                        if(fixedToppings.contains(topings[index])){
                                          print('exists...');
                                        }else{
                                          fixedToppings.add(topings[index]);
                                        }
                                      }else{
                                        fixedToppings.remove(topings[index]);
                                        toppingsVal[index]=false;
                                      }
                                    });
                                  },
                                  leading: Transform.scale(
                                    scale: 1.3,
                                    child: Checkbox(
                                      checkColor: Colors.white,
                                      fillColor: MaterialStateProperty.resolveWith((states) => Colors.green),
                                      value: toppingsVal[index],
                                      onChanged: (bool? value){
                                        print(value);
                                        setState((){
                                          if(toppingsVal[index]==false){
                                            toppingsVal[index]=true;
                                            fixedToppings[index] = topings[index];
                                          }else{
                                            fixedToppings[index] = 'index';
                                            toppingsVal[index]=false;
                                          }
                                        });
                                      },
                                      shape: CircleBorder(),
                                    ),
                                  ),
                                  title: Text("${topings[index]}",style: TextStyle(
                                    fontFamily: "Poppins",color: darkBlue
                                  ),),
                                );
                              }
                          ),
                        ),
                      ),

                      Container(
                        height: 45,
                        width: 120,
                        child: RaisedButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          color: lightPink,
                          onPressed: (){
                            saveFixedToppings();
                            Navigator.pop(context);
                          },
                          child: Text("ADD",style: TextStyle(
                              color: Colors.white,fontWeight: FontWeight.bold,fontFamily: "Poppins"
                          ),),
                        ),
                      ),
                    ],
                  ),
                );
              });
        }
    );
  }

  //Cake flavours sheet...
  void showCakeFlavSheet(){
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
        ),
        context: context,
        builder: (BuildContext context){
          return StatefulBuilder(
              builder: (BuildContext context,void Function(void Function()) setState)
              {
                return Container(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 8,),
                      //Title text...
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('FLAVOUR',style: TextStyle(color: darkBlue,fontSize: 18,
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

                      Container(
                        height: 300,
                        child: Scrollbar(
                          child: ListView.builder(
                              itemCount: flavour.length,
                              shrinkWrap: true,
                              itemBuilder: (context,index){
                                return RadioListTile(
                                        activeColor: Colors.green,
                                        title: Text("${flavour[index]}",style: TextStyle(
                                            fontFamily: "Poppins",color: darkBlue
                                        ),),
                                        value: index,
                                        groupValue: flavGrpValue,
                                        onChanged: (int? value){
                                          print(value);
                                          setState((){
                                            flavGrpValue = value!;
                                          });
                                        }
                                    );
                              }
                          ),
                        ),
                      ),

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
                            setState((){
                              saveFixedFlav(flavGrpValue);
                            });
                          },
                          child: Text("ADD",style: TextStyle(
                              color: Colors.white,fontWeight: FontWeight.bold,fontFamily: "Poppins"
                          ),),
                        ),
                      ),
                    ],
                  ),
                );
              });
        }
    );
  }

  //Cake Shapes bottom...
  void showCakeShapesSheet(){
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
        ),
        context: context,
        builder: (BuildContext context){
          return StatefulBuilder(
              builder: (BuildContext context,void Function(void Function()) setState)
              {
                return Container(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 8,),
                      //Title text...
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('SHAPES',style: TextStyle(color: darkBlue,fontSize: 18,
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

                      Container(
                        height: 300,
                        child: Scrollbar(
                          child: ListView.builder(
                              itemCount: shapes.length,
                              shrinkWrap: true,
                              itemBuilder: (context,index){
                                return RadioListTile(
                                    activeColor: Colors.green,
                                    title: Text("${shapes[index]}",style: TextStyle(
                                        fontFamily: "Poppins",color: darkBlue
                                    ),),
                                    value: index,
                                    groupValue: shapeGrpValue,
                                    onChanged: (int? value){
                                      print(value);
                                      setState((){
                                        shapeGrpValue = value!;
                                      });
                                    }
                                );
                              }
                          ),
                        ),
                      ),

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
                            setState((){
                              saveFixedShape(shapeGrpValue);
                            });
                          },
                          child: Text("ADD",style: TextStyle(
                              color: Colors.white,fontWeight: FontWeight.bold,fontFamily: "Poppins"
                          ),),
                        ),
                      ),
                    ],
                  ),
                );
              });
        }
    );
  }

  //Saving fixed flavour from bottomsheet
  void saveFixedFlav(int i){
    setState(() {
      fixedFlavour = flavour[i];
    });
  }

  //Saving fixed shape
  void saveFixedShape(int i){
    setState(() {
      fixedShape = shapes[i];
    });
  }

  //Saving fixed topping..
  void saveFixedToppings(){
    setState((){
      fixedToppings.removeWhere((element) => element=='index');
    });
    print(fixedToppings);
  }

  //endregion

  @override
  Widget build(BuildContext context) {
    profileUrl = context.watch<ContextData>().getProfileUrl();
    return Scaffold(
      body:SafeArea(
        child: NestedScrollView(
            headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled){
              return <Widget>[
                SliverAppBar(
                  title: innerBoxIsScrolled?Text("$cakeName",style: TextStyle(
                    color: darkBlue
                  ),): Text(""),
                  expandedHeight: 300.0,
                  leading: Container(
                    margin: const EdgeInsets.all(10),
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                          decoration: BoxDecoration(
                              color: Colors.grey,
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
                                color: Colors.grey,
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
                            "that knowledge to their own code. You are also likely to have positive feedback/upvotes from users, when the code is explained."
                          ,style: TextStyle(color: Colors.grey),),
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
                              trailing: GestureDetector(
                                onTap:(){
                                  showThemeBottomSheet();
                                },
                                child: Container(
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
                            ),
                            ListTile(
                              leading: Text('Flavours',style: TextStyle(fontFamily: "Poppins"),),
                              title: fixedFlavour.isNotEmpty?
                              GestureDetector(
                                onTap:(){
                                  setState(() {
                                    fixedFlavour = "";
                                  });
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  margin: EdgeInsets.only(right: 90),
                                  padding: EdgeInsets.only(top: 6,bottom: 6,left: 4),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    color: lightPink,
                                  ),
                                  child: Wrap(
                                    children: [
                                      Text('${fixedFlavour}',maxLines: 1,overflow: TextOverflow.ellipsis,style: TextStyle(
                                          fontFamily: "Poppins",fontSize: 10,color: Colors.white
                                      ),),
                                      Icon(Icons.close,size: 15,color: Colors.white,)
                                    ],
                                  ),
                                ),
                              ):Container(),
                              trailing: fixedFlavour.isEmpty?GestureDetector(
                                onTap:(){
                                  showCakeFlavSheet();
                                },
                                child: Container(
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
                              ):
                              CircleAvatar(
                                  radius: 15,
                                  backgroundColor: Colors.white,
                                  child: Icon(Icons.check_circle,color: Colors.green,size: 30,)
                              ),
                            ),
                            ListTile(
                              leading: Text('Shapes',style: TextStyle(fontFamily: "Poppins"),),
                              title: fixedShape.isNotEmpty?
                              GestureDetector(
                                onTap:(){
                                  setState(() {
                                    fixedShape = "";
                                  });
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  margin: EdgeInsets.only(right: 90),
                                  padding: EdgeInsets.only(top: 6,bottom: 6,left: 4),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    color: lightPink,
                                  ),
                                  child: Wrap(
                                    children: [
                                      Text('${fixedShape}',maxLines: 1,overflow: TextOverflow.ellipsis,style: TextStyle(
                                          fontFamily: "Poppins",fontSize: 10,color: Colors.white
                                      ),),
                                      Icon(Icons.close,size: 15,color: Colors.white,)
                                    ],
                                  ),
                                ),
                              ):Container(),
                              trailing: fixedShape.isEmpty?GestureDetector(
                                onTap:(){
                                  showCakeShapesSheet();
                                },
                                child: Container(
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
                              ):
                              CircleAvatar(
                                  radius: 15,
                                  backgroundColor: Colors.white,
                                  child: Icon(Icons.check_circle,color: Colors.green,size: 30,)
                              ),
                            ),
                            ListTile(
                              leading: Text('Cake Toppings',style: TextStyle(fontFamily: "Poppins"),),
                              title: Text(fixedToppings.length>0?'${fixedToppings.length }+ Toppings selected.':'',
                                style: TextStyle(fontFamily: "Poppins",fontSize: 12,color: darkBlue),),
                              trailing: GestureDetector(
                                onTap:(){
                                  showCakeToppingsSheet();
                                },
                                child: Container(
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
                                    onPressed: () async {
                                      DateTime? SelDate = await showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now(),
                                        lastDate: DateTime(2050),
                                        firstDate:DateTime.now().subtract(Duration(days: 0)),
                                      );

                                      setState(() {
                                        deliverDate = simplyFormat(time: SelDate,dateOnly: true);
                                      });

                                      // print(SelDate.toString());
                                      // print(DateTime.now().subtract(Duration(days: 0)));

                                    },
                                    child: Row(
                                      children: [
                                        Text('$deliverDate',style: TextStyle(
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
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(20)
                                              ),
                                              title: Text("Select delivery session",style: TextStyle(
                                                color: lightPink,fontFamily: "Poppins",fontSize: 16,)),
                                              content:Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  ListTile(
                                                    onTap:(){
                                                      Navigator.pop(context);
                                                      setState(() {
                                                        deliverSession = "Morning";
                                                      });
                                                    },
                                                    title: Text('Morning',style: TextStyle(
                                                      color: darkBlue,fontFamily: "Poppins")),
                                                  ),
                                                  ListTile(
                                                    onTap:(){
                                                      Navigator.pop(context);
                                                      setState(() {
                                                        deliverSession = "Afternoon";
                                                      });
                                                    },
                                                    title: Text('Afternoon',style: TextStyle(
                                                        color: darkBlue,fontFamily: "Poppins")),
                                                  ),
                                                  ListTile(
                                                    onTap:(){
                                                      Navigator.pop(context);
                                                      setState(() {
                                                        deliverSession = "Evening";
                                                      });
                                                    },
                                                    title: Text('Evening',style: TextStyle(
                                                        color: darkBlue,fontFamily: "Poppins")),
                                                  ),
                                                  ListTile(
                                                    onTap:(){
                                                      Navigator.pop(context);
                                                      setState(() {
                                                        deliverSession = "Night";
                                                      });
                                                    },
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
                                        Text('$deliverSession',style: TextStyle(
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

String simplyFormat({required DateTime? time, bool dateOnly = false}) {

  List<String> months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];

  String year = time!.year.toString();

  // Add "0" on the left if month is from 1 to 9
  String month = time.month.toString().padLeft(2, '0');

  // Add "0" on the left if day is from 1 to 9
  String day = time.day.toString().padLeft(2, '0');

  // Add "0" on the left if hour is from 1 to 9
  String hour = time.hour.toString().padLeft(2, '0');

  // Add "0" on the left if minute is from 1 to 9
  String minute = time.minute.toString().padLeft(2, '0');

  // Add "0" on the left if second is from 1 to 9
  String second = time.second.toString();

  // return the "yyyy-MM-dd HH:mm:ss" format
  if (dateOnly == false) {
    return "$day-$month-$year $hour:$minute:$second";
  }

  // If you only want year, month, and date
  return "$day-$month-$year";
}