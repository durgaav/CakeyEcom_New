import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class CheckOut extends StatefulWidget {
  const CheckOut({Key? key}) : super(key: key);
  @override
  State<CheckOut> createState() => _CheckOutState();
}

class _CheckOutState extends State<CheckOut> {

  //Colors
  Color lightGrey = Color(0xffF5F5F5);
  Color darkBlue = Color(0xffF213959);
  Color lightPink = Color(0xffFE8416D);

  String poppins = "Poppins";

  List<bool> isExpands = [];

  String paymentType = "UPI";
  bool isExpand = false;

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
          title: Text('CHECKOUT',
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
          ],
        ),
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: double.infinity,
          margin: EdgeInsets.all(15),
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.black26,width: 1)
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 90,
                      width: 75,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          image: DecorationImage(
                              image:NetworkImage( "https://newcastlebeach.org/images/mousse-9.jpg"),fit: BoxFit.cover
                          )
                      ),
                    ),
                    SizedBox(width: 5,),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 210,
                          child: Text('The cake name goes here fhggdsfdhsgfhdgshf',style: TextStyle(
                              fontSize: 12,fontFamily: "Poppins",fontWeight: FontWeight.bold
                          ),overflow: TextOverflow.ellipsis,maxLines: 2,),
                        ),
                        SizedBox(height: 5,),
                        Container(
                          width: 210,
                          child: Text('descriptionsssssssabfhadshfghhfgdghgdfagadgzdfgg',style: TextStyle(
                              fontSize: 10,fontFamily: "Poppins",color: Colors.black26
                          ),overflow: TextOverflow.ellipsis,maxLines: 2,),
                        ),
                        SizedBox(height: 5,),
                        Text('₹ 720',style: TextStyle(
                            fontSize: 17,color: lightPink,fontWeight: FontWeight.bold
                        ),
                          overflow: TextOverflow.ellipsis,maxLines: 2,
                        ),
                      ],
                    )
                  ],
                ),
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(bottomRight: Radius.circular(25)
                      ,bottomLeft:  Radius.circular(25)
                      ),
                      color: Colors.black12
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        title: const Text('Vendor',style: const TextStyle(
                            fontSize: 11,fontFamily: "Poppins"
                        ),),
                        subtitle: const Text('Naveen',style: TextStyle(
                            fontSize: 14,fontFamily: "Poppins",
                            fontWeight: FontWeight.bold,color: Colors.black
                        ),),
                        trailing: Container(
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
                                  decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white
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
                                  decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white
                                  ),
                                  child:const Icon(Icons.whatsapp_rounded,color: Colors.green,),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.only(left: 15,bottom: 10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Cake Type',style: TextStyle(
                                fontSize: 11,fontFamily: "Poppins"
                            ),),
                            const Text('Birthday',style: TextStyle(
                                fontSize: 14,fontFamily: "Poppins",
                                fontWeight: FontWeight.bold,color: Colors.black
                            ),),
                          ],
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 10,right: 10),
                        color: Colors.black26,
                        height: 1,
                      ),
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
                    ],
                  ),
                ),
                ExpansionTile(
                  title: Text('Payment type',style: TextStyle(
                    color: Colors.black26,fontFamily: "Poppins",fontSize: 12
                  ),),
                  subtitle: Text('$paymentType',style: TextStyle(
                      color: darkBlue,fontFamily: "Poppins",fontSize: 14,
                      fontWeight: FontWeight.bold
                  ),),
                  children: [
                    ListTile(
                      onTap: (){
                        setState(() {
                          paymentType = "UPI";
                        });
                      },
                      title:Text('UPI',style: TextStyle(
                          color: darkBlue,fontFamily: "Poppins",fontSize: 14,
                          fontWeight: FontWeight.bold
                      ),),
                    ),
                    ListTile(
                      onTap: (){
                        setState(() {
                          paymentType = "COD";
                        });
                      },
                      title:Text('Cash On Delivery',style: TextStyle(
                          color: darkBlue,fontFamily: "Poppins",fontSize: 14,
                          fontWeight: FontWeight.bold
                      ),),
                    ),
                    ListTile(
                      onTap: (){
                        setState(() {
                          paymentType = "Credit Card";
                        });
                      },
                      title:Text('Credit Card',style: TextStyle(
                          color: darkBlue,fontFamily: "Poppins",fontSize: 14,
                          fontWeight: FontWeight.bold
                      ),),
                    ),
                  ],
                ),
                paymentType=="Credit Card"?
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.black12
                  ),
                  child: Column(
                    children: [
                      TextField(
                        decoration: InputDecoration(
                            label: Text('Name on card'),
                            hintText: "Name on card",
                            prefixIcon: Icon(Icons.account_circle)
                        ),
                      ),
                      TextField(
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                            label: Text('Card number'),
                            hintText: "Card number",
                            prefixIcon: Icon(Icons.credit_card_outlined)
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Container(
                            width: 130,
                            child: TextField(
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                  label: Text('Card Expiry'),
                                  hintText: "Card Expiry",
                              ),
                            ),
                          ),
                          Container(
                            width: 130,
                            child: TextField(
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                  label: Text('CVV'),
                                  hintText: "CVV",
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ) ,
                ):
                Container(),
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
                      // Navigator.of(context).push(
                      //   PageRouteBuilder(
                      //     pageBuilder: (context, animation, secondaryAnimation) => CheckOut(),
                      //     transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      //       const begin = Offset(1.0, 0.0);
                      //       const end = Offset.zero;
                      //       const curve = Curves.ease;
                      //
                      //       final tween = Tween(begin: begin, end: end);
                      //       final curvedAnimation = CurvedAnimation(
                      //         parent: animation,
                      //         curve: curve,
                      //       );
                      //
                      //       return SlideTransition(
                      //         position: tween.animate(curvedAnimation),
                      //         child: child,
                      //       );
                      //     },
                      //   ),
                      // );
                    },
                    color: lightPink,
                    child: Text("PROCEED TO PAY",style: TextStyle(
                        color: Colors.white,fontWeight: FontWeight.bold
                    ),),
                  ),
                )
              ],
            ),
          ),
        )
    );
  }
}

