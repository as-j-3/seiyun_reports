import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:seiyun_reports_app/screens/report/viewmodel/report_viewmodel.dart';
import 'package:seiyun_reports_app/screens/profile/viewmodel/profile_viewmodel.dart';
import 'package:seiyun_reports_app/screens/home/viewmodel/home_viewmodel.dart';
import 'package:seiyun_reports_app/screens/report/view/widgets/report_header.dart';
import 'package:seiyun_reports_app/screens/report/view/widgets/category_grid.dart';
import 'package:seiyun_reports_app/screens/report/view/widgets/priority_selector.dart';
import 'package:seiyun_reports_app/screens/report/view/widgets/location_card.dart';
import 'package:seiyun_reports_app/screens/report/view/widgets/image_picker_widget.dart';

const sectionTitleStyle = TextStyle(fontSize: 16, fontWeight: FontWeight.bold);

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();

  @override
  void dispose() {
    _descriptionController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reportVM = context.watch<ReportViewModel>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ReportHeader(),
            if (!context.watch<ProfileViewModel>().isPhoneVerified)
              _buildVerificationWarning(context, context.read<HomeViewModel>()),
            Padding(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "report.type".tr(),
                    style: sectionTitleStyle.copyWith(
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 15),
                  const CategoryGrid(),
                  if (reportVM.selectedCategory == 'أخرى') ...[
                    const SizedBox(height: 30),
                    Text(
                      "report.custom_title".tr(),
                      style: sectionTitleStyle.copyWith(
                        color: Theme.of(context).textTheme.titleLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 15),
                    _buildTitleField(),
                  ],
                  const SizedBox(height: 30),
                  Text(
                    "report.priority".tr(),
                    style: sectionTitleStyle.copyWith(
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 15),
                  const PrioritySelector(),
                  const SizedBox(height: 30),
                  Text(
                    "report.location".tr(),
                    style: sectionTitleStyle.copyWith(
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 15),
                  const LocationCard(),
                  const SizedBox(height: 30),
                  Text(
                    "report.image_optional".tr(),
                    style: sectionTitleStyle.copyWith(
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 15),
                  const ImagePickerWidget(),
                  const SizedBox(height: 30),
                  Text(
                    "report.description".tr(),
                    style: sectionTitleStyle.copyWith(
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 15),
                  _buildDescriptionField(),
                  const SizedBox(height: 35),
                  _buildSubmitButton(context),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationWarning(BuildContext context, HomeViewModel homeVM) {
    return GestureDetector(
      onTap: () {
        homeVM.setPage(3); 
        Navigator.pop(context);
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(25, 20, 25, 0),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.orange.shade200, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange,
                size: 24,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "report.warning_account_inactive".tr(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFD35400),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "report.warning_verify_phone".tr(),
                    style: const TextStyle(fontSize: 12, color: Colors.black87),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_back_ios_new,
              size: 14,
              color: Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleField() {
    return TextField(
      controller: _titleController,
      style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
      decoration: InputDecoration(
        hintText: "report.hint_title".tr(),
        hintStyle: TextStyle(
          color: Theme.of(context).textTheme.bodySmall?.color,
          fontSize: 13,
        ),
        prefixIcon: const Icon(Icons.title_rounded, color: Colors.grey),
        filled: true,
        fillColor: Theme.of(context).cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    final reportVM = context.watch<ReportViewModel>();
    final profileVM = context.read<ProfileViewModel>();
    final homeVM = context.read<HomeViewModel>();

    return ElevatedButton(
      onPressed:
          reportVM.isUploading
              ? null
              : () {
                if (!profileVM.isPhoneVerified) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("report.toast_verify_phone".tr()),
                      duration: const Duration(seconds: 3),
                    ),
                  );
                  homeVM.setPage(3); 
                  Navigator.pop(context);
                  return;
                }

                if (reportVM.selectedCategory == 'أخرى' &&
                    _titleController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("report.toast_enter_title".tr())),
                  );
                  return;
                }

                reportVM.sendNewReport(
                  context,
                  _descriptionController.text.trim(),
                  customTitle:
                      reportVM.selectedCategory == 'أخرى'
                          ? _titleController.text.trim()
                          : null,
                );
              },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF27ae60),
        disabledBackgroundColor: const Color(0xFF27ae60).withOpacity(0.6),
        minimumSize: const Size(double.infinity, 65),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child:
          reportVM.isUploading
              ? const SizedBox(
                width: 25,
                height: 25,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
              : Text(
                "report.submit".tr(),
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
    );
  }

  Widget _buildDescriptionField() {
    return TextField(
      controller: _descriptionController,
      maxLines: 4,
      style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
      decoration: InputDecoration(
        hintText: "report.hint_description".tr(),
        hintStyle: TextStyle(
          color: Theme.of(context).textTheme.bodySmall?.color,
          fontSize: 13,
        ),
        filled: true,
        fillColor: Theme.of(context).cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Theme.of(context).dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
    );
  }
}
