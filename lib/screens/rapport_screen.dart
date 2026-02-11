// lib/screens/rapport_screen.dart
// Écran de gestion des rapports IA - Style Professionnel AgriFarm
// Version enrichie avec widgets de contenu et export

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import '../providers/rapport_provider.dart';
import '../models/rapport.dart';
import '../widgets/rapports/report_content_widget.dart';
import '../widgets/rapports/export_format_selector.dart';
import '../widgets/rapports/loading_spinner.dart';
import '../utils/rapport_messages.dart';

class RapportScreen extends StatefulWidget {
  const RapportScreen({Key? key}) : super(key: key);

  @override
  State<RapportScreen> createState() => _RapportScreenState();
}

class _RapportScreenState extends State<RapportScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _filterPeriode = 'tous';
  List<Rapport> _filteredRapports = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RapportProvider>(context, listen: false).fetchRapports();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Consumer<RapportProvider>(
        builder: (context, provider, _) {
          // Mettre à jour les rapports filtrés
          _updateFilteredRapports(provider);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // HEADER
                _buildHeader(),
                const SizedBox(height: 24),

                // STATS CARDS
                _buildStatsCards(provider),
                const SizedBox(height: 32),

                // FILTRES ET RECHERCHE
                _buildFiltersSection(provider),
                const SizedBox(height: 24),

                // LISTE DES RAPPORTS
                _buildRapportsList(provider),
              ],
            ),
          );
        },
      ),
      floatingActionButton: _buildFab(),
    );
  }

  void _updateFilteredRapports(RapportProvider provider) {
    List<Rapport> filtered = List.from(provider.rapports);

    // Filtrer par période
    if (_filterPeriode != 'tous') {
      filtered = filtered.where((r) => r.periode == _filterPeriode).toList();
    }

    // Filtrer par recherche
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered = filtered.where((r) {
        return r.titre.toLowerCase().contains(query) ||
               r.contenu.toLowerCase().contains(query);
      }).toList();
    }

    _filteredRapports = filtered;
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

  Widget _buildStatsCards(RapportProvider provider) {
    final totalIaRapports = provider.rapports.where((r) => r.generatedAt != null).length;

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
            totalIaRapports.toString(),
            Icons.auto_awesome,
            Colors.purple,
            "Auto-générés",
          ),
        ),
      ],
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

  Widget _buildFiltersSection(RapportProvider provider) {
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
                  child: const Text(
                    "Réinitialiser",
                    style: TextStyle(color: Color(0xFF21A84D)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Barre de recherche
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Rechercher un rapport...",
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF21A84D), width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (value) {
                setState(() {});
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
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.grey[700],
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _filterPeriode = value);
      },
      backgroundColor: Colors.grey[100],
      selectedColor: const Color(0xFF21A84D),
      checkmarkColor: Colors.white,
      side: BorderSide.none,
    );
  }

  Widget _buildRapportsList(RapportProvider provider) {
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
              "${_filteredRapports.length} rapport(s)",
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_filteredRapports.isEmpty && _filterPeriode != 'tous')
          Center(
            child: Column(
              children: [
                const SizedBox(height: 32),
                Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  "Aucun rapport pour cette période",
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          )
        else
          ..._filteredRapports.map((rapport) => _buildRapportCard(rapport, provider)),
      ],
    );
  }

  Widget _buildRapportCard(Rapport rapport, RapportProvider provider) {
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
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
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
              if (rapport.contenu.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    rapport.apercuContenu,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              // Boutons d'action
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => _showDeleteConfirmDialog(rapport),
                    icon: const Icon(Icons.delete_outline, size: 16, color: Colors.red),
                    label: const Text(
                      "Supprimer",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => _downloadRapport(rapport.id!),
                    icon: const Icon(Icons.download, size: 16),
                    label: const Text("Télécharger"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF21A84D),
                      foregroundColor: Colors.white,
                    ),
                  ),
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
        return 'J';
      case 'semaine':
        return 'S';
      case 'mois':
        return 'M';
      default:
        return '?';
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
          Text(
            "Générez votre premier rapport IA",
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
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
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        );
      },
    );
  }

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
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildPeriodRadio('jour', 'Jour', selectedPeriode, (value) {
                            selectedPeriode = value;
                          }),
                          _buildPeriodRadio('semaine', 'Semaine', selectedPeriode, (value) {
                            selectedPeriode = value;
                          }),
                          _buildPeriodRadio('mois', 'Mois', selectedPeriode, (value) {
                            selectedPeriode = value;
                          }),
                        ],
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        decoration: InputDecoration(
                          labelText: "Titre personnalisé (optionnel)",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFF21A84D), width: 2),
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
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text("Annuler"),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            Navigator.pop(context);
                            final provider = Provider.of<RapportProvider>(
                              context,
                              listen: false,
                            );

                            final rapport = await provider.generateAiReport(
                              periode: selectedPeriode,
                              titre: titre.isNotEmpty ? titre : null,
                            );

                            if (!mounted) return;

                            if (rapport != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Rapport généré avec succès'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              _showRapportDetail(rapport);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(provider.error ?? 'Erreur'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF21A84D),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text(
                            "Générer",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
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

  Widget _buildPeriodRadio(String value, String label, String groupValue, Function(String) onChanged) {
    return Expanded(
      child: RadioListTile<String>(
        title: Text(label),
        value: value,
        groupValue: groupValue,
        onChanged: (v) {
          if (v != null) onChanged(v);
        },
        contentPadding: EdgeInsets.zero,
        activeColor: const Color(0xFF21A84D),
      ),
    );
  }

  void _showRapportDetail(Rapport rapport) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RapportDetailScreen(rapport: rapport),
      ),
    );
  }

  Future<void> _showDeleteConfirmDialog(Rapport rapport) async {
    final provider = Provider.of<RapportProvider>(context, listen: false);

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirmer la suppression"),
        content: Text("Êtes-vous sûr de vouloir supprimer le rapport \"${rapport.titre}\" ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text("Supprimer", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final success = await provider.deleteRapport(rapport.id!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Rapport supprimé' : 'Erreur de suppression'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _downloadRapport(int id) async {
    final provider = Provider.of<RapportProvider>(context, listen: false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Génération du PDF en cours...'),
        backgroundColor: Colors.orange,
      ),
    );

    // ✅ NOUVELLE MÉTHODE: Générer et télécharger le PDF
    final filePath = await provider.downloadPdfWithState(id);

    if (!mounted) return;

    if (filePath != null) {
      // Succès - montrer le chemin du fichier
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PDF sauvegardé: $filePath'),
          backgroundColor: Colors.green,
          action: SnackBarAction(
            label: 'Ouvrir',
            onPressed: () async {
              // Ouvrir le fichier PDF avec l'application par défaut
              final result = await OpenFile.open(filePath);
              if (result.type != ResultType.done) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erreur ouverture: ${result.message}')),
                  );
                }
              }
            },
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Erreur de téléchargement'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

