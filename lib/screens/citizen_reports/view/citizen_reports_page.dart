import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/citizen_reports_viewmodel.dart';
import 'widgets/citizen_reports_header.dart';
import 'widgets/citizen_reports_stats.dart';
import 'widgets/citizen_report_card.dart';

class CitizenReportsPage extends StatelessWidget {
  const CitizenReportsPage({Key? key}) : super(key: key);

  @override

  Widget build(BuildContext context) {
   return Scaffold(
        body: Consumer<CitizenReportsViewModel>(
          builder: (context, viewModel, child) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  CitizenReportsHeader(
                    onSearch: (query) => viewModel.setSearchQuery(query),
                  ),
                  CitizenReportsStats(
                    total: viewModel.totalReports,
                    resolved: viewModel.resolvedReports,
                    active: viewModel.activeReports,
                    rate: viewModel.resolutionRate,
                  ),
                  if (viewModel.isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (viewModel.filteredReports.isEmpty)
                    const _EmptyState()
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: viewModel.filteredReports.length,
                      itemBuilder: (context, index) {
                        final report = viewModel.filteredReports[index];
                        return CitizenReportCard(
                          report: report,
                          onLike: () => viewModel.toggleLike(report.id),
                          onComment: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('ميزة التعليق ستتوفر قريباً')),
                            );
                          },
                          onShare: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('ميزة المشاركة ستتوفر قريباً')),
                            );
                          },
                        );
                      },
                    ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      );
  
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 40),
        Icon(Icons.search_off_outlined, size: 80, color: Colors.grey[300]),
        const SizedBox(height: 16),
        Text(
          'لا توجد بلاغات تطابق بحثك',
          style: TextStyle(color: Colors.grey[600], fontSize: 16),
        ),
      ],
    );
  }
}
