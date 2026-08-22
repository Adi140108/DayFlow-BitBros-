import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/auth/auth_notifier.dart';
import '../../core/notification/app_notification.dart';
import '../../core/notification/notification_repository.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

/// In-App Notification Center widget displaying unread badge & notification list.
class NotificationCenterWidget extends ConsumerStatefulWidget {
  const NotificationCenterWidget({super.key});

  @override
  ConsumerState<NotificationCenterWidget> createState() => _NotificationCenterWidgetState();
}

class _NotificationCenterWidgetState extends ConsumerState<NotificationCenterWidget> {
  final _notifRepo = NotificationRepository();
  List<AppNotification> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final session = ref.read(authNotifierProvider).state;
    if (session.user == null) return;

    try {
      final list = await _notifRepo.getUserNotifications(session.user!.uid);
      setState(() {
        _notifications = list;
      });
    } catch (e) {
      // Graceful error handle
    }
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _notifications.where((n) => !n.isRead).length;

    return Stack(
      children: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () => _showNotificationSheet(context),
        ),
        if (unreadCount > 0)
          Positioned(
            right: 6,
            top: 6,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
              child: Text(
                '$unreadCount',
                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ),
      ],
    );
  }

  void _showNotificationSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('In-App Notifications', style: AppTypography.sectionHeading),
                  TextButton(
                    onPressed: () async {
                      final session = ref.read(authNotifierProvider).state;
                      if (session.user != null) {
                        final nav = Navigator.of(context);
                        await _notifRepo.markAllAsRead(session.user!.uid);
                        _loadNotifications();
                        if (mounted) nav.pop();
                      }
                    },
                    child: const Text('Mark all as read'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              if (_notifications.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(AppSpacing.lg),
                  child: Center(child: Text('No new notifications.')),
                )
              else
                Expanded(
                  child: ListView.separated(
                    itemCount: _notifications.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final n = _notifications[index];
                      return ListTile(
                        leading: Icon(
                          n.isRead ? Icons.notifications_none : Icons.notifications_active,
                          color: n.isRead ? AppColors.lightTextMuted : AppColors.primary,
                        ),
                        title: Text(n.title, style: AppTypography.label),
                        subtitle: Text(n.message, style: AppTypography.bodySmall),
                        onTap: () async {
                          final nav = Navigator.of(context);
                          await _notifRepo.markAsRead(n.id);
                          _loadNotifications();
                          if (mounted) nav.pop();
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
