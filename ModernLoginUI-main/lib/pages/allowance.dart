import 'dart:convert';
import 'package:flutter/services.dart';
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
  double AmountAllowance = 0;
  bool _isChecked = false;

  Future<bool> Allowance(AllowanceForm form) async {
    final url = Uri.parse(
        'http://127.0.0.1:8000/allowance_api'); // insert correct API endpoint
    final headers = {'Content-Type': 'application/json'};
    print(form.date);
    final body = json.encode(form.toJson());
    final response = await http.post(url, headers: headers, body: body);
    // final user=0;
    if (response.statusCode == 200) {
      // Successful login
      print("Allowance added successfully.");
      AmountAllowance = double.parse(form.amount);
      final user = json.decode(response.body)[0];
      // Save the token to local storage or global state
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) =>
              buildAlertDialog(context, "Allowance added successfully."),
        );
      }
    } else {
      // Failed login
      // throw Exception('Failed to add allowance');
      print("Bill couldn't be created. Please try again.");
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) => buildAlertDialog(
              context, "Allowance couldn't be added. Please try again."),
        );
      }
    }
    // return user;
    return response.statusCode == 200;
  }

  Widget buildAlertDialog(BuildContext context, String response) {
    return AlertDialog(
      title: const Text('Allowance info'),
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
    var choice;
    var dropdownValue;

    List<String> subsOnly = [];
    // Retrieving Sub Users
    for (dynamic innerList in widget.user[0]["mainSsubs"]) {
      subsOnly.add(innerList[0]);
    }
    print(widget.user[0]);
    return AlertDialog(
      clipBehavior: Clip.none,
      backgroundColor: Color.fromARGB(255, 171, 182, 231),
      title: const Text(
        'Allowance',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Color.fromARGB(255, 77, 105, 230),
          fontSize: 44,

          // fontWeight: FontWeight,
        ),
      ),
      content: SingleChildScrollView(
          child: Form(
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
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(
                    r'^\d{1,9}$|(?=^.{1,9}$)^\d+\.\d{0,2}$')), // only allow numbers and dot
              ],
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
      )),
      actions: <Widget>[
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, 0);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Color.fromARGB(255, 126, 120, 120),
          ),
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

              bool successful = await Allowance(form);
              // Do something with the form data, e.g. submit to server
              await Future.delayed(const Duration(seconds: 1));
              Navigator.of(context).pop(AmountAllowance);
              if (successful) {
                Navigator.of(context).pop(AmountAllowance);
              }
            }
          },
          child: const Text('Submit'),
        ),
      ],
    );
  }
}
