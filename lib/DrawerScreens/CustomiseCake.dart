import 'package:cakey/DrawerScreens/VendorsList.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dotted_border/dotted_border.dart';

import '../ContextData.dart';
import '../screens/Profile.dart';

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

  //Articles
  var articals = ["Happy Birth Day" , "Butterflies" , "Hello World"];
  var articalsPrice = ['Rs.100' , 'Rs.125','Rs.50'];
  int articGroupVal = 0;

  //Font family
  String poppins = "Poppins";
  String profileUrl = '';
  String fixedWeight = '';
  String btnMsg = 'ORDER NOW';

  //main variables
  bool egglesSwitch = true;
  String userCurLocation = 'Searching...';

  var weight = [
    1.5,2,2.5,3,4,5,6,7,8
  ];

  var cakeTowers = ["2","3","5","8"];

  List<bool> selwIndex = [];
  List<bool> selCakeTower = [];

  //For category selecions
  List<Widget> cateWidget = [];
  List<bool> selCategory = [];
  List categories = ["Birthday" , "Wedding" , "Others" , "Anniversary" , "Farewell"];


  //region Functions
  Future<void> loadPrefs() async{
    var pref = await SharedPreferences.getInstance();
    setState(() {
      userCurLocation = pref.getString('userCurrentLocation')??'Not Found';
    });
  }

  void addCategories(){
    setState(() {
      for(int index=0;index<categories.length;index++){
        selCategory.add(false);
        cateWidget.add(
          StatefulBuilder(
            builder: (context , void Function(void Function()) setState){
              return InkWell(
                onTap:(){
                  setState((){
                    print('$index');
                    for(int i = 0 ; i<selCategory.length;i++){
                      if(i==index){
                        selCategory[index] = true;
                      }else{
                        selCategory[index] = false;
                      }
                    }
                  });
                },
                child: Stack(
                  children: [
                    Container(
                      padding: EdgeInsets.all(5),
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            border: Border.all(color: lightPink,width: 1),
                            borderRadius: BorderRadius.circular(8)
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.cake_outlined,color: lightPink,),
                            SizedBox(width: 10,),
                            Text('${categories[index]}',style: TextStyle(
                                fontFamily: "Poppins",
                                color: Colors.black26
                            ),)
                          ],
                        ),
                      ),
                    ),
                    selCategory[index]==true?
                    Positioned(
                      right: 0,
                      child: Icon(Icons.check_circle,color: Colors.green,),
                    ):Positioned(
                      right: 0,
                      child:Container(),
                    )
                  ],
                ),
              );
           },
          )
        );
      }
    });
  }

  //endregion

  @override
  void initState() {
    // TODO: implement initState
    Future.delayed(Duration.zero , () async{
      loadPrefs();
      addCategories();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    profileUrl = context.watch<ContextData>().getProfileUrl();

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
        title: Text('FULLY CUSTOMIZATION',
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
          SizedBox(
            width: 10,
          ),
        ],
      ),
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
                      child: Text('$userCurLocation',style:TextStyle(fontFamily: "Poppins",fontSize: 18,color: darkBlue,fontWeight: FontWeight.bold),),
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
                                style: TextStyle(color: darkBlue,fontSize: 15,fontFamily: "Poppins",fontWeight: FontWeight.bold),
                              ),
                            ),

                            //Egg Eggless switch
                            Row(
                              children: [
                                Transform.scale(
                                  scale: 0.6,
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
                                    fontWeight: FontWeight.bold,fontFamily: "Poppins" ,fontSize: 13),),
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
                                runSpacing: 4.0,
                                spacing: 4.0,
                                children:cateWidget
                              ),
                            ),

                            //Shapes....flav...toppings
                            ExpansionTile(
                              title: Text('Shapes',style: TextStyle(
                                  fontFamily: "Poppins",fontSize: 13,fontWeight: FontWeight.bold,color: Colors.grey
                              ),),
                              subtitle:Text('Heart',style: TextStyle(
                                  fontFamily: "Poppins",fontSize: 15,fontWeight: FontWeight.w900,
                                  color: darkBlue
                              ),),
                              children: [
                                Text('Shapes.....',style: TextStyle(
                                    fontFamily: "Poppins",fontSize: 13,fontWeight: FontWeight.w900,
                                    color: darkBlue
                                ),),
                              ],
                            ),
                            Container(
                              margin: EdgeInsets.only(left: 8,right: 8),
                              height: 0.5,
                              color:Colors.pink[200],
                            ),
                            ExpansionTile(
                              title: Text('Flavours',style: TextStyle(
                                  fontFamily: "Poppins",fontSize: 13,fontWeight: FontWeight.bold,color: Colors.grey
                              ),),
                              subtitle:Text('Strawberry',style: TextStyle(
                                  fontFamily: "Poppins",fontSize: 15,fontWeight: FontWeight.w900,
                                  color: darkBlue
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
                              color:Colors.pink[200],
                            ),
                            ExpansionTile(
                              title: Text('Cake Articles',style: TextStyle(
                                  fontFamily: "Poppins",fontSize: 13,fontWeight: FontWeight.bold ,
                                  color: Colors.grey
                              ),),
                              subtitle:Text('- - - - - - - -',style: TextStyle(
                                  fontFamily: "Poppins",fontSize: 15,fontWeight: FontWeight.w900,
                                  color: darkBlue
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
                              color:Colors.pink[200],
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

                                            if(weight[index]>=5){
                                              setState(() {
                                                btnMsg = "CONNECT - HELP DESK";
                                              });
                                            }else{
                                              btnMsg = "ORDER NOW";
                                            }

                                          });
                                        },
                                        child:Container(
                                          width: 70,
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
                                            '${weight[index]} Kg',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontFamily: "Poppins",color: selwIndex[index]?Colors.white:darkBlue
                                            ),
                                          ),
                                        ),
                                      );
                                    })),

                            SizedBox(height:15),
                             Container(
                              margin: EdgeInsets.only(left: 8,right: 8),
                              height: 0.5,
                              color:Colors.pink[200],
                            ),

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
                                    itemCount: cakeTowers.length,
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

                            SizedBox(height:15),
                            Container(
                              margin: EdgeInsets.only(left: 8,right: 8),
                              height: 0.5,
                              color:Colors.pink[200],
                            ),

                            Container(
                              //margin
                                margin: EdgeInsets.all(10),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(' Message on the cake',
                                      style: TextStyle(color: darkBlue,fontSize: 14,fontFamily: "Poppins",fontWeight: FontWeight.bold),
                                    ),
                                    Container(
                                      margin: EdgeInsets.symmetric(horizontal: 10),
                                      child: TextField(
                                        decoration: InputDecoration(
                                            hintText: 'Type here..',
                                            prefixIcon: Icon(Icons.message_outlined,color: lightPink,)
                                        ),
                                      ),
                                    ),


                                    //Articlessss
                                    Padding(
                                      padding: const EdgeInsets.only(top: 10),
                                      child: Text(
                                        ' Articles',
                                        style: TextStyle(color: darkBlue,fontSize: 14,fontFamily: "Poppins",fontWeight: FontWeight.bold),
                                      ),
                                    ),

                                    Container(
                                        child:ListView.builder(
                                          shrinkWrap : true,
                                          physics : NeverScrollableScrollPhysics(),
                                          itemCount:articals.length,
                                          itemBuilder: (context , index){
                                            return InkWell(
                                              onTap:(){
                                                setState(() {
                                                  articGroupVal = index;
                                                });
                                              },
                                              child: Row(
                                                  children:[
                                                    Radio(
                                                        value: index,
                                                        groupValue: articGroupVal,
                                                        onChanged: (int? val){
                                                          setState(() {
                                                            articGroupVal = val!;
                                                          });
                                                        }
                                                    ),

                                                    Text('${articals[index]} - ',style: TextStyle(
                                                        fontFamily: poppins, color:Colors.black54 , fontSize: 13
                                                    ),),

                                                    Text('${articalsPrice[index]}',style: TextStyle(
                                                        fontFamily: poppins, color:darkBlue , fontSize: 13
                                                    ),),
                                                  ]
                                              ),
                                            );
                                          },
                                        )
                                    ),

                                    Padding(
                                      padding: const EdgeInsets.only(top:10),
                                      child: Text(' Special request to bakers',
                                        style: TextStyle(color: darkBlue,fontSize: 14,fontFamily: "Poppins",fontWeight: FontWeight.bold),
                                      ),
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
                                        Text('Delivery Date',
                                          style: TextStyle(color: darkBlue,fontSize: 14,fontFamily: "Poppins",fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(width: 65,),
                                        Text('Delivery Session',
                                          style: TextStyle(color: darkBlue,fontSize: 14,fontFamily: "Poppins",fontWeight: FontWeight.bold),
                                        )
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
                                              Text('31-03-2022',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,color: Colors.grey,
                                                  fontSize: 13
                                              ),
                                              ),
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
                              child: Text(' Address',
                                style: TextStyle(color: darkBlue,fontSize: 14,fontFamily: "Poppins",fontWeight: FontWeight.bold),
                              ),
                            ),
                            ListTile(
                              title: Text('1/4 vellandipalaym , thekkalur , 641654  ',
                                style: TextStyle(fontFamily: poppins,color: Colors.grey,fontSize: 13),
                              ),
                              trailing: Icon(Icons.check_circle,color: Colors.green,),
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

                            //Image Upload
                            Padding(
                              padding: const EdgeInsets.only(left: 10.0),
                              child: Text(' Upload Image',
                                style: TextStyle(color: darkBlue,fontSize: 14,fontFamily: "Poppins",fontWeight: FontWeight.bold),
                              ),
                            ),
                            
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: DottedBorder(
                                radius: Radius.circular(20),
                                color: Colors.grey,//color of dotted/dash line
                                strokeWidth: 1, //thickness of dash/dots
                                dashPattern: [3,2],
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: 160,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.image_rounded , color: Colors.blueAccent,size: 40,),
                                      Text('Pick Your Image',
                                        style: TextStyle(color: darkBlue,fontSize: 16,fontFamily: "Poppins",fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: 15,),
                            
                            Container(
                              padding: EdgeInsets.all(10.0),
                              color: Colors.black12,
                              child: Column(
                                children: [
                                  btnMsg.toLowerCase()!='connect - help desk'?
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
                                  ):Container(),
                                  btnMsg.toLowerCase()!='connect - help desk'?
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
                                  ):Container(),
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
                                      child: Text("$btnMsg",style: TextStyle(
                                          color: Colors.white,fontWeight: FontWeight.bold
                                      ),),
                                    ),
                                  ),
                                  SizedBox(height: 15,),
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

