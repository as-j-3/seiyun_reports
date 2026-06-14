import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:seiyun_reports_app/screens/notifications/viewmodel/notification_viewmodel.dart';
import 'package:seiyun_reports_app/screens/notifications/models/notification_model.dart';
import 'package:seiyun_reports_app/screens/notifications/view/widgets/notifications_header.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notificationVM = context.watch<NotificationViewModel>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      notificationVM.markAsRead();
    });

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          const NotificationsHeader(),
          Expanded(
            child:
                notificationVM.notifications.isEmpty
                    ? _buildEmptyState(context)
                    : ListView.separated(
                      padding: const EdgeInsets.all(20),
                      itemCount: notificationVM.notifications.length,
                      separatorBuilder:
                          (context, index) => const SizedBox(height: 15),
                      itemBuilder: (context, index) {
                        final notification =
                            notificationVM.notifications[index];
                        return _buildNotificationItem(context, notification);
                      },
                    ),
          ),
        ],
      ),
    );
  }

  /// بناء واجهة الحالة الفارغة عند عدم وجود إشعارات
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 80,
            color: Colors.grey.withOpacity(0.5),
          ),
          const SizedBox(height: 20),
          Text(
            "notifications.empty".tr(),
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
        ],
      ),
    );
  }

  /// بناء عنصر الإشعار الفردي في القائمة
  Widget _buildNotificationItem(
    BuildContext context,
    AppNotification notification,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color:
              notification.isRead
                  ? Colors.transparent
                  : Theme.of(context).primaryColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_active_outlined,
              color: Theme.of(context).primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  notification.body,
                  style: TextStyle(
                    color:
                        Theme.of(context).textTheme.bodySmall?.color ??
                        Colors.grey[600],
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 14, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text(
                      DateFormat(
                        'yyyy-MM-dd – kk:mm',
                      ).format(notification.time),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
