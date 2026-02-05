import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/stock_provider.dart';
import '../providers/cultures_provider.dart';
import '../providers/auth_provider.dart';
import '../models/stock.dart';
import '../models/culture.dart';

class StockScreen extends StatefulWidget {
  const StockScreen({Key? key}) : super(key: key);

  @override
  State<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<StockProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final stocks = provider.stocks;
        final totalQuantite = provider.totalQuantite;

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Gestion du Stock",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Gérez vos intrants agricoles",
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(child: _buildStatCard("Total articles", stocks.length.toString(), Icons.inventory_2, Colors.blue, "articles")),
                    const SizedBox(width: 20),
                    Expanded(child: _buildStatCard("Quantité totale", "${totalQuantite.toStringAsFixed(1)} kg", Icons.scale, Colors.green, "en stock")),
                  ],
                ),
                const SizedBox(height: 32),

                Card(
                  elevation: 0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: Color(0xFFEEEEEE)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Votre Stock", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            ElevatedButton.icon(
                              onPressed: () => _showAddStockDialog(),
                              icon: const Icon(Icons.add, color: Colors.white),
                              label: const Text("Ajouter un stock", style: TextStyle(color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF21A84D),
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        
                        SizedBox(
                          width: double.infinity,
                          child: DataTable(
                            headingTextStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
                            horizontalMargin: 0,
                            columns: const [
                              DataColumn(label: Text('Produit')),
                              DataColumn(label: Text('Quantité')),
                              DataColumn(label: Text('Date de stockage')),
                              DataColumn(label: Text('Disponibilité')),
                              DataColumn(label: Text('Actions')),
                            ],
                            rows: stocks.map((stock) {
                              return DataRow(cells: [
                                DataCell(_buildProductCell(stock)),
                                DataCell(
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        stock.quantite.toStringAsFixed(1).replaceAll('.', ','),
                                        style: const TextStyle(fontWeight: FontWeight.w500),
                                      ),
                                      Text(
                                        stock.unite,
                                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                                      ),
                                    ],
                                  ),
                                ),
                                DataCell(_buildDateInfo(stock.dateEntree)),
                                DataCell(_buildDisponibiliteChip(stock)),
                                DataCell(
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit_outlined, color: Colors.blue, size: 20),
                                        onPressed: () => _showEditStockDialog(stock),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                        onPressed: () => _showDeleteConfirmDialog(stock),
                                      ),
                                    ],
                                  ),
                                ),
                              ]);
                            }).toList(),
                          ),
                        ),
                        
                        if (stocks.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(32),
                            child: Column(
                              children: [
                                Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
                                SizedBox(height: 16),
                                Text(
                                  "Aucun stock enregistré",
                                  style: TextStyle(fontSize: 16, color: Colors.grey),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  "Commencez par ajouter votre premier stock",
                                  style: TextStyle(fontSize: 14, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProductCell(Stock stock) {
    final String productName = stock.produitNom;
    final String? type = stock.culture?.type;
    final int maxLength = 30;
    
    final displayName = productName.length > maxLength 
        ? '${productName.substring(0, maxLength)}...' 
        : productName;
    
    return Tooltip(
      message: type != null && type.isNotEmpty 
          ? '$productName\nType: $type' 
          : productName,
      preferBelow: false,
      verticalOffset: 10,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getProductIcon(stock.culture?.type),
                size: 16,
                color: Colors.green.shade700,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  displayName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (type != null && type.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 22, top: 2),
              child: Text(
                type,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }

  /// Méthode helper pour afficher une date (ou un message si null)
  Widget _buildDateInfo(DateTime? date) {
    if (date == null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.remove_circle_outline,
            size: 14,
            color: Colors.grey.shade400,
          ),
          const SizedBox(width: 4),
          Text(
            'Non définie',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade400,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.event,
          size: 14,
          color: Colors.green.shade600,
        ),
        const SizedBox(width: 4),
        Text(
          _formatDate(date),
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  IconData _getProductIcon(String? type) {
    if (type == null) return Icons.grass;
    final normalizedType = type.toLowerCase();
    if (normalizedType.contains('céréale') || normalizedType.contains('ble')) return Icons.grain;
    if (normalizedType.contains('légume') || normalizedType.contains('legume')) return Icons.eco;
    if (normalizedType.contains('fruit')) return Icons.local_florist;
    if (normalizedType.contains('tubercul')) return Icons.grass;
    if (normalizedType.contains('ol')) return Icons.energy_savings_leaf;
    return Icons.grass;
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
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: color, size: 24),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(badgeText, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildDisponibiliteChip(Stock stock) {
    String displayText;
    Color color;
    IconData icon;

    switch (stock.disponibilite) {
      case 'Disponible':
        displayText = 'Disponible';
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case 'Réservé':
        displayText = 'Réservé';
        color = Colors.orange;
        icon = Icons.warning;
        break;
      case 'Sortie':
        displayText = 'Sorti';
        color = Colors.red;
        icon = Icons.error;
        break;
      default:
        displayText = 'Inconnu';
        color = Colors.grey;
        icon = Icons.help;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            displayText,
            style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void _showAddStockDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddStockDialog(),
    );
  }

  void _showEditStockDialog(Stock stock) {
    showDialog(
      context: context,
      builder: (context) => EditStockDialog(stock: stock),
    );
  }

  void _showDeleteConfirmDialog(Stock stock) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le stock'),
        content: Text('Êtes-vous sûr de vouloir supprimer le stock de ${stock.produitNom} ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await Provider.of<StockProvider>(context, listen: false).deleteStock(stock.id!);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Stock supprimé avec succès')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class AddStockDialog extends StatefulWidget {
  const AddStockDialog({Key? key}) : super(key: key);

  @override
  State<AddStockDialog> createState() => _AddStockDialogState();
}

class _AddStockDialogState extends State<AddStockDialog> {
  final _formKey = GlobalKey<FormState>();
  final _quantiteController = TextEditingController();
  int? _selectedCultureId;
  String _unite = 'kg';
  String _disponibilite = 'Disponible';
  DateTime _dateEntree = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CulturesProvider>(context, listen: false).fetchCultures();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.6,
        constraints: const BoxConstraints(maxWidth: 700),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Ajouter un Stock", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20))),
                    IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                  ],
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _buildCultureDropdown()),
                          const SizedBox(width: 20),
                          Expanded(child: _buildInputField("Quantité *", _quantiteController, "Ex: 500", isNumber: true)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _buildDropdownField("Unité *", ['kg', 'tonne', 'sac', 'litre', 'unite'], (v) => _unite = v!)),
                          const SizedBox(width: 20),
                          Expanded(child: _buildDropdownField("Disponibilité *", ['Disponible', 'Réservé', 'Sortie'], (v) => _disponibilite = v!)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _buildDateField("Date d'entrée *")),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildBtn("Annuler", Colors.white, Colors.black, () => Navigator.pop(context), true),
                          const SizedBox(width: 20),
                          _buildBtn("Ajouter", const Color(0xFF21A84D), Colors.white, _handleSave, false),
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

  // --- HELPERS DU FORMULAIRE ---

  Widget _buildCultureDropdown() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text("Culture/Produit *", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      const SizedBox(height: 8),
      Consumer<CulturesProvider>(builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (provider.cultures.isEmpty) {
          return const Text('Aucune culture disponible. Veuillez d\'abord créer une culture.', style: TextStyle(color: Colors.red));
        }
        return DropdownButtonFormField<int>(
          decoration: _inputDeco("Choisir"),
          value: _selectedCultureId,
          items: provider.cultures.map((c) => DropdownMenuItem(value: c.id, child: Text('${c.nom} (${c.type})'))).toList(),
          onChanged: (v) => setState(() => _selectedCultureId = v),
          validator: (v) => v == null ? 'Requis' : null,
        );
      }),
    ]);
  }

  Widget _buildInputField(String label, TextEditingController controller, String hint, {bool isNumber = false}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      const SizedBox(height: 8),
      TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: _inputDeco(hint),
        validator: (v) => (label.contains('*') && (v == null || v.isEmpty)) ? 'Requis' : null,
      ),
    ]);
  }

  Widget _buildDropdownField(String label, List<String> items, Function(String?) onChanged) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      const SizedBox(height: 8),
      DropdownButtonFormField<String>(
        decoration: _inputDeco("Choisir"),
        value: items.first,
        items: items.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
        onChanged: onChanged,
      ),
    ]);
  }

  Widget _buildDateField(String label) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      const SizedBox(height: 8),
      TextFormField(
        readOnly: true,
        onTap: _pickDateEntree,
        decoration: _inputDeco("Sélectionner").copyWith(suffixIcon: const Icon(Icons.calendar_today, size: 18)),
        controller: TextEditingController(text: _formatDate(_dateEntree)),
      ),
    ]);
  }

  Widget _buildBtn(String txt, Color bg, Color tx, VoidCallback tap, bool out) {
    return SizedBox(width: 180, height: 48, child: ElevatedButton(
      onPressed: tap,
      style: ElevatedButton.styleFrom(backgroundColor: bg, elevation: 0,
      side: out ? const BorderSide(color: Color(0xFFEEEEEE)) : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
      child: Text(txt, style: TextStyle(color: tx, fontWeight: FontWeight.bold)),
    ));
  }

  InputDecoration _inputDeco(String hint) => InputDecoration(
    hintText: hint, contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFEEEEEE))),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFEEEEEE))),
  );

  Future<void> _pickDateEntree() async {
    final DateTime? picked = await showDatePicker(context: context, initialDate: _dateEntree, firstDate: DateTime(2020), lastDate: DateTime.now());
    if (picked != null) setState(() { _dateEntree = picked; });
  }

  String _formatDate(DateTime d) => '${d.day.toString().padLeft(2,'0')}/${d.month.toString().padLeft(2,'0')}/${d.year}';

  void _handleSave() async {
    if (_formKey.currentState!.validate() && _selectedCultureId != null) {
      final culturesProvider = Provider.of<CulturesProvider>(context, listen: false);
      final selectedCulture = culturesProvider.cultures.firstWhere(
        (c) => c.id == _selectedCultureId,
        orElse: () => Culture(
          id: _selectedCultureId,
          nom: 'Inconnu',
          type: '',
          surface: 0,
          datePlantation: DateTime.now(),
          etat: 'active',
          userId: 0,
        ),
      );

      // NOTE: dateExpiration n'est pas inclus car le backend ne supporte pas ce champ
      final stock = Stock(
        produit: _selectedCultureId!,
        quantite: double.parse(_quantiteController.text),
        unite: _unite,
        dateEntree: _dateEntree,
        disponibilite: _disponibilite,
        produitNom: selectedCulture.nom,
      );

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await Provider.of<StockProvider>(context, listen: false).addStock(stock, authProvider);

      if (mounted) {
        Navigator.pop(context);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Stock de ${selectedCulture.nom} ajouté avec succès')),
          );
        } else {
          final errorMessage = Provider.of<StockProvider>(context, listen: false).error;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage ?? 'Erreur lors de l\'ajout du stock'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}

class EditStockDialog extends StatefulWidget {
  final Stock stock;

  const EditStockDialog({Key? key, required this.stock}) : super(key: key);

  @override
  State<EditStockDialog> createState() => _EditStockDialogState();
}

class _EditStockDialogState extends State<EditStockDialog> {
  final _formKey = GlobalKey<FormState>();
  final _quantiteController = TextEditingController();
  late int? _selectedCultureId;
  late String _unite;
  late String _disponibilite;
  late DateTime _dateEntree;

  @override
  void initState() {
    super.initState();
    _quantiteController.text = widget.stock.quantite.toString();
    _selectedCultureId = widget.stock.produit;
    _unite = widget.stock.unite;
    _disponibilite = widget.stock.disponibilite;
    _dateEntree = widget.stock.dateEntree;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CulturesProvider>(context, listen: false).fetchCultures();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.6,
        constraints: const BoxConstraints(maxWidth: 700),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Modifier le Stock", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20))),
                    IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                  ],
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _buildCultureDropdown()),
                          const SizedBox(width: 20),
                          Expanded(child: _buildInputField("Quantité *", _quantiteController, "Ex: 500", isNumber: true)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _buildDropdownField("Unité *", ['kg', 'tonne', 'sac', 'litre', 'unite'], (v) => _unite = v!)),
                          const SizedBox(width: 20),
                          Expanded(child: _buildDropdownField("Disponibilité *", ['Disponible', 'Réservé', 'Sortie'], (v) => _disponibilite = v!)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _buildDateField("Date d'entrée *")),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildBtn("Annuler", Colors.white, Colors.black, () => Navigator.pop(context), true),
                          const SizedBox(width: 20),
                          _buildBtn("Enregistrer", const Color(0xFF21A84D), Colors.white, _handleSave, false),
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

  // --- HELPERS DU FORMULAIRE ---

  Widget _buildCultureDropdown() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text("Culture/Produit *", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      const SizedBox(height: 8),
      Consumer<CulturesProvider>(builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (provider.cultures.isEmpty) {
          return const Text('Aucune culture disponible. Veuillez d\'abord créer une culture.', style: TextStyle(color: Colors.red));
        }
        // Trouver la valeur initiale si elle existe dans la liste
        int? initialValue = _selectedCultureId;
        if (initialValue != null && !provider.cultures.any((c) => c.id == initialValue)) {
          // Si la culture n'est plus dans la liste, ne pas pré-sélectionner
          initialValue = null;
        }
        return DropdownButtonFormField<int>(
          decoration: _inputDeco("Choisir"),
          value: initialValue,
          items: provider.cultures.map((c) => DropdownMenuItem(value: c.id, child: Text('${c.nom} (${c.type})'))).toList(),
          onChanged: (v) => setState(() => _selectedCultureId = v),
          validator: (v) => v == null ? 'Requis' : null,
        );
      }),
    ]);
  }

  Widget _buildInputField(String label, TextEditingController controller, String hint, {bool isNumber = false}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      const SizedBox(height: 8),
      TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: _inputDeco(hint),
        validator: (v) => (label.contains('*') && (v == null || v.isEmpty)) ? 'Requis' : null,
      ),
    ]);
  }

  Widget _buildDropdownField(String label, List<String> items, Function(String?) onChanged) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      const SizedBox(height: 8),
      DropdownButtonFormField<String>(
        decoration: _inputDeco("Choisir"),
        value: items.contains(_disponibilite) ? _disponibilite : items.first,
        items: items.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
        onChanged: onChanged,
      ),
    ]);
  }

  Widget _buildDateField(String label) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      const SizedBox(height: 8),
      TextFormField(
        readOnly: true,
        onTap: _pickDateEntree,
        decoration: _inputDeco("Sélectionner").copyWith(suffixIcon: const Icon(Icons.calendar_today, size: 18)),
        controller: TextEditingController(text: _formatDate(_dateEntree)),
      ),
    ]);
  }

  Widget _buildBtn(String txt, Color bg, Color tx, VoidCallback tap, bool out) {
    return SizedBox(width: 180, height: 48, child: ElevatedButton(
      onPressed: tap,
      style: ElevatedButton.styleFrom(backgroundColor: bg, elevation: 0,
      side: out ? const BorderSide(color: Color(0xFFEEEEEE)) : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
      child: Text(txt, style: TextStyle(color: tx, fontWeight: FontWeight.bold)),
    ));
  }

  InputDecoration _inputDeco(String hint) => InputDecoration(
    hintText: hint, contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFEEEEEE))),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFEEEEEE))),
  );

  Future<void> _pickDateEntree() async {
    final DateTime? picked = await showDatePicker(context: context, initialDate: _dateEntree, firstDate: DateTime(2020), lastDate: DateTime.now());
    if (picked != null) setState(() { _dateEntree = picked; });
  }

  String _formatDate(DateTime d) => '${d.day.toString().padLeft(2,'0')}/${d.month.toString().padLeft(2,'0')}/${d.year}';

  void _handleSave() async {
    if (_formKey.currentState!.validate() && _selectedCultureId != null) {
      // NOTE: dateExpiration n'est pas inclus car le backend ne supporte pas ce champ
      final updatedStock = Stock(
        id: widget.stock.id,
        produit: _selectedCultureId!,
        quantite: double.parse(_quantiteController.text),
        unite: _unite,
        dateEntree: _dateEntree,
        disponibilite: _disponibilite,
      );

      final success = await Provider.of<StockProvider>(context, listen: false)
          .updateStock(widget.stock.id!, updatedStock);

      if (mounted) {
        Navigator.pop(context);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Stock modifié avec succès')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erreur lors de la modification'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }
}

