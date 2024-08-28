import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:route_tracking/models/routes_api_response_model/routes_api_response_model.dart';
import 'package:route_tracking/models/routes_details_body.dart';
import 'package:route_tracking/utils/google_maps_service.dart';
import 'package:route_tracking/widgets/custom_text_field_autocomplete.dart';
import 'package:uuid/uuid.dart';

import '../utils/location_service.dart';

class GoogleMapView extends StatefulWidget {
  const GoogleMapView({super.key});

  @override
  State<GoogleMapView> createState() => _GoogleMapViewState();
}

class _GoogleMapViewState extends State<GoogleMapView> {
  final Set<Polyline> _polyLines = {};
  final Set<Marker> _markers = {};
  late GoogleMapController _googleMapController;
  late CameraPosition _initialCameraPosition;
  late LocationService _locationService;
  late GoogleMapsService _googleMapsService;
  // we handle wether to animate the camera to the new position or not using this variable
  // as we don't want to animate the camera to the current user position when we are showing a  route to the user
  bool canTrack = true;
  late Uuid _uuid;
  LatLng? _userLocation;

  @override
  void initState() {
    super.initState();

    _initialCameraPosition =
        const CameraPosition(target: LatLng(29.0, 31.0), zoom: 3);
    _locationService = LocationService();
    _googleMapsService = GoogleMapsService();
    _uuid = const Uuid();
  }

  @override
  void dispose() {
    _googleMapController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          GoogleMap(
            initialCameraPosition: _initialCameraPosition,
            zoomControlsEnabled: false,
            markers: _markers,
            polylines: _polyLines,
            onMapCreated: (controller) {
              _googleMapController = controller;

              _initUserLocation();
            },
          ),
          Padding(
            padding: const EdgeInsets.only(top: 70, right: 20, left: 20),
            child: CustomTextFieldAutocomplete(
              onPredictionTaped: onPredictionTap,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () {
          canTrack = true;
          _animateNewCameraPosition(_userLocation!);
        },
        child: const Icon(
          Icons.my_location,
          color: Colors.white,
        ),
      ),
    );
  }

// asks for the the location service and permission and track the live location
  //if the user if permission is granted
  Future<void> _initUserLocation() async {
    try {
      await _locationService.fetchLocationDataStream((locationData) {
        final latLng = LatLng(locationData.latitude!, locationData.longitude!);
        if (canTrack) {
          print(
              "Location data: $locationData ===============================================");
          _setLocationMarker(
            latLng: latLng,
            markerId: '',
            icon: BitmapDescriptor.defaultMarker,
          );
          _animateNewCameraPosition(latLng);

          setState(() {});
        }
        _userLocation = latLng;
      });
    } on LocationServiceException catch (e) {
      print(e);
    } on LocationPermissionException catch (e) {
      print(e);
    } on Exception catch (e) {
      print(e);
    }
  }

  void _setLocationMarker({
    required LatLng latLng,
    required String markerId,
    required BitmapDescriptor icon,
  }) {
    final marker = Marker(
      icon: icon,
      markerId: MarkerId(
        markerId,
      ),
      position: latLng,
    );
    _markers.add(marker);
  }

// animate a newCameraPosition with a zoom of 15,
  void _animateNewCameraPosition(LatLng latLng, [double zoom = 15]) {
    final cameraPosition = CameraPosition(
      target: latLng,
      zoom: zoom,
    );
    _googleMapController.animateCamera(
      CameraUpdate.newCameraPosition(cameraPosition),
    );
  }

// fetch the route details through the routes api using the current latLng
//and chosen location by the user and display a route using this info
  Future<void> onPredictionTap(LatLng latLng) async {
    RoutesDetailsBody routeDetailsBody =
        _googleMapsService.constructRouteDetailsBody(
            destination: latLng, currentLocation: _userLocation!);
    final routeDetails =
        await _googleMapsService.fetchRouteDetails(routeDetailsBody);

    if (routeDetails != null) {
      print('got route details==================================');
      _setRoute(routeDetails);

      _setLocationMarker(
        latLng: latLng,
        markerId: 'markerId',
        icon: BitmapDescriptor.defaultMarker,
      );

      canTrack = false;
    }
    setState(() {});
  }

// take the response and decode the the encodedPolyLine and add the route to the [_polyLines] set
  void _setRoute(RoutesApiResponseModel routeDetails) {
    final List<LatLng> points = _googleMapsService
        .decodeRouteData(routeDetails.routes!.first.polyline!.encodedPolyline!);

    final id = _uuid.v4();
    _polyLines.clear();
    _polyLines.add(
      Polyline(
        color: Colors.blue,
        startCap: Cap.roundCap,
        width: 8,
        polylineId: PolylineId(id),
        points: points,
      ),
    );

    final LatLngBounds bounds = _googleMapsService.cameraBounds(points);
    _googleMapController.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 50),
    );
  }
}
