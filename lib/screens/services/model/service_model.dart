import 'package:flutter/material.dart';

class AppService {
  final String id;
  final String title;
  final String subtitle;
  final double? price;
  final String? priceLabel; // for "حسب الحجم"
  final IconData icon;
  final Color iconBgColor;

  AppService({
    required this.id,
    required this.title,
    required this.subtitle,
    this.price,
    this.priceLabel,
    required this.icon,
    required this.iconBgColor,
  });
}
