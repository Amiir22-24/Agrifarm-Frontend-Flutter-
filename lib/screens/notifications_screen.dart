// lib/screens/notifications_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notifications_provider.dart';
import '../models/notification_model.dart';
import 'notification_detail_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _showUnreadOnly = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationsProvider>().loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            onPressed: _markAllAsRead,
            tooltip: 'Tout marquer comme lu',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _showUnreadOnly = value == 'unread';
              });
              if (value == 'unread') {
                context.read<NotificationsProvider>().loadUnreadOnly();
              } else {
                context.read<NotificationsProvider>().loadNotifications();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'all',
                child: Row(
                  children: const [
                    Icon(Icons.list),
                    SizedBox(width: 8),
                    Text('Toutes'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'unread',
                child: Row(
                  children: const [
                    Icon(Icons.mark_email_unread),
                    SizedBox(width: 8),
                    Text('Non lues'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<NotificationsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.notifications.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null && provider.notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text('Erreur: ${provider.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => provider.loadNotifications(refresh: true),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          final notifications = _showUnreadOnly 
              ? provider.unreadNotifications 
              : provider.notifications;

          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.notifications_off, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Aucune notification'),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.refresh(),
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return NotificationTile(notification: notification);
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _markAllAsRead() async {
    try {
      await context.read<NotificationsProvider>().markAllAsRead();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Toutes les notifications marquées comme lues')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }
}

class NotificationTile extends StatelessWidget {
  final NotificationModel notification;

  const NotificationTile({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    final typeData = notification.typeData;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      color: notification.isRead ? Colors.white : Colors.blue[50],
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Color(
            typeData?.priorityColor ?? 0xFF4CAF50
          ).withOpacity(0.2),
          child: Text(
            typeData?.iconPath ?? '📢',
            style: const TextStyle(fontSize: 20),
          ),
        ),
        title: Text(
          notification.titre,
          style: TextStyle(
            fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (notification.message != null) ...[
              const SizedBox(height: 4),
              Text(
                notification.message!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 4),
            Row(
              children: [
                if (typeData != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Color(typeData!.priorityColor).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      typeData.priority,
                      style: TextStyle(
                        fontSize: 10,
                        color: Color(typeData.priorityColor),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  _formatDate(notification.createdAt),
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'read') {
              context.read<NotificationsProvider>().markAsReadById(notification.id);
            } else if (value == 'delete') {
              _showDeleteDialog(context, notification.id);
            }
          },
          itemBuilder: (context) => [
            if (!notification.isRead)
              const PopupMenuItem(
                value: 'read',
                child: Text('Marquer comme lu'),
              ),
            const PopupMenuItem(
              value: 'delete',
              child: Text('Supprimer'),
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NotificationDetailScreen(notification: notification),
            ),
          );
          // Marquer comme lu si pas encore lu
          if (!notification.isRead) {
            context.read<NotificationsProvider>().markAsReadById(notification.id);
          }
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'À l\'instant';
    } else if (difference.inMinutes < 60) {
      return 'Il y a ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Il y a ${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return 'Il y a ${difference.inDays} jours';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _showDeleteDialog(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la notification'),
        content: const Text('Êtes-vous sûr de vouloir supprimer cette notification ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              try {
                await context.read<NotificationsProvider>().deleteNotification(id);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Notification supprimée')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erreur: $e')),
                );
              }
            },
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}

