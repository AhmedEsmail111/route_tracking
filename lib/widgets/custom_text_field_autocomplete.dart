import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:route_tracking/utils/consts.dart';
import 'package:route_tracking/utils/google_maps_service.dart';
import 'package:route_tracking/widgets/predictions_list_view.dart';
import 'package:uuid/uuid.dart';

import '../models/autocomplete_predictions_model/autocomplete_predictions_model.dart';

class CustomTextFieldAutocomplete extends StatefulWidget {
  const CustomTextFieldAutocomplete({
    super.key,
    required this.onPredictionTaped,
  });
  final void Function(LatLng latLng) onPredictionTaped;
  @override
  State<CustomTextFieldAutocomplete> createState() =>
      _CustomTextFieldAutocompleteState();
}

class _CustomTextFieldAutocompleteState
    extends State<CustomTextFieldAutocomplete> {
  late Uuid _uuid;
  final _textFieldFocusNode = FocusNode();
  late TextEditingController _controller;

  late GoogleMapsService _googleMapsPlacesService;
  AutocompletePredictionsModel? _autocompletePredictionsModel;
  String? _sessionToken;
  Timer? _debounce;
  @override
  void initState() {
    super.initState();
    _uuid = const Uuid();
    _controller = TextEditingController();
    _googleMapsPlacesService = GoogleMapsService();
    _controller.addListener(_autocompleteTextListener);
  }

  @override
  void dispose() {
    _controller.removeListener(_autocompleteTextListener);
    _controller.dispose();
    _textFieldFocusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _controller,
          focusNode: _textFieldFocusNode,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            fillColor: Colors.white,
            filled: true,
            hintText: 'search here',
            prefixIcon: Image.asset(
              googleMapSearchLogo,
              height: 18,
              width: 18,
              fit: BoxFit.contain,
            ),
            border: _buildBorder(),
            focusedBorder: _buildBorder(),
            enabledBorder: _buildBorder(),
          ),
        ),
        _autocompletePredictionsModel != null &&
                _controller.text.trim().isNotEmpty
            ? PredictionsListView(
                onPredictionTaped: _onPredictionTap,
                predictions: _autocompletePredictionsModel!.predictions!,
              )
            : Container()
      ],
    );
  }

  OutlineInputBorder _buildBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(24),
      borderSide: BorderSide.none,
    );
  }

// set up and clear some data , update the sessionToken and animate the camera
  void _onPredictionTap(LatLng latLng) {
    _textFieldFocusNode.unfocus();
    _controller.text = '';
    _autocompletePredictionsModel = null;
    _sessionToken = _uuid.v4();

    widget.onPredictionTaped(latLng);
  }

// a listener to be called every time the textField has a new value
  void _autocompleteTextListener() {
    if (_debounce?.isActive ?? false) {
      _debounce?.cancel();
    }
    _debounce = Timer(
      const Duration(milliseconds: 200),
      () async {
        _sessionToken ??= _uuid.v4();
        if (_controller.text.trim().isNotEmpty) {
          _autocompletePredictionsModel =
              await _googleMapsPlacesService.fetchAutocompletePredictions(
            input: _controller.text,
            sessionToken: _sessionToken!,
          );
        } else {
          _autocompletePredictionsModel = null;
        }
        setState(() {});
      },
    );
  }
}
