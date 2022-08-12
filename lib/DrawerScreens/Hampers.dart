import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        backgroundColor: lightGrey,
        elevation: 0,
        centerTitle: true,
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
          "Hampers",
          style: TextStyle(color: darkBlue, fontFamily: poppins, fontSize: 16),
        ),
      ),
    );
  }
}
