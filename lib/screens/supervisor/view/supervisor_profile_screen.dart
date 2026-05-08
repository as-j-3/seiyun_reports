import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:seiyun_reports_app/core/theme/app_theme.dart';
import 'package:seiyun_reports_app/core/utils/pref_helper.dart';
import 'package:seiyun_reports_app/screens/auth/view/auth_screen.dart';

class SupervisorProfileScreen extends StatefulWidget {
  const SupervisorProfileScreen({Key? key}) : super(key: key);

  @override
  State<SupervisorProfileScreen> createState() => _SupervisorProfileScreenState();
}

class _SupervisorProfileScreenState extends State<SupervisorProfileScreen> {
  String? _userName;
  String? _userRole;
  String? _qrData;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfileData();
    });
  }

  Future<void> _loadProfileData() async {
    final name = await PrefHelper.getUserName() ?? FirebaseAuth.instance.currentUser?.displayName ?? "مشرف ميداني";
    final role = await PrefHelper.getRole();

    if (mounted) {
      setState(() {
        _userName = name;
        _userRole = role;
        _qrData = name; // الباركود يمثل اسم المشرف كما طلب المستخدم
      });
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    await PrefHelper.clear();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AuthScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(isDark),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  _buildStatsRow(isDark),
                  const SizedBox(height: 40),
                  Text(
                    'باركود التحضير الرقمي',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'استخدم هذا الكود لتسجيل الحضور اليومي',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 25),
                  _buildQRCodeCard(isDark),
                  const SizedBox(height: 30),
                  _buildLogoutButton(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      padding: const EdgeInsets.only(top: 70, bottom: 40, left: 20, right: 20),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const CircleAvatar(
                  radius: 55,
                  backgroundColor: Color(0xFFE8F5E9),
                  child: Icon(CupertinoIcons.person_fill, size: 60, color: Color(0xFF2E7D32)),
                ),
              ),
              Positioned(
                bottom: 5,
                right: 5,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Color(0xFF2ECC71),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            _userName ?? 'جاري التحميل...',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Text(
              'مشرف ميداني معتمد',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(bool isDark) {
    return Row(
      children: [
        _buildStatCard('المهام اليومية', '12', CupertinoIcons.doc_text, Colors.blue, isDark),
        const SizedBox(width: 15),
        _buildStatCard('تم إنجازها', '08', CupertinoIcons.check_mark_circled, Colors.green, isDark),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQRCodeCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: _qrData != null
          ? QrImageView(
              data: _qrData!,
              version: QrVersions.auto,
              size: 180.0,
              gapless: false,
              eyeStyle: const QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: Color(0xFF1B5E20),
              ),
              dataModuleStyle: const QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: Colors.black,
              ),
            )
          : const SizedBox(
              height: 180,
              width: 180,
              child: Center(child: CircularProgressIndicator()),
            ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: TextButton.icon(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('تسجيل الخروج'),
              content: const Text('هل أنت متأكد أنك تريد تسجيل الخروج من حساب المشرف؟'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('إلغاء'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _logout();
                  },
                  child: const Text('تسجيل خروج', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          );
        },
        icon: const Icon(CupertinoIcons.power, color: Colors.red),
        label: const Text('تسجيل الخروج', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }
}
