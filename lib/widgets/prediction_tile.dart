import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:route_tracking/utils/google_maps_service.dart';

import '../models/autocomplete_predictions_model/prediction.dart';

class PredictionTile extends StatelessWidget {
  const PredictionTile({
    super.key,
    required this.onPredictionTaped,
    required this.prediction,
  });
  final PredictionData prediction;
  final void Function(LatLng latLng) onPredictionTaped;

  @override
  Widget build(BuildContext context) {
    final googleMapsPlacesService = GoogleMapsService();
    return Container(
      color: Colors.white,
      child: ListTile(
        onTap: () async {
          final placeDetails = await googleMapsPlacesService
              .fetchPlaceDetails(prediction.placeId!);

          if (placeDetails != null) {
            final latLng = LatLng(
              placeDetails.result!.geometry!.location!.lat!,
              placeDetails.result!.geometry!.location!.lng!,
            );
            onPredictionTaped(latLng);
          }
        },
        leading: const Icon(
          Icons.pin_drop,
          color: Colors.black54,
        ),
        title: Text(
          prediction.description!,
          style: const TextStyle().copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: const Icon(
          Icons.rocket_launch,
          color: Colors.black54,
        ),
      ),
    );
  }
}
