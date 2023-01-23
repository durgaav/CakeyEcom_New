import 'dart:convert';

import 'package:cakey/ContextData.dart';
import 'package:cakey/MyDialogs.dart';
import 'package:cakey/functions.dart';
import 'package:cakey/screens/utils.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CouponsList extends StatefulWidget {
  String uid;
  CouponsList(this.uid);

  @override
  State<CouponsList> createState() => _CouponsListState(uid);
}

class _CouponsListState extends State<CouponsList> {
  String uid;
  _CouponsListState(this.uid);

  //Colors
  Color lightGrey = const Color(0xffF5F5F5);
  Color darkBlue = const Color(0xffF213959);
  Color lightPink = const Color(0xffFE8416D);

  List codesList = [];

  Future<void> getCouponCodesByUid() async {
    MyDialogs().showTheLoader(context);
    try{
      var pr = await SharedPreferences.getInstance();
      var tok = pr.getString("authToken")??"";

      var res = await http.get(
          Uri.parse("${API_URL}api/couponCode/ListbyUserID/$uid"),
          headers:{'Authorization': '$tok'}
      );

      print(res.body);
      var data = jsonDecode(res.body);

      if(res.statusCode == 200){
        Navigator.pop(context);

        setState(() {
          if(data is List){
            codesList = data;
          }
        });

      }else{
        Navigator.pop(context);
      }


    }catch(e){
      Navigator.pop(context);
    }
    
  }

  Future<String> checkValidCoupon(String coupon) async {

    String status = "Not Expired";

    try{
      var pr = await SharedPreferences.getInstance();
      var tok = pr.getString("authToken")??"";

      var res = await http.get(
          Uri.parse("${API_URL}api/couponCode/validate/$uid/$coupon"),
          headers:{'Authorization': '$tok'}
      );

      print(res.body);
      var data = jsonDecode(res.body);

      if(res.statusCode == 200){
        if(data['statusCode']==400){
          status = "Expired!";
        }
      }else{

      }


    }catch(e){
      print(e);
    }

    return status;

  }

  @override
  void initState() {
    // TODO: implement initState
    Future.delayed(Duration.zero , () async {
      getCouponCodesByUid();
    });
    super.initState();
  }


  @override
  Widget build(BuildContext context) {

    var deviceSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor:Colors.white,
      appBar:PreferredSize(
          preferredSize: Size.fromHeight(50),
          child:SafeArea(
            child: Container(
              padding: EdgeInsets.only(left: 15),
              height: 50,
              color:lightGrey,
              child:Row(
                children: [
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
                  Container(
                    margin: EdgeInsets.only(left: 15),
                    child: Text(
                      'MY COUPONS',
                      style: TextStyle(
                          color: darkBlue,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
          )
      ),
      body:Container(
        height:deviceSize.height,
        width:deviceSize.width,
        padding:EdgeInsets.all(10),
        child:Column(
          children: [
            Expanded(child:
            codesList.isNotEmpty?
            GridView.builder(
              gridDelegate:SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing:10,
                  mainAxisSpacing:10,
                  mainAxisExtent:deviceSize.height*0.12
              ),
              itemBuilder:(c , index){
                String snapData = "";
                return GestureDetector(
                  onTap: (){
                    print(snapData);
                    if(snapData.toString()=="Expired!"){
                      print(snapData);
                      Functions().showSnackMsg(context, "Coupon code is expired!", true);
                    }else{
                      Navigator.pop(context);
                      context.read<ContextData>().setCodeData({
                        "type":codesList[index]['CouponType'].toString(),
                        "value":codesList[index]['CouponValue'].toString(),
                        "code":codesList[index]['Code'].toString(),
                        "id":codesList[index]['_id'].toString()
                      });
                      /*Rest of code*/
                    }
                    //checkValidCoupon(codesList[index]['Code']);
                  },
                  child: Container(
                    alignment:Alignment.center,
                    margin:EdgeInsets.symmetric(horizontal:5,vertical: 4),
                    decoration:BoxDecoration(
                      borderRadius:BorderRadius.circular(20),
                      color:Colors.white,
                      image:DecorationImage(
                        image:AssetImage("assets/images/splash.png"),
                        fit:BoxFit.cover
                      ),
                      boxShadow:[
                        BoxShadow(
                            color: Colors.grey[400]!,
                            blurRadius: 6.0,
                            offset: Offset(0.0, 0.6)
                        )
                      ]
                    ),
                    child:Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("${codesList[index]['Code']}" , style:TextStyle(
                          fontFamily:"Poppins",
                          fontSize:20,
                          fontWeight:FontWeight.bold,
                          color:darkBlue
                        ),maxLines:1,),
                        SizedBox(height:5,),
                        Text(
                          codesList[index]['CouponType'].toString().toLowerCase()=="amount"?
                          "Rs ${codesList[index]['CouponValue']}":
                          "${codesList[index]['CouponValue']} %"
                          ,maxLines: 1,style: TextStyle(
                            fontFamily:"Poppins",
                            fontSize:13,
                            color:Colors.grey[40]
                        ),),
                        SizedBox(height:5,),
                        FutureBuilder(
                          future:checkValidCoupon(codesList[index]['Code']),
                          builder:(con , snap){
                            if(snap.hasData){
                              snapData = snap.data.toString();
                              return Text(
                                "${snap.data}",maxLines: 1,style: TextStyle(
                                  fontFamily:"Poppins",
                                  fontSize:13,
                                  color:Colors.grey[40]
                              ),);
                            }else{
                              return Text(
                                "Not Expired!"
                                ,maxLines: 1,style: TextStyle(
                                  fontFamily:"Poppins",
                                  fontSize:13,
                                  color:Colors.grey[40]
                              ),);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
              itemCount:codesList.length,
            ):
            Center(
              child:Text("No Coupons Found!",style:TextStyle(
                fontFamily:"Poppins",
                fontSize:20,
                fontWeight:FontWeight.bold,
                color:darkBlue
              ),),
            )
            )
          ],
        ),
      ),
    );
  }
}
