
class ProfileModel {
  final String fullName;
  final String email;
  final String phone;
  final double latitude;
  final double longitude;
  final String areaName;
  final String? profileImage;

  ProfileModel({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.latitude,
    required this.longitude,
    required this.areaName,
    this.profileImage,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      fullName: json['full_name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      latitude: double.tryParse(json['latitude'].toString()) ?? 0.0,
      longitude: double.tryParse(json['longitude'].toString()) ?? 0.0,
      areaName: json['area_name'] ?? '',
      profileImage: json['profile_image'],
    );
  }
}
