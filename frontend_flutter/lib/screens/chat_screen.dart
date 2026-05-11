import 'package:flutter/material.dart';
import 'dart:async';
import '../models/message_model.dart';
import '../services/api_service.dart';
import '../services/audio_service.dart';
import '../services/voice_input_service.dart';
import '../widgets/message_bubble.dart';
import '../widgets/input_field.dart';
import '../widgets/typing_indicator.dart';
import '../utils/constants.dart';
import '../utils/app_colors.dart';

class ChatScreen extends StatefulWidget {
  final UserSettings userSettings;

  const ChatScreen({
    super.key,
    required this.userSettings,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<MessageModel> _messages = [];
  final ApiService _apiService = ApiService();
  final AudioService _audioService = AudioService();
  final VoiceInputService _voiceInputService = VoiceInputService();
  
  bool _isLoading = false;
  bool _isListening = false;
  bool _isInitialized = false;

  // Initialize voice input service callbacks
  @override
  void initState() {
    super.initState();
    _initializeAudioService();
    _addWelcomeMessage();
    _initializeVoiceInputCallbacks();
  }

  void _initializeVoiceInputCallbacks() {
    _voiceInputService.onResult = (String transcript) {
      _textController.text = transcript;
      _textController.selection = TextSelection.fromPosition(
        TextPosition(offset: transcript.length),
      );
    };
    
    _voiceInputService.onListeningStateChanged = (bool isListening) {
      if (mounted) {
        setState(() {
          _isListening = isListening;
        });
      }
    };
    
    _voiceInputService.onError = (String error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Voice input: $error'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    };
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _audioService.dispose();
    _voiceInputService.dispose();
    super.dispose();
  }

  Future<void> _initializeAudioService() async {
    final isInitialized = await _audioService.initialize();
    final voiceSupported = await _voiceInputService.isSupported();
    
    setState(() {
      _isInitialized = isInitialized && voiceSupported;
    });
  }

  void _addWelcomeMessage() {
    final welcomeMessage = MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: AppStrings.welcomeMessage,
      isUser: false,
      timestamp: DateTime.now(),
    );
    
    setState(() {
      _messages.add(welcomeMessage);
    });
  }

  Future<void> _handleSendMessage() async {
    if (_textController.text.trim().isEmpty || _isLoading) return;

    final message = MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: _textController.text.trim(),
      isUser: true,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(message);
      _isLoading = true;
    });

    _textController.clear();

    try {
      final response = await _apiService.correctEnglish(
        message.text,
        userLanguage: widget.userSettings.preferredLanguage.name,
        englishLevel: widget.userSettings.englishLevel,
        learningGoal: widget.userSettings.learningGoal,
        mode: widget.userSettings.currentMode.name,
      );

      final aiMessage = MessageModel(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        text: response.assistantReply ?? response.correctedSentence,
        isUser: false,
        timestamp: DateTime.now(),
        correctedSentence: response.correctedSentence,
        shortExplanation: response.shortExplanation,
        motivation: response.motivation,
      );

      setState(() {
        _messages.add(aiMessage);
        _isLoading = false;
      });

      _scrollToBottom();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send message: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleVoiceInput() async {
    if (!_isInitialized || _isListening) return;

    try {
      await _voiceInputService.startListening();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to start voice input: $e'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    }
  }

  Future<void> _handleStopListening() async {
    try {
      await _voiceInputService.stopListening();
    } catch (e) {
      debugPrint('Error stopping voice input: $e');
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        elevation: 0,
        titleSpacing: 0,
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              margin: const EdgeInsets.only(right: 12),
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
            Text(
              AppConstants.appName,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        centerTitle: false,
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Colors.white),
            onSelected: (String value) {
              if (value == 'clear') {
                setState(() {
                  _messages.clear();
                });
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  value: 'clear',
                  child: Row(
                    children: [
                      Icon(Icons.clear_all, color: AppColors.primaryText),
                      const SizedBox(width: 8),
                      Text('Clear Chat', style: TextStyle(color: AppColors.primaryText)),
                    ],
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return MessageBubble(
                  message: message,
                );
              },
            ),
          ),
          if (_isLoading) ...[
            Container(
              padding: const EdgeInsets.all(16),
              child: const TypingIndicator(),
            ),
          ],
          ChatInputField(
            controller: _textController,
            onSend: _handleSendMessage,
            onVoiceInput: _isInitialized ? _handleVoiceInput : null,
            onStopListening: _isListening ? _handleStopListening : null,
            isLoading: _isLoading,
            isListening: _isListening,
          ),
        ],
      ),
    );
  }
}
