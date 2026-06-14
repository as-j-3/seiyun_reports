import 'package:flutter/foundation.dart';
import 'package:seiyun_reports_app/core/database/news_local_service.dart';
import 'package:seiyun_reports_app/core/network/dio_client.dart';
import 'package:seiyun_reports_app/core/network/api_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart'; 
import 'package:seiyun_reports_app/core/network/network_info.dart';
import 'package:seiyun_reports_app/core/utils/update_helper.dart';
import 'news_service.dart';
import '../models/news_tips_model.dart';

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
    List<NewsModel> cachedData = await _localService.getLocalNews();
    
    bool shouldSync = await UpdateHelper.canSync(
      lastUpdateKey: 'news_tips_sync',
      daysInterval: 1, 
      forceUpdate: isRefresh,
    );

    bool hasInternet = await _networkInfo.isConnected;

    if (shouldSync && hasInternet) {
      _syncDataWithServer(); 
    }

    return cachedData;
  }

  /// عملية المزامنة الخلفية مع السيرفر
  /// عملية المزامنة الخلفية مع السيرفر ومزامنة الحذف
  Future<void> _syncDataWithServer() async {
    try {

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

      if (responses[0].statusCode == 200 && responses[1].statusCode == 200) {
        await _localService.syncNewsTable(allRemoteData);

        await UpdateHelper.saveLastUpdate('news_tips_sync');
      }
    } catch (e) {
    }
  }

  /// دالة مساعدة لجلب البيانات المحلية وترتيبها حسب تاريخ الإنشاء
  Future<List<NewsModel>> _getAndSortLocalData() async {
    try {
      List<NewsModel> localData = await _localService.getLocalNews();
      localData.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return localData;
    } catch (e) {
      return [];
    }
  }
}

