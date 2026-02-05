// lib/screens/notification_detail_screen.dart

import 'package:flutter/material.dart';
import '../models/notification_model.dart';

class NotificationDetailScreen extends StatelessWidget {
  final NotificationModel notification;

  const NotificationDetailScreen({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    final typeData = notification.typeData;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails'),
        actions: [
          if (!notification.isRead)
            TextButton(
              onPressed: () {
                Navigator.pop(context, true); // Retourner true pour indiquer "marqué comme lu"
              },
              child: const Text('MARQUER COMME LU'),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icône et priorité
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Color(
                    typeData?.priorityColor ?? 0xFF4CAF50
                  ).withOpacity(0.2),
                  child: Text(
                    typeData?.iconPath ?? '📢',
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.titre,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Color(
                            typeData?.priorityColor ?? 0xFF4CAF50
                          ).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${typeData?.categoryTitle ?? 'Système'} • ${typeData?.priority ?? 'normal'}',
                          style: TextStyle(
                            color: Color(
                              typeData?.priorityColor ?? 0xFF4CAF50
                            ),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Message
            if (notification.message != null) ...[
              const Text(
                'Message',
                style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(notification.message!),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Données supplémentaires
            if (typeData != null && typeData!.data.isNotEmpty) ...[
              const Text(
                'Informations supplémentaires',
                style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: typeData!.data.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 120,
                              child: Text(
                                '${entry.key}:',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(
                              child: Text(entry.value.toString()),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Dates
            const Text(
              'Dates',
              style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildDateRow('Reçu le', notification.createdAt),
                    if (notification.readAt != null) ...[
                      const SizedBox(height: 8),
                      _buildDateRow('Lu le', notification.readAt!),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateRow(String label, DateTime date) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Text(
          '${date.day}/${date.month}/${date.year} à ${date.hour}:${date.minute.toString().padLeft(2, '0')}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

