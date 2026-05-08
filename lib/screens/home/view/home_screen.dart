import 'package:flutter/material.dart';
import 'package:seiyun_reports_app/core/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:seiyun_reports_app/screens/home/viewmodel/home_viewmodel.dart';
import 'package:seiyun_reports_app/screens/report/view/report_screen.dart';
import 'package:seiyun_reports_app/screens/home/view/widgets/home_header.dart';
import 'package:seiyun_reports_app/screens/home/view/widgets/stats_cards.dart';
import 'package:seiyun_reports_app/screens/home/view/widgets/next_pickup_card.dart';
import 'package:seiyun_reports_app/screens/home/view/widgets/order_service_banner.dart';
import 'package:seiyun_reports_app/screens/home/view/widgets/section_header.dart';
import 'package:seiyun_reports_app/screens/home/view/widgets/recent_reports_list.dart';
import 'package:seiyun_reports_app/screens/home/view/widgets/news_list.dart';
import 'package:seiyun_reports_app/screens/home/view/widgets/tips_grid.dart';
import 'package:seiyun_reports_app/screens/home/view/widgets/custom_bottom_nav_bar.dart';
import 'package:seiyun_reports_app/screens/map/view/map_screen.dart';
import 'package:seiyun_reports_app/screens/news_tips/view/news_tips_screen.dart';
import 'package:seiyun_reports_app/screens/profile/view/profile_screen.dart';

import '../../citizen_reports/viewmodel/citizen_reports_viewmodel.dart';

const sectionTitleStyle = TextStyle(fontSize: 16, fontWeight: FontWeight.bold);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Widget> _pages = [
    const _HomeContent(),
    const MapScreen(),
    const NewsTipsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final homeVM = context.watch<HomeViewModel>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      extendBody: true,
      body: _pages[homeVM.currentIndex],
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ReportScreen()),
          );
        },
        backgroundColor: AppTheme.primaryColor,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: homeVM.currentIndex,
        onTap: (index) {
          homeVM.setPage(index);
        },
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SingleChildScrollView(
        child: Column(
          children: [
            HomeHeader(),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Consumer<CitizenReportsViewModel>(
                  builder: (context, reportsVM, child) {
                    return StatsCards(
                       // ربطها بالبيانات الحقيقية القادمة من السيرفر 
                      activeCount: reportsVM.activeReports,
                      resolvedCount: reportsVM.resolvedReports, 
                    );
                  },
                ),
                  SizedBox(height: 20),
                  NextPickupCard(),
                  SizedBox(height: 20),
                  OrderServiceBanner(),
                  SizedBox(height: 25),
                  SectionHeader(title: "البلاغات الأخيرة", action: "عرض الكل"),
                  SizedBox(height: 15),
                  RecentReportsList(),
                  SizedBox(height: 25),
                  SectionHeader(
                    title: "الأخبار والتحديثات",
                    action: "عرض الكل",
                  ),
                  SizedBox(height: 15),
                  NewsList(),
                  SizedBox(height: 25),
                  Text(
                    "نصائح مفيدة",
                    style: sectionTitleStyle.copyWith(
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                  ),
                  SizedBox(height: 15),
                  TipsGrid(),
                  SizedBox(height: 100), // مساحة للزر العائم
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
