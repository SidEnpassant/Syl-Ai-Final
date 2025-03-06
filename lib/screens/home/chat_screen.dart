import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sylai2/models/syllabus_model.dart';
import 'package:sylai2/screens/home/resources_screen.dart';
import 'package:sylai2/services/ai_service.dart';
import 'package:sylai2/widgets/chat/chat_bubble.dart';

import 'package:sylai2/widgets/chat/message_input.dart';

final aiServiceProvider = Provider<AiService>((ref) {
  return AiService();
});

final chatMessagesProvider =
    StateNotifierProvider<ChatMessagesNotifier, List<ChatMessage>>((ref) {
      return ChatMessagesNotifier();
    });

class ChatMessagesNotifier extends StateNotifier<List<ChatMessage>> {
  ChatMessagesNotifier() : super([]);

  void addMessage(ChatMessage message) {
    state = [...state, message];
  }

  void clearMessages() {
    state = [];
  }
}

enum ChatMessageType { user, assistant }

class ChatMessage {
  final String text;
  final ChatMessageType type;
  final DateTime timestamp;

  ChatMessage({required this.text, required this.type, DateTime? timestamp})
    : timestamp = timestamp ?? DateTime.now();
}

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _isProcessing = false;
  SyllabusModel? _currentSyllabus;

  @override
  void initState() {
    super.initState();
    _loadLatestSyllabus();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadLatestSyllabus() async {
    try {
      final supabaseService = ref.read(supabaseServiceProvider);
      final latestSyllabus = await supabaseService.getLatestSyllabus();

      if (latestSyllabus != null) {
        setState(() {
          _currentSyllabus = latestSyllabus;
        });

        // Add a welcome message
        ref
            .read(chatMessagesProvider.notifier)
            .addMessage(
              ChatMessage(
                text:
                    "Welcome back! I'm here to help you with your syllabus. What would you like to know about it?",
                type: ChatMessageType.assistant,
              ),
            );
      } else {
        // No syllabus found, prompt the user to upload one
        ref
            .read(chatMessagesProvider.notifier)
            .addMessage(
              ChatMessage(
                text:
                    "Welcome to Syl Ai! To get started, please upload your syllabus using the Upload tab, or type your syllabus details here.",
                type: ChatMessageType.assistant,
              ),
            );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading syllabus: $e')));
      }
    }
  }

  Future<void> _sendMessage(String message) async {
    // final message = _messageController.text.trim();
    if (message.isEmpty) return;

    _messageController.clear();

    // Add user message
    ref
        .read(chatMessagesProvider.notifier)
        .addMessage(ChatMessage(text: message, type: ChatMessageType.user));

    // Scroll to bottom
    _scrollToBottom();

    setState(() {
      _isProcessing = true;
    });

    try {
      final aiService = ref.read(aiServiceProvider);

      // If user is sending a syllabus text directly
      if (_currentSyllabus == null && message.length > 100) {
        // Process as syllabus text
        final extractedSyllabus = await aiService.extractSyllabusFromText(
          message,
        );

        if (extractedSyllabus != null) {
          // Save syllabus to database
          final supabaseService = ref.read(supabaseServiceProvider);
          final syllabusModel = await supabaseService.saveSyllabus(
            name: 'Chat Extracted Syllabus',
            content: extractedSyllabus,
            source: 'chat',
          );

          setState(() {
            _currentSyllabus = syllabusModel;
          });

          // Generate topics from syllabus
          await supabaseService.generateTopicsFromSyllabus(syllabusModel!);

          // Add assistant response
          ref
              .read(chatMessagesProvider.notifier)
              .addMessage(
                ChatMessage(
                  text:
                      "I've extracted and saved your syllabus! You can now ask me any questions about it, or I can find learning resources for specific topics.",
                  type: ChatMessageType.assistant,
                ),
              );
        } else {
          // Could not extract syllabus
          ref
              .read(chatMessagesProvider.notifier)
              .addMessage(
                ChatMessage(
                  text:
                      "I couldn't identify a syllabus in your message. Please try uploading a syllabus file instead, or format your syllabus more clearly.",
                  type: ChatMessageType.assistant,
                ),
              );
        }
      } else {
        // Regular chat with AI about the syllabus
        final response = await aiService.generateResponse(
          message,
          syllabusContent: _currentSyllabus?.content,
        );

        // Add assistant response
        ref
            .read(chatMessagesProvider.notifier)
            .addMessage(
              ChatMessage(text: response, type: ChatMessageType.assistant),
            );
      }
    } catch (e) {
      // Add error message
      ref
          .read(chatMessagesProvider.notifier)
          .addMessage(
            ChatMessage(
              text: "Sorry, I encountered an error: ${e.toString()}",
              type: ChatMessageType.assistant,
            ),
          );
    } finally {
      setState(() {
        _isProcessing = false;
      });

      // Scroll to bottom again after response
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatMessagesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Syl Ai Chat'),
        actions: [
          if (_currentSyllabus != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Chip(
                label: Text(
                  'Syllabus: ${_currentSyllabus!.title}',
                  style: const TextStyle(fontSize: 12),
                ),
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.primary.withOpacity(0.2),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Chat messages
          Expanded(
            child:
                messages.isEmpty
                    ? const Center(child: Text('Start a conversation!'))
                    : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        return ChatBubble(
                          message: message.text,
                          isUser: message.type == ChatMessageType.user,
                          timestamp: message.timestamp,
                        );
                      },
                    ),
          ),

          // Typing indicator
          if (_isProcessing)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              alignment: Alignment.centerLeft,
              child: const Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 8),
                  Text('AI is thinking...'),
                ],
              ),
            ),

          // Message input
          MessageInput(
            controller: _messageController,
            onSend: _sendMessage,
            enabled: !_isProcessing,
          ),
        ],
      ),
    );
  }
}
