// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MessageModel _$MessageModelFromJson(Map<String, dynamic> json) => MessageModel(
  id: json['id'] as String,
  text: json['text'] as String,
  isUser: json['isUser'] as bool,
  timestamp: DateTime.parse(json['timestamp'] as String),
  correctedSentence: json['correctedSentence'] as String?,
  shortExplanation: json['shortExplanation'] as String?,
  motivation: json['motivation'] as String?,
  confidence: (json['confidence'] as num?)?.toDouble(),
  languageDetected: json['languageDetected'] as String?,
  mode: json['mode'] as String?,
);

Map<String, dynamic> _$MessageModelToJson(MessageModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'text': instance.text,
      'isUser': instance.isUser,
      'timestamp': instance.timestamp.toIso8601String(),
      'correctedSentence': instance.correctedSentence,
      'shortExplanation': instance.shortExplanation,
      'motivation': instance.motivation,
      'confidence': instance.confidence,
      'languageDetected': instance.languageDetected,
      'mode': instance.mode,
    };

AIResponse _$AIResponseFromJson(Map<String, dynamic> json) => AIResponse(
  mode: json['mode'] as String,
  originalText: json['original_text'] as String,
  languageDetected: json['language_detected'] as String,
  correctedSentence: json['corrected_sentence'] as String,
  shortExplanation: json['short_explanation'] as String,
  motivation: json['motivation'] as String,
  confidence: (json['confidence'] as num).toDouble(),
  tone: json['tone'] as String,
  assistantReply: json['assistant_reply'] as String?,
);

Map<String, dynamic> _$AIResponseToJson(AIResponse instance) =>
    <String, dynamic>{
      'mode': instance.mode,
      'original_text': instance.originalText,
      'language_detected': instance.languageDetected,
      'corrected_sentence': instance.correctedSentence,
      'short_explanation': instance.shortExplanation,
      'motivation': instance.motivation,
      'confidence': instance.confidence,
      'tone': instance.tone,
      'assistant_reply': instance.assistantReply,
    };

UserSettings _$UserSettingsFromJson(Map<String, dynamic> json) => UserSettings(
  preferredLanguage: $enumDecode(_$LanguageEnumMap, json['preferredLanguage']),
  currentMode: $enumDecode(_$AppModeEnumMap, json['currentMode']),
  englishLevel: json['englishLevel'] as String,
  learningGoal: json['learningGoal'] as String,
);

Map<String, dynamic> _$UserSettingsToJson(UserSettings instance) =>
    <String, dynamic>{
      'preferredLanguage': _$LanguageEnumMap[instance.preferredLanguage]!,
      'currentMode': _$AppModeEnumMap[instance.currentMode]!,
      'englishLevel': instance.englishLevel,
      'learningGoal': instance.learningGoal,
    };

const _$LanguageEnumMap = {
  Language.english: 'english',
  Language.kannada: 'kannada',
  Language.kanglish: 'kanglish',
};

const _$AppModeEnumMap = {
  AppMode.correction: 'correction',
  AppMode.conversation: 'conversation',
};
