import 'dart:developer' as developer;
import 'pref_helper.dart';
class UpdateHelper {
  // دالة فحص المزامنة: ترجع (true) إذا كان يجب علينا الاتصال بالسيرفر
  static Future<bool> canSync({
    required String lastUpdateKey, // مفتاح خاص بكل ميزة (أخبار، بلاغات..)
    int daysInterval = 1,          // عدد الأيام المطلوبة للتحديث (افتراضياً يوم واحد)
    bool forceUpdate = false,      // لو المستخدم سحب الشاشة للتحديث اليدوي
  }) async {
    
    // 1. إذا كان التحديث إجبارياً (مثل Refresh)، وافق فوراً
    if (forceUpdate) {
      developer.log('Update forced by user', name: 'UpdateHelper');
      return true;
    }

    // 2. جلب تاريخ آخر تحديث من الـ Shared Preferences
    final String? lastUpdateStr = await PrefHelper.getString(lastUpdateKey);

    // 3. إذا لم يسبق للتطبيق التحديث أبداً، وافق على التحديث
    if (lastUpdateStr == null) {
      developer.log('First time sync for: $lastUpdateKey', name: 'UpdateHelper');
      return true;
    }

    try {
      final DateTime lastUpdate = DateTime.parse(lastUpdateStr);
      final DateTime now = DateTime.now();
      
      // 4. حساب الفرق: هل مر "يوم" (أو المدة المحددة)؟
      final bool isExpired = now.difference(lastUpdate).inDays >= daysInterval;

      developer.log(
        'Feature: $lastUpdateKey | Last: $lastUpdate | Should Sync: $isExpired',
        name: 'UpdateHelper'
      );

      return isExpired;
    } catch (e) {
      // في حال حدوث خطأ في قراءة التاريخ، نحدث احتياطاً
      return true; 
    }
  }

  // دالة لحفظ تاريخ التحديث "الآن" بعد نجاح المزامنة
  static Future<void> saveLastUpdate(String key) async {
    await PrefHelper.setString( key, DateTime.now().toIso8601String(), );
  }
}