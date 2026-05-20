import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:dio/dio.dart';
import 'dart:async';
import 'dart:developer' as developer;
import '../../core/constants/api_constants.dart';

import '../../widgets/traffic/traffic_overlay_widget.dart';
import '../../widgets/traffic/route_simulation_widget.dart';
import '../../widgets/traffic/emergency_route_widget.dart';
import '../../providers/demo_playbook_provider.dart';
import '../../services/map/google_maps_loader.dart';
import '../../widgets/map/map_loading_skeleton.dart';

class SmartMapScreen extends ConsumerStatefulWidget {
  const SmartMapScreen({super.key});

  @override
  ConsumerState<SmartMapScreen> createState() => _SmartMapScreenState();
}

class _SmartMapScreenState extends ConsumerState<SmartMapScreen> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final Set<Circle> _circles = {};
  final Set<Polyline> _polylines = {};

  final List<String> _swarmLogs = [];
  bool _isSimulating = false;
  Timer? _simulationTimer;
  int _simStep = 0;

  // AI response state
  String _trafficStatus = "CONGESTED";
  String _delay = "Calculating...";
  String _riskLevel = "MODERATE";
  String _recommendation = "Acquiring live satellite feed and routing intelligence...";
  List<String> _blockedRoutes = ["Shahrah Faisal"];

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
      "featureType": "road",
      "elementType": "geometry",
      "stylers": [
        {
          "color": "#21262d"
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

  @override
  void initState() {
    super.initState();
    _loadInitialDangerZones();
    _triggerRoutingAnalysis();
  }

  @override
  void dispose() {
    _simulationTimer?.cancel();
    super.dispose();
  }

  void _loadInitialDangerZones() {
    setState(() {
      // Flood danger zone (Red)
      _circles.add(
        Circle(
          circleId: const CircleId('flood_zone_1'),
          center: const LatLng(33.6980, 73.0610),
          radius: 400,
          fillColor: const Color(0xFFFF007F).withOpacity(0.2),
          strokeColor: const Color(0xFFFF007F),
          strokeWidth: 2,
        ),
      );

      // Blocked incident zone (Orange)
      _circles.add(
        Circle(
          circleId: const CircleId('block_zone_1'),
          center: const LatLng(33.7130, 73.0780),
          radius: 300,
          fillColor: Colors.orangeAccent.withOpacity(0.2),
          strokeColor: Colors.orangeAccent,
          strokeWidth: 2,
        ),
      );

      // Markers for blocks
      _markers.add(
        const Marker(
          markerId: MarkerId('flood_marker'),
          position: LatLng(33.6980, 73.0610),
          infoWindow: InfoWindow(title: 'FLOOD ALERT: 1.5m Water accumulation'),
        ),
      );
    });
  }

  Future<void> _triggerRoutingAnalysis() async {
    final dio = Dio();
    try {
      final response = await dio.post(
        '${ApiConstants.baseUrl}/traffic/simulation',
        data: {
          "origin": "Jinnah Avenue, Islamabad",
          "destination": "Saddar, Rawalpindi",
          "blocked_streets": ["Murree Road"]
        },
      );

      if (response.statusCode == 200 && response.data['status'] == 'success') {
        final data = response.data['data'];
        setState(() {
          _trafficStatus = data['traffic_status'];
          _delay = data['estimated_delay'];
          _riskLevel = data['risk_level'];
          _recommendation = data['ai_recommendation'];
          _blockedRoutes = List<String>.from(data['blocked_routes']);
        });
      }
    } catch (e) {
      developer.log("Failed to connect to backend traffic api: $e");
      // Load fallback values in UI if offline
      setState(() {
        _trafficStatus = "BLOCKED";
        _delay = "18 mins delay";
        _riskLevel = "CRITICAL";
        _recommendation = "Heavy urban flooding near primary expressway. Alternate route generated via elevated western bypass.";
      });
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _mapController?.setMapStyle(_darkMapStyle);
    _drawRoutes();
  }

  void _drawRoutes() {
    setState(() {
      // Primary Blocked route (Red polyline)
      _polylines.add(
        const Polyline(
          polylineId: PolylineId('primary_blocked'),
          points: [
            LatLng(33.6844, 73.0479),
            LatLng(33.6980, 73.0610),
            LatLng(33.7130, 73.0780),
          ],
          color: Color(0xFFFF007F),
          width: 5,
        ),
      );

      // Safe Alternate Bypass route (Cyan polyline)
      _polylines.add(
        const Polyline(
          polylineId: PolylineId('alternate_safe'),
          points: [
            LatLng(33.6844, 73.0479),
            LatLng(33.6720, 73.0600),
            LatLng(33.6890, 73.0800),
            LatLng(33.7294, 73.0931),
          ],
          color: Color(0xFF00E5FF),
          width: 5,
        ),
      );
    });
  }

  void _startEmergencyDispatch() {
    if (_isSimulating) {
      _simulationTimer?.cancel();
      setState(() {
        _isSimulating = false;
        _swarmLogs.clear();
        // Remove dispatch marker
        _markers.removeWhere((m) => m.markerId.value == 'dispatch_vehicle');
      });
      return;
    }

    setState(() {
      _isSimulating = true;
      _simStep = 0;
      _swarmLogs.add("[Swarm Orchesrator] Dispatch request accepted.");
      _swarmLogs.add("[Decision Agent] Querying safe bypass routes...");
    });

    final points = [
      const LatLng(33.6844, 73.0479),
      const LatLng(33.6720, 73.0600),
      const LatLng(33.6890, 73.0800),
      const LatLng(33.7294, 73.0931),
    ];

    _simulationTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_simStep >= points.length) {
        timer.cancel();
        setState(() {
          _isSimulating = false;
          _swarmLogs.add("[Swarm Orchestrator] Emergency vehicle successfully reached destination safely.");
        });
        return;
      }

      final currentPos = points[_simStep];
      setState(() {
        _markers.removeWhere((m) => m.markerId.value == 'dispatch_vehicle');
        _markers.add(
          Marker(
            markerId: const MarkerId('dispatch_vehicle'),
            position: currentPos,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
            infoWindow: const InfoWindow(title: 'Ambulance: Dispatched on safe route'),
          ),
        );

        if (_simStep == 1) {
          _swarmLogs.add("[Traffic Agent] Bypassing flooded sector Murree Road.");
        } else if (_simStep == 2) {
          _swarmLogs.add("[Simulation Engine] Speed optimized +45kmh on western expressway.");
        }

        _simStep++;
      });

      _mapController?.animateCamera(CameraUpdate.newLatLng(currentPos));
    });
  }

  @override
  Widget build(BuildContext context) {
    final mapLoadStatus = ref.watch(googleMapsLoaderProvider);
    ref.listen(demoPlaybookProvider, (previous, next) {
      if (next?.currentStepIndex == 3) {
        if (!_isSimulating) {
          // Add a tiny delay to let screen transition finish
          Future.delayed(const Duration(milliseconds: 1000), () {
            if (mounted && !_isSimulating) {
              _startEmergencyDispatch();
            }
          });
        }
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          // Dark Google Map
          if (mapLoadStatus == GoogleMapsLoadStatus.loaded)
            GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: LatLng(33.6950, 73.0650),
                zoom: 13.0,
              ),
              onMapCreated: _onMapCreated,
              markers: _markers,
              circles: _circles,
              polylines: _polylines,
              myLocationButtonEnabled: false,
            )
          else
            MapLoadingSkeleton(
              hasError: mapLoadStatus == GoogleMapsLoadStatus.error,
              onRetry: () {
                _triggerRoutingAnalysis();
                ref.read(googleMapsLoaderProvider.notifier).retry();
              },
            ),

          // Sliding Panels & Overlays
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const Text(
                  'TRAFFIC INTELLIGENCE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),

          // Bottom Glassmorphic Dashboard Controls
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Column(
              children: [
                // Analytical simulation panel
                RouteSimulationWidget(
                  beforeCongestion: 0.85,
                  afterCongestion: 0.35,
                  beforeTimeMins: 38,
                  afterTimeMins: 20,
                  timeSavedMins: 18,
                ),
                const SizedBox(height: 12),
                
                // AI Routing Panel
                TrafficOverlayWidget(
                  status: _trafficStatus,
                  delay: _delay,
                  riskLevel: _riskLevel,
                  recommendation: _recommendation,
                  blockedRoutes: _blockedRoutes,
                ),
                const SizedBox(height: 12),

                // Emergency Dispatch Controller
                EmergencyRouteWidget(
                  onDispatch: _startEmergencyDispatch,
                  isSimulating: _isSimulating,
                  logs: _swarmLogs,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
