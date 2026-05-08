import 'package:flutter/material.dart';

class CitizenReportsStats extends StatelessWidget {
  final int total;
  final int resolved;
  final int active;
  final String rate;

  const CitizenReportsStats({
    Key? key,
    required this.total,
    required this.resolved,
    required this.active,
    required this.rate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _StatCard(label: 'إجمالي', value: '$total', color: Colors.blue[50]!, textColor: Colors.blue),
          _StatCard(label: 'محلولة', value: '$resolved', color: Colors.green[50]!, textColor: Colors.green),
          _StatCard(label: 'نشطة', value: '$active', color: Colors.orange[50]!, textColor: Colors.orange),
          _StatCard(label: 'معدل الحل', value: rate, color: Colors.pink[50]!, textColor: Colors.pink),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final Color textColor;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: textColor.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: textColor.withOpacity(0.8)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
