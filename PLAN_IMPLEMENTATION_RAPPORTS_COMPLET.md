# Plan d'Implémentation - Section Rapports Complète

## 📋 Vue d'Ensemble

Ce plan détaille l'implémentation complète de la section rapports en respectant l'architecture Flutter existante et les spécifications backend fournies.

---

## 🔍 Analyse de l'Existant

### ✅ Éléments déjà présents :
- `lib/models/rapport.dart` - Modèle de base
- `lib/providers/rapport_provider.dart` - Provider avec fonctions de base
- `lib/services/rapport_service.dart` - Service API basique
- `lib/screens/rapport_screen.dart` - Interface utilisateur de base

### ❌ Éléments manquants ou à améliorer :
- Modèle non conforme à l'API backend
- Fonctionnalités de filtrage et recherche
- Téléchargement de fichiers
- Interface utilisateur enrichie
- Gestion des erreurs avancée
- Pagination

---

## 🎯 Plan d'Implémentation Détaillé

### Phase 1 : Mise à Jour du Modèle de Données

#### 1.1 Mise à jour du modèle Rapport (`lib/models/rapport.dart`)
**Problèmes identifiés :**
- Champs manquants : `conditions`, `ai_prompt`, `generated_at`, `fichier`
- Structure non conforme à l'API

**Actions :**
- Ajouter les champs manquants
- Ajuster la sérialisation/désérialisation JSON
- Ajouter des getters pour l'affichage
- Méthodes utilitaires pour le formatage

### Phase 2 : Amélioration du Service API

#### 2.1 Mise à jour du service (`lib/services/rapport_service.dart`)
**Améliorations nécessaires :**
- Ajout du paramètre `titre` optionnel dans la génération
- Implémentation du téléchargement de fichiers
- Gestion avancée des erreurs
- Timeout et retry logic

**Nouvelles fonctionnalités :**
```dart
// Génération avec titre personnalisé
static Future<Rapport> generateAiReport({
  required String periode,
  String? titre, // NOUVEAU
}) async { /* ... */ }

// Téléchargement de fichier
static Future<String> downloadRapport(int id) async { /* ... */ }

// Récupération d'un rapport spécifique
static Future<Rapport> getRapport(int id) async { /* ... */ }
```

### Phase 3 : Enrichissement du Provider

#### 3.1 Amélioration du provider (`lib/providers/rapport_provider.dart`)
**Nouvelles fonctionnalités :**
- Gestion des états de filtrage et recherche
- Pagination
- Cache local
- Actions en lot (suppression multiple)

**États à ajouter :**
```dart
class RapportProvider with ChangeNotifier {
  // États existants
  List<Rapport> _rapports = [];
  bool _isLoading = false;
  bool _isGenerating = false;
  String? _error;
  
  // NOUVEAUX ÉTATS
  String _filtrePeriode = 'tous';
  String _recherche = '';
  String _triPar = 'date';
  bool _ordreDesc = true;
  int _page = 1;
  bool _hasMore = true;
  
  // NOUVELLES MÉTHODES
  List<Rapport> get rapportsFiltres => filtrerRapports();
  void setFiltrePeriode(String periode) { /* ... */ }
  void setRecherche(String terme) { /* ... */ }
  void trierRapports({String? par, bool? desc}) { /* ... */ }
  Future<void> chargerPlus() async { /* ... */ }
}
```

### Phase 4 : Amélioration de l'Interface Utilisateur

#### 4.1 Mise à jour de l'écran principal (`lib/screens/rapport_screen.dart`)
**Nouvelles fonctionnalités :**
- Barre de recherche
- Filtres par période
- Tri dynamique
- Pagination infinie
- Actions en lot
- Animations et feedback visuel

#### 4.2 Composants UI spécialisés
**Nouveaux composants à créer :**
- `RapportCard` amélioré avec actions en lot
- `RapportFilterBar` pour les filtres
- `RapportSearchBar` pour la recherche
- `RapportSortDialog` pour le tri
- `DownloadDialog` pour le téléchargement
- `GenerateReportDialog` amélioré avec titre personnalisé

### Phase 5 : Fonctionnalités Avancées

