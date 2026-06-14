import 'package:seiyun_reports_app/core/database/pickup_schedules_local_service.dart';
import '../models/pickup_schedule_model.dart';
import 'pickup_schedules_service.dart';
import 'package:seiyun_reports_app/core/network/network_info.dart';

class PickupSchedulesRepository {
  final PickupSchedulesService _service;
  final NetworkInfo _networkInfo;
  final PickupSchedulesLocalService _localService;

  PickupSchedulesRepository(
    this._service,
    this._networkInfo,
    this._localService,
  );

  /// جلب الحاويات القريبة والجداول (مع دعم التخزين المحلي)
  Future<List<PickupScheduleModel>> fetchNearbyContainers(
    double lat,
    double lng,
  ) async {
    final bool isConnected = await _networkInfo.isConnected;

    if (isConnected) {
      try {
        final response = await _service.getAreaSchedules(lat: lat, lng: lng);

        if (response.data['status'] == 'success') {
          final List list = response.data['data']['containers'];
          final schedules =
              list.map((json) => PickupScheduleModel.fromJson(json)).toList();

          await _localService.saveSchedules(schedules);

          return schedules;
        }
      } catch (e) {
      }
    }

    return await _localService.getSchedules();
  }
}
