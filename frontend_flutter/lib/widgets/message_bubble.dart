import 'package:flutter/material.dart';
import '../models/message_model.dart';
import '../utils/constants.dart';
import '../utils/app_colors.dart';
import '../services/pronunciation_service.dart';

class MessageBubble extends StatefulWidget {
  final MessageModel message;

  const MessageBubble({
    super.key,
    required this.message,
  });

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  final PronunciationService _pronunciationService = PronunciationService();
  bool _isSpeaking = false;
  bool _isHighlighted = false;

  @override
  void initState() {
    super.initState();
    _setupPronunciationCallbacks();
  }

  void _setupPronunciationCallbacks() {
    _pronunciationService.onStart = () {
      if (mounted) {
        setState(() {
          _isSpeaking = true;
          _isHighlighted = true;
        });
      }
    };

    _pronunciationService.onComplete = () {
      if (mounted) {
        setState(() {
          _isSpeaking = false;
          _isHighlighted = false;
        });
      }
    };

    _pronunciationService.onError = (error) {
      if (mounted) {
        setState(() {
          _isSpeaking = false;
          _isHighlighted = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pronunciation error: $error'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    };
  }

  void _playPronunciation(String text) {
    if (_isSpeaking && _pronunciationService.currentlySpeaking == text) {
      // Stop if currently speaking the same text
      _pronunciationService.stop();
    } else {
      // Speak the text
      _pronunciationService.speak(text);
    }
  }

  @override
  void dispose() {
    _pronunciationService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
        vertical: AppConstants.messageSpacing,
      ),
      child: Column(
        crossAxisAlignment: widget.message.isUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: widget.message.isUser
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            children: [
              if (!widget.message.isUser) ...[
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.accentGreen,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadowColor,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.smart_toy,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  decoration: BoxDecoration(
                    color: widget.message.isUser
                        ? AppColors.userBubble
                        : AppColors.aiBubble,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(AppConstants.bubbleRadius),
                      topRight: Radius.circular(AppConstants.bubbleRadius),
                      bottomLeft: widget.message.isUser 
                          ? Radius.circular(AppConstants.bubbleRadius)
                          : Radius.circular(4),
                      bottomRight: widget.message.isUser
                          ? Radius.circular(4)
                          : Radius.circular(AppConstants.bubbleRadius),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadowColor,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.message.text,
                          style: TextStyle(
                            color: AppColors.primaryText,
                            fontSize: 16,
                            height: 1.4,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (widget.message.correctedSentence != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.correctionCard,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.correctionBorder,
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle_outline,
                                      size: 16,
                                      color: AppColors.accentGreen,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () => _playPronunciation(widget.message.correctedSentence!),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(8),
                                            color: _isHighlighted 
                                                ? AppColors.accentGreen.withValues(alpha: 0.1)
                                                : Colors.transparent,
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.volume_up,
                                                size: 16,
                                                color: _isSpeaking 
                                                    ? AppColors.accentGreen
                                                    : AppColors.primaryGreen,
                                              ),
                                              const SizedBox(width: 6),
                                              Expanded(
                                                child: Text(
                                                  '✅ ${widget.message.correctedSentence!}',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color: _isHighlighted 
                                                        ? AppColors.accentGreen
                                                        : AppColors.primaryText,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (widget.message.shortExplanation != null) ...[
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.lightbulb_outline,
                                        size: 14,
                                        color: AppColors.explanationText,
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          widget.message.shortExplanation!,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: AppColors.explanationText,
                                            height: 1.3,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                        if (widget.message.motivation != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.emoji_events,
                                size: 14,
                                color: AppColors.motivationText,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  widget.message.motivation!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.motivationText,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              if (widget.message.isUser) ...[
                const SizedBox(width: 8),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadowColor,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 2),
          Padding(
            padding: EdgeInsets.only(
              left: widget.message.isUser ? 0 : 40,
              right: widget.message.isUser ? 40 : 0,
            ),
            child: Text(
              _formatTime(widget.message.timestamp),
              style: TextStyle(
                fontSize: 11,
                color: AppColors.secondaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}