#### 5.1 Système de cache local
- Cache des rapports pour usage hors ligne
- Synchronisation automatique
- Gestion de l'expiration

#### 5.2 Export et partage
- Export en PDF/HTML
- Partage par email
- Impression directe

#### 5.3 Notifications et rappels
- Notification de nouveaux rapports
- Rappels de génération périodique
- Alertes de rapport généré

---

## 📊 Structure de Données Cible

### Modèle Rapport Mis à Jour
```dart
class Rapport {
  final int id;
  final int userId;
  final String titre;
  final String periode; // 'jour' | 'semaine' | 'mois'
  final String contenu;
  final double? temperature;
  final int? humidite;
  final String? conditions; // NOUVEAU
  final String? fichier; // NOUVEAU
  final DateTime? generatedAt; // NOUVEAU
  final String? aiPrompt; // NOUVEAU
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Getters pour l'affichage
  String get dateFormatee => DateFormat('dd MMM yyyy').format(createdAt);
  String get apercuContenu => contenu.substring(0, 100) + '...';
  String get iconePeriode => /* ... */;
  Color get couleurPeriode => /* ... */;
}
```

### États du Provider
```dart
class RapportProviderState {
  // Données
  List<Rapport> rapports;
  List<Rapport> rapportsFiltres;
  
  // États de chargement
  bool isLoading;
  bool isGenerating;
  bool isDownloading;
  
  // Filtres et recherche
  String filtrePeriode;
  String recherche;
  String triPar;
  bool ordreDesc;
  
  // Pagination
  int page;
  bool hasMore;
  
  // Interface
  Rapport? rapportSelectionne;
  bool modalOuvert;
  Set<int> rapportsSelectionnes; // Pour actions en lot
}
```

---

## 🎨 Interface Utilisateur Cible

### Écran Principal Amélioré
```
┌─────────────────────────────────────┐
│ 🔍 Recherche...     🔄 ⚙️ 📊      │ <- Barre de recherche + actions
├─────────────────────────────────────┤
│ [📅 Tous] [📊 Jour] [📈 Semaine]    │ <- Filtres par période
├─────────────────────────────────────┤
│ ┌─ Rapport 1 ──────────────┐ ☐     │
│ │ 📊 Rapport Semaine        │       │
│ │ 📅 15 Jan 2024           │ 🗑️📥 │ <- Actions
│ │ 🌡️ 25°C 💧 65%           │       │
│ │ 📝 Aperçu du contenu...   │       │
│ └───────────────────────────┘       │
│ ┌─ Rapport 2 ──────────────┐ ☐     │
│ │ 📈 Rapport Mensuel        │       │
│ │ 📅 10 Jan 2024           │ 🗑️📥 │
│ └───────────────────────────┘       │
├─────────────────────────────────────┤
│                ⋮                    │ <- Pagination infinie
└─────────────────────────────────────┘
```

### Dialogue de Génération Amélioré
```
┌─────────────────────────────────────┐
│        🤖 Générer un Rapport        │
├─────────────────────────────────────┤
│                                     │
│ Période : ○ Jour  ○ Semaine  ○ Mois│
│                                     │
│ Titre (optionnel) :                 │
│ ┌─────────────────────────────────┐ │
│ │ Rapport personnalisé           │ │
│ └─────────────────────────────────┘ │
│                                     │
│ 📋 Aperçu :                         │
│ • Analyse des ventes                │
│ • Données météo                     │
│ • Recommandations IA               │
│                                     │
│           [Annuler]  [Générer]     │
└─────────────────────────────────────┘
```

