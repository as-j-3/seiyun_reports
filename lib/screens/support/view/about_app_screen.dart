import 'package:flutter/material.dart';
import 'package:seiyun_reports_app/core/theme/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  Future<void> _launchURL(BuildContext context, String url) async {
    final Uri uri = Uri.parse(url);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('عذراً، لم يتم العثور على تطبيق لفتح هذا الرابط'),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('حدث خطأ أثناء محاولة فتح الرابط')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text("حول التطبيق"), centerTitle: true),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Logo
              Container(
                height: 120,
                width: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Image.asset('assets/google.png', fit: BoxFit.contain),
                ),
              ),
              const SizedBox(height: 25),
              const Text(
                "بلاغات سيئون",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              const Text(
                "الإصدار 1.0.0",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 40),
              const Text(
                "تطبيق بلاغات سيئون هو منصة تقنية تهدف إلى تعزيز التواصل بين المواطنين والجهات الخدمية في مدينة سيئون (صندوق النظافة والتحسين)، للمساهمة في بيئة أنظف ومدينة أجمل.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, height: 1.8),
              ),
              const SizedBox(height: 50),
              _buildLinkItem(
                context,
                Icons.privacy_tip_outlined,
                "سياسة الخصوصية",
                () => _launchURL(context, "https://sayun-reports.com/privacy"),
              ),
              _buildLinkItem(
                context,
                Icons.description_outlined,
                "شروط الاستخدام",
                () => _launchURL(context, "https://sayun-reports.com/terms"),
              ),
              _buildLinkItem(
                context,
                Icons.language_outlined,
                "الموقع الإلكتروني",
                () => _launchURL(context, "https://sayun-reports.com"),
              ),
              const SizedBox(height: 60),
              const Text(
                "© 2026 جميع الحقوق محفوظة لمدينة سيئون",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLinkItem(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.withOpacity(0.05)),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primaryColor, size: 22),
        title: Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 14,
          color: Colors.grey,
        ),
        onTap: onTap,
      ),
    );
  }
}
