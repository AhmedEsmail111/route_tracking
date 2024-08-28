import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:route_tracking/models/place_details_response_model/place_details_response_model.dart';
import 'package:route_tracking/models/routes_details_body.dart';
import 'package:route_tracking/utils/api_keys_endpoints.dart';

import '../models/autocomplete_predictions_model/autocomplete_predictions_model.dart';
import '../models/routes_api_response_model/routes_api_response_model.dart';

class GoogleMapsService {
  final _dio = Dio();
  Future<AutocompletePredictionsModel?> fetchAutocompletePredictions(
      {required String input, required String sessionToken}) async {
    try {
      final response = await _dio.get(
          '$placesAutocompleteUrl?input=$input&sessiontoken=$sessionToken&key=$placesApiKey');

      final autocompletePredictionsModel =
          AutocompletePredictionsModel.fromJson(response.data);

      if (autocompletePredictionsModel.status == 'OK') {
        return autocompletePredictionsModel;
      } else {
        return null;
      }
    } on Exception catch (e) {
      print(
          'error occurred ===================== and the error is ====================== $e');
      return null;
    }
  }

  Future<PlaceDetailsResponseModel?> fetchPlaceDetails(String placeId) async {
    try {
      final response = await _dio
          .get('$placeDetailsUrl?place_id=$placeId&key=$placesApiKey');

      final placeDetailsResponseModel =
          PlaceDetailsResponseModel.fromJson(response.data);

      if (placeDetailsResponseModel.status == 'OK') {
        return placeDetailsResponseModel;
      } else {
        return null;
      }
    } on Exception catch (e) {
      print(
          'error occurred ===================== and the error is ====================== $e');
      return null;
    }
  }

  Future<RoutesApiResponseModel?> fetchRouteDetails(
      RoutesDetailsBody routesDetailsBody) async {
    final header = {
      'Content-Type': 'application/json',
      'X-Goog-Api-Key': routesApiKey,
      'X-Goog-FieldMask':
          'routes.duration,routes.distanceMeters,routes.polyline.encodedPolyline',
    };
    try {
      final response = await _dio.post(
        fetchRoutesUrl,
        data: routesDetailsBody.toJson(),
        options: Options(
          headers: header,
        ),
      );

      if (response.statusCode == 200) {
        return RoutesApiResponseModel.fromJson(response.data);
      }
      return null;
    } on Exception catch (e) {
      print(e);
      return null;
    }
  }

  List<LatLng> decodeRouteData(String encodedPolyLine) {
    List<PointLatLng> points = PolylinePoints().decodePolyline(encodedPolyLine);

    List<LatLng> polyLine = [];
    for (final point in points) {
      polyLine.add(
        LatLng(point.latitude, point.longitude),
      );
    }

    return polyLine;
  }

  // return the LarLngBounds for the given route
//(the least LatLng is the southwest and the biggest is the northeast bound)
  LatLngBounds cameraBounds(List<LatLng> points) {
    var southwestLatitude = points.first.latitude;
    var southwestLongitude = points.first.longitude;
    var northeastLatitude = points.first.latitude;
    var northeastLongitude = points.first.longitude;

    for (final point in points) {
      southwestLatitude = min(southwestLatitude, point.latitude);
      southwestLongitude = min(southwestLongitude, point.longitude);
      northeastLatitude = max(northeastLatitude, point.latitude);
      northeastLongitude = max(northeastLongitude, point.longitude);
    }

    final bounds = LatLngBounds(
      southwest: LatLng(southwestLatitude, southwestLongitude),
      northeast: LatLng(
        northeastLatitude,
        northeastLongitude,
      ),
    );

    return bounds;
  }

  RoutesDetailsBody constructRouteDetailsBody(
      {required LatLng destination, required LatLng currentLocation}) {
    final userLocation = LatLngData(
      latitude: currentLocation.latitude,
      longitude: currentLocation.longitude,
    );
    final destinationLatLng = LatLngData(
      latitude: destination.latitude,
      longitude: destination.longitude,
    );
    final routeDetailsBody = RoutesDetailsBody(
      origin: Destination(
        location: Location(latLng: userLocation),
      ),
      destination: Destination(
        location: Location(latLng: destinationLatLng),
      ),
      travelMode: 'DRIVE',
      routingPreference: 'TRAFFIC_AWARE',
      computeAlternativeRoutes: false,
      routeModifiers: RouteModifiers(
        avoidTolls: false,
        avoidHighways: false,
        avoidFerries: false,
      ),
      languageCode: 'en-US',
      units: 'IMPERIAL',
    );
    return routeDetailsBody;
  }
}
