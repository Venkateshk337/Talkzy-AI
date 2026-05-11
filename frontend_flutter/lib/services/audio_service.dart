import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'web_audio_service.dart';
import '../utils/constants.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();

  factory AudioService() => _instance;

  AudioService._internal();

  final SpeechToText _speechToText = SpeechToText();
  final AudioRecorder _audioRecorder = AudioRecorder();
  final WebAudioService _webAudioService = WebAudioService();

  bool _isInitialized = false;
  bool _isListening = false;

  bool get isInitialized => _isInitialized;
  bool get isListening => _isListening;

  Future<bool> initialize() async {
    if (_isInitialized) {
      return true;
    }

    try {
      debugPrint('Initializing audio service...');

      // Request microphone permission
      final hasPermission = await _requestMicrophonePermission();

      if (!hasPermission) {
        debugPrint('Microphone permission not granted');
        return false;
      }

      // Initialize speech recognition
      bool available = await _speechToText.initialize(
        onStatus: (status) {
          debugPrint('Speech status: $status');
        },
        onError: (error) {
          debugPrint('Speech error: $error');
        },
      );

      debugPrint('Speech to text available: $available');

      if (available && !kIsWeb) {
        try {
          final locales = await _speechToText.locales();

          debugPrint(
            'Available locales: ${locales.map((e) => e.localeId).toList()}',
          );

          if (locales.isNotEmpty) {
            String preferredLocale = 'en_US';

            if (!locales.any(
              (locale) => locale.localeId == preferredLocale,
            )) {
              final englishLocale = locales.firstWhere(
                (locale) => locale.localeId.startsWith('en'),
                orElse: () => locales.first,
              );

              preferredLocale = englishLocale.localeId;

              debugPrint(
                'Using fallback locale: $preferredLocale',
              );
            } else {
              debugPrint(
                'Preferred locale available: $preferredLocale',
              );
            }
          }
        } catch (e) {
          debugPrint('Error getting locales: $e');
        }
      }

      _isInitialized = available;

      debugPrint(
        'Audio service initialization completed: $_isInitialized',
      );

      return _isInitialized;
    } catch (e, stackTrace) {
      debugPrint(
        'Failed to initialize audio service: $e',
      );

      debugPrint(
        'Error type: ${e.runtimeType}',
      );

      debugPrint(
        'Stack trace: $stackTrace',
      );

      return false;
    }
  }

  Future<bool> _requestMicrophonePermission() async {
    try {
      final status = await Permission.microphone.request();

      return status.isGranted;
    } catch (e) {
      debugPrint(
        'Error requesting microphone permission: $e',
      );

      return false;
    }
  }

  Future<bool> startListening({
    required Function(String) onResult,
    required Function(String) onError,
    Duration? listenFor,
    Duration? pauseFor,
  }) async {
    if (!_isInitialized) {
      onError('Audio service not initialized');
      return false;
    }

    if (_isListening) {
      return true;
    }

    try {
      debugPrint('=== Starting Hybrid Speech Recognition ===');

      // HYBRID APPROACH: Use different strategies based on platform
      if (kIsWeb) {
        debugPrint('Running on Flutter Web - Using Whisper upload approach');
        return await _startWebListening(onResult, onError);
      } else {
        debugPrint('Running on Mobile - Using local speech_to_text');
        return await _startMobileListening(onResult, onError, listenFor, pauseFor);
      }
    } catch (e, stackTrace) {
      debugPrint(
        'Speech recognition exception: $e',
      );

      debugPrint(
        'Stack trace: $stackTrace',
      );

      _isListening = false;

      onError(
        'Failed to start voice input.',
      );

      return false;
    }
  }

  Future<bool> _startWebListening(
    Function(String) onResult,
    Function(String) onError,
  ) async {
    try {
      // Initialize web audio service
      bool webInitialized = await _webAudioService.initialize();
      if (!webInitialized) {
        onError(AppConstants.webVoiceUnavailable);
        return false;
      }

      // Start recording
      bool recordingStarted = await _webAudioService.startRecording();
      if (!recordingStarted) {
        onError(AppConstants.audioRecordingFailed);
        return false;
      }

      _isListening = true;

      // For web, we'll simulate the recording process
      // In a real implementation, the UI should handle stopping the recording
      Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!_isListening) {
          timer.cancel();
          return;
        }
        
        // Show status updates
        debugPrint(_webAudioService.getStatusMessage());
      });

      debugPrint('Web audio recording started successfully');
      return true;
    } catch (e) {
      debugPrint('Web listening failed: $e');
      onError(AppConstants.webVoiceUnavailable);
      return false;
    }
  }

  Future<bool> _startMobileListening(
    Function(String) onResult,
    Function(String) onError,
    Duration? listenFor,
    Duration? pauseFor,
  ) async {
    try {
      String localeId = 'en_US';

      // MOBILE LOCALE HANDLING
      try {
        final locales = await _speechToText.locales();

        debugPrint(
          'Available locales count: ${locales.length}',
        );

        if (locales.isNotEmpty) {
          if (!locales.any(
            (locale) => locale.localeId == localeId,
          )) {
            final englishLocale = locales.firstWhere(
              (locale) => locale.localeId.startsWith('en'),
              orElse: () => locales.first,
            );

            localeId = englishLocale.localeId;

            debugPrint(
              'Using fallback locale: $localeId',
            );
          } else {
            debugPrint(
              'Using preferred locale: $localeId',
            );
          }
        }
      } catch (e) {
        debugPrint(
          'Locale detection failed: $e',
        );
      }

      _isListening = false;

      final listenResult = await _speechToText.listen(
        onResult: (result) {
          debugPrint(
            'Speech result: ${result.recognizedWords}',
          );

          if (result.recognizedWords.isNotEmpty) {
            onResult(result.recognizedWords);
          }
        },
        listenFor: listenFor ?? const Duration(seconds: 30),
        pauseFor: pauseFor ?? const Duration(seconds: 3),
        localeId: localeId,
        listenOptions: SpeechListenOptions(
          partialResults: true,
          cancelOnError: false,
          listenMode: ListenMode.dictation,
          autoPunctuation: true,
        ),
        onSoundLevelChange: (level) {
          if (level > 0) {
            debugPrint('Sound level: $level');
          }
        },
      );

      _isListening = listenResult ?? false;

      debugPrint(
        'Mobile speech recognition started: $_isListening',
      );

      return _isListening;
    } catch (e) {
      debugPrint('Mobile listening failed: $e');
      onError(AppConstants.mobileVoiceUnavailable);
      return false;
    }
  }

  Future<void> stopListening() async {
    if (_isListening) {
      try {
        if (kIsWeb) {
          // Handle web audio recording stop
          final String? audioFilePath = await _webAudioService.stopRecording();
          if (audioFilePath != null) {
            debugPrint('Web audio recording stopped: $audioFilePath');
            // Note: In a real implementation, you would upload and transcribe here
            // For now, we just stop the recording
          }
        } else {
          // Handle mobile speech recognition stop
          await _speechToText.stop();
        }

        _isListening = false;

        debugPrint('Speech recognition stopped');
      } catch (e) {
        debugPrint(
          'Error stopping speech recognition: $e',
        );
      }
    }
  }

  Future<void> cancelListening() async {
    if (_isListening) {
      try {
        await _speechToText.cancel();

        _isListening = false;

        debugPrint('Speech recognition canceled');
      } catch (e) {
        debugPrint(
          'Error canceling speech recognition: $e',
        );
      }
    }
  }

  Future<Map<String, dynamic>> getSpeechRecognitionStatus() async {
    try {
      return {
        'available': _speechToText.isAvailable,
        'initialized': _isInitialized,
        'listening': _isListening,
        'hasMicrophonePermission':
            await Permission.microphone.isGranted,
      };
    } catch (e) {
      debugPrint(
        'Error getting speech recognition status: $e',
      );

      return {
        'available': false,
        'initialized': _isInitialized,
        'listening': _isListening,
        'error': e.toString(),
      };
    }
  }

  Future<bool> setLanguage(String languageCode) async {
    try {
      if (kIsWeb) {
        debugPrint(
          'Language switching limited on Flutter Web',
        );

        return true;
      }

      final locales = await _speechToText.locales();

      final targetLocale = locales.firstWhere(
        (locale) => locale.localeId.startsWith(languageCode),
        orElse: () => locales.firstWhere(
          (locale) => locale.localeId.startsWith('en'),
          orElse: () => locales.first,
        ),
      );

      debugPrint(
        'Setting language to: ${targetLocale.localeId}',
      );

      return true;
    } catch (e) {
      debugPrint(
        'Error setting language: $e',
      );

      return false;
    }
  }

  Future<String?> transcribeWebAudio() async {
    if (!kIsWeb) {
      debugPrint('transcribeWebAudio should only be called on web platform');
      return null;
    }

    try {
      // Get the audio file path from web audio service
      // Note: This would need to be implemented properly in a real app
      // For now, we'll use the recordAndTranscribe method
      return await _webAudioService.recordAndTranscribe();
    } catch (e) {
      debugPrint('Web audio transcription failed: $e');
      return null;
    }
  }

  void dispose() {
    _speechToText.stop();
    _audioRecorder.dispose();
    _webAudioService.dispose();
  }
}