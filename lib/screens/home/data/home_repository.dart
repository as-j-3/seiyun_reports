import '../models/home_data_model.dart';
import 'home_service.dart';
import 'home_local_service.dart';
import 'package:seiyun_reports_app/core/network/network_info.dart';
import 'package:flutter/foundation.dart';

class HomeRepository {
  final HomeService _service;
  final NetworkInfo _networkInfo;
  final HomeLocalService _localService;

  HomeRepository(this._service, this._networkInfo, this._localService);

  /// جلب بيانات الهوم ومعالجتها (مع دعم التخزين المحلي)
  Future<HomeDataModel?> getHomeData() async {
    final bool isConnected = await _networkInfo.isConnected;

    if (isConnected) {
      try {
        final response = await _service.getHomeData();
        if (response.data['status'] == 'success') {
          final data = HomeDataModel.fromJson(response.data['data']);

          await _localService.saveHomeData(data);

          return data;
        }
      } catch (e) {
      }
    }

    return await _localService.getHomeData();
  }
}
