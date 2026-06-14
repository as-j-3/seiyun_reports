import 'package:flutter/material.dart';
import 'package:seiyun_reports_app/core/theme/app_theme.dart';
import 'package:seiyun_reports_app/screens/support/view/header.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

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
            const SupportHeader(title: "حول التطبيق"),
            
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    
                    Container(
                      height: 110,
                      width: 110,
                      decoration: BoxDecoration(
                        color: theme.cardColor, 
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: isDarkMode 
                                ? Colors.black.withOpacity(0.3) 
                                : AppTheme.primaryColor.withOpacity(0.08),
                            blurRadius: 24,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.asset(
                            'assets/images/app_logo.jpeg',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    const Text(
                      "بلاغاتي",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 13),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        "الإصدار 1.0.0",
                        style: TextStyle(
                          fontSize: 12, 
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w600
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 35),
                    
                    _buildSectionCard(
                      context,
                      icon: Icons.info_outline,
                      iconColor: AppTheme.primaryColor,
                      title: "عن المنصة",
                      content: "تطبيق بلاغات سيئون هو منصة تقنية متطورة تهدف إلى تعزيز التواصل المباشر بين المواطنين والجهات الخدمية في مدينة سيئون (صندوق النظافة والتحسين)، لتسهيل رفع البلاغات ومتابعتها والمساهمة معاً في بناء بيئة أنظف ومدينة أجمل.",
                    ),
                    
                    const SizedBox(height: 16),
                    
                    _buildSectionCard(
                      context,
                      icon: Icons.emoji_objects_outlined,
                      iconColor: Colors.orange[700]!,
                      title: "رؤيتنا",
                      content: "الارتقاء بمستوى الخدمات العامة في المدينة من خلال التحول الرقمي، وإشراك المجتمع بشكل فعال وسريع في رصد وتحسين المظهر الحضاري لمدينة سيئون.",
                    ),
                    
                    const SizedBox(height: 40),
                    
                    Text(
                      "© 2026 جميع الحقوق محفوظة لمدينة سيئون",
                      style: TextStyle(
                        fontSize: 12, 
                        color: theme.textTheme.bodySmall?.color ?? Colors.grey,
                        fontWeight: FontWeight.w500
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String content,
  }) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor, 
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.dividerColor.withOpacity(0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(theme.brightness == Brightness.dark ? 0.2 : 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 22),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.titleMedium?.color, 
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Divider(
              color: theme.dividerColor.withOpacity(0.4), 
              height: 1,
            ),
          ),
          Text(
            content,
            style: TextStyle(
              fontSize: 13.5,
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.85), 
              height: 1.7,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}