// lib/screens/recoltes_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recolte_provider.dart';
import '../providers/cultures_provider.dart';
import '../providers/auth_provider.dart';
import '../models/recolte.dart';
import '../models/culture.dart';

class RecoltesScreen extends StatefulWidget {
  const RecoltesScreen({Key? key}) : super(key: key);

  @override
  State<RecoltesScreen> createState() => _RecoltesScreenState();
}

class _RecoltesScreenState extends State<RecoltesScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<RecolteProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final recoltes = provider.recoltes;
        final totalQuantite = provider.totalQuantite;
        final totalRecoltes = provider.totalRecoltes;
        final recoltesExcellentes = recoltes.where((r) => r.qualite.toLowerCase() == 'excellente').length;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. HEADER
              const Text(
                "Gestion des Récoltes",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
              ),
              const SizedBox(height: 4),
              const Text(
                "Suivez et gérez toutes vos récoltes en temps réel",
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 24),

              // 2. STATS CARDS
              Row(
                children: [
                  Expanded(child: _buildStatCard("Quantité totale", "${totalQuantite.toStringAsFixed(1)} kg", Icons.eco, Colors.green, "+$recoltesExcellentes excellentes")),
                  const SizedBox(width: 20),
                  Expanded(child: _buildStatCard("Récoltes", totalRecoltes.toString(), Icons.calendar_today, Colors.orange, "$totalRecoltes opérations")),
                ],
              ),
              const SizedBox(height: 32),

              // 3. TABLE CARD
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
                          const Text("Historique des Récoltes", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ElevatedButton.icon(
                            onPressed: () => _showAddRecolteDialog(),
                            icon: const Icon(Icons.add, color: Colors.white, size: 18),
                            label: const Text("Nouvelle Récolte", style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF21A84D),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
                            DataColumn(label: Text('Date')),
                            DataColumn(label: Text('Culture')),
                            DataColumn(label: Text('Quantité')),
                            DataColumn(label: Text('Qualité')),
                            DataColumn(label: Text('Actions')),
                          ],
                          rows: recoltes.map((recolte) => _buildDataRow(recolte)).toList(),
                        ),
                      ),
                      if (recoltes.isEmpty) _buildEmptyState(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- WIDGETS DE L'INTERFACE PRINCIPALE ---

  DataRow _buildDataRow(Recolte recolte) {
    return DataRow(cells: [
      DataCell(Text(_formatDate(recolte.dateRecolte), style: const TextStyle(fontWeight: FontWeight.w500))),
      DataCell(Text(recolte.culture?.nom ?? 'Culture ${recolte.cultureId}')),
      DataCell(Text("${recolte.quantite} ${recolte.unite ?? 'kg'}")),
      DataCell(_buildQualiteChip(recolte.qualite)),
      DataCell(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.edit_outlined, color: Colors.blue, size: 20), onPressed: () => _showEditRecolteDialog(recolte)),
            IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20), onPressed: () => _showDeleteConfirmDialog(recolte)),
          ],
        ),
      ),
    ]);
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
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                child: Text(badgeText, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildQualiteChip(String qualite) {
    Color color = qualite.toLowerCase() == 'excellente' ? Colors.green : (qualite.toLowerCase() == 'bonne' ? Colors.blue : Colors.orange);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withOpacity(0.2))),
      child: Text(qualite, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(40.0),
        child: Column(
          children: [
            Icon(Icons.eco_outlined, size: 50, color: Colors.grey),
            SizedBox(height: 10),
            Text("Aucune récolte enregistrée", style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) => '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

  void _showAddRecolteDialog() {
    showDialog(context: context, builder: (context) => const AddRecolteDialog());
  }

  void _showEditRecolteDialog(Recolte recolte) {
    showDialog(context: context, builder: (context) => EditRecolteDialog(recolte: recolte));
  }

  void _showDeleteConfirmDialog(Recolte recolte) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer'),
        content: const Text('Voulez-vous vraiment supprimer cette récolte ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await Provider.of<RecolteProvider>(context, listen: false).deleteRecolte(recolte.id!);
              Navigator.pop(context);
            },
            child: const Text('Supprimer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// --- FORMULAIRE D'AJOUT DE RÉCOLTE ---

class AddRecolteDialog extends StatefulWidget {
  const AddRecolteDialog({Key? key}) : super(key: key);

  @override
  State<AddRecolteDialog> createState() => _AddRecolteDialogState();
}

class _AddRecolteDialogState extends State<AddRecolteDialog> {
  final _formKey = GlobalKey<FormState>();
  final _quantiteController = TextEditingController();
  final _observationController = TextEditingController();
  final _dateController = TextEditingController();
  
  int? _selectedCultureId;
  String _qualite = 'excellente';
  String _unite = 'kg';
  DateTime _dateRecolte = DateTime.now();

  @override
  void initState() {
    super.initState();
    _dateController.text = _formatDate(_dateRecolte);
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
                    const Text("Nouvelle Récolte", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20))),
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
                          Expanded(child: _buildDateField("Date de récolte *")),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _buildInputField("Quantité *", _quantiteController, "Ex: 500", isNumber: true)),
                          const SizedBox(width: 20),
                          Expanded(child: _buildDropdownField("Unité *", ['kg', 'tonne', 'litre', 'piece'], (v) => _unite = v!)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _buildDropdownField("Qualité *", ['excellente', 'bonne', 'moyenne'], (v) => _qualite = v!)),
                          const SizedBox(width: 20),
                          Expanded(child: _buildInputField("Observations", _observationController, "Notes...")),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildBtn("Annuler", Colors.white, Colors.black, () => Navigator.pop(context), true),
                          const SizedBox(width: 20),
                          _buildBtn("Enregistrer", const Color(0xFF21A84D), Colors.white, _handleSave, false, isLoading: _isLoading),
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
      const Text("Culture *", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      const SizedBox(height: 8),
      Consumer<CulturesProvider>(builder: (context, provider, child) {
        return DropdownButtonFormField<int>(
          decoration: _inputDeco("Choisir"),
          value: _selectedCultureId,
          items: provider.cultures.map((c) => DropdownMenuItem(value: c.id, child: Text(c.nom))).toList(),
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
        controller: _dateController,
        readOnly: true,
        onTap: _pickDate,
        decoration: _inputDeco("Sélectionner").copyWith(suffixIcon: const Icon(Icons.calendar_today, size: 18)),
      ),
    ]);
  }

  Widget _buildBtn(String txt, Color bg, Color tx, VoidCallback tap, bool out, {bool isLoading = false}) {
    return SizedBox(
      width: 180, 
      height: 48, 
      child: ElevatedButton(
        onPressed: isLoading ? null : tap,
        style: ElevatedButton.styleFrom(
          backgroundColor: isLoading ? Colors.grey : bg, 
          elevation: 0, 
          side: out ? const BorderSide(color: Color(0xFFEEEEEE)) : null,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: isLoading 
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
            : Text(txt, style: TextStyle(color: tx, fontWeight: FontWeight.bold)),
      ),
    );
  }

  InputDecoration _inputDeco(String hint) => InputDecoration(
    hintText: hint, contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFEEEEEE))),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFEEEEEE))),
  );

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(context: context, initialDate: _dateRecolte, firstDate: DateTime(2020), lastDate: DateTime.now());
    if (picked != null) setState(() { _dateRecolte = picked; _dateController.text = _formatDate(picked); });
  }

  String _formatDate(DateTime d) => '${d.day.toString().padLeft(2,'0')}/${d.month.toString().padLeft(2,'0')}/${d.year}';

  bool _isLoading = false;

  void _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_isLoading) return;
    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.user;
    
    if (currentUser == null) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur: Utilisateur non connecté'), backgroundColor: Colors.red),
      );
      return;
    }
    
    final recolte = Recolte(
      userId: currentUser.id,
      cultureId: _selectedCultureId!,
      quantite: double.parse(_quantiteController.text),
      unite: _unite,
      qualite: _qualite,
      dateRecolte: _dateRecolte,
      observation: _observationController.text,
    );
    
    final success = await Provider.of<RecolteProvider>(context, listen: false).addRecolte(recolte);
    
    if (!mounted) return;
    setState(() => _isLoading = false);
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Récolte ajoutée avec succès !'), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    } else {
      final error = Provider.of<RecolteProvider>(context, listen: false).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${error ?? 'Impossible d\'ajouter la récolte'}'), backgroundColor: Colors.red),
      );
    }
  }
}

