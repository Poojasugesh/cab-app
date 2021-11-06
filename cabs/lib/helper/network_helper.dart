import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';

class NetworkHelper {
  final String url = "https://api.openrouteservice.org/v2/directions/";
  final String apiKey =
      "5b3ce3597851110001cf62488c8b5ca3a3f4442fb50e0c0bef9172be";
  final String pathParameter = "driving-car";

  final double startLat;
  final double startLong;
  final double endLat;
  final double endLong;

  NetworkHelper({
    required this.startLat,
    required this.startLong,
    required this.endLat,
    required this.endLong,
  });

  Future getData() async {
    Response response = await get(Uri.parse(
        '$url$pathParameter?api_key=$apiKey&start=$startLong,$startLat&end=$endLong,$endLat'));
    if (response.statusCode == 200) {
      String data = response.body;
      return jsonDecode(data);
    } else {
      debugPrint(response.statusCode.toString());
    }
  }
}
