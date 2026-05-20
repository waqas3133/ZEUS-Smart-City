import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:glassmorphism/glassmorphism.dart';
import '../../providers/location_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/demo_playbook_provider.dart';
import '../../services/map/google_maps_loader.dart';
import '../../widgets/map/map_loading_skeleton.dart';

class LiveMapScreen extends ConsumerStatefulWidget {
  const LiveMapScreen({super.key});

  @override
  ConsumerState<LiveMapScreen> createState() => _LiveMapScreenState();
}

class _LiveMapScreenState extends ConsumerState<LiveMapScreen> {
  GoogleMapController? _mapController;

  // Custom Night Map Theme Style
  final String _darkMapStyle = '''
  [
    {
      "elementType": "geometry",
      "stylers": [
        {
          "color": "#0d1117"
        }
      ]
    },
    {
      "elementType": "labels.text.fill",
      "stylers": [
        {
          "color": "#8b949e"
        }
      ]
    },
    {
      "elementType": "labels.text.stroke",
      "stylers": [
        {
          "color": "#0d1117"
        }
      ]
    },
    {
      "featureType": "administrative",
      "elementType": "geometry",
      "stylers": [
        {
          "color": "#30363d"
        }
      ]
    },
    {
      "featureType": "poi",
      "elementType": "labels.text.fill",
      "stylers": [
        {
          "color": "#8b949e"
        }
      ]
    },
    {
      "featureType": "road",
      "elementType": "geometry",
      "stylers": [
        {
          "color": "#21262d"
        }
      ]
    },
    {
      "featureType": "road.highway",
      "elementType": "geometry",
      "stylers": [
        {
          "color": "#30363d"
        }
      ]
    },
    {
      "featureType": "water",
      "elementType": "geometry",
      "stylers": [
        {
          "color": "#161b22"
        }
      ]
    }
  ]
  ''';

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _mapController?.setMapStyle(_darkMapStyle);
  }

  @override
  Widget build(BuildContext context) {
    final mapLoadStatus = ref.watch(googleMapsLoaderProvider);
    final locationState = ref.watch(locationProvider);
    final position = locationState.position;
    
    // Listen to real-time incident reports from Firestore
    final incidentReportsAsync = ref.watch(incidentReportsStreamProvider);
    final playbookState = ref.watch(demoPlaybookProvider);
    
    final Set<Marker> markers = {};
    final Set<Circle> circles = {};
    
    if (position != null) {
      final userLatLng = LatLng(position.latitude, position.longitude);
      
      // User location marker
      markers.add(
        Marker(
          markerId: const MarkerId('user_loc'),
          position: userLatLng,
          infoWindow: const InfoWindow(title: 'You are here'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
        ),
      );

      // Add simulated flood hazard geofence if Step 1 is active
      if (playbookState.currentStepIndex == 1) {
        final hazardPos = LatLng(position.latitude + 0.003, position.longitude + 0.003);
        markers.add(
          Marker(
            markerId: const MarkerId('simulated_flood_hazard'),
            position: hazardPos,
            infoWindow: const InfoWindow(
              title: '⚠️ CRITICAL: Urban Flood Forecast',
              snippet: 'AI agent forecasts 1.2m accumulation within 30 minutes.',
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          ),
        );
        circles.add(
          Circle(
            circleId: const CircleId('flood_radar_geofence'),
            center: hazardPos,
            radius: 350,
            fillColor: const Color(0xFFFF007F).withValues(alpha: 0.18),
            strokeColor: const Color(0xFFFF007F),
            strokeWidth: 2,
          ),
        );
      }

      // Add markers for nearby alerts from state intelligence (simulated/cached alerts)
      final alerts = locationState.intelligence?['nearby_alerts'] as List<dynamic>?;
      if (alerts != null) {
        for (var alert in alerts) {
          final double distance = (alert['distance_km'] as num?)?.toDouble() ?? 1.0;
          final alertLatLng = LatLng(
            userLatLng.latitude + (0.005 * distance),
            userLatLng.longitude + (0.005 * distance),
          );

          markers.add(
            Marker(
              markerId: MarkerId(alert['alert_id'] ?? 'alert'),
              position: alertLatLng,
              infoWindow: InfoWindow(
                title: alert['type'] ?? 'Crisis Alert',
                snippet: alert['message'] ?? '',
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                alert['severity'] == 'HIGH' 
                    ? BitmapDescriptor.hueRed 
                    : BitmapDescriptor.hueOrange,
              ),
            ),
          );
        }
      }
    }

    // Add markers from real-time Firestore stream
    incidentReportsAsync.whenData((incidentList) {
      for (var incident in incidentList) {
        markers.add(
          Marker(
            markerId: MarkerId(incident.id),
            position: LatLng(incident.latitude, incident.longitude),
            infoWindow: InfoWindow(
              title: incident.detectedEvent,
              snippet: '${incident.severity} | ${incident.aiSummary}',
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              incident.severity == 'SEVERE' || incident.severity == 'HIGH' || incident.severity == 'CRITICAL'
                  ? BitmapDescriptor.hueRed
                  : BitmapDescriptor.hueOrange,
            ),
          ),
        );
      }
    });

    final initialCameraPosition = CameraPosition(
      target: position != null 
          ? LatLng(position.latitude, position.longitude)
          : const LatLng(33.6844, 73.0479), // Default Islamabad coords
      zoom: 14.0,
    );

    return Scaffold(
      body: Stack(
        children: [
          // Google Map
          if (mapLoadStatus == GoogleMapsLoadStatus.loaded)
            GoogleMap(
              initialCameraPosition: initialCameraPosition,
              onMapCreated: _onMapCreated,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              markers: markers,
              circles: circles,
            )
          else
            MapLoadingSkeleton(
              hasError: mapLoadStatus == GoogleMapsLoadStatus.error,
              onRetry: () => ref.read(googleMapsLoaderProvider.notifier).retry(),
            ),

          // Top Location Bar (Glassmorphic)
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: GlassmorphicContainer(
              width: double.infinity,
              height: 70,
              borderRadius: 16,
              blur: 15,
              border: 1,
              linearGradient: LinearGradient(
                colors: [
                  Colors.black.withValues(alpha: 0.6),
                  Colors.black.withValues(alpha: 0.4),
                ],
              ),
              borderGradient: LinearGradient(
                colors: [
                  const Color(0xFF00E5FF).withValues(alpha: 0.3),
                  Colors.white.withValues(alpha: 0.1),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: Color(0xFF00E5FF), size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            locationState.detectedCity ?? 'Detecting Location...',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            locationState.intelligence?['formatted_address'] ?? 'Fetching address details...',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.my_location, color: Colors.white),
                      onPressed: () {
                        if (position != null && _mapController != null) {
                          _mapController!.animateCamera(
                            CameraUpdate.newLatLng(
                              LatLng(position.latitude, position.longitude),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom AI Recommendation Overlay (Glassmorphic)
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: GlassmorphicContainer(
              width: double.infinity,
              height: 200,
              borderRadius: 24,
              blur: 20,
              border: 1,
              linearGradient: LinearGradient(
                colors: [
                  Colors.black.withValues(alpha: 0.75),
                  Colors.black.withValues(alpha: 0.55),
                ],
              ),
              borderGradient: LinearGradient(
                colors: [
                  const Color(0xFFFF007F).withValues(alpha: 0.3),
                  const Color(0xFF00E5FF).withValues(alpha: 0.2),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF007F).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFFF007F)),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.bolt, color: Color(0xFFFF007F), size: 16),
                              SizedBox(width: 4),
                              Text(
                                'AI INSIGHT',
                                style: TextStyle(
                                  color: Color(0xFFFF007F),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        const Text(
                          '2 alerts nearby',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Personalized Safety Guidance:',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Text(
                          locationState.intelligence?['ai_recommendation'] ?? 
                              'Analyzing nearby weather risks and traffic conditions to synthesize real-time safety recommendations...',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
