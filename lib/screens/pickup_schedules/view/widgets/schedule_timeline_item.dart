import 'package:flutter/material.dart';
import 'package:seiyun_reports_app/screens/pickup_schedules/models/pickup_schedule_model.dart';
import 'package:seiyun_reports_app/core/theme/app_theme.dart';

class ScheduleTimelineItem extends StatelessWidget {
  final PickupScheduleModel schedule;

  const ScheduleTimelineItem({Key? key, required this.schedule})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isHighlight = schedule.isToday || schedule.isTomorrow;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color:
            isHighlight
                ? (isDark
                    ? AppTheme.primaryGreen.withOpacity(0.15)
                    : const Color(0xFFF1F8E9))
                : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color:
              isHighlight
                  ? AppTheme.primaryGreen.withOpacity(0.5)
                  : Theme.of(context).dividerColor.withOpacity(0.1),
          width: 1.5,
        ),
        boxShadow:
            isDark
                ? []
                : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDayInfo(context, isDark),
          const SizedBox(height: 16),
          _buildTimeInfo(context),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),
          _buildLocationsInfo(context, isDark),
        ],
      ),
    );
  }

  Widget _buildDayInfo(BuildContext context, bool isDark) {
    return Row(
      children: [
        if (schedule.isToday || schedule.isTomorrow)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            margin: const EdgeInsets.only(left: 12),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              schedule.isToday ? 'اليوم' : 'غداً',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                schedule.day,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                schedule.date,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryGreen,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimeInfo(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.access_time_filled, size: 16, color: Colors.orange),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            '${schedule.startTime} - ${schedule.endTime}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.titleMedium?.color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationsInfo(BuildContext context, bool isDark) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          schedule.locations
              .map(
                (loc) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white10 : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 14,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        loc,
                        style: TextStyle(
                          color: isDark ? Colors.grey[300] : Colors.grey[800],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
    );
  }
}
