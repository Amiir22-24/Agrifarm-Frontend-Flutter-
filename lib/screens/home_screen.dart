import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/cultures_provider.dart';
import '../providers/ventes_provider.dart';
import '../providers/stock_provider.dart';
import '../utils/constants.dart';

// Importations des écrans
import 'cultures_screen.dart';
import 'ventes_screen.dart';
import 'profile_screen.dart';
import 'stock_screen.dart';
import 'chat_screen.dart';
import 'rapport_screen_new.dart';
import 'notifications_screen.dart';
import 'recoltes_screen.dart';
import 'meteo_screen.dart';

// Nouvelles importations pour les providers et modèles
import '../providers/recolte_provider.dart';
import '../providers/notifications_provider.dart';
import '../providers/weather_provider.dart';
import '../models/recolte.dart';
import '../models/notification_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Liste des écrans correspondant aux index de la sidebar
  late final List<Widget> _widgetOptions = <Widget>[
    const HomeContent(),         // Index 0 - Tableau de Bord
    const CulturesScreen(),      // Index 1 - Gestion des Cultures
    const RecoltesScreen(), // Index 2 - Gestion des Récoltes
    const StockScreen(),         // Index 3 - Gestion des Stocks
    const MeteoScreen(),                                 // Index 4 - Service Météo
    const ChatScreen(),          // Index 5 - Assistant IA
    const RapportScreen(),       // Index 6 - Rapports
    const NotificationsScreen(), // Index 7 - Notifications
    const VentesScreen(),        // Index 8 - Ventes
    const ProfileScreen(),       // Index 9 - Profil
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // 🔧 DIAGNOSTIC : Méthode de déconnexion avec confirmation
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Se déconnecter"),
          content: const Text("Êtes-vous sûr de vouloir vous déconnecter ?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fermer le dialogue
              },
              child: const Text("Annuler"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fermer le dialogue
                _performLogout();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Se déconnecter"),
            ),
          ],
        );
      },
    );
  }

  // 🔧 DIAGNOSTIC : Effectuer la déconnexion
  void _performLogout() {
    // Appeler la méthode de déconnexion du UserProvider
    Provider.of<UserProvider>(context, listen: false).logout();
    
    // Naviguer vers l'écran de connexion
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/login',
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;

    return Scaffold(
      body: isMobile ? _buildMobileLayout() : _buildDesktopLayout(isTablet),
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        _buildTopNavbar(),
        Expanded(
          child: Container(
            color: const Color(0xFFF8F9FA),
            child: _widgetOptions.elementAt(_selectedIndex),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(bool isTablet) {
    final sidebarWidth = isTablet ? 220.0 : 260.0;

    return Row(
      children: [
        // SIDEBAR
        Container(
          width: sidebarWidth,
          color: Colors.white,
          child: Column(
            children: [
              _buildSidebarHeader(),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  children: [
                    _buildSidebarItem(Icons.dashboard_outlined, "Tableau de Bord", 0),
                    _buildSidebarItem(Icons.agriculture, "Gestion des Cultures", 1),
                    _buildSidebarItem(Icons.eco_outlined, "Gestion des Récoltes", 2),
                    _buildSidebarItem(Icons.inventory_2_outlined, "Gestion des Stocks", 3),
                    _buildSidebarItem(Icons.cloud_outlined, "Service Météo", 4),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Divider(),
                    ),
                    // SECTIONS SÉPARÉES IA ET RAPPORT
                    _buildSidebarItem(Icons.smart_toy_outlined, "Assistant IA", 5),
                    _buildSidebarItem(Icons.description_outlined, "Rapports", 6),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Divider(),
                    ),
                    _buildSidebarItem(Icons.notifications_none, "Notifications", 7),
                    _buildSidebarItem(Icons.trending_up, "Ventes", 8),
                    _buildSidebarItem(Icons.person_outline, "Profil", 9),
                  ],
                ),
              ),
              _buildTipCard(),
            ],
          ),
        ),
        const VerticalDivider(width: 1, thickness: 1, color: Color(0xFFEEEEEE)),

        // CONTENU PRINCIPAL
        Expanded(
          child: Column(
            children: [
              _buildTopNavbar(),
              Expanded(
                child: Container(
                  color: const Color(0xFFF8F9FA),
                  child: _widgetOptions.elementAt(_selectedIndex),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSidebarHeader() {
    return const Padding(
      padding: EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Tableau de Bord", 
            style: TextStyle(color: Color(0xFF1B5E20), fontWeight: FontWeight.bold, fontSize: 19)),
          SizedBox(height: 4),
          Text("Gestion de votre exploitation", 
            style: TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(IconData icon, String title, int index) {
    bool isSelected = _selectedIndex == index;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF21A84D) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        onTap: () => _onItemTapped(index),
        dense: true,
        leading: Icon(icon, color: isSelected ? Colors.white : Colors.black54, size: 22),
        title: Text(title, 
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87, 
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 13,
          )),
      ),
    );
  }

  Widget _buildTopNavbar() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        final user = userProvider.user;
        return Container(
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
          ),
          child: Row(
            children: [
              const Icon(Icons.eco, color: Color(0xFF21A84D), size: 30),
              const SizedBox(width: 10),
              const Text("AgriFarm", 
                style: TextStyle(color: Color(0xFF1B5E20), fontWeight: FontWeight.bold, fontSize: 22)),
              const Spacer(),
              const Icon(Icons.notifications_none, color: Colors.black54),
              const SizedBox(width: 20),
              const VerticalDivider(indent: 20, endIndent: 20),
              const SizedBox(width: 20),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'logout') {
                    _showLogoutDialog();
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem<String>(
                    value: 'profile',
                    child: ListTile(
                      leading: const Icon(Icons.person_outline),
                      title: Text(user?.name ?? "Utilisateur"),
                      subtitle: const Text("Agriculteur"),
                      dense: true,
                    ),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem<String>(
                    value: 'logout',
                    child: ListTile(
                      leading: const Icon(Icons.logout, color: Colors.red),
                      title: const Text("Se déconnecter"),
                      dense: true,
                    ),
                  ),
                ],
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(user?.name ?? "Utilisateur", style: const TextStyle(fontWeight: FontWeight.bold)),
                        const Text("Agriculteur", style: TextStyle(fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(width: 12),
                    CircleAvatar(
                      backgroundColor: const Color(0xFF21A84D),
                      radius: 18,
                      child: Text(
                        user?.name != null ? user!.name.substring(0, 2).toUpperCase() : "JD",
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_drop_down, color: Colors.black54),
                  ],
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _buildTipCard() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F8E9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: Color(0xFF21A84D), shape: BoxShape.circle),
                child: const Icon(Icons.lightbulb_outline, color: Colors.white, size: 16),
              ),
              const SizedBox(width: 8),
              const Text("Astuce du jour", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1B5E20))),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            "Utilisez l'IA pour obtenir des recommandations personnalisées sur vos cultures", 
            style: TextStyle(fontSize: 11, color: Colors.black87, height: 1.4),
          ),
        ],
      ),
    );
  }
}

