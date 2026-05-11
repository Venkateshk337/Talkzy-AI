import 'package:flutter/foundation.dart';
import 'dart:js' as js;

class VoiceInputService {
  static final VoiceInputService _instance = VoiceInputService._internal();
  factory VoiceInputService() => _instance;
  VoiceInputService._internal();

  bool _isListening = false;
  bool _isInitialized = false;

  // Callbacks for state management
  Function(String)? onResult;
  Function()? onStart;
  Function()? onEnd;
  Function(String)? onError;
  Function(bool)? onListeningStateChanged;

  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      if (kIsWeb) {
        await _initializeWebSpeechRecognition();
        _isInitialized = true;
        return true;
      } else {
        // Mobile: Use existing speech_to_text package
        _isInitialized = true;
        return true;
      }
    } catch (e) {
      debugPrint('Failed to initialize voice input: $e');
      onError?.call('Failed to initialize voice input');
      return false;
    }
  }

  Future<void> _initializeWebSpeechRecognition() async {
    if (kIsWeb) {
      try {
        // Initialize Web Speech Recognition API using your JavaScript code
        js.context.callMethod('eval', ['''
          // Check for browser support
          const SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition;
          
          if (!SpeechRecognition) {
            console.error("Speech recognition not supported");
            window.voiceInputSupported = false;
            return;
          }
          
          window.voiceInputSupported = true;
          
          const recognition = new SpeechRecognition();
          
          // Configure recognition
          recognition.lang = "en-US";
          recognition.continuous = false;
          recognition.interimResults = false;
          recognition.maxAlternatives = 1;
          
          // Store recognition globally
          window.voiceRecognition = recognition;
          
          // Voice input functions
          window.startVoiceInput = function() {
            if (!window.voiceRecognition) {
              console.error("Voice recognition not initialized");
              return false;
            }
            
            // Stop any previous session
            try {
              window.voiceRecognition.stop();
            } catch (e) {
              // Ignore stop errors
            }
            
            // Start new session
            window.voiceRecognition.start();
            return true;
          };
          
          window.stopVoiceInput = function() {
            if (window.voiceRecognition) {
              try {
                window.voiceRecognition.stop();
                return true;
              } catch (e) {
                console.error("Error stopping voice input:", e);
                return false;
              }
            }
            return false;
          };
          
          // Event handlers
          recognition.onresult = function(event) {
            if (event.results.length > 0) {
              const transcript = event.results[0][0].transcript;
              if (window.voiceInputResult) {
                window.voiceInputResult(transcript);
              }
            }
          };
          
          recognition.onerror = function(event) {
            console.error("Speech recognition error:", event.error);
            if (window.voiceInputError) {
              window.voiceInputError(event.error || 'Unknown error');
            }
          };
          
          recognition.onstart = function() {
            if (window.voiceInputStart) {
              window.voiceInputStart();
            }
          };
          
          recognition.onend = function() {
            if (window.voiceInputEnd) {
              window.voiceInputEnd();
            }
          };
        ''']);

        // Set up JavaScript callbacks for Flutter
        js.context['voiceInputResult'] = (String transcript) {
          onResult?.call(transcript);
        };

        js.context['voiceInputError'] = (String error) {
          _isListening = false;
          onListeningStateChanged?.call(false);
          onError?.call('Voice input error: $error');
        };

        js.context['voiceInputStart'] = () {
          _isListening = true;
          onListeningStateChanged?.call(true);
          onStart?.call();
        };

        js.context['voiceInputEnd'] = () {
          _isListening = false;
          onListeningStateChanged?.call(false);
          onEnd?.call();
        };

      } catch (e) {
        debugPrint('Failed to initialize web speech recognition: $e');
        onError?.call('Failed to initialize web speech recognition');
      }
    }
  }

  Future<bool> startListening() async {
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) {
        onError?.call('Voice input service not available');
        return false;
      }
    }

    try {
      if (_isListening) {
        await stopListening();
      }

      if (kIsWeb) {
        // Web: Use JavaScript Speech Recognition
        final success = js.context.callMethod('startVoiceInput');
        return success;
      } else {
        // Mobile: Use existing speech_to_text implementation
        // This would integrate with your existing mobile voice input
        return true;
      }
    } catch (e) {
      debugPrint('Failed to start voice input: $e');
      onError?.call('Failed to start voice input');
      return false;
    }
  }

  Future<void> stopListening() async {
    try {
      if (kIsWeb) {
        // Web: Use JavaScript to stop recognition
        js.context.callMethod('stopVoiceInput');
        _isListening = false;
        onListeningStateChanged?.call(false);
      } else {
        // Mobile: Stop existing speech recognition
        _isListening = false;
        onListeningStateChanged?.call(false);
      }
    } catch (e) {
      debugPrint('Failed to stop voice input: $e');
    }
  }

  Future<bool> isSupported() async {
    if (!kIsWeb) return true; // Mobile supports via speech_to_text
    
    try {
      final supported = js.context.callMethod('eval', ['''
        if (typeof window !== 'undefined' && 
            (window.SpeechRecognition || window.webkitSpeechRecognition)) {
          return true;
        }
        return false;
      ''']);
      return supported ?? false;
    } catch (e) {
      return false;
    }
  }

  // Getters for state management
  bool get isInitialized => _isInitialized;
  bool get isListening => _isListening;

  // Dispose method
  void dispose() {
    if (kIsWeb) {
      try {
        js.context.callMethod('stopVoiceInput');
      } catch (e) {
        debugPrint('Failed to dispose voice input: $e');
      }
    }
    _isInitialized = false;
    _isListening = false;
  }
}
