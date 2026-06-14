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
          return RefreshIndicator(
              onRefresh: () async {
                await viewModel.loadDashboardData(showLoading: true);
              },
              child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
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
                          onLike: () {
                            context.read<CitizenReportsViewModel>().toggleLike(report);
                          },
                        );
                      },
                    ),
                  const SizedBox(height: 20),
                ],
              ),
            )
            );
          },
        ),
      );
  }

  void _showCommentsBottomSheet(BuildContext context, CitizenReportModel report) {
    final viewModel = context.read<CitizenReportsViewModel>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CommentsSheet(report: report, viewModel: viewModel),
    );
  }
}

class _CommentsSheet extends StatefulWidget {
  final CitizenReportModel report;
  final CitizenReportsViewModel viewModel;

  const _CommentsSheet({required this.report, required this.viewModel});

  @override
  State<_CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<_CommentsSheet> {
  final TextEditingController _commentController = TextEditingController();
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      widget.viewModel.fetchComments(widget.report.id);
      widget.viewModel.incrementReportView(widget.report);
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _sendComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSending = true);

    final success = await widget.viewModel.addComment(widget.report.id, text);

    if (mounted) {
      setState(() => _isSending = false);
      if (success) {
        _commentController.clear();
        FocusScope.of(context).unfocus();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إرسال تعليقك بنجاح ✓'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('فشل إرسال التعليق، يرجى المحاولة لاحقاً'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.2))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'التعليقات (${widget.report.commentsCount})',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Consumer<CitizenReportsViewModel>(
                builder: (context, vm, child) {
                  if (vm.comments.isEmpty && widget.report.commentsCount > 0) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  if (vm.comments.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.chat_bubble_outline, size: 40, color: Colors.grey[300]),
                          const SizedBox(height: 10),
                          Text(
                            'لا توجد تعليقات بعد، كن أول من يعلق!',
                            style: TextStyle(color: Colors.grey[600], fontSize: 14),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: vm.comments.length,
                    itemBuilder: (context, index) {
                      final comment = vm.comments[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 15),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              backgroundImage: comment.userProfile.isNotEmpty 
                                  ? NetworkImage(comment.userProfile) 
                                  : null,
                              backgroundColor: Colors.grey[300],
                              radius: 18,
                              child: comment.userProfile.isEmpty 
                                  ? const Icon(Icons.person, color: Colors.white, size: 20) 
                                  : null,
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
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          comment.userName,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                        ),
                                        Text(
                                          comment.createdAt,
                                          style: TextStyle(color: Colors.grey[500], fontSize: 10),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      comment.commentText,
                                      style: TextStyle(
                                        color: Theme.of(context).textTheme.bodyMedium?.color,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),

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
                      controller: _commentController,
                      textDirection: TextDirection.rtl,
                      enabled: !_isSending,
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
                    child: _isSending
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : IconButton(
                            icon: const Icon(Icons.send, color: Colors.white, size: 20),
                            onPressed: _sendComment,
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
