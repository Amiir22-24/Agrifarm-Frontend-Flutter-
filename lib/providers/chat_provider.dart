import 'package:flutter/foundation.dart';
import '../models/chat_message.dart';
import '../models/chat_state.dart';
import '../services/chat_service.dart';
import '../utils/storage_helper.dart';
import '../utils/constants.dart';

class ChatProvider with ChangeNotifier {
  final ChatService _chatService;
  ChatState _state = ChatState();
  bool _isInitialized = false;

  ChatState get state => _state;
  List<ChatMessage> get messages => _state.messages;
  bool get isLoading => _state.isLoading;
  bool get isSending => _state.isSending;
  bool get hasError => _state.hasError;
  String? get errorMessage => _state.errorMessage;
  bool get hasMessages => _state.hasMessages;
  String? get aiStatus => _state.aiStatus;
  bool get isInitialized => _isInitialized;
  bool get isSimulationMode => _state.isSimulationMode;

  // Constructeur avec injection de dépendance
  ChatProvider({required ChatService chatService}) : _chatService = chatService {
    _initializeChat();
  }

  // Constructeur factory pour compatibilité avec ChangeNotifierProvider
  static ChatProvider create() {
    return ChatProvider(chatService: ChatService(baseUrl: ApiConstants.baseUrl));
  }

  // Initialiser le chat de manière asynchrone
  Future<void> _initializeChat() async {
    await _loadMessages();
    
    // Ajouter le message de bienvenida si pas de messages
    if (_state.messages.isEmpty) {
      final welcomeMessage = ChatMessage.assistant(
        '🌱 Bonjour ! Je suis AgriBot, votre assistant agricole.\n\n'
        'Je peux vous aider avec :\n'
        '• Conseils de culture et agriculture\n'
        '• Questions sur les engrais et pesticides\n'
        '• Informations météorologiques\n'
        '• Gestion des récoltes et stocks\n'
        '• Recommandations personnalisées\n\n'
        'Comment puis-je vous aider aujourd\'hui ?'
      );
      _updateMessages([welcomeMessage]);
      await _saveMessages();
    }
    
    // Vérifier le statut IA
    await checkAiStatus();
    
    _isInitialized = true;
  }

  // Charger l'historique depuis le cache
  Future<void> _loadMessages() async {
    final cached = await StorageHelper.getChatHistory();
    if (cached != null && cached.isNotEmpty) {
      _updateMessages(cached);
    }
  }

  // Sauvegarder l'historique dans le cache
  Future<void> _saveMessages() async {
    await StorageHelper.saveChatHistory(_state.messages);
  }

  // Mettre à jour les messages
  void _updateMessages(List<ChatMessage> messages) {
    _state = _state.copyWith(messages: messages);
    notifyListeners();
  }

  // Définir le statut
  void _setStatus(ChatStatus status) {
    _state = _state.copyWith(status: status);
    notifyListeners();
  }

  // Définir une erreur
  void _setError(String message) {
    _state = _state.copyWith(status: ChatStatus.error, errorMessage: message);
    notifyListeners();
  }

  // Effacer l'erreur
  void _clearError() {
    _state = _state.copyWith(status: ChatStatus.idle, errorMessage: null);
    notifyListeners();
  }

  // Envoyer un message
  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    final trimmedContent = content.trim();
    final userMessage = ChatMessage.user(trimmedContent);
    final loadingMessage = ChatMessage.loading();
    
    // Créer la liste des messages AVANT de mettre à jour l'état
    // Correction du bug: éviter d'ajouter le message utilisateur deux fois
    final messagesWithUser = [..._state.messages, userMessage];
    final messagesWithLoading = [...messagesWithUser, loadingMessage];
    
    // Mettre à jour les messages en une seule fois
    _updateMessages(messagesWithLoading);
    _setStatus(ChatStatus.sending);

    // Vérifier si on est en mode simulation
    if (_state.isSimulationMode) {
      // Mode simulation: réponse immédiate sans appel API
      await Future.delayed(const Duration(milliseconds: 800)); // Petit délai pour effet visuel
      final simulatedResponse = getSimulatedResponse(trimmedContent);
      final aiMessage = ChatMessage.assistant(simulatedResponse);
      _updateMessages([...messagesWithUser, aiMessage]);
      _setStatus(ChatStatus.idle);
      await _saveMessages();
      return;
    }

