import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seiyun_reports_app/screens/root/view/root_screen.dart';
import 'package:seiyun_reports_app/screens/auth/viewmodel/auth_viewmodel.dart';
import 'auth_text_field.dart';
import 'auth_button.dart';
import 'google_signin_button.dart';
import 'package:seiyun_reports_app/core/theme/app_theme.dart';

class AuthForm extends StatefulWidget {
  const AuthForm({super.key});

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _showErrorSnackBar(String message, [ScaffoldMessengerState? messenger]) {
    (messenger ?? ScaffoldMessenger.of(context)).showSnackBar(
      SnackBar(
        backgroundColor: AppTheme.errorColor,
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  bool _validateInputs(AuthViewModel authVM) {
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      _showErrorSnackBar("يرجى إدخال البريد الإلكتروني وكلمة المرور");
      return false;
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(_emailController.text.trim())) {
      _showErrorSnackBar("يرجى إدخال بريد إلكتروني صحيح");
      return false;
    }

    if (authVM.isSignupMode && _nameController.text.trim().isEmpty) {
      _showErrorSnackBar("يرجى إدخال الاسم الكامل");
      return false;
    }

    return true;
  }

  Future<void> _handleEmailAuth() async {
    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    if (!_validateInputs(authVM)) return;

    final success = await authVM.handleEmailAuth(
      email: _emailController.text,
      password: _passwordController.text,
      name: authVM.isSignupMode ? _nameController.text : null,
    );

    if (!mounted) return;

    if (success) {
      navigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const RootScreen()),
        (route) => false,
      );
    } else {
      if (authVM.errorMessage != null) {
        _showErrorSnackBar(authVM.errorMessage!, scaffoldMessenger);
        authVM.clearError();
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final success = await authVM.handleGoogleSignIn();

    if (!mounted) return;

    if (success) {
      navigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const RootScreen()),
        (route) => false,
      );
    } else {
      if (authVM.errorMessage != null) {
        _showErrorSnackBar(authVM.errorMessage!, scaffoldMessenger);
        authVM.clearError();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authVM = Provider.of<AuthViewModel>(context);

    return SingleChildScrollView(
      child: Column(
        children: [
          const Icon(
            Icons.forest_rounded,
            color: AppTheme.accentGreen,
            size: 40,
          ),
          const SizedBox(height: 10),
          Text(
            authVM.isSignupMode ? 'إنشاء حساب جديد' : 'مرحباً بك مجدداً',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 30),
          if (authVM.isSignupMode) ...[
            AuthTextField(
              label: "الاسم الكامل",
              hint: "أدخل اسمك بالكامل",
              controller: _nameController,
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 20),
          ],
          AuthTextField(
            label: "البريد الإلكتروني",
            hint: "example@mail.com",
            controller: _emailController,
            icon: Icons.email_outlined,
          ),
          const SizedBox(height: 20),
          AuthTextField(
            label: "كلمة المرور",
            hint: "********",
            controller: _passwordController,
            isPassword: true,
            icon: Icons.lock_outline,
          ),
          const SizedBox(height: 30),
          AuthButton(
            text: authVM.isSignupMode ? 'إنشاء حساب' : 'تسجيل الدخول',
            onPressed: _handleEmailAuth,
          ),
          const SizedBox(height: 25),
          GoogleSignInButton(
            text:
                authVM.isSignupMode
                    ? "تسجيل بواسطة Google"
                    : "الدخول بواسطة Google",
            onTap: _handleGoogleSignIn,
          ),
          const SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                authVM.isSignupMode
                    ? "لديك حساب بالفعل؟ "
                    : "ليس لديك حساب؟ ",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              GestureDetector(
                onTap: () {
                  authVM.toggleSignupMode();
                },
                child: Text(
                  authVM.isSignupMode ? "تسجيل الدخول" : "إنشاء حساب",
                  style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (!authVM.isSignupMode)
            TextButton(
              onPressed: () {},
              child: Text(
                "نسيت كلمة المرور؟",
                style: TextStyle(color: Theme.of(context).colorScheme.secondary),
              ),
            ),
        ],
      ),
    );
  }
}
