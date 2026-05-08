import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seiyun_reports_app/screens/auth/viewmodel/auth_viewmodel.dart';
import 'package:seiyun_reports_app/core/utils/pref_helper.dart';
import 'package:seiyun_reports_app/screens/home/view/home_screen.dart';
import 'package:seiyun_reports_app/screens/supervisor/view/supervisor_main_screen.dart';
import 'package:seiyun_reports_app/core/theme/app_theme.dart';

class RootScreen extends StatefulWidget {
  const RootScreen({Key? key}) : super(key: key);

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  String? _userRole;
  bool _isLoading = true;
  AuthViewModel? _authVM;

  @override
  void initState() {
    super.initState();
    
    // Listen to AuthViewModel. If it finishes a network call, reload the role.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkRole();
      if (mounted) {
        _authVM = Provider.of<AuthViewModel>(context, listen: false);
        _authVM?.addListener(_onAuthChange);
      }
    });
  }

  void _onAuthChange() {
    if (_authVM != null && !_authVM!.isLoading) {
      _checkRole();
    }
  }

  @override
  void dispose() {
    _authVM?.removeListener(_onAuthChange);
    super.dispose();
  }

  Future<void> _checkRole() async {
    final role = await PrefHelper.getRole();
    if (mounted) {
      setState(() {
        _userRole = role;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // If AuthViewModel is currently loading (e.g. backend registerUser is in progress),
    // we should show the loading indicator instead of resolving the screen yet.
    final authVM = Provider.of<AuthViewModel>(context);
    
    if (_isLoading || authVM.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: AppTheme.primaryColor,
          ),
        ),
      );
    }

    if (_userRole == 'supervisor') {
      return const SupervisorMainScreen();
    } else {
      // Default to citizens / normal users
      return HomeScreen();
    }
  }
}
