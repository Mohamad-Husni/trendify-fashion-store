import 'package:flutter/material.dart';
import 'package:fashion_store/theme/app_theme.dart';
import 'package:fashion_store/services/notification_service.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    await _notificationService.loadNotifications();
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'order':
        return Icons.local_shipping;
      case 'promotion':
        return Icons.local_offer;
      case 'system':
        return Icons.info;
      default:
        return Icons.notifications;
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'order':
        return Colors.blue;
      case 'promotion':
        return Colors.orange;
      case 'system':
        return Colors.purple;
      default:
        return AppTheme.gold;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _notificationService,
      builder: (context, child) {
        final notifications = _notificationService.notifications;
        final unreadCount = _notificationService.unreadCount;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppTheme.deepBlack),
              onPressed: () => Navigator.pop(context),
            ),
            title: Column(
              children: [
                const Text(
                  'NOTIFICATIONS',
                  style: TextStyle(
                    color: AppTheme.deepBlack,
                    fontSize: 14,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (unreadCount > 0)
                  Text(
                    '$unreadCount unread',
                    style: TextStyle(
                      color: AppTheme.gold,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
            centerTitle: true,
            actions: [
              if (notifications.isNotEmpty)
                TextButton(
                  onPressed: () async {
                    await _notificationService.markAllAsRead();
                  },
                  child: const Text(
                    'MARK ALL',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
            ],
          ),
          body: _notificationService.isLoading
              ? const Center(child: CircularProgressIndicator(color: AppTheme.gold))
              : notifications.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        final notification = notifications[index];
                        return Dismissible(
                          key: Key(notification.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          onDismissed: (_) async {
                            await _notificationService.deleteNotification(notification.id);
                          },
                          child: Card(
                            elevation: 0,
                            color: notification.isRead ? Colors.white : Colors.blue.shade50,
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: Colors.grey.shade200),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: _getColorForType(notification.type).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  _getIconForType(notification.type),
                                  color: _getColorForType(notification.type),
                                ),
                              ),
                              title: Text(
                                notification.title,
                                style: TextStyle(
                                  fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(notification.body),
                                  const SizedBox(height: 8),
                                  Text(
                                    DateFormat('MMM d, y • h:mm a').format(notification.createdAt),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                              onTap: () async {
                                if (!notification.isRead) {
                                  await _notificationService.markAsRead(notification.id);
                                }
                              },
                            ),
                          ),
                        );
                      },
                    ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          const Text(
            'No Notifications',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Stay tuned for updates on your orders and offers',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () async {
              await _notificationService.sendTestNotification();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.gold,
              foregroundColor: Colors.black,
            ),
            child: const Text('SEND TEST NOTIFICATION'),
          ),
        ],
      ),
    );
  }
}
