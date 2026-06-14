import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:seiyun_reports_app/core/theme/app_theme.dart';

class EmptyReportsState extends StatelessWidget {
  const EmptyReportsState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.description_outlined,
              size: 80,
              color: Colors.grey.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "my_reports.empty".tr(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              "my_reports.empty_desc".tr(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color:
                    Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
