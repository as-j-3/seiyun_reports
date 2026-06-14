import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
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
      body:
          viewModel.isLoading &&
                  viewModel.newsList.isEmpty &&
                  viewModel.tipssList.isEmpty
              ? const Center(
                child: CircularProgressIndicator(),
              ) 
              : RefreshIndicator(
                onRefresh: () => viewModel.loadContent(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
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
                              NewsSectionHeader(
                                title: "news_tips.top_news".tr(),
                              ),
                              ...viewModel.newsList.map(
                                (news) => NewsCard(news: news),
                              ),
                              if (viewModel.newsList.isEmpty)
                                Center(child: Text("news_tips.no_news".tr())),
                            ] else ...[
                              NewsSectionHeader(
                                title: "news_tips.environmental_tips".tr(),
                              ),
                              ...viewModel.tipssList.map(
                                (tip) => TipItem(tip: tip),
                              ),
                              if (viewModel.tipssList.isEmpty)
                                Center(child: Text("news_tips.no_tips".tr())),
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
    );
  }
}
