# 📊 Plan de Refonte de la Section Rapports - Style Professionnel AgriFarm

## 🎨 Style de Référence (issu de cultures_screen.dart et stock_screen.dart)

### Design System AgriFarm

| Élément | Valeur |
|---------|--------|
| **Couleur primaire** | Vert : `Color(0xFF21A84D)` / `Color(0xFF1B5E20)` |
| **Fond** | `Color(0xFFF8F9FA)` |
| **Cartes** | Blanc avec bordure `Color(0xFFEEEEEE)` |
| **Coins arrondis** | `BorderRadius.circular(16)` |
| **Padding écran** | `EdgeInsets.all(24.0)` |
| **Titre principal** | 28px bold |
| **Sous-titre** | 14px gris |

---

## 📋 Structure de l'Écran Rapports (Refonte Complète)

### 1. HEADER
```
┌─────────────────────────────────────────────────┐
│  📊 Rapports IA                                  │  ← Titre: 28px bold Color(0xFF1B5E20)
│  Analysez vos données agricoles                  │  ← Sous-titre: gris
└─────────────────────────────────────────────────┘
```

### 2. STATS CARDS (2 cartes)
```
┌──────────────────────┐  ┌──────────────────────┐
│ 📄 [Icône]           │  │ 🤖 [Icône]           │
│ Total                │  │ IA                   │
│ X rapports           │  │ Y générés            │
└──────────────────────┘  └──────────────────────┘
```

### 3. FILTRES ET RECHERCHE
```
┌─────────────────────────────────────────────────┐
│ [🔍 Rechercher...]     [📅 Tous ▼]  [📊 Tri ▼] │
└─────────────────────────────────────────────────┘
```

### 4. LISTE DES RAPPORTS (Style Card comme ventes_screen.dart)
```
┌─────────────────────────────────────────────────┐
│ 📄 Rapport Journalier - 15 Jan 2025              │
│ ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  │
│ 📅 Période: Journalier  │  📅 15/01/2025        │
│ 🌡️ 25°C  │ 💧 60%                               │
└─────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────┐
│ 📊 Rapport Hebdomadaire - Semaine 3             │
│ ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  │
│ 📅 Période: Hebdomadaire  │  📅 08-15 Jan 2025  │
│ 🌡️ 22°C  │ 💧 65%                               │
└─────────────────────────────────────────────────┘
```

### 5. BOUTON D'ACTION FLOTTANT
```
              ┌─────────────────┐
              │ + 🤖 Générer IA │
              └─────────────────┘
```

---

## 🔧 Modifications à Apporter

### Fichier: `lib/screens/rapport_screen.dart`

#### A. Nouvelles Importations
```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/rapport_provider.dart';
import '../models/rapport.dart';
```

#### B. Refonte Complete de l'Écran

**Nouveau design avec :**
1. Header avec titre et sous-titre
2. Cartes statistiques (total rapports, générés par IA)
3. Barre de recherche stylisée
4. Filtres par période (chips)
5. Liste de rapports avec cards professionnelles
6. Dialog de génération IA redesigné

#### C. Structure du Nouveau Widget

