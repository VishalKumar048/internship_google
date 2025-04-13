import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'home_page.dart';
import 'login_page.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

const String BASE_URL = 'http://localhost:5000'; 

class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _signup() async {
    final email = _emailController.text;
    final password = _passwordController.text;

    try {
      final response = await http.post(
        Uri.parse('$BASE_URL/signup'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"email": email, "password": password}),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['token'] != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage(token: data['token'])),
        );
      } else if (data['message']?.toLowerCase().contains('already exists') == true) {
        _showError('User already exists. Redirecting to login...');
        Future.delayed(Duration(seconds: 2), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginPage()),
          );
        });
      } else {
        _showError(data['message'] ?? 'Signup failed');
      }
    } catch (e) {
      _showError('An error occurred. Please try again.');
    }
  }

  void _googleSignup() async {
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return; 
      final googleAuth = await googleUser.authentication;

      
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );
      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final token = await userCredential.user?.getIdToken();

      
      final response = await http.post(
        Uri.parse('$BASE_URL/google-signup'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"token": token}),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['token'] != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage(token: data['token'])),
        );
      } else if (data['message']?.toLowerCase().contains('already exists') == true) {
        _showError('Google account already registered. Redirecting to login...');
        Future.delayed(Duration(seconds: 2), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginPage()),
          );
        });
      } else {
        _showError(data['message'] ?? 'Google signup failed');
      }
    } catch (e) {
      _showError('Google sign-up error: ${e.toString()}');
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
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(24),
              color: Colors.blueGrey.shade50,
              child: Image.asset(
                'assets/images/signup.jpg', 
                fit: BoxFit.contain,
              ),
            ),
          ),

          
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Create Account",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _signup,
                      child: const Text('Sign Up'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _googleSignup,
                      icon: const Icon(Icons.login),
                      label: const Text('Sign Up with Google'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightBlue[400],
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const LoginPage()),
                          );
                        },
                        child: const Text(
                          "Already have an account? Log in",
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}