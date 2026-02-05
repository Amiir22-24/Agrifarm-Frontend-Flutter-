# TODO - Correction Chatbot

## Objectif
Corriger deux problèmes dans le chatbot:
1. Message affiché deux fois lors de l'envoi
2. Pas de réponse en mode simulation quand la clé API n'est pas disponible

## Tâches

### 1. Corriger le bug de duplication des messages ✅
- [x] Modifier `chat_provider.dart` - méthode `sendMessage`
- [x] Utiliser `messagesWithUser` au lieu de `_state.messages` dans la deuxième ligne
- [x] Simplifier le flux pour éviter les doublons

### 2. Implémenter le mode simulation ✅
- [x] Ajouter `isSimulationMode` au `ChatState`
- [x] Ajouter getter `isSimulationMode` dans `ChatProvider`
- [x] Modifier `checkAiStatus` pour définir le mode simulation
- [x] Implémenter `getSimulatedResponse` pour les réponses pré-définies
- [x] Modifier `sendMessage` pour utiliser la réponse simulée si en mode simulation

### 3. Mise à jour de l'interface ✅
- [x] Afficher un indicateur visuel quand le chatbot est en mode simulation

## Modifications effectuées

### Fichier: `lib/models/chat_state.dart`
- Ajout de la propriété `isSimulationMode` à `ChatState`
- Mise à jour de `copyWith` pour inclure `isSimulationMode`

### Fichier: `lib/providers/chat_provider.dart`
- Ajout du getter `isSimulationMode`
- Correction de `sendMessage` pour éviter la duplication:
  - Création de `messagesWithUser` et `messagesWithLoading` avant mise à jour de l'état
  - Utilisation cohérente des variables pour éviter les références à `_state.messages` non mis à jour
- Implémentation de `getSimulatedResponse()` avec réponses pré-définies pour:
  - Questions sur les cultures
  - Questions sur les engrais
  - Questions météorologiques
  - Questions sur les récoltes
  - Questions sur le stockage
  - Questions sur les maladies/ravageurs
  - Réponse générique
- Modification de `checkAiStatus` pour définir `isSimulationMode` basé sur `apiConfigured`

### Fichier: `lib/screens/chat_screen.dart`
- Affichage "Mode Simulation" en orange dans l'appBar
- Ajout d'un tooltip explicatif

## Progression
- [x] TODO créé
- [x] Bug de duplication corrigé
- [x] Mode simulation implémenté
- [ ] Tests de vérification

