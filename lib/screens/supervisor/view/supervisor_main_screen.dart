import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:seiyun_reports_app/core/theme/app_theme.dart';
import 'package:seiyun_reports_app/screens/supervisor/view/supervisor_tasks_screen.dart';
import 'package:seiyun_reports_app/screens/supervisor/view/supervisor_profile_screen.dart';

class SupervisorMainScreen extends StatefulWidget {
  const SupervisorMainScreen({Key? key}) : super(key: key);

  @override
  State<SupervisorMainScreen> createState() => _SupervisorMainScreenState();
}

class _SupervisorMainScreenState extends State<SupervisorMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const SupervisorTasksScreen(),
    const SupervisorProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: Theme.of(context).cardColor,
          selectedItemColor: AppTheme.primaryColor,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.list_bullet),
              activeIcon: Icon(CupertinoIcons.list_bullet),
              label: 'المهام',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.person),
              activeIcon: Icon(CupertinoIcons.person_fill),
              label: 'حسابي',
            ),
          ],
        ),
      ),
    );
  }
}
