import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class SingleVendor extends StatefulWidget {
  const SingleVendor({Key? key}) : super(key: key);
  @override
  State<SingleVendor> createState() => _SingleVendorState();
}

class _SingleVendorState extends State<SingleVendor> {

  //Colors
  Color lightGrey = Color(0xffF5F5F5);
  Color darkBlue = Color(0xffF213959);
  Color lightPink = Color(0xffFE8416D);

  String poppins = "Poppins";
  String description = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, "
      "sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. "
      "Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut"
      " aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate "
      "velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa "
      "qui officia deserunt mollit anim id est laborum.";

  List<bool> isExpands = [];

  @override
  Widget build(BuildContext context) {
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
                        SizedBox(width: 8,),
                        Text('Delivery to',style: TextStyle(color: Colors.black54,fontWeight: FontWeight.bold,
                            fontFamily: "Poppins"),)
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
                          Text('Vendor name',style: TextStyle(
                            color: darkBlue,fontFamily:"Poppins",
                            fontSize: 16,fontWeight: FontWeight.bold
                          ),),
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
                      Container(
                        width: 100,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            InkWell(
                              onTap: (){
                                print('phone..');
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
                                print('whatsapp');
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
                  //Sel button
                  Container(
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
                  SizedBox(height: 10,),
                  //Theme text
                  Text('Special velvet theme cake made by Surya this hgafjgdfghg',
                    style: TextStyle(color: darkBlue,
                      fontWeight: FontWeight.bold),
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

            //Vendors recent orders....
            Padding(
              padding: const EdgeInsets.all(10),
              child: Text("History",
                style: TextStyle(color: darkBlue,fontSize: 14,fontFamily: "Poppins",fontWeight: FontWeight.bold),
              ),
            ),

            Container(
              margin: EdgeInsets.all(10),
              child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: 2,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context,index){
                    isExpands.add(false);
                    return GestureDetector(
                      onTap:(){
                        setState(() {
                          if(isExpands[index]==false){
                            isExpands[index]=true;
                          }else{
                            isExpands[index]=false;
                          }
                        });
                      },
                      child: Card(
                        elevation: 6.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)
                        ),
                        child: Container(
                          padding: EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: Colors.black26
                                ),
                                child:const Text('Order ID #0007',style: const TextStyle(
                                    fontSize: 10,fontFamily: "Poppins",color: Colors.black
                                ),),
                              ),
                              SizedBox(height: 6,),
                              //Theme text
                              Text('Special velvet theme cake made by Surya this hgafjgdfghg',
                                style: TextStyle(color: darkBlue,
                                    fontWeight: FontWeight.bold,fontSize: 13
                                ),
                              ),
                              SizedBox(height: 6,),
                              Text('Cake description goskanfndsnfdsjfjdfCake',
                                style: TextStyle(
                                    color: Colors.grey,fontFamily: "Poppins",fontSize: 12
                                ),
                              ),
                              SizedBox(height: 3,),
                              Container(
                                  height: 1,
                                  color: Colors.black26,
                              ),SizedBox(height: 3,),

                              Row(
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
                                  Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text("Delivered ",style: TextStyle(color: Colors.green,
                                                  fontWeight: FontWeight.bold,fontFamily: "Poppins",fontSize: 11),),
                                              Icon(Icons.verified_rounded,color: Colors.green,size: 12,)
                                            ],
                                          ),
                                          SizedBox(width: 5,),
                                          Text("28-03-2022",style: TextStyle(color: Colors.black26,
                                              fontFamily: "Poppins",fontSize: 10,fontWeight: FontWeight.bold),),
                                        ],
                                      ),
                                ],
                              ),
                              SizedBox(height: 3,),
                              Container(
                                height: 1,
                                color: Colors.black26,
                              ),
                              ListTile(
                                title: Text('Customer',style: TextStyle(
                                  fontSize: 12,color: Colors.grey,fontFamily: "Poppins"
                                ),),
                                subtitle: Text('Surya prakash',style: TextStyle(
                                    fontSize: 13,color:darkBlue,fontFamily: "Poppins",
                                    fontWeight: FontWeight.bold
                                ),),
                              ),
                              Visibility(
                                visible:isExpands[index],
                                child: AnimatedContainer(
                                  duration: const Duration(seconds: 3),
                                  curve: Curves.elasticInOut,
                                  color: Colors.black12,
                                  child: Column(
                                    children: [
                                      const SizedBox(height: 15,),
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(width: 8,),
                                          const Icon(
                                            Icons.location_on,
                                            color: Colors.red,
                                          ),
                                          const SizedBox(width: 8,),
                                          Container(
                                              width: 260,
                                              child: const Text(
                                                "1/4 Vellandipalayam thekkalur 641654",
                                                style: TextStyle(
                                                    fontFamily: "Poppins",
                                                    color: Colors.black54,
                                                    fontSize: 13
                                                ),
                                              )
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 15,),
                                      Container(
                                        margin: const EdgeInsets.only(left: 10,right: 10),
                                        color: Colors.black26,
                                        height: 1,
                                      ),

                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            const Text('Item Total',style: TextStyle(
                                              fontFamily: "Poppins",
                                              color: Colors.black54,
                                            ),),
                                            const Text('₹500',style: const TextStyle(fontWeight: FontWeight.bold),),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            const Text('Delivery charge',style: const TextStyle(
                                              fontFamily: "Poppins",
                                              color: Colors.black54,
                                            ),),
                                            const Text('₹10',style: const TextStyle(fontWeight: FontWeight.bold),),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            const Text('Discounts',style: const TextStyle(
                                              fontFamily: "Poppins",
                                              color: Colors.black54,
                                            ),),
                                            const Text('₹500',style: const TextStyle(fontWeight: FontWeight.bold),),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            const Text('Taxes',style: const TextStyle(
                                              fontFamily: "Poppins",
                                              color: Colors.black54,
                                            ),),
                                            const Text('₹500',style: const TextStyle(fontWeight: FontWeight.bold),),
                                          ],
                                        ),
                                      ),

                                      Container(
                                        margin: const EdgeInsets.only(left: 10,right: 10),
                                        color: Colors.black26,
                                        height: 1,
                                      ),
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            const Text('Bill Total',style: TextStyle(
                                                fontFamily: "Poppins",
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold
                                            ),),
                                            const Text('₹500',style: TextStyle(fontWeight: FontWeight.bold),),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            const Text('Paid via : Google pay',style: TextStyle(
                                              fontFamily: "Poppins",
                                              color: Colors.black54,
                                            ),),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  }
              ),
            )
          ],
        ),
      )
    );
  }
}

