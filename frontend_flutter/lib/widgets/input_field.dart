import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/app_colors.dart';
import '../models/message_model.dart';
import '../services/voice_input_service.dart';

class ChatInputField extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback? onVoiceInput;
  final VoidCallback? onStopListening;
  final bool isLoading;
  final bool isListening;

  const ChatInputField({
    super.key,
    required this.controller,
    required this.onSend,
    this.onVoiceInput,
    this.onStopListening,
    this.isLoading = false,
    this.isListening = false,
  });

  @override
  State<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> 
    with SingleTickerProviderStateMixin {
  bool _isComposing = false;
  bool _isInitialized = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  final VoiceInputService _voiceInputService = VoiceInputService();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
    
    // Initialize pulse animation
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.15,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _pulseAnimation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _pulseController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _pulseController.forward();
      }
    });
    
    // Initialize voice input service
    _initializeVoiceInput();
  }

  Future<void> _initializeVoiceInput() async {
    await _voiceInputService.initialize();
    _isInitialized = true;
    
    _voiceInputService.onResult = (String transcript) {
      widget.controller.text = transcript;
      widget.controller.selection = TextSelection.fromPosition(
        TextPosition(offset: transcript.length),
      );
    };
    
    _voiceInputService.onListeningStateChanged = (bool isListening) {
      if (mounted) {
        setState(() {});
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
    widget.controller.removeListener(_onTextChanged);
    _pulseController.dispose();
    _voiceInputService.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _isComposing = widget.controller.text.isNotEmpty;
    });
  }

  void _handleVoiceInput() async {
    if (widget.isListening) {
      await _voiceInputService.stopListening();
      _pulseController.stop();
      _pulseController.reset();
    } else {
      final success = await _voiceInputService.startListening();
      if (success) {
        _pulseController.forward();
      }
    }
  }

  void _handleSend() {
    if (_isComposing && !widget.isLoading) {
      widget.onSend();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(
            color: AppColors.borderColor,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            if (widget.isListening) ...[
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.voiceBackground,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.voiceActive.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: AppColors.voiceActive,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.mic,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        AppStrings.listening,
                        style: TextStyle(
                          color: AppColors.voiceActive,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: widget.onStopListening,
                      icon: Icon(
                        Icons.close,
                        color: AppColors.voiceActive,
                        size: 20,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
            ],
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.inputField,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadowColor,
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: widget.isListening ? _pulseAnimation.value : 1.0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: widget.isListening 
                                ? AppColors.voiceActive
                                : AppColors.inputField,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: widget.isListening 
                                    ? AppColors.voiceActive.withValues(alpha: 0.3)
                                    : AppColors.shadowColor,
                                blurRadius: widget.isListening ? 8 : 2,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: IconButton(
                            onPressed: _isInitialized ? () => _handleVoiceInput() : null,
                            icon: Icon(
                              widget.isListening ? Icons.mic : Icons.mic_none,
                              color: widget.isListening
                                  ? Colors.white
                                  : AppColors.primaryGreen,
                              size: 22,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.inputField,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadowColor,
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: widget.controller,
                      enabled: !widget.isLoading,
                      maxLines: 5,
                      minLines: 1,
                      textCapitalization: TextCapitalization.sentences,
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.primaryText,
                      ),
                      decoration: InputDecoration(
                        hintText: AppStrings.typeMessage,
                        hintStyle: TextStyle(
                          color: AppColors.secondaryText,
                          fontSize: 16,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                      onSubmitted: (_) => _handleSend(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: _isComposing && !widget.isLoading
                        ? AppColors.primaryGreen
                        : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: (_isComposing && !widget.isLoading)
                        ? _handleSend
                        : null,
                    icon: widget.isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primaryGreen,
                              ),
                            ),
                          )
                        : Icon(
                            _isComposing ? Icons.send : Icons.thumb_up_alt_outlined,
                            color: (_isComposing && !widget.isLoading)
                                ? Colors.white
                                : AppColors.primaryGreen,
                            size: 22,
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ModeSelector extends StatelessWidget {
  final AppMode currentMode;
  final Function(AppMode) onModeChanged;

  const ModeSelector({
    super.key,
    required this.currentMode,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.selectMode,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _ModeButton(
                  title: AppStrings.correctionMode,
                  icon: Icons.spellcheck,
                  isSelected: currentMode == AppMode.correction,
                  onTap: () => onModeChanged(AppMode.correction),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ModeButton(
                  title: AppStrings.conversationMode,
                  icon: Icons.chat,
                  isSelected: currentMode == AppMode.conversation,
                  onTap: () => onModeChanged(AppMode.conversation),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeButton({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey.shade600,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey.shade700,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