### Vue Détail Enrichie
```
┌─────────────────────────────────────┐
│ ← Rapport Semaine - 15 Jan 2024     │
├─────────────────────────────────────┤
│ 📊 Rapport IA Complet               │
│ 📅 15 janvier 2024 à 14:30          │
│                                     │
│ ┌─ Conditions Météo ──────────────┐ │
│ │ 🌡️ 25°C  💧 65%  ☀️ Ensoleillé  │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─ Rapport Généré ────────────────┐ │
│ │ 📊 RAPPORT D'ANALYSE AGRICOLE   │ │
│ │                                 │ │
│ │ 🌡️ CONDITIONS MÉTÉO            │ │
│ │ Température: 25°C               │ │
│ │ Humidité: 65%                   │ │
│ │ Conditions: Ensoleillé          │ │
│ │                                 │ │
│ │ 💡 RECOMMANDATIONS              │ │
│ │ • Arroser le matin              │ │
│ │ • Surveiller l'humidité         │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─ Métadonnées ──────────────────┐ │
│ │ 🤖 IA Prompt: "Génère un..."   │ │
│ │ 📄 Fichier: rapport_123.html   │ │
│ └─────────────────────────────────┘ │
│                                     │
│ [📥 Télécharger] [📋 Copier] [🗑️]  │
└─────────────────────────────────────┘
```

---

## 🔧 Implémentation Technique

### 1. Mise à Jour du Modèle
```dart
// lib/models/rapport.dart - VERSION COMPLÈTE
class Rapport {
  // Champs existants + nouveaux
  final int id;
  final int userId;
  final String titre;
  final String periode;
  final String contenu;
  final double? temperature;
  final int? humidite;
  final String? conditions; // NOUVEAU
  final String? fichier; // NOUVEAU  
  final DateTime? generatedAt; // NOUVEAU
  final String? aiPrompt; // NOUVEAU
  final DateTime createdAt;
  final DateTime updatedAt;

  // Getters pour l'affichage
  String get dateFormatee => DateFormat('dd MMM yyyy').format(createdAt);
  String get apercuContenu => contenu.length > 100 
      ? '${contenu.substring(0, 100)}...' 
      : contenu;
  String get iconePeriode {
    switch (periode.toLowerCase()) {
      case 'jour': return '📅';
      case 'semaine': return '📊';
      case 'mois': return '📈';
      default: return '📄';
    }
  }
  Color get couleurPeriode {
    switch (periode.toLowerCase()) {
      case 'jour': return Colors.blue;
      case 'semaine': return Colors.green;
      case 'mois': return Colors.purple;
      default: return Colors.grey;
    }
  }
}
```

### 2. Service API Enrichi
```dart
// lib/services/rapport_service.dart - VERSION COMPLÈTE
class RapportService {
  static const String baseUrl = 'http://localhost:8000/api';
  
  // Génération avec titre personnalisé
  static Future<Rapport> generateAiReport({
    required String periode,
    String? titre, // NOUVEAU
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/rapports/generer-ia'),
      headers: await _getHeaders(),
      body: jsonEncode({
        'periode': periode,
        if (titre != null) 'titre': titre,
      }),
    );
    
    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return Rapport.fromJson(data['rapport']);
    }
    throw Exception('Erreur génération IA: ${response.statusCode}');
  }
  
  // Téléchargement de fichier
  static Future<String> downloadRapport(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/rapports/$id/download'),
      headers: await _getHeaders(),
    );
    
    if (response.statusCode == 200) {
      return response.body; // HTML content
    }
    throw Exception('Erreur téléchargement: ${response.statusCode}');
  }
}
```

