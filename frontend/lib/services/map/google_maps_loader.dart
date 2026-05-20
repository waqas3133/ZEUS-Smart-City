import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'dart:developer' as developer;
import '../web_utils/web_utils.dart';

enum GoogleMapsLoadStatus {
  loading,
  loaded,
  error,
}

class GoogleMapsLoader extends Notifier<GoogleMapsLoadStatus> {
  @override
  GoogleMapsLoadStatus build() {
    if (!kIsWeb) {
      return GoogleMapsLoadStatus.loaded;
    }
    
    if (_isSdkLoaded()) {
      return GoogleMapsLoadStatus.loaded;
    }

    // Schedule asynchronous script injection and checks
    Future.microtask(() => _checkAndLoad());
    return GoogleMapsLoadStatus.loading;
  }

  void _checkAndLoad() {
    if (_isSdkLoaded()) {
      state = GoogleMapsLoadStatus.loaded;
      return;
    }

    developer.log("Initializing Google Maps script dynamic load listeners...");

    try {
      const apiKey = 'AIzaSyAqdk4QSDbGIsmJ36Q3jb7ZRrSLvM9CFhQ';
      loadGoogleMapsSdkWeb(
        apiKey,
        () {
          developer.log("Google Maps loaded callback received from browser.");
          state = GoogleMapsLoadStatus.loaded;
        },
        () {
          developer.log("Google Maps failed to load callback received from browser.");
          state = GoogleMapsLoadStatus.error;
        },
      );
    } catch (e) {
      developer.log("Failed to register callbacks or call script loader: $e");
      state = GoogleMapsLoadStatus.error;
    }
  }

  /// Attempts to re-load the Google Maps JavaScript SDK
  void retry() {
    if (state == GoogleMapsLoadStatus.loading) return;
    developer.log("Retrying Google Maps dynamic script load...");
    state = GoogleMapsLoadStatus.loading;
    _checkAndLoad();
  }

  /// Internal utility to verify if window.google.maps namespace is available
  bool _isSdkLoaded() {
    if (!kIsWeb) return true;
    return isGoogleMapsSdkLoaded();
  }
}

final googleMapsLoaderProvider = NotifierProvider<GoogleMapsLoader, GoogleMapsLoadStatus>(GoogleMapsLoader.new);
