import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ventes_provider.dart';
import '../providers/cultures_provider.dart';
import '../providers/stock_provider.dart';
import '../utils/constants.dart';
import '../models/vente.dart';
import 'vente_detail_screen.dart';

class VentesScreen extends StatefulWidget {
  const VentesScreen({Key? key}) : super(key: key);

  @override
  State<VentesScreen> createState() => _VentesScreenState();
}

class _VentesScreenState extends State<VentesScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<VentesProvider>(context, listen: false).fetchVentes();
      _loadCulturesIfNeeded();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Charge les cultures si elles ne sont pas déjà chargées
  void _loadCulturesIfNeeded() {
    final culturesProvider = Provider.of<CulturesProvider>(
      context,
      listen: false,
    );
    if (culturesProvider.cultures.isEmpty) {
      culturesProvider.fetchCultures();
    }
  }

  /// Récupère le nom du produit avec fallback multiple
  /// Logique améliorée pour éviter "Produit #ID"
  String _getProductName(
    dynamic stock,
    int stockId,
  ) {
    // Priorité 1: Si stock.culture.nom existe et n'est pas vide
    if (stock?.culture?.nom?.isNotEmpty == true) {
      return stock!.culture!.nom!;
    }

    // Priorité 2: Essayer culture.type comme alternative
    if (stock?.culture?.type?.isNotEmpty == true) {
      return stock!.culture!.type!;
    }

    // Priorité 3: Si stock a produitNomValue
    if (stock?.produitNomValue?.isNotEmpty == true) {
      return stock!.produitNomValue!;
    }

    // Priorité 4: Chercher dans le stockProvider par stockId
    try {
      final stockProvider = Provider.of<StockProvider>(
        context,
        listen: false,
      );
      final stockItem = stockProvider.stocks.firstWhere(
        (s) => s.id == stockId,
      );
      // Essayer culture.nom d'abord
      if (stockItem.culture?.nom?.isNotEmpty == true) {
        return stockItem.culture!.nom!;
      }
      // Essayer produitNomValue
      if (stockItem.produitNomValue?.isNotEmpty == true && 
          !stockItem.produitNomValue!.startsWith('Stock #')) {
        return stockItem.produitNomValue!;
      }
    } catch (e) {
      // Stock non trouvé, continuer
    }

    // Priorité 5: Chercher via stock.produit (cultureId) dans culturesProvider
    if (stock?.produit != null && stock!.produit > 0) {
      try {
        final culturesProvider = Provider.of<CulturesProvider>(
          context,
          listen: false,
        );
        final culture = culturesProvider.cultures.firstWhere(
          (c) => c.id == stock.produit,
        );
        if (culture.nom.isNotEmpty) {
          return culture.nom;
        }
      } catch (e) {
        // Culture non trouvée
      }
    }

    // Dernier recours: Fallback générique avec mention explicite
    return 'Produit #$stockId';
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final provider = Provider.of<VentesProvider>(context, listen: false);
      if (provider.hasMore && !provider.isLoadingMore) {
        provider.loadMore();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Ventes'),
        backgroundColor: const Color(0xFF21A84D),
        elevation: 0,
      ),
      body: Consumer<VentesProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.ventes.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.ventes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.trending_up,
                    size: 64,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Aucune vente',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Commencez par enregistrer votre première vente',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Header avec statistiques
              _buildHeader(provider),
              const Divider(height: 1),
              
              // Liste des ventes
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(24),
                  itemCount: provider.ventes.length +
                      (provider.hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == provider.ventes.length) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    final vente = provider.ventes[index];
                    final String produit = _getProductName(
                      vente.stock,
                      vente.stockId,
                    );
                    final double montantTotal = (vente.montant != null &&
                            vente.montant! > 0)
                        ? vente.montant!
                        : (vente.quantite * vente.prixUnitaire);

                    return _buildVenteCard(vente, produit, montantTotal);
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/ventes/add'),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Ajouter',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF21A84D),
      ),
    );
  }

  Widget _buildHeader(VentesProvider provider) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFEEEEEE)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Gestion des Ventes",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Suivez et gérez vos ventes",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  "Total des ventes",
                  formatCFA(provider.totalRevenue),
                  Icons.attach_money,
                  Colors.blue,
                  "${provider.totalVentes} ventes",
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _buildStatCard(
                  "Ventes réalisées",
                  "${provider.ventes.where((v) => v.statut == 'vendu').length}",
                  Icons.check_circle,
                  Colors.green,
                  "terminées",
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _buildStatCard(
                  "En attente",
                  "${provider.ventes.where((v) => v.statut == 'en_attente').length}",
                  Icons.pending,
                  Colors.orange,
                  "en cours",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String badgeText,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
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
                child: Icon(icon, color: color, size: 20),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B5E20),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVenteCard(Vente vente, String produit, double montantTotal) {
    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFEEEEEE)),
      ),
      child: InkWell(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => VenteDetailDialog(vente: vente),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      produit,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF1B5E20),
                      ),
                    ),
                  ),
                  _buildStatutChip(vente.statut),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailItem(
                          Icons.shopping_bag_outlined,
                          'Quantité',
                          '${vente.quantite} ${vente.stock?.unite ?? ""}',
                        ),
                        const SizedBox(height: 8),
                        _buildDetailItem(
                          Icons.attach_money_outlined,
                          'Prix unitaire',
                          '${vente.prixUnitaire.toStringAsFixed(0)} FCFA',
                        ),
                        const SizedBox(height: 8),
                        _buildDetailItem(
                          Icons.calendar_today_outlined,
                          'Date',
                          vente.dateVente.toString().split(' ')[0],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF21A84D).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Total',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          formatCFA(montantTotal),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Color(0xFF21A84D),
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
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStatutChip(String statut) {
    Color color;
    String label;

    switch (statut) {
      case 'vendu':
        color = Colors.green;
        label = 'Vendu';
        break;
      case 'en_attente':
        color = Colors.orange;
        label = 'En attente';
        break;
      default:
        color = Colors.grey;
        label = statut;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            label == 'Vendu' ? Icons.check_circle : Icons.pending,
            color: color,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// Dialog pour afficher les détails d'une vente
class VenteDetailDialog extends StatefulWidget {
  final Vente vente;

  const VenteDetailDialog({Key? key, required this.vente}) : super(key: key);

  @override
  State<VenteDetailDialog> createState() => _VenteDetailDialogState();
}

class _VenteDetailDialogState extends State<VenteDetailDialog> {
  late Vente _vente;

  @override
  void initState() {
    super.initState();
    _vente = widget.vente;
  }

  /// Récupère le nom du produit avec fallback multiple
  /// Logique améliorée pour éviter "Produit #ID"
  String _getProductName(dynamic stock, int stockId) {
    // Priorité 1: Si stock.culture.nom existe et n'est pas vide
    if (stock?.culture?.nom?.isNotEmpty == true) {
      return stock!.culture!.nom!;
    }

    // Priorité 2: Essayer culture.type comme alternative
    if (stock?.culture?.type?.isNotEmpty == true) {
      return stock!.culture!.type!;
    }

    // Priorité 3: Si stock a produitNomValue
    if (stock?.produitNomValue?.isNotEmpty == true) {
      return stock!.produitNomValue!;
    }

    // Priorité 4: Chercher dans le stockProvider par stockId
    try {
      final stockProvider = Provider.of<StockProvider>(
        context,
        listen: false,
      );
      final stockItem = stockProvider.stocks.firstWhere(
        (s) => s.id == stockId,
      );
      // Essayer culture.nom d'abord
      if (stockItem.culture?.nom?.isNotEmpty == true) {
        return stockItem.culture!.nom!;
      }
      // Essayer produitNomValue
      if (stockItem.produitNomValue?.isNotEmpty == true && 
          !stockItem.produitNomValue!.startsWith('Stock #')) {
        return stockItem.produitNomValue!;
      }
    } catch (e) {
      // Stock non trouvé, continuer
    }

    // Priorité 5: Chercher via stock.produit (cultureId) dans culturesProvider
    if (stock?.produit != null && stock!.produit > 0) {
      try {
        final culturesProvider = Provider.of<CulturesProvider>(
          context,
          listen: false,
        );
        final culture = culturesProvider.cultures.firstWhere(
          (c) => c.id == stock.produit,
        );
        if (culture.nom.isNotEmpty) {
          return culture.nom;
        }
      } catch (e) {
        // Culture non trouvée
      }
    }

    // Dernier recours: Fallback générique avec mention explicite
    return 'Produit #$stockId';
  }

  @override
  Widget build(BuildContext context) {
    final String produit = _getProductName(_vente.stock, _vente.stockId);
    final String unite = (_vente.stock?.unite ?? '').toString();
    final String client = (_vente.client ?? 'Non spécifié').toString();
    final double montantTotal = _vente.quantite * _vente.prixUnitaire;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 600),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header avec montant
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF21A84D), Color(0xFF1B5E20)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Montant total',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      formatCFA(montantTotal),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildStatutChip(_vente.statut),
                  ],
                ),
              ),

              // Contenu
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Produit
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PRODUIT',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            produit,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1B5E20),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Détails
                    _buildDetailRow(
                      Icons.person_outline,
                      'Client',
                      client,
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      Icons.shopping_bag_outlined,
                      'Quantité',
                      '${_vente.quantite} $unite',
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      Icons.attach_money_outlined,
                      'Prix unitaire',
                      '${_vente.prixUnitaire.toStringAsFixed(0)} FCFA',
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      Icons.calendar_today_outlined,
                      'Date de vente',
                      _vente.dateVente.toString().split(' ')[0],
                    ),
                  ],
                ),
              ),

              // Boutons d'action
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Color(0xFFEEEEEE)),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: Colors.grey),
                        label: const Text(
                          'Fermer',
                          style: TextStyle(color: Colors.grey),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: Color(0xFFEEEEEE)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _showFullDetails(context);
                        },
                        icon: const Icon(Icons.visibility, color: Colors.white),
                        label: const Text(
                          'Voir plus',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF21A84D),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
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
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: Colors.grey[600]),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatutChip(String statut) {
    Color color;
    String label;

    switch (statut) {
      case 'vendu':
        color = Colors.white;
        label = 'Vendu';
        break;
      case 'en_attente':
        color = Colors.orange[200]!;
        label = 'En attente';
        break;
      default:
        color = Colors.grey[300]!;
        label = statut;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            label == 'Vendu' ? Icons.check_circle : Icons.pending,
            color: Colors.white,
            size: 14,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showFullDetails(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VenteDetailScreen(vente: _vente),
      ),
    );
  }
}

