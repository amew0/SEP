import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:date_field/date_field.dart';

class billForm {
  String bill_name;
  String bill_amount;
  String bill_description;
  String date;
  bool bill_scheduled_monthly;

  dynamic user;
  billForm({
    required this.bill_name,
    required this.user,
    required this.bill_amount,
    required this.bill_description,
    required this.bill_scheduled_monthly,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'bill_name': bill_name,
        'bill_amount': bill_amount,
        'bill_description': bill_description,
        'bill_scheduled_monthly': bill_scheduled_monthly,
        'user': user,
        'date': date,
      };
}

class MyBillPopup extends StatefulWidget {
  @override
  dynamic user;
  MyBillPopup({required this.user});
  _MyBillPopupState createState() => _MyBillPopupState();
}

class _MyBillPopupState extends State<MyBillPopup> {
  final _formKey = GlobalKey<FormState>();
  // String? bill_name = '';
  // String? bill_amount = '';
  TextEditingController bill_description = TextEditingController();
  TextEditingController bill_name = TextEditingController();
  TextEditingController bill_amount = TextEditingController();
  bool _isChecked = false;

  Future<void> bill(billForm form) async {
    final url = Uri.parse(
        'http://127.0.0.1:8000/pay_bills'); // insert correct API endpoint
    final headers = {'Content-Type': 'application/json'};
    final body = json.encode(form.toJson());
    final response = await http.post(url, headers: headers, body: body);
    // final user=0;
    if (response.statusCode == 200) {
      // Successful login
      print("successfully added bill");
      final user = json.decode(response.body)[0];
      // Save the token to local storage or global state
    } else {
      // Failed login
      throw Exception('Failed to add bill');
    }
    // return user;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Bill form'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextFormField(
              controller: bill_name,
              decoration: InputDecoration(labelText: 'Bill Name'),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter bill name';
                }
                return null;
              },
              // onSaved: (value) {
              //   bill_name = value;
              // },
            ),
            TextFormField(
              controller: bill_amount,
              decoration: InputDecoration(labelText: 'Bill amount'),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter bill amount';
                }
                return null;
              },
              // onSaved: (value) {
              //   bill_amount = value;
              // },
            ),
            TextField(
              controller: bill_description,
              maxLines: 10,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
              ),
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
                'make this payment monthly recurring',
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
              if (_isChecked == true) {
                date = DateTime.now();
                form = billForm(
                    bill_name: bill_name.text.trim(),
                    bill_amount: bill_amount.text.trim(),
                    bill_description: bill_description.text.trim(),
                    bill_scheduled_monthly: _isChecked,
                    user: widget.user,
                    date: DateFormat('yyyy-MM-dd').format(date));
              } else {
                form = billForm(
                    bill_name: bill_name.text.trim(),
                    bill_amount: bill_amount.text.trim(),
                    bill_description: bill_description.text.trim(),
                    bill_scheduled_monthly: _isChecked,
                    user: widget.user,
                    date: "none");
              }
              await bill(form);
              // Do something with the form data, e.g. submit to server
              Navigator.pop(context);
            }
          },
          child: Text('Submit'),
        ),
      ],
    );
  }
}
