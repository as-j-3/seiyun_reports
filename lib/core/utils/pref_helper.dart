import 'package:shared_preferences/shared_preferences.dart';

class PrefHelper {
  static SharedPreferences? _prefs;

  /// تهيئة مثيل التفضيلات المشتركة Shared Preferences
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static const String _tokenKey = 'access_token';
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _roleKey = 'user_role';
  static const String _userIdKey = 'user_id';
  static const String _profileImagePathKey = 'profile_image_path';
  static const String _notificationsEnabledKey = 'notifications_enabled';
  static const String _userNameKey = 'user_name';
  static const String _userPhoneKey = 'user_phone';
  static const String _userEmailKey = 'user_email';
  static const String _userAddressKey = 'user_address';
  static const String _userLatKey = 'user_lat';
  static const String _userLngKey = 'user_lng';
  static const String _isDarkModeKey = 'is_dark_mode';
  static const String _isPhoneVerifiedKey = 'is_phone_verified';

  /// حفظ حالة التحقق من رقم الهاتف
  static Future<void> savePhoneVerified(bool verified) async {
    final prefs = _prefs!;
    await prefs.setBool(_isPhoneVerifiedKey, verified);
  }

  /// جلب حالة التحقق من رقم الهاتف
  static Future<bool> isPhoneVerified() async {
    final prefs = _prefs!;
    return prefs.getBool(_isPhoneVerifiedKey) ?? false;
  }

  /// حفظ التوكن
  static Future<void> saveToken(String token) async {
    final prefs = _prefs!;
    await prefs.setString(_tokenKey, token);
    await prefs.setBool(_isLoggedInKey, true);
  }
    /// جلب التوكن
  static Future<String?> getToken() async {
    final prefs = _prefs!;
    return prefs.getString(_tokenKey);
  }
  /// حفظ حالة تسجيل الدخول للمستخدم
  static Future<void> saveLoginStatus(bool status) async {
    final prefs = _prefs!;
    await prefs.setBool(_isLoggedInKey, status);
  }
  
  /// حفظ المعرف الرقمي للمستخدم
  static Future<void> saveUserId(int userId) async {
    final prefs = _prefs!;
    await prefs.setInt(_userIdKey, userId);
  }

  /// جلب المعرف الرقمي للمستخدم
  static Future<int?> getUserId() async {
    final prefs = _prefs!;
    return prefs.getInt(_userIdKey);
  }



  /// حفظ الدور (مواطن / مشرف)
  static Future<void> saveRole(String role) async {
    final prefs = _prefs!;
    await prefs.setString(_roleKey, role);
  }

  /// جلب الدور
  static Future<String?> getRole() async {
    final prefs = _prefs!;
    return prefs.getString(_roleKey);
  }

  /// حفظ مسار صورة الملف الشخصي
  static Future<void> saveProfileImagePath(String path) async {
    final prefs = _prefs!;
    await prefs.setString(_profileImagePathKey, path);
  }

  /// جلب مسار صورة الملف الشخصي
  static Future<String?> getProfileImagePath() async {
    final prefs = _prefs!;
    return prefs.getString(_profileImagePathKey);
  }

  /// حفظ إعدادات الإشعارات
  static Future<void> saveNotificationsEnabled(bool enabled) async {
    final prefs = _prefs!;
    await prefs.setBool(_notificationsEnabledKey, enabled);
  }

  /// جلب إعدادات الإشعارات
  static Future<bool> isNotificationsEnabled() async {
    final prefs = _prefs!;
    return prefs.getBool(_notificationsEnabledKey) ?? true;
  }

  /// حفظ اسم المستخدم
  static Future<void> saveUserName(String name) async {
    final prefs = _prefs!;
    await prefs.setString(_userNameKey, name);
  }

  /// جلب اسم المستخدم
  static Future<String?> getUserName() async {
    final prefs = _prefs!;
    return prefs.getString(_userNameKey);
  }

  /// حفظ رقم جوال المستخدم
  static Future<void> saveUserPhone(String phone) async {
    final prefs = _prefs!;
    await prefs.setString(_userPhoneKey, phone);
  }

  /// جلب رقم جوال المستخدم
  static Future<String?> getUserPhone() async {
    final prefs = _prefs!;
    return prefs.getString(_userPhoneKey);
  }

  /// حفظ البريد الإلكتروني للمستخدم
  static Future<void> saveUserEmail(String email) async {
    final prefs = _prefs!;
    await prefs.setString(_userEmailKey, email);
  }

  /// جلب البريد الإلكتروني للمستخدم
  static Future<String?> getUserEmail() async {
    final prefs = _prefs!;
    return prefs.getString(_userEmailKey);
  }

  /// حفظ عنوان المستخدم
  static Future<void> saveUserAddress(String address) async {
    final prefs = _prefs!;
    await prefs.setString(_userAddressKey, address);
  }

  /// جلب عنوان المستخدم
  static Future<String?> getUserAddress() async {
    final prefs = _prefs!;
    return prefs.getString(_userAddressKey);
  }

  /// حفظ وضع الظهور (داكن / فاتح)
  static Future<void> saveDarkMode(bool isDark) async {
    final prefs = _prefs!;
    await prefs.setBool(_isDarkModeKey, isDark);
  }

  /// جلب وضع الظهور
  static Future<bool> isDarkMode() async {
    final prefs = _prefs!;
    return prefs.getBool(_isDarkModeKey) ?? false;
  }

  /// حفظ الإحداثيات
  static Future<void> saveUserLocation(double lat, double lng) async {
    final prefs = _prefs!;
    await prefs.setDouble(_userLatKey, lat);
    await prefs.setDouble(_userLngKey, lng);
  }

  /// جلب خط العرض
  static Future<double?> getUserLat() async {
    final prefs = _prefs!;
    return prefs.getDouble(_userLatKey);
  }

  /// جلب خط الطول
  static Future<double?> getUserLng() async {
    final prefs = _prefs!;
    return prefs.getDouble(_userLngKey);
  }

  /// التحقق من حالة الدخول
  static Future<bool> isLoggedIn() async {

    final prefs = _prefs!;
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  /// تسجيل الخروج
  static Future<void> clear() async {
    final prefs = _prefs!;
    await prefs.clear();
  }

  /// دالة عامة لحفظ أي نص (نستخدمها للمزامنة)
  static Future<void> setString(String key, String value) async {
    final prefs = _prefs!;
    await prefs.setString(key, value);
  }

  /// دالة عامة لجلب أي نص (نستخدمها للمزامنة)
  static Future<String?> getString(String key) async {
    final prefs = _prefs!;
    return prefs.getString(key);
  }
}
