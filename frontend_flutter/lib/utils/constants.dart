import 'dart:io';

class AppConstants {
  // API Configuration - Platform specific
  static String get baseUrl {
    if (Platform.isAndroid) {
      // For Android emulator
      return 'http://10.0.2.2:8000';
    } else if (Platform.isIOS) {
      // For iOS simulator
      return 'http://localhost:8000';
    } else {
      // For desktop/web
      return 'http://localhost:8000';
    }
  }
  static const String endPoint = '/api/correct';
  
  // App Settings
  static const String appName = 'English Buddy';
  static const String appVersion = '1.0.0';
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double borderRadius = 20.0;
  static const double messageSpacing = 12.0;
  static const double bubbleRadius = 18.0;
  
  // Animation Durations
  static const int animationDurationMs = 300;
  static const int typingAnimationDurationMs = 1500;
  
  // Storage Keys
  static const String userSettingsKey = 'user_settings';
  static const String conversationHistoryKey = 'conversation_history';
  
  // Error Messages
  static const String networkErrorMessage = 'Network error. Please check your connection.';
  static const String serverErrorMessage = 'Server error. Please try again later.';
  static const String genericErrorMessage = 'Something went wrong. Please try again.';
  
  // Voice Error Messages
  static const String webVoiceUnavailable = 'Voice transcription temporarily unavailable. Please try typing or retry recording.';
  static const String mobileVoiceUnavailable = 'Voice recognition unavailable. Please check microphone permission.';
  static const String serverBusy = 'Server is processing audio. Please wait a moment.';
  static const String microphonePermissionDenied = 'Microphone permission denied. Please enable microphone access in settings.';
  static const String audioRecordingFailed = 'Failed to start recording. Please check microphone permissions.';
  static const String audioTranscriptionFailed = 'Voice transcription failed. Please try again.';
  static const String audioFileTooLarge = 'Audio file too large. Please keep recordings under 25 seconds.';
}

class AppStrings {
  // App Bar Titles
  static const String homeTitle = 'English Buddy';
  static const String chatTitle = 'English Buddy';
  
  // Home Screen
  static const String welcomeMessage = 'Welcome to English Buddy! 🌟';
  static const String selectMode = 'Choose your learning style';
  static const String correctionMode = 'Grammar Help';
  static const String conversationMode = 'Chat Practice';
  static const String startLearning = 'Start Learning';
  
  // Chat Screen
  static const String typeMessage = 'Type a message...';
  static const String voiceInput = 'Voice Input';
  static const String send = 'Send';
  static const String listening = 'Listening... 🎤';
  static const String processing = 'Thinking... 🤔';
  
  // Settings
  static const String settings = 'Settings';
  static const String selectLanguage = 'Preferred Language';
  static const String englishLevel = 'English Level';
  static const String learningGoal = 'Learning Goal';
  
  // Language Options
  static const String english = 'English';
  static const String kannada = 'Kannada';
  static const String kanglish = 'Kanglish';
  
  // Level Options
  static const String beginner = 'Beginner';
  static const String intermediate = 'Intermediate';
  static const String advanced = 'Advanced';
  
  // Goal Options
  static const String dailyConversation = 'Daily Conversation';
  static const String interviewPrep = 'Interview Preparation';
  static const String generalImprovement = 'General Improvement';
}
