import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:route_tracking/widgets/prediction_tile.dart';

import '../models/autocomplete_predictions_model/prediction.dart';

class PredictionsListView extends StatelessWidget {
  const PredictionsListView({
    super.key,
    required this.predictions,
    required this.onPredictionTaped,
  });
  final List<PredictionData> predictions;
  final void Function(LatLng latLng) onPredictionTaped;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.separated(
        itemCount: predictions.length,
        itemBuilder: (context, index) => InkWell(
          onTap: () {
            print(predictions[index].placeId);
          },
          child: PredictionTile(
            onPredictionTaped: onPredictionTaped,
            prediction: predictions[index],
          ),
        ),
        separatorBuilder: (context, index) => const SizedBox(
          height: 8,
        ),
      ),
    );
  }
}
