import 'package:flutter/material.dart';


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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text('Grouped ListView')
        ),
        body: GroupedListView<dynamic, String>(
            groupBy: (element) => element['group'],
            elements: _elements,
            order: GroupedListOrder.DESC,
            groupSeparatorBuilder: (String value) => Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                    child: Text(
                        value,
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
                    ))
            ),
            itemBuilder: (c, element) {
              return Card(
                  elevation: 1.0,
                  margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                  child: Container(
                      child: ListTile(
                          contentPadding:
                          EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                          leading: Icon(Icons.account_circle),
                          title: Text(element['topic']), //element['group'] group name get
                          trailing: Icon(Icons.arrow_forward)
                      )
                  )
              );
            }
        )
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