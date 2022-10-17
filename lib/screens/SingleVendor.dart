import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cakey/Dialogs.dart';
import 'package:cakey/DrawerScreens/CakeTypes.dart';
import 'package:cakey/DrawerScreens/VendorsList.dart';
import 'package:cakey/screens/ChatScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../ContextData.dart';
import 'package:http/http.dart' as http;
import '../DrawerScreens/HomeScreen.dart';
import '../DrawerScreens/Notifications.dart';
import '../drawermenu/NavDrawer.dart';
import 'Profile.dart';

class SingleVendor extends StatefulWidget {
  const SingleVendor({Key? key}) : super(key: key);
  @override
  State<SingleVendor> createState() => _SingleVendorState();
}

class _SingleVendorState extends State<SingleVendor> {

  //region Global
  //Colors
  Color lightGrey = Color(0xffF5F5F5);
  Color darkBlue = Color(0xffF213959);
  Color lightPink = Color(0xffFE8416D);

  String poppins = "Poppins";
  String profileUrl = "";
  String userCurLocation = 'Searching...';

  String description = "";
  String speciality = "";
  String rate = "0.0";
  String vendorID = '';
  String vendorName = 'Un name';
  String vendorSpecial = 'not provide';
  String vendorPhone = '';
  String vendorLocalAddres = '';
  String deliverCharge = '';
  String profileImage = '';
  String vendorEggOrEggless = '';
  String authToken = "";
  String goBacktoVenList= '';
  String userLatitude= '';
  String userLongtitude = '';
  String phone1 = "", phone2 = "";

  bool ordersNull = false;
  bool isFromCD = false;

  List<bool> isExpands = [];
  List vendorOrders = [];

  List nearestVendors = [];
  List vendorsList = [];
  
  //key
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  
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

  //loadPrefs
  Future<void> loadPrefs() async{
    var pref = await SharedPreferences.getInstance();
    setState(() {
      userCurLocation = pref.getString('userCurrentLocation')??'Not Found';
      goBacktoVenList = pref.getString('ventosingleven')??'Not Found';
    });
  }

  //get datas
  Future<void> receiveDataFromScreen() async{
    var pref = await SharedPreferences.getInstance();

    setState(() {

      rate = pref.getString('singleVendorRate')??'0.0';
      vendorID = pref.getString('singleVendorID')??'';
      authToken = pref.getString('authToken')??'';
      vendorName = pref.getString('singleVendorName')??'No name';
      description = pref.getString('singleVendorDesc')??'No Description';
      deliverCharge = pref.getString('singleVendorDelivery')??'';
      vendorSpecial = pref.getString('singleVendorSpecial')??'';
      profileImage = pref.getString('singleVendorDpImage')??'';
      vendorLocalAddres = pref.getString('singleVendorAddress')??'';
      userLatitude = pref.getString('userLatitute')??'';
      userLongtitude = pref.getString('userLongtitude')??'';
      vendorEggOrEggless = pref.getString('singleVendorEggs')??'';

      isFromCD = pref.getBool('singleVendorFromCd')??false;
      phone1 = pref.getString('singleVendorPhone1')??'';
      phone2 = pref.getString('singleVendorPhone2')??'';
      speciality = pref.getString('singleVendorSpecial')??'';
    });

    print('Spel $speciality');


    getVendorsList();

  }

  //Distance calculator
  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  //geting the vendors list
  Future<void> getVendorsList() async{

    nearestVendors.clear();
    vendorsList.clear();
    showAlertDialog();

    try{

      var res = await http.get(Uri.parse("http://sugitechnologies.com/cakey/api/vendors/list"),
          headers: {"Authorization":"$authToken"}
      );

      if(res.statusCode==200){
          setState(() {
            List myList = jsonDecode(res.body);

            nearestVendors = myList.where((element) =>
            calculateDistance(double.parse(userLatitude), double.parse(userLongtitude),
                element['GoogleLocation']['Latitude'],element['GoogleLocation']['Longitude'])<=10
            ).toList();


            nearestVendors = nearestVendors.where((element) => element['_id'].toString()==vendorID).toList();

            Navigator.pop(context);

            print("selected ven len : ${nearestVendors.length}");

          });

      }else{
        checkNetwork();
        Navigator.pop(context);
      }

    }catch(e){
      print(e);
      Navigator.pop(context);
      checkNetwork();

    }

  }