// --- FORMULAIRE DE MODIFICATION DE RÉCOLTE ---

class EditRecolteDialog extends StatefulWidget {
  final Recolte recolte;

  const EditRecolteDialog({Key? key, required this.recolte}) : super(key: key);

  @override
  State<EditRecolteDialog> createState() => _EditRecolteDialogState();
}

class _EditRecolteDialogState extends State<EditRecolteDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _quantiteController;
  late final TextEditingController _observationController;
  late final TextEditingController _dateController;
  
  late int? _selectedCultureId;
  late String _qualite;
  late String _unite;
  late DateTime _dateRecolte;

  @override
  void initState() {
    super.initState();
    // Initialiser les contrôleurs avec les valeurs de la récolte existante
    _quantiteController = TextEditingController(text: widget.recolte.quantite.toString());
    _observationController = TextEditingController(text: widget.recolte.observation ?? '');
    _dateController = TextEditingController(text: _formatDate(widget.recolte.dateRecolte));
    
    _selectedCultureId = widget.recolte.cultureId;
    _qualite = widget.recolte.qualite;
    _unite = widget.recolte.unite;
    _dateRecolte = widget.recolte.dateRecolte;
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CulturesProvider>(context, listen: false).fetchCultures();
    });
  }

  @override
  void dispose() {
    _quantiteController.dispose();
    _observationController.dispose();
    _dateController.dispose();
    super.dispose();
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
                    const Text("Modifier la Récolte", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20))),
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
                          Expanded(child: _buildDateField("Date de récolte *")),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _buildInputField("Quantité *", _quantiteController, "Ex: 500", isNumber: true)),
                          const SizedBox(width: 20),
                          Expanded(child: _buildDropdownField("Unité *", ['kg', 'tonne', 'litre', 'piece'], (v) => _unite = v!)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _buildDropdownField("Qualité *", ['excellente', 'bonne', 'moyenne'], (v) => _qualite = v!)),
                          const SizedBox(width: 20),
                          Expanded(child: _buildInputField("Observations", _observationController, "Notes...")),
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
      const Text("Culture *", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      const SizedBox(height: 8),
      Consumer<CulturesProvider>(builder: (context, provider, child) {
        // Trouver la valeur initiale si elle existe dans la liste
        int? initialValue = _selectedCultureId;
        if (initialValue != null && !provider.cultures.any((c) => c.id == initialValue)) {
          // Si la culture n'est plus dans la liste, ne pas pré-sélectionner
          initialValue = null;
        }
        return DropdownButtonFormField<int>(
          decoration: _inputDeco("Choisir"),
          value: initialValue,
          items: provider.cultures.map((c) => DropdownMenuItem(value: c.id, child: Text(c.nom))).toList(),
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
        value: items.contains(_qualite) ? _qualite : items.first,
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
        controller: _dateController,
        readOnly: true,
        onTap: _pickDate,
        decoration: _inputDeco("Sélectionner").copyWith(suffixIcon: const Icon(Icons.calendar_today, size: 18)),
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

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(context: context, initialDate: _dateRecolte, firstDate: DateTime(2020), lastDate: DateTime.now());
    if (picked != null) setState(() { _dateRecolte = picked; _dateController.text = _formatDate(picked); });
  }

  String _formatDate(DateTime d) => '${d.day.toString().padLeft(2,'0')}/${d.month.toString().padLeft(2,'0')}/${d.year}';

  void _handleSave() async {
    if (_formKey.currentState!.validate()) {
      final recolte = Recolte(
        id: widget.recolte.id,
        userId: widget.recolte.userId,
        cultureId: _selectedCultureId!,
        quantite: double.parse(_quantiteController.text),
        unite: _unite,
        qualite: _qualite,
        dateRecolte: _dateRecolte,
        observation: _observationController.text,
        culture: widget.recolte.culture,
        createdAt: widget.recolte.createdAt,
      );
      
      final success = await Provider.of<RecolteProvider>(context, listen: false).updateRecolte(widget.recolte.id!, recolte);
      if (mounted && success) Navigator.pop(context);
    }
  }
}

