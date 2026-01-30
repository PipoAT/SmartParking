import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smart_parking/core/constants.dart';

class SensorService {
  final String baseUrl = AppConstants.baseApiUrl;
  Timer? _sensorPollingTimer;
  bool _isReading = false;

  // Get current light sensor reading from backend
  Future<int?> getLightSensorReading() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/LightSensor/read'),
        headers: {"Content-Type": "application/json"},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        // The endpoint returns JSON with lightLevel and timestamp
        final data = jsonDecode(response.body);
        final lightLevel = data['lightLevel'] as int?;
        return lightLevel;
      }
      return null;
    } on TimeoutException {
      // Log timeout for debugging
      print('Warning: Sensor reading timed out');
      return null;
    } catch (e) {
      // Sensor might not be available, return null
      print('Warning: Failed to read sensor: $e');
      return null;
    }
  }

  // Start polling sensor data at regular intervals
  void startSensorPolling(Function(int) onDataReceived) {
    _sensorPollingTimer?.cancel();
    _sensorPollingTimer = Timer.periodic(
      Duration(milliseconds: AppConstants.sensorRefreshInterval),
      (_) async {
        // Prevent overlapping requests
        if (_isReading) return;
        
        _isReading = true;
        try {
          final reading = await getLightSensorReading();
          if (reading != null) {
            onDataReceived(reading);
          }
        } finally {
          _isReading = false;
        }
      },
    );
  }

  // Stop polling sensor data
  void stopSensorPolling() {
    _sensorPollingTimer?.cancel();
    _sensorPollingTimer = null;
  }

  // Dispose resources
  void dispose() {
    stopSensorPolling();
  }
}
