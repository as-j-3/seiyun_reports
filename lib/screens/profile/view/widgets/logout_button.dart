import 'package:flutter/material.dart';
import 'package:seiyun_reports_app/screens/profile/viewmodel/profile_viewmodel.dart';
import 'package:easy_localization/easy_localization.dart';

class LogoutButton extends StatelessWidget {
  final ProfileViewModel viewModel;

  const LogoutButton({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.logout, color: Colors.red),
        ),
        title: Text(
         "profile.logout".tr(),
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
        onTap: () => viewModel.logout(),
      ),
    );
  }
}
