import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seiyun_reports_app/screens/report/viewmodel/report_viewmodel.dart';
import 'package:seiyun_reports_app/core/theme/app_theme.dart';

class CategoryGrid extends StatelessWidget {
  const CategoryGrid({super.key});

  static const List<Map<String, dynamic>> categories = [
    {
      'id': 'تراكم_نفايات',
      'label': 'تراكم نفايات',
      'subtitle': 'حاويات وتجمعات النفايات',
      'icon': Icons.delete_outline_rounded,
      'color': Color(0xFF27ae60),
      'gradient': [Color(0xFF27ae60), Color(0xFF1e8449)],
      'bg': Color(0xFFe8f5e9),
      'subTypes': ['حاوية ممتلئة', 'نفايات خارج الحاوية', 'مخلفات أشجار'],
    },
    {
      'id': 'نظافة_شوارع',
      'label': 'نظافة الشوارع',
      'subtitle': 'الكنس والتنظيف الميداني',
      'icon': Icons.cleaning_services_rounded,
      'color': Color(0xFF2980b9),
      'gradient': [Color(0xFF2980b9), Color(0xFF1a6090)],
      'bg': Color(0xFFebf5fb),
      'subTypes': ['أتربة متراكمة', 'زجاج مكسور', 'مخلفات بناء على الطريق'],
    },
    {
      'id': 'تشوه_بصري',
      'label': 'التشوه البصري',
      'subtitle': 'المظهر العام للمدينة',
      'icon': Icons.visibility_rounded,
      'color': Color(0xFF8e44ad),
      'gradient': [Color(0xFF8e44ad), Color(0xFF6c3483)],
      'bg': Color(0xFFf5eef8),
      'subTypes': ['لوحات متهالكة', 'كتابات جدارية', 'عوائق بصرية'],
    },
    {
      'id': 'أخرى',
      'label': 'أخرى',
      'subtitle': 'بلاغات متنوعة',
      'icon': Icons.help_outline_rounded,
      'color': Color(0xFF7f8c8d),
      'gradient': [Color(0xFF95a5a6), Color(0xFF7f8c8d)],
      'bg': Color(0xFFf4f6f7),
      'subTypes': <String>[],
    },
  ];

  @override
  Widget build(BuildContext context) {
    final reportVM = context.watch<ReportViewModel>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.25, 
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              final bool isSelected = reportVM.selectedCategory == cat['id'];
              final Color catColor = cat['color'] as Color;
              final List<Color> gradColors = List<Color>.from(cat['gradient'] as List);

              return GestureDetector(
                onTap: () {
                  reportVM.setCategory(cat['id'] as String);
                  reportVM.setSubType(null);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeInOut,
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(
                            colors: gradColors,
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                          )
                        : null,
                    color: isSelected ? null : Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? Colors.transparent
                          : catColor.withOpacity(0.25),
                      width: 1.5,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: catColor.withOpacity(0.35),
                              blurRadius: 14,
                              offset: const Offset(0, 6),
                            ),
                          ]
                        : [
                            BoxShadow(
                              color: Colors.black.withOpacity(isDark ? 0.15 : 0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white.withOpacity(0.2)
                              : (cat['bg'] as Color).withOpacity(isDark ? 0.2 : 1.0),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          cat['icon'] as IconData,
                          color: isSelected ? Colors.white : catColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              cat['label'] as String,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                                color: isSelected
                                    ? Colors.white
                                    : Theme.of(context).textTheme.titleMedium?.color,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.visible,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              cat['subtitle'] as String,
                              style: TextStyle(
                                fontSize: 10.5,
                                height: 1.2,
                                color: isSelected
                                    ? Colors.white.withOpacity(0.8)
                                    : Colors.grey[500],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.visible,
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        const Icon(Icons.check_circle_rounded,
                            color: Colors.white, size: 18),
                    ],
                  ),
                ),
              );
            },
          ),

          Builder(builder: (context) {
            final selectedCat = categories.firstWhere(
              (c) => c['id'] == reportVM.selectedCategory,
              orElse: () => {},
            );

            final subTypes = selectedCat.isNotEmpty
                ? (selectedCat['subTypes'] as List<String>)
                : <String>[];

            if (subTypes.isEmpty) return const SizedBox.shrink();

            final Color catColor = selectedCat['color'] as Color;

            return AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              child: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 20,
                          decoration: BoxDecoration(
                            color: catColor,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'حدد نوع المشكلة',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textTheme.titleMedium?.color,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: catColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'مطلوب',
                            style: TextStyle(
                              fontSize: 10,
                              color: catColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ...subTypes.map((sub) {
                      final isSubSelected = reportVM.selectedSubType == sub;
                      return GestureDetector(
                        onTap: () => reportVM.setSubType(sub),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSubSelected
                                ? catColor.withOpacity(0.08)
                                : Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSubSelected ? catColor : Colors.grey.withOpacity(0.2),
                              width: isSubSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSubSelected ? catColor : Colors.grey[400]!,
                                    width: 2,
                                  ),
                                  color: isSubSelected ? catColor : Colors.transparent,
                                ),
                                child: isSubSelected
                                    ? const Icon(Icons.check,
                                        color: Colors.white, size: 12)
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                sub,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: isSubSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isSubSelected
                                      ? catColor
                                      : Theme.of(context).textTheme.bodyMedium?.color,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