### 3. Provider Enrichi
```dart
// lib/providers/rapport_provider.dart - VERSION COMPLÈTE
class RapportProvider with ChangeNotifier {
  // États existants
  List<Rapport> _rapports = [];
  bool _isLoading = false;
  bool _isGenerating = false;
  String? _error;
  
  // NOUVEAUX ÉTATS
  String _filtrePeriode = 'tous';
  String _recherche = '';
  String _triPar = 'date';
  bool _ordreDesc = true;
  Set<int> _selection = {};
  
  // Getters
  List<Rapport> get rapports => _rapports;
  List<Rapport> get rapportsFiltres => filtrerRapports();
  bool get hasSelection => _selection.isNotEmpty;
  
  // Méthodes de filtrage
  List<Rapport> filtrerRapports() {
    var filtered = _rapports;
    
    // Filtre par période
    if (_filtrePeriode != 'tous') {
      filtered = filtered.where((r) => r.periode == _filtrePeriode).toList();
    }
    
    // Recherche par titre
    if (_recherche.isNotEmpty) {
      filtered = filtered.where((r) => 
        r.titre.toLowerCase().contains(_recherche.toLowerCase())
      ).toList();
    }
    
    // Tri
    filtered.sort((a, b) {
      int comparison = 0;
      switch (_triPar) {
        case 'titre':
          comparison = a.titre.compareTo(b.titre);
          break;
        case 'periode':
          comparison = a.periode.compareTo(b.periode);
          break;
        case 'date':
        default:
          comparison = a.createdAt.compareTo(b.createdAt);
          break;
      }
      return _ordreDesc ? -comparison : comparison;
    });
    
    return filtered;
  }
  
  // Actions de filtrage
  void setFiltrePeriode(String periode) {
    _filtrePeriode = periode;
    notifyListeners();
  }
  
  void setRecherche(String terme) {
    _recherche = terme;
    notifyListeners();
  }
  
  // Actions en lot
  void toggleSelection(int rapportId) {
    if (_selection.contains(rapportId)) {
      _selection.remove(rapportId);
    } else {
      _selection.add(rapportId);
    }
    notifyListeners();
  }
  
  void clearSelection() {
    _selection.clear();
    notifyListeners();
  }
  
  Future<bool> deleteSelected() async {
    bool success = true;
    for (int id in _selection) {
      if (!await deleteRapport(id)) {
        success = false;
      }
    }
    _selection.clear();
    notifyListeners();
    return success;
  }
}
```

---

## 📋 Checklist d'Implémentation

### Phase 1 - Modèle et Service
- [ ] 1.1 Mettre à jour le modèle `Rapport` avec tous les champs API
- [ ] 1.2 Ajouter les getters pour l'affichage
- [ ] 1.3 Implémenter le téléchargement de fichiers
- [ ] 1.4 Ajouter la gestion des erreurs avancée
- [ ] 1.5 Tester la sérialisation/désérialisation

### Phase 2 - Provider Enrichi
- [ ] 2.1 Ajouter les états de filtrage et recherche
- [ ] 2.2 Implémenter les méthodes de filtrage
- [ ] 2.3 Ajouter la gestion des sélections multiples
- [ ] 2.4 Implémenter le tri dynamique
- [ ] 2.5 Ajouter la pagination (si nécessaire)

### Phase 3 - Interface Utilisateur
- [ ] 3.1 Ajouter la barre de recherche
- [ ] 3.2 Créer les filtres par période
- [ ] 3.3 Améliorer la carte de rapport (actions en lot)
- [ ] 3.4 Enrichir le dialogue de génération
- [ ] 3.5 Améliorer la vue détail
- [ ] 3.6 Ajouter les animations et feedback

### Phase 4 - Fonctionnalités Avancées
- [ ] 4.1 Implémenter le téléchargement de fichiers
- [ ] 4.2 Ajouter l'export PDF/HTML
- [ ] 4.3 Créer le système de cache local
- [ ] 4.4 Ajouter les notifications
- [ ] 4.5 Optimiser les performances

### Phase 5 - Tests et Polissage
- [ ] 5.1 Tests unitaires des modèles et services
- [ ] 5.2 Tests d'intégration des providers
- [ ] 5.3 Tests d'interface utilisateur
- [ ] 5.4 Tests de performance
- [ ] 5.5 Tests de compatibilité mobile

---

## 🎯 Résultat Final

La section rapports aura alors toutes ces fonctionnalités :

### ✅ Fonctionnalités de Base
- ✅ Liste des rapports avec pagination
- ✅ Génération automatique par IA
- ✅ Affichage détaillé d'un rapport
- ✅ Suppression avec confirmation

### ✅ Fonctionnalités Avancées
- ✅ Filtrage par période (jour/semaine/mois)
- ✅ Recherche par titre
- ✅ Tri dynamique (date/titre/période)
- ✅ Actions en lot (sélection multiple)
- ✅ Téléchargement en HTML
- ✅ Interface responsive et intuitive
- ✅ Gestion d'erreurs robuste

### 🎨 Interface Utilisateur
- Design moderne et cohérent
- Animations fluides
- Feedback visuel immédiat
- Accessibilité optimisée
- Performance optimisée

Cette implémentation respectera parfaitement l'architecture backend fournie et offrira une expérience utilisateur excellente pour la gestion des rapports agricoles.
