import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seiyun_reports_app/screens/home/viewmodel/home_viewmodel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:seiyun_reports_app/core/theme/app_theme.dart';
import 'package:seiyun_reports_app/viewmodels/notification_viewmodel.dart';
import 'package:seiyun_reports_app/screens/notifications/view/notifications_screen.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final homeVM = context.watch<HomeViewModel>();
    final notificationVM = context.watch<NotificationViewModel>();
    final User? user = homeVM.currentUser;
    String name = user?.displayName ?? "مستخدم";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, left: 25, right: 25, bottom: 30),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.accentGreen, AppTheme.darkGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(35),
          bottomRight: Radius.circular(35),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        "أهلاً، $name",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 5),
                      const Text("👋", style: TextStyle(fontSize: 20)),
                    ],
                  ),
                  Text(
                    homeVM.currentArea,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                  );
                },
                child: Stack(
                  children: [
                    const Icon(
                      Icons.notifications_none,
                      color: Colors.white,
                      size: 30,
                    ),
                    if (notificationVM.unreadCount > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.orange,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            notificationVM.unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const TextField(
              decoration: InputDecoration(
                hintText: "ابحث في الخدمات...",
                hintStyle: TextStyle(color: Colors.white70),
                border: InputBorder.none,
                icon: Icon(Icons.search, color: Colors.white70),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