    // L'historique pour l'API doit exclure le message de loading
    final history = messagesWithLoading.where((m) => !m.isLoading).toList();

    try {
      final response = await _chatService.sendQuestion(
        question: trimmedContent, 
        history: history
      );

      if (response.success && response.data != null) {
        final aiMessage = ChatMessage.assistant(response.data!.response);
        _updateMessages([...messagesWithUser, aiMessage]);
        _setStatus(ChatStatus.idle);
        await _saveMessages();
      } else {
        final errorMsg = ChatMessage.assistant(response.message ?? 'Erreur lors de la réponse');
        _updateMessages([...messagesWithUser, errorMsg]);
        _setError(response.message ?? 'Erreur lors de la réponse');
      }
    } catch (e) {
      final errorMsg = ChatMessage.assistant('Erreur de connexion au serveur');
      _updateMessages([...messagesWithUser, errorMsg]);
      _setError(e.toString());
    }
  }

  // Réinitialiser la conversation
  Future<void> resetConversation() async {
    _setStatus(ChatStatus.loading);
    
    try {
      final response = await _chatService.resetConversation();
      
      if (response.success) {
        _updateMessages([]);
        _clearError();
        _setStatus(ChatStatus.idle);
        await StorageHelper.clearChatHistory();
      } else {
        _setError(response.message ?? 'Erreur lors de la réinitialisation');
      }
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Vérifier le statut de l'IA
  Future<void> checkAiStatus() async {
    try {
      final response = await _chatService.getChatStatus();
      if (response.success && response.data != null) {
        final mode = response.data!.mode;
        final isSimulation = response.data!.apiConfigured == false || mode == 'simulation';
        _state = _state.copyWith(
          aiStatus: mode,
          isSimulationMode: isSimulation,
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Erreur vérification statut IA: $e');
    }
  }

  // Générer une réponse simulée basée sur la question
  String getSimulatedResponse(String question) {
    final lowerQuestion = question.toLowerCase();
    
    // Mots-clés pour chaque catégorie
    if (lowerQuestion.contains('culture') || 
        lowerQuestion.contains('planter') || 
        lowerQuestion.contains('semer') ||
        lowerQuestion.contains('cultiver')) {
      return '🌱 **Mode Simulation**\n\n'
          'Pour vos questions sur les cultures:\n\n'
          '• **Préparation du sol**: Labourer à 20-30cm de profondeur et enrichir avec du compost.\n'
          '• **Rotation des cultures**: Alternez légume-feuille, légume-racine, légume-fruit.\n'
          '• **Périodes de semis**: Respectez le calendrier local selon votre zone climatique.\n'
          '• **Espacement**: Consultez les recommandations sur les sachets de semences.\n\n'
          '💡 *Note: Cette réponse est en mode simulation. Connectez-vous à l\'IA pour des conseils personnalisés.*';
    }
    
    if (lowerQuestion.contains('engrais') || 
        lowerQuestion.contains('fertilisant') || 
        lowerQuestion.contains('nutri')) {
      return '🌿 **Mode Simulation**\n\n'
          'Pour vos questions sur les engrais:\n\n'
          '• **Engrais organiques**: Compost, fumier, cendres de bois.\n'
          '• **Engrais minéraux**: NPK (azote, phosphore, potassium) selon les besoins.\n'
          '• **Dosage**: Suivez les recommandations sur l\'emballage.\n'
          '• **Application**: Préférez le matin ou le soir pour éviter l\'évaporation.\n\n'
          '💡 *Note: Cette réponse est en mode simulation. Connectez-vous à l\'IA pour des recommandations précises.*';
    }
    
    if (lowerQuestion.contains('météo') || 
        lowerQuestion.contains('pluie') || 
        lowerQuestion.contains('climat') ||
        lowerQuestion.contains('température')) {
      return '🌤️ **Mode Simulation**\n\n'
          'Pour vos questions météorologiques:\n\n'
          '• **Avant semis**: Vérifiez les prévisions sur 7-10 jours.\n'
          '• ** Irrigation**: Prévoyez 25-30mm d\'eau par semaine pour la plupart des cultures.\n'
          '• **Protection**: Soyez prêt à couvrir les plantes en cas de gel ou de forte chaleur.\n'
          '• **Outils**: Utilisez notre écran météo intégré pour des prévisions locales.\n\n'
          '💡 *Note: Cette réponse est en mode simulation. Consultez l\'écran météo pour des données précises.*';
    }
    
    if (lowerQuestion.contains('récolte') || 
        lowerQuestion.contains('récolter') || 
        lowerQuestion.contains('cueillir')) {
      return '🌾 **Mode Simulation**\n\n'
          'Pour vos questions sur les récoltes:\n\n'
          '• **Moment optimal**: Récoltez le matin tôt pour une meilleure conservation.\n'
          '• **Signes de maturité**: Couleur, taille, fermeté selon le légume.\n'
          '• **Conservation**: Stockez dans un endroit frais et aéré.\n'
          '• **Rendement**: Notez les quantités pour suivre votre productivité.\n\n'
          '💡 *Note: Cette réponse est en mode simulation. Utilisez le module de gestion des récoltes pour un suivi détaillé.*';
    }
    
    if (lowerQuestion.contains('stock') || 
        lowerQuestion.contains('stockage') || 
        lowerQuestion.contains('entreposer')) {
      return '📦 **Mode Simulation**\n\n'
          'Pour vos questions sur le stockage:\n\n'
          '• **Conditions idéales**: Endroit frais (10-15°C), sec et ventilé.\n'
          '• **Durée de conservation**: Varie selon le produit (quelques jours à plusieurs mois).\n'
          '• **Rotation**: Premier entré, premier sorti (FIFO).\n'
          '• **Contrôle**: Inspectez régulièrement pour détecter les dégradations.\n\n'
          '💡 *Note: Cette réponse est en mode simulation. Utilisez le module de gestion des stocks pour un suivi précis.*';
    }
    
    if (lowerQuestion.contains('maladie') || 
        lowerQuestion.contains('ravageur') || 
        lowerQuestion.contains('insecte') ||
        lowerQuestion.contains('parasite')) {
      return '🐛 **Mode Simulation**\n\n'
          'Pour vos questions sur les ravageurs et maladies:\n\n'
          '• **Prévention**: Rotation des cultures, compagnonnage,太阳能消毒 du sol.\n'
          '• **Identification**: Observez les feuilles, tiges et fruits régulièrement.\n'
          '• **Traitements**: Savon noir, huile de neem, purins naturels.\n'
          '• **Lutte biologique**: Introduisez des auxiliaires (coccinelles, chrysopes).\n\n'
          '💡 *Note: Cette réponse est en mode simulation. Consultez un professionnel pour les cas graves.*';
    }
    
    // Réponse générique pour autres questions
    return '🤖 **Mode Simulation**\n\n'
        'Merci pour votre question sur: "$question"\n\n'
        'En mode simulation, je peux vous orienter vers:\n'
        '• 📱 L\'écran **Météo** pour les conditions climatiques\n'
        '• 🌾 Le module **Cultures** pour les conseils de plantation\n'
        '• 📦 La gestion des **Stocks** pour votre inventaire\n'
        '• 📊 Les **Rapports** pour analyser vos données\n\n'
        '🔑 *Configurez votre clé API OpenAI pour bénéficier de l\'assistant intelligent.*';
  }

  // Ajouter le message de bienvenida
  void addWelcomeMessage() {
    if (_state.messages.isEmpty) {
      final welcomeMessage = ChatMessage.assistant(
        '🌱 Bonjour ! Je suis AgriBot, votre assistant agricole.\n\n'
        'Je peux vous aider avec :\n'
        '• Conseils de culture et agriculture\n'
        '• Questions sur les engrais et pesticides\n'
        '• Informations météorologiques\n'
        '• Gestion des récoltes et stocks\n'
        '• Recommandations personnalisées\n\n'
        'Comment puis-je vous aider aujourd\'hui ?'
      );
      _updateMessages([welcomeMessage]);
      _saveMessages();
    }
  }

  // Supprimer un message
  void deleteMessage(int index) {
    if (index >= 0 && index < _state.messages.length) {
      final newMessages = List<ChatMessage>.from(_state.messages)..removeAt(index);
      _updateMessages(newMessages);
      _saveMessages();
    }
  }

  void clearError() {
    _clearError();
  }
}

