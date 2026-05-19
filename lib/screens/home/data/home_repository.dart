
import '../models/home_data_model.dart';
import 'home_service.dart';
import 'package:seiyun_reports_app/core/network/network_info.dart';
import 'package:flutter/foundation.dart';

class HomeRepository {
  final HomeService _service;
  final NetworkInfo _networkInfo;

  HomeRepository(this._service, this._networkInfo);

  /// جلب بيانات الهوم ومعالجتها
  Future<HomeDataModel?> getHomeData() async {
    if (!await _networkInfo.isConnected) return null;

    try {
      final response = await _service.getHomeData();
      debugPrint("Home API Response Data: ${response.data}");
      if (response.data['status'] == 'success') {
        return HomeDataModel.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      debugPrint("Error in HomeRepository: $e");
      return null;
    }
  }
}
