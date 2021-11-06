import 'dart:async';

import 'package:cabs/helper/network_helper.dart';
import 'package:cabs/helper/response_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class LocationTracker extends StatefulWidget {
  final LocationData currentLocation;
  final Stream<LocationData> locationStream;
  final List<dynamic> targetEmails;
  final LatLng firstTarget;
  final String designation;
  const LocationTracker(this.locationStream, this.currentLocation,
      this.designation, this.targetEmails, this.firstTarget,
      {Key? key})
      : super(key: key);

  @override
  _LocationTrackerState createState() => _LocationTrackerState();
}

class _LocationTrackerState extends State<LocationTracker> {
  GoogleMapController? mapController;

  late BitmapDescriptor manPin;
  late BitmapDescriptor vanPin;

  final List<LatLng> polyPoints = [];
  final Set<Polyline> polyLines = {};
  final Set<Marker> markers = {};

  final List<LatLng> targetLocations = [];
  final CollectionReference users =
      FirebaseFirestore.instance.collection('users');
  Timer? timer;
  late LocationData currentLocation;

  @override
  void initState() {
    currentLocation = widget.currentLocation;
    generatePolylines(currentLocation, widget.firstTarget);
    timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      updateTargetLocations();
    });
    widget.locationStream.listen((newLocation) {
      if (mounted) {
        setState(() {
          currentLocation = newLocation;
        });
      }
      updateCurrentLocation();
    });
    super.initState();
  }

  void updateCurrentLocation() async {
    await users.doc(FirebaseAuth.instance.currentUser!.email!).update({
      "lat": currentLocation.latitude,
      "long": currentLocation.longitude,
    });
  }

  void updateTargetLocations() async {
    if (targetLocations.isEmpty) {
      for (int index = 0; index < widget.targetEmails.length; index++) {
        Map<String, dynamic> target =
            (await users.doc(widget.targetEmails[index]).get()).data()
                as Map<String, dynamic>;
        targetLocations.add(LatLng(target["lat"], target["long"]));
      }
    } else {
      for (int index = 0; index < widget.targetEmails.length; index++) {
        Map<String, dynamic> target =
            (await users.doc(widget.targetEmails[index]).get()).data()
                as Map<String, dynamic>;
        targetLocations[index] = LatLng(target["lat"], target["long"]);
      }
    }
    debugPrint(targetLocations.toString());
    setMarkers();
  }

  void onMapCreated(GoogleMapController controller) async {
    mapController = controller;
    setPins();
  }

  void setPins() async {
    manPin = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(devicePixelRatio: 0.5),
      'assets/images/man.png',
    );
    vanPin = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(devicePixelRatio: 0.25),
      'assets/images/van.png',
    );
  }

  void setMarkers() {
    markers.clear();
    markers.add(
      Marker(
        markerId:
            MarkerId(widget.designation == 'Faculty' ? 'Faculty' : 'Driver'),
        position: LatLng(currentLocation.latitude!, currentLocation.longitude!),
        icon: widget.designation == 'Faculty' ? manPin : vanPin,
      ),
    );
    for (var i = 0; i < targetLocations.length; i++) {
      var targetLocation = targetLocations[i];
      markers.add(
        Marker(
          markerId: MarkerId(widget.designation == 'Driver'
              ? 'Faculty' + (i + 1).toString()
              : 'Driver' + (i + 1).toString()),
          position: LatLng(targetLocation.latitude, targetLocation.longitude),
          icon: widget.designation == 'Faculty' ? vanPin : manPin,
          onTap: () => generatePolylines(currentLocation, targetLocation),
        ),
      );
    }
    if (mounted) {
      setState(() {});
    }
  }

  void generatePolylines(
      LocationData currentLocation, LatLng targetLocation) async {
    polyLines.clear();
    polyPoints.clear();
    NetworkHelper helper = NetworkHelper(
      startLat: currentLocation.latitude!,
      startLong: currentLocation.longitude!,
      endLat: targetLocation.latitude,
      endLong: targetLocation.longitude,
    );

    try {
      final data = await helper.getData();
      LineString ls =
          LineString(data['features'][0]['geometry']['coordinates']);
      for (int i = 0; i < ls.lineString.length; i++) {
        polyPoints.add(LatLng(ls.lineString[i][1], ls.lineString[i][0]));
      }
      setPolyLines();
    } catch (e) {
      debugPrint("There was an error: " + e.toString());
    }
    debugPrint('Polylines set');
  }

  setPolyLines() {
    Polyline py = Polyline(
      polylineId: const PolylineId('route'),
      color: Colors.blue,
      points: polyPoints,
      width: 2,
    );
    if (mounted) {
      setState(() {
        polyLines.clear();
        polyLines.add(py);
      });
    }
    debugPrint("Polylines set");
  }

  @override
  void dispose() {
    timer!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      onMapCreated: onMapCreated,
      initialCameraPosition: CameraPosition(
        zoom: 15,
        target: LatLng(
          targetLocations.isNotEmpty
              ? targetLocations[0].latitude
              : currentLocation.latitude!,
          targetLocations.isNotEmpty
              ? targetLocations[0].longitude
              : currentLocation.longitude!,
        ),
      ),
      markers: markers,
      polylines: polyLines,
    );
  }
}
