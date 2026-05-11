import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/message_model.dart';
import '../utils/constants.dart';
import '../utils/app_colors.dart';
import 'chat_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  UserSettings? _userSettings;

  @override
  void initState() {
    super.initState();
    _loadUserSettings();
  }

  Future<void> _loadUserSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = prefs.getString(AppConstants.userSettingsKey);
    
    if (settingsJson != null) {
      try {
        final Map<String, dynamic> jsonMap = jsonDecode(settingsJson);
        final userSettings = UserSettings.fromJson(jsonMap);
        setState(() {
          _userSettings = userSettings;
        });
      } catch (e) {
        // If parsing fails, use default settings
        setState(() {
          _userSettings = UserSettings(
            preferredLanguage: Language.kannada,
            currentMode: AppMode.correction,
            englishLevel: AppStrings.beginner,
            learningGoal: AppStrings.dailyConversation,
          );
        });
        _saveUserSettings();
      }
    } else {
      setState(() {
        _userSettings = UserSettings(
          preferredLanguage: Language.kannada,
          currentMode: AppMode.correction,
          englishLevel: AppStrings.beginner,
          learningGoal: AppStrings.dailyConversation,
        );
      });
      _saveUserSettings();
    }
  }

  Future<void> _saveUserSettings() async {
    if (_userSettings == null) return;
    
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = jsonEncode(_userSettings!.toJson());
    await prefs.setString(AppConstants.userSettingsKey, settingsJson);
  }

  void _updateLanguage(Language language) {
    if (_userSettings == null) return;
    
    setState(() {
      _userSettings = _userSettings!.copyWith(
        preferredLanguage: language,
      );
    });
    _saveUserSettings();
  }

  void _updateMode(AppMode mode) {
    if (_userSettings == null) return;
    
    setState(() {
      _userSettings = _userSettings!.copyWith(
        currentMode: mode,
      );
    });
    _saveUserSettings();
  }

  void _updateEnglishLevel(String level) {
    if (_userSettings == null) return;
    
    setState(() {
      _userSettings = _userSettings!.copyWith(
        englishLevel: level,
      );
    });
    _saveUserSettings();
  }

  void _updateLearningGoal(String goal) {
    if (_userSettings == null) return;
    
    setState(() {
      _userSettings = _userSettings!.copyWith(
        learningGoal: goal,
      );
    });
    _saveUserSettings();
  }

  void _navigateToChat() {
    if (_userSettings == null) return;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          userSettings: _userSettings!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.school,
                color: AppColors.primaryGreen,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              AppStrings.homeTitle,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      body: _userSettings == null
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryGreen,
                          AppColors.darkGreen,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadowColor,
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.auto_awesome,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                            const Spacer(),
                            Icon(
                              Icons.emoji_events,
                              color: Colors.white.withValues(alpha: 0.8),
                              size: 24,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          AppStrings.welcomeMessage,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Learn English naturally with AI assistance',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Language Selection
                  _buildModernSectionCard(
                    title: '🌍 ${AppStrings.selectLanguage}',
                    child: Column(
                      children: Language.values.map((language) {
                        return _buildModernRadioTile<Language>(
                          title: _getLanguageDisplayName(language),
                          subtitle: _getLanguageDescription(language),
                          value: language,
                          groupValue: _userSettings!.preferredLanguage,
                          onChanged: (value) {
                            if (value != null) {
                              _updateLanguage(value);
                            }
                          },
                        );
                      }).toList(),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Mode Selection
                  _buildModernSectionCard(
                    title: '🎯 ${AppStrings.selectMode}',
                    child: _buildModeSelector(),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // English Level
                  _buildModernSectionCard(
                    title: '📈 ${AppStrings.englishLevel}',
                    child: Column(
                      children: [
                        _Strings.beginner,
                        _Strings.intermediate,
                        _Strings.advanced,
                      ].map((level) {
                        return _buildModernRadioTile<String>(
                          title: level,
                          value: level,
                          groupValue: _userSettings!.englishLevel,
                          onChanged: (value) {
                            if (value != null) {
                              _updateEnglishLevel(value);
                            }
                          },
                        );
                      }).toList(),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Learning Goal
                  _buildModernSectionCard(
                    title: '🎯 ${AppStrings.learningGoal}',
                    child: Column(
                      children: [
                        AppStrings.dailyConversation,
                        AppStrings.interviewPrep,
                        AppStrings.generalImprovement,
                      ].map((goal) {
                        return _buildModernRadioTile<String>(
                          title: goal,
                          value: goal,
                          groupValue: _userSettings!.learningGoal,
                          onChanged: (value) {
                            if (value != null) {
                              _updateLearningGoal(value);
                            }
                          },
                        );
                      }).toList(),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Start Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _navigateToChat,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        backgroundColor: AppColors.accentGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                        ),
                        elevation: 4,
                        shadowColor: AppColors.shadowColor,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.rocket_launch, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            AppStrings.startLearning,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildModernSectionCard({
    required String title,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryText,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 20,
              right: 20,
              bottom: 20,
            ),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildModernRadioTile<T>({
    required String title,
    String? subtitle,
    required T value,
    required T groupValue,
    required Function(T?) onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: groupValue == value 
            ? AppColors.correctionCard 
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: groupValue == value 
              ? AppColors.correctionBorder 
              : AppColors.borderColor,
          width: groupValue == value ? 2 : 1,
        ),
      ),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(
            color: AppColors.primaryText,
            fontWeight: groupValue == value ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        subtitle: subtitle != null 
            ? Text(
                subtitle,
                style: TextStyle(
                  color: AppColors.secondaryText,
                  fontSize: 12,
                ),
              )
            : null,
        leading: Radio<T>(
          value: value,
          groupValue: groupValue,
          onChanged: onChanged,
          activeColor: AppColors.accentGreen,
          fillColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.accentGreen;
            }
            return AppColors.secondaryText;
          }),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }

  Widget _buildModeSelector() {
    return Row(
      children: [
        Expanded(
          child: _buildModeButton(
            title: AppStrings.correctionMode,
            icon: Icons.spellcheck,
            isSelected: _userSettings!.currentMode == AppMode.correction,
            onTap: () => _updateMode(AppMode.correction),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildModeButton(
            title: AppStrings.conversationMode,
            icon: Icons.chat,
            isSelected: _userSettings!.currentMode == AppMode.conversation,
            onTap: () => _updateMode(AppMode.conversation),
          ),
        ),
      ],
    );
  }

  Widget _buildModeButton({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accentGreen
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.accentGreen
                : AppColors.borderColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? Colors.white
                  : AppColors.primaryGreen,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : AppColors.primaryText,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getLanguageDisplayName(Language language) {
    switch (language) {
      case Language.english:
        return AppStrings.english;
      case Language.kannada:
        return AppStrings.kannada;
      case Language.kanglish:
        return AppStrings.kanglish;
    }
  }

  String _getLanguageDescription(Language language) {
    switch (language) {
      case Language.english:
        return 'Practice English conversation';
      case Language.kannada:
        return 'ಕನ್ನಡದಿಂದ ಇಂಗ್ಲಿಷ್ ಕಲಿಯಿರಿ';
      case Language.kanglish:
        return 'Kannada typed in English';
    }
  }
}

class _Strings {
  static const String beginner = 'Beginner';
  static const String intermediate = 'Intermediate';
  static const String advanced = 'Advanced';
}
