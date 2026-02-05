// lib/widgets/notification_badge.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notifications_provider.dart';

class NotificationBadge extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const NotificationBadge({super.key, required this.child, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          child,
          Consumer<NotificationsProvider>(
            builder: (context, provider, child) {
              final unreadCount = provider.unreadCount;
              if (unreadCount > 0) {
                return Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                    child: Text(
                      unreadCount > 99 ? '99+' : unreadCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}

