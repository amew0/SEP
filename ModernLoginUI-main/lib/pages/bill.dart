import 'dart:convert';
import 'package:flutter/services.dart';
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
  double AmountBill = 0.0;
  Future<bool> bill(billForm form) async {
    final url = Uri.parse(
        'http://127.0.0.1:8000/pay_bills'); // insert correct API endpoint
    final headers = {'Content-Type': 'application/json'};
    final body = json.encode(form.toJson());
    final response = await http.post(url, headers: headers, body: body);
    if (response.statusCode == 200) {
      AmountBill = double.parse(form.bill_amount);
      print("successfully added bill");
      // await Future.delayed(const Duration(seconds: 3));
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) =>
              buildAlertDialog(context, "Bill created successfully."),
        );
      }
    } else {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) => buildAlertDialog(
              context, "Bill couldn't be created. Please try again."),
        );
      }
    }
    return response.statusCode == 200;
  }

  Widget buildAlertDialog(BuildContext context, String response) {
    return AlertDialog(
      title: const Text('Bill info'),
      content: Text(response),
      // actions: [
      //   TextButton(
      //     child: const Text('OK'),
      //     onPressed: () {
      //       Navigator.of(context).pop();
      //     },
      //   ),
      // ],
    );
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
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(
                    r'^\d{1,9}$|(?=^.{1,9}$)^\d+\.\d{0,2}$')), // only allow numbers and dot
              ],
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
              decoration: const InputDecoration(
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
            Navigator.pop(context, AmountBill);
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            DateTime date;
            final form;
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              date = DateTime.now();
              form = billForm(
                  bill_name: bill_name.text.trim(),
                  bill_amount: bill_amount.text.trim(),
                  bill_description: bill_description.text.trim(),
                  bill_scheduled_monthly: _isChecked,
                  user: widget.user,
                  date: DateFormat('dd/MM/yy hh:mm:ss').format(date));
              // if (_isChecked == true) {
              //   date = DateTime.now();
              //   form = billForm(
              //       bill_name: bill_name.text.trim(),
              //       bill_amount: bill_amount.text.trim(),
              //       bill_description: bill_description.text.trim(),
              //       bill_scheduled_monthly: _isChecked,
              //       user: widget.user,
              //       date: DateFormat('dd/MM/yy hh:mm:ss').format(date));
              // } else {
              //   form = billForm(
              //       bill_name: bill_name.text.trim(),
              //       bill_amount: bill_amount.text.trim(),
              //       bill_description: bill_description.text.trim(),
              //       bill_scheduled_monthly: _isChecked,
              //       user: widget.user,
              //       date: "none");
              // }
              bool successful = await bill(form);
              // Do something with the form data, e.g. submit to server
              await Future.delayed(const Duration(seconds: 1));
              Navigator.of(context).pop(AmountBill);
              if (successful) {
                Navigator.of(context).pop(AmountBill);
              }
              // Navigator.pop(context);
            }
          },
          child: const Text('Submit'),
        ),
      ],
    );
  }
}
