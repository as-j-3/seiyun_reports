import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../viewmodel/pickup_schedules_viewmodel.dart';
import 'widgets/pickup_schedules_header.dart';
import 'widgets/pickup_summary_stats.dart';
import 'widgets/nearby_container_card.dart';
import 'widgets/pickup_tips_card.dart';

class PickupSchedulesPage extends StatefulWidget {
  const PickupSchedulesPage({Key? key}) : super(key: key);

  @override
  State<PickupSchedulesPage> createState() => _PickupSchedulesPageState();
}

class _PickupSchedulesPageState extends State<PickupSchedulesPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PickupSchedulesViewModel>().fetchData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<PickupSchedulesViewModel>(
        builder: (context, viewModel, child) {
          return RefreshIndicator(
            onRefresh: () => viewModel.fetchData(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  PickupSchedulesHeader(
                    currentLocation: viewModel.currentLocationName,
                  ),
                  PickupSummaryStats(
                    nearbyCount: viewModel.totalNearbyContainers,
                    nextPickupDay: viewModel.nextPickupDayLabel,
                  ),
                  if (viewModel.isLoading)
                    const Padding(
                      padding: EdgeInsets.all(40.0),
                      child: CircularProgressIndicator(),
                    )
                  else ...[
                    _buildSectionHeader(
                      context,
                      'schedules.nearby_containers'.tr(),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children:
                            viewModel.nearbyContainers
                                .map((c) => NearbyContainerCard(container: c))
                                .toList(),
                      ),
                    ),
                    const PickupTipsCard(),
                    const SizedBox(height: 30),
                  ],
                ],
              ),
            ),
          );
        },
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
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
