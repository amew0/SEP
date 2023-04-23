import 'package:flutter/material.dart';

class StatementPopup extends StatelessWidget {
  @override
  final List<dynamic> itemList;
  dynamic user;
  StatementPopup({required this.user, required this.itemList});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'List',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          Container(
            height: 200,
            child: ListView.builder(
              itemCount: itemList.length,
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(itemList[index].toString()),
                      ),
                    ],
                  ),
                );
              },
            ),
            // ListView.builder(
            //   itemCount: itemList.length,
            //   itemBuilder: (context, index) {
            //     // print(itemList[0]['statements']);
            //     final element = itemList[index];
            //     return ListTile(
            //       title: Text(element.toString()),
            //     );
            //     // itemBuilder: (BuildContext context, int index) {
            //     //   return ListTile(
            //     //     title: Text(itemList[index]),
            //     //   );
            //   },
            // ),
          ),
        ],
      ),
    );
  }
}
