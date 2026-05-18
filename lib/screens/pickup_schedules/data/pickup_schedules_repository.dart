
import '../models/pickup_schedule_model.dart';
import 'pickup_schedules_service.dart';
import 'package:seiyun_reports_app/core/network/network_info.dart';

class PickupSchedulesRepository {
  final PickupSchedulesService _service;
  final NetworkInfo _networkInfo;

  PickupSchedulesRepository(this._service, this._networkInfo);

  /// جلب الحاويات القريبة والجداول (بنفس أسلوب المستودعات الأخرى)
  Future<List<PickupScheduleModel>> fetchNearbyContainers(double lat, double lng) async {
    if (!await _networkInfo.isConnected) return [];

    try {
      final response = await _service.getAreaSchedules(lat: lat, lng: lng);
      
      if (response.data['status'] == 'success') {
        final List list = response.data['data']['containers'];
        return list.map((json) => PickupScheduleModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print("Error in PickupSchedulesRepository: $e");
      return [];
    }
  }
}
