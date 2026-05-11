import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/message_model.dart';
import '../utils/constants.dart';
import '../config/api_config.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  Future<AIResponse> correctEnglish(String userInput, {
    String? userLanguage,
    String? englishLevel,
    String? learningGoal,
    String? mode,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.getEndpointUrl(ApiConfig.correctEndpoint)),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'text': userInput,
          'user_language': userLanguage ?? 'kannada',
          'english_level': englishLevel ?? 'beginner',
          'learning_goal': learningGoal ?? 'daily_conversation',
          'mode': mode ?? 'correction',
        }),
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return AIResponse.fromJson(data);
      } else {
        // Improved error handling with detailed information
        throw Exception(
          'Status: ${response.statusCode}, Body: ${response.body}',
        );
      }
    } catch (e) {
      if (e is http.ClientException) {
        throw Exception(AppConstants.networkErrorMessage);
      } else {
        // Re-throw the detailed exception for better debugging
        rethrow;
      }
    }
  }

  Future<bool> checkServerConnection() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getEndpointUrl(ApiConfig.healthEndpoint)),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<String> getServerStatus() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getEndpointUrl(ApiConfig.statusEndpoint)),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['status'] ?? 'Unknown';
      } else {
        return 'Error: ${response.statusCode}';
      }
    } catch (e) {
      return 'Connection failed';
    }
  }
}
