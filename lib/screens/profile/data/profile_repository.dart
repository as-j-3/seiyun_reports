import '../models/profile_model.dart';
import 'profile_service.dart';
import 'package:seiyun_reports_app/core/network/network_info.dart';

class ProfileRepository {
  final ProfileService _service;
  final NetworkInfo _networkInfo;

  ProfileRepository(this._service, this._networkInfo);

  /// جلب بيانات الملف الشخصي ومعالجتها
  Future<ProfileModel?> getProfile() async {
    if (!await _networkInfo.isConnected) return null;

    try {
      final response = await _service.getProfileInformation();
      if (response.data['status'] == 'success') {
        return ProfileModel.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      print("Error in ProfileRepository: $e");
      return null;
    }
  }

  /// تحديث بيانات البروفايل
  Future<ProfileModel?> updateProfile({
    double? latitude,
    double? longitude,
    String? name,
    String? phone,
    String? email,
    String? imagePath,
  }) async {
    if (!await _networkInfo.isConnected) return null;

    try {
      final response = await _service.updateProfileInformation(
        latitude: latitude,
        longitude: longitude,
        name: name,
        phone: phone,
        email: email,
        imagePath: imagePath,
      );
      if (response.data['status'] == 'success') {
        return ProfileModel.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      print("Error updating profile in repository: $e");
      return null;
    }
  }
}