// Classe HomeContent - Tableau de bord principal avec statistiques
class HomeContent extends StatefulWidget {
  const HomeContent({Key? key}) : super(key: key);

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Charger toutes les données au démarrage
      _loadAllData();
    });
  }

  void _loadAllData() {
    // 🔧 CORRECTION: Vider les données précédentes avant de charger les nouvelles
    Provider.of<CulturesProvider>(context, listen: false).clearData();
    Provider.of<VentesProvider>(context, listen: false).clearData();
    Provider.of<StockProvider>(context, listen: false).clearData();
    Provider.of<RecolteProvider>(context, listen: false).clearData();
    Provider.of<NotificationsProvider>(context, listen: false).clearData();

    // Charger les données de tous les providers
    Provider.of<CulturesProvider>(context, listen: false).fetchCultures();
    Provider.of<VentesProvider>(context, listen: false).fetchVentes();
    Provider.of<StockProvider>(context, listen: false).fetchStocks();
    Provider.of<RecolteProvider>(context, listen: false).fetchRecoltes();
    Provider.of<NotificationsProvider>(context, listen: false).fetchNotifications();

    // 🔧 CORRECTION: Charger la météo avec la ville de l'utilisateur en temps réel
    _loadWeatherData();
  }

  /// Méthode pour charger les données météo en temps réel avec la ville de l'utilisateur
  Future<void> _loadWeatherData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final weatherProvider = Provider.of<WeatherProvider>(context, listen: false);
    
    try {
      // 1. D'abord récupérer le profil utilisateur (avec sa ville par défaut)
      await userProvider.fetchUser();
      
      // 2. Récupérer la ville météo de l'utilisateur (depuis l'API si nécessaire)
      await userProvider.fetchUserWeatherCity();
      
      // 3. Déterminer la ville cible (priorité: profile > userWeatherCity > défaut)
      final String targetCity = _getTargetCity(userProvider);
      
      // 4. Charger la météo en temps réel avec la bonne ville
      await weatherProvider.loadCurrentWeather(userWeatherCity: targetCity);
      
      print('🌤️ Météo chargée en temps réel pour: $targetCity');
    } catch (e) {
      print('❌ Erreur lors du chargement de la météo: $e');
      // En cas d'erreur, charger avec la ville par défaut
      await weatherProvider.loadCurrentWeather();
    }
  }

  /// Méthode d'aide pour déterminer la ville cible pour la météo en temps réel
  String _getTargetCity(UserProvider userProvider) {
    // Priorité 1: Ville du profil utilisateur (depuis l'API)
    if (userProvider.user?.profile?.defaultWeatherCity != null && 
        userProvider.user!.profile!.defaultWeatherCity.isNotEmpty) {
      print('🎯 Ville utilisée (profil): ${userProvider.user!.profile!.defaultWeatherCity}');
      return userProvider.user!.profile!.defaultWeatherCity;
    }
    
    // Priorité 2: Ville stockée dans UserProvider
    if (userProvider.userWeatherCity != null && 
        userProvider.userWeatherCity!.isNotEmpty) {
      print('🎯 Ville utilisée (stockée): ${userProvider.userWeatherCity}');
      return userProvider.userWeatherCity!;
    }
    
    // Valeur par défaut
    print('🎯 Ville utilisée (défaut): Paris');
    return 'Paris';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeHeader(),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Première rangée - Cartes principales
                  Row(
                    children: [
                      Expanded(child: _buildCulturesCard()),
                      const SizedBox(width: 16),
                      Expanded(child: _buildVentesCard()),
                      const SizedBox(width: 16),
                      Expanded(child: _buildStockCard()),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Deuxième rangée - Cartes secondaires
                  Row(
                    children: [
                      Expanded(child: _buildRecoltesCard()),
                      const SizedBox(width: 16),
                      Expanded(child: _buildWeatherCard()),
                      const SizedBox(width: 16),
                      Expanded(child: _buildNotificationsCard()),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        final user = userProvider.user;
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF21A84D), Color(0xFF1B5E20)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Bonjour, ${user?.name ?? 'Agriculteur'} !",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Voici un aperçu de votre exploitation agricole",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.eco,
                color: Colors.white,
                size: 48,
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _buildCulturesCard() {
    return Consumer<CulturesProvider>(
      builder: (context, culturesProvider, _) {
        final cultures = culturesProvider.cultures;
        final isLoading = culturesProvider.isLoading;

        return Card(
          elevation: 4,
          child: InkWell(
            onTap: () {
              // Navigation vers la gestion des cultures
              _navigateToScreen(1);
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [Colors.green[50]!, Colors.green[100]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.agriculture, color: Colors.green[600], size: 32),
                      const Spacer(),
                      _buildStatusIndicator(isLoading),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isLoading ? "..." : "${cultures.length}",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Cultures Actives",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.trending_up, size: 16, color: Colors.green),
                      const SizedBox(width: 4),
                      Text(
                        "Gestion optimale",
                        style: TextStyle(fontSize: 12, color: Colors.green[700]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }
    );
  }

  Widget _buildVentesCard() {
    return Consumer<VentesProvider>(
      builder: (context, ventesProvider, _) {
        final ventes = ventesProvider.ventes;
        final isLoading = ventesProvider.isLoading;
        final totalRevenue = ventesProvider.totalRevenue;
        final totalVentes = ventesProvider.totalVentes;

        return Card(
          elevation: 4,
          child: InkWell(
            onTap: () {
              // Navigation vers les ventes
              _navigateToScreen(8);
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [Colors.blue[50]!, Colors.blue[100]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.trending_up, color: Colors.blue[600], size: 32),
                      const Spacer(),
                      _buildStatusIndicator(isLoading),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Afficher le TOTAL en grand
                  Text(
                    isLoading ? "..." : formatCFA(totalRevenue),
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Total des Ventes",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Nombre de ventes en info secondaire
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "$totalVentes vente${totalVentes != 1 ? 's' : ''}",
                          style: TextStyle(fontSize: 11, color: Colors.blue[700], fontWeight: FontWeight.w500),
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
    );
  }

  Widget _buildStockCard() {
    return Consumer<StockProvider>(
      builder: (context, stockProvider, _) {
        final stocks = stockProvider.stocks;
        final isLoading = stockProvider.isLoading;
        final stocksDisponibles = stockProvider.stocksDisponibles;

        return Card(
          elevation: 4,
          child: InkWell(
            onTap: () {
              // Navigation vers la gestion des stocks
              _navigateToScreen(3);
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [Colors.orange[50]!, Colors.orange[100]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.inventory_2, color: Colors.orange[600], size: 32),
                      const Spacer(),
                      _buildStatusIndicator(isLoading),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isLoading ? "..." : "${stocks.length}",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Produits en Stock",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.check_circle, size: 16, color: Colors.orange),
                      const SizedBox(width: 4),
                      Text(
                        isLoading ? "..." : "${stocksDisponibles} disponibles",
                        style: TextStyle(fontSize: 12, color: Colors.orange[700]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }
    );
  }


  Widget _buildRecoltesCard() {
    return Consumer<RecolteProvider>(
      builder: (context, recolteProvider, _) {
        final recoltes = recolteProvider.recoltes;
        final isLoading = recolteProvider.isLoading;
        
        // Calculer les récoltes par qualité
        final recoltesExcellentes = recoltes.where((r) => r.qualite == 'excellente').length;

        return Card(
          elevation: 4,
          child: InkWell(
            onTap: () {
              // Navigation vers la gestion des récoltes
              _navigateToScreen(2);
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [Colors.purple[50]!, Colors.purple[100]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.eco, color: Colors.purple[600], size: 32),
                      const Spacer(),
                      _buildStatusIndicator(isLoading),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isLoading ? "..." : "${recoltes.length}",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Récoltes",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16, color: Colors.purple),
                      const SizedBox(width: 4),
                      Text(
                        isLoading ? "..." : "$recoltesExcellentes excellentes",
                        style: TextStyle(fontSize: 12, color: Colors.purple[700]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }
    );
  }

  Widget _buildWeatherCard() {
    // 🔧 CORRECTION : Utiliser le vrai widget WeatherCard avec gestion correcte de la ville
    return Consumer2<WeatherProvider, UserProvider>(
      builder: (context, weatherProvider, userProvider, _) {
        // Déterminer la ville cible en utilisant la méthode centralisée
        final String targetCity = _getTargetCity(userProvider);
        
        // Charger la météo uniquement si pas encore chargée
        final shouldLoad = !weatherProvider.isLoading && 
                          weatherProvider.currentWeather == null;
        
        // Utiliser addPostFrameCallback pour éviter les appels répétés
        if (shouldLoad && mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (targetCity.isNotEmpty) {
              weatherProvider.loadCurrentWeather(userWeatherCity: targetCity);
            } else {
              // Ville par défaut si aucune n'est configurée
              weatherProvider.loadCurrentWeather();
            }
          });
        }

        if (weatherProvider.isLoading && weatherProvider.currentWeather == null) {
          // Indicateur de chargement
          return Card(
            elevation: 4,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [Colors.cyan[50]!, Colors.cyan[100]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      targetCity.isNotEmpty 
                          ? 'Chargement météo pour $targetCity...'
                          : 'Chargement météo...',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (weatherProvider.currentWeather == null) {
          // Carte statique de fallback si pas de données
          return Card(
            elevation: 4,
            child: InkWell(
              onTap: () {
                _navigateToScreen(4);
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: [Colors.cyan[50]!, Colors.cyan[100]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.cloud, color: Colors.cyan[600], size: 32),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.orange[500],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            "NON DISPONIBLE",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Météo",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.cyan,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      targetCity.isNotEmpty
                          ? 'Ville: $targetCity (configurée)'
                          : 'Aucune ville configurée',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Cliquez pour configurer votre ville",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // Afficher les vraies données météo
        final weather = weatherProvider.currentWeather!;
        final city = weather['city'] ?? weather['ville'] ?? 'Ville';
        final temp = weather['temperature'] ?? '--';
        final desc = weather['description'] ?? 'Données disponibles';
        final humidity = weather['humidity'] ?? '--';

        return Card(
          elevation: 4,
          child: InkWell(
            onTap: () {
              _navigateToScreen(4);
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [Colors.blue[400]!, Colors.blue[600]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            city,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            desc,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.wb_sunny,
                        color: Colors.white,
                        size: 40,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildWeatherInfo(Icons.thermostat, '$temp°C'),
                      const SizedBox(width: 24),
                      _buildWeatherInfo(Icons.water_drop, '$humidity%'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWeatherInfo(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(width: 6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationsCard() {
    return Consumer<NotificationsProvider>(
      builder: (context, notificationsProvider, _) {
        final notifications = notificationsProvider.notifications;
        final isLoading = notificationsProvider.isLoading;
        final unreadCount = notificationsProvider.unreadCount;

        return Card(
          elevation: 4,
          child: InkWell(
            onTap: () {
              // Navigation vers les notifications
              _navigateToScreen(7);
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [Colors.red[50]!, Colors.red[100]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.notifications, color: Colors.red[600], size: 32),
                      const Spacer(),
                      if (unreadCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red[500],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isLoading ? "..." : "${notifications.length}",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Notifications",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(unreadCount > 0 ? Icons.mark_email_unread : Icons.mark_email_read, 
                           size: 16, color: Colors.red),
                      const SizedBox(width: 4),
                      Text(
                        isLoading ? "..." : "${unreadCount} non lues",
                        style: TextStyle(fontSize: 12, color: Colors.red[700]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }
    );
  }

  Widget _buildStatusIndicator(bool isLoading) {
    if (isLoading) {
      return const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }
    return Container(
      width: 12,
      height: 12,
      decoration: const BoxDecoration(
        color: Colors.green,
        shape: BoxShape.circle,
      ),
    );
  }

  // Méthode pour naviguer vers une autre section
  void _navigateToScreen(int index) {
    // Cette méthode sera appelée depuis le contexte de HomeContent
    // pour naviguer vers une autre section de l'application
    final homeScreenState = context.findAncestorStateOfType<_HomeScreenState>();
    if (homeScreenState != null) {
      homeScreenState.setState(() {
        homeScreenState._selectedIndex = index;
      });
    }
  }
}

