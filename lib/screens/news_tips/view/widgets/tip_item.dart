import 'package:flutter/material.dart';
import 'package:seiyun_reports_app/screens/news_tips/data/news_tips_model.dart';

class TipItem extends StatelessWidget {
  final NewsModel tip;

  const TipItem({super.key, required this.tip});

  @override
  Widget build(BuildContext context) {
    const Color tipColor = Colors.green;
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: tipColor.withValues(alpha: 0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: tipColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
          child: const Icon(Icons.lightbulb_outline, color: tipColor, size: 24),          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tip.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleSmall?.color,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  tip.content,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
