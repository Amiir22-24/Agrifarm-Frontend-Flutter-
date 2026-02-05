import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';
import '../models/user.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _farmNameController = TextEditingController();
  final _weatherCityController = TextEditingController();

  // Password change controllers
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserProvider>(context, listen: false).fetchUser();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _farmNameController.dispose();
    _weatherCityController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: const Color(0xFF21A84D),
        elevation: 0,
      ),
      body: Consumer<UserProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = provider.user;
          if (user == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('Erreur de chargement du profil'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.fetchUser(),
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header avec avatar
                _buildHeader(user),
                const SizedBox(height: 24),

                // Carte d'informations personnelles
                _buildInfoCard(user),
                const SizedBox(height: 24),

                // Carte d'informations de la ferme
                _buildFarmCard(user),
                const SizedBox(height: 24),

                // Boutons d'actions
                _buildActionButtons(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(User user) {
    return Center(
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFF21A84D),
              borderRadius: BorderRadius.circular(50),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Center(
              child: Text(
                user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            user.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user.email,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(User user) {
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
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF21A84D).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.person_outline,
                    color: Color(0xFF21A84D),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Informations personnelles',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B5E20),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow(
              Icons.phone,
              'Téléphone',
              user.profile?.phone ?? 'Non renseigné',
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              Icons.location_on,
              'Adresse',
              user.profile?.address ?? 'Non renseignée',
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              Icons.location_city,
              'Ville météo',
              user.profile?.defaultWeatherCity ?? 'Non définie',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFarmCard(User user) {
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
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.agriculture,
                    color: Colors.blue,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Informations de la ferme',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B5E20),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow(
              Icons.grass,
              'Nom de la ferme',
              user.profile?.farmName ?? 'Non renseigné',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
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
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _showEditDialog(),
            icon: const Icon(Icons.edit, color: Colors.white),
            label: const Text(
              'Modifier le profil',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
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
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _showChangePasswordDialog(),
            icon: const Icon(Icons.lock_outline, color: Color(0xFF21A84D)),
            label: const Text(
              'Changer le mot de passe',
              style: TextStyle(
                color: Color(0xFF21A84D),
                fontWeight: FontWeight.w600,
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: const BorderSide(color: Color(0xFF21A84D)),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _logout(),
            icon: const Icon(Icons.logout, color: Colors.white),
            label: const Text(
              'Se déconnecter',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showEditDialog() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;

    if (user == null) return;

    // Initialiser les contrôleurs avec les valeurs actuelles
    _nameController.text = user.name;
    _phoneController.text = user.profile?.phone ?? '';
    _addressController.text = user.profile?.address ?? '';
    _farmNameController.text = user.profile?.farmName ?? '';
    _weatherCityController.text = user.profile?.defaultWeatherCity ?? '';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
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
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Color(0xFFEEEEEE)),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Modifier le profil",
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
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        _buildEditField(
                          'Nom complet *',
                          _nameController,
                          Icons.person,
                          TextInputType.name,
                        ),
                        const SizedBox(height: 16),
                        _buildEditField(
                          'Téléphone *',
                          _phoneController,
                          Icons.phone,
                          TextInputType.phone,
                        ),
                        const SizedBox(height: 16),
                        _buildEditField(
                          'Adresse *',
                          _addressController,
                          Icons.location_on,
                          TextInputType.streetAddress,
                        ),
                        const SizedBox(height: 16),
                        _buildEditField(
                          'Nom de la ferme',
                          _farmNameController,
                          Icons.agriculture,
                          TextInputType.text,
                        ),
                        const SizedBox(height: 16),
                        _buildEditField(
                          'Ville météo par défaut',
                          _weatherCityController,
                          Icons.wb_sunny,
                          TextInputType.text,
                          hint: 'Ex: Lomé',
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Color(0xFFEEEEEE)),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 150,
                          height: 48,
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFFEEEEEE)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Annuler',
                              style: TextStyle(color: Colors.black87),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        SizedBox(
                          width: 150,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () => _handleEditProfile(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF21A84D),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: userProvider.isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Enregistrer',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
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
        ),
      ),
    );
  }

  Widget _buildEditField(
    String label,
    TextEditingController controller,
    IconData icon,
    TextInputType keyboardType, {
    String? hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint ?? label.replaceAll('*', '').trim(),
            prefixIcon: Icon(icon, size: 18, color: Colors.grey[600]),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
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
          validator: (value) {
            if (label.contains('*') && (value == null || value.isEmpty)) {
              return 'Ce champ est requis';
            }
            return null;
          },
        ),
      ],
    );
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            constraints: const BoxConstraints(maxWidth: 500),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Color(0xFFEEEEEE)),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Changer le mot de passe",
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
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        _buildPasswordField(
                          'Mot de passe actuel *',
                          _currentPasswordController,
                          Icons.lock_outline,
                          true,
                        ),
                        const SizedBox(height: 16),
                        _buildPasswordField(
                          'Nouveau mot de passe *',
                          _newPasswordController,
                          Icons.lock,
                          true,
                          hint: 'Minimum 8 caractères',
                        ),
                        const SizedBox(height: 16),
                        _buildPasswordField(
                          'Confirmer le mot de passe *',
                          _confirmPasswordController,
                          Icons.lock_reset,
                          true,
                        ),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: const [
                              Icon(Icons.info_outline, color: Colors.blue, size: 20),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Le nouveau mot de passe doit contenir au moins 8 caractères.',
                                  style: TextStyle(fontSize: 12, color: Colors.blue),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Color(0xFFEEEEEE)),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 150,
                          height: 48,
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFFEEEEEE)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Annuler',
                              style: TextStyle(color: Colors.black87),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        SizedBox(
                          width: 150,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () => _handleChangePassword(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF21A84D),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Consumer<UserProvider>(
                              builder: (context, provider, _) {
                                if (provider.isLoading) {
                                  return const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  );
                                }
                                return const Text(
                                  'Modifier',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              },
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
      ),
    );
  }

  Widget _buildPasswordField(
    String label,
    TextEditingController controller,
    IconData icon,
    bool obscure, {
    String? hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          decoration: InputDecoration(
            hintText: hint ?? label.replaceAll('*', '').trim(),
            prefixIcon: Icon(icon, size: 18, color: Colors.grey[600]),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
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
          validator: (value) {
            if (label.contains('*') && (value == null || value.isEmpty)) {
              return 'Ce champ est requis';
            }
            return null;
          },
        ),
      ],
    );
  }

  Future<void> _handleEditProfile() async {
    if (_nameController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir tous les champs obligatoires'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final userProvider = Provider.of<UserProvider>(context, listen: false);

    final data = {
      'name': _nameController.text,
      'phone': _phoneController.text,
      'address': _addressController.text,
      if (_farmNameController.text.isNotEmpty)
        'farm_name': _farmNameController.text,
      if (_weatherCityController.text.isNotEmpty)
        'default_weather_city': _weatherCityController.text,
    };

    final success = await userProvider.updateUser(data);

    if (mounted) {
      Navigator.pop(context);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil mis à jour avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(userProvider.error ?? 'Erreur lors de la mise à jour'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleChangePassword() async {
    if (_currentPasswordController.text.isEmpty ||
        _newPasswordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir tous les champs'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_newPasswordController.text.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Le nouveau mot de passe doit contenir au moins 8 caractères'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Les mots de passe ne correspondent pas'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final userProvider = Provider.of<UserProvider>(context, listen: false);

    final success = await userProvider.changePassword(
      currentPassword: _currentPasswordController.text,
      newPassword: _newPasswordController.text,
      confirmPassword: _confirmPasswordController.text,
    );

    if (mounted) {
      if (success) {
        Navigator.pop(context);
        // Clear password fields
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mot de passe modifié avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(userProvider.error ?? 'Erreur lors du changement de mot de passe'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Voulez-vous vraiment vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text(
              'Déconnexion',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await Provider.of<AuthProvider>(context, listen: false).logout();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }
}

