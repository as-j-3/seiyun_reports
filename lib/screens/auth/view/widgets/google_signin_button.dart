import 'package:flutter/material.dart';

class GoogleSignInButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const GoogleSignInButton({
    super.key,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          const Expanded(child: Divider()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                Image.asset(
                  'assets/google.png',
                  width: 20,
                  errorBuilder:
                      (context, error, stackTrace) =>
                          const Icon(Icons.g_mobiledata),
                ),
                const SizedBox(width: 8),
                Text(
                  text, 
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const Expanded(child: Divider()),
        ],
      ),
    );
  }
}
