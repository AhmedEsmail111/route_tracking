import 'prediction.dart';

class AutocompletePredictionsModel {
  List<PredictionData>? predictions;
  String? status;

  AutocompletePredictionsModel({this.predictions, this.status});

  factory AutocompletePredictionsModel.fromJson(Map<String, dynamic> json) {
    return AutocompletePredictionsModel(
      predictions: (json['predictions'] as List<dynamic>?)
          ?.map((e) => PredictionData.fromJson(e as Map<String, dynamic>))
          .toList(),
      status: json['status'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'predictions': predictions?.map((e) => e.toJson()).toList(),
        'status': status,
      };
}
