import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:seiyun_reports_app/screens/report/viewmodel/report_viewmodel.dart';

class ImagePickerWidget extends StatelessWidget {
  const ImagePickerWidget({super.key});

  void _pickFromCamera(BuildContext context) {
    context.read<ReportViewModel>().pickImage(ImageSource.camera);
  }

  @override
  Widget build(BuildContext context) {
    final reportVM = context.watch<ReportViewModel>();

    return GestureDetector(
      onTap: () => _pickFromCamera(context),
      child: Container(
        width: double.infinity,
        height: 200, // زيادة الطول قليلاً لعرض الصورة بشكل أوضح
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E293B) : const Color(0xFFf8fafc),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF334155) : const Color(0xFFcbd5e1), width: 2),
          image:
              reportVM.image != null
                  ? DecorationImage(
                    image: FileImage(reportVM.image!),
                    fit: BoxFit.cover,
                  )
                  : null,
        ),
        child:
            reportVM.image == null
                ? const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.camera_alt_outlined,
                      size: 42,
                      color: Color(0xFF94a3b8),
                    ),
                    SizedBox(height: 12),
                    Text(
                      "اضغط لالتقاط صورة للمخالفة",
                      style: TextStyle(color: Color(0xFF94a3b8), fontSize: 14),
                    ),
                  ],
                )
                : Stack(
                  children: [
                    Positioned(
                      top: 10,
                      right: 10,
                      child: CircleAvatar(
                        backgroundColor: Colors.red.withOpacity(0.8),
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed:
                              () =>
                                  context.read<ReportViewModel>().removeImage(),
                        ),
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}
