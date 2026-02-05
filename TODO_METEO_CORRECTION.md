# TODO - Correction Section Météo

## Objectif
Corriger la section météo pour:
1. Afficher les vrais historiques et alertes depuis le backend
2. Appliquer un style conforme aux autres sections (Cultures, Stock)

---

## Étapes de Correction

### Phase 1: Connexion Backend Réelle

- [x] 1.1 - Modifier `_buildAlertesSection()` pour utiliser `weatherProvider.alerts`
- [x] 1.2 - Modifier `_buildForecastSection()` pour utiliser `weatherProvider.weatherForecast`
- [x] 1.3 - Modifier `_buildHistorySection()` pour utiliser `weatherProvider.meteoHistory`
- [x] 1.4 - Supprimer les données mockées (données statiques hardcodées)

### Phase 2: Refonte Style

- [x] 2.1 - Appliquer fond gris `const Color(0xFFF8F9FA)` au Scaffold
- [x] 2.2 - Utiliser `const Color(0xFF1B5E20)` (vert AgriFarm) pour les accents
- [x] 2.3 - Harmoniser cartes avec bordures `const BorderSide(color: Color(0xFFEEEEEE))`
- [x] 2.4 - Utiliser `BorderRadius.circular(16)` pour les cartes
- [x] 2.5 - Adapter typographie (titres h1: 28px bold, sous-titres: gris 14px)

### Phase 3: Modèle Backend

- [x] 3.1 - Vérifier conformité `Meteo.fromJson()` avec structure backend
- [x] 3.2 - Vérifier conformité `AlertMeteo.fromJson()` avec structure backend

---

## Fichiers à Modifier

1. `lib/screens/meteo_screen.dart` - Correction principale
2. `lib/models/meteo.dart` - Si nécessaire pour conformité JSON
3. `lib/models/alert_meteo.dart` - Si nécessaire pour conformité JSON

---

## Vérifications Post-Correction

- [x] Historique affiche données réelles depuis `/meteo/historique`
- [x] Alertes affiche données réelles depuis `/meteo/alerts`
- [x] Prévisions affiche données réelles depuis forecast API
- [x] Style conforme à `cultures_screen.dart` et `stock_screen.dart`
- [x] Aucune donnée mockée dans l'UI finale

---

## Résumé des Modifications

### Fichier: `lib/screens/meteo_screen.dart`

| Modification | Avant | Après |
|--------------|-------|-------|
| Source des alertes | Données mockées hardcodées | `weatherProvider.alerts` (API réel) |
| Source des prévisions | Données mockées | `weatherProvider.weatherForecast` (API réel) |
| Source de l'historique | Données mockées | `weatherProvider.meteoHistory` (API réel) |
| Couleur principale | `Colors.blue[600]` | `const Color(0xFF21A84D)` |
| Couleur texte titres | Noir par défaut | `const Color(0xFF1B5E20)` |
| Fond Scaffold | Blanc | `const Color(0xFFF8F9FA)` |
| Style des cartes | Elevation 4, sans bordure | Elevation 0, avec `BorderSide(color: Color(0xFFEEEEEE))` |
| Border Radius | 8px | 16px |

### Nouvelles fonctionnalités ajoutées:
- Affichage du résumé des prévisions (moyenne des températures, jours pluvieux)
- Indicateur de chargement pour l'historique
- Message d'état vide si pas de données historiques
- Meilleure gestion des erreurs avec Retry
- Icons météo dynamiques selon les codes OpenWeatherMap

