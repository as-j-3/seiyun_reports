import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:seiyun_reports_app/screens/auth/data/auth_repository.dart';

/// كلاس إدارة حالة المصادقة (تسجيل الدخول، إنشاء حساب، تسجيل جوجل)
class AuthViewModel extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSignupMode = true; // وضع إنشاء حساب (true) أو تسجيل دخول (false)
  bool get isSignupMode => _isSignupMode;

  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthRepository _authRepo = AuthRepository();

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// التبديل بين واجهة تسجيل الدخول وإنشاء الحساب
  void toggleSignupMode() {
    _isSignupMode = !_isSignupMode;
    notifyListeners();
  }

  /// فرض وضع تسجيل الدخول
  void forceSignInMode() {
    _isSignupMode = false;
    notifyListeners();
  }

  /// مسح رسائل الخطأ الحالية
  void clearError() {
    _errorMessage = null;
  }

  /// معالجة المصادقة عبر البريد الإلكتروني وكلمة المرور
  Future<bool> handleEmailAuth({
    required String email,
    required String password,
    String? name,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (_isSignupMode) {
        // إنشاء حساب جديد في Firebase
        await _auth.createUserWithEmailAndPassword(
          email: email.trim(),
          password: password.trim(),
        );

        // تحديث اسم المستخدم إذا تم توفيره
        if (name != null && name.trim().isNotEmpty) {
          await _auth.currentUser?.updateDisplayName(name.trim());
          await _auth.currentUser?.reload();
        }
      } else {
        // تسجيل الدخول لحساب موجود
        await _auth.signInWithEmailAndPassword(
          email: email.trim(),
          password: password.trim(),
        );
      }

      final user = _auth.currentUser;
      if (user != null) {
<<<<<<< main
        // تسجيل المستخدم في قاعدة بيانات السيرفر الخاص بالتطبيق
        await _authRepo.registerUser(
          role: 'citizens',
          name: (name != null && name.trim().isNotEmpty)
              ? name.trim()
              : (user.displayName ?? "User"),
=======
        final token = await user.getIdToken();
        debugPrint("FIREBASE_TOKEN: $token");

        // تحديد الدور بناءً على الإيميل (إيميل سحري للمشرف)
        final String role = (user.email?.toLowerCase() == 'supervisor@app.com') ? 'supervisor' : 'citizens';

        await _authRepo.registerUser(
          role: role,
          name:
              (name != null && name.trim().isNotEmpty)
                  ? name.trim()
                  : (user.displayName ?? "User"),
>>>>>>> main
        );
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } on FirebaseAuthException catch (e) {
<<<<<<< main
      _errorMessage = e.message ?? "حدث خطأ غير متوقع في Firebase";
    } catch (e) {
      _errorMessage = "فشل الربط مع الخادم، يرجى المحاولة لاحقاً";
=======
      _errorMessage = e.message ?? "حدث خطأ في المصادقة";
    } catch (e) {
      _errorMessage = e.toString().contains("Exception:") 
          ? e.toString().replaceAll("Exception: ", "") 
          : "فشل الربط مع الخادم: $e";
>>>>>>> main
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// معالجة تسجيل الدخول عبر حساب Google
  Future<bool> handleGoogleSignIn() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _googleSignIn.signOut(); // تسجيل خروج مسبق لضمان اختيار الحساب
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // تسجيل الدخول في Firebase باستخدام بيانات جوجل
      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        final finalName = user.displayName ??
            (user.email != null ? user.email!.split('@')[0] : "User");

<<<<<<< main
        // تسجيل المستخدم في قاعدة بيانات السيرفر
        await _authRepo.registerUser(role: 'citizens', name: finalName);
=======
        // تحديد الدور بناءً على الإيميل (إيميل سحري للمشرف)
        final String role = (user.email?.toLowerCase() == 'supervisor@app.com') ? 'supervisor' : 'citizens';

        await _authRepo.registerUser(role: role, name: finalName);
>>>>>>> main
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _errorMessage = "فشل تسجيل الدخول بواسطة Google";
      debugPrint("Google SignIn Error: $e");
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }
}

