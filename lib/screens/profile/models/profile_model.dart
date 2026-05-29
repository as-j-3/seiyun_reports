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
    // التعامل مع احتمالية وجود البيانات داخل كائن 'user'
    final userData = json['user'] ?? json;

    return ProfileModel(
      fullName: userData['name'] ?? userData['full_name'] ?? '',
      email: userData['email'] ?? '',
      phone: userData['phone'] ?? '',
      latitude: double.tryParse(userData['latitude'].toString()) ?? 0.0,
      longitude: double.tryParse(userData['longitude'].toString()) ?? 0.0,
      areaName: userData['area_name'] ?? '',
      profileImage: userData['profile_image'],
    );
  }
}
