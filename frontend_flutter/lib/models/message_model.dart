import 'package:json_annotation/json_annotation.dart';

part 'message_model.g.dart';

@JsonSerializable()
class MessageModel {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? correctedSentence;
  final String? shortExplanation;
  final String? motivation;
  final double? confidence;
  final String? languageDetected;
  final String? mode;

  MessageModel({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.correctedSentence,
    this.shortExplanation,
    this.motivation,
    this.confidence,
    this.languageDetected,
    this.mode,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) =>
      _$MessageModelFromJson(json);

  Map<String, dynamic> toJson() => _$MessageModelToJson(this);

  MessageModel copyWith({
    String? id,
    String? text,
    bool? isUser,
    DateTime? timestamp,
    String? correctedSentence,
    String? shortExplanation,
    String? motivation,
    double? confidence,
    String? languageDetected,
    String? mode,
  }) {
    return MessageModel(
      id: id ?? this.id,
      text: text ?? this.text,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      correctedSentence: correctedSentence ?? this.correctedSentence,
      shortExplanation: shortExplanation ?? this.shortExplanation,
      motivation: motivation ?? this.motivation,
      confidence: confidence ?? this.confidence,
      languageDetected: languageDetected ?? this.languageDetected,
      mode: mode ?? this.mode,
    );
  }
}

@JsonSerializable()
class AIResponse {
  @JsonKey(name: 'mode')
  final String mode;
  @JsonKey(name: 'original_text')
  final String originalText;
  @JsonKey(name: 'language_detected')
  final String languageDetected;
  @JsonKey(name: 'corrected_sentence')
  final String correctedSentence;
  @JsonKey(name: 'short_explanation')
  final String shortExplanation;
  @JsonKey(name: 'motivation')
  final String motivation;
  @JsonKey(name: 'confidence')
  final double confidence;
  @JsonKey(name: 'tone')
  final String tone;
  @JsonKey(name: 'assistant_reply')
  final String? assistantReply;

  AIResponse({
    required this.mode,
    required this.originalText,
    required this.languageDetected,
    required this.correctedSentence,
    required this.shortExplanation,
    required this.motivation,
    required this.confidence,
    required this.tone,
    this.assistantReply,
  });

  factory AIResponse.fromJson(Map<String, dynamic> json) =>
      _$AIResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AIResponseToJson(this);
}

enum AppMode {
  correction,
  conversation,
}

enum Language {
  english,
  kannada,
  kanglish,
}

@JsonSerializable()
class UserSettings {
  final Language preferredLanguage;
  final AppMode currentMode;
  final String englishLevel;
  final String learningGoal;

  UserSettings({
    required this.preferredLanguage,
    required this.currentMode,
    required this.englishLevel,
    required this.learningGoal,
  });

  factory UserSettings.fromJson(Map<String, dynamic> json) =>
      _$UserSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$UserSettingsToJson(this);

  UserSettings copyWith({
    Language? preferredLanguage,
    AppMode? currentMode,
    String? englishLevel,
    String? learningGoal,
  }) {
    return UserSettings(
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      currentMode: currentMode ?? this.currentMode,
      englishLevel: englishLevel ?? this.englishLevel,
      learningGoal: learningGoal ?? this.learningGoal,
    );
  }
}
