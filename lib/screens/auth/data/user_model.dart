/// موديل يمثل بيانات المستخدم في النظام
class UserModel {
  final int id;
  final String name;
  final String email;
  final String role; // دور المستخدم (مثلاً: مواطن، مسؤول)
  final String? street; // الشارع (اختياري)
  final String? district; // الحي/المنطقة (اختياري)
  final String? type; // نوع الحساب

  UserModel({
    required this.id, 
    required this.name, 
    required this.email, 
    required this.role,
    this.street,
    this.district,
    this.type,
  });

  /// تحويل البيانات القادمة من السيرفر (JSON) إلى كائن UserModel
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      street: json['street'], 
      district: json['district'], 
      type: json['type'],
    );
  }

  /// تحويل كائن UserModel إلى Map لإرساله للسيرفر أو حفظه
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'street': street,
      'district': district,
      'type': type,
    };
  }
}