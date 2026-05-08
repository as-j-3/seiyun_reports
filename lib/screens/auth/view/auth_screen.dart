import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seiyun_reports_app/screens/auth/viewmodel/auth_viewmodel.dart';
import 'package:seiyun_reports_app/core/theme/app_theme.dart';
import 'widgets/auth_form.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final authVM = Provider.of<AuthViewModel>(context);

    return Scaffold(
      body: Stack(
        children: [
          /// خلفية الشاشة
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.darkGreen, Colors.green],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          /// زر الرجوع في حالة تسجيل الدخول
          if (!authVM.isSignupMode)
            Positioned(
              top: 50,
              left: 20,
              child: TextButton.icon(
                onPressed: () {
                  authVM.toggleSignupMode();
                },
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                  size: 18,
                ),
                label: const Text(
                  "Back",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),

          /// واجهة الإدخال
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: screenHeight * 0.8,
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  const AuthForm(),
                  if (authVM.isLoading)
                    Container(
                      color: Theme.of(context).cardColor.withValues(alpha: 0.7),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
