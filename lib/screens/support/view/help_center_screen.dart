import 'package:flutter/material.dart';
import 'package:seiyun_reports_app/core/theme/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  Future<void> _launchEmail(BuildContext context) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'projectg25ar@gmail.com',
      query: Uri.encodeFull('subject=طلب دعم فني - تطبيق بلاغات سيئون'),
    );

    try {
      final bool launched = await launchUrl(
        emailLaunchUri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'عذراً، لم يتم العثور على تطبيق بريد إلكتروني على الجهاز',
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint("Email Launch Error: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'عذراً، لا يمكن فتح البريد الإلكتروني على هذا الجهاز',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text("مركز المساعدة")),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              "كيف يمكننا مساعدتك؟",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildFAQItem(
              context,
              "كيف يمكنني تقديم بلاغ جديد؟",
              "يمكنك تقديم بلاغ جديد بالضغط على زر (+) في الشاشة الرئيسية، ثم اختيار نوع البلاغ وإرفاق الصورة وتحديد الموقع.",
            ),
            _buildFAQItem(
              context,
              "كيف أعرف موعد رفع النفايات في منطقتي؟",
              "تظهر المواعيد والحاويات القريبة بناءً على 'موقعك المحفوظ' في ملفك الشخصي. تأكد من تحديد موقع منزلك بدقة في الإعدادات لتصلك أدق البيانات لمنطقتك.",
            ),
            _buildFAQItem(
              context,
              "هل يحتاج التطبيق إلى إنترنت طوال الوقت؟",
              "التطبيق يدعم العمل بدون إنترنت للعرض، حيث يتم تخزين آخر البيانات محلياً، ولكن تقديم البلاغات الجديدة يتطلب اتصالاً بالإنترنت.",
            ),
            _buildFAQItem(
              context,
              "من هم القائمون على التطبيق؟",
              "هذا التطبيق مبادرة لتحسين الخدمات في مدينة سيئون وتسهيل التواصل بين المواطنين وصندوق النظافة.",
            ),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.contact_support_outlined,
                    size: 40,
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    "لم تجد إجابة لسؤالك؟",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    "فريق الدعم الفني متواجد لمساعدتك في أي وقت",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => _launchEmail(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("تواصل معنا الآن"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem(BuildContext context, String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        childrenPadding: const EdgeInsets.all(15),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            answer,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
