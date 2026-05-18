import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:seiyun_reports_app/core/theme/app_theme.dart';
import 'supervisor_task_detail_screen.dart';
import 'package:seiyun_reports_app/screens/map/view/map_zones_screen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'supervisor_task_completion_detail_screen.dart';
import 'package:seiyun_reports_app/screens/supervisor/TasksScreen/viewmodel/supervisor_tasks_viewmodel.dart';
import 'package:seiyun_reports_app/screens/supervisor/TasksScreen/models/assignment_model.dart';

class SupervisorTasksScreen extends StatefulWidget {
  const SupervisorTasksScreen({Key? key}) : super(key: key);

  @override
  State<SupervisorTasksScreen> createState() => _SupervisorTasksScreenState();
}

class _SupervisorTasksScreenState extends State<SupervisorTasksScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _openInAppMap(AssignmentModel task) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapZonesScreen(
          initialLocation: LatLng(double.tryParse(task.lat) ?? 0.0, double.tryParse(task.lng) ?? 0.0),
          initialTitle: task.title,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SupervisorTasksViewModel>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('إدارة المهام'),
          bottom: TabBar(
            controller: _tabController,
            labelColor: AppTheme.primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppTheme.primaryColor,
            tabs: const [
              Tab(text: 'المهام الجديدة'),
              Tab(text: 'المهام المكتملة'),
            ],
          ),
        ),
        body: viewModel.isLoading && viewModel.assignments.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                controller: _tabController,
                children: [
                  _buildTaskList(tasks: viewModel.pendingTasks, isDark: isDark, viewModel: viewModel),
                  _buildTaskList(tasks: viewModel.completedTasks, isDark: isDark, viewModel: viewModel),
                ],
              ),
      ),
    );
  }

  Widget _buildTaskList({required List<AssignmentModel> tasks, required bool isDark, required SupervisorTasksViewModel viewModel}) {
    if (tasks.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => viewModel.fetchAssignments(),
        child: ListView(
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.3),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(CupertinoIcons.doc_text_search, size: 60, color: Colors.grey.withOpacity(0.5)),
                  const SizedBox(height: 15),
                  const Text("لا توجد مهام حالياً", style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => viewModel.fetchAssignments(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          final bool isCompleted = task.status == 'تم الحل' || 
                                   task.status == 'solved' || 
                                   task.status == 'مكتملة' ||
                                   task.status == 'completed';

          return Card(
            elevation: 2,
            color: isDark ? Colors.grey.shade900 : Colors.white,
            margin: const EdgeInsets.only(bottom: 16.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: isDark ? Colors.grey.shade800 : Colors.grey.shade100),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category and Status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          task.reportType,
                          style: const TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                      _buildStatusBadge(isCompleted, task.status),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Title and Zone
                  Text(
                    task.title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  _buildIconRow(Icons.location_on_outlined, " ${task.area} ${task.square}", isDark),
                  const SizedBox(height: 6),
             
                  // Description
                  Text(
                    task.description,
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 14, height: 1.5),
                  ),
                  const SizedBox(height: 16),

                  // Image Section
                  const Text(
                    "صورة البلاغ",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          task.reportImage,
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: 180,
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.broken_image, color: Colors.grey),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Supervisor
                  Row(
                    children: [
                      const Icon(Icons.person_outline, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      const Text(
                        "المشرف:",
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        task.supervisorName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      const Text(
                        "التاريخ:",
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _formatDate(task.assignedAt),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 32),

                  // Actions
                  if (!isCompleted) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SupervisorTaskDetailScreen(task: task),
                            ),
                          );
                        },
                        icon: const Icon(Icons.check_circle_outline, size: 20),
                        label: const Text('إكمال البلاغ'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ] else ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SupervisorTaskCompletionDetailScreen(task: task),
                            ),
                          );
                        },
                        icon: const Icon(Icons.info_outline, size: 20),
                        label: const Text('تفاصيل الإنجاز'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _openInAppMap(task),
                      icon: const Icon(CupertinoIcons.map, size: 18),
                      label: const Text('الخريطة'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return "";
    try {
      DateTime? dt;
      // محاولة تحليل التنسيق القادم من السيرفر "22:28:41 2026-05-13"
      if (dateStr.contains(':') && dateStr.contains('-')) {
        // إذا كان الوقت أولاً "HH:mm:ss yyyy-MM-dd"
        if (dateStr.indexOf(':') < dateStr.indexOf('-')) {
          dt = DateFormat("HH:mm:ss yyyy-MM-dd").parse(dateStr);
        } else {
          // التنسيق القياسي yyyy-MM-dd HH:mm:ss
          dt = DateTime.parse(dateStr);
        }
      } else {
        dt = DateTime.tryParse(dateStr);
      }
      
      if (dt != null) {
        String datePart = DateFormat('yyyy-MM-dd').format(dt);
        String timePart = DateFormat('hh:mm').format(dt);
        String amPm = dt.hour >= 12 ? 'م' : 'ص';
        return '$datePart | $timePart $amPm';
      }
      return dateStr;
    } catch (e) {
      return dateStr;
    }
  }

  Widget _buildStatusBadge(bool isCompleted, String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isCompleted ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: isCompleted ? Colors.green : Colors.orange,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildIconRow(IconData icon, String text, bool isDark) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primaryColor, size: 16),
        const SizedBox(width: 10),
        Text(
          text,
          style: TextStyle(
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

