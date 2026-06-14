import 'package:flutter/material.dart';
import 'package:seiyun_reports_app/screens/news_tips/view/news_tips_screen.dart';

import 'package:seiyun_reports_app/screens/citizen_reports/view/citizen_reports_page.dart';

import 'package:seiyun_reports_app/screens/home/view/home_screen.dart'; 

class SectionHeader extends StatelessWidget {
  final String title;
  final String action;

  const SectionHeader({super.key, required this.title, required this.action});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: sectionTitleStyle),
        TextButton(
          child: Text(
            action,
            style: const TextStyle(
              color: Color(0xFF27ae60),
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          onPressed: () {
            if (title == 'البلاغات الأخيرة') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CitizenReportsPage()),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NewsTipsScreen()),
              );
            }
          },
        ),
      ],
    );
  }
}
