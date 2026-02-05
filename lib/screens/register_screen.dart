// lib/screens/register_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  // Contrôleurs
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _defaultWeatherCityController = TextEditingController();
  final _farmNameController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _defaultWeatherCityController.dispose();
    _farmNameController.dispose();
    super.dispose();
  }

  // Fonction utilitaire pour le style des champs
  InputDecoration _inputDeco(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.green[700], size: 22),
      filled: true,
      fillColor: Colors.grey[50],
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.green, width: 2),
      ),
    );
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (_passwordController.text != _confirmPasswordController.text) {
      _showSnackBar('Les mots de passe ne correspondent pas', Colors.red);
      return;
    }

    try {
      final userData = {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'password': _passwordController.text,
        'password_confirmation': _confirmPasswordController.text,
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'default_weather_city': _defaultWeatherCityController.text.trim(),
        'farm_name': _farmNameController.text.trim(),
      };

      final success = await authProvider.register(userData);

      if (success && mounted) {
        _showSnackBar('Compte créé avec succès !', Colors.green);
        // Rediriger vers la page de connexion pour que l'utilisateur s'authentifie
        Navigator.of(context).pushReplacementNamed('/login');
      } else if (mounted) {
        _showSnackBar(authProvider.error ?? 'Erreur lors de l\'inscription', Colors.red);
      }
    } catch (e) {
      _showSnackBar('Erreur: $e', Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color, behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.green[100]!, Colors.white, Colors.green[50]!],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // LOGO ET TITRE
                    const Icon(Icons.eco, color: Color(0xFF21A84D), size: 60),
                    const SizedBox(height: 10),
                    Text(
                      'Créer un compte',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[900],
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Rejoignez l\'aventure AgriFarm',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                    const SizedBox(height: 30),

                    // FORMULAIRE DANS UNE CARTE
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          )
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _nameController,
                              decoration: _inputDeco('Nom complet *', Icons.person_outline),
                              validator: (v) => v!.isEmpty ? 'Le nom est requis' : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _emailController,
                              decoration: _inputDeco('Email *', Icons.email_outlined),
                              keyboardType: TextInputType.emailAddress,
                              validator: (v) => !v!.contains('@') ? 'Email invalide' : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _phoneController,
                              decoration: _inputDeco('Téléphone *', Icons.phone_android_outlined),
                              keyboardType: TextInputType.phone,
                              validator: (v) => v!.isEmpty ? 'Le téléphone est requis' : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              decoration: _inputDeco('Mot de passe *', Icons.lock_outline).copyWith(
                                suffixIcon: IconButton(
                                  icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                ),
                              ),
                              validator: (v) => v!.length < 6 ? '6 caractères minimum' : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _confirmPasswordController,
                              obscureText: _obscureConfirmPassword,
                              decoration: _inputDeco('Confirmer mot de passe *', Icons.lock_reset),
                              validator: (v) => v != _passwordController.text ? 'Mots de passe différents' : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _addressController,
                              decoration: _inputDeco('Adresse *', Icons.map_outlined),
                              validator: (v) => v!.isEmpty ? 'L\'adresse est requise' : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _defaultWeatherCityController,
                              decoration: _inputDeco('Ville (Météo) *', Icons.wb_cloudy_outlined),
                              validator: (v) => v!.isEmpty ? 'La ville est requise' : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _farmNameController,
                              decoration: _inputDeco('Nom de la ferme', Icons.agriculture),
                            ),
                            const SizedBox(height: 30),

                            // BOUTON VALIDER
                            Consumer<AuthProvider>(
                              builder: (context, auth, _) {
                                return SizedBox(
                                  width: double.infinity,
                                  height: 55,
                                  child: ElevatedButton(
                                    onPressed: auth.isLoading ? null : _handleRegister,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green[700],
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      elevation: 0,
                                    ),
                                    child: auth.isLoading
                                        ? const CircularProgressIndicator(color: Colors.white)
                                        : const Text(
                                            'S\'inscrire',
                                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                          ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),

                    // LIEN VERS LOGIN
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Déjà un compte ? ', style: TextStyle(color: Colors.grey)),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'Se connecter',
                            style: TextStyle(color: Colors.green[800], fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}