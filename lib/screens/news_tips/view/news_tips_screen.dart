import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seiyun_reports_app/screens/news_tips/view/widgets/news_tips_header.dart';
import 'package:seiyun_reports_app/screens/news_tips/view/widgets/news_section_header.dart';
import 'package:seiyun_reports_app/screens/news_tips/view/widgets/news_card.dart';
import 'package:seiyun_reports_app/screens/news_tips/view/widgets/tip_item.dart';
import 'package:seiyun_reports_app/screens/news_tips/view/widgets/call_to_action_card.dart';
import 'package:seiyun_reports_app/screens/news_tips/viewmodel/news_tips_viewmodel.dart';

class NewsTipsScreen extends StatefulWidget {
  const NewsTipsScreen({super.key});

  @override
  State<NewsTipsScreen> createState() => _NewsTipsScreenState();
}

class _NewsTipsScreenState extends State<NewsTipsScreen> {
  bool isNewsSelected = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NewsTipsViewModel>().loadContent();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<NewsTipsViewModel>();
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Directionality(
        textDirection: TextDirection.rtl,
             child :viewModel.isLoading && viewModel.newsList.isEmpty && viewModel.tipssList.isEmpty
                ? const Center(
                  child: CircularProgressIndicator(),
                ) // عرض تحميل أثناء جلب البيانات
                : RefreshIndicator(
                  onRefresh: () => viewModel.loadContent(),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        NewsTipsHeader(
                          isNewsSelected: viewModel.isNewsSelected,
                          onToggle: (val) => viewModel.toggleSelection(val),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (viewModel.isNewsSelected) ...[
                                const NewsSectionHeader(title: "أهم الأخبار"),
                                ...viewModel.newsList.map(
                                  (news) => NewsCard(news: news),
                                ),
                                if (viewModel.newsList.isEmpty)
                                  const Center(
                                    child: Text("لا توجد أخبار حالياً"),
                                  ),
                              ] else ...[
                                const NewsSectionHeader(title: "نصائح بيئية"),
                                // ربط قائمة النصائح الحقيقية من السيرفر
                                ...viewModel.tipssList.map(
                                  (tip) => TipItem(tip: tip),
                                ),
                                if (viewModel.tipssList.isEmpty)
                                  const Center(
                                    child: Text("لا توجد نصائح حالياً"),
                                  ),
                              ],
                              const SizedBox(height: 25),
                              const CallToActionCard(),
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
      ),
    );
  }
}
