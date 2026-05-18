import 'package:flutter/material.dart';
import 'package:seiyun_reports_app/screens/pickup_schedules/view/pickup_schedules_page.dart';
import '../../models/home_data_model.dart';

import 'package:provider/provider.dart';
import 'package:seiyun_reports_app/screens/home/viewmodel/home_viewmodel.dart';

class NextPickupCard extends StatelessWidget {
  const NextPickupCard({super.key});

  @override
  Widget build(BuildContext context) {
    final homeVM = context.watch<HomeViewModel>();
    final nextCollection = homeVM.nextCollection;
    return InkWell(
      onTap: () {
        if (nextCollection == null) {
          context.read<HomeViewModel>().setPage(3); // الانتقال للبروفايل لتحديد الموقع
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PickupSchedulesPage()),
          );
        }
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nextCollection != null ? "موعد الرفع القادم" : "تنبيه",
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    (nextCollection != null && nextCollection!.timing.isNotEmpty)
                        ? nextCollection!.timing
                        : "حدد موقعك ليظهر لك أقرب نقاط تجمع نفايات",
                    style: TextStyle(
                      fontSize: nextCollection != null ? 14 : 12,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ],
              ),
            ),
            if (nextCollection != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  nextCollection!.status.isNotEmpty
                      ? nextCollection!.status
                      : "قريباً",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 15),
            ],
            Icon(
              nextCollection != null ? Icons.timer_outlined : Icons.location_on_outlined, 
              color: const Color(0xFF27ae60), 
              size: 35
            ),
          ],
        ),
      ),
    );
  }
}
