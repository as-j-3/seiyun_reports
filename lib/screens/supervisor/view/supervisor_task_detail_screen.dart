import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:seiyun_reports_app/core/theme/app_theme.dart';

class SupervisorTaskDetailScreen extends StatefulWidget {
  final Map<String, dynamic> task;
  const SupervisorTaskDetailScreen({Key? key, required this.task}) : super(key: key);

  @override
  State<SupervisorTaskDetailScreen> createState() => _SupervisorTaskDetailScreenState();
}

class _SupervisorTaskDetailScreenState extends State<SupervisorTaskDetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  File? _image;
  bool _isSubmitting = false;

  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? photo = await picker.pickImage(source: source, imageQuality: 70);
    if (photo != null) {
      setState(() {
        _image = File(photo.path);
      });
    }
  }

  void _submitUpdate() {
    if (_commentController.text.isEmpty && _image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("يرجى إضافة تعليق أو صورة")),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    // Simulate API call
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("تم تحديث حالة البلاغ بنجاح")),
        );
        Navigator.pop(context, true); // Return true to indicate update
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('تفاصيل المهمة'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Task Info Card
              _buildTaskInfoCard(isDark),
              const SizedBox(height: 30),
              
              Text(
                "الرد على البلاغ *",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),
              const SizedBox(height: 15),
              
              // Comment Field
              Container(
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
                ),
                child: TextField(
                  controller: _commentController,
                  maxLines: 4,
                  style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                  decoration: const InputDecoration(
                    hintText: "أضف تعليقك حول الإجراء المتخذ ...",
                    hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(15),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Image Picker
              Text(
                "صورة الإثبات ( اختيارية )",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Theme.of(context).textTheme.titleMedium?.color,
                ),
              ),
              const SizedBox(height: 10),
              _buildImagePicker(isDark),
              
              const SizedBox(height: 40),
              
              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitUpdate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "تحديث وإغلاق البلاغ",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaskInfoCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(CupertinoIcons.doc_text, color: AppTheme.primaryColor),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.task['title'],
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    Text(
                      "رقم البلاغ: #${widget.task['id']}",
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 30),
          _buildInfoRow(CupertinoIcons.location, widget.task['location_name']),
          const SizedBox(height: 10),
          _buildInfoRow(CupertinoIcons.calendar, widget.task['date']),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        const SizedBox(width: 10),
        Text(text, style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  Widget _buildImagePicker(bool isDark) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder: (context) => SafeArea(
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(CupertinoIcons.camera),
                  title: const Text('الكاميرا'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(CupertinoIcons.photo),
                  title: const Text('المعرض'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
      child: Container(
        height: 150,
        width: double.infinity,
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
            style: _image == null ? BorderStyle.solid : BorderStyle.none,
          ),
        ),
        child: _image != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.file(_image!, fit: BoxFit.cover),
              )
            : const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(CupertinoIcons.camera_fill, color: Colors.grey, size: 40),
                  SizedBox(height: 10),
                  Text("اضغط لإضافة صورة", style: TextStyle(color: Colors.grey)),
                ],
              ),
      ),
    );
  }
}
