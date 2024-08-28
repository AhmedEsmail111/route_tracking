import 'package:flutter/material.dart';

import 'views/google_map_view.dart';

void main() {
  runApp(const RouteTrackingApp());
}

class RouteTrackingApp extends StatelessWidget {
  const RouteTrackingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: GoogleMapView(),
    );
  }
}
