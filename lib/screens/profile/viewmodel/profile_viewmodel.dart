import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:seiyun_reports_app/core/utils/pref_helper.dart';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:seiyun_reports_app/core/services/location_service.dart';
import '../models/profile_model.dart';
import '../data/profile_repository.dart';

class ProfileViewModel extends ChangeNotifier {
  final ProfileRepository _repository;
  final LocationService _locationService;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();

  ProfileModel? _profile;
  ProfileModel? get profile => _profile;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  File? _profileImage;
  File? get profileImage => _profileImage;

  bool _notificationsEnabled = true;
  bool get notificationsEnabled => _notificationsEnabled;

  String? _userName;
  String? get userName => _userName;

  String? _userPhone;
  String? get userPhone => _userPhone;

  String? _userAddress;
  String? get userAddress => _userAddress;

  String? _userEmail;
  String? get userEmail => _userEmail;

  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  bool _isPhoneVerified = false;
  bool get isPhoneVerified => _isPhoneVerified;

  bool _isVerifying = false;
  bool get isVerifying => _isVerifying;

  bool _otpSent = false;
  bool get otpSent => _otpSent;

  String? _verificationId;
  String? _phoneErrorMessage;
  String? get phoneErrorMessage => _phoneErrorMessage;

  ProfileViewModel(this._repository, this._locationService) {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        _loadProfileData();
        fetchProfile();
      } else {
        _clearLocalState();
      }
    });
  }

  /// تصفير بيانات الحالة المحلية للمستخدم عند تسجيل الخروج
  void _clearLocalState() {
    _profile = null;
    _profileImage = null;
    _userName = null;
    _userPhone = null;
    _userAddress = null;
    _userEmail = null;
    _isPhoneVerified = false;
    _otpSent = false;
    _verificationId = null;
    notifyListeners();
  }

  /// جلب بيانات الملف الشخصي للمستخدم من المستودع وحفظها محلياً
  Future<void> fetchProfile() async {
    _isLoading = true;
    notifyListeners();

    try {
      _profile = await _repository.getProfile();
      if (_profile != null) {
        _userName = _profile!.fullName;
        _userPhone = _profile!.phone;
        
        String resolvedAddress = _profile!.areaName;
        if (resolvedAddress.isEmpty && _profile!.latitude != 0.0 && _profile!.longitude != 0.0) {
          resolvedAddress = _locationService.getAreaName(_profile!.latitude, _profile!.longitude);
        }
        _userAddress = resolvedAddress;
        _userEmail = _profile!.email;

        await PrefHelper.saveUserName(_profile!.fullName);
        await PrefHelper.saveUserPhone(_profile!.phone);
        await PrefHelper.saveUserEmail(_profile!.email);
        await PrefHelper.saveUserAddress(resolvedAddress);
        await PrefHelper.saveUserLocation(
          _profile!.latitude,
          _profile!.longitude,
        );
      }
    } catch (e) {
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// تحديث موقع المستخدم تلقائياً باستخدام نظام تحديد المواقع العالمي (GPS)
  Future<void> updateLocationAutomatically() async {
    _isLoading = true;
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

        final localAreaName = _locationService.getAreaName(position.latitude, position.longitude);

        try {
          final updatedProfile = await _repository.updateProfile(
            latitude: position.latitude,
            longitude: position.longitude,
          );
          if (updatedProfile != null) {
            _profile = updatedProfile;
            _userAddress = updatedProfile.areaName.isNotEmpty ? updatedProfile.areaName : localAreaName;
            await PrefHelper.saveUserAddress(_userAddress!);
            await PrefHelper.saveUserLocation(
              updatedProfile.latitude,
              updatedProfile.longitude,
            );
          } else {
            _userAddress = localAreaName;
            await PrefHelper.saveUserAddress(localAreaName);
            await PrefHelper.saveUserLocation(
              position.latitude,
              position.longitude,
            );
          }
        } catch (apiError) {
          _userAddress = localAreaName;
          await PrefHelper.saveUserAddress(localAreaName);
          await PrefHelper.saveUserLocation(
            position.latitude,
            position.longitude,
          );
        }
      }
    } catch (e) {
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// تحديث موقع المستخدم يدوياً بإحداثيات محددة
  Future<void> updateLocationManually(double lat, double lng) async {
    _isLoading = true;
    notifyListeners();

    final localAreaName = _locationService.getAreaName(lat, lng);

    try {
      final updatedProfile = await _repository.updateProfile(
        latitude: lat,
        longitude: lng,
      );
      if (updatedProfile != null) {
        _profile = updatedProfile;
        _userAddress = updatedProfile.areaName.isNotEmpty ? updatedProfile.areaName : localAreaName;
        await PrefHelper.saveUserAddress(_userAddress!);
        await PrefHelper.saveUserLocation(
          updatedProfile.latitude,
          updatedProfile.longitude,
        );
      } else {
        _userAddress = localAreaName;
        await PrefHelper.saveUserAddress(localAreaName);
        await PrefHelper.saveUserLocation(lat, lng);
      }
    } catch (e) {
      _userAddress = localAreaName;
      await PrefHelper.saveUserAddress(localAreaName);
      await PrefHelper.saveUserLocation(lat, lng);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// تحميل بيانات الملف الشخصي للمستخدم المخزنة محلياً
  Future<void> _loadProfileData() async {
    final String? path = await PrefHelper.getProfileImagePath();
    if (path != null && path.isNotEmpty) {
      final file = File(path);
      if (await file.exists()) {
        _profileImage = file;
      }
    }

    _notificationsEnabled = await PrefHelper.isNotificationsEnabled();
    _userName = await PrefHelper.getUserName();
    _userPhone = await PrefHelper.getUserPhone();
    _userEmail = await PrefHelper.getUserEmail();
    _userAddress = await PrefHelper.getUserAddress();
    _isDarkMode = await PrefHelper.isDarkMode();
    _isPhoneVerified = await PrefHelper.isPhoneVerified();

    notifyListeners();
  }


  /// إرسال رمز التحقق (OTP) إلى رقم الهاتف المحدد لتوثيقه
  Future<void> sendOTP(String phoneNumber) async {
    _isVerifying = true;
    _phoneErrorMessage = null;
    notifyListeners();

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
          _isPhoneVerified = true;
          await PrefHelper.savePhoneVerified(true);
          await PrefHelper.saveUserPhone(phoneNumber);
          _userPhone = phoneNumber;
          _isVerifying = false;
          notifyListeners();
        },
        verificationFailed: (FirebaseAuthException e) {
          _phoneErrorMessage = e.message ?? "فشل إرسال الرمز";
          _isVerifying = false;
          notifyListeners();
        },
        codeSent: (String verId, int? resendToken) {
          _verificationId = verId;
          _otpSent = true;
          _isVerifying = false;
          notifyListeners();
        },
        codeAutoRetrievalTimeout: (String verId) {
          _verificationId = verId;
        },
      );
    } catch (e) {
      _phoneErrorMessage = "خطأ غير متوقع";
      _isVerifying = false;
      notifyListeners();
    }
  }

  /// التحقق من رمز الـ OTP المدخل من قبل المستخدم
  Future<bool> verifyOTP(String smsCode) async {
    if (_verificationId == null) return false;

    _isVerifying = true;
    _phoneErrorMessage = null;
    notifyListeners();

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: smsCode,
      );

      await _auth.signInWithCredential(credential);
      _isPhoneVerified = true;
      _otpSent = false;
      await PrefHelper.savePhoneVerified(true);
      _isVerifying = false;
      notifyListeners();
      return true;
    } catch (e) {
      _phoneErrorMessage = "الرمز غير صحيح";
      _isVerifying = false;
      notifyListeners();
      return false;
    }
  }

  User? get currentUser => _auth.currentUser;

  /// اختيار صورة للملف الشخصي من المعرض أو الكاميرا ورفعها
  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );

      if (pickedFile != null) {
        final updatedProfile = await _repository.updateProfile(
          imagePath: pickedFile.path,
        );

        if (updatedProfile != null) {
          _profile = updatedProfile;
        }

        _profileImage = File(pickedFile.path);
        await PrefHelper.saveProfileImagePath(pickedFile.path);
        notifyListeners();
      }
    } catch (e) {
    }
  }

  /// تسجيل خروج المستخدم وتصفير كافة البيانات المحلية والحالة الحالية
  Future<void> logout() async {
    await PrefHelper.clear();
    await _auth.signOut();
    _clearLocalState();
  }

  /// تفعيل أو تعطيل تلقي التنبيهات
  Future<void> toggleNotifications(bool value) async {
    _notificationsEnabled = value;
    await PrefHelper.saveNotificationsEnabled(value);
    notifyListeners();
  }

  /// حفظ وتحديث تفاصيل الملف الشخصي للمستخدم (الاسم، الهاتف، العنوان)
  Future<void> saveProfileDetails({
    required String name,
    required String phone,
    required String address,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      _userName = name;
      _userPhone = phone;
      _userAddress = address;

      await PrefHelper.saveUserName(name);
      await PrefHelper.saveUserPhone(phone);
      await PrefHelper.saveUserAddress(address);

      final lat = _profile?.latitude ?? await PrefHelper.getUserLat();
      final lng = _profile?.longitude ?? await PrefHelper.getUserLng();

      final updatedProfile = await _repository.updateProfile(
        name: name,
        phone: phone,
        latitude: lat,
        longitude: lng,
      );

      if (updatedProfile != null) {
        _profile = updatedProfile;
      }
    } catch (e) {
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// تحديث اسم المستخدم في المستودع والمخزن المحلي
  Future<void> updateUserName(String name) async {
    _userName = name;
    await PrefHelper.saveUserName(name);

    final lat = _profile?.latitude ?? await PrefHelper.getUserLat();
    final lng = _profile?.longitude ?? await PrefHelper.getUserLng();

    final updatedProfile = await _repository.updateProfile(
      name: name,
      latitude: lat,
      longitude: lng,
    );
    if (updatedProfile != null) {
      _profile = updatedProfile;
    }
    notifyListeners();
  }

  /// تحديث رقم هاتف المستخدم في المستودع والمخزن المحلي
  Future<void> updateUserPhone(String phone) async {
    _userPhone = phone;
    await PrefHelper.saveUserPhone(phone);

    final lat = _profile?.latitude ?? await PrefHelper.getUserLat();
    final lng = _profile?.longitude ?? await PrefHelper.getUserLng();

    final updatedProfile = await _repository.updateProfile(
      phone: phone,
      latitude: lat,
      longitude: lng,
    );
    if (updatedProfile != null) {
      _profile = updatedProfile;
    }
    notifyListeners();
  }

  /// تحديث عنوان المستخدم في المخزن المحلي
  Future<void> updateUserAddress(String address) async {
    _userAddress = address;
    await PrefHelper.saveUserAddress(address);
    notifyListeners();
  }

  /// تحديث البريد الإلكتروني للمستخدم في المخزن المحلي
  Future<void> updateUserEmail(String email) async {
    _userEmail = email;
    await PrefHelper.saveUserEmail(email);

    notifyListeners();
  }

  /// التبديل بين الوضع المظلم والوضع المضيء للتطبيق
  Future<void> toggleTheme(bool value) async {
    _isDarkMode = value;
    await PrefHelper.saveDarkMode(value);
    notifyListeners();
  }
}
