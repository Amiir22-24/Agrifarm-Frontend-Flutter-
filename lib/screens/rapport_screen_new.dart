// lib/screens/rapport_screen_new.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import '../providers/rapport_provider.dart';
import '../models/rapport.dart';
import '../utils/pdf_generator.dart';
import '../widgets/rapports/loading_spinner.dart';
import '../widgets/rapports/error_message.dart';
import '../widgets/rapports/success_message.dart';
import '../widgets/rapports/confirm_dialog.dart';
import '../widgets/rapports/search_bar.dart' as search_widgets;
import '../widgets/rapports/sort_button.dart';

class RapportScreen extends StatefulWidget {
  const RapportScreen({Key? key}) : super(key: key);

  @override
  State<RapportScreen> createState() => _RapportScreenState();
}

class _RapportScreenState extends State<RapportScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _filtrePeriode = 'tous';
  String _triPar = 'created_at';
  bool _ordreDesc = true;
  Set<int> _selection = {};
  bool _modeSelection = false;
  bool _showFilters = false;

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
      appBar: _buildAppBar(),
      body: Consumer<RapportProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.rapports.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null && provider.rapports.isEmpty) {
            return _buildErrorState(provider);
          }

          if (provider.rapports.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () => provider.refreshWithFilters(),
            child: Column(
              children: [
                // Barre de recherche et filtres
                _buildSearchAndFilters(),
                // Messages de succès/erreur
                if (provider.successMessage != null) ...[
                  _buildSuccessMessage(provider),
                  const SizedBox(height: 8),
                ],
                // Actions en lot
                if (provider.isSelectionMode) _buildBatchActions(),
                // Liste des rapports
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: provider.filteredRapports.length,
                    itemBuilder: (context, index) {
                      final rapport = provider.filteredRapports[index];
                      return ImprovedRapportCard(
                        rapport: rapport,
                        isSelected: provider.isSelected(rapport.id!),
                        isSelectionMode: provider.isSelectionMode,
                        onTap: () => _showRapportDetail(rapport),
                        onSelect: () => provider.toggleSelection(rapport.id!),
                        onDelete: () => _deleteRapport(rapport.id!),
                        onDownload: () => _downloadRapport(rapport.id!),
                        onShare: () => _shareRapport(rapport.id!),
                        onCopy: () => _copyRapport(rapport.id!),
                      );
                    },
                  ),
                ),
                // Pagination (si nécessaire)
                if (provider.totalPages > 1) _buildPagination(),
              ],
            ),
          );
        },
      ),
      floatingActionButton: _buildFloatingActionButton(),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Rapports', style: TextStyle(color: Colors.white)),
      backgroundColor: const Color(0xFF21A84D), // AgriFarm Green
      foregroundColor: Colors.white,
      elevation: 0,
      actions: [
        // Bouton de rafraîchissement
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: () {
            Provider.of<RapportProvider>(context, listen: false)
                .refreshWithFilters();
          },
        ),
        // Bouton de filtres
        IconButton(
          icon: Icon(_showFilters ? Icons.filter_list : Icons.filter_list_off, color: Colors.white),
          onPressed: () {
            setState(() {
              _showFilters = !_showFilters;
            });
          },
        ),
        // Menu de tri
        _buildSortMenu(),
      ],
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Barre de recherche
          search_widgets.SearchBar(
            hintText: 'Rechercher dans les rapports...',
            initialValue: _searchController.text,
            onChanged: (value) {
              _searchController.text = value;
              Provider.of<RapportProvider>(context, listen: false)
                  .updateSearch(value);
            },
            onClear: () {
              _searchController.clear();
              Provider.of<RapportProvider>(context, listen: false)
                  .updateSearch('');
            },
          ),
          if (_showFilters) ...[
            const SizedBox(height: 12),
            // Filtres par période
            Row(
              children: [
                const Text(
                  'Période: ',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    children: [
                      _buildFilterChip('tous', 'Tous'),
                      _buildFilterChip('jour', 'Jour'),
                      _buildFilterChip('semaine', 'Semaine'),
                      _buildFilterChip('mois', 'Mois'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Boutons d'action
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Provider.of<RapportProvider>(context, listen: false)
                          .resetFilters();
                      _searchController.clear();
                    },
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Réinitialiser'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showAdvancedFilters(),
                    icon: const Icon(Icons.tune, size: 16),
                    label: const Text('Avancé'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final provider = Provider.of<RapportProvider>(context, listen: false);
    final isSelected = provider.filterPeriode == value;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        provider.updateFilter(value);
      },
      backgroundColor: Colors.grey[200],
      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
      checkmarkColor: Theme.of(context).primaryColor,
      labelStyle: TextStyle(
        color: isSelected
            ? Theme.of(context).primaryColor
            : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Widget _buildSortMenu() {
    final provider = Provider.of<RapportProvider>(context, listen: false);
    
    return PopupMenuButton<String>(
      icon: const Icon(Icons.sort),
      onSelected: (value) {
        if (value == 'asc' || value == 'desc') {
          provider.updateSort(provider.sortBy, value == 'desc');
        } else {
          provider.updateSort(value, provider.sortDesc);
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'created_at',
          child: Text('Trier par date'),
        ),
        const PopupMenuItem(
          value: 'titre',
          child: Text('Trier par titre'),
        ),
        const PopupMenuItem(
          value: 'periode',
          child: Text('Trier par période'),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'asc',
          child: Text('Croissant'),
        ),
        const PopupMenuItem(
          value: 'desc',
          child: Text('Décroissant'),
        ),
      ],
    );
  }

  Widget _buildBatchActions() {
    final provider = Provider.of<RapportProvider>(context, listen: false);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        border: Border(
          bottom: BorderSide(color: Colors.blue[200]!),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.select_all, color: Colors.blue[600]),
          const SizedBox(width: 8),
          Text(
            '${provider.selectedCount} sélectionné(s)',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.blue[800],
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: () => provider.selectAll(),
            child: const Text('Tout sélectionner'),
          ),
          TextButton(
            onPressed: () => provider.clearSelection(),
            child: const Text('Désélectionner'),
          ),
          ElevatedButton.icon(
            onPressed: () => _showBatchDeleteDialog(),
            icon: const Icon(Icons.delete, size: 16),
            label: const Text('Supprimer'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessMessage(provider) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green[600], size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              provider.successMessage,
              style: TextStyle(
                color: Colors.green[800],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 16),
            onPressed: () => provider.clearSuccessMessage(),
          ),
        ],
      ),
    );
  }

  Widget _buildPagination() {
    final provider = Provider.of<RapportProvider>(context, listen: false);
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: provider.currentPage > 1
                ? () => provider.previousPage()
                : null,
          ),
          const SizedBox(width: 16),
          Text(
            'Page ${provider.currentPage} sur ${provider.totalPages}',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 16),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: provider.currentPage < provider.totalPages
                ? () => provider.nextPage()
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.description, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Aucun rapport',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Generer votre premier rapport pour commencer',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showGenerateDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Generer un rapport'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF21A84D), // AgriFarm Green
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Consumer<RapportProvider>(
      builder: (context, provider, _) {
        return FloatingActionButton.extended(
          onPressed: provider.isGenerating
              ? null
              : () => _showGenerateDialog(),
          backgroundColor: const Color(0xFF21A84D), // AgriFarm Green
          icon: provider.isGenerating
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.add),
          label: Text(
            provider.isGenerating ? 'Generation...' : 'Nouveau',
          ),
        );
      },
    );
  }

  Widget _buildBottomBar() {
    final provider = Provider.of<RapportProvider>(context, listen: false);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(
          top: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Row(
        children: [
          Text(
            '${provider.totalFilteredRapports} rapport(s)',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.grid_view),
            onPressed: () => _toggleViewMode(),
            tooltip: 'Changer de vue',
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showMoreOptions(),
            tooltip: 'Plus d\'options',
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(RapportProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
          const SizedBox(height: 16),
          Text(
            'Erreur de chargement',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            provider.error ?? 'Une erreur est survenue',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => provider.fetchRapports(),
            icon: const Icon(Icons.refresh),
            label: const Text('Réessayer'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _showGenerateDialog() {
    String selectedPeriode = 'semaine';
    String titre = '';
    bool includeWeather = true;
    bool includeSales = true;
    bool includeRecommendations = true;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Générer un Rapport IA'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Période
                  const Text(
                    'Sélectionnez la période :',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  ...['jour', 'semaine', 'mois'].map((periode) {
                    return RadioListTile<String>(
                      title: Text(periode.toUpperCase()),
                      value: periode,
                      groupValue: selectedPeriode,
                      onChanged: (value) {
                        setState(() => selectedPeriode = value!);
                      },
                    );
                  }).toList(),
                  
                  const SizedBox(height: 16),
                  
                  // Titre personnalisé
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Titre personnalisé (optionnel)',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => titre = value,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Options avancées
                  const Text(
                    'Options avancées :',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  CheckboxListTile(
                    title: const Text('Inclure les données météo'),
                    value: includeWeather,
                    onChanged: (value) {
                      setState(() => includeWeather = value!);
                    },
                  ),
                  CheckboxListTile(
                    title: const Text('Inclure les ventes'),
                    value: includeSales,
                    onChanged: (value) {
                      setState(() => includeSales = value!);
                    },
                  ),
                  CheckboxListTile(
                    title: const Text('Inclure les recommandations'),
                    value: includeRecommendations,
                    onChanged: (value) {
                      setState(() => includeRecommendations = value!);
                    },
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
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
                  SnackBar(
                    content: Text('Rapport généré avec succès !'),
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
            child: const Text('Générer'),
          ),
        ],
      ),
    );
  }

  void _showAdvancedFilters() {
    // TODO: Implémenter les filtres avancés
  }

  void _toggleViewMode() {
    // TODO: Implémenter le changement de vue (liste/grille)
  }

  void _showMoreOptions() {
    // TODO: Implémenter le menu d'options
  }

  void _showRapportDetail(Rapport rapport) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImprovedRapportDetailScreen(rapport: rapport),
      ),
    );
  }

  Future<void> _deleteRapport(int id) async {
    final provider = Provider.of<RapportProvider>(context, listen: false);
    
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => DeleteConfirmDialog(
        itemName: 'ce rapport',
        onConfirm: () {},
      ),
    );

    if (confirm == true && mounted) {
      final success = await provider.deleteRapport(id);
      
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Rapport supprimé'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(provider.error ?? 'Erreur'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _downloadRapport(int id) async {
    final provider = Provider.of<RapportProvider>(context, listen: false);
    
    // Trouver le rapport correspondant
    final rapport = provider.rapports.firstWhere((r) => r.id == id);
    if (rapport == null) return;

    // Afficher un indicateur de progression
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Génération du PDF en cours...'),
        backgroundColor: Colors.blue,
      ),
    );

    try {
      // Générer le PDF professionnel
      final pdfBytes = await PdfGenerator.generateRapportPdf(rapport);
      
      // Générer le nom du fichier
      final fileName = PdfGenerator.generateFileName(rapport);
      
      // Sauvegarder le PDF
      final filePath = await PdfGenerator.savePdfToFile(
        pdfBytes: pdfBytes,
        fileName: fileName,
      );

      if (!mounted) return;

      // Afficher une boîte de dialogue avec les options
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('PDF Généré avec succès !'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 48),
              const SizedBox(height: 16),
              Text('Fichier sauvegardé:\n$fileName'),
              const SizedBox(height: 8),
              Text(
                filePath,
                style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fermer'),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                Navigator.pop(context);
                // Ouvrir le PDF
                final result = await OpenFile.open(filePath);
                if (!mounted) return;
                
                if (result.type != ResultType.done) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erreur: ${result.message}'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              },
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Ouvrir le PDF'),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Fichier ouvert: $filePath'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              icon: const Icon(Icons.folder_open),
              label: const Text('Ouvrir le dossier'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur de génération PDF: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _shareRapport(int id) async {
    final provider = Provider.of<RapportProvider>(context, listen: false);
    
    try {
      await provider.shareRapport(id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Rapport partagé'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur de partage: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _copyRapport(int id) async {
    final provider = Provider.of<RapportProvider>(context, listen: false);
    
    try {
      await provider.copyRapportContent(id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Contenu copié dans le presse-papiers'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur de copie: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showBatchDeleteDialog() {
    final provider = Provider.of<RapportProvider>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) => BatchActionConfirmDialog(
        action: 'Supprimer',
        itemCount: provider.selectedCount,
        onConfirm: () async {
          final success = await provider.deleteSelected();
          if (mounted) {
            if (success) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Rapports supprimés avec succès'),
                  backgroundColor: Colors.green,
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(provider.error ?? 'Erreur'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
      ),
    );
  }
}

// Card améliorée pour les rapports
class ImprovedRapportCard extends StatelessWidget {
  final Rapport rapport;
  final bool isSelected;
  final bool isSelectionMode;
  final VoidCallback onTap;
  final VoidCallback onSelect;
  final VoidCallback onDelete;
  final VoidCallback onDownload;
  final VoidCallback onShare;
  final VoidCallback onCopy;

  const ImprovedRapportCard({
    Key? key,
    required this.rapport,
    required this.isSelected,
    required this.isSelectionMode,
    required this.onTap,
    required this.onSelect,
    required this.onDelete,
    required this.onDownload,
    required this.onShare,
    required this.onCopy,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFEEEEEE)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: isSelectionMode ? onSelect : onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header avec sélection
              Row(
                children: [
                  if (isSelectionMode) ...[
                    Checkbox(
                      value: isSelected,
                      onChanged: (_) => onSelect(),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Text(
                    rapport.typeIcon,
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
                          rapport.periodeDisplay,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Menu d'actions
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (value) {
                      switch (value) {
                        case 'view':
                          onTap();
                          break;
                        case 'download':
                          onDownload();
                          break;
                        case 'share':
                          onShare();
                          break;
                        case 'copy':
                          onCopy();
                          break;
                        case 'delete':
                          onDelete();
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'view',
                        child: ListTile(
                          leading: Icon(Icons.visibility),
                          title: Text('Voir'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'download',
                        child: ListTile(
                          leading: Icon(Icons.download),
                          title: Text('Télécharger'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'share',
                        child: ListTile(
                          leading: Icon(Icons.share),
                          title: Text('Partager'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'copy',
                        child: ListTile(
                          leading: Icon(Icons.copy),
                          title: Text('Copier'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: ListTile(
                          leading: Icon(Icons.delete, color: Colors.red),
                          title: Text('Supprimer'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Aperçu du contenu
              if (rapport.contenu.isNotEmpty) ...[
                Text(
                  rapport.contenu.length > 120
                      ? '${rapport.contenu.substring(0, 120)}...'
                      : rapport.contenu,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 12),
              ],
              
              // Données météo
              if (rapport.aDonneesMeteo) ...[
                Row(
                  children: [
                    Icon(Icons.wb_sunny, size: 16, color: Colors.orange[600]),
                    const SizedBox(width: 8),
                    if (rapport.temperature != null) ...[
                      Text('${rapport.temperature!.toStringAsFixed(1)}°C'),
                      const SizedBox(width: 16),
                    ],
                    if (rapport.humidite != null) ...[
                      Icon(Icons.water_drop, size: 16, color: Colors.blue[600]),
                      const SizedBox(width: 4),
                      Text('${rapport.humidite}%'),
                    ],
                  ],
                ),
                const SizedBox(height: 12),
              ],
              
              // Métadonnées
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 14, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(
                    'Créé le ${rapport.dateCompleteFormatee}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                  const Spacer(),
                  if (rapport.aTelechargement) ...[
                    Icon(Icons.download, size: 14, color: Colors.green[600]),
                    const SizedBox(width: 4),
                    Text(
                      'Téléchargeable',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green[600],
                      ),
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
}

// Écran de détail amélioré
class ImprovedRapportDetailScreen extends StatelessWidget {
  final Rapport rapport;

  const ImprovedRapportDetailScreen({Key? key, required this.rapport}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(rapport.titre, style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF21A84D), // AgriFarm Green
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () => _shareRapport(context),
          ),
          IconButton(
            icon: const Icon(Icons.download, color: Colors.white),
            onPressed: () => _downloadRapport(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header avec informations de base
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          rapport.typeIcon,
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
                                rapport.periodeDisplay,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      rapport.statusDisplay,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Données météo
            if (rapport.aDonneesMeteo)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Conditions météorologiques',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          if (rapport.temperature != null) ...[
                            Icon(Icons.thermostat, color: Colors.orange[600]),
                            const SizedBox(width: 8),
                            Text(
                              '${rapport.temperature!.toStringAsFixed(1)}°C',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(width: 24),
                          ],
                          if (rapport.humidite != null) ...[
                            Icon(Icons.water_drop, color: Colors.blue[600]),
                            const SizedBox(width: 8),
                            Text(
                              '${rapport.humidite}%',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            
            const SizedBox(height: 16),
            
            // Contenu du rapport
            if (rapport.contenu.isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Contenu du rapport',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        rapport.contenu,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            
            const SizedBox(height: 16),
            
            // Métadonnées détaillées
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Informations détaillées',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(Icons.calendar_today, 'Créé le', rapport.dateCompleteFormatee),
                    if (rapport.updatedAt != null) ...[
                      const SizedBox(height: 8),
                      _buildInfoRow(Icons.update, 'Modifié le', DateFormat('dd/MM/yyyy HH:mm').format(rapport.updatedAt!)),
                    ],
                    if (rapport.generatedAt != null) ...[
                      const SizedBox(height: 8),
                      _buildInfoRow(Icons.auto_awesome, 'Généré par IA le', DateFormat('dd/MM/yyyy HH:mm').format(rapport.generatedAt!)),
                    ],
                  ],
                ),
              ),
            ),
            
            // Prompt IA si disponible
            if (rapport.aAiPrompt) ...[
              const SizedBox(height: 16),
              Card(
                color: Colors.purple[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.smart_toy, color: Colors.purple[600]),
                          const SizedBox(width: 8),
                          const Text(
                            'Prompt IA utilisé',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        rapport.aiPrompt!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[500]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        Expanded(
          child: Text(value),
        ),
      ],
    );
  }

  void _shareRapport(BuildContext context) {
    // TODO: Implémenter le partage
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fonctionnalité de partage à venir'),
      ),
    );
  }

  void _downloadRapport(BuildContext context) {
    // TODO: Implémenter le téléchargement
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Téléchargement en cours...'),
      ),
    );
  }
}

