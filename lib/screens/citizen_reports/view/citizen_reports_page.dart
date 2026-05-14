import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/citizen_reports_viewmodel.dart';
import 'widgets/citizen_reports_header.dart';
import 'widgets/citizen_reports_stats.dart';
import 'widgets/citizen_report_card.dart';
import 'package:share_plus/share_plus.dart';
import '../models/citizen_report_model.dart';

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
                            _showCommentsBottomSheet(context, report);
                          },
                          onShare: () {
                            final String shareText = 'شاهد هذا البلاغ في تطبيق سيئون:\n\n'
                                'العنوان: ${report.title}\n'
                                'الوصف: ${report.description}\n\n'
                                'حالة البلاغ: ${report.status}';
                            Share.share(shareText);
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

  void _showCommentsBottomSheet(BuildContext context, CitizenReportModel report) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.2))),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'التعليقات (${report.commentsCount})',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              // Comments List
              Expanded(
                child: report.commentsCount == 0
                    ? Center(
                        child: Text(
                          'لا توجد تعليقات بعد، كن أول من يعلق!',
                          style: TextStyle(color: Colors.grey[600], fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: report.commentsCount,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 15),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.grey[300],
                                  radius: 18,
                                  child: const Icon(Icons.person, color: Colors.white, size: 20),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).cardColor,
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(color: Colors.grey.withOpacity(0.2)),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'مواطن ${(index + 1)}',
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'تعليق تجريبي رقم ${(index + 1)} على هذا البلاغ لإظهار التفاعل.',
                                          style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 13),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
              // Add Comment Input
              Container(
                padding: EdgeInsets.only(
                  left: 15,
                  right: 15,
                  top: 10,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 10,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      offset: const Offset(0, -3),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'أضف تعليقاً...',
                          hintStyle: const TextStyle(fontSize: 14),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                          filled: true,
                          fillColor: Theme.of(context).cardColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    CircleAvatar(
                      backgroundColor: const Color(0xFF27ae60),
                      radius: 22,
                      child: IconButton(
                        icon: const Icon(Icons.send, color: Colors.white, size: 20),
                        onPressed: () {
                          // TODO: Implement actual send comment to server
                          FocusScope.of(context).unfocus();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('تم إرسال تعليقك! سيتم مراجعته.'), backgroundColor: Colors.green),
                          );
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
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
