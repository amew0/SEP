import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:date_field/date_field.dart';
import 'package:modernlogintute/pages/login_page.dart';

class registerForm {
  String username;
  String phonenumber;
  DateTime dateofbirth;
  registerForm(
      {required this.username,
      required this.phonenumber,
      required this.dateofbirth});

  Map<String, dynamic> toJson() => {
        'username': username,
        'phonenumber': phonenumber,
        'dateofbirth': dateofbirth,
      };
}

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

DateTimeField(
    {required format,
    required InputDecoration decoration,
    required Future<DateTime> Function(dynamic context, dynamic currentValue)
        onShowPicker}) {}

class _RegistrationPageState extends State<RegistrationPage> {
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _phoneNumberController = TextEditingController();
  TextEditingController _dateOfBirthController = TextEditingController();
  late DateTime _selectedDate;

  Future<void> register(registerForm form) async {
    final url = Uri.parse(
        'http://127.0.0.1:8000/register_flutter'); // insert correct API endpoint
    final headers = {'Content-Type': 'application/json'};
    final body = json.encode(form.toJson());
    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      // Successful login
      print("successfully sent Login POST");
      final token = json.decode(response.body)['token'];
      // Save the token to local storage or global state
    } else {
      // Failed login
      throw Exception('Failed to login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registration Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            TextFormField(
              controller: _phoneNumberController,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 16.0),
            DateTimeFormField(
              // controller: _dateOfBirthController,
              decoration: const InputDecoration(
                labelText: 'Date of Birth',
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
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // Do something with the user's registration information
                // String username = _usernameController.text;
                // String phoneNumber = _phoneNumberController.text;
                final form = registerForm(
                    username: _usernameController.text.trim(),
                    phonenumber: _phoneNumberController.text.trim(),
                    dateofbirth: _selectedDate);
                register(form);
              },
              child: Text('Register'),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Already a member?',
                  style: TextStyle(color: Colors.grey[700]),
                ),
                const SizedBox(width: 4),
                // FloatingActionButton(
                //   onPressed: onPressed,
                //   tooltip: 'register',
                // ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  },
                  child: Text(
                    'Login',
                    style: TextStyle(color: Color.fromARGB(255, 211, 191, 11)),
                  ),
                )
                // const Text(
                //   'Register now',
                //   style: TextStyle(
                //     color: Colors.blue,
                //     fontWeight: FontWeight.bold,
                //   ),
                // ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
