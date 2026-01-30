import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smart_parking/core/constants.dart';

class SensorService {
  final String baseUrl = AppConstants.baseApiUrl;
  Timer? _sensorPollingTimer;

  // Get current light sensor reading from backend
  Future<int?> getLightSensorReading() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/LightSensor/read'),
        headers: {"Content-Type": "application/json"},
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        // The endpoint returns just the light level value as text
        final lightLevel = int.tryParse(response.body.trim());
        return lightLevel;
      }
      return null;
    } catch (e) {
      // Sensor might not be available, return null
      return null;
    }
  }

  // Start polling sensor data at regular intervals
  void startSensorPolling(Function(int) onDataReceived) {
    _sensorPollingTimer?.cancel();
    _sensorPollingTimer = Timer.periodic(
      Duration(milliseconds: AppConstants.sensorRefreshInterval),
      (_) async {
        final reading = await getLightSensorReading();
        if (reading != null) {
          onDataReceived(reading);
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
