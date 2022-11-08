import 'dart:convert';
import 'dart:math';

import 'package:cakey/screens/HamperDetails.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Hampers extends StatefulWidget {
  const Hampers({Key? key}) : super(key: key);

  @override
  State<Hampers> createState() => _HampersState();
}

class _HampersState extends State<Hampers> {

  //colors...
  String poppins = "Poppins";
  Color darkBlue = Color(0xffF213959);
  Color lightPink = Color(0xffFE8416D);
  Color lightGrey = Color(0xffF5F5F5);
  
  String userLat = "";
  String userLong = "";
  String authToken = "";
  List hampers = [];

  List<String> activeVendorsIds = [];
  
  Future<void> getInitialData() async{
    var pref = await SharedPreferences.getInstance();
    setState((){
      authToken = pref.getString('authToken')!;
      userLat = pref.getString('userLatitute')??'Not Found';
      userLong = pref.getString('userLongtitude')??'Not Found';
      activeVendorsIds = pref.getStringList('activeVendorsIds')??[];
    });
    getHampers();
  }


  Future<void> passDetails(int index) async{
    var pref = await SharedPreferences.getInstance();
    List<String> productsContains = [];

    if(hampers[index]['Product_Contains']!=null && hampers[index]['Product_Contains'].isNotEmpty){
      for(int i = 0 ; i<hampers[index]['Product_Contains'].length;i++){
        productsContains.add(hampers[index]['Product_Contains'][i].toString());
      }
    }

    pref.remove("hamperImage");
    pref.remove("hamperName");
    pref.remove("hamperPrice");
    pref.remove("hamper_ID");
    pref.remove("hamperDescription");
    pref.remove("hamperVendorName");
    pref.remove("hamperVendorID");
    pref.remove("hamperVendorName");
    pref.remove("hamperVendorPhn1");
    pref.remove("hamperVendorPhn2");
    pref.remove("hamperProducts");


    List<String> extraImages = [];
    if(hampers[index]['AdditionalHamperImage']!=null && hampers[index]['AdditionalHamperImage'].isNotEmpty){
      for(int j = 0;j<hampers[index]['AdditionalHamperImage'].length;j++){
        extraImages.add(hampers[index]['AdditionalHamperImage'][j].toString());
      }
    }

    extraImages.add(hampers[index]['HamperImage'].toString());

    pref.setStringList("hamperImages", extraImages??[]);
    pref.setString("hamperName", hampers[index]['HampersName']??'null');
    pref.setString("hamperPrice", hampers[index]['Price']??'null');
    pref.setString("hamperStartDate", hampers[index]['StartDate']??'null');
    pref.setString("hamperDeliStartDate", hampers[index]['DeliveryStartDate']??'null');
    pref.setString("hamperDeliEndDate", hampers[index]['DeliveryEndDate']??'null');
    pref.setString("hamperEndDate", hampers[index]['EndDate']??'null');
    pref.setString("hamperEggreggless", hampers[index]['EggOrEggless']??'null');
    pref.setString("hamper_ID", hampers[index]['_id']??'null');
    pref.setString("hamperModID", hampers[index]['Id']??'null');
    pref.setString("hamperDescription", hampers[index]['Description']??'null');
    pref.setString("hamperVendorName", hampers[index]['VendorName']??'null');
    pref.setString("hamperVendorID", hampers[index]['VendorID']??'null');
    pref.setString("hamperVendor_ID", hampers[index]['Vendor_ID']??'null');
    pref.setString("hamperVendorAddress", hampers[index]['VendorAddress']??'null');
    pref.setString("hamperVendorPhn1", hampers[index]['VendorPhoneNumber1']??'null');
    pref.setString("hamperVendorPhn2", hampers[index]['VendorPhoneNumber2']??'null');
    pref.setString("hamperTitle", hampers[index]['Title']??'null');
    pref.setString("hamperWeight", hampers[index]['Weight']??'null');
    pref.setString("hamperLat", hampers[index]['GoogleLocation']['Latitude'].toString()??'null');
    pref.setString("hamperLong", hampers[index]['GoogleLocation']['Longitude'].toString()??'null');
    pref.setStringList("hamperProducts", productsContains??[]);

    print(productsContains);

    Navigator.push(context, MaterialPageRoute(builder: (context)=>HamperDetails()));

  }


