import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/chat_provider.dart';
import '../models/chat_message.dart';
import '../utils/constants.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withOpacity(0.1), 
              shape: BoxShape.circle
            ),
            child: const Icon(Icons.grass, color: AppColors.primaryGreen),
          ),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('AgriBot', style: TextStyle(
              fontWeight: FontWeight.bold, 
              fontSize: 18
            )),
            Consumer<ChatProvider>(builder: (context, provider, child) {
              final status = provider.aiStatus;
              if (status == null) {
                return const Text(
                  '🔵 Chargement...',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                );
              }
              if (provider.isSimulationMode) {
                return Row(
                  children: [
                    Text(
                      '🟡 Mode Simulation',
                      style: TextStyle(fontSize: 12, color: Colors.orange.shade700),
                    ),
                    const SizedBox(width: 4),
                    Tooltip(
                      message: 'L\'IA n\'est pas configurée. Réponses pré-définies.',
                      child: Icon(Icons.help_outline, size: 14, color: Colors.orange.shade400),
                    ),
                  ],
                );
              }
              return Text(
                status == 'production' 
                  ? '🟢 IA Active' 
                  : '🟡 Mode $status',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              );
            }),
          ]),
        ]),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _showResetDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, provider, _) {
                // Afficher un indicateur de chargement pendant l'initialisation
                if (!provider.isInitialized) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(
                          color: AppColors.primaryGreen,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Initialisation d\'AgriBot...',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                if (provider.messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline, 
                          size: 80, 
                          color: Colors.grey[400]
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Posez votre première question',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Je suis là pour vous aider !',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToBottom();
                });

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.messages.length,
                  itemBuilder: (context, index) {
                    final message = provider.messages[index];
                    return ChatBubble(message: message);
                  },
                );
              },
            ),
          ),
          Consumer<ChatProvider>(
            builder: (context, provider, _) {
              if (provider.isSending) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.grey[100],
                  child: Row(
                    children: [
                      _buildLoadingIndicator(),
                      const SizedBox(width: 16),
                      Text(
                        'L\'assistant réfléchit...',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                );
              }
              if (provider.errorMessage != null) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.red[50],
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          provider.errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () => provider.clearError(),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            enabled: !context.watch<ChatProvider>().isSending,
                            decoration: const InputDecoration(
                              hintText: 'Posez votre question agricole...',
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              border: InputBorder.none,
                            ),
                            maxLines: 4,
                            minLines: 1,
                            textCapitalization: TextCapitalization.sentences,
                            textInputAction: TextInputAction.send,
                            onSubmitted: (_) => _sendMessage(),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Consumer<ChatProvider>(
                            builder: (context, provider, _) {
                              final canSend = _messageController.text.trim().isNotEmpty && !provider.isSending;
                              return IconButton(
                                onPressed: canSend ? _sendMessage : null,
                                icon: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: canSend ? AppColors.primaryGreen : Colors.grey.shade300,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.send, color: Colors.white, size: 20),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (context.watch<ChatProvider>().hasMessages) 
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton.icon(
                            onPressed: context.watch<ChatProvider>().isSending 
                              ? null 
                              : () => _showResetDialog(),
                            icon: const Icon(Icons.refresh, size: 18, color: Colors.grey),
                            label: const Text(
                              'Nouvelle conversation', 
                              style: TextStyle(color: Colors.grey)
                            ),
                          ),
                          const Text(
                            'Appuyez sur Entrée pour envoyer',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 6),
      duration: const Duration(milliseconds: 600),
      builder: (context, value, child) => Transform.translate(
        offset: Offset(0, -value),
        child: Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: AppColors.loadingGreen,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final provider = Provider.of<ChatProvider>(context, listen: false);
    provider.sendMessage(text);
    _messageController.clear();
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Réinitialiser la conversation ?'),
        content: const Text(
          'Cela effacera tous les messages et redémarrera une nouvelle conversation.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Provider.of<ChatProvider>(context, listen: false).resetConversation();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
            ),
            child: const Text('Réinitialiser'),
          ),
        ],
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final isLoading = message.isLoading;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isUser 
            ? AppColors.userMessageBg 
            : AppColors.assistantMessageBg,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: isUser ? const Radius.circular(18) : Radius.zero,
            bottomRight: isUser ? Radius.zero : const Radius.circular(18),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
          border: isUser ? null : Border.all(color: Colors.grey.shade300),
        ),
        child: isLoading ? _buildLoadingBubble() : _buildMessageContent(),
      ),
    );
  }

  Widget _buildLoadingBubble() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildDot(),
        const SizedBox(width: 4),
        _buildDot(),
        const SizedBox(width: 4),
        _buildDot(),
      ],
    );
  }

  Widget _buildDot() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 6),
      duration: const Duration(milliseconds: 600),
      builder: (context, value, child) => Transform.translate(
        offset: Offset(0, -value),
        child: Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: AppColors.primaryGreen,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  Widget _buildMessageContent() {
    return SelectionArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message.content,
            style: TextStyle(
              color: message.isUser ? Colors.white : Colors.black87,
              fontSize: 15,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            DateFormat('HH:mm').format(message.timestamp),
            style: TextStyle(
              color: message.isUser ? Colors.white70 : Colors.grey[600],
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

