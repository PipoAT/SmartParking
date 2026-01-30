import 'constants_stub.dart'
    if (dart.library.io) 'constants_io.dart'
    if (dart.library.html) 'constants_web.dart';

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
    
    // Use platform-specific implementation
    return getDefaultApiUrl();
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