  //Default loader dialog
  void showAlertDialog() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)
            ),
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
                  SizedBox(
                    height: 13,
                  ),
                  Text(
                    'Please Wait...',
                    style: TextStyle(
                      color: Colors.black,
                      fontFamily: 'Poppins',
                    ),
                  )
                ],
              ),
            ),
          );
        });
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
  
  Future<void> getHampers() async{
    showAlertDialog();

    var headers = {
      'Authorization': '$authToken'
    };
    var request = http.Request('GET', Uri.parse('http://sugitechnologies.com/cakey/api/hamper/approvedlist'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      List map = jsonDecode(await response.stream.bytesToString());
      print(map);
      print(activeVendorsIds);
      setState((){
        if(activeVendorsIds.isNotEmpty){
          for(int i = 0;i<activeVendorsIds.length;i++){
            hampers = hampers + map.where((element) => element['VendorID'].toString().toLowerCase()==
                activeVendorsIds[i].toLowerCase()).toList();
          }
        }

        hampers = hampers.toSet().toList();
      });

      Navigator.pop(context);
    }
    else {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.reasonPhrase.toString()))
      );
    }

  }

  @override
  void initState(){
    Future.delayed(Duration.zero , () async{
      getInitialData();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar:AppBar(
        backgroundColor: lightGrey,
        elevation: 0.0,
        leading: Container(
          margin: EdgeInsets.all(12),
          child: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              height: 30,
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(7)),
              alignment: Alignment.center,
              child: Icon(
                Icons.chevron_left,
                size: 30,
                color: lightPink,
              ),
            ),
          ),
        ),
        title: Text(
          "GIFT HAMPERS",
          style: TextStyle(color: darkBlue, fontFamily: poppins, fontSize: 16),
        ),
      ),
      body:
      hampers.isEmpty?
      Center(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sentiment_dissatisfied_outlined , color:lightPink, size: 36,),
            SizedBox(height: 10,),
            Text("No Data Found!" , style: TextStyle(
              color: darkBlue  , fontSize: 20 , fontFamily: "Poppins" , fontWeight: FontWeight.bold
            ),)
          ],
        ),
      ):
      Container(
        padding: EdgeInsets.all(8),
        height: MediaQuery.of(context).size.height * 0.9,
        child:GridView.builder(
            shrinkWrap: true,
            itemCount: hampers.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 5.0,
                mainAxisSpacing: 5.0 ,
                mainAxisExtent: MediaQuery.of(context).size.height*0.27
            ),
            itemBuilder: (c , i)=>
                GestureDetector(
                  onTap: ()=>passDetails(i),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)
                    ),
                    child: Container(
                      padding: EdgeInsets.all(6),
                      child:Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            height: 125,
                            decoration: BoxDecoration(
                              color: Colors.red ,
                              borderRadius: BorderRadius.circular(10),
                              image: DecorationImage(
                                image: NetworkImage("${hampers[i]['HamperImage']}"),
                                fit: BoxFit.cover
                              )
                            ),
                          ),
                          SizedBox(height: 6,),
                          Text(
                              "${hampers[i]['HampersName']}",
                              style: TextStyle(
                               color: darkBlue,
                               fontFamily: "Poppins",
                               fontSize: 12.5,
                                overflow: TextOverflow.ellipsis
                              ),
                            maxLines: 2,
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 6,),
                          Text(
                            "₹ ${hampers[i]['Price']}",
                            style: TextStyle(
                                color: lightPink,
                                fontSize: 15,
                                fontWeight: FontWeight.w600
                            ),
                            maxLines: 2,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                )
        ),
      ),
    );
  }
}
