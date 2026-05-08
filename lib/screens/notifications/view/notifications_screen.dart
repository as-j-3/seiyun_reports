import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seiyun_reports_app/viewmodels/notification_viewmodel.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notificationVM = context.watch<NotificationViewModel>();

    // تعليم الكل كمقروء عند الدخول
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notificationVM.markAsRead();
    });

    return Scaffold(
      appBar: AppBar(title: const Text("الإشعارات"), centerTitle: true),
      body:
          notificationVM.notifications.isEmpty
              ? _buildEmptyState(context)
              : ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: notificationVM.notifications.length,
                separatorBuilder:
                    (context, index) => const SizedBox(height: 15),
                itemBuilder: (context, index) {
                  final notification = notificationVM.notifications[index];
                  return _buildNotificationItem(context, notification);
                },
              ),
    );
  }

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
            "لا توجد إشعارات حالياً",
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(
    BuildContext context,
    AppNotification notification,
  ) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color:
              notification.isRead
                  ? Colors.transparent
                  : Theme.of(context).primaryColor.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
            child: Icon(
              Icons.notifications,
              color: Theme.of(context).primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  notification.body,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  DateFormat('yyyy-MM-dd – kk:mm').format(notification.time),
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
