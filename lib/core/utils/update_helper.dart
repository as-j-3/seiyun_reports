import 'dart:developer' as developer;
import 'pref_helper.dart';
class UpdateHelper {
  /// التحقق مما إذا كان بالإمكان إجراء المزامنة بناءً على تاريخ آخر تحديث والمدة المحددة
  static Future<bool> canSync({
    required String lastUpdateKey, 
    int daysInterval = 1,          
    bool forceUpdate = false,      
  }) async {
    
    if (forceUpdate) {
      return true;
    }

    final String? lastUpdateStr = await PrefHelper.getString(lastUpdateKey);

    if (lastUpdateStr == null) {
      return true;
    }

    try {
      final DateTime lastUpdate = DateTime.parse(lastUpdateStr);
      final DateTime now = DateTime.now();
      
      final bool isExpired = now.difference(lastUpdate).inDays >= daysInterval;

      return isExpired;
    } catch (e) {
      return true; 
    }
  }

  /// حفظ تاريخ ووقت آخر عملية تحديث/مزامنة ناجحة
  static Future<void> saveLastUpdate(String key) async {
    await PrefHelper.setString( key, DateTime.now().toIso8601String(), );
  }
}