import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> with SingleTickerProviderStateMixin {
  Color lightGrey = Color(0xffF5F5F5);
  Color darkBlue = Color(0xffF213959);
  Color lightPink = Color(0xffFE8416D);

   late TabController tabControl ;

  @override
  void initState() {
    // TODO: implement initState
    tabControl = new TabController(length: 2,vsync: this);
    super.initState();
  }

  //region Widgets........
  Widget ProfileView(){
    return Column(
      children: [
        SizedBox(height: 10,),
        Container(
          height: 120,
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(blurRadius: 3, color: Colors.black, spreadRadius: 0)],
                ),
                child: CircleAvatar(
                  radius: 47,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: 45,
                    backgroundImage: NetworkImage("https://yt3.ggpht.com/1ezlnMBACv7Aa5TVu7OVumYrvIFQSsVtmKxKN102PV1vrZIoqIzHCO-XY_ZsWuGHzIgksOv__9o=s900-c-k-c0x00ffffff-no-rj"),
                  ),
                ),
              ),
              Positioned(
                  top: 60,
                  left: 50,
                  child: InkWell(
                    onTap: (){
                      print('hii');
                    },
                    child: CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 20,
                        child: Icon(Icons.camera_alt),
                      ),
                    ),
                  )
              ),
            ],
          ),
        ),
        TextField(
          maxLines: 1,
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            hintText: "Type Name",
            border: OutlineInputBorder(),
            label: Text('Name')
          ),
        ),
        SizedBox(height: 15,),
        TextField(
          maxLines: 1,
          maxLength: 10,
          maxLengthEnforced: true,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
              hintText: "Type Phone Number",
              border: OutlineInputBorder(),
              label: Text('Phone')
          ),
        ),
        TextField(
          maxLines: 3,
          keyboardType: TextInputType.streetAddress,
          decoration: InputDecoration(
              hintText: "Type Address",
              border: OutlineInputBorder(),
              label: Text('Address')
          ),
        ),
        Container(
          alignment: Alignment.centerLeft,
          child: TextButton(
              onPressed: (){},
              child: Text('add new address',style: TextStyle(
                color: Colors.orange,fontFamily: "Poppins",decoration: TextDecoration.underline
              ),)
          ),
        ),
        Container(
          alignment: Alignment.centerLeft,
          child: RaisedButton(
              onPressed: (){},
              color: darkBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)
              ),
              child: Text('SAVE',style: TextStyle(
                color: Colors.white
              ),),
          ),
        ),
        ListTile(
          leading: Icon(Icons.notifications_outlined,color: darkBlue,),
          title: Text('Notifications'),
          trailing: Transform.scale(
            scale: 0.7,
            child: CupertinoSwitch(
              value: true,
              onChanged: (bool? val){

              },
              activeColor: Colors.green,
            ),
          ),
        ),ListTile(
          leading: Icon(Icons.logout_outlined,color: lightPink,),
          title: Text('Logout'),
        ),

      ],
    );
  }

  Widget OrdersView(){
    return Column(
      children: [

      ],
    );
  }

  //endregion
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leading: Container(
          margin: EdgeInsets.all(6),
          child: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
                decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(10)),
                alignment: Alignment.center,
                height: 35,
                width: 35,
                child: Icon(
                  Icons.chevron_left,
                  color: lightPink,
                  size: 40,
                )),
          ),
        ),
        backgroundColor: lightGrey,
        title: Text(
          'PROFILE',
          style: TextStyle(
            color: darkBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              InkWell(
                onTap: () => print("hii"),
                child: Container(
                  alignment: Alignment.center,
                  height: 35,
                  width: 35,
                  decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(8)),
                  child: Icon(
                    Icons.notifications_none,
                    color: darkBlue,
                    size: 30,
                  ),
                ),
              ),
              Positioned(
                left: 20,
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
          )
        ],
      ),
      body: Container(
        margin: EdgeInsets.all(15),
        child: Column(
          children: [
            Container(
              height: 55,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black54,width: 1),
                borderRadius: BorderRadius.circular(
                  25.0,
                ),
              ),
              child: TabBar(
                controller: tabControl,
                // give the indicator a decoration (color and border radius)
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    25.0,
                  ),
                  color: Colors.black,
                ),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.black,
                tabs: [
                  // first tab [you can add an icon using the icon property]
                  Tab(
                    text: 'PROFILE INFO',
                  ),

                  // second tab [you can add an icon using the icon property]
                  Tab(
                    text: 'ORDER INFO',
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                 controller: tabControl,
                  children: [
                    SingleChildScrollView(
                        child: ProfileView()
                    ),
                    OrdersView(),
                  ]
              ),
            )
          ],
        ),
      ),
    );
  }
}
