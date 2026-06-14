import 'dart:io';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:seiyun_reports_app/screens/citizen_reports/viewmodel/citizen_reports_viewmodel.dart';
import 'package:seiyun_reports_app/screens/report/models/report_model.dart';
import '../data/report_repository.dart';

class ReportViewModel extends ChangeNotifier {
  final ReportRepository _repository;
  ReportViewModel(this._repository) {
    fetchReportsFromLaravel();
  }

  String _selectedCategory = 'تراكم_نفايات';
  String get selectedCategory => _selectedCategory;

  String? _selectedSubType;
  String? get selectedSubType => _selectedSubType;

  String _selectedPriority = 'مرتفعة';
  String get selectedPriority => _selectedPriority;

  File? _image;
  File? get image => _image;

  String _locationStatus = "يرجى الضغط لتحديد الموقع";
  String get locationStatus => _locationStatus;

  bool _isLoadingLocation = false;
  bool get isLoadingLocation => _isLoadingLocation;

  String? _verificationId;
  bool _isPhoneVerified = false;
  bool get isPhoneVerified => _isPhoneVerified;

  bool _isVerifying = false;
  bool get isVerifying => _isVerifying;

  String? _phoneErrorMessage;
  String? get phoneErrorMessage => _phoneErrorMessage;

  /// تعيين الفئة الرئيسية للبلاغ المحدد وتصفير الفئة الفرعية
  void setCategory(String category) {
    _selectedCategory = category;
    _selectedSubType = null; 
    notifyListeners();
  }

  /// تعيين الفئة الفرعية للبلاغ
  void setSubType(String? subType) {
    _selectedSubType = subType;
    notifyListeners();
  }

  /// تعيين مستوى أولوية البلاغ (منخفضة، متوسطة، مرتفعة)
  void setPriority(String priority) {
    _selectedPriority = priority;
    notifyListeners();
  }

  /// إزالة الصورة المرفقة بالبلاغ حالياً
  void removeImage() {
    _image = null;
    notifyListeners();
  }