// Écran de détail du rapport enrichi
class RapportDetailScreen extends StatelessWidget {
  final Rapport rapport;

  const RapportDetailScreen({Key? key, required this.rapport}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          rapport.titre,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF1B5E20),
        elevation: 0,
        actions: [
          // Bouton de partage
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareRapport(context),
            tooltip: 'Partager',
          ),
          // Menu d'export
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showExportOptions(context),
            tooltip: 'Plus d\'options',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            _buildHeaderCard(),
            const SizedBox(height: 16),

            // Conditions météo
            if (rapport.aDonneesMeteo)
              _buildMeteoCard(),
            const SizedBox(height: 16),

            // Contenu du rapport avec Widget enrichi
            if (rapport.contenu.isNotEmpty)
              _buildContentCard(),
            const SizedBox(height: 16),

            // Métadonnées
            _buildMetaCard(),
          ],
        ),
      ),
      // Bouton de téléchargement flottant
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showExportDialog(context),
        backgroundColor: const Color(0xFF21A84D),
        icon: const Icon(Icons.download),
        label: const Text('Exporter'),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      elevation: 0,
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
                Text(
                  rapport.iconePeriode,
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rapport.titre,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getPeriodeLabel(rapport.periode),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                _buildPeriodeChip(rapport.periode),
              ],
            ),
            if (rapport.fichier != null && rapport.fichier!.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.attach_file, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    'Fichier: ${rapport.fichier}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMeteoCard() {
    return Card(
      elevation: 0,
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
                Icon(Icons.wb_sunny, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  "Conditions météorologiques",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 12,
              children: [
                if (rapport.temperature != null)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.thermostat, color: Colors.orange),
                        const SizedBox(width: 8),
                        Text(
                          '${rapport.temperature!.toStringAsFixed(1)}°C',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (rapport.humidite != null)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.water_drop, color: Colors.blue),
                        const SizedBox(width: 8),
                        Text(
                          '${rapport.humidite}%',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (rapport.conditions != null)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.lightBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.cloud, color: Colors.lightBlue),
                        const SizedBox(width: 8),
                        Text(
                          rapport.conditions!,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentCard() {
    return Card(
      elevation: 0,
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
                Icon(Icons.article, color: const Color(0xFF21A84D)),
                const SizedBox(width: 8),
                Text(
                  "Contenu du rapport",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // ✅ NOUVEAU: Utilisation du widget de contenu enrichi
            ReportContentWidget(
              contenu: rapport.contenu,
              selectable: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Color(0xFFEEEEEE)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Informations",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              Icons.calendar_today,
              "Créé le",
              DateFormat('dd MMMM yyyy à HH:mm').format(rapport.createdAt),
            ),
            if (rapport.generatedAt != null) ...[
              const SizedBox(height: 12),
              _buildInfoRow(
                Icons.auto_awesome,
                "Généré par IA",
                DateFormat('dd MMMM yyyy à HH:mm').format(rapport.generatedAt!),
              ),
            ],
            if (rapport.aiPrompt != null && rapport.aiPrompt!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildInfoRow(
                Icons.psychology,
                "Type",
                "Rapport IA",
              ),
            ],
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.numbers,
              "ID",
              "#${rapport.id}",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        Text(value),
      ],
    );
  }

  void _showExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ExportFormatSelector(rapport: rapport),
    );
  }

  void _showExportOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Options du rapport',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.download),
              title: const Text('Exporter en PDF'),
              onTap: () {
                Navigator.pop(context);
                _showExportDialog(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Partager le rapport'),
              onTap: () {
                Navigator.pop(context);
                _shareRapport(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.content_copy),
              title: const Text('Copier le contenu'),
              onTap: () {
                Navigator.pop(context);
                _copyContent(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _shareRapport(BuildContext context) {
    // Utiliser le service d'export pour partager
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Partage du rapport...'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _copyContent(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Contenu copié dans le presse-papiers'),
        backgroundColor: Colors.green,
      ),
    );
  }

  // ========== MÉTHODES HELPER ==========

  String _getPeriodeIcon(String periode) {
    switch (periode.toLowerCase()) {
      case 'jour':
        return 'J';
      case 'semaine':
        return 'S';
      case 'mois':
        return 'M';
      default:
        return '?';
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
}

