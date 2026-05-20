import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'dart:js_interop';
import 'dart:developer' as developer;

enum GoogleMapsLoadStatus {
  loading,
  loaded,
  error,
}

// Extension to access window/global properties safely
extension GlobalMapsExtension on JSObject {
  external JSObject? get google;
  external void loadGoogleMapsSdk(JSString apiKey);
  external set onGoogleMapsLoaded(JSFunction callback);
  external set onGoogleMapsLoadError(JSFunction callback);
}

extension GoogleMapsObjectExtension on JSObject {
  external JSObject? get maps;
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
      // Register web callbacks on globalContext
      globalContext.onGoogleMapsLoaded = (() {
        developer.log("Google Maps loaded callback received from browser.");
        state = GoogleMapsLoadStatus.loaded;
      }).toJS;

      globalContext.onGoogleMapsLoadError = (() {
        developer.log("Google Maps failed to load callback received from browser.");
        state = GoogleMapsLoadStatus.error;
      }).toJS;

      // Call global JS loader defined in index.html
      const apiKey = 'AIzaSyAqdk4QSDbGIsmJ36Q3jb7ZRrSLvM9CFhQ';
      globalContext.loadGoogleMapsSdk(apiKey.toJS);
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
    try {
      final google = globalContext.google;
      if (google == null) return false;
      final maps = google.maps;
      return maps != null;
    } catch (e) {
      return false;
    }
  }
}

final googleMapsLoaderProvider = NotifierProvider<GoogleMapsLoader, GoogleMapsLoadStatus>(GoogleMapsLoader.new);
