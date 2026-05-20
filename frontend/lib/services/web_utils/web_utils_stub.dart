import 'dart:ui';

bool isPushSupported() {
  return true;
}

bool isGoogleMapsSdkLoaded() {
  return true;
}

void loadGoogleMapsSdkWeb(String apiKey, VoidCallback onLoaded, VoidCallback onError) {
  // No-op on mobile/native platforms
}
