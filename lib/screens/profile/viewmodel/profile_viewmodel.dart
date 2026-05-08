import 'package:firebase_auth/firebase_auth.dart';
import 'package:seiyun_reports_app/core/utils/pref_helper.dart';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfileViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();

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

  ProfileViewModel() {
    _loadProfileData();
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
        _profileImage = File(pickedFile.path);
        await PrefHelper.saveProfileImagePath(pickedFile.path);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  Future<void> logout() async {
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
    notifyListeners();
  }

  Future<void> updateUserPhone(String phone) async {
    _userPhone = phone;
    await PrefHelper.saveUserPhone(phone);
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
