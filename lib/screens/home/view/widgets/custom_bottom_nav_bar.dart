import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:seiyun_reports_app/core/theme/app_theme.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      elevation: 0,
      color: Theme.of(context).cardColor,
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(
              Icons.home,
              "nav.home".tr(),
              currentIndex == 0,
              () => onTap(0),
            ),
            _navItem(
              Icons.map_outlined,
              "nav.map".tr(),
              currentIndex == 1,
              () => onTap(1),
            ),
            const SizedBox(width: 40), 
            _navItem(
              Icons.newspaper_outlined,
              "nav.news".tr(),
              currentIndex == 2,
              () => onTap(2),
            ),
            _navItem(
              Icons.person_outline,
              "nav.profile".tr(),
              currentIndex == 3,
              () => onTap(3),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navItem(
    IconData icon,
    String label,
    bool isActive,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque, 
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? AppTheme.primaryColor : Colors.grey,
            size: 24,
          ),
          Text(
            label,
            style: TextStyle(
              color: isActive ? AppTheme.primaryColor : Colors.grey,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
