import 'chat_message.dart';

enum ChatStatus { idle, loading, sending, error, connected }

class ChatState {
  final List<ChatMessage> messages;
  final ChatStatus status;
  final String? errorMessage;
  final bool isTyping;
  final String? aiStatus;
  final bool isSimulationMode;

  ChatState({
    this.messages = const [],
    this.status = ChatStatus.idle,
    this.errorMessage,
    this.isTyping = false,
    this.aiStatus,
    this.isSimulationMode = false,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    ChatStatus? status,
    String? errorMessage,
    bool? isTyping,
    String? aiStatus,
    bool? isSimulationMode,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      isTyping: isTyping ?? this.isTyping,
      aiStatus: aiStatus ?? this.aiStatus,
      isSimulationMode: isSimulationMode ?? this.isSimulationMode,
    );
  }

  bool get hasMessages => messages.isNotEmpty;
  int get messageCount => messages.length;

  bool get isLoading => status == ChatStatus.loading;
  bool get isSending => status == ChatStatus.sending;
  bool get hasError => status == ChatStatus.error;
  bool get isConnected => status == ChatStatus.connected;
}

