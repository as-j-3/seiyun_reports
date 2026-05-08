import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:seiyun_reports_app/core/theme/app_theme.dart';
import 'supervisor_task_detail_screen.dart';
import 'package:seiyun_reports_app/screens/map/view/map_screen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SupervisorTasksScreen extends StatefulWidget {
  const SupervisorTasksScreen({Key? key}) : super(key: key);

  @override
  State<SupervisorTasksScreen> createState() => _SupervisorTasksScreenState();
}

class _SupervisorTasksScreenState extends State<SupervisorTasksScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _allTasks = [
    {
      'id': '101',
      'title': 'متابعة بلاغ تراكم النفايات',
      'location_name': 'السوق العام - سيئون',
      'lat': 15.9392,
      'lng': 48.7895,
      'status': 'قيد الانتظار',
      'date': '02-05-2026',
    },
    {
      'id': '102',
      'title': 'الإشراف على صيانة الإضاءة',
      'location_name': 'شارع المطار',
      'lat': 15.9501,
      'lng': 48.7801,
      'status': 'مكتملة',
      'date': '01-05-2026',
    },
    {
      'id': '103',
      'title': 'بلاغ رمي مخلفات بناء',
      'location_name': 'حي الوحدة',
      'lat': 15.9429,
      'lng': 48.7844,
      'status': 'قيد الانتظار',
      'date': '02-05-2026',
    },
    {
      'id': '104',
      'title': 'تنظيف مجرى السيل',
      'location_name': 'شارع الجزائر',
      'lat': 15.9400,
      'lng': 48.7800,
      'status': 'مكتملة',
      'date': '28-04-2026',
    },
  ];

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

  Future<void> _openInAppMap(Map<String, dynamic> task) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapScreen(
          initialLocation: LatLng(task['lat'], task['lng']),
          initialTitle: task['title'],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
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
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildTaskList(status: 'قيد الانتظار', isDark: isDark),
            _buildTaskList(status: 'مكتملة', isDark: isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskList({required String status, required bool isDark}) {
    final tasks = _allTasks.where((t) => t['status'] == status).toList();

    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(CupertinoIcons.doc_text_search, size: 60, color: Colors.grey.withOpacity(0.5)),
            const SizedBox(height: 15),
            const Text("لا توجد مهام حالياً", style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        final bool isCompleted = task['status'] == 'مكتملة';

        return GestureDetector(
          onTap: () async {
            if (!isCompleted) {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SupervisorTaskDetailScreen(task: task),
                ),
              );
              if (result == true) {
                // Refresh logic if needed
              }
            }
          },
          child: Card(
            elevation: 0,
            color: isDark ? Colors.grey.shade900 : Colors.white,
            margin: const EdgeInsets.only(bottom: 16.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: isDark ? Colors.grey.shade800 : Colors.grey.shade100),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          task['title'],
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      _buildStatusBadge(isCompleted),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildIconRow(CupertinoIcons.location_solid, task['location_name'], isDark),
                  const SizedBox(height: 10),
                  _buildIconRow(CupertinoIcons.calendar, task['date'], isDark),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _openInAppMap(task),
                          icon: const Icon(CupertinoIcons.map, size: 18),
                          label: const Text('الخريطة'),
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      if (!isCompleted) ...[
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SupervisorTaskDetailScreen(task: task),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('تحديث'),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(bool isCompleted) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isCompleted ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        isCompleted ? 'مكتملة' : 'قيد الانتظار',
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

