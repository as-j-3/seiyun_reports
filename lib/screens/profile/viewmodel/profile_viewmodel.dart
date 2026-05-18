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
    _loadProfileData();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    _isLoading = true;
    notifyListeners();

    try {
      _profile = await _repository.getProfile();
      if (_profile != null) {
        _userName = _profile!.fullName;
        _userPhone = _profile!.phone;
        _userAddress = _profile!.areaName;
        
        await PrefHelper.saveUserName(_profile!.fullName);
        await PrefHelper.saveUserPhone(_profile!.phone);
        await PrefHelper.saveUserAddress(_profile!.areaName);
        await PrefHelper.saveUserLocation(_profile!.latitude, _profile!.longitude);
      }
    } catch (e) {
      debugPrint("Error fetching profile: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

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
          desiredAccuracy: LocationAccuracy.high
        );
        
        // جلب اسم المنطقة محلياً في حالة فشل الاتصال بالإنترنت
        final localAreaName = await _locationService.getCurrentAreaName();
        
        try {
          final updatedProfile = await _repository.updateProfile(
            latitude: position.latitude,
            longitude: position.longitude,
          );
          if (updatedProfile != null) {
            _profile = updatedProfile;
            _userAddress = updatedProfile.areaName;
            await PrefHelper.saveUserAddress(updatedProfile.areaName);
            await PrefHelper.saveUserLocation(updatedProfile.latitude, updatedProfile.longitude);
          }
        } catch (apiError) {
          debugPrint("API update failed, using local area name: $apiError");
          _userAddress = localAreaName;
          await PrefHelper.saveUserAddress(localAreaName);
          await PrefHelper.saveUserLocation(position.latitude, position.longitude);
        }
      }
    } catch (e) {
      debugPrint("Error updating location automatically: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateLocationManually(double lat, double lng) async {
    _isLoading = true;
    notifyListeners();

    try {
      final updatedProfile = await _repository.updateProfile(
        latitude: lat,
        longitude: lng,
      );
      if (updatedProfile != null) {
        _profile = updatedProfile;
        _userAddress = updatedProfile.areaName;
        await PrefHelper.saveUserAddress(updatedProfile.areaName);
        await PrefHelper.saveUserLocation(updatedProfile.latitude, updatedProfile.longitude);
      }
    } catch (e) {
      debugPrint("Error updating location manually: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

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
    _userAddress = await PrefHelper.getUserAddress();
    _isDarkMode = await PrefHelper.isDarkMode();
    _isPhoneVerified = await PrefHelper.isPhoneVerified();

    notifyListeners();
  }

  // --- Phone Verification Logic ---

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

  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );

      if (pickedFile != null) {
        // تحديث الصورة في السيرفر أيضاً
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
      debugPrint('Error picking image: $e');
    }
  }

  Future<void> logout() async {
    await PrefHelper.clear();
    await _auth.signOut();
    notifyListeners();
  }

  Future<void> toggleNotifications(bool value) async {
    _notificationsEnabled = value;
    await PrefHelper.saveNotificationsEnabled(value);
    notifyListeners();
  }

  Future<void> updateUserName(String name) async {
    _userName = name;
    await PrefHelper.saveUserName(name);
    
    // تحديث في السيرفر
    await _repository.updateProfile(name: name);
    notifyListeners();
  }

  Future<void> updateUserPhone(String phone) async {
    _userPhone = phone;
    await PrefHelper.saveUserPhone(phone);
    
    // تحديث في السيرفر
    await _repository.updateProfile(phone: phone);
    notifyListeners();
  }

  Future<void> updateUserAddress(String address) async {
    _userAddress = address;
    await PrefHelper.saveUserAddress(address);
    notifyListeners();
  }

  Future<void> toggleTheme(bool value) async {
    _isDarkMode = value;
    await PrefHelper.saveDarkMode(value);
    notifyListeners();
  }
}
