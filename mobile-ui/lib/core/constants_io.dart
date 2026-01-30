import 'dart:io' show Platform;

// Platform-specific implementation for native platforms (iOS, Android, Desktop)
String getDefaultApiUrl() {
  if (Platform.isAndroid) {
    // Android emulator uses 10.0.2.2 to access host machine
    return 'http://10.0.2.2:8080/api';
  } else if (Platform.isIOS) {
    // iOS simulator can use localhost
    return 'http://localhost:8080/api';
  } else {
    // Desktop or other platforms
    return 'http://localhost:8080/api';
  }
}
