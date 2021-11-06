import 'dart:async';

import 'package:cabs/screens/location_getter.dart';
import 'package:cabs/screens/login_screen.dart';
import 'package:cabs/widgets/payment.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = "/home";
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Location _location = Location();
  late LocationData currentLocation;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String email = FirebaseAuth.instance.currentUser!.email!;
  final CollectionReference _users =
      FirebaseFirestore.instance.collection('users');
  int currentPage = 0;
  Timer? timer;
  late String designation;

  final List<LatLng> targetLocations = [];

  void signOut() async {
    await _auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    // signOut();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text([
          'Tracking',
          'Payment',
        ][currentPage]),
        actions: [
          IconButton(
            onPressed: () async {
              await _auth.signOut();
              dispose();
              Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
            },
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: [
        const LocationGetter(),
        const Payment(),
      ][currentPage],
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          setState(() {
            currentPage = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.pin_drop),
            label: 'Tracking',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.money),
            label: 'Payment',
          ),
        ],
      ),
    );
  }
}
