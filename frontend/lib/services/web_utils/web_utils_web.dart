import 'dart:js_interop';
import 'dart:ui';
import 'dart:developer' as developer;

// Extensions on JSObject to query properties safely
extension FCMBrowserExtension on JSObject {
  external JSObject? get navigator;
  external JSObject? get PushManager;
}

extension FCMNavigatorExtension on JSObject {
  external JSObject? get serviceWorker;
}

extension GlobalMapsExtension on JSObject {
  external JSObject? get google;
  external void loadGoogleMapsSdk(JSString apiKey);
  external set onGoogleMapsLoaded(JSFunction callback);
  external set onGoogleMapsLoadError(JSFunction callback);
}

extension GoogleMapsObjectExtension on JSObject {
  external JSObject? get maps;
}

bool isPushSupported() {
  try {
    final navigator = globalContext.navigator;
    if (navigator == null) return false;
    final serviceWorker = navigator.serviceWorker;
    if (serviceWorker == null) return false;
    
    final pushManager = globalContext.PushManager;
    return pushManager != null;
  } catch (e) {
    return false;
  }
}

bool isGoogleMapsSdkLoaded() {
  try {
    final google = globalContext.google;
    if (google == null) return false;
    final maps = google.maps;
    return maps != null;
  } catch (e) {
    return false;
  }
}

void loadGoogleMapsSdkWeb(String apiKey, VoidCallback onLoaded, VoidCallback onError) {
  try {
    globalContext.onGoogleMapsLoaded = onLoaded.toJS;
    globalContext.onGoogleMapsLoadError = onError.toJS;
    globalContext.loadGoogleMapsSdk(apiKey.toJS);
  } catch (e) {
    developer.log("Failed to register callbacks or call script loader: $e");
    onError();
  }
}