  //network check
  Future<void> checkNetwork() async{
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('connected');
      }
    } on SocketException catch (_) {
      NetworkDialog().showNoNetworkAlert(context);
      print('not connected');
    }
  }

  //getting oreders by id
  Future<void> getOrdersByVendorId() async{
    showAlertDialog();

    try{
      var res = await http.get(Uri.parse('http://sugitechnologies.com/cakey/api/order/listbyvendorid/$vendorID'));

      if(res.statusCode==200){

        print(jsonDecode(res.body));

        setState(() {
          vendorOrders = jsonDecode(res.body);
          vendorOrders = vendorOrders.reversed.toList();
          print(vendorOrders);

          Navigator.pop(context);
        });

      }else{
        print(res.statusCode);
        Navigator.pop(context);
      }
    }catch (error){
      print(error);
      Navigator.pop(context);
    }


  }

  //load select Vendor data to CakeTypeScreen
  Future<void> loadSelVendorDataToCTscreen() async{

    var pref = await SharedPreferences.getInstance();

    pref.setString('myVendorId', vendorID);
    pref.setString('myVendorName', vendorName);
    pref.setString('myVendorPhone', vendorPhone);
    pref.setString('myVendorDesc', description);
    pref.setString('myVendorProfile', profileImage);
    pref.setString('myVendorDeliverChrg', deliverCharge);
    pref.setString('myVendorAddress', deliverCharge);
    pref.setString('myVendorEggs', vendorEggOrEggless);

    pref.setBool('iamYourVendor', true);
    pref.setBool('vendorCakeMode',true);

    context.read<ContextData>().addMyVendor(true);
    context.read<ContextData>().setMyVendors([
      nearestVendors[0]
    ]);

    Navigator.push(context, MaterialPageRoute(builder: (context)=>CakeTypes()));

  }

  //endregion

  @override
  void initState() {
    // TODO: implement initState
    Future.delayed(Duration.zero , () async{
      receiveDataFromScreen();
      loadPrefs();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    profileUrl = context.watch<ContextData>().getProfileUrl();
    return WillPopScope(
      onWillPop: () async{
        Navigator.pop(context);
        // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>VendorsList()));
        // // if(goBacktoVenList=="yes"){
        // //   context.read<ContextData>().setCurrentIndex(3);
        // // }
        return true;
      },
      child: Scaffold(
          key: _scaffoldKey,
          drawer: NavDrawer(screenName: "svendor",),
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(50),
            child: SafeArea(
              child: Container(
                padding: EdgeInsets.only(left: 15, right: 15),
                color: lightGrey,
                height: 50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        isFromCD==false?
                        InkWell(
                          onTap: () {
                            FocusScope.of(context).unfocus();
                            _scaffoldKey.currentState!.openDrawer();
                          },
                          child: Container(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircleAvatar(
                                      radius: 5.2,
                                      backgroundColor: darkBlue,
                                    ),
                                    SizedBox(width: 3,),
                                    CircleAvatar(
                                      radius: 5.2,
                                      backgroundColor: darkBlue,
                                    ),
                                  ],
                                ),
                                SizedBox(height: 3,),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircleAvatar(
                                        radius: 5.2,
                                        backgroundColor: darkBlue
                                    ),
                                    SizedBox(width: 3,),
                                    CircleAvatar(
                                      radius: 5.2,
                                      backgroundColor: Colors.red,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ):
                        Container(
                          // margin: const EdgeInsets.only(top: 10,bottom: 15),
                          child: InkWell(
                            onTap: (){
                              Navigator.pop(context);
                            },
                            child: Container(
                              height: 30,
                              decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(7)
                              ),
                              alignment: Alignment.center,
                              child: Icon(Icons.chevron_left,size: 30,color: lightPink,),
                            ),
                          ),
                        ),
                        SizedBox(width: 15,),
                        Text("VENDORS",
                            style: TextStyle(color: darkBlue,fontWeight: FontWeight.bold,fontFamily: poppins,
                                fontSize: 16
                            )),
                      ],
                    ),

                    Row(
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.of(context).push(
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation, secondaryAnimation) => Notifications(),
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
                                padding: EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(6)),
                                child: Icon(
                                  Icons.notifications_none,
                                  color: darkBlue,
                                  size: 22,
                                ),
                              ),
                            ),
                            Positioned(
                              left: 15,
                              top: 6,
                              child: CircleAvatar(
                                radius: 3.7,
                                backgroundColor: Colors.white,
                                child: CircleAvatar(
                                  radius: 2.7,
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
                              radius: 14.7,
                              backgroundColor: Colors.white,
                              child: CircleAvatar(
                                  radius: 13,
                                  backgroundImage:NetworkImage("$profileUrl")
                              ),
                            ):CircleAvatar(
                              radius: 14.7,
                              backgroundColor: Colors.white,
                              child: CircleAvatar(
                                  radius: 13,
                                  backgroundImage:AssetImage("assets/images/user.png")
                              ),
                            ),
                          ),
                        ),
                      ],
                    )


                  ],
                ),
              ),
            ),
          ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.only(left:10,top: 8,bottom: 15),
                color: lightGrey,
                child: Column(
                  children: [
                    Container(
                      child: Row(
                        children: [
                          Icon(Icons.location_on,color: Colors.red,),
                          SizedBox(width: 5,),
                          Text('Delivery to',style: TextStyle(color: Colors.black54,fontWeight: FontWeight.bold,
                              fontSize: 13,
                              fontFamily: "Poppins"),)
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(left: 8),
                      alignment: Alignment.centerLeft,
                      child: Text('$userCurLocation',style:TextStyle(fontFamily: "Poppins",fontSize: 15,color: darkBlue,fontWeight: FontWeight.bold),),
                    ),
                  ],
                ),
              ),
              //Vendor name details......
              Container(
                padding: EdgeInsets.all(15),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //Vendor name and whatsapp...
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${vendorName[0].toUpperCase()
                                +vendorName.substring(1).toLowerCase()
                            }',style: TextStyle(
                              color: darkBlue,fontFamily:"Poppins",
                              fontSize: 15,fontWeight: FontWeight.bold
                            ),),
                            Row(
                              children: [
                                RatingBar.builder(
                                  initialRating: double.parse(rate.toString()),
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
                                Text(' $rate',style: TextStyle(
                                    color: Colors.black54,fontWeight: FontWeight.bold,fontSize: 13,fontFamily: poppins
                                ),)
                              ],
                            ),
                          ],
                        ),

                        Container(
                          width: 100,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              InkWell(
                                onTap: (){
                                  print('phone.. ');
                                  PhoneDialog().showPhoneDialog(context, "$phone1", "$phone2");
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  height: 35,
                                  width: 35,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: lightGrey,
                                  ),
                                  child:const Icon(Icons.phone,color: Colors.blueAccent,),
                                ),
                              ),
                              const SizedBox(width: 10,),
                              InkWell(
                                onTap: (){
                                  print('whatsapp : ');
                                  // Navigator.push(context,
                                  //     MaterialPageRoute(builder: (context)=>ChatScreen()));
                                  //PhoneDialog().showPhoneDialog(context, "$phone1", "$phone2" , true);
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  height: 35,
                                  width: 35,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: lightGrey
                                  ),
                                  child:const Icon(Icons.whatsapp_rounded,color: Colors.green,),
                                ),
                              ),
                              const SizedBox(width: 10,),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10,),
                    // Text('$vendorLocalAddres', style:TextStyle(
                    //   fontFamily: "Poppins",
                    // )),
                    // SizedBox(height: 10,),
                    //Sel button
                    InkWell(
                      splashColor: Colors.red[200],
                      onTap: ()=>loadSelVendorDataToCTscreen(),
                      child: Container(
                        height: 30,
                        width: 80,
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: darkBlue,width: 0.5)
                        ),
                        child: Text('SELECT',style: TextStyle(color: darkBlue,fontSize: 12),)
                      ),
                    ),
                    SizedBox(height: 10,),
                    //Theme text
                    Text('Speciality in ${speciality.replaceAll("[", "").replaceAll("]", "")}',
                      style: TextStyle(color: darkBlue,
                        fontWeight: FontWeight.bold,),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 10,),
                    ExpandableText(
                        "$description",
                        expandText: "",
                        collapseText: "collapse",
                        expandOnTextTap: true,
                        collapseOnTextTap: true,
                        style: TextStyle(
                          color: Colors.grey,fontFamily: "Poppins"
                        ),
                    ),
                  ],
                ),
              ),

              /*This is temp hiden Vendors Public Orders*/
              //Vendors recent orders....
              // Padding(
              //   padding: const EdgeInsets.all(10),
              //   child: Text("History",
              //     style: TextStyle(color: darkBlue,fontSize: 14,fontFamily: "Poppins",fontWeight: FontWeight.bold),
              //   ),
              // ),
              //
              // vendorOrders.isNotEmpty?
              // Container(
              //   margin: EdgeInsets.all(10),
              //   child: ListView.builder(
              //       shrinkWrap: true,
              //       itemCount: vendorOrders.length,
              //       physics: NeverScrollableScrollPhysics(),
              //       itemBuilder: (context,index){
              //         isExpands.add(false);
              //         return Card(
              //             elevation: 6.0,
              //             shape: RoundedRectangleBorder(
              //               borderRadius: BorderRadius.circular(10)
              //             ),
              //             child: Container(
              //               padding: EdgeInsets.all(10),
              //               child: Column(
              //                 crossAxisAlignment: CrossAxisAlignment.start,
              //                 children: [
              //                   GestureDetector(
              //                     onTap:(){
              //                       setState(() {
              //                         if(isExpands[index]==false){
              //                           isExpands[index]=true;
              //                         }else{
              //                           isExpands[index]=false;
              //                         }
              //                       });
              //                     },
              //                     child: Column(
              //                       crossAxisAlignment: CrossAxisAlignment.start,
              //                       children: [
              //                         Container(
              //                           padding: const EdgeInsets.all(3),
              //                           decoration: BoxDecoration(
              //                               borderRadius: BorderRadius.circular(20),
              //                               color: Colors.black26
              //                           ),
              //                           child:Text('Order ID # ${vendorOrders[index]["_id"]}',style: const TextStyle(
              //                               fontSize: 10,fontFamily: "Poppins",color: Colors.black
              //                           ),),
              //                         ),
              //                         SizedBox(height: 6,),
              //                         //Theme text
              //                         Text('${vendorOrders[index]['Title']}',
              //                           style: TextStyle(color: darkBlue,
              //                               fontWeight: FontWeight.bold,fontSize: 13
              //                           ),
              //                           maxLines: 2,
              //                         ),
              //                         SizedBox(height: 6,),
              //                         ExpandableText(
              //                           '${vendorOrders[index]['Description']}',
              //                           style: TextStyle(
              //                               color: Colors.grey,fontFamily: "Poppins",fontSize: 12
              //                           ),
              //                           expandText: '',
              //                           collapseText: 'collapse',
              //                           maxLines: 3,
              //                           collapseOnTextTap: true,
              //                           expandOnTextTap: true,
              //                         ),
              //                         SizedBox(height: 3,),
              //                         Container(
              //                           height: 1,
              //                           color: Colors.black26,
              //                         ),SizedBox(height: 3,),
              //                         Row(
              //                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //                           children: [
              //                             Row(
              //                               children: [
              //                                 RatingBar.builder(
              //                                   initialRating: 4.1,
              //                                   minRating: 1,
              //                                   direction: Axis.horizontal,
              //                                   allowHalfRating: true,
              //                                   itemCount: 5,
              //                                   itemSize: 14,
              //                                   itemPadding: EdgeInsets.symmetric(horizontal: 1.0),
              //                                   itemBuilder: (context, _) => Icon(
              //                                     Icons.star,
              //                                     color: Colors.amber,
              //                                   ),
              //                                   onRatingUpdate: (rating) {
              //                                     print(rating);
              //                                   },
              //                                 ),
              //                                 Text(' 4.5',style: TextStyle(
              //                                     color: Colors.black54,fontWeight: FontWeight.bold,fontSize: 13,fontFamily: poppins
              //                                 ),)
              //                               ],
              //                             ),
              //                             vendorOrders[index]['Status'].toString().toLowerCase().contains('delivered')?
              //                             Row(
              //                               crossAxisAlignment: CrossAxisAlignment.start,
              //                               children: [
              //                                 Row(
              //                                   children: [
              //                                     Text("Delivered ",style: TextStyle(color: Colors.green,
              //                                         fontWeight: FontWeight.bold,fontFamily: "Poppins",fontSize: 11),),
              //                                     Icon(Icons.verified_rounded,color: Colors.green,size: 12,)
              //                                   ],
              //                                 ),
              //                                 SizedBox(width: 5,),
              //                                 Text("${vendorOrders[index]['Status_Updated_On'].toString().split(" ").first}",style: TextStyle(color: Colors.black26,
              //                                     fontFamily: "Poppins",fontSize: 10,fontWeight: FontWeight.bold),),
              //                               ],
              //                             ):
              //                             Text('${vendorOrders[index]['Status'].toString()}',style: TextStyle(
              //                                 color: vendorOrders[index]['Status'].toString().toLowerCase().contains('cancelled')?
              //                                 Colors.red:Colors.blueAccent,
              //                                 fontWeight: FontWeight.bold,fontFamily: poppins,fontSize: 10),)
              //                           ],
              //                         ),
              //                         SizedBox(height: 3,),
              //                         Container(
              //                           height: 1,
              //                           color: Colors.black26,
              //                         ),
              //                         ListTile(
              //                           title: Text('Customer',style: TextStyle(
              //                               fontSize: 12,color: Colors.grey,fontFamily: "Poppins"
              //                           ),),
              //                           subtitle: Text('${vendorOrders[index]['UserName']}',style: TextStyle(
              //                               fontSize: 13,color:darkBlue,fontFamily: "Poppins",
              //                               fontWeight: FontWeight.bold
              //                           ),),
              //                         ),
              //                       ],
              //                     ),
              //                   ),
              //                   Visibility(
              //                     visible:isExpands[index],
              //                     child: AnimatedContainer(
              //                       duration: const Duration(seconds: 3),
              //                       curve: Curves.elasticInOut,
              //                       decoration: BoxDecoration(
              //                         color: Colors.black12,
              //                         borderRadius: BorderRadius.only(
              //                           bottomLeft: Radius.circular(15),
              //                           bottomRight: Radius.circular(15),
              //                         )
              //                       ),
              //                       child: Column(
              //                         children: [
              //                           const SizedBox(height: 15,),
              //                           Row(
              //                             crossAxisAlignment: CrossAxisAlignment.start,
              //                             children: [
              //                               const SizedBox(width: 8,),
              //                               const Icon(
              //                                 Icons.location_on,
              //                                 color: Colors.red,
              //                               ),
              //                               const SizedBox(width: 8,),
              //                               Container(
              //                                   width: 260,
              //                                   child: Text(
              //                                     "${vendorOrders[index]['DeliveryAddress']}",
              //                                     style: TextStyle(
              //                                         fontFamily: "Poppins",
              //                                         color: Colors.black54,
              //                                         fontSize: 13
              //                                     ),
              //                                   )
              //                               ),
              //                             ],
              //                           ),
              //                           const SizedBox(height: 15,),
              //                           Container(
              //                             margin: const EdgeInsets.only(left: 10,right: 10),
              //                             color: Colors.black26,
              //                             height: 1,
              //                           ),
              //
              //                           Container(
              //                             padding: const EdgeInsets.all(10),
              //                             child: Row(
              //                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //                               crossAxisAlignment: CrossAxisAlignment.center,
              //                               children: [
              //                                 const Text('Item Total',style: TextStyle(
              //                                   fontFamily: "Poppins",
              //                                   color: Colors.black54,
              //                                 ),),
              //                                  Text('₹${vendorOrders[index]['Total']}',style: const TextStyle(fontWeight: FontWeight.bold),),
              //                               ],
              //                             ),
              //                           ),
              //                           Container(
              //                             padding: const EdgeInsets.all(10),
              //                             child: Row(
              //                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //                               crossAxisAlignment: CrossAxisAlignment.center,
              //                               children: [
              //                                 const Text('Delivery charge',style: const TextStyle(
              //                                   fontFamily: "Poppins",
              //                                   color: Colors.black54,
              //                                 ),),
              //                                 Text(vendorOrders[index]['DeliveryCharge'].toString()!="null"?
              //                                   '₹${vendorOrders[index]['DeliveryCharge']}':'₹0',style: const TextStyle(fontWeight: FontWeight.bold),)
              //                               ],
              //                             ),
              //                           ),
              //                           Container(
              //                             padding: const EdgeInsets.all(10),
              //                             child: Row(
              //                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //                               crossAxisAlignment: CrossAxisAlignment.center,
              //                               children: [
              //                                 const Text('Discounts',style: const TextStyle(
              //                                   fontFamily: "Poppins",
              //                                   color: Colors.black54,
              //                                 ),),
              //                                 Text(vendorOrders[index]['DeliveryCharge'].toString()!="null"?
              //                                 '₹${vendorOrders[index]['Discount']}':'₹0',style: const TextStyle(fontWeight: FontWeight.bold),),
              //                               ],
              //                             ),
              //                           ),
              //                           Container(
              //                             padding: const EdgeInsets.all(10),
              //                             child: Row(
              //                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //                               crossAxisAlignment: CrossAxisAlignment.center,
              //                               children: [
              //                                 const Text('Taxes',style: const TextStyle(
              //                                   fontFamily: "Poppins",
              //                                   color: Colors.black54,
              //                                 ),),
              //                                 Text('₹0',style: const TextStyle(fontWeight: FontWeight.bold),),
              //                               ],
              //                             ),
              //                           ),
              //
              //                           Container(
              //                             margin: const EdgeInsets.only(left: 10,right: 10),
              //                             color: Colors.black26,
              //                             height: 1,
              //                           ),
              //                           Container(
              //                             padding: const EdgeInsets.all(10),
              //                             child: Row(
              //                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //                               crossAxisAlignment: CrossAxisAlignment.center,
              //                               children: [
              //                                 const Text('Bill Total',style: TextStyle(
              //                                     fontFamily: "Poppins",
              //                                     color: Colors.black,
              //                                     fontWeight: FontWeight.bold
              //                                 ),),
              //                                  Text('₹${vendorOrders[index]['Total']}',style: TextStyle(fontWeight: FontWeight.bold),),
              //                               ],
              //                             ),
              //                           ),
              //                           Container(
              //                             padding: const EdgeInsets.all(10),
              //                             child: Row(
              //                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //                               crossAxisAlignment: CrossAxisAlignment.center,
              //                               children: [
              //                                 Text('Paid via : ${vendorOrders[index]['PaymentType']}',style: TextStyle(
              //                                   fontFamily: "Poppins",
              //                                   color: Colors.black54,
              //                                 ),),
              //                               ],
              //                             ),
              //                           ),
              //                         ],
              //                       ),
              //                     ),
              //                   )
              //                 ],
              //               ),
              //             ),
              //           );
              //       }
              //   ),
              // ):
              // Center(
              //   child: Padding(
              //     padding:EdgeInsets.all(8.0),
              //     child: Text('No Orders Found!' , style: TextStyle(
              //       color: darkBlue , fontFamily: "Poppins" ,
              //       fontSize: 17 , fontWeight: FontWeight.bold
              //     ),),
              //   ),
              // )


            ],
          ),
        )
      ),
    );
  }
}

