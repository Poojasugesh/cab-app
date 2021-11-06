import 'dart:async';

import 'package:cabs/screens/forgot_password_screen.dart';
import 'package:cabs/screens/home_screen.dart';
import 'package:cabs/screens/login_screen.dart';
import 'package:cabs/screens/signup_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Main page",
      home: const MainPage(),
      routes: {
        LoginScreen.routeName: (ctx) => const LoginScreen(),
        SignupPage.routeName: (ctx) => const SignupPage(),
        HomeScreen.routeName: (ctx) => const HomeScreen(),
        ForgotPasswordScreen.routeName: (ctx) => const ForgotPasswordScreen(),
      },
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return const LoginScreen();
        }
        return Container(
          color: Colors.white,
          child: Image.asset("assets/images/ssn-logo.jpg"),
        );
      },
    );
  }
}
