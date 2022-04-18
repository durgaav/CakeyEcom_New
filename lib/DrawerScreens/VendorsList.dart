import 'dart:convert';

import 'package:cakey/screens/SingleVendor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../ContextData.dart';
import '../screens/Profile.dart';
import 'package:http/http.dart' as http;

class VendorsList extends StatefulWidget {
  const VendorsList({Key? key}) : super(key: key);

  @override
  State<VendorsList> createState() => _VendorsListState();
}

class _VendorsListState extends State<VendorsList> {

  //region Variables
  //Colors
  Color lightGrey = Color(0xffF5F5F5);
  Color darkBlue = Color(0xffF213959);
  Color lightPink = Color(0xffFE8416D);

  //Strings
  String poppins = "Poppins";
  String profileUrl = '';
  String userCurLocation = 'Searching...';
  String userMainLocation = '';
  String searchLocation = '';

  //booleans
  bool isSearching = false;

  //Lists
  List locations = ["Tirupur","Avinashi","Avinashi",'Coimbatore','Neelambur','Thekkalur','Chennai'];
  List locationBySearch = [];
  List nearestVendors = [];
  List vendorsList = [];

  TextEditingController searchCtrl = new TextEditingController();

  //endregion

  //region Alerts

  //Default loader dialog
  void showAlertDialog(){
    showDialog(
        context: context,
        barrierDismissible: false,
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

  //endregion

  //region Functions

  Future<void> loadPrefs() async{
    var pref = await SharedPreferences.getInstance();
    setState(() {
      getVendorsList();
      userCurLocation = pref.getString('userCurrentLocation')??'Not Found';
      userMainLocation = pref.getString('userMainLocation')??'Not Found';
    });
  }

  Future<void> getVendorsList() async{
    showAlertDialog();
    var res = await http.get(Uri.parse("https://cakey-database.vercel.app/api/vendors/list"));

    if(res.statusCode==200){

      setState(() {
        vendorsList = jsonDecode(res.body);

        nearestVendors = vendorsList.where((element) =>
        element['Address']['City'].toString().toLowerCase().contains(userMainLocation.toLowerCase())
        ).toList();

        Navigator.pop(context);
      });

    }else{
      Navigator.pop(context);
    }
  }

  Future<void> sendDataToScreen(int index) async{
    var pref = await SharedPreferences.getInstance();

    //common keyword single****
    pref.setString('singleVendorID', locationBySearch[index]['_id']);
    pref.setString('singleVendorName', locationBySearch[index]['VendorName']);
    pref.setString('singleVendorDesc', locationBySearch[index]['Description']??'No Description');

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

  }

  //endregion

  @override
  void initState() {
    // TODO: implement initState
    Future.delayed(Duration.zero , () async{
      loadPrefs();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    if(searchLocation.isNotEmpty){
      setState(() {
        isSearching = false;
        locationBySearch =
            vendorsList.where((element) => element['Address']['City'].toString().toLowerCase()
                .contains(searchLocation.toLowerCase())).toList();
      });
    }else{
      setState(() {
        isSearching = true;
        locationBySearch = vendorsList.toList();
      });

    }

    profileUrl = context.watch<ContextData>().getProfileUrl();
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
                    child: Text('$userCurLocation',style:TextStyle(fontFamily: "Poppins",fontSize: 18,color: darkBlue,fontWeight: FontWeight.bold),),
                  ),
                ],
              ),
            ),
            //Search bar...
            Container(
              margin: EdgeInsets.all(10),
              height: 50,
              child: TextField(
                controller: searchCtrl,
                onChanged: (String? text){
                  setState(() {
                    searchLocation = text!;
                  });
                },
                decoration: InputDecoration(
                  hintText: "Search location",
                  hintStyle: TextStyle(fontFamily: "Poppins"),
                  prefixIcon: Icon(Icons.location_on),
                  suffixIcon:IconButton(
                    onPressed: (){
                      FocusScope.of(context).unfocus();
                      setState(() {
                        searchLocation = "";
                        searchCtrl = new TextEditingController(text: "");
                      });
                    },
                    icon: Icon(Icons.close,size: 20,),
                  ),
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
                    //All nearest vendors
                    Visibility(
                      visible: isSearching,
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
                              height: 190,
                              child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  shrinkWrap: true,
                                  itemCount: nearestVendors.length,
                                  itemBuilder: (context , index){
                                    return Card(
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10)
                                      ),
                                      child: Container(
                                        padding: EdgeInsets.all(10),
                                        width: 260,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                nearestVendors[index]['ProfileImage']!=null?
                                                CircleAvatar(
                                                  radius:32,
                                                  backgroundColor: Colors.white,
                                                  child: CircleAvatar(
                                                    radius:30,
                                                    backgroundImage: NetworkImage('${nearestVendors[index]['ProfileImage']}'),
                                                  ),
                                                ):
                                                CircleAvatar(
                                                  radius:32,
                                                  backgroundColor: Colors.white,
                                                  child: CircleAvatar(
                                                    radius:30,
                                                    backgroundImage:Svg('assets/images/pictwo.svg'),
                                                  ),
                                                ),
                                                SizedBox(width: 6,),
                                                Container(
                                                  width:170,
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Container(
                                                            width:120,
                                                            child: Text(nearestVendors[index]['VendorName'].toString().isEmpty?
                                                            'Un name':'${nearestVendors[index]['VendorName'][0].toString().toUpperCase()+
                                                                nearestVendors[index]['VendorName'].toString().substring(1).toLowerCase()
                                                            }',style: TextStyle(
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
                                                      ),
                                                      InkWell(
                                                        onTap: (){

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
                                              ],
                                            ),
                                            SizedBox(height: 10,),
                                            Container(
                                              alignment: Alignment.centerLeft,
                                              child: Text(nearestVendors[index]['Description']!=null?
                                                 " "+nearestVendors[index]['Description']:'',
                                                style: TextStyle(color: Colors.black54,fontFamily: "Poppins"),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 2,
                                                textAlign: TextAlign.start,
                                              ),
                                            ),
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
                                                    SizedBox(height: 8,),
                                                    Text(nearestVendors[index]['DeliveryCharge'].toString()=='null'?
                                                    'DELIVERY FREE':'Delivery Charge ₹${nearestVendors[index]['DeliveryCharge'].toString()}',style: TextStyle(
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
                        ],
                      ),
                    ),

                    //Other vendor title...
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: searchLocation.isEmpty?Text("Other Vendors",
                        style: TextStyle(color: darkBlue,fontSize: 14,fontFamily: "Poppins",fontWeight: FontWeight.bold),
                      ):Text("Search Results : ${locationBySearch.length} Found",
                        style: TextStyle(color: Colors.grey,fontSize: 12,fontFamily: "Poppins",fontWeight: FontWeight.bold),
                      )
                    ),

                    //Other vendors list....
                    Container(
                      child: ListView.builder(
                          itemCount: locationBySearch.length,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context,index){
                            return GestureDetector(
                              onTap: (){
                               sendDataToScreen(index);
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
                                      locationBySearch[index]['ProfileImage']!=null?
                                      Container(
                                        height: 120,
                                        width: 90,
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(15),
                                            image: DecorationImage(
                                              fit: BoxFit.cover,
                                              image: NetworkImage('${locationBySearch[index]['ProfileImage']}')
                                            )
                                        ),
                                      ):
                                      Container(
                                        height: 120,
                                        width: 90,
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(15),
                                            image: DecorationImage(
                                                fit: BoxFit.cover,
                                                image: Svg('assets/images/pictwo.svg')
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
                                                        child: Text(locationBySearch[index]['VendorName'].toString().isEmpty?
                                                            'Un name':'${locationBySearch[index]['VendorName'][0].toString().toUpperCase()+
                                                            locationBySearch[index]['VendorName'].toString().substring(1).toLowerCase()
                                                          }'
                                                          ,overflow: TextOverflow.ellipsis,style: TextStyle(
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
                                                      sendDataToScreen(index);
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
                                              child: Text(locationBySearch[index]['Description'].toString()=='null'?
                                              '':'${locationBySearch[index]['Description']}'
                                                ,overflow: TextOverflow.ellipsis,style: TextStyle(
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
                                                  locationBySearch[index]['DeliveryCharge'].toString()=='null'?
                                                  Text('DELIVERY FREE',style: TextStyle(
                                                      color: Colors.orange,fontSize: 10,fontFamily: poppins
                                                  ),):Text('Delivery Charge ₹${locationBySearch[index]['DeliveryCharge'].toString()}'
                                                    ,style: TextStyle(
                                                      color: darkBlue,fontSize: 12,fontFamily: poppins
                                                  ),),
                                                  TextButton(
                                                    onPressed: (){
                                                      print(width*0.63);
                                                     },
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
