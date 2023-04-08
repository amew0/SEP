import 'dart:convert';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:http/http.dart' as http;
// import 'package:sms/sms.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:date_field/date_field.dart';
import 'package:modernlogintute/pages/Homepage.dart';
import 'package:modernlogintute/pages/login_page.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:shared_preferences/shared_preferences.dart';

class registerForm {
  String username;
  String phonenumber;
  String dateofbirth;
  String? privilege;
  registerForm(
      {required this.username,
      required this.phonenumber,
      required this.dateofbirth,
      required this.privilege});

  Map<String, dynamic> toJson() => {
        'username': username,
        'phonenumber': phonenumber,
        'dateofbirth': dateofbirth,
        'privilege': privilege
      };
}

class RegistrationPage extends StatefulWidget {
  @override
  final String message;
  RegistrationPage({required this.message});
  _RegistrationPageState createState() => _RegistrationPageState();
}

DateTimeField(
    {required format,
    required InputDecoration decoration,
    required Future<DateTime> Function(dynamic context, dynamic currentValue)
        onShowPicker}) {}

class _RegistrationPageState extends State<RegistrationPage> {
  // final String message;

  // _RegistrationPage({required this.message});
  final _usernameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _dateOfBirthController = TextEditingController();
  late DateTime _selectedDate;
  String? selectedOption = "Main";

  // Future<void> storeToken(String token) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.setString('auth_token', token);
  // }

  // Future<String?> getToken() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   return prefs.getString('auth_token');
  // }

  // void sendSMS(String message, String recipient) {
  //   SmsSender sender = new SmsSender();
  //   sender.sendSms(new SmsMessage(
  //     recipient,
  //     message,
  //   ));
  // }

  Future<dynamic> register(registerForm form) async {
    final url = Uri.parse(
        'http://127.0.0.1:8000/register'); // insert correct API endpoint
    final headers = {'Content-Type': 'application/json'};
    print(form);
    final body = json.encode(form.toJson());
    print(body);
    final response = await http.post(url, headers: headers, body: body);
    dynamic user;
    // final user=0;
    if (response.statusCode == 200) {
      // Successful login
      print("successfully registered");
      user = json.decode(response.body)[0];
      if (widget.message != "family") {
        // storeToken(user[1]);
      }

      // Save the token to local storage or global state
    } else {
      // Failed login

      throw Exception('Failed to register');
    }
    print(user);
    return user;
  }

  @override
  Widget build(BuildContext context) {
    bool hide = true;
    if (widget.message == "family") {
      hide = false;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Registration Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Visibility(
              visible: !hide,
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(
                  'Add a Family member',
                  style: TextStyle(color: Colors.grey[700], fontSize: 35),
                ),
              ]),
            ),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'Privilege: ',
                  style: TextStyle(color: Colors.grey[700]),
                ),
                DropdownButton(
                  value: selectedOption,
                  items: [
                    DropdownMenuItem(
                      value: "Main",
                      child: Text('Main'),
                    ),
                    DropdownMenuItem(
                      value: "Sub",
                      child: Text('Sub'),
                    ),
                  ],
                  onChanged: (value) {
                    if (widget.message == "family") {
                      setState(() {
                        selectedOption = value;
                      });
                    }
                    // setState(() {
                    //   selectedOption = value;
                    // });
                  },
                ),
              ],
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                // Do something with the user's registration information
                // String username = _usernameController.text;
                // String phoneNumber = _phoneNumberController.text;
                // String message = "This is a test message!";
                // print(message);
                // // print("yoooo11");
                // List<String> recipents = [_phoneNumberController.text.trim()];

                // if (await Permission.sms.request().isGranted) {
                //   String _result = await sendSMS(
                //           message: message,
                //           recipients: recipents,
                //           sendDirect: true)
                //       .catchError((onError) {
                //     print(onError);
                //   });
                //   print(_result);
                // } else
                //   print("no permission");
                final form = registerForm(
                    username: _usernameController.text.trim(),
                    phonenumber: _phoneNumberController.text.trim(),
                    dateofbirth: DateFormat('yyyy-MM-dd').format(_selectedDate),
                    privilege: selectedOption);
                dynamic user = await register(form);
                if (widget.message == "login") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Homepage(
                              user: user,
                            )),
                  );
                } else {
                  Navigator.pop(context);
                }
              },
              child: Text('Register'),
            ),
            Visibility(
                visible: hide,
                child: Row(
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
                        style:
                            TextStyle(color: Color.fromARGB(255, 211, 191, 11)),
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
                ))
          ],
        ),
      ),
    );
  }
}
