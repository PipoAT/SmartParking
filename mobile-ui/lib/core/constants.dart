import 'dart:io' show Platform;

class AppConstants {
  // API Configuration
  // Default to localhost for development
  // Set environment variable API_BASE_URL for production deployment
  static String get baseApiUrl {
    // Check for environment variable first
    const envApiUrl = String.fromEnvironment('API_BASE_URL', defaultValue: '');
    if (envApiUrl.isNotEmpty) {
      return envApiUrl;
    }
    
    // Platform-specific defaults for local development
    if (Platform.isAndroid) {
      // Android emulator uses 10.0.2.2 to access host machine
      return 'http://10.0.2.2:8080/api';
    } else if (Platform.isIOS) {
      // iOS simulator can use localhost
      return 'http://localhost:8080/api';
    } else {
      // Web, desktop, or other platforms
      return 'http://localhost:8080/api';
    }
  }

  // App Information
  static const String appName = 'Smart Parking';
  static const String appVersion = '1.0.0';

  // Sensor Configuration
  static const int sensorRefreshInterval = 5000; // milliseconds
  
  // Storage Keys
  static const String jwtTokenKey = 'jwt_token';
  static const String userDataKey = 'user_data';
}
