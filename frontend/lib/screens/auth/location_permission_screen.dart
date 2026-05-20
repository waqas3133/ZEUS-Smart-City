import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:glassmorphism/glassmorphism.dart';
import '../../providers/location_provider.dart';

class LocationPermissionScreen extends ConsumerStatefulWidget {
  const LocationPermissionScreen({super.key});

  @override
  ConsumerState<LocationPermissionScreen> createState() => _LocationPermissionScreenState();
}

class _LocationPermissionScreenState extends ConsumerState<LocationPermissionScreen> {
  final TextEditingController _cityController = TextEditingController();
  bool _showManualInput = false;

  @override
  Widget build(BuildContext context) {
    final locationState = ref.watch(locationProvider);

    // Watch status and navigate to map/dashboard if location is successfully detected
    ref.listen(locationProvider, (previous, next) {
      if (next.status == LocationStatus.success) {
        context.go('/dashboard');
      }
    });

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0D1117), Color(0xFF161B22)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 96,
                    color: Color(0xFF00E5FF),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'LOCATION INTELLIGENCE',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'ZEUS Smart City uses live location to deliver real-time crisis alerts, flood forecasts, and local weather updates instantly.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 48),
                  
                  if (locationState.status == LocationStatus.fetching || 
                      locationState.status == LocationStatus.requesting)
                    const Column(
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00E5FF)),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Detecting City & Coordinates...',
                          style: TextStyle(color: Color(0xFF00E5FF)),
                        )
                      ],
                    )
                  else ...[
                    // Premium Glassmorphic Permission Card
                    GlassmorphicContainer(
                      width: double.infinity,
                      height: _showManualInput ? 240 : 160,
                      borderRadius: 20,
                      blur: 20,
                      alignment: Alignment.center,
                      border: 2,
                      linearGradient: LinearGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.05),
                          Colors.white.withValues(alpha: 0.02),
                        ],
                      ),
                      borderGradient: LinearGradient(
                        colors: [
                          const Color(0xFF00E5FF).withValues(alpha: 0.2),
                          const Color(0xFFFF007F).withValues(alpha: 0.1),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (!_showManualInput) ...[
                              ElevatedButton.icon(
                                onPressed: () {
                                  ref.read(locationProvider.notifier).detectLiveLocation();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF00E5FF),
                                  foregroundColor: Colors.black,
                                  minimumSize: const Size(double.infinity, 50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                icon: const Icon(Icons.gps_fixed),
                                label: const Text(
                                  'ENABLE GPS DETECTION',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _showManualInput = true;
                                  });
                                },
                                child: const Text(
                                  'Or enter city manually',
                                  style: TextStyle(color: Color(0xFFFF007F)),
                                ),
                              ),
                            ] else ...[
                              TextField(
                                controller: _cityController,
                                decoration: InputDecoration(
                                  labelText: 'Enter your city (e.g. Islamabad)',
                                  labelStyle: const TextStyle(color: Colors.white70),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.white.withValues(alpha: 0.3),
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  focusedBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(color: Color(0xFF00E5FF)),
                                  ),
                                ),
                                style: const TextStyle(color: Colors.white),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextButton(
                                      onPressed: () {
                                        setState(() {
                                          _showManualInput = false;
                                        });
                                      },
                                      child: const Text('Back'),
                                    ),
                                  ),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        if (_cityController.text.isNotEmpty) {
                                          ref.read(locationProvider.notifier).setManualCity(_cityController.text);
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFFFF007F),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: const Text('SAVE'),
                                    ),
                                  ),
                                ],
                              ),
                            ]
                          ],
                        ),
                      ),
                    ),
                  ],
                  if (locationState.status == LocationStatus.error) ...[
                    const SizedBox(height: 16),
                    Text(
                      locationState.errorMessage ?? 'Error fetching location.',
                      style: const TextStyle(color: Colors.redAccent),
                    )
                  ]
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
