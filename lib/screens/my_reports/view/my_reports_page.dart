import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seiyun_reports_app/screens/report/view/report_screen.dart';
import 'package:seiyun_reports_app/screens/my_reports/view/widgets/reports_header.dart';
import 'package:seiyun_reports_app/screens/my_reports/view/widgets/empty_reports_state.dart';
import 'package:seiyun_reports_app/screens/my_reports/view/widgets/reports_list.dart';
import 'package:seiyun_reports_app/core/theme/app_theme.dart';
import 'package:seiyun_reports_app/screens/report/viewmodel/report_viewmodel.dart';

class MyReportsPage extends StatefulWidget {
  const MyReportsPage({super.key});

  @override
  State<MyReportsPage> createState() => _MyReportsPageState();
}

class _MyReportsPageState extends State<MyReportsPage> {
  @override
  void initState() {
    super.initState();
    // Fetch reports when the page is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReportViewModel>().fetchReportsFromLaravel();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            const ReportsHeader(),
            Expanded(
              child: Consumer<ReportViewModel>(
                builder: (context, viewModel, child) {
                  if (viewModel.isLoadingReports) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.accentGreen,
                      ),
                    );
                  }

                  if (viewModel.reportsList.isEmpty) {
                    return const EmptyReportsState();
                  }

                  return ReportsList(reports: viewModel.reportsList);
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ReportScreen()),
          );
        },
        backgroundColor: const Color(0xFF2ecc71),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }
}
