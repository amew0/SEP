// import 'dart:convert';
// import 'dart:html';

import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
// import 'dart:js';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:modernlogintute/components/my_button.dart';
import 'package:modernlogintute/components/my_textfield.dart';
import 'package:modernlogintute/components/square_tile.dart';
import 'package:modernlogintute/pages/Homepage.dart';
import 'package:modernlogintute/pages/Registrationpage.dart';

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
  final String endpointUrl = 'http://127.0.0.1:8000/ccds';
  final Map<String, String> headers = {
    'Content-Type': 'application/json',
    // 'Authorization': 'Bearer your_access_token_here',
  };
  Client client = http.Client() as Client;
  // text editing controllers
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  // sign user in method
  void signIn() {
    //  var url = "http://127.0.0.1:8000/register/";
    //  List response = json.decode((await client.get(url)).body);
  }
  Future<void> login(LoginForm form) async {
    final url = Uri.parse(
        'http://127.0.0.1:8000/login_flutter'); // insert correct API endpoint
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

  Future<void> signUp() async {
    // Make the GET request
    final response = await http.get(
      Uri.parse(endpointUrl),
      headers: headers,
    );

    // Check the response status code
    if (response.statusCode == 200) {
      // The request was successful, parse the response body
      final List<dynamic> users = jsonDecode(response.body);
      print('Users: $users');
    } else {
      // The request failed, handle the error
      print('Request failed with status: ${response.statusCode}.');
    }
  }

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
                padding: const EdgeInsets.symmetric(horizontal: 400.0),
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
                onPressed: () {
                  final form = LoginForm(
                      username: usernameController.text.trim(),
                      password: passwordController.text.trim());
                  login(form);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Homepage()),
                  );
                },
                child: Text('Login'),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                      Color.fromARGB(255, 7, 7, 7)),
                ),
              ),

              const SizedBox(height: 50),

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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => RegistrationPage()),
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
