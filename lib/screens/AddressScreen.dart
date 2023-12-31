import 'package:cakey/ContextData.dart';
import 'package:cakey/raised_button_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddressScreen extends StatefulWidget {
  const AddressScreen({Key? key}) : super(key: key);

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {

  //colors
  Color lightGrey = Color(0xffF5F5F5);
  Color darkBlue = Color(0xffF213959);
  Color lightPink = Color(0xffFE8416D);

  //controllers
  var streetCtrl = new TextEditingController();
  var cityCtrl = new TextEditingController();
  var distCtrl = new TextEditingController();
  var pinCtrl = new TextEditingController();

  var loading = false;

  List<String> addressList = [];


  Future<void> getAddrs() async{

  }

  //load pref
  Future<void> loadPref() async{

    var pr = await SharedPreferences.getInstance();

    setState((){
      addressList = pr.getStringList('addressList')!;
    });

  }

  void showLoader(){
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context){
          return AlertDialog(
            shape:RoundedRectangleBorder(
              borderRadius:BorderRadius.circular(20)
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

  //Fetching user's current location...Lat Long
  Future<Position> _getGeoLocationPosition() async {

    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      await Geolocator.openLocationSettings();
      print('Location services are disabled.');
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        print('Location permissions are denied');
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      print('Location permissions are permanently denied, we cannot request permissions.');
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.

    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  @override
  void initState(){
    Future.delayed(Duration.zero, () async{
      loadPref();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leading:Container(
          margin: const EdgeInsets.all(10),
          child: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
                decoration: BoxDecoration(
                    color:Colors.grey[300],
                    borderRadius: BorderRadius.circular(10)
                ),
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
        title: Text('ADD ADDRESS',
            style: TextStyle(
                color: darkBlue, fontWeight: FontWeight.bold, fontSize: 16)),
        elevation: 0.0,
        backgroundColor: lightGrey,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async{
          showLoader();

          Position position = await _getGeoLocationPosition();
          List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);

          Placemark place = placemarks[0];
          print(place);
          // Address = '${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';

          setState(()  {
            streetCtrl = new TextEditingController(text: place.street.toString()+", "+place.subLocality.toString()+", ");
            cityCtrl = new TextEditingController(text: place.locality.toString()+","+place.subAdministrativeArea.toString()+",");
            distCtrl = new TextEditingController(text: place.administrativeArea.toString()+", ");
            pinCtrl = new TextEditingController(text: place.postalCode);
          });

          Navigator.pop(context);
        },
        child: Icon(
          Icons.my_location_outlined,
          color: Colors.white,
        ),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        color: Colors.white,
        padding: EdgeInsets.all(8),
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            children: [
              TextField(
                controller: streetCtrl,
                keyboardType: TextInputType.streetAddress,
                maxLines: 1,
                decoration: InputDecoration(
                    hintText: "Street.",
                    hintStyle: TextStyle(
                        fontSize: 13.5,fontFamily: "Poppins"
                    ),
                    border:OutlineInputBorder()
                ),
              ),
              SizedBox(height: 10,),
              TextField(
                controller: cityCtrl,
                keyboardType: TextInputType.streetAddress,
                maxLines: 1,
                decoration: InputDecoration(
                    hintText: "City/Area/Town.",
                    hintStyle: TextStyle(
                        fontSize: 13.5,fontFamily: "Poppins"
                    ),
                    border:OutlineInputBorder()
                ),
              ),
              SizedBox(height: 10,),
              TextField(
                controller: distCtrl,
                keyboardType: TextInputType.streetAddress,
                maxLines: 1,
                decoration: InputDecoration(
                    hintText: "District.",
                    hintStyle: TextStyle(
                        fontSize: 13.5,fontFamily: "Poppins"
                    ),
                    border:OutlineInputBorder()
                ),
              ),
              SizedBox(height: 10,),
              TextField(
                controller: pinCtrl,
                keyboardType: TextInputType.phone,
                maxLines: 1,
                maxLength: 6,
                decoration: InputDecoration(
                    hintText: "Pincode.",
                    hintStyle: TextStyle(
                        fontSize: 13.5,fontFamily: "Poppins"
                    ),
                    border:OutlineInputBorder()
                ),
              ),
              SizedBox(height: 10,),
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  width:90,
                  height:35,
                  child: CustomRaisedButton(
                    onPressed: () async{
                      var pr = await SharedPreferences.getInstance();
                      FocusScope.of(context).unfocus();



                      if(streetCtrl.text.isEmpty||cityCtrl.text.isEmpty||distCtrl.text.isEmpty||
                          pinCtrl.text.isEmpty||pinCtrl.text.length<6){

                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Please Fill All Fields!"),
                              backgroundColor: Colors.black,
                              behavior: SnackBarBehavior.floating,
                            )
                        );

                      }else if(addressList.contains("${streetCtrl.text} ${cityCtrl.text} ${distCtrl.text} ${pinCtrl.text}")){

                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Address Already exist"),
                              backgroundColor: Colors.black,
                              behavior: SnackBarBehavior.floating,
                            )
                        );

                      }else{

                        // setState((){
                        //   context.read<ContextData>().setAddress(
                        //       "${streetCtrl.text},${cityCtrl.text},${distCtrl.text},${pinCtrl.text}"
                        //   );
                        // });

                        setState(() {
                          addressList.add("${streetCtrl.text} ${cityCtrl.text} ${distCtrl.text} ${pinCtrl.text}");
                          context.read<ContextData>().setAddressList(addressList);
                          pr.setStringList('addressList', addressList);
                          streetCtrl.text='';
                          cityCtrl.text='';
                          distCtrl.text='';
                          pinCtrl.text='';
                          loadPref();
                        });

                        // Navigator.pop(context);
                      }

                    },
                    child: Text(
                      "Save",
                      style: TextStyle(
                          fontFamily: "Poppins",
                          color: Colors.white
                      ),
                    ),
                    color: lightPink,
                  ),
                ),
              ),

              ListView.builder(
                shrinkWrap: true,
                reverse: true,
                itemCount: addressList.length,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (c,i)=>
                    GestureDetector(
                      onTap: (){

                      },
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(10)
                        ),
                        margin: EdgeInsets.only(bottom: 8,top: 8),
                        padding: EdgeInsets.all(12),
                        child:ListTile(
                          title: Text(addressList[i], style: TextStyle(
                              fontFamily: "Poppins",
                              color:darkBlue
                          ),),
                          trailing: IconButton(
                            splashColor: Colors.red,
                            onPressed: () async{

                              var pr = await SharedPreferences.getInstance();

                              setState((){
                                addressList.removeWhere((element) => element==addressList[i]);
                                context.read<ContextData>().setAddressList(addressList);
                                pr.setStringList("addressList", addressList);
                                loadPref();
                              });

                            },
                            icon: Icon(Icons.delete_outline_outlined),
                          ),
                        ),
                      ),
                    )
                ,
              ),

            ],
          ),
        ),
      ),

    );
  }
}

