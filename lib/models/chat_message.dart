class ChatMessage {
  final String id;
  final String role; // 'user' ou 'assistant'
  final String content;
  final DateTime timestamp;
  final bool isLoading;

  ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
    this.isLoading = false,
  });

  // Factory pour créer un message utilisateur
  factory ChatMessage.user(String content) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: 'user',
      content: content,
      timestamp: DateTime.now(),
      isLoading: false,
    );
  }

  // Factory pour créer un message assistant
  factory ChatMessage.assistant(String content) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: 'assistant',
      content: content,
      timestamp: DateTime.now(),
      isLoading: false,
    );
  }

  // Factory pour créer un message de loading
  factory ChatMessage.loading() {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: 'assistant',
      content: '',
      timestamp: DateTime.now(),
      isLoading: true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'isLoading': isLoading,
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      role: json['role'] ?? 'assistant',
      content: json['content'] ?? '',
      timestamp: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      isLoading: json['isLoading'] ?? false,
    );
  }

  bool get isUser => role == 'user';
  bool get isAssistant => role == 'assistant';

  ChatMessage copyWith({
    String? id,
    String? role,
    String? content,
    DateTime? timestamp,
    bool? isLoading,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      role: role ?? this.role,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// Modèle pour la réponse du chat
class ChatResponse {
  final String question;
  final String response;
  final DateTime timestamp;

  ChatResponse({
    required this.question,
    required this.response,
    required this.timestamp,
  });

  factory ChatResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    return ChatResponse(
      question: data['question'] ?? '',
      response: data['response'] ?? '',
      timestamp: data['timestamp'] != null
          ? DateTime.parse(data['timestamp'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'response': response,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

// Modèle pour le statut IA
class AiStatus {
  final String status;
  final bool apiConfigured;
  final String mode;
  final DateTime timestamp;

  AiStatus({
    required this.status,
    required this.apiConfigured,
    required this.mode,
    required this.timestamp,
  });

  factory AiStatus.fromJson(Map<String, dynamic> json) {
    return AiStatus(
      status: json['status'] ?? 'unknown',
      apiConfigured: json['api_configured'] ?? false,
      mode: json['mode'] ?? 'unknown',
      timestamp: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp']) 
          : DateTime.now(),
    );
  }

  bool get isAvailable => status == 'available' && apiConfigured;
}

