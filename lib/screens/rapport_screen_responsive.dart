// lib/screens/rapport_screen_responsive.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/rapport_provider.dart';
import '../models/rapport.dart';
import '../utils/rapport_messages.dart';
import '../services/export_service.dart';
import '../widgets/rapports/loading_spinner.dart';
import '../widgets/rapports/error_message.dart';
import '../widgets/rapports/search_bar.dart' as search_bar;
import '../widgets/rapports/sort_button.dart' as sort_button;

/// Écran responsive des rapports avec interface mobile optimisée
class RapportScreenResponsive extends StatefulWidget {
  const RapportScreenResponsive({Key? key}) : super(key: key);

  @override
  State<RapportScreenResponsive> createState() => _RapportScreenResponsiveState();
}

class _RapportScreenResponsiveState extends State<RapportScreenResponsive> {
  @override
  void initState() {
    super.initState();
    // Charger les rapports au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RapportProvider>().fetchRapports();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(RapportMessages.rapportsIA),
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          // Bouton de génération rapide
          IconButton(
            icon: const Icon(Icons.auto_awesome),
            onPressed: () => _showGenerateDialog(),
            tooltip: RapportMessages.genererRapport,
          ),
          // Menu d'actions
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'refresh',
                child: Row(
                  children: [
                    const Icon(Icons.refresh),
                    const SizedBox(width: 8),
                    Text('Actualiser'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'filters',
                child: Row(
                  children: [
                    const Icon(Icons.filter_list),
                    const SizedBox(width: 8),
                    Text(RapportMessages.filtres),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'stats',
                child: Row(
                  children: [
                    const Icon(Icons.analytics),
                    const SizedBox(width: 8),
                    Text('Statistiques'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<RapportProvider>(
        builder: (context, provider, child) {
          return RefreshIndicator(
            onRefresh: () => provider.refreshWithFilters(),
            child: Column(
              children: [
                // Barre de recherche et filtres
                _buildSearchAndFilters(context, provider),
                
                // Messages de succès/erreur
                if (provider.successMessage != null) ...[
                  Container(
                    margin: const EdgeInsets.all(8),
                    child: Card(
                      color: Colors.green[50],
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.green[600]),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                provider.successMessage!,
                                style: TextStyle(
                                  color: Colors.green[800],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () => provider.clearSuccessMessage(),
                              icon: const Icon(Icons.close, size: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
                
                // Contenu principal
                Expanded(
                  child: _buildMainContent(context, provider),
                ),
              ],
            ),
          );
        },
      ),
      // Bouton flottant pour génération rapide
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showGenerateDialog(),
        icon: const Icon(Icons.add),
        label: Text(RapportMessages.genererRapport),
        tooltip: 'Générer un nouveau rapport IA',
      ),
    );
  }

  /// Construire la barre de recherche et filtres
  Widget _buildSearchAndFilters(BuildContext context, RapportProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Barre de recherche responsive
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 600) {
                // Mode mobile: barre de recherche en plein largeur
                return Column(
                  children: [
                    search_bar.SearchBar(
                      onChanged: provider.updateSearch,
                      hintText: RapportMessages.rechercheRapports,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        // Filtre de période
                        Expanded(
                          child: _buildPeriodeFilter(provider),
                        ),
                        const SizedBox(width: 8),
                        // Bouton de tri
                        SizedBox(
                          width: 120,
                          child: _buildSortButton(provider),
                        ),
                      ],
                    ),
                  ],
                );
              } else {
                // Mode desktop: disposition en ligne
                return Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: search_bar.SearchBar(
                        onChanged: provider.updateSearch,
                        hintText: RapportMessages.rechercheRapports,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildPeriodeFilter(provider),
                    ),
                    const SizedBox(width: 8),
                    _buildSortButton(provider),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  /// Construire le bouton de tri avec la bonne signature
  Widget _buildSortButton(RapportProvider provider) {
    return sort_button.SortButton(
      currentSort: provider.sortBy,
      isDescending: provider.sortDesc,
      onSortChanged: (sortBy) => provider.updateSort(sortBy, provider.sortDesc),
      onSortOrderChanged: (isDescending) => provider.updateSort(provider.sortBy, isDescending),
      sortOptions: [
        sort_button.SortOption(
          value: 'created_at',
          label: 'Date de création',
          icon: Icons.calendar_today,
        ),
        sort_button.SortOption(
          value: 'titre',
          label: 'Titre',
          icon: Icons.title,
        ),
        sort_button.SortOption(
          value: 'periode',
          label: 'Période',
          icon: Icons.schedule,
        ),
      ],
    );
  }

  /// Construire le filtre de période
  Widget _buildPeriodeFilter(RapportProvider provider) {
    return DropdownButtonFormField<String>(
      value: provider.filterPeriode,
      decoration: InputDecoration(
        labelText: RapportMessages.periode,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: [
        DropdownMenuItem(
          value: 'tous',
          child: Text(RapportMessages.tous),
        ),
        DropdownMenuItem(
          value: 'jour',
          child: Text('${RapportMessages.jour} 📅'),
        ),
        DropdownMenuItem(
          value: 'semaine',
          child: Text('${RapportMessages.semaine} 📊'),
        ),
        DropdownMenuItem(
          value: 'mois',
          child: Text('${RapportMessages.mois} 📈'),
        ),
      ],
      onChanged: (value) {
        if (value != null) {
          provider.updateFilter(value);
        }
      },
    );
  }

  /// Construire le contenu principal
  Widget _buildMainContent(BuildContext context, RapportProvider provider) {
    if (provider.isLoading && provider.rapports.isEmpty) {
      return const Center(child: LoadingSpinner(message: 'Chargement des rapports...'));
    }

    if (provider.error != null) {
      return ErrorMessage(
        error: provider.error!,
        onRetry: () => provider.fetchRapports(),
      );
    }

    if (provider.filteredRapports.isEmpty) {
      return _buildEmptyState(context, provider);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          // Mode mobile: liste verticale
          return _buildMobileList(context, provider);
        } else if (constraints.maxWidth < 900) {
          // Mode tablette: grille 2 colonnes
          return _buildTabletGrid(context, provider, 2);
        } else {
          // Mode desktop: grille 3-4 colonnes
          return _buildDesktopGrid(context, provider, 3);
        }
      },
    );
  }

  /// État vide
  Widget _buildEmptyState(BuildContext context, RapportProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.description_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            provider.searchQuery.isNotEmpty || provider.filterPeriode != 'tous'
                ? RapportMessages.aucunResultat
                : RapportMessages.aucunRapport,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          if (provider.searchQuery.isEmpty && provider.filterPeriode == 'tous')
            ElevatedButton.icon(
              onPressed: () => _showGenerateDialog(),
              icon: const Icon(Icons.add),
              label: Text(RapportMessages.genererRapport),
            ),
          if (provider.searchQuery.isNotEmpty || provider.filterPeriode != 'tous')
            OutlinedButton.icon(
              onPressed: () => provider.resetFilters(),
              icon: const Icon(Icons.clear),
              label: const Text('Effacer les filtres'),
            ),
        ],
      ),
    );
  }

  /// Liste mobile
  Widget _buildMobileList(BuildContext context, RapportProvider provider) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: provider.filteredRapports.length,
      itemBuilder: (context, index) {
        final rapport = provider.filteredRapports[index];
        return _buildMobileCard(context, rapport, provider);
      },
    );
  }

  /// Carte mobile
  Widget _buildMobileCard(BuildContext context, Rapport rapport, RapportProvider provider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _openRapportDetails(rapport),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header avec titre et période
              Row(
                children: [
                  Expanded(
                    child: Text(
                      rapport.titre,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: rapport.couleurPeriode.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(rapport.iconePeriode),
                        const SizedBox(width: 4),
                        Text(
                          rapport.periodeDisplay,
                          style: TextStyle(
                            color: rapport.couleurPeriode,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Aperçu du contenu
              Text(
                rapport.apercuContenu,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 12),
              
              // Footer avec date et actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    rapport.dateFormatee,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Row(
                    children: [
                      // Indicateur météo
                      if (rapport.aDonneesMeteo) ...[
                        // Icon(
                        //   rapport.iconeMeteo,
                        //   size: 16,
                        //   color: Colors.orange,
                        // ),
                        const SizedBox(width: 4),
                      ],
                      // Menu d'actions
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_horiz, size: 20),
                        onSelected: (action) => _handleRapportAction(context, rapport, action),
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'view',
                            child: Row(
                              children: [
                                const Icon(Icons.visibility, size: 16),
                                const SizedBox(width: 8),
                                Text(RapportMessages.voir),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'export',
                            child: Row(
                              children: [
                                const Icon(Icons.download, size: 16),
                                const SizedBox(width: 8),
                                Text(RapportMessages.telecharger),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'share',
                            child: Row(
                              children: [
                                const Icon(Icons.share, size: 16),
                                const SizedBox(width: 8),
                                Text(RapportMessages.partager),
                              ],
                            ),
                          ),
                          const PopupMenuDivider(),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                const Icon(Icons.delete, size: 16, color: Colors.red),
                                const SizedBox(width: 8),
                                Text(RapportMessages.supprimer, style: const TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Grille tablette
  Widget _buildTabletGrid(BuildContext context, RapportProvider provider, int columns) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemCount: provider.filteredRapports.length,
      itemBuilder: (context, index) {
        final rapport = provider.filteredRapports[index];
        return _buildDesktopCard(context, rapport, provider);
      },
    );
  }

  /// Grille desktop
  Widget _buildDesktopGrid(BuildContext context, RapportProvider provider, int columns) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.1,
      ),
      itemCount: provider.filteredRapports.length,
      itemBuilder: (context, index) {
        final rapport = provider.filteredRapports[index];
        return _buildDesktopCard(context, rapport, provider);
      },
    );
  }

  /// Carte desktop/tablette
  Widget _buildDesktopCard(BuildContext context, Rapport rapport, RapportProvider provider) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => _openRapportDetails(rapport),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Text(
                      rapport.titre,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: rapport.couleurPeriode.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      rapport.iconePeriode,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Contenu
              Expanded(
                child: Text(
                  rapport.apercuContenu,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Footer
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    rapport.dateFormatee,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (rapport.aDonneesMeteo) ...[
                        // Icon(rapport.iconeMeteo, size: 14, color: Colors.orange),
                        const SizedBox(width: 4),
                      ],
                      IconButton(
                        onPressed: () => _showExportDialog(rapport),
                        icon: const Icon(Icons.download, size: 16),
                        tooltip: RapportMessages.telecharger,
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      IconButton(
                        onPressed: () => _deleteRapport(rapport),
                        icon: const Icon(Icons.delete, size: 16, color: Colors.red),
                        tooltip: RapportMessages.supprimer,
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Ouvrir les détails du rapport
  void _openRapportDetails(Rapport rapport) {
    Navigator.pushNamed(
      context,
      '/rapport-details',
      arguments: rapport,
    );
  }

  /// Afficher le dialogue de génération
  void _showGenerateDialog() {
    showDialog(
      context: context,
      builder: (context) => _GenerateRapportDialog(),
    );
  }

  /// Afficher le dialogue d'export
  void _showExportDialog(Rapport rapport) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(RapportMessages.export),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ExportService.getSupportedFormats().map((format) {
            final info = ExportService.getFormatInfo()[format]!;
            return ListTile(
              leading: Icon(info.icon, color: Theme.of(context).primaryColor),
              title: Text(info.description),
              subtitle: Text('.${info.extension}'),
              onTap: () => _exportRapport(rapport, format),
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
        ],
      ),
    );
  }

  /// Exporter un rapport
  Future<void> _exportRapport(Rapport rapport, ExportFormat format) async {
    Navigator.of(context).pop();
    
    try {
      final filePath = await ExportService.exportWithFormat(
        rapport: rapport,
        format: format,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${RapportMessages.rapportTelecharge}: ${filePath.split('/').last}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${RapportMessages.telechargementEchoue}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Supprimer un rapport
  Future<void> _deleteRapport(Rapport rapport) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(RapportMessages.supprimer),
        content: Text(RapportMessages.suppressionConfirmation(rapport.titre)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await context.read<RapportProvider>().deleteRapport(rapport.id);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(RapportMessages.rapportSupprime),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  /// Gérer les actions du menu principal
  void _handleMenuAction(String action) {
    switch (action) {
      case 'refresh':
        context.read<RapportProvider>().refreshWithFilters();
        break;
      case 'filters':
        // Ouvrir les filtres avancés
        break;
      case 'stats':
        _showStatistics();
        break;
    }
  }

  /// Gérer les actions sur un rapport
  void _handleRapportAction(BuildContext context, Rapport rapport, String action) {
    switch (action) {
      case 'view':
        _openRapportDetails(rapport);
        break;
      case 'export':
        _showExportDialog(rapport);
        break;
      case 'share':
        _shareRapport(rapport);
        break;
      case 'delete':
        _deleteRapport(rapport);
        break;
    }
  }

  /// Partager un rapport
  void _shareRapport(Rapport rapport) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Fonctionnalité de partage en cours d\'implémentation'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  /// Afficher les statistiques
  void _showStatistics() {
    final stats = context.read<RapportProvider>().getStatistics();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('📊 Statistiques des Rapports'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total: ${stats['total']} rapports'),
            Text('Avec données météo: ${stats['avec_meteo']}'),
            Text('Sans données météo: ${stats['sans_meteo']}'),
            const SizedBox(height: 16),
            const Text('Par période:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('• Jour: ${stats['par_periode']['jour']}'),
            Text('• Semaine: ${stats['par_periode']['semaine']}'),
            Text('• Mois: ${stats['par_periode']['mois']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }
}

/// Dialogue de génération de rapport
class _GenerateRapportDialog extends StatefulWidget {
  @override
  State<_GenerateRapportDialog> createState() => _GenerateRapportDialogState();
}

class _GenerateRapportDialogState extends State<_GenerateRapportDialog> {
  String _selectedPeriode = 'jour';
  String _titre = '';
  bool _isGenerating = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(RapportMessages.genererRapport),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Message d'erreur
          if (_errorMessage != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: Colors.red[700],
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          
          if (_errorMessage != null) const SizedBox(height: 16),
          
          Text(
            'Générer un nouveau rapport avec l\'IA',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),
          
          // Indicateur de chargement ou formulaire
          if (_isGenerating)
            Column(
              children: [
                const SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(
                    strokeWidth: 4,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Génération du rapport IA en cours...',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Cela peut prendre quelques instants',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            )
          else
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedPeriode,
                  decoration: const InputDecoration(
                    labelText: 'Période *',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'jour', child: Text('📅 Jour')),
                    DropdownMenuItem(value: 'semaine', child: Text('📊 Semaine')),
                    DropdownMenuItem(value: 'mois', child: Text('📈 Mois')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedPeriode = value!;
                      _errorMessage = null;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Titre (optionnel)',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _titre = value;
                      _errorMessage = null;
                    });
                  },
                ),
              ],
            ),
        ],
      ),
      actions: [
        if (!_isGenerating) ...[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton.icon(
            onPressed: () => _generateRapport(),
            icon: const Icon(Icons.auto_awesome),
            label: const Text('Générer'),
          ),
        ],
      ],
    );
  }

  Future<void> _generateRapport() async {
    // Validation
    if (_selectedPeriode.isEmpty) {
      setState(() {
        _errorMessage = 'Veuillez sélectionner une période';
      });
      return;
    }

    setState(() {
      _isGenerating = true;
      _errorMessage = null;
    });

    try {
      final provider = context.read<RapportProvider>();
      final rapport = await provider.generateAiReport(
        periode: _selectedPeriode,
        titre: _titre.isNotEmpty ? _titre : null,
      );
      
      if (rapport != null && mounted) {
        // Fermer le dialogue et montrer le succès
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(RapportMessages.rapportGenere),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        _showError('La génération a échoué. Veuillez réessayer.');
      }
    } catch (e) {
      _showError('Erreur: ${e.toString().replaceAll('Exception: ', '')}');
    }
  }

  void _showError(String message) {
    setState(() {
      _isGenerating = false;
      _errorMessage = message;
    });
  }
}
