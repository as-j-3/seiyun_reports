import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:seiyun_reports_app/core/database/news_local_service.dart';
import 'package:seiyun_reports_app/core/network/api_service.dart';
import 'package:seiyun_reports_app/core/network/dio_client.dart';
import 'package:seiyun_reports_app/core/network/network_info.dart';
import 'package:seiyun_reports_app/screens/news_tips/data/news_service.dart';
import 'package:seiyun_reports_app/screens/news_tips/models/news_tips_model.dart';
import '../data/news_repository.dart';

class NewsTipsViewModel extends ChangeNotifier {
  late NewsRepository _newsRepository;
 NewsTipsViewModel(this._newsRepository) {
  // 1. تجهيز الأدوات الأساسية (التي كانت ناقصة عندك)
    final dioClient = DioClient();
    final apiService = ApiService(dioClient);
    final newsService = Newsservice(apiService); // تأكدي من مطابقة اسم الكلاس عندك
    final localService = NewsLocalService();
    final networkInfo = NetworkInfoImpl(Connectivity());
     _newsRepository = NewsRepository(
      newsService,
      localService,
      networkInfo,
    );
    loadContent();
  }
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  bool _isNewsSelected = true;
  bool get isNewsSelected => _isNewsSelected;

  //تخزن كل 
  List<NewsModel> _allContent = [];
  List<NewsModel>  get newsList => _allContent.where((item)=>item.type.trim().toLowerCase()=='news').toList();
  List<NewsModel>  get tipssList => _allContent.where((item)=>item.type.trim().toLowerCase()=='tips').toList();


  void toggleSelection(bool isNews) {
    _isNewsSelected = isNews;
    notifyListeners();
  }

  Future <void> loadContent() async {
    //اذا كانت القائمة فارغة تماما يظهر حق
  if (_allContent.isEmpty) {
      _isLoading = true;
      notifyListeners();
    }
    try{
      //يجيب من الكاش اول مره 
      _allContent = await _newsRepository.fetchAllContent();
      _isLoading = false;
      notifyListeners();

      // انتظار بسيط للسماح للمزامنة الخلفية بالانتهاء
      await Future.delayed(const Duration(seconds: 2));

      _allContent = await _newsRepository.fetchAllContent();
      notifyListeners();

   
    } catch (e) {
     debugPrint("Error fetching content: $e");
    } finally {
      _isLoading = false;
      notifyListeners(); 
    }
  }
  }
