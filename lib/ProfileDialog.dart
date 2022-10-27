import 'package:cakey/screens/Profile.dart';
import 'package:flutter/material.dart';

class ProfileAlert{

  Color lightGrey = Color(0xffF5F5F5);
  Color darkBlue = Color(0xffF213959);
  Color lightPink = Color(0xffFE8416D);

  void showProfileAlert(BuildContext context){
    showDialog(
        barrierDismissible: true,
        context: context,
        builder: (context) {
          return Align(
              alignment: Alignment.topCenter,
              child:Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                    )
                ),
                padding: EdgeInsets.all(10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children:[
                          Container(
                            height : 40,
                            width: 40,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                color: Colors.amber,
                                borderRadius: BorderRadius.circular(10)
                            ),
                            child: Icon(Icons.campaign_rounded,color:darkBlue,size: 28,),
                          ),
                          const SizedBox(width: 8,),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Complete Your Profile",style: TextStyle(
                                    color: darkBlue,fontFamily: "Poppins",fontWeight: FontWeight.bold,
                                    fontSize: 14.5,decoration: TextDecoration.none
                                ),),
                                SizedBox(height: 20,),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Container(
                                    height: 30,
                                    width: 100,
                                    decoration:BoxDecoration(
                                        borderRadius: BorderRadius.circular(20)
                                    ),
                                    child: RaisedButton(
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20)
                                      ),
                                      onPressed:(){
                                        Navigator.push(context, MaterialPageRoute(builder: (context)=>Profile(defindex: 0)));
                                      },
                                      child: Text("PROFILE",style: TextStyle(
                                          color: Colors.white,fontFamily: "Poppins",fontWeight: FontWeight.bold,
                                          fontSize: 12,decoration: TextDecoration.none
                                      ),),
                                      color: lightPink,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                    color: Colors.black12,
                                    borderRadius: BorderRadius.circular(7)),
                                alignment: Alignment.center,
                                child: Icon(
                                  Icons.close_outlined,
                                  color: darkBlue,
                                )),
                          ),
                        ]
                    )
                  ],
                ),
              )
          );
        });
  }
}