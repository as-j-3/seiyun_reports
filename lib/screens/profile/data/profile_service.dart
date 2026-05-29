import 'package:dio/dio.dart';
import 'package:seiyun_reports_app/core/network/api_service.dart';

class ProfileService {
  final ApiService _apiService;

  ProfileService(this._apiService);

  /// جلب معلومات المواطن (POST)
  Future<Response> getProfileInformation() async {
    try {
      return await _apiService.post('showInformationCitizen');
    } catch (e) {
      rethrow;
    }
  }

  /// تحديث معلومات المواطن (POST)
  Future<Response> updateProfileInformation({
    double? latitude,
    double? longitude,
    String? name,
    String? phone,
    String? email,
    String? imagePath,
  }) async {
    try {
      Map<String, dynamic> data = {};
      if (latitude != null) data['latitude'] = latitude;
      if (longitude != null) data['longitude'] = longitude;
      if (name != null) data['name'] = name;
      if (phone != null) data['phone'] = phone;
      if (email != null) data['email'] = email;

      FormData formData = FormData.fromMap(data);

      if (imagePath != null) {
        formData.files.add(
          MapEntry('image', await MultipartFile.fromFile(imagePath)),
        );
      }

      return await _apiService.post('updateInformationCitizen', data: formData);
    } catch (e) {
      rethrow;
    }
  }
}
