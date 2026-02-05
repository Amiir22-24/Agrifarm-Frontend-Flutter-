import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cultures_provider.dart';
import '../models/culture.dart';

class CulturesScreen extends StatefulWidget {
  const CulturesScreen({Key? key}) : super(key: key);

  @override
  State<CulturesScreen> createState() => _CulturesScreenState();
}

class _CulturesScreenState extends State<CulturesScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<CulturesProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // Logique de calcul pour les statistiques
        final cultures = provider.cultures;
        // Additionne les surfaces de toutes les cultures
        final double totalSurface = cultures.fold(0, (sum, item) => sum + (item.surface ?? 0));
        final int totalActives = cultures.length;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. HEADER (Titre et sous-titre)
              const Text(
                "Gestion des Cultures",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
              ),
              const SizedBox(height: 4),
              const Text(
                "Suivez et gérez toutes vos cultures en temps réel",
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 24),

              // 2. STATS CARDS (Surface totale et Nombre de cultures)
              Row(
                children: [
                  Expanded(child: _buildStatCard("Surface totale cultivée", "${totalSurface.toStringAsFixed(0)} ha", Icons.eco, Colors.green, "+12%")),
                  const SizedBox(width: 20),
                  Expanded(child: _buildStatCard("Cultures actives", totalActives.toString(), Icons.agriculture, Colors.orange, "$totalActives types")),
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
                          const Text("Vos Cultures", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ElevatedButton.icon(
                            onPressed: () => Navigator.pushNamed(context, '/add-culture'),
                            icon: const Icon(Icons.add, color: Colors.white),
                            label: const Text("Ajouter", style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF21A84D),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // TABLEAU DES CULTURES - VERSION RESPONSIVE
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isMobile = constraints.maxWidth < 600;
                          if (isMobile) {
                            // VERSION MOBILE - LISTE
                            return Column(
                              children: cultures.map((culture) {
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                culture.nom,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            _buildStatusChip(culture.etat),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          "${culture.surface} ha",
                                          style: const TextStyle(color: Colors.grey),
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.edit_outlined, color: Colors.blue, size: 20),
                                              onPressed: () => _navigateToEditCulture(context, culture),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                              onPressed: () => _showDeleteConfirmation(context, culture),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            );
                          } else {
                            // VERSION DESKTOP - TABLEAU
                            return SizedBox(
                              width: double.infinity,
                              child: DataTable(
                                headingTextStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
                                horizontalMargin: 0,
                                columns: const [
                                  DataColumn(label: Text('Nom')),
                                  DataColumn(label: Text('Surface')),
                                  DataColumn(label: Text('Statut')),
                                  DataColumn(label: Text('Actions')),
                                ],
                                rows: cultures.map((culture) {
                                  return DataRow(cells: [
                                    DataCell(Text(culture.nom, style: const TextStyle(fontWeight: FontWeight.w500))),
                                    DataCell(Text("${culture.surface} ha")),
                                    DataCell(_buildStatusChip(culture.etat)),
                                    DataCell(
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit_outlined, color: Colors.blue, size: 20),
                                            onPressed: () => _navigateToEditCulture(context, culture),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                            onPressed: () => _showDeleteConfirmation(context, culture),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ]);
                                }).toList(),
                              ),
                            );
                          }
                        },
                      ),
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

  // Naviguer vers l'écran d'édition
  void _navigateToEditCulture(BuildContext context, Culture culture) {
    Navigator.pushNamed(
      context,
      '/edit-culture',
      arguments: culture,
    );
  }

  // Afficher la boîte de confirmation de suppression
  Future<void> _showDeleteConfirmation(BuildContext context, Culture culture) async {
    final provider = Provider.of<CulturesProvider>(context, listen: false);
    
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirmer la suppression"),
          content: Text("Êtes-vous sûr de vouloir supprimer la culture \"${culture.nom}\" ?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Annuler"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text("Supprimer", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );

    if (confirm == true && mounted) {
      final success = await provider.deleteCulture(culture.id!);
      
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${culture.nom} a été supprimée'),
              backgroundColor: Colors.green,
            ),
          );
        } else if (provider.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur: ${provider.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  // Widget pour les cartes de statistiques (comme sur la capture)
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

  // Widget pour le badge de statut coloré
  Widget _buildStatusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'en croissance': color = Colors.green; break;
      case 'semis récent': color = Colors.orange; break;
      case 'floraison': color = Colors.blue; break;
      case 'préparation': color = Colors.purple; break;
      default: color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }
}

