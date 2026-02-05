import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ventes_provider.dart';
import '../providers/stock_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/storage_helper.dart';
import '../utils/unit_converter.dart';
import '../models/vente.dart';

class AddVenteScreen extends StatefulWidget {
  const AddVenteScreen({Key? key}) : super(key: key);

  @override
  State<AddVenteScreen> createState() => _AddVenteScreenState();
}

class _AddVenteScreenState extends State<AddVenteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _clientController = TextEditingController();
  final _quantiteController = TextEditingController();
  final _prixController = TextEditingController();
  final _montantController = TextEditingController();
  
  String _statut = 'en_attente';
  int? _selectedStockId;
  List<DropdownMenuItem<int>> _stockOptions = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadStocks();
    });
  }

  void _loadStocks() {
    final stockProvider = Provider.of<StockProvider>(context, listen: false);
    setState(() {
      _stockOptions = stockProvider.stocks.map((stock) {
        // Récupérer le nom du produit via culture.nom ou produitNom
        final String produitNom = stock.culture?.nom?.isNotEmpty == true
            ? stock.culture!.nom!
            : (stock.produitNomValue ?? 'Produit #${stock.id}');
        return DropdownMenuItem<int>(
          value: stock.id!,
          child: Text('$produitNom (${stock.quantite} ${stock.unite})'),
        );
      }).toList();
    });
  }

  // Style de référence (identique à la section Récolte)
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
      width: 180,
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
    return Stack(
      children: [
        // Arrière-plan flou (blur)
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              color: Colors.black.withOpacity(0.3),
            ),
          ),
        ),
        // Dialog avec effet de profondeur
        Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.6,
            constraints: const BoxConstraints(maxWidth: 700),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
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
                          "Nouvelle Vente",
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
                          // Ligne 1: Client et Stock
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
                                      "Stock (Produit) *",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    DropdownButtonFormField<int>(
                                      value: _selectedStockId,
                                      decoration: _inputDeco("Choisir"),
                                      items: _stockOptions,
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedStockId = value;
                                        });
                                      },
                                      validator: (v) => v == null ? 'Requis' : null,
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
                                      onChanged: _calculateMontant,
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
                                      onChanged: _calculateMontant,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          
                          // Ligne 3: Montant total et Statut
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Montant total (FCFA) *",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    TextFormField(
                                      controller: _montantController,
                                      keyboardType: TextInputType.number,
                                      decoration: _inputDeco("0"),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Veuillez saisir le montant';
                                        }
                                        final montant = double.tryParse(value);
                                        if (montant == null || montant <= 0) {
                                          return 'Le montant doit être supérieur à 0';
                                        }
                                        return null;
                                      },
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
        ),
      ],
    );
  }

  void _calculateMontant(String value) {
    if (value.isNotEmpty && _quantiteController.text.isNotEmpty) {
      final prix = double.tryParse(value) ?? 0.0;
      final quantite = double.tryParse(_quantiteController.text) ?? 0.0;
      final montant = prix * quantite;
      _montantController.text = montant.toStringAsFixed(2);
    }
  }

  Future<void> _handleSubmit() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final stockProvider = Provider.of<StockProvider>(context, listen: false);
    
    final token = await StorageHelper.getToken();
    print('🔑 Token actuel: ${token?.substring(0, 50)}...');
    print('🔑 Longueur du token: ${token?.length}');
    print('🔑 isAuthenticated: ${authProvider.isAuthenticated}');
    
    if (!_formKey.currentState!.validate()) return;
    if (_selectedStockId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner un stock')),
      );
      return;
    }

    // Vérifier la quantité demandée
    final quantiteDemandee = double.tryParse(_quantiteController.text);
    if (quantiteDemandee == null || quantiteDemandee <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Quantité invalide')),
      );
      return;
    }

    // Trouver le stock sélectionné
    final stockSelectionne = stockProvider.stocks.firstWhere(
      (s) => s.id == _selectedStockId,
      orElse: () => throw Exception('Stock non trouvé'),
    );

    // Vérifier si le stock est suffisant
    final verification = stockProvider.canSell(
      stockId: _selectedStockId!,
      quantite: quantiteDemandee,
      unite: stockSelectionne.unite,
    );

    if (!verification['possible']) {
      // Afficher une erreur détaillée
      final details = verification['details'] as Map<String, dynamic>;
      final stockActuel = details['stockActuel'] as double;
      final unite = details['unite'] as String;
      final manquantKg = details['manquantKg'] as double;
      
      final messageErreur = 'Stock insuffisant!\n'
          'Stock actuel: ${stockActuel.toStringAsFixed(2)} $unite\n'
          'Manquant: ${manquantKg.toStringAsFixed(2)} kg';
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(messageErreur),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
      return;
    }

    final vente = Vente(
      stockId: _selectedStockId!,
      client: _clientController.text.isNotEmpty ? _clientController.text : null,
      quantite: quantiteDemandee,
      prixUnitaire: double.parse(_prixController.text),
      montant: double.parse(_montantController.text),
      dateVente: DateTime.now(),
      statut: _statut,
    );

    final provider = Provider.of<VentesProvider>(context, listen: false);
    final success = await provider.addVente(vente);

    if (mounted) {
      if (success) {
        // Décrémenter le stock localement après vente réussie
        stockProvider.decrementStock(
          stockId: _selectedStockId!,
          quantite: quantiteDemandee,
          unite: stockSelectionne.unite,
        );
        
        // ✅ CORRIGÉ: Fermer le dialogue et retourner à l'écran précédent
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vente ajoutée avec succès')),
        );
      } else {
        final errorMessage = provider.error ?? 'Erreur lors de l\'enregistrement';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Réessayer',
              onPressed: () => _handleSubmit(),
            ),
          ),
        );
      }
    }
  }
}

