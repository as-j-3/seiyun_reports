import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:seiyun_reports_app/core/theme/app_theme.dart';
import 'package:seiyun_reports_app/screens/profile/viewmodel/profile_viewmodel.dart';
import 'package:seiyun_reports_app/screens/map/view/map_screen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ProfileHeader extends StatelessWidget {
  final ProfileViewModel viewModel;

  const ProfileHeader({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final user = viewModel.currentUser;
    final name = viewModel.userName ?? user?.displayName ?? "غير محدد";
    final phone =
        (viewModel.userPhone != null && viewModel.userPhone!.isNotEmpty)
            ? viewModel.userPhone!
            : "رقم غير محدد";
    final address =
        (viewModel.userAddress != null && viewModel.userAddress!.isNotEmpty)
            ? viewModel.userAddress!
            : "موقع غير محدد";

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 240,
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: AppTheme.headerGradient,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(50),
              bottomRight: Radius.circular(50),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "profile.title".tr(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  IconButton(
                    onPressed: () => _showEditProfileDialog(context),
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 110,
          left: 20,
          right: 20,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.12),
                  blurRadius: 25,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                _buildAvatar(context),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.titleLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "عضو فعال",
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.primaryColor.withOpacity(0.8),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        context,
                        Icons.email_outlined,
                        viewModel.userEmail ??
                            user?.email ??
                            "no-email@example.com",
                      ),
                      const SizedBox(height: 6),
                      _buildInfoRow(
                        context,
                        Icons.phone_android_outlined,
                        phone,
                      ),
                      const SizedBox(height: 6),
                      _buildInfoRow(
                        context,
                        Icons.location_on_outlined,
                        address,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    final nameController = TextEditingController(
      text: viewModel.userName ?? viewModel.currentUser?.displayName,
    );
    final phoneController = TextEditingController(text: viewModel.userPhone);
    final addressController = TextEditingController(
      text: viewModel.userAddress,
    );

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("تعديل البيانات", textAlign: TextAlign.center),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: "الأسم الكامل",
                    ),
                  ),
                  TextField(
                    controller: phoneController,
                    decoration: const InputDecoration(labelText: "رقم الهاتف"),
                    keyboardType: TextInputType.phone,
                  ),
                  TextField(
                    controller: addressController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: "العنوان",
                      hintText: "لم يتم تحديد موقع بعد",
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "تحديث الموقع:",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            addressController.text = "جاري التحديد...";
                            await viewModel.updateLocationAutomatically();
                            addressController.text =
                                viewModel.userAddress ?? "موقع غير محدد";
                          },
                          icon: const Icon(Icons.my_location, size: 18),
                          label: const Text(
                            "تلقائي",
                            style: TextStyle(fontSize: 12),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor.withOpacity(
                              0.1,
                            ),
                            foregroundColor: AppTheme.primaryColor,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final LatLng? pickedLocation = await Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder:
                                    (
                                      context,
                                      animation,
                                      secondaryAnimation,
                                    ) => MapScreen(
                                      isPicker: true,
                                      initialLocation: LatLng(
                                        viewModel.profile?.latitude ?? 15.9429,
                                        viewModel.profile?.longitude ?? 48.7844,
                                      ),
                                    ),
                                transitionDuration: Duration.zero,
                                reverseTransitionDuration: Duration.zero,
                              ),
                            );

                            if (pickedLocation != null) {
                              await viewModel.updateLocationManually(
                                pickedLocation.latitude,
                                pickedLocation.longitude,
                              );
                              addressController.text =
                                  viewModel.userAddress ?? "موقع غير محدد";
                            }
                          },
                          icon: const Icon(Icons.map_outlined, size: 18),
                          label: const Text(
                            "الخريطة",
                            style: TextStyle(fontSize: 12),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor.withOpacity(
                              0.1,
                            ),
                            foregroundColor: AppTheme.primaryColor,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("إلغاء"),
              ),
              ElevatedButton(
                onPressed: () async {
                  await viewModel.saveProfileDetails(
                    name: nameController.text,
                    phone: phoneController.text,
                    address: addressController.text,
                  );
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
                child: const Text("حفظ"),
              ),
            ],
          ),
    );
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext bc) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: SafeArea(
            child: Wrap(
              children: [
                const Center(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 15),
                    child: Text(
                      "تغيير صورة الملف الشخصي",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.photo_library,
                    color: AppTheme.primaryColor,
                  ),
                  title: const Text('المعرض'),
                  onTap: () {
                    viewModel.pickImage(ImageSource.gallery);
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.photo_camera,
                    color: AppTheme.primaryColor,
                  ),
                  title: const Text('الكاميرا'),
                  onTap: () {
                    viewModel.pickImage(ImageSource.camera);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAvatar(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppTheme.primaryColor.withOpacity(0.1),
              width: 4,
            ),
          ),
          child: CircleAvatar(
            radius: 46,
            backgroundColor: AppTheme.primaryColor.withOpacity(0.05),
            backgroundImage:
                viewModel.profileImage != null
                    ? FileImage(viewModel.profileImage!)
                    : (viewModel.profile?.profileImage != null
                            ? NetworkImage(viewModel.profile!.profileImage!)
                            : null)
                        as ImageProvider?,
            child:
                (viewModel.profileImage == null &&
                        viewModel.profile?.profileImage == null)
                    ? const Icon(
                      Icons.person,
                      size: 50,
                      color: AppTheme.primaryColor,
                    )
                    : null,
          ),
        ),
        Positioned(
          bottom: 4,
          left: 4,
          child: GestureDetector(
            onTap: () => _showPicker(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).cardColor,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Theme.of(context).textTheme.bodySmall?.color,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(
                context,
              ).textTheme.bodyMedium?.color?.withOpacity(0.8),
              height: 1.2,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
