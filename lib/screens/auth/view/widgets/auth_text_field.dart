import 'package:flutter/material.dart';
import 'package:seiyun_reports_app/core/theme/app_theme.dart';

class AuthTextField extends StatefulWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final bool isPassword;
  final IconData? icon;

  const AuthTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.isPassword = false,
    this.icon,
  });

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  bool _isObscure = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: isDark ? Colors.grey.shade400 : Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: widget.controller,
          obscureText: widget.isPassword ? _isObscure : false,
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
            prefixIcon: widget.icon != null ? Icon(widget.icon, color: AppTheme.primaryGreen, size: 20) : null,
            filled: true,
            fillColor: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(
                color: AppTheme.primaryGreen,
                width: 2,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                width: 1.5,
              ),
            ),
            suffixIcon:
                widget.isPassword
                    ? IconButton(
                      icon: Icon(
                        _isObscure ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _isObscure = !_isObscure;
                        });
                      },
                    )
                    : null,
          ),
        ),
      ],
    );
  }
}
