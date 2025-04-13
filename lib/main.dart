import 'package:flutter/material.dart';
import 'login_page.dart';
import 'signup_page.dart';
import 'home_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: const FirebaseOptions(apiKey
));
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key); 

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'trial0',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home:   SplashScreen(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
        '/home': (context) => HomePage(), 
      },
    );
  }
}
