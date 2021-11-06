import 'package:cabs/widgets/location_tracker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class LocationGetter extends StatefulWidget {
  const LocationGetter({Key? key}) : super(key: key);

  @override
  _LocationGetterState createState() => _LocationGetterState();
}

class _LocationGetterState extends State<LocationGetter> {
  final Location location = Location();
  final CollectionReference users =
      FirebaseFirestore.instance.collection('users');
  final String email = FirebaseAuth.instance.currentUser!.email!;
  List<Future<dynamic>> futures = [];

  @override
  void initState() {
    futures.add(location.getLocation());
    futures.add(users.doc(email).get());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.wait(futures),
      builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshots) {
        if (snapshots.connectionState == ConnectionState.done) {
          LocationData currentLocation = snapshots.data![0];
          String designation = ((snapshots.data![1] as DocumentSnapshot).data()
              as Map<String, dynamic>)["designation"];
          List<dynamic> targetEmails = ((snapshots.data![1] as DocumentSnapshot)
              .data() as Map<String, dynamic>)["targets"] as List<dynamic>;
          List<dynamic> targetLocations = [];
          debugPrint(targetEmails.toString());
          // return LocationTracker(location.onLocationChanged, currentLocation,
          //     designation, targetEmails);
          // return LocationTrackingScreen(snapshots.data![0], location);
          return FutureBuilder(
            future: users.doc(targetEmails[0]).get(),
            builder: (BuildContext context,
                AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                Map<String, dynamic> userData =
                    snapshot.data!.data() as Map<String, dynamic>;
                LatLng firstTarget = LatLng(userData["lat"], userData["long"]);
                return LocationTracker(location.onLocationChanged,
                    currentLocation, designation, targetEmails, firstTarget);
              }
              return const Center(
                child: CircularProgressIndicator(),
              );
            },
          );
        }
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}
