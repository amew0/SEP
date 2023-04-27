import 'package:flutter/material.dart';

class StatementPopup extends StatelessWidget {
  @override
  final List<dynamic> itemList;
  dynamic user;
  StatementPopup({required this.user, required this.itemList});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Color.fromARGB(255, 171, 182, 231),
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
                  'Transactions',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color.fromARGB(255, 77, 105, 230),
                    fontWeight: FontWeight.bold,
                    fontSize: 40,
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
                return Card(
                  color: Color.fromARGB(255, 171, 182, 231),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: Colors.black),
                  ),
                  child: Container(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                itemList[index].toString(),
                                style: TextStyle(
                                    color: Color.fromARGB(255, 77, 105, 230),
                                    fontWeight: FontWeight
                                        .w400 // set text color to white
                                    ),
                              ),
                            ),
                          ],
                        ),
                        // Divider(
                        //   height: 1,
                        //   color: Colors.black,
                        // ),
                        SizedBox(height: 10), // add gap between rows
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
