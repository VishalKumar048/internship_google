import 'package:flutter/material.dart';
import 'dart:async';
import 'login_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Optional: customize background
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/app.png', // <-- your logo path
              height: 120,
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(
              color: Colors.white70,
            ),
            const SizedBox(height: 10),
            const Text(
              "Loading...",
              style: TextStyle(color: Colors.white54),
            ),
          ],
        ),
      ),
    );
  }
}