```dart
class RapportScreen extends StatefulWidget {
  const RapportScreen({Key? key}) : super(key: key);

  @override
  State<RapportScreen> createState() => _RapportScreenState();
}

class _RapportScreenState extends State<RapportScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _filterPeriode = 'tous';
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RapportProvider>(context, listen: false).fetchRapports();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            _buildHeader(),
            const SizedBox(height: 24),
            
            // STATS CARDS
            _buildStatsCards(),
            const SizedBox(height: 32),
            
            // FILTRES ET RECHERCHE
            _buildFiltersSection(),
            const SizedBox(height: 24),
            
            // LISTE DES RAPPORTS
            _buildRapportsList(),
          ],
        ),
      ),
      floatingActionButton: _buildFab(),
    );
  }

  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Rapports IA",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1B5E20),
          ),
        ),
        SizedBox(height: 4),
        Text(
          "Analysez vos données agricoles avec l'intelligence artificielle",
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildStatsCards() {
    return Consumer<RapportProvider>(
      builder: (context, provider, _) {
        return Row(
          children: [
            Expanded(
              child: _buildStatCard(
                "Total Rapports",
                provider.rapports.length.toString(),
                Icons.description,
                Colors.blue,
                "${provider.rapports.length} rapports",
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: _buildStatCard(
                "Générés par IA",
                provider.rapports.where((r) => r.generatedAt != null).length.toString(),
                Icons.auto_awesome,
                Colors.purple,
                "Auto-générés",
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, String badgeText) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildFiltersSection() {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFEEEEEE)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  "Filtres",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _filterPeriode = 'tous');
                  },
                  child: const Text("Réinitialiser"),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Barre de recherche
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Rechercher un rapport...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
                ),
              ),
              onChanged: (value) {
                // Implémenter filtrage
              },
            ),
            const SizedBox(height: 16),
            // Chips de période
            Wrap(
              spacing: 8,
              children: [
                _buildPeriodChip('tous', 'Tous'),
                _buildPeriodChip('jour', 'Jour'),
                _buildPeriodChip('semaine', 'Semaine'),
                _buildPeriodChip('mois', 'Mois'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodChip(String value, String label) {
    final isSelected = _filterPeriode == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _filterPeriode = value);
      },
      backgroundColor: Colors.grey[100],
      selectedColor: const Color(0xFF21A84D).withOpacity(0.2),
      checkmarkColor: const Color(0xFF21A84D),
    );
  }

  Widget _buildRapportsList() {
    return Consumer<RapportProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.rapports.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.rapports.isEmpty) {
          return _buildEmptyState();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Vos Rapports",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  "${provider.rapports.length} rapport(s)",
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...provider.rapports.map((rapport) => _buildRapportCard(rapport)),
          ],
        );
      },
    );
  }

  Widget _buildRapportCard(Rapport rapport) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFEEEEEE)),
      ),
      child: InkWell(
        onTap: () => _showRapportDetail(rapport),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    _getPeriodeIcon(rapport.periode),
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          rapport.titre,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getPeriodeLabel(rapport.periode),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildPeriodeChip(rapport.periode),
                ],
              ),
              const SizedBox(height: 12),
              // Ligne de métadonnées
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('dd/MM/yyyy').format(rapport.createdAt),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  if (rapport.temperature != null) ...[
                    const SizedBox(width: 16),
                    const Icon(Icons.thermostat, size: 14, color: Colors.orange),
                    const SizedBox(width: 4),
                    Text(
                      '${rapport.temperature!.toStringAsFixed(1)}°C',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                  if (rapport.humidite != null) ...[
                    const SizedBox(width: 16),
                    const Icon(Icons.water_drop, size: 14, color: Colors.blue),
                    const SizedBox(width: 4),
                    Text(
                      '${rapport.humidite}%',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodeChip(String periode) {
    Color color;
    switch (periode.toLowerCase()) {
      case 'jour':
        color = Colors.blue;
        break;
      case 'semaine':
        color = Colors.green;
        break;
      case 'mois':
        color = Colors.purple;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        periode.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _getPeriodeIcon(String periode) {
    switch (periode.toLowerCase()) {
      case 'jour':
        return '📅';
      case 'semaine':
        return '📊';
      case 'mois':
        return '📈';
      default:
        return '📄';
    }
  }

  String _getPeriodeLabel(String periode) {
    switch (periode.toLowerCase()) {
      case 'jour':
        return 'Journalier';
      case 'semaine':
        return 'Hebdomadaire';
      case 'mois':
        return 'Mensuel';
      default:
        return periode;
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.description, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            "Aucun rapport",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Générez votre premier rapport IA",
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildFab() {
    return Consumer<RapportProvider>(
      builder: (context, provider, _) {
        return FloatingActionButton.extended(
          onPressed: provider.isGenerating ? null : () => _showGenerateDialog(),
          backgroundColor: const Color(0xFF21A84D),
          icon: provider.isGenerating
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.auto_awesome, color: Colors.white),
          label: Text(
            provider.isGenerating ? 'Génération...' : 'Générer IA',
            style: const TextStyle(color: Colors.white),
          ),
        );
      },
    );
  }

  void _showGenerateDialog() {
    // Dialog redesigné selon le style
  }

  void _showRapportDetail(Rapport rapport) {
    // Navigation vers l'écran de détail
  }
}
```

---

## 📝 Dialog de Génération IA (Nouveau Design)

```dart
void _showGenerateDialog() {
  String selectedPeriode = 'semaine';
  String titre = '';

  showDialog(
    context: context,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.5,
        constraints: const BoxConstraints(maxWidth: 500),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Générer un Rapport IA",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B5E20),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Période du rapport *",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildPeriodRadio('jour', 'Jour', selectedPeriode),
                        _buildPeriodRadio('semaine', 'Semaine', selectedPeriode),
                        _buildPeriodRadio('mois', 'Mois', selectedPeriode),
                      ],
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: "Titre personnalisé (optionnel)",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: (value) => titre = value,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFEEEEEE)),
                        ),
                        child: const Text("Annuler"),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          // Logique de génération
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF21A84D),
                        ),
                        child: const Text(
                          "Générer",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget _buildPeriodRadio(String value, String label, String groupValue) {
  return Expanded(
    child: RadioListTile<String>(
      title: Text(label),
      value: value,
      groupValue: groupValue,
      onChanged: (v) {},
      contentPadding: EdgeInsets.zero,
    ),
  );
}
```

---

## 📁 Fichiers à Modifier

| Fichier | Action |
|---------|--------|
| `lib/screens/rapport_screen.dart` | Refonte complète |
| `lib/screens/rapport_screen_new.dart` | Supprimer ou remplacer |
| `lib/main.dart` | Mise à jour route si nécessaire |

---

## ✅ Checklist

- [ ] Header avec titre et sous-titre
- [ ] 2 cartes statistiques (Total, IA)
- [ ] Section filtres avec recherche
- [ ] Chips de période fonctionnels
- [ ] Liste de rapports avec cards professionnelles
- [ ] Dialog de génération redesigné
- [ ] Bouton flottant stylisé
- [ ] État vide (aucun rapport)
- [ ] Responsive (adaptation mobile)

---

*Plan généré le ${DateTime.now().toString()}*

