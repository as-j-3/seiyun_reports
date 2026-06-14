import 'package:flutter/material.dart';
import 'package:seiyun_reports_app/core/theme/app_theme.dart';
import 'package:seiyun_reports_app/screens/support/view/header.dart';
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
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Column(
          children: [
            const SupportHeader(title: "مركز المساعدة"),
            
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                children: [
                  Text(
                    "كيف يمكننا مساعدتك؟",
                    style: TextStyle(
                      fontSize: 20, 
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.titleLarge?.color, 
                    ),
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
                    "هل يحتاج التطبيق إلى إنترنت طوال الوقت？",
                    "التطبيق يدعم العمل بدون إنترنت للعرض، حيث يتم تخزين آخر البيانات محلياً، ولكن تقديم البلاغات الجديدة يتطلب اتصالاً بالإنترنت.",
                  ),
                  _buildFAQItem(
                    context,
                    "من هم القائمون على التطبيق؟",
                    "هذا التطبيق مبادرة لتحسين الخدمات في مدينة سيئون وتسهيل التواصل بين المواطنين وصندوق النظافة.",
                  ),
                  const SizedBox(height: 35),
                  
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.12), 
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.primaryColor.withOpacity(0.15)),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.contact_support_outlined,
                          size: 40,
                          color: AppTheme.primaryColor,
                        ),
                        const SizedBox(height: 15),
                        Text(
                          "لم تجد إجابة لسؤالك؟",
                          style: TextStyle(
                            fontWeight: FontWeight.bold, 
                            fontSize: 16,
                            color: theme.textTheme.titleMedium?.color, 
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "فريق الدعم الفني متواجد لمساعدتك في أي وقت",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13, 
                            color: theme.textTheme.bodySmall?.color ?? Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () => _launchEmail(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 50),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            "تواصل معنا الآن",
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
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
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: theme.cardColor, 
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.01),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: theme.dividerColor.withOpacity(0.08)),
      ),
      child: ExpansionTile(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
        collapsedShape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
        iconColor: AppTheme.primaryColor,
        collapsedIconColor: theme.hintColor,
        title: Text(
          question,
          style: TextStyle(
            fontSize: 14.5, 
            fontWeight: FontWeight.w700, 
            color: theme.textTheme.titleMedium?.color, 
          ),
        ),
        childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 4),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            answer,
            style: TextStyle(
              fontSize: 13.5,
              height: 1.6,
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.85), 
            ),
          ),
        ],
      ),
    );
  }
}