  /// التقاط أو اختيار صورة من الكاميرا أو المعرض لارفاقها بالبلاغ
  Future<void> pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? photo = await picker.pickImage(
        source: source,
        imageQuality: 70,
      );
      if (photo != null) {
        _image = File(photo.path);
        notifyListeners();
      }
    } catch (e) {
    }
  }

  /// جلب الموقع الجغرافي الحالي للمستخدم باستخدام GPS
  Future<void> getCurrentLocation() async {
    _isLoadingLocation = true;
    notifyListeners();

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        _locationStatus =
            "إحداثيات: ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}";
      } else {
        _locationStatus = "تعذر الحصول على الصلاحية";
      }
    } catch (e) {
      _locationStatus = "خطأ في جلب الموقع";
    }
    _isLoadingLocation = false;
    notifyListeners();
  }

  /// تعيين الموقع من خريطة الاختيار
  void setLocationFromMap(double lat, double lng) {
    _locationStatus =
        "إحداثيات: ${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}";
    notifyListeners();
  }

  List<ReportModel> _reportsList = [];
  List<ReportModel> get reportsList => _reportsList;

  String _searchQuery = "";
  /// تعيين نص البحث لتصفية قائمة بلاغات المستخدم
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  List<ReportModel> get filteredReports {
    if (_searchQuery.isEmpty) return _reportsList;
    return _reportsList.where((report) {
      final query = _searchQuery.toLowerCase();
      return report.title.toLowerCase().contains(query) ||
          report.description.toLowerCase().contains(query) ||
          report.status.toLowerCase().contains(query);
    }).toList();
  }

  bool _isLoadingReports = false; 
  bool get isLoadingReports => _isLoadingReports;

  bool _isUploading = false; 
  bool get isUploading => _isUploading;

  /// جلب بلاغات المستخدم من خادم لارفل ومزامنة البلاغات المعلقة
  Future<void> fetchReportsFromLaravel({bool isRefresh = false}) async {
    _isLoadingReports = true;
    notifyListeners();
    try {
      await _repository.syncPendingReports();
      _reportsList = await _repository.fetchMyReports(
        isRefresh: isRefresh,
      ); 
    } catch (e) {
    } finally {
      _isLoadingReports = false;
      notifyListeners();
    }
  }

  /// إرسال بلاغ جديد إلى الخادم مع التحقق من النطاق الجغرافي والصورة
  Future<void> sendNewReport(
    BuildContext context,
    String description, {
    String? customTitle,
  }) async {
    _isUploading = true;
    notifyListeners();
    String lat = "0.0";
    String lng = "0.0";
    if (_locationStatus.contains(":") && _locationStatus.contains(",")) {
      try {
        var parts = _locationStatus.split(":")[1].split(",");
        lat = parts[0].trim();
        lng = parts[1].trim();
      } catch (e) {
      }
    }

    if (lat != "0.0" && lng != "0.0") {
      bool isInside = await _isLocationInServiceArea(
        double.parse(lat),
        double.parse(lng),
      );
      if (!isInside) {
        _isUploading = false;
        notifyListeners();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "عفواً، الموقع المحدد خارج نطاق الخدمة المسموح به (مدينة سيئون).",
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
          ),
        );
        return; 
      }
    }

    String categoryLabel = 'أخرى';
    if (_selectedCategory == 'تراكم_نفايات') {
      categoryLabel = 'تراكم نفايات';
    } else if (_selectedCategory == 'نظافة_شوارع') {
      categoryLabel = 'نظافة الشوارع';
    } else if (_selectedCategory == 'تشويه_بصري') {
      categoryLabel = 'التشوه البصري';
    }

    final String generatedTitle =
        (customTitle != null && customTitle.isNotEmpty)
            ? customTitle
            : (_selectedSubType != null && _selectedSubType!.isNotEmpty
                ? '$categoryLabel - $_selectedSubType'
                : categoryLabel);

    String mappedType = 'اخرى';
    if (_selectedCategory == 'تراكم_نفايات') {
      mappedType = 'رفع';
    } else if (_selectedCategory == 'نظافة_شوارع') {
      mappedType = 'كنس';
    } else {
      mappedType = 'اخرى';
    }

    bool success = await _repository.sendNewReport(
      title: generatedTitle,
      description: description.isEmpty ? "لا يوجد وصف" : description,
      type: mappedType,
      priority: _selectedPriority,
      lat: lat,
      lng: lng,
      imageFile: _image,
    );

    _isUploading = false;
    notifyListeners();
    if (success) {
      await fetchReportsFromLaravel(isRefresh: true);

      try {
        if (context.mounted) {
          Provider.of<CitizenReportsViewModel>(
            context,
            listen: false,
          ).loadDashboardData();
        }
      } catch (e) {
      }

      String message = "تمت العملية بنجاح";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "لا يوجد اتصال بالإنترنت حاليًا سيتم رفعه البلاغ عند توفر الشبكة.",
          ),
          backgroundColor: Colors.blueGrey, 
          duration: Duration(seconds: 5),
        ),
      );
      fetchReportsFromLaravel();
      Navigator.pop(context); 
    }
  }

  /// التحقق مما إذا كانت الإحداثيات المحددة تقع ضمن نطاق الخدمة المسموح به (مدينة سيئون)
  Future<bool> _isLocationInServiceArea(double lat, double lng) async {
    try {
      final String jsonString = await rootBundle.loadString(
        'json/boundary_sayun.json',
      );
      final Map<String, dynamic> geoJson = jsonDecode(jsonString);

      final List<dynamic> coordinates =
          geoJson['features'][0]['geometry']['coordinates'][0];

      bool isInside = false;
      int i, j = coordinates.length - 1;
      for (i = 0; i < coordinates.length; i++) {
        double polyLngI = coordinates[i][0];
        double polyLatI = coordinates[i][1];
        double polyLngJ = coordinates[j][0];
        double polyLatJ = coordinates[j][1];

        if (((polyLatI > lat) != (polyLatJ > lat)) &&
            (lng <
                (polyLngJ - polyLngI) *
                        (lat - polyLatI) /
                        (polyLatJ - polyLatI) +
                    polyLngI)) {
          isInside = !isInside;
        }
        j = i;
      }
      return isInside;
    } catch (e) {
      return true;
    }
  }
}
