import 'dart:io';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:seiyun_reports_app/screens/report/models/report_model.dart';
import '../data/report_repository.dart';
class ReportViewModel extends ChangeNotifier {
  final ReportRepository _repository;
  ReportViewModel(this._repository){
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

  // Phone Verification State
  String? _verificationId;
  bool _isPhoneVerified = false;
  bool get isPhoneVerified => _isPhoneVerified;
  
  bool _isVerifying = false;
  bool get isVerifying => _isVerifying;

  String? _phoneErrorMessage;
  String? get phoneErrorMessage => _phoneErrorMessage;

  void setCategory(String category) {
    _selectedCategory = category;
    _selectedSubType = null; // reset sub-type on category change
    notifyListeners();
  }

  void setSubType(String? subType) {
    _selectedSubType = subType;
    notifyListeners();
  }

  void setPriority(String priority) {
     _selectedPriority = priority;
      notifyListeners() ;
      }

  void removeImage() {
     _image = null;
      notifyListeners(); 
      }

  Future<void> pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? photo = await picker.pickImage(
        source: source,
         imageQuality: 70
         );
      if (photo != null)
       { _image = File(photo.path); notifyListeners(); }
    } catch (e) { debugPrint("Error picking image: $e"); }
  }

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
        desiredAccuracy: LocationAccuracy.high
        );
      _locationStatus = "إحداثيات: ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}";
    }
    else {
        _locationStatus = "تعذر الحصول على الصلاحية";
      }}
       catch (e) {
         debugPrint("Error location: $e");
        _locationStatus = "خطأ في جلب الموقع";
      }
    _isLoadingLocation = false;
    notifyListeners();
  }

  
  List<ReportModel> _reportsList = []; 
  List<ReportModel> get reportsList => _reportsList;

  bool _isLoadingReports = false; // حالة تحميل القائمة
  bool get isLoadingReports => _isLoadingReports;

  bool _isUploading = false; // حالة تحميل الزر عند الإرسال
  bool get isUploading => _isUploading;

  //  دالة جلب البلاغات المستخدم  من قاعدة البيانات
  Future<void> fetchReportsFromLaravel({bool isRefresh = false}) async {
    _isLoadingReports = true;
    notifyListeners();
    try {
      //نحاول رفع أي بلاغات كانت مخزنة أوفلاين
      await _repository.syncPendingReports();
      //جلب القائمة (سواء من السيرفر أو الكاش حسب منطق الريبوزيتوري)
      _reportsList = await _repository.fetchMyReports(isRefresh: isRefresh);//ياخذ البيانات من الريبوزتري 
    } catch (e) {
      debugPrint("خطأ في جلب البلاغات: $e");
    } finally {
      _isLoadingReports = false;
      notifyListeners();
    } 
  }

  // دالة ارسال البلاغ 
  Future<void> sendNewReport(BuildContext context,String title, String description) async {
    //تحقق من وجود عنوان للبلاغ
    if (title.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("الرجاء إكمال البيانات الأساسية المطلوبة"), backgroundColor: Colors.orange));
    return;
  }
    
    _isUploading = true;
    notifyListeners();
   // قيم افتراضية للاحداثيات 
    String lat = "0.0";  
    String lng = "0.0";
  //هذا لضمان ارسال بيانات الاحداثيات صحيحة يقبلها السيرفر
    if (_locationStatus.contains(":") && _locationStatus.contains(",")) {
      try {
       //تقص النص عشان ناخذ الارقام ونخزنها في المتغيرات 
        var parts = _locationStatus.split(":")[1].split(",");
        lat = parts[0].trim();
        lng = parts[1].trim();
      } catch (e) {
        debugPrint("خطأ في تحليل إحداثيات الموقع: $e");
      }
    }

    // التحقق من أن الموقع داخل نطاق مدينة سيئون
    if (lat != "0.0" && lng != "0.0") {
      bool isInside = await _isLocationInServiceArea(double.parse(lat), double.parse(lng));
      if (!isInside) {
        _isUploading = false;
        notifyListeners();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("عفواً، الموقع المحدد خارج نطاق الخدمة المسموح به (مدينة سيئون)."),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
          ),
        );
        return; // منع إرسال البلاغ
      }
    }

  //نستدعي الريبو عشان نرسل البيانات الى السيرفر 
    // نبني نوع البلاغ مع النوع الفرعي إن وُجد
    final String fullType = _selectedSubType != null && _selectedSubType!.isNotEmpty
        ? '$_selectedCategory - $_selectedSubType'
        : _selectedCategory;

    bool success = await _repository.sendNewReport(
      title: title,
      description: description.isEmpty ? "لا يوجد وصف" : description,
      type: fullType,
      priority: _selectedPriority,
      lat: lat,
      lng: lng,
      imageFile: _image, // imageFile is nullable in sendNewReport? Let's check!
    );

    _isUploading = false;
    notifyListeners();
  // في حال نجح ارسال البلاغ نستدعي دالة جلب البلاغات لاجل ان تتحدث قائمة بلاغاتي ويوضع فيها البلاغ الجديد
    if (success) {
      await fetchReportsFromLaravel(isRefresh: true);  
      String message = "تمت العملية بنجاح";
      ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "لا يوجد اتصال بالإنترنت حاليًا سيتم رفعه البلاغ عند توفر الشبكة.",
          ),
          backgroundColor: Colors.blueGrey, // لون هادئ يدل على الحفظ المحلي
          duration: Duration(seconds: 5),
        ),
      );
      // حتى لو فشل الإرسال للسيرفر، نقوم بتحديث القائمة لعرض البلاغ المخزن محلياً
      fetchReportsFromLaravel();
      Navigator.pop(context); // نغلق الصفحة لأن البلاغ "حُفظ" ولم يضع
    }
  }

  // خوارزمية Ray-Casting للتحقق مما إذا كانت النقطة داخل مضلع (Polygon) سيئون
  Future<bool> _isLocationInServiceArea(double lat, double lng) async {
    try {
      final String jsonString = await rootBundle.loadString('json/boundary_sayun.json');
      final Map<String, dynamic> geoJson = jsonDecode(jsonString);
      
      final List<dynamic> coordinates = geoJson['features'][0]['geometry']['coordinates'][0];
      
      bool isInside = false;
      int i, j = coordinates.length - 1;
      for (i = 0; i < coordinates.length; i++) {
        double polyLngI = coordinates[i][0];
        double polyLatI = coordinates[i][1];
        double polyLngJ = coordinates[j][0];
        double polyLatJ = coordinates[j][1];
        
        if (((polyLatI > lat) != (polyLatJ > lat)) &&
            (lng < (polyLngJ - polyLngI) * (lat - polyLatI) / (polyLatJ - polyLatI) + polyLngI)) {
          isInside = !isInside;
        }
        j = i;
      }
      return isInside;
    } catch (e) {
      debugPrint("Error checking boundary: \$e");
      // في حالة وجود خطأ في قراءة الملف، نسمح بمرور البلاغ لتجنب تعطيل التطبيق
      return true;
    }
  }
}