import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cultures_provider.dart';
import '../providers/auth_provider.dart';
import '../models/culture.dart';

class AddCultureScreen extends StatefulWidget {
  final Culture? culture;

  const AddCultureScreen({super.key, this.culture});

  @override
  State<AddCultureScreen> createState() => _AddCultureScreenState();
}

class _AddCultureScreenState extends State<AddCultureScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _surfaceController = TextEditingController();
  final _villeController = TextEditingController();
  final _dateController = TextEditingController();
  
  String? _type;
  String? _etat;
  DateTime _datePlantation = DateTime.now();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.culture != null;
    if (_isEditing) {
      _prefillFields();
    }
  }

  void _prefillFields() {
    final culture = widget.culture!;
    _nomController.text = culture.nom;
    _surfaceController.text = culture.surface.toString();
    _villeController.text = culture.ville ?? '';
    _type = culture.type;
    _etat = culture.etat;
    _datePlantation = culture.datePlantation;
    _dateController.text = "${_datePlantation.day}/${_datePlantation.month}/${_datePlantation.year}";
  }

  @override
  void dispose() {
    _nomController.dispose();
    _surfaceController.dispose();
    _villeController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String title = _isEditing ? "Modifier la culture" : "Ajouter une nouvelle culture";
    final String buttonText = _isEditing ? "Enregistrer les modifications" : "Ajouter la culture";

    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.5),
      body: Center(
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
                // HEADER DE LA MODALE
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
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

                // FORMULAIRE
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // LIGNE 1 : Nom et Type
                        Row(
                          children: [
                            Expanded(child: _buildInputField("Nom de la culture *", _nomController, "Tomates Roma")),
                            const SizedBox(width: 20),
                            Expanded(child: _buildDropdownField("Type de culture *", ['céréale', 'légume', 'fruit'], (v) => _type = v, initialValue: _type)),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // LIGNE 2 : Date et Surface
                        Row(
                          children: [
                            Expanded(child: _buildDateField("Date de plantation *")),
                            const SizedBox(width: 20),
                            Expanded(child: _buildInputField("Surface (hectares) *", _surfaceController, "250.75", isNumber: true, isSurface: true)),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // LIGNE 3 : État et Ville
                        Row(
                          children: [
                            Expanded(child: _buildDropdownField("État actuel *", ['en croissance', 'mature', 'récoltée'], (v) => _etat = v, initialValue: _etat)),
                            const SizedBox(width: 20),
                            Expanded(child: _buildInputField("Ville", _villeController, "Lomé")),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // BOUTONS D'ACTION
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 200,
                              height: 50,
                              child: OutlinedButton(
                                onPressed: () => Navigator.pop(context),
                                style: OutlinedButton.styleFrom(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  side: const BorderSide(color: Color(0xFFEEEEEE)),
                                ),
                                child: const Text("Annuler", style: TextStyle(color: Colors.black)),
                              ),
                            ),
                            const SizedBox(width: 20),
                            SizedBox(
                              width: 200,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _handleSubmit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF21A84D),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  elevation: 0,
                                ),
                                child: Text(buttonText, style: const TextStyle(color: Colors.white)),
                              ),
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
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, String hint, {bool isNumber = false, bool isSurface = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFEEEEEE))),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez saisir ${label.toLowerCase().replaceAll('*', '').trim()}';
            }
            if (isSurface) {
              final surface = double.tryParse(value);
              if (surface == null || surface <= 0) {
                return 'La surface doit être supérieure à 0';
              }
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, List<String> items, Function(String?) onChanged, {String? initialValue}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFEEEEEE))),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          hint: const Text("Sélectionner", style: TextStyle(fontSize: 14)),
          value: initialValue,
          items: items.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
          onChanged: onChanged,
          validator: (v) => v == null ? 'Requis' : null,
        ),
      ],
    );
  }

  Widget _buildDateField(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 8),
        TextFormField(
          controller: _dateController,
          readOnly: true,
          onTap: _selectDate,
          decoration: InputDecoration(
            hintText: "jj/mm/aaaa",
            suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFEEEEEE))),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _datePlantation,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _datePlantation = picked;
        _dateController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.user?.id;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erreur: utilisateur non connecté')));
      return;
    }

    final provider = Provider.of<CulturesProvider>(context, listen: false);

    if (_isEditing) {
      // Mode modification
      final updatedCulture = Culture(
        id: widget.culture!.id,
        userId: userId,
        nom: _nomController.text,
        type: _type!,
        surface: double.parse(_surfaceController.text),
        datePlantation: _datePlantation,
        etat: _etat!,
        ville: _villeController.text.isEmpty ? null : _villeController.text,
        createdAt: widget.culture!.createdAt,
      );

      final success = await provider.updateCulture(widget.culture!.id!, updatedCulture);
      
      if (mounted && success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Culture modifiée avec succès'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      } else if (mounted && provider.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${provider.error}'), backgroundColor: Colors.red),
        );
      }
    } else {
      // Mode ajout
      final culture = Culture(
        nom: _nomController.text,
        type: _type!,
        surface: double.parse(_surfaceController.text),
        datePlantation: _datePlantation,
        etat: _etat!,
        ville: _villeController.text.isEmpty ? null : _villeController.text,
        userId: userId,
      );

      final success = await provider.addCulture(culture);
      
      if (mounted && success) {
        Navigator.pop(context);
      } else if (mounted && provider.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${provider.error}'), backgroundColor: Colors.red),
        );
      }
    }
  }
}

