import 'package:flutter/material.dart';
import 'package:seiyun_reports_app/core/theme/app_theme.dart';

class ReportHeader extends StatelessWidget {
  const ReportHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, left: 25, right: 25, bottom: 30),
      decoration: const BoxDecoration(
        gradient: AppTheme.headerGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(35),
          bottomRight: Radius.circular(35),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.chevron_right,
                  color: Colors.white,
                  size: 30,
                ),
                onPressed: () => Navigator.maybePop(context),
              ),
              const Text(
                "بلاغ جديد",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: const Text(
              "ساعد في تحسين مدينتك من خلال الإبلاغ عن المشكلات، سنعمل على حلها في أقرب وقت.",
              style: TextStyle(color: Colors.white, fontSize: 13, height: 1.6),
            ),
          ),
        ],
      ),
    );
  }
}
