import 'package:flutter/foundation.dart';
// Conditional imports for web vs mobile
import 'package:flutter_tts/flutter_tts.dart' if (dart.library.io) 'mobile_stub.dart';

// Import js for web interop
import 'dart:js' as js;

class PronunciationService {
  static final PronunciationService _instance = PronunciationService._internal();
  factory PronunciationService() => _instance;
  PronunciationService._internal();

  dynamic _flutterTts;
  bool _isInitialized = false;
  bool _isSpeaking = false;
  String? _currentlySpeaking;

  // Callbacks for state management
  Function()? onStart;
  Function()? onComplete;
  Function(String)? onError;

  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      if (kIsWeb) {
        // Web: Initialize JavaScript Web Speech API
        await _initializeWebSpeech();
        _isInitialized = true;
        return true;
      } else {
        // Mobile: Use Flutter TTS
        _flutterTts = FlutterTts();
        
        // Configure TTS settings for natural English voice
        await _flutterTts!.setLanguage("en-US");
        await _flutterTts!.setPitch(1.0);
        await _flutterTts!.setSpeechRate(0.8); // Slightly slower for learning
        await _flutterTts!.setVolume(1.0);
        
        // Set up completion handler
        _flutterTts!.setCompletionHandler(() {
          _isSpeaking = false;
          _currentlySpeaking = null;
          onComplete?.call();
        });

        // Set up error handler
        _flutterTts!.setErrorHandler((msg) {
          _isSpeaking = false;
          _currentlySpeaking = null;
          onError?.call(msg);
          debugPrint('TTS Error: $msg');
        });

        // Set up start handler
        _flutterTts!.setStartHandler(() {
          _isSpeaking = true;
          onStart?.call();
        });

        _isInitialized = true;
        return true;
      }
    } catch (e) {
      debugPrint('Failed to initialize TTS: $e');
      onError?.call('Failed to initialize pronunciation service');
      return false;
    }
  }

  Future<void> _initializeWebSpeech() async {
    if (kIsWeb) {
      try {
        // Initialize Web Speech API using your JavaScript code
        js.context.callMethod('eval', ['''
          if (!window.speechSynthesis) {
            console.error("Speech synthesis not supported");
          }
          
          window.speakText = function(text) {
            if (!window.speechSynthesis) {
              console.error("Speech not supported");
              return false;
            }

            window.speechSynthesis.cancel();

            const speech = new SpeechSynthesisUtterance(text);

            speech.lang = "en-US";
            speech.rate = 0.9;
            speech.pitch = 1;

            const voices = window.speechSynthesis.getVoices();

            if (voices.length > 0) {
              speech.voice = voices.find(v => v.lang.includes("en")) || voices[0];
            }

            speech.onerror = function(e) {
              console.error("Pronunciation error:", e);
            };

            speech.onstart = function() {
              if (window.flutterPronunciationStart) {
                window.flutterPronunciationStart();
              }
            };

            speech.onend = function() {
              if (window.flutterPronunciationComplete) {
                window.flutterPronunciationComplete();
              }
            };

            window.speechSynthesis.speak(speech);
            return true;
          };
          
          window.stopSpeech = function() {
            if (window.speechSynthesis) {
              window.speechSynthesis.cancel();
              return true;
            }
            return false;
          };
        ''']);

        // Set up JavaScript callbacks for Flutter
        js.context['flutterPronunciationStart'] = () {
          _isSpeaking = true;
          onStart?.call();
        };

        js.context['flutterPronunciationComplete'] = () {
          _isSpeaking = false;
          _currentlySpeaking = null;
          onComplete?.call();
        };
      } catch (e) {
        debugPrint('Failed to initialize web speech: $e');
        onError?.call('Failed to initialize web speech');
      }
    }
  }

  Future<void> speak(String text) async {
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) {
        onError?.call('Pronunciation service not available');
        return;
      }
    }

    try {
      // Stop any current speech
      if (_isSpeaking) {
        await stop();
      }

      _currentlySpeaking = text;
      
      // Clean the text for better pronunciation
      final cleanText = _cleanText(text);
      
      if (kIsWeb) {
        // Web: Use direct JavaScript call
        final success = js.context.callMethod('speakText', [cleanText]);
        if (success) {
          _isSpeaking = true;
          onStart?.call();
        } else {
          onError?.call('Failed to speak text');
        }
      } else {
        // Mobile: Use Flutter TTS
        await _flutterTts!.speak(cleanText);
      }
    } catch (e) {
      debugPrint('Failed to speak text: $e');
      onError?.call('Failed to play pronunciation');
    }
  }

  Future<void> stop() async {
    if (kIsWeb) {
      // Web: Use direct JavaScript call
      try {
        js.context.callMethod('stopSpeech');
        _isSpeaking = false;
        _currentlySpeaking = null;
      } catch (e) {
        debugPrint('Failed to stop web speech: $e');
      }
    } else {
      // Mobile: Use Flutter TTS to stop speech
      if (_flutterTts != null && _isSpeaking) {
        try {
          await _flutterTts!.stop();
          _isSpeaking = false;
          _currentlySpeaking = null;
        } catch (e) {
          debugPrint('Failed to stop speech: $e');
        }
      }
    }
  }

  Future<void> pause() async {
    if (kIsWeb) {
      // Web: Pause functionality (not commonly used but included for completeness)
      try {
        js.context.callMethod('eval', ['if (window.speechSynthesis) window.speechSynthesis.pause();']);
      } catch (e) {
        debugPrint('Failed to pause web speech: $e');
      }
    } else {
      // Mobile: Use Flutter TTS to pause speech
      if (_flutterTts != null && _isSpeaking) {
        try {
          await _flutterTts!.pause();
        } catch (e) {
          debugPrint('Failed to pause speech: $e');
        }
      }
    }
  }

  // Clean text for better pronunciation
  String _cleanText(String text) {
    // Remove checkmarks and other icons
    String cleanText = text.replaceAll('✅', '');
    cleanText = cleanText.replaceAll('💡', '');
    cleanText = cleanText.replaceAll('🔊', '');
    
    // Trim extra whitespace
    cleanText = cleanText.trim();
    
    return cleanText;
  }

  // Getters for state management
  bool get isInitialized => _isInitialized;
  bool get isSpeaking => _isSpeaking;
  String? get currentlySpeaking => _currentlySpeaking;

  // Dispose method
  void dispose() {
    if (kIsWeb) {
      // Web: Cancel any ongoing speech
      try {
        js.context.callMethod('stopSpeech');
      } catch (e) {
        debugPrint('Failed to dispose web speech: $e');
      }
    } else {
      // Mobile: Dispose Flutter TTS
      if (_flutterTts != null) {
        _flutterTts!.stop();
        _flutterTts = null;
      }
    }
    _isInitialized = false;
    _isSpeaking = false;
    _currentlySpeaking = null;
  }
}
