import 'package:flutter/foundation.dart';
import 'dart:io';

class ApiConfig {
  static String get baseUrl {
    // Flutter Web
    if (kIsWeb) {
      return 'http://localhost:8000';
    }

    // Android Emulator
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000';
    }

    // Desktop
    return 'http://localhost:8000';
  }

  // For physical Android device testing
  // Replace with your PC's local IP when testing on physical device
  // Example: http://192.168.1.5:8000
  static const String physicalDeviceBaseUrl = 'http://YOUR_PC_LOCAL_IP:8000';

  // Endpoints
  static String get correctEndpoint => '/api/correct';
  static String get healthEndpoint => '/health';
  static String get statusEndpoint => '/status';
  static String get voiceTranscribeEndpoint => '/voice/transcribe';
  static String get voiceStatusEndpoint => '/voice/status';

  // Helper method to get full URL for endpoints
  static String getEndpointUrl(String endpoint) {
    return '$baseUrl$endpoint';
  }

  // Check if running on physical device (for debugging)
  static bool get isPhysicalDevice {
    if (!kIsWeb && Platform.isAndroid) {
      // You can add additional checks here if needed
      return true; // Assume true for Android, adjust as needed
    }
    return false;
  }
}
