import 'dart:async';
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
  Timer? _autoRefreshTimer;
  
  NewsTipsViewModel(this._newsRepository) {
    final dioClient = DioClient();
    final apiService = ApiService(dioClient);
    final newsService = Newsservice(apiService); 
    final localService = NewsLocalService();
    final networkInfo = NetworkInfoImpl(Connectivity());
     _newsRepository = NewsRepository(
      newsService,
      localService,
      networkInfo,
    );
    loadContent();
    _startAutoRefresh();
  }

  void _startAutoRefresh() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      loadContent();
    });
  }
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  bool _isNewsSelected = true;
  bool get isNewsSelected => _isNewsSelected;

  List<NewsModel> _allContent = [];
  List<NewsModel>  get newsList => _allContent.where((item)=>item.type.trim().toLowerCase()=='news').toList();
  List<NewsModel>  get tipssList => _allContent.where((item)=>item.type.trim().toLowerCase()=='tips').toList();


  void toggleSelection(bool isNews) {
    _isNewsSelected = isNews;
    notifyListeners();
  }

  Future <void> loadContent({bool isRefresh = true}) async {
  if (_allContent.isEmpty) {
      _isLoading = true;
      notifyListeners();
    }
    try{
      _allContent = await _newsRepository.fetchAllContent(isRefresh: isRefresh);
      _isLoading = false;
      notifyListeners();

      await Future.delayed(const Duration(seconds: 2));

      _allContent = await _newsRepository.fetchAllContent(isRefresh: false);
      notifyListeners();

   
    } catch (e) {
    } finally {
      _isLoading = false;
      notifyListeners(); 
    }
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    super.dispose();
  }
}
