import 'dart:convert';
import 'package:date_field/date_field.dart';
import 'package:flutter/services.dart';
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
  late DateTime? _selectedDate;

  Future<bool> debit(debitForm form) async {
    final url = Uri.parse(
        'http://127.0.0.1:8000/add_debits'); // insert correct API endpoint
    final headers = {'Content-Type': 'application/json'};
    final body = json.encode(form.toJson());
    final response = await http.post(url, headers: headers, body: body);
    // final user=0;
    if (response.statusCode == 200) {
      // Successful debit
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) =>
              buildAlertDialog(context, "Debit added successfully."),
        );
      }
      // final user = json.decode(response.body)[0];
      // Save the token to local storage or global state
    } else {
      // Failed debit
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) => buildAlertDialog(
              context, "Debit couldn't be added. Please try again."),
        );
      }
      // throw Exception('Failed to add debit');
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
    bool isFinalDateEdittable = true;
    return AlertDialog(
      title: const Text('Debit form'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextFormField(
              controller: debit_name,
              decoration: const InputDecoration(labelText: 'Debit Name'),
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
              decoration: const InputDecoration(labelText: 'Debit amount'),
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(
                    r'^\d{1,9}$|(?=^.{1,9}$)^\d+\.\d{0,2}$')), // only allow numbers and dot
              ],
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
              decoration: const InputDecoration(
                labelText: 'Debit monthly installment',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(
                    r'^\d{1,9}$|(?=^.{1,9}$)^\d+\.\d{0,2}$')), // only allow numbers and dot
              ],
              validator: (value) {
                if (value!.isNotEmpty) {
                  double? amount = double.tryParse(debit_amount.text);
                  double? installment = double.tryParse(value);
                  if (installment! > amount!) {
                    return "Installment can't be greater than Debit Amount";
                  }
                }
                return null;
              },
              onChanged: (value) {
                // This is not working for some reason
                if (value.isNotEmpty) {
                  setState(() {
                    _selectedDate = null;
                  });
                }
              },
            ),
            DateTimeFormField(
              // controller: _dateOfBirthController,
              decoration: const InputDecoration(
                labelText: 'Final date',
                hintStyle: TextStyle(color: Color.fromARGB(115, 211, 19, 19)),
                errorStyle: TextStyle(color: Colors.redAccent),
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.event_note),
                // labelText: 'Only time',
              ),
              mode: DateTimeFieldPickerMode.date,
              autovalidateMode: AutovalidateMode.always,
              validator: (e) {
                if (e != null &&
                    e.isBefore(DateTime.now().add(Duration(days: 31)))) {
                  return 'Please choose a date at least a month ahead from now';
                }
                return null;
              },
              onDateSelected: (DateTime value) {
                if (value.isBefore(DateTime.now().add(Duration(days: 31)))) {
                  // Show an error message or take some other action
                } else {
                  setState(() {
                    _selectedDate = value;
                  });
                  debit_installment.clear();
                }
              },
            ),
          ],
        ),
      ),
      actions: <Widget>[
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              if (debit_installment.text.isEmpty) {
                DateTime now = DateTime.now();
                Duration? difference = _selectedDate?.difference(now);
                int monthsDifference = (difference!.inDays / 30)
                    .floor(); // round up the result to the nearest integer
                debit_installment.text =
                    (double.parse(debit_amount.text.trim()) / monthsDifference)
                        .toString();
              }
              final form = debitForm(
                  debit_name: debit_name.text.trim(),
                  debit_amount: debit_amount.text.trim(),
                  debit_installment: debit_installment.text.trim(),
                  debit_final_date:
                      DateFormat('dd/MM/yy hh:mm:ss').format(_selectedDate!),
                  user: widget.user);
              bool successful = await debit(form);
              // Do something with the form data, e.g. submit to server
              await Future.delayed(const Duration(seconds: 1));
              Navigator.pop(context);

              if (successful) {
                Navigator.pop(context);
              }
            }
          },
          child: Text('Submit'),
        ),
      ],
    );
  }
}
