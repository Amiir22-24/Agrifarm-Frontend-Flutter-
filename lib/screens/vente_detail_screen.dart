import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/vente.dart';
import '../providers/ventes_provider.dart';
import '../providers/cultures_provider.dart';
import '../utils/constants.dart';

class VenteDetailScreen extends StatefulWidget {
  final Vente vente;

  const VenteDetailScreen({Key? key, required this.vente}) : super(key: key);

  @override
  State<VenteDetailScreen> createState() => _VenteDetailScreenState();
}

class _VenteDetailScreenState extends State<VenteDetailScreen> {
  late Vente _vente;

  @override
  void initState() {
    super.initState();
    _vente = widget.vente;
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF21A84D)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: valueColor ?? Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatutChip(String statut) {
    Color color;
    String label;
    IconData icon;

    switch (statut) {
      case 'vendu':
        color = Colors.green;
        label = 'Vendu';
        icon = Icons.check_circle;
        break;
      case 'en_attente':
        color = Colors.orange;
        label = 'En attente';
        icon = Icons.pending;
        break;
      default:
        color = Colors.grey;
        label = statut;
        icon = Icons.info;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  void _showEditVenteDialog(BuildContext context, Vente vente) {
    showDialog(
      context: context,
      builder: (context) => EditVenteDialog(vente: vente),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, Vente vente) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Supprimer la vente'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text('Êtes-vous sûr de vouloir supprimer cette vente de ${vente.stock?.produit ?? 'produit'} ?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await Provider.of<VentesProvider>(
                context,
                listen: false,
              ).deleteVente(vente.id!);

              if (mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Vente supprimée avec succès')),
                  );
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        Provider.of<VentesProvider>(context, listen: false).error ??
                            'Erreur lors de la suppression'
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Supprimer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  /// Récupère le nom de la culture avec fallback multiple
  /// Logique améliorée pour éviter "Produit #ID"
  String _getCultureName(
    dynamic stock,
    int stockId,
    CulturesProvider culturesProvider,
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

    // Priorité 4: Chercher dans la liste des cultures chargées via stock.produit (cultureId)
    if (stock?.produit != null && stock!.produit > 0) {
      try {
        final culture = culturesProvider.cultures.firstWhere(
          (c) => c.id == stock.produit,
        );
        if (culture.nom.isNotEmpty) {
          return culture.nom;
        }
      } catch (e) {
        // Culture non trouvée dans la liste locale, continuer
      }
    }

    // Priorité 5: Si stock.produitNomValue existe
    if (stock?.produitNomValue?.isNotEmpty == true) {
      return stock!.produitNomValue!;
    }

    // Dernier recours: Fallback générique avec mention explicite
    return 'Produit #$stockId';
  }

  @override
  Widget build(BuildContext context) {
    // Charger les cultures si nécessaire pour l'affichage du nom
    final culturesProvider = Provider.of<CulturesProvider>(
      context,
      listen: false,
    );
    if (culturesProvider.cultures.isEmpty) {
      culturesProvider.fetchCultures();
    }
    
    final String produit = _getCultureName(
      _vente.stock,
      _vente.stockId,
      culturesProvider,
    );
    final String unite = (_vente.stock?.unite ?? '').toString();
    final String client = (_vente.client ?? 'Client non spécifié').toString();
    
    // Calcul du montant total
    final double montantTotal = _vente.quantite * _vente.prixUnitaire;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails de la vente'),
        centerTitle: true,
        backgroundColor: const Color(0xFF21A84D),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _showDeleteConfirmDialog(context, _vente),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header avec montant calculé
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF21A84D),
                    const Color(0xFF1B5E20),
                  ],
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
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildStatutChip(_vente.statut),
                ],
              ),
            ),

            // Liste des détails
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section Produit
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFEEEEEE)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PRODUIT',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          produit,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1B5E20),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Liste des détails
                  _buildDetailRow(
                    icon: Icons.person_outline,
                    label: 'Client',
                    value: client,
                  ),
                  _buildDetailRow(
                    icon: Icons.shopping_bag_outlined,
                    label: 'Quantité',
                    value: '${_vente.quantite} $unite',
                  ),
                  _buildDetailRow(
                    icon: Icons.attach_money_outlined,
                    label: 'Prix unitaire',
                    value: '${_vente.prixUnitaire.toStringAsFixed(0)} FCFA',
                  ),
                  _buildDetailRow(
                    icon: Icons.calendar_today_outlined,
                    label: 'Date de vente',
                    value: _vente.dateVente.toString().split(' ')[0],
                  ),

                  // Boutons d'action
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _showEditVenteDialog(context, _vente),
                          icon: const Icon(Icons.edit_outlined),
                          label: const Text('Modifier'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: const Color(0xFF21A84D),
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _showDeleteConfirmDialog(context, _vente),
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          label: const Text('Supprimer', style: TextStyle(color: Colors.red)),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: const BorderSide(color: Colors.red),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EditVenteDialog extends StatefulWidget {
  final Vente vente;

  const EditVenteDialog({Key? key, required this.vente}) : super(key: key);

  @override
  State<EditVenteDialog> createState() => _EditVenteDialogState();
}

class _EditVenteDialogState extends State<EditVenteDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _clientController;
  late TextEditingController _quantiteController;
  late TextEditingController _prixController;
  late TextEditingController _montantController;
  
  late String _statut;
  late double _quantite;
  late double _prixUnitaire;

  @override
  void initState() {
    super.initState();
    _clientController = TextEditingController(text: widget.vente.client ?? '');
    _quantiteController = TextEditingController(text: widget.vente.quantite.toString());
    _prixController = TextEditingController(text: widget.vente.prixUnitaire.toString());
    _montantController = TextEditingController(
      text: (widget.vente.quantite * widget.vente.prixUnitaire).toStringAsFixed(0)
    );
    _statut = widget.vente.statut;
    _quantite = widget.vente.quantite;
    _prixUnitaire = widget.vente.prixUnitaire;
  }

  @override
  void dispose() {
    _clientController.dispose();
    _quantiteController.dispose();
    _prixController.dispose();
    _montantController.dispose();
    super.dispose();
  }

  void _calculateMontant() {
    if (_quantiteController.text.isNotEmpty && _prixController.text.isNotEmpty) {
      final prix = double.tryParse(_prixController.text) ?? 0.0;
      final quantite = double.tryParse(_quantiteController.text) ?? 0.0;
      final montant = prix * quantite;
      _montantController.text = montant.toStringAsFixed(0);
      setState(() {
        _quantite = quantite;
        _prixUnitaire = prix;
      });
    }
  }

  InputDecoration _inputDeco(String hint) => InputDecoration(
    hintText: hint,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
    ),
  );

  Widget _buildBtn(String txt, Color bg, Color tx, VoidCallback tap, bool out) {
    return SizedBox(
      width: 160,
      height: 48,
      child: ElevatedButton(
        onPressed: tap,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          elevation: 0,
          side: out ? const BorderSide(color: Color(0xFFEEEEEE)) : null,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          txt,
          style: TextStyle(color: tx, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.6,
        constraints: const BoxConstraints(maxWidth: 700),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Modifier la vente",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B5E20),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              
              // Formulaire
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Ligne 1: Client
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Client",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _clientController,
                                  decoration: _inputDeco("Optionnel"),
                                  validator: (v) => null,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Statut *",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<String>(
                                  value: _statut,
                                  decoration: _inputDeco("Choisir"),
                                  items: ['vendu', 'en_attente'].map((s) {
                                    String label;
                                    switch (s) {
                                      case 'vendu':
                                        label = 'Vendu';
                                        break;
                                      case 'en_attente':
                                        label = 'En attente';
                                        break;
                                      default:
                                        label = s;
                                    }
                                    return DropdownMenuItem(value: s, child: Text(label));
                                  }).toList(),
                                  onChanged: (v) => setState(() => _statut = v!),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      
                      // Ligne 2: Quantité et Prix unitaire
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Quantité *",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _quantiteController,
                                  keyboardType: TextInputType.number,
                                  decoration: _inputDeco("Ex: 100"),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Veuillez saisir la quantité';
                                    }
                                    final quantity = double.tryParse(value);
                                    if (quantity == null || quantity <= 0) {
                                      return 'La quantité doit être supérieure à 0';
                                    }
                                    return null;
                                  },
                                  onChanged: (_) => _calculateMontant(),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Prix unitaire (FCFA) *",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _prixController,
                                  keyboardType: TextInputType.number,
                                  decoration: _inputDeco("Ex: 15000"),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Veuillez saisir le prix';
                                    }
                                    final price = double.tryParse(value);
                                    if (price == null || price <= 0) {
                                      return 'Le prix doit être supérieur à 0';
                                    }
                                    return null;
                                  },
                                  onChanged: (_) => _calculateMontant(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      
                      // Ligne 3: Montant total
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Montant total (FCFA)",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _montantController,
                                  enabled: false,
                                  decoration: _inputDeco("0"),
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),
                          const Expanded(child: SizedBox()),
                        ],
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Boutons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildBtn(
                            "Annuler",
                            Colors.white,
                            Colors.black,
                            () => Navigator.pop(context),
                            true,
                          ),
                          const SizedBox(width: 20),
                          _buildBtn(
                            "Enregistrer",
                            const Color(0xFF21A84D),
                            Colors.white,
                            _handleSubmit,
                            false,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final updatedVente = Vente(
      id: widget.vente.id,
      stockId: widget.vente.stockId,
      client: _clientController.text.isNotEmpty ? _clientController.text : null,
      quantite: double.parse(_quantiteController.text),
      prixUnitaire: double.parse(_prixController.text),
      montant: double.parse(_montantController.text),
      dateVente: widget.vente.dateVente,
      statut: _statut,
      stock: widget.vente.stock,
      userId: widget.vente.userId,
    );

    final success = await Provider.of<VentesProvider>(
      context,
      listen: false,
    ).updateVente(widget.vente.id!, updatedVente);

    if (mounted) {
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vente modifiée avec succès')),
        );
      } else {
        final errorMessage = Provider.of<VentesProvider>(
          context,
          listen: false,
        ).error ?? 'Erreur lors de la modification';
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

