import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seiyun_reports_app/core/theme/app_theme.dart';
import 'package:seiyun_reports_app/screens/home/viewmodel/home_viewmodel.dart';

class RecentReportsList extends StatelessWidget {
  const RecentReportsList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeViewModel>(
      builder: (context, viewModel, child) {
        // نستخدم البيانات القادمة من رابط الهوم الموحد
        final reportsToShow = viewModel.recentReports;

        if (reportsToShow.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Text("لا توجد بلاغات تظهر حالياً"),
            ),
          );
        }

        return Column(
          children:
              reportsToShow.map((report) {
                final reportData = {
                  "title": report.title,
                  "date": report.createdAt,
                  "status": report.status,
                };
                return _reportItem(reportData, context);
              }).toList(),
        );
      },
    );
  }

  Widget _reportItem(Map<String, String> data, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  data['title']!,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "عرض",
                  style: TextStyle(
                    fontSize: 11,
                    color:
                        Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : AppTheme.secondaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.circle,
                    size: 8,
                    color:
                        Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF2ecc71)
                            : AppTheme.primaryColor,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    data['status']!,
                    style: TextStyle(
                      fontSize: 12,
                      color:
                          Theme.of(context).brightness == Brightness.dark
                              ? const Color(0xFF2ecc71)
                              : AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
              Text(
                data['date']!.split('T')[0],
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
