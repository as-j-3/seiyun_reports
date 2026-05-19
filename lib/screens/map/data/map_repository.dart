
import '../models/map_data_model.dart';
import 'map_service.dart';
import 'package:seiyun_reports_app/core/network/network_info.dart';

class MapRepository {
  final MapService _service;
  final NetworkInfo _networkInfo;

  MapRepository(this._service, this._networkInfo);

  Future<MapDataModel?> getMapData() async {
    if (!await _networkInfo.isConnected) return null;

    try {
      final response = await _service.getMapData();
      if (response.data['success'] == 'success') {
        return MapDataModel.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      print("Error in MapRepository: $e");
      return null;
    }
  }
}
