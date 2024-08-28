class RoutesDetailsBody {
  final Destination origin;
  final Destination destination;
  final String travelMode;
  final String routingPreference;
  final bool computeAlternativeRoutes;
  final RouteModifiers routeModifiers;
  final String languageCode;
  final String units;

  RoutesDetailsBody({
    required this.origin,
    required this.destination,
    required this.travelMode,
    required this.routingPreference,
    required this.computeAlternativeRoutes,
    required this.routeModifiers,
    required this.languageCode,
    required this.units,
  });

  factory RoutesDetailsBody.fromJson(Map<String, dynamic> json) =>
      RoutesDetailsBody(
        origin: Destination.fromJson(json["origin"]),
        destination: Destination.fromJson(json["destination"]),
        travelMode: json["travelMode"],
        routingPreference: json["routingPreference"],
        computeAlternativeRoutes: json["computeAlternativeRoutes"],
        routeModifiers: RouteModifiers.fromJson(json["routeModifiers"]),
        languageCode: json["languageCode"],
        units: json["units"],
      );

  Map<String, dynamic> toJson() => {
        "origin": origin.toJson(),
        "destination": destination.toJson(),
        "travelMode": travelMode,
        "routingPreference": routingPreference,
        "computeAlternativeRoutes": computeAlternativeRoutes,
        "routeModifiers": routeModifiers.toJson(),
        "languageCode": languageCode,
        "units": units,
      };
}

class Destination {
  final Location location;

  Destination({
    required this.location,
  });

  factory Destination.fromJson(Map<String, dynamic> json) => Destination(
        location: Location.fromJson(json["location"]),
      );

  Map<String, dynamic> toJson() => {
        "location": location.toJson(),
      };
}

class Location {
  final LatLngData latLng;

  Location({
    required this.latLng,
  });

  factory Location.fromJson(Map<String, dynamic> json) => Location(
        latLng: LatLngData.fromJson(json["latLng"]),
      );

  Map<String, dynamic> toJson() => {
        "latLng": latLng.toJson(),
      };
}

class LatLngData {
  final double latitude;
  final double longitude;

  LatLngData({
    required this.latitude,
    required this.longitude,
  });

  factory LatLngData.fromJson(Map<String, dynamic> json) => LatLngData(
        latitude: json["latitude"]?.toDouble(),
        longitude: json["longitude"]?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "latitude": latitude,
        "longitude": longitude,
      };
}

class RouteModifiers {
  final bool avoidTolls;
  final bool avoidHighways;
  final bool avoidFerries;

  RouteModifiers({
    required this.avoidTolls,
    required this.avoidHighways,
    required this.avoidFerries,
  });

  factory RouteModifiers.fromJson(Map<String, dynamic> json) => RouteModifiers(
        avoidTolls: json["avoidTolls"],
        avoidHighways: json["avoidHighways"],
        avoidFerries: json["avoidFerries"],
      );

  Map<String, dynamic> toJson() => {
        "avoidTolls": avoidTolls,
        "avoidHighways": avoidHighways,
        "avoidFerries": avoidFerries,
      };
}
