import 'dart:convert';

import 'package:cakey/drawermenu/DrawerHome.dart';
import 'package:cakey/screens/CheckOut.dart';
import 'package:cakey/screens/Profile.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:http/http.dart' as http;


class TestScreen extends StatefulWidget {
  const TestScreen({Key? key}) : super(key: key);

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {

  List _elements = [
    {'topic': 'ListView.builder', 'group': 'ListView Type'},
    {'topic': 'Introduction', 'group': 'java'},
    {'topic': 'Explanation', 'group': 'java'},
    {'topic': 'Conclusion', 'group': 'java'},
    {'topic': 'StatefulWidget', 'group': 'Type of Widget'},
    {'topic': 'ListView', 'group': 'ListView Type'},
    {'topic': 'ListView.separated', 'group': 'ListView Type'},
    {'topic': 'ListView.custom', 'group': 'ListView Type'},
    {'topic': 'StatelessWidget', 'group': 'Type of Widget'},
  ];

  var height = 50.0;
  var width = 0.0;
  var closed = false;
  var droped = false;

  double opacity = 1.0;

  static const List<String> _kOptions = <String>[
    'aardvark',
    'bobcat',
    'chameleon',
  ];

  List suggest = [];

  var sugg = new TextEditingController();

  Future<void> suggestions(String typing) async {
    print(typing);
    suggest.clear();
    var res = await http.get(Uri.
    parse(
        'https://nominatim.openstreetmap.org/?addressdetails=1&q=$typing&format=json&limit=10'));

    if(res.statusCode==200){
      setState((){
        print(res.body);
        List myList = jsonDecode(res.body);
        print(myList.toSet());

        for(int i = 0 ; i < myList.length;i++){
          suggest.add(myList[i]['display_name'].toString());
        }

      });
    }else{
      print(res.statusCode);
    }

  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    return Scaffold(
      
      appBar: AppBar(
        title: Text(
          'Test Screen'
        ),
      ),
      body: Container(
        
        child:Column(
          children: [
            AnimatedOpacity(
              opacity: 0.5,
              duration: Duration(seconds: 3),
              child: Container(
                margin: EdgeInsets.all(10),
                height: 150,
                color: Colors.grey[350],
              ),
            ),
            RaisedButton(onPressed: (){
              setState((){

              });
            })
          ],
        ),

      ),
      // body: Container(
      //   child: SingleChildScrollView(
      //     child: Column(
      //       mainAxisAlignment: MainAxisAlignment.end,
      //       crossAxisAlignment: CrossAxisAlignment.center,
      //       mainAxisSize: MainAxisSize.min,
      //       children: [
      //
      //         TextField(
      //           controller: sugg,
      //           decoration: InputDecoration(
      //             hintText: "Search here..."
      //           ),
      //           onSubmitted:(String text){
      //               suggestions(text);
      //           },
      //           onEditingComplete: (){
      //             suggestions(sugg.text);
      //           },
      //         ),
      //
      //         SizedBox(height: 10,),
      //
      //         suggest.length>0?
      //         Container(
      //           height: 450,
      //           child: ListView.builder(
      //             shrinkWrap: true,
      //             itemCount: suggest.length,
      //             itemBuilder: (c , i){
      //               return Padding(
      //                 padding: const EdgeInsets.all(15.0),
      //                 child: Text("${suggest[i]}"),
      //               );
      //             },
      //           ),
      //         ):Text('No suggestion.')
      //
      //         // IndexedStack(
      //         //   index: 1,
      //         //   children: [
      //         //     CheckOut([],[]),
      //         //     Profile(defindex: 0),
      //         //   ],
      //         // ),
      //         //
      //         // // AnimatedContainer(
      //         // //     height: height,
      //         // //     margin: EdgeInsets.all(10),
      //         // //     duration: Duration(seconds: 1),
      //         // //     color:Colors.yellow,
      //         // //     curve: Curves.easeInOutCubicEmphasized,
      //         // //     child: Text('Hi broo how are you')
      //         // // ),
      //         //
      //         // // Container(
      //         // //   margin: EdgeInsets.all(10),
      //         // //   padding: EdgeInsets.all(10),
      //         // //   decoration: BoxDecoration(
      //         // //     color: Colors.indigo,
      //         // //     borderRadius: BorderRadius.circular(20)
      //         // //   ),
      //         // //   child: Row(
      //         // //     children: [
      //         // //       Draggable(
      //         // //           data: "Ok",
      //         // //           axis: Axis.horizontal,
      //         // //           child: Icon(Icons.arrow_forward_ios_rounded, color: Colors.white,),
      //         // //           feedback: Icon(Icons.arrow_forward_ios_rounded,color: Colors.white70,)
      //         // //       ),
      //         // //
      //         // //       SizedBox(width: 10,) ,
      //         // //
      //         // //       Shimmer.fromColors(
      //         // //         highlightColor: Colors.grey[400]!,
      //         // //         baseColor: Colors.white,
      //         // //         child: Text('Swipe To Navigate' , style: TextStyle(
      //         // //           color: Colors.white ,fontFamily: "Poppins" , fontSize: 20 ,
      //         // //           fontWeight: FontWeight.bold
      //         // //         ),),
      //         // //       ),
      //         // //
      //         // //       SizedBox(width: 10,) ,
      //         // //
      //         // //       Expanded(
      //         // //         child: Align(
      //         // //           alignment: Alignment.centerRight,
      //         // //           child: Container(
      //         // //
      //         // //             child: DragTarget(
      //         // //                 builder: (BuildContext context , List<dynamic> start , List<dynamic> end){
      //         // //                   return Icon(Icons.lock_open,color:Colors.white);
      //         // //                 } ,
      //         // //               onAccept: (data){
      //         // //                   Navigator.push(context, MaterialPageRoute(builder: (context)=>DrawerHome()));
      //         // //                   print(data);
      //         // //                   setState(() {
      //         // //                     droped = true;
      //         // //                   });
      //         // //               },
      //         // //               onWillAccept: (data){
      //         // //                   return data == "Ok";
      //         // //               },
      //         // //             ),
      //         // //           ),
      //         // //         ),
      //         // //       )
      //         // //
      //         // //     ],
      //         // //   ),
      //         // // )
      //
      //       ],
      //     ),
      //   ),
      // ),
    );
  }
}



class GroupedListView<T, E> extends ListView {
  GroupedListView({
    required E Function(T element) groupBy,
    required Widget Function(E value) groupSeparatorBuilder,
    required Widget Function(BuildContext context, T element) itemBuilder,
    GroupedListOrder order = GroupedListOrder.ASC,
    bool sort = true,
    Widget separator = const Divider(height: 0.0),
    List<T>? elements,
    Key? key,
    Axis scrollDirection = Axis.vertical,
    ScrollController? controller,
    bool? primary,
    ScrollPhysics? physics,
    bool shrinkWrap = false,
    EdgeInsetsGeometry? padding,
    bool addAutomaticKeepAlives = true,
    bool addRepaintBoundaries = true,
    bool addSemanticIndexes = true,
    double? cacheExtent,
  }) : super.builder(
    key: key,
    scrollDirection: scrollDirection,
    controller: controller,
    primary: primary,
    physics: physics,
    shrinkWrap: shrinkWrap,
    padding: padding,
    itemCount: elements!.length * 2,
    addAutomaticKeepAlives: addAutomaticKeepAlives,
    addRepaintBoundaries: addRepaintBoundaries,
    addSemanticIndexes: addSemanticIndexes,
    cacheExtent: cacheExtent,
    itemBuilder: (context, index) {
      int actualIndex = index ~/ 2;
      if (index.isEven) {
        E curr = groupBy(elements![actualIndex]);
        E prev = (actualIndex - 1 < 0
            ? null
            : groupBy(elements[actualIndex - 1])) as E;

        if (prev != curr) {
          return groupSeparatorBuilder(curr);
        }
        return Container();
      }
      return itemBuilder(context, elements![actualIndex]);
    },
  ) {
    if (sort && elements.isNotEmpty) {
      if (groupBy(elements[0]) is Comparable) {
        elements.sort((e1, e2) =>
            (groupBy(e1) as Comparable).compareTo(groupBy(e2) as Comparable));
      } else {
        elements
            .sort((e1, e2) => ('${groupBy(e1)}').compareTo('${groupBy(e2)}'));
      }
      if (order == GroupedListOrder.DESC) {
        elements = elements.reversed.toList();
      }
    }
  }
}

enum GroupedListOrder { ASC, DESC }