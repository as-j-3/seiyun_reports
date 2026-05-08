import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seiyun_reports_app/viewmodels/notification_viewmodel.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final notifVM = context.watch<NotificationViewModel>();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("إشعارات النظام"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.notifications_active, size: 80, color: Colors.green),
              const SizedBox(height: 20),
              Text(
                notifVM.token == null ? "جاري جلب التوكن من Firebase..." : "تم جلب التوكن بنجاح",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              if (notifVM.token != null)
                SelectableText(
                  notifVM.token!,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 20),
              if (notifVM.notifications.isNotEmpty)
                Card(
                  elevation: 4,
                  margin: const EdgeInsets.all(8),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          notifVM.notifications.first.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          notifVM.notifications.first.body,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}