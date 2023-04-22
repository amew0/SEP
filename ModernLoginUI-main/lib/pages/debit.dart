import 'dart:convert';
import 'package:date_field/date_field.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class debitForm {
  String debit_name;
  String debit_amount;
  String debit_installment;
  String debit_final_date;
  dynamic user;
  debitForm({
    required this.debit_name,
    required this.user,
    required this.debit_amount,
    required this.debit_installment,
    required this.debit_final_date,
  });

  Map<String, dynamic> toJson() => {
        'debit_name': debit_name,
        'debit_amount': debit_amount,
        'debit_installment': debit_installment,
        'debit_final_date': debit_final_date,
        'user': user,
      };
}

class MydebitPopup extends StatefulWidget {
  @override
  dynamic user;
  MydebitPopup({required this.user});
  _MydebitPopupState createState() => _MydebitPopupState();
}

class _MydebitPopupState extends State<MydebitPopup> {
  final _formKey = GlobalKey<FormState>();
  // String? debit_name = '';
  // String? debit_amount = '';
  TextEditingController debit_installment = TextEditingController();
  TextEditingController debit_name = TextEditingController();
  TextEditingController debit_amount = TextEditingController();
  late DateTime _selectedDate;

  Future<void> debit(debitForm form) async {
    final url = Uri.parse(
        'http://127.0.0.1:8000/add_debits'); // insert correct API endpoint
    final headers = {'Content-Type': 'application/json'};
    final body = json.encode(form.toJson());
    final response = await http.post(url, headers: headers, body: body);
    // final user=0;
    if (response.statusCode == 200) {
      // Successful debit
      print("successfully added debit");
      // final user = json.decode(response.body)[0];
      // Save the token to local storage or global state
    } else {
      // Failed debit
      throw Exception('Failed to add debit');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('debit form'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextFormField(
              controller: debit_name,
              decoration: InputDecoration(labelText: 'debit Name'),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter debit name';
                }
                return null;
              },
              // onSaved: (value) {
              //   debit_name = value;
              // },
            ),
            TextFormField(
              controller: debit_amount,
              decoration: InputDecoration(labelText: 'debit amount'),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter debit amount';
                }
                return null;
              },
              // onSaved: (value) {
              //   debit_amount = value;
              // },
            ),
            TextFormField(
              controller: debit_installment,
              decoration: InputDecoration(
                labelText: 'debit monthly installment',
              ),
            ),
            DateTimeFormField(
              // controller: _dateOfBirthController,
              decoration: const InputDecoration(
                labelText: 'final date',
                hintStyle: TextStyle(color: Color.fromARGB(115, 211, 19, 19)),
                errorStyle: TextStyle(color: Colors.redAccent),
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.event_note),
                // labelText: 'Only time',
              ),
              mode: DateTimeFieldPickerMode.date,
              autovalidateMode: AutovalidateMode.always,
              validator: (e) =>
                  (e?.day ?? 0) == 1 ? 'Please not the first day' : null,
              onDateSelected: (DateTime value) {
                _selectedDate = value;
              },
            ),
            // Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            //   Checkbox(
            //     value: _isChecked,
            //     onChanged: (bool? value) {
            //       setState(() {
            //         _isChecked = value ?? false;
            //       });
            //     },
            //   ),
            //   Text(
            //     'make this payment monthly recurring',
            //     style: TextStyle(color: Colors.grey[700], fontSize: 10),
            //   ),
            // ]),
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
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              final form = debitForm(
                  debit_name: debit_name.text.trim(),
                  debit_amount: debit_amount.text.trim(),
                  debit_installment: debit_installment.text.trim(),
                  debit_final_date:
                      DateFormat('dd/MM/yy hh:mm:ss').format(_selectedDate),
                  user: widget.user);
              await debit(form);
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
