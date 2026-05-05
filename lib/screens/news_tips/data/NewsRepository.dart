import 'package:flutter/foundation.dart';
import 'package:seiyun_reports_app/core/database/news_local_service.dart';
import 'package:seiyun_reports_app/core/network/dio_client.dart';
import 'package:seiyun_reports_app/core/network/api_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart'; 
import 'package:seiyun_reports_app/core/network/network_info.dart';
import 'package:seiyun_reports_app/core/utils/update_helper.dart';
import 'NewsService.dart';
import 'news_tips_model.dart';

/// كلاس المستودع (Repository) المسؤول عن التنسيق بين البيانات المحلية (Local) والبيانات البعيدة (Remote)
/// يتبع استراتيجية "البيانات المحلية أولاً" (Offline-first)
class NewsRepository {
  late Newsservice _newsService ;
  late NewsLocalService _localService;
  final NetworkInfo _networkInfo;

  NewsRepository(this._newsService, this._localService, this._networkInfo);

  /// جلب كل المحتوى (أخبار ونصائح)
  /// يقوم بجلب البيانات المخزنة محلياً فوراً، ثم يبدأ عملية مزامنة خلفية إذا لزم الأمر
  Future<List<NewsModel>> fetchAllContent({bool isRefresh = false}) async {
    // 1. جلب البيانات من الذاكرة المحلية أولاً لسرعة العرض للمستخدم
    List<NewsModel> cachedData = await _localService.getLocalNews();
    
    // 2. التحقق مما إذا كان يجب تحديث البيانات من السيرفر (بناءً على الوقت أو طلب التحديث)
    bool shouldSync = await UpdateHelper.canSync(
      lastUpdateKey: 'news_tips_sync',
      daysInterval: 1, // التحديث التلقائي يتم كل يوم واحد
      forceUpdate: isRefresh,
    );

    // 3. التحقق من وجود اتصال بالإنترنت
    bool hasInternet = await _networkInfo.isConnected;

    if (shouldSync && hasInternet) {
      // بدء عملية المزامنة في الخلفية دون تعطيل واجهة المستخدم
      _syncDataWithServer(); 
    }

    // إعادة البيانات المخزنة (التي قد تكون قديمة قليلاً) ريثما تكتمل المزامنة
    return cachedData;
  }

  /// عملية المزامنة الخلفية مع السيرفر
  Future<void> _syncDataWithServer() async {
    try {
      debugPrint("بدء المزامنة الصامتة مع السيرفر...");
      
      // جلب الأخبار والنصائح في وقت واحد (Parallel requests) لسرعة التنفيذ
      final responses = await Future.wait([
          _newsService.getNews(),
          _newsService.getTips(),
        ]);

      List<NewsModel> allRemoteData = [];

      for (var response in responses) {
        if (response.statusCode == 200 && response.data['status'] == 'success') {
          List dataList = response.data['data'];
          allRemoteData.addAll(dataList.map((j) => NewsModel.fromJson(j)).toList());
        }
      }

      if (allRemoteData.isNotEmpty) {
        // 4. تحديث الذاكرة المحلية بالبيانات الجديدة القادمة من السيرفر
        await _localService.saveNews(allRemoteData);
        // تحديث طابع الوقت لآخر مزامنة ناجحة
        await UpdateHelper.saveLastUpdate('news_tips_sync');
        debugPrint("تمت المزامنة وحفظ البيانات الجديدة في قاعدة البيانات المحلية.");
      }
    } catch (e) {
      debugPrint("فشل في المزامنة الخلفية: $e");
    }
  }

  /// دالة مساعدة لجلب البيانات المحلية وترتيبها حسب تاريخ الإنشاء
  Future<List<NewsModel>> _getAndSortLocalData() async {
    try {
      List<NewsModel> localData = await _localService.getLocalNews();
      localData.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return localData;
    } catch (e) {
      debugPrint("خطأ في قراءة قاعدة البيانات المحلية: $e");
      return [];
    }
  }
}