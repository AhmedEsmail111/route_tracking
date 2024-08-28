import 'route.dart';

class RoutesApiResponseModel {
  List<Route>? routes;

  RoutesApiResponseModel({this.routes});

  factory RoutesApiResponseModel.fromJson(Map<String, dynamic> json) {
    return RoutesApiResponseModel(
      routes: (json['routes'] as List<dynamic>?)
          ?.map((e) => Route.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'routes': routes?.map((e) => e.toJson()).toList(),
      };
}
