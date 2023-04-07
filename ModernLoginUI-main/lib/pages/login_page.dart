// import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
// import 'package:flutter_nfc/flutter_nfc.dart';
import 'package:http/http.dart' as http;
import 'package:modernlogintute/components/my_textfield.dart';
import 'package:modernlogintute/pages/Homepage.dart';
import 'package:modernlogintute/pages/Registrationpage.dart';
import 'package:nfc_manager/nfc_manager.dart';

class LoginForm {
  String username;
  String password;

  LoginForm({required this.username, required this.password});

  Map<String, dynamic> toJson() => {
        'username': username,
        'password': password,
      };
}

class LoginPage extends StatelessWidget {
  LoginPage({super.key});
  LoginPage.ensureInitialized();
  // text editing controllers
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  // Future<void> storeToken(String token) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.setString('auth_token', token);
  // }

  // Future<String?> getToken() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   return prefs.getString('auth_token');
  // }

  Future<dynamic> login(LoginForm form) async {
    // https://fbsbanking.herokuapp.com/
    final url = Uri.parse(
        'http://127.0.0.1:8000/login_flutter'); // insert correct API endpoint
    final headers = {'Content-Type': 'application/json'};
    final body = json.encode(form.toJson());
    final response = await http.post(url, headers: headers, body: body);
    dynamic user;
    if (response.statusCode == 200) {
      // Successful login
      print("successfully logged in");
      // print(json.decode(response.body)[0]);
      user = json.decode(response.body)[0];
      // print(user.runtimeType);
      // await storeToken(user[1]);
      // print(json.decode(response.body)['token']);
      // print(user.username);
      // Save the token to local storage or global state
    } else {
      // Failed login
      throw Exception('Failed to login');
    }
    print(user);
    return user;
  }

  // Future<void> signUp() async {
  //   // Make the GET request
  //   final response = await http.get(
  //     Uri.parse(endpointUrl),
  //     headers: headers,
  //   );

  //   // Check the response status code
  //   if (response.statusCode == 200) {
  //     // The request was successful, parse the response body
  //     final List<dynamic> users = jsonDecode(response.body);
  //     print('Users: $users');
  //   } else {
  //     // The request failed, handle the error
  //     print('Request failed with status: ${response.statusCode}.');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 50),

              // logo
              const Icon(
                Icons.account_balance,
                size: 100,
              ),

              const SizedBox(height: 50),

              // welcome!
              Text(
                'Welcome!',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 16,
                ),
              ),

              const SizedBox(
                height: 25,
              ),

              // username textfield
              MyTextField(
                controller: usernameController,
                hintText: 'Username',
                obscureText: false,
              ),

              const SizedBox(height: 10),

              // password textfield
              MyTextField(
                controller: passwordController,
                hintText: 'Password',
                obscureText: true,
              ),

              const SizedBox(height: 10),

              // forgot password?
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Forgot Password?',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // sign in button
              // MyButton(onTap: login()),
              ElevatedButton(
                onPressed: () async {
                  final form = LoginForm(
                      username: usernameController.text.trim(),
                      password: passwordController.text.trim());
                  dynamic user = await login(form);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Homepage(user: user)),
                  );
                },
                child: Text('Login'),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                      Color.fromARGB(255, 7, 7, 7)),
                ),
              ),

              TextButton(
                onPressed: () async {
                  // Check availability
                  bool isAvailable =
                      await NfcManager.instance.isAvailable() ?? false;
                  print("in");
                  print(isAvailable);
                  // Start Session
                  NfcManager.instance.startSession(
                    // print("hey")
                    onDiscovered: (NfcTag? tag) async {
                      await nfc_handle();
                      print("nfc found");
                      if (tag != null) {
                        print("not null");
                      } else
                        print("found");
                      // Do something with an NfcTag instance.
                    },
                  );
                  // Stop Session
                  NfcManager.instance.stopSession();
                  print("out");
                },
                child: Text("NFC"),
              ),

              const SizedBox(height: 25),

              // ElevatedButton(
              //   onPressed: () {
              //     // NFC 监听
              //     FlutterNfc.onTagDiscovered().listen((value) {
              //       print("id: ${value.id}");
              //       print("content: ${value.content}");
              //     });
              //   },
              //   child: Text("NFC"),
              //   style: ButtonStyle(
              //     backgroundColor: MaterialStateProperty.all<Color>(
              //         Color.fromARGB(255, 7, 7, 7)),
              //   ),
              // ),

              const SizedBox(height: 25),
              // not a member? register now
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Not a member?',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  const SizedBox(width: 4),
                  // FloatingActionButton(
                  //   onPressed: onPressed,
                  //   tooltip: 'register',
                  // ),
                  TextButton(
                    onPressed: () {
                      String message = "login";
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                RegistrationPage(message: message)),
                      );
                    },
                    child: Text(
                      'Register',
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
              )
            ],
          ),
        ),
      ),
    );
  }
}

nfc_handle() {
  print("nfc_handle function called");
}
