import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/pickup_schedules_viewmodel.dart';
import 'widgets/pickup_schedules_header.dart';
import 'widgets/pickup_summary_stats.dart';
import 'widgets/nearby_container_card.dart';
import 'widgets/schedule_timeline_item.dart';
import 'widgets/pickup_tips_card.dart';

class PickupSchedulesPage extends StatelessWidget {
  const PickupSchedulesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PickupSchedulesViewModel(),
      child: Scaffold(
        body: Consumer<PickupSchedulesViewModel>(
          builder: (context, viewModel, child) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  PickupSchedulesHeader(
                    currentLocation: viewModel.currentLocationName,
                  ),
                  PickupSummaryStats(
                    nearbyCount: viewModel.totalNearbyContainers,
                    nextPickupDay: 'غداً',
                  ),
                  if (viewModel.isLoading)
                    const Padding(
                      padding: EdgeInsets.all(40.0),
                      child: CircularProgressIndicator(),
                    )
                  else ...[
                    _buildSectionHeader(context, 'الحاويات القريبة'),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: viewModel.nearbyContainers.map((c) => NearbyContainerCard(container: c)).toList(),
                      ),
                    ),
                    _buildSectionHeader(context, 'جدول مواعيد الرفع'),
                    Column(
                      children: viewModel.schedules.map((s) => ScheduleTimelineItem(schedule: s)).toList(),
                    ),
                    const PickupTipsCard(),
                    const SizedBox(height: 30),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
