import 'package:flutter/material.dart';
import 'package:seiyun_reports_app/core/theme/app_theme.dart';

class StatsCards extends StatelessWidget {
  final int activeCount;
  final int resolvedCount;
    const StatsCards({
      super.key,
      required this.activeCount, 
      required this.resolvedCount,  
      });


  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _statCard(
          "$activeCount",
          "بلاغات نشطة",
          const Color(0xFFfee2e2),
          Theme.of(context).brightness == Brightness.dark ? const Color(0xFFfca5a5) : const Color(0xFF991b1b),
          context,
        ),
        const SizedBox(width: 15),
        _statCard(
          "$resolvedCount",
          "بلاغ تم إنجازه",
          const Color(0xFFe0f2fe),
          Theme.of(context).brightness == Brightness.dark ? const Color(0xFF7dd3fc) : const Color(0xFF075985),
          context,
        ),
      ],
    );
  }

  Widget _statCard(String val, String label, Color bg, Color textColor, BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
            ),
          ],
          border: Border(
            bottom: BorderSide(color: AppTheme.secondaryColor, width: 3),
          ),
        ),
        child: Column(
          children: [
            Text(
              val,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
