import 'package:flutter/material.dart';
import '../model/service_model.dart';

class ServicesViewModel extends ChangeNotifier {
  final List<AppService> availableServices = [
    AppService(
      id: '1',
      title: 'رفع نفايات كبيرة',
      subtitle: 'رفع الأثاث والنفايات الكبيرة',
      price: 3000,
      icon: Icons.local_shipping,
      iconBgColor: const Color(0xFF4285F4),
    ),
    AppService(
      id: '2',
      title: 'حاوية خاصة',
      subtitle: 'طلب حاوية إضافية مؤقتة',
      price: 5000,
      icon: Icons.delete_outline,
      iconBgColor: const Color(0xFF34A853),
    ),
    AppService(
      id: '3',
      title: 'خدمة فعالية',
      subtitle: 'إدارة النفايات للفعاليات',
      priceLabel: 'حسب الحجم',
      icon: Icons.group_outlined,
      iconBgColor: const Color(0xFFD94B1B),
    ),
    AppService(
      id: '4',
      title: 'تنظيف شامل',
      subtitle: 'تنظيف عميق للمنطقة',
      price: 6000,
      icon: Icons.cleaning_services_outlined,
      iconBgColor: const Color(0xFFC539DB),
    ),
    AppService(
      id: '5',
      title: 'صيانة حاوية',
      subtitle: 'صيانة أو استبدال حاوية',
      price: 5000,
      icon: Icons.handyman_outlined,
      iconBgColor: const Color(0xFFFBBC05),
    ),
  ];

  AppService? _selectedService;
  AppService? get selectedService => _selectedService;

  DateTime? _selectedDate;
  DateTime? get selectedDate => _selectedDate;

  String? _selectedTime; // 'صباحاً', 'ظهراً', 'مساءً'
  String? get selectedTime => _selectedTime;

  final TextEditingController phoneController = TextEditingController(text: "+967 773 849 866");
  final TextEditingController notesController = TextEditingController();

  ServicesViewModel() {
    // Select a default service for demonstration
    _selectedService = availableServices[3]; // تنظيف شامل
    _selectedTime = "مساءً";
    _selectedDate = DateTime.now();
  }

  void selectService(AppService service) {
    _selectedService = service;
    notifyListeners();
  }

  void selectDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  void selectTime(String time) {
    _selectedTime = time;
    notifyListeners();
  }

  @override
  void dispose() {
    phoneController.dispose();
    notesController.dispose();
    super.dispose();
  }
}
