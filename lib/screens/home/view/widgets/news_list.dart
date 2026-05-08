import 'package:flutter/material.dart';
import 'package:seiyun_reports_app/core/theme/app_theme.dart';
import 'package:seiyun_reports_app/import.dart';
import 'package:seiyun_reports_app/screens/news_tips/viewmodel/news_tips_viewmodel.dart';

class NewsList extends StatelessWidget {
  const NewsList({super.key});

@override
Widget build(BuildContext context) {
  //للاستماع لبيانات الاخبار من السيرفر 
  return Consumer<NewsTipsViewModel>(
    builder: (context, viewModel, child) {
      //مؤشر تحميل لين تجي البيانات من السيرفر
      if (viewModel.isLoading) {
        return const Center(child: CircularProgressIndicator());
      }
   // ياخذ اول خبرين فقط 
      final newsOnly = viewModel.newsList.take(2).toList();
      if (newsOnly.isEmpty) {
        return const Center(child: Text("لا توجد أخبار جديدة حالياً"));
      }

      return Column(
        children: newsOnly.map((news) {
          return _newsItem(
            news.title,
            news.publishDate, 
            Icons.newspaper,
            context,
          );
        }).toList(),
      );
    },
  );
}

  Widget _newsItem(String title, String date, IconData icon, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppTheme.primaryBrown, size: 20),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                Text(
                  date,
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
