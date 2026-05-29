import 'package:flutter/material.dart';

class PickupSummaryStats extends StatelessWidget {
  final int nearbyCount;
  final String nextPickupDay;

  const PickupSummaryStats({
    super.key,
    required this.nearbyCount,
    required this.nextPickupDay,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Transform.translate(
        offset: const Offset(0, -30),
        child: Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'حاويات قريبة',
                value: '$nearbyCount',
                color: const Color(0xFFE8F5E9),
                textColor: const Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _StatCard(
                label: 'موعد الرفع',
                value: nextPickupDay,
                color: const Color(0xFFFFF3E0),
                textColor: const Color(0xFFE65100),
              ),
            ),
          ],
        ),
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
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: textColor.withOpacity(0.7),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
