import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';

enum LocationStatus { initial, requesting, fetching, success, denied, error }

class LocationState {
  final LocationStatus status;
  final Position? position;
  final String? detectedCity;
  final Map<String, dynamic>? intelligence;
  final String? errorMessage;

  LocationState({
    required this.status,
    this.position,
    this.detectedCity,
    this.intelligence,
    this.errorMessage,
  });

  LocationState copyWith({
    LocationStatus? status,
    Position? position,
    String? detectedCity,
    Map<String, dynamic>? intelligence,
    String? errorMessage,
  }) {
    return LocationState(
      status: status ?? this.status,
      position: position ?? this.position,
      detectedCity: detectedCity ?? this.detectedCity,
      intelligence: intelligence ?? this.intelligence,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class LocationNotifier extends Notifier<LocationState> {
  final LocationService _locationService = LocationService();

  @override
  LocationState build() {
    return LocationState(status: LocationStatus.initial);
  }

  /// Attempts to initialize the live location system
  Future<void> detectLiveLocation() async {
    state = state.copyWith(status: LocationStatus.requesting);

    try {
      bool hasPerm = await _locationService.checkPermission();
      if (!hasPerm) {
        bool granted = await _locationService.requestPermission();
        if (!granted) {
          state = state.copyWith(status: LocationStatus.denied);
          return;
        }
      }

      state = state.copyWith(status: LocationStatus.fetching);
      Position? position = await _locationService.getCurrentCoordinates();

      if (position != null) {
        final intelligence = await _locationService.getLocationIntelligence(
          position.latitude,
          position.longitude,
          // We pass context if needed, but not required
        );

        String city = intelligence?['detected_city'] ?? 'Unknown City';

        state = state.copyWith(
          status: LocationStatus.success,
          position: position,
          detectedCity: city,
          intelligence: intelligence,
        );
      } else {
        state = state.copyWith(
          status: LocationStatus.error,
          errorMessage: 'Could not fetch GPS coordinates.',
        );
      }
    } catch (e) {
      state = state.copyWith(
        status: LocationStatus.error,
        errorMessage: 'An unexpected location error occurred: $e',
      );
    }
  }

  /// Fallback to manual city entry
  Future<void> setManualCity(String city) async {
    state = state.copyWith(status: LocationStatus.fetching);
    
    // Simulate manual location context
    final mockIntelligence = {
      'detected_city': city,
      'formatted_address': '$city, Pakistan',
      'nearby_alerts': [
        {
          'alert_id': 'ALT-MANUAL',
          'type': 'Weather Update',
          'severity': 'INFO',
          'message': 'Manual location set to $city.',
          'distance_km': 0.0
        }
      ],
      'ai_recommendation': 'Stay tuned for localized reports in $city.'
    };

    state = state.copyWith(
      status: LocationStatus.success,
      detectedCity: city,
      intelligence: mockIntelligence,
      position: null, // GPS coordinates not available for manual entry
    );
  }
}

final locationProvider = NotifierProvider<LocationNotifier, LocationState>(LocationNotifier.new);
