import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:date_field/date_field.dart';

class AllowanceForm {
  String userMain;
  String? userSub;
  String amount;
  bool instant;
  dynamic user;
  String date;

  AllowanceForm({
    required this.userMain,
    required this.userSub,
    required this.amount,
    required this.instant,
    required this.user,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'userMain': userMain,
        'userSub': userSub,
        'amount': amount,
        'user': user,
        'date': date,
        'instant': instant,
      };
}

class MyallowancePopup extends StatefulWidget {
  @override
  dynamic user;
  MyallowancePopup({required this.user});
  _MyallowancePopupState createState() => _MyallowancePopupState();
}

class _MyallowancePopupState extends State<MyallowancePopup> {
  final _formKey = GlobalKey<FormState>();
  // String? allowance_name = '';
  // String? allowance_amount = '';
  TextEditingController userMain = TextEditingController();
  String? userSub = "";
  TextEditingController amount = TextEditingController();
  TextEditingController instant = TextEditingController();

  // TextEditingController allowance_name = TextEditingController();
  // TextEditingController allowance_amount = TextEditingController();
  // TextEditingController allowance_description = TextEditingController();

  bool _isChecked = false;

  Future<void> Allowance(AllowanceForm form) async {
    final url = Uri.parse(
        'http://127.0.0.1:8000/allowance_api'); // insert correct API endpoint
    final headers = {'Content-Type': 'application/json'};
    print(form.date);
    final body = json.encode(form.toJson());
    final response = await http.post(url, headers: headers, body: body);
    // final user=0;
    if (response.statusCode == 200) {
      // Successful login
      print("successfully added allowance");

      final user = json.decode(response.body)[0];
      // Save the token to local storage or global state
    } else {
      // Failed login
      throw Exception('Failed to add allowance');
    }
    // return user;
  }

  @override
  Widget build(BuildContext context) {
    var choice;
    var dropdownValue;

    List<String> subsOnly = [];
    // Retrieving Sub Users
    for (dynamic innerList in widget.user[0]["mainSsubs"]) {
      subsOnly.add(innerList[0]);
    }
    print(widget.user[0]);
    return AlertDialog(
      title: const Text('Allowance Form'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: "Select User"),
              value: dropdownValue,
              onChanged: (String? newValue) {
                setState(() {
                  dropdownValue = newValue;
                  userSub = newValue;
                });
              },
              items: subsOnly.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            TextFormField(
              controller: amount,
              decoration: const InputDecoration(labelText: 'Amount'),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter allowance amount';
                }
                return null;
              },
              // onSaved: (value) {
              //   allowance_name = value;
              // },
            ),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Checkbox(
                value: _isChecked,
                onChanged: (bool? value) {
                  setState(() {
                    _isChecked = value ?? false;
                  });
                },
              ),
              Text(
                'Make an instant transfer',
                style: TextStyle(color: Colors.grey[700], fontSize: 10),
              ),
            ]),
          ],
        ),
      ),
      actions: <Widget>[
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            DateTime date;
            final form;
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              date = DateTime.now();
              form = AllowanceForm(
                  userMain: widget.user[0]["UserId"].toString(),
                  userSub: userSub,
                  amount: amount.text.trim(),
                  instant: _isChecked,
                  user: widget.user,
                  date: DateFormat('yy/MM/dd HH:mm:ss').format(DateTime.now()));
              // date: DateFormat('yyyy-MM-dd').format(date));

              await Allowance(form);
              // Do something with the form data, e.g. submit to server
              Navigator.pop(context);
            }
          },
          child: const Text('Submit'),
        ),
      ],
    );
  }
}
