import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:record/record.dart';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import '../config/api_config.dart';

enum WebAudioState {
  idle,
  recording,
  uploading,
  processing,
  completed,
  error
}

class WebAudioService {
  static final WebAudioService _instance = WebAudioService._internal();
  factory WebAudioService() => _instance;
  WebAudioService._internal();

  final AudioRecorder _audioRecorder = AudioRecorder();
  
  WebAudioState _state = WebAudioState.idle;
  String _errorMessage = '';
  
  WebAudioState get state => _state;
  String get errorMessage => _errorMessage;
  bool get isRecording => _state == WebAudioState.recording;
  bool get isProcessing => _state == WebAudioState.uploading || _state == WebAudioState.processing;

  Future<bool> initialize() async {
    try {
      debugPrint('Initializing web audio service...');
      
      // Check if we're on web platform
      if (!kIsWeb) {
        debugPrint('WebAudioService should only be used on Flutter Web');
        return false;
      }
      
      // Check microphone permission for web
      bool hasPermission = await _audioRecorder.hasPermission();
      if (!hasPermission) {
        debugPrint('Microphone permission not granted for web');
        _errorMessage = AppConstants.microphonePermissionDenied;
        return false;
      }
      
      debugPrint('Web audio service initialized successfully');
      return true;
    } catch (e) {
      debugPrint('Failed to initialize web audio service: $e');
      _errorMessage = AppConstants.audioRecordingFailed;
      _state = WebAudioState.error;
      return false;
    }
  }

  Future<bool> startRecording() async {
    if (_state == WebAudioState.recording) {
      debugPrint('Already recording');
      return true;
    }

    try {
      _state = WebAudioState.recording;
      _errorMessage = '';
      
      debugPrint('🎤 Starting audio recording...');
      
      // Start recording in webm format for web compatibility
      await _audioRecorder.start(
        const RecordConfig(
          encoder: AudioEncoder.wav,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: 'recording.wav',
      );
      
      debugPrint('Audio recording started successfully');
      return true;
    } catch (e) {
      debugPrint('Failed to start recording: $e');
      _errorMessage = AppConstants.audioRecordingFailed;
      _state = WebAudioState.error;
      return false;
    }
  }

  Future<String?> stopRecording() async {
    if (_state != WebAudioState.recording) {
      debugPrint('Not currently recording');
      return null;
    }

    try {
      debugPrint('⏹️ Stopping audio recording...');
      
      // Stop recording and get the audio data
      final String? filePath = await _audioRecorder.stop();
      
      if (filePath == null) {
        throw Exception('Failed to get audio file path');
      }
      
      debugPrint('Audio recording stopped: $filePath');
      _state = WebAudioState.idle;
      return filePath;
    } catch (e) {
      debugPrint('Failed to stop recording: $e');
      _errorMessage = AppConstants.audioTranscriptionFailed;
      _state = WebAudioState.error;
      return null;
    }
  }

  Future<String?> uploadAndTranscribeAudio(String audioFilePath) async {
    if (_state == WebAudioState.uploading || _state == WebAudioState.processing) {
      debugPrint('Already processing audio');
      return null;
    }

    try {
      _state = WebAudioState.uploading;
      _errorMessage = '';
      
      debugPrint('⬆ Uploading audio file...');
      
      // Read the audio file
      final File audioFile = File(audioFilePath);
      if (!await audioFile.exists()) {
        throw Exception('Audio file not found: $audioFilePath');
      }
      
      final Uint8List audioBytes = await audioFile.readAsBytes();
      
      // Create multipart request
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiConfig.getEndpointUrl(ApiConfig.voiceTranscribeEndpoint)),
      );
      
      // Add audio file
      request.files.add(
        http.MultipartFile.fromBytes(
          'audio',
          audioBytes,
          filename: 'recording.webm',
        ),
      );
      
      // Add headers
      request.headers.addAll({
        'Content-Type': 'multipart/form-data',
      });
      
      _state = WebAudioState.processing;
      debugPrint('🧠 Processing speech with Whisper...');
      
      // Send request
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
      );
      
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final String transcribedText = data['transcript'] ?? '';
        
        debugPrint('✍ Transcription completed: $transcribedText');
        
        // Clean up temporary file
        try {
          await audioFile.delete();
          debugPrint('Temporary audio file deleted');
        } catch (e) {
          debugPrint('Warning: Failed to delete temp file: $e');
        }
        
        _state = WebAudioState.completed;
        return transcribedText.isNotEmpty ? transcribedText : null;
      } else {
        throw Exception('Server error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('Failed to upload and transcribe audio: $e');
      _errorMessage = AppConstants.audioTranscriptionFailed;
      _state = WebAudioState.error;
      return null;
    }
  }

  Future<String?> recordAndTranscribe() async {
    try {
      // Start recording
      if (!await startRecording()) {
        return null;
      }
      
      // Wait for user to stop recording (this should be handled by UI)
      // For now, we'll record for a fixed duration
      await Future.delayed(const Duration(seconds: 5));
      
      // Stop recording
      final String? audioFilePath = await stopRecording();
      if (audioFilePath == null) {
        return null;
      }
      
      // Upload and transcribe
      return await uploadAndTranscribeAudio(audioFilePath);
    } catch (e) {
      debugPrint('Record and transcribe failed: $e');
      _errorMessage = AppConstants.audioTranscriptionFailed;
      _state = WebAudioState.error;
      return null;
    }
  }

  void reset() {
    _state = WebAudioState.idle;
    _errorMessage = '';
  }

  String getStatusMessage() {
    switch (_state) {
      case WebAudioState.idle:
        return 'Ready to record';
      case WebAudioState.recording:
        return '🎤 Recording...';
      case WebAudioState.uploading:
        return '⬆ Uploading audio...';
      case WebAudioState.processing:
        return '🧠 Understanding speech...';
      case WebAudioState.completed:
        return '✅ Recording completed';
      case WebAudioState.error:
        return '❌ $_errorMessage';
    }
  }

  void dispose() {
    if (_state == WebAudioState.recording) {
      _audioRecorder.stop();
    }
    _audioRecorder.dispose();
  }
}
