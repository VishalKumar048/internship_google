import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'home_page.dart';
import 'signup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

const String BASE_URL = 'http://localhost:5000';

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final GoogleSignIn _googleSignIn = GoogleSignIn();

  void _login() async {
    final email = _emailController.text;
    final password = _passwordController.text;
    final response = await http.post(
      Uri.parse('$BASE_URL/login'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({"email": email, "password": password}),
    );

    final data = json.decode(response.body);
    if (response.statusCode == 200) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomePage(token: data['token'])));
    } else {
      _showError(data['message']);
    }
  }

  void _googleSignInFunc() async {
  try {
    final GoogleSignInAccount? account = await _googleSignIn.signIn();
    if (account == null) {
      _showError("Sign-in aborted by user");
      return;
    }

    final GoogleSignInAuthentication auth = await account.authentication;

    if (auth.idToken == null) {
      _showError("Failed to retrieve ID token.");
      return;
    }

    final response = await http.post(
      Uri.parse('$BASE_URL/google-signin'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({"token": auth.idToken}),
    );

    final data = json.decode(response.body);
    if (response.statusCode == 200) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(token: data['token']),
        ),
      );
    } else {
      _showError(data['message'] ?? 'Unknown error during Google Sign-In.');
    }
  } catch (e) {
    _showError("Google sign-in error: ${e.toString()}");
  }
}



  void _showError(String message) {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: const Text('Error'),
              content: Text(message),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context), child: const Text('OK')),
              ],
            ));
  }

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Image.asset(
                'assets/images/login.jpg',
                fit: BoxFit.contain,
              ),
            ),
          ),

          
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Login to Your Account",
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 32),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      backgroundColor: Colors.blueAccent,
                    ),
                    child: const Text('Login', style: TextStyle(fontSize: 18)),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _googleSignInFunc,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: Colors.grey),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.login, color: Colors.black),
                        SizedBox(width: 10),
                        Text('Sign in with Google', style: TextStyle(color: Colors.black)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const SignupPage()),
                        );
                      },
                      child: const Text(
                        "Are you new? Sign up",
                        style: TextStyle(color: Colors.blueAccent),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}