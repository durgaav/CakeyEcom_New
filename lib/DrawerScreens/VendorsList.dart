import 'package:flutter/material.dart';

class VendorsList extends StatefulWidget {
  const VendorsList({Key? key}) : super(key: key);

  @override
  State<VendorsList> createState() => _VendorsListState();
}

class _VendorsListState extends State<VendorsList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("Vendors list"),
      ),
    );
  }
}
