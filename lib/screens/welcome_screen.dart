import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  // Routes de navigation
  final String loginRoute = '/login';
  final String registerRoute = '/register';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.eco, color: Colors.green, size: 30),
            const SizedBox(width: 8),
            const Text('AgriFarm', 
              style: TextStyle(color: Color(0xFF1B5E20), fontWeight: FontWeight.bold)
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pushNamed(context, loginRoute),
            child: const Text('Se connecter', style: TextStyle(color: Color(0xFF2E7D32))),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, registerRoute),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('S\'enregistrer', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- SECTION HERO (Image Drone) ---
            _buildHeroSection(context),

            // --- SECTION FONCTIONNALITÉS ---
            _buildFeaturesSection(),

            // --- SECTION POURQUOI CHOISIR ---
            _buildWhyChooseSection(),

            // --- SECTION CTA (Vert Foncé) ---
            _buildCTASection(context),

            // --- FOOTER ---
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  // 1. SECTION HERO
  Widget _buildHeroSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
      decoration: BoxDecoration(
        image: DecorationImage(
        image: const NetworkImage('https://images.unsplash.com/photo-1574943320219-553eb213f72d?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1000&q=80'), // Agriculture moderne avec drone
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.darken),
        ),
      ),
      child: Column(
        children: [
          const Text(
            'Révolutionnez votre Agriculture avec AgriFarm',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 20),
          const Text(
            'La plateforme intelligente qui transforme la gestion agricole grâce à l\'IA, le monitoring en temps réel et des outils de gestion avancés',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, registerRoute),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
                child: const Text('Commencer gratuitement', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF1B5E20),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
                child: const Text('Découvrir les fonctionnalités'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 2. SECTION FONCTIONNALITÉS
  Widget _buildFeaturesSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
      child: Column(
        children: [
          const Text('Fonctionnalités Complètes',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20))),
          const SizedBox(height: 16),
          const Text('Découvrez toutes les fonctionnalités qui font d\'AgriFarm la solution idéale pour moderniser votre exploitation agricole',
              textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 16)),
          const SizedBox(height: 40),
          Wrap(
            spacing: 20,
            runSpacing: 20,
            children: [
              _buildFeatureCard(Icons.verified_user, 'Authentification & Sécurité', 'Système d\'authentification robuste avec gestion sécurisée des accès et protection des données agricoles'),
              _buildFeatureCard(Icons.lan, 'Gestion Agricole', 'Gestion complète des cultures, récoltes et stocks pour optimiser votre production agricole'),
              _buildFeatureCard(Icons.smart_toy, 'Services IA', 'Assistant intelligent avec chat et génération de rapports automatisés pour des décisions éclairées'),
              _buildFeatureCard(Icons.cloud_queue, 'Météo & Monitoring', 'Surveillance météorologique en temps réel et monitoring des conditions de vos cultures'),
              _buildFeatureCard(Icons.notifications_active, 'Notifications & Communication', 'Système de notifications intelligent pour rester informé des événements importants'),
              _buildFeatureCard(Icons.analytics, 'Business Logic', 'Gestion des ventes, profils utilisateurs et analyse des performances de votre exploitation'),
              _buildFeatureCard(Icons.settings, 'Administration & Maintenance', 'Outils d\'administration complets pour gérer et maintenir votre plateforme agricole'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(IconData icon, String title, String desc) {
    return Container(
      width: 350,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F8E9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: const Color(0xFF2E7D32), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20))),
          const SizedBox(height: 8),
          Text(desc, style: const TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }

  // 3. SECTION POURQUOI CHOISIR
  Widget _buildWhyChooseSection() {
    return Container(
      color: const Color(0xFFF1F8E9),
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Pourquoi choisir AgriFarm ?',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20))),
                const SizedBox(height: 30),
                _buildCheckItem('Intelligence Artificielle Avancée', 'Bénéficiez de recommandations personnalisées et de rapports automatisés pour optimiser vos rendements agricoles'),
                _buildCheckItem('Gestion Centralisée', 'Gérez toutes vos opérations agricoles depuis une seule plateforme intuitive et facile à utiliser'),
                _buildCheckItem('Monitoring en Temps Réel', 'Surveillez vos cultures et recevez des alertes météo pour prendre les meilleures décisions au bon moment'),
              ],
            ),
          ),
          Expanded(
            child: Container(
              height: 400,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: const DecorationImage(
                  image: NetworkImage('https://images.unsplash.com/photo-1464226184884-fa280b87c399?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1000&q=80'), // Agriculteur avec tablette
                  fit: BoxFit.cover,
                ),
              ),
              child: const Center(child: Icon(Icons.person, size: 100, color: Colors.white24)), // Placeholder icône
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckItem(String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_box, color: Color(0xFF2E7D32), size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20))),
                Text(desc, style: const TextStyle(color: Colors.black54)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 4. SECTION APPEL À L'ACTION (CTA)
  Widget _buildCTASection(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF2E7D32),
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 20),
      child: Column(
        children: [
          const Text('Prêt à transformer votre agriculture ?',
              style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 16),
          const Text('Rejoignez des milliers d\'agriculteurs qui ont déjà modernisé leur exploitation avec AgriFarm.\nCommencez dès aujourd\'hui gratuitement.',
              textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 18)),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, registerRoute),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF2E7D32),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Créer mon compte gratuitement', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // 5. FOOTER
  Widget _buildFooter() {
    return Container(
      color: const Color(0xFF1B5E20),
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('AgriFarm', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  Text('La plateforme intelligente pour une agriculture moderne et durable', style: TextStyle(color: Colors.white54)),
                ],
              ),
              _buildFooterColumn('Fonctionnalités', ['Gestion des cultures', 'Services IA', 'Météo & Monitoring', 'Gestion des ventes']),
              _buildFooterColumn('Contact', ['Support', 'Documentation', 'À propos']),
            ],
          ),
          const Divider(color: Colors.white24, height: 40),
          const Text('© 2025 AgriFarm. Tous droits réservés. | Powered by Readdy', style: TextStyle(color: Colors.white54)),
        ],
      ),
    );
  }

  Widget _buildFooterColumn(String title, List<String> links) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 12),
        ...links.map((link) => Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(link, style: const TextStyle(color: Colors.white54)),
        )),
      ],
    );
  }
}