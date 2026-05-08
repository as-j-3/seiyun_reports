import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seiyun_reports_app/screens/profile/viewmodel/profile_viewmodel.dart';
import 'package:seiyun_reports_app/core/theme/app_theme.dart';
import 'package:seiyun_reports_app/screens/profile/view/widgets/profile_header.dart';
import 'package:seiyun_reports_app/screens/profile/view/widgets/rewards_card.dart';
import 'package:seiyun_reports_app/screens/profile/view/widgets/settings_item.dart';
import 'package:seiyun_reports_app/screens/profile/view/widgets/logout_button.dart';
import 'package:seiyun_reports_app/screens/my_reports/view/my_reports_page.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ProfileViewModel>(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: ListView(
          padding: EdgeInsets.zero,
          children: [
            ProfileHeader(viewModel: viewModel),
            const SizedBox(height: 80),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const RewardsCard(),
                  const SizedBox(height: 30),
                  const _SectionTitle(title: "نشاطاتي"),
                  const SizedBox(height: 15),
                  SettingsItem(
                    icon: Icons.assignment_outlined,
                    title: "بلاغاتي",
                    subtitle: "عرض ومتابعة البلاغات التي قمت برفعها",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MyReportsPage(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 25),
                  const _SectionTitle(title: "الإعدادات العامة"),
                  const SizedBox(height: 15),
                  SettingsItem(
                    icon: Icons.phone_android_outlined,
                    title: "رقم الهاتف",
                    subtitle: viewModel.isPhoneVerified 
                      ? (viewModel.userPhone ?? "تم التحقق") 
                      : "لم يتم التحقق - اضغط للتحقق الآن",
                    trailing: Icon(
                      viewModel.isPhoneVerified ? Icons.verified : Icons.error_outline,
                      color: viewModel.isPhoneVerified ? Colors.green : Colors.orange,
                    ),
                    onTap: () => _showPhoneVerificationDialog(context, viewModel),
                  ),
                  SettingsItem(
                    icon: Icons.notifications_active_outlined,
                    title: "تنبيهات التطبيق",
                    subtitle: "تلقي تحديثات حول البلاغات الجديدة",
                    trailing: Switch.adaptive(
                      value: viewModel.notificationsEnabled,
                      onChanged: (v) => viewModel.toggleNotifications(v),
                      activeColor: AppTheme.primaryColor,
                    ),
                    onTap: () {},
                  ),
                  SettingsItem(
                    icon: Icons.language_outlined,
                    title: "لغة التطبيق",
                    subtitle: "العربية (اليمن)",
                    onTap: () {},
                  ),
                  SettingsItem(
                    icon: Icons.dark_mode_outlined,
                    title: "الوضع الليلي",
                    subtitle: "تفعيل السمات الداكنة",
                    trailing: Switch.adaptive(
                      value: viewModel.isDarkMode,
                      onChanged: (v) => viewModel.toggleTheme(v),
                    ),
                    onTap: () {},
                  ),
                  const SizedBox(height: 25),
                  const _SectionTitle(title: "الدعم والمساعدة"),
                  const SizedBox(height: 15),
                  SettingsItem(
                    icon: Icons.help_outline,
                    title: "مركز المساعدة",
                    subtitle: "الأسئلة الشائعة وطرق الاستخدام",
                    onTap: () {},
                  ),
                  SettingsItem(
                    icon: Icons.info_outline,
                    title: "حول التطبيق",
                    subtitle: "معلومات الإصدار وسياسة الخصوصية",
                    onTap: () {},
                  ),
                  const SizedBox(height: 30),
                  LogoutButton(viewModel: viewModel),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPhoneVerificationDialog(BuildContext context, ProfileViewModel viewModel) {
    if (viewModel.isPhoneVerified) return;

    final phoneController = TextEditingController();
    final otpController = TextEditingController();
    bool otpSent = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("التحقق من رقم الهاتف", textAlign: TextAlign.center),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!otpSent) ...[
                const Text("سيتم إرسال رمز تحقق عبر الرسائل القصيرة", textAlign: TextAlign.center, style: TextStyle(fontSize: 13)),
                const SizedBox(height: 15),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: "77xxxxxxx",
                    prefixText: "+967 ",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                ),
              ] else ...[
                const Text("أدخل الرمز المكون من 6 أرقام", textAlign: TextAlign.center),
                const SizedBox(height: 15),
                TextField(
                  controller: otpController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: "000000",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                ),
              ],
              if (viewModel.phoneErrorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(viewModel.phoneErrorMessage!, style: const TextStyle(color: Colors.red, fontSize: 12)),
                ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("إلغاء")),
            ElevatedButton(
              onPressed: viewModel.isVerifying ? null : () async {
                if (!otpSent) {
                  if (phoneController.text.length < 9) return;
                  await viewModel.sendOTP("+967${phoneController.text}");
                  setDialogState(() => otpSent = true);
                } else {
                  final success = await viewModel.verifyOTP(otpController.text);
                  if (success) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("تم التحقق بنجاح")));
                  } else {
                    setDialogState(() {}); // Refresh error message
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: viewModel.isVerifying 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text(otpSent ? "تأكيد" : "إرسال الرمز", style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).textTheme.titleMedium?.color,
      ),
    );
  }
}
