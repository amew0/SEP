import 'dart:convert';
import 'package:modernlogintute/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Homepage extends StatefulWidget {
  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  void signIn() {
    //  var url = "http://127.0.0.1:8000/register/";
    //  List response = json.decode((await client.get(url)).body);
  }

  Future<void> logout() async {
    final url = Uri.parse(
        'http://127.0.0.1:8000/logout'); // insert correct API endpoint
    final headers = {'Content-Type': 'application/json'};
    // final body = json.encode(form.toJson());
    final response = await http.post(url, headers: headers);

    if (response.statusCode == 200) {
      // Successful logout
      print("successfully sent Logout POST");
      // final token = json.decode(response.body)['token'];
      // Save the token to local storage or global state
    } else {
      // Failed login
      throw Exception('Failed to logout');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Homepage'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        logout;
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage()),
                        );
                      },
                      child: Text(
                        'logout',
                        style:
                            TextStyle(color: Color.fromARGB(255, 211, 191, 11)),
                      ),
                    ),

                    TextButton(
                      onPressed: signIn,
                      child: Text(
                        'family',
                        style:
                            TextStyle(color: Color.fromARGB(255, 211, 191, 11)),
                      ),
                    ),

                    TextButton(
                      onPressed: signIn,
                      child: Text(
                        'pay_bills',
                        style:
                            TextStyle(color: Color.fromARGB(255, 211, 191, 11)),
                      ),
                    ),

                    TextButton(
                      onPressed: signIn,
                      child: Text(
                        'add_debits',
                        style:
                            TextStyle(color: Color.fromARGB(255, 211, 191, 11)),
                      ),
                    )

                    // SizedBox(height: 16.0),
                  ],
                ),
              ),
            ),
    );
  }
}
