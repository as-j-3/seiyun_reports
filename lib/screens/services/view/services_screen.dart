import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/services_viewmodel.dart';
import '../model/service_model.dart';
import 'package:intl/intl.dart' as intl;

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ServicesViewModel(),
      child: const _ServicesScreenContent(),
    );
  }
}

class _ServicesScreenContent extends StatelessWidget {
  const _ServicesScreenContent();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ServicesViewModel>();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Column(
          children: [
            const _Header(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "نوع الخدمة *",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Theme.of(context).textTheme.titleLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 15),
                    ...vm.availableServices.map((service) => _ServiceCard(
                          service: service,
                          isSelected: vm.selectedService?.id == service.id,
                          onTap: () => vm.selectService(service),
                        )),
                    const SizedBox(height: 30),
                    Text(
                      "التاريخ المفضل *",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Theme.of(context).textTheme.titleLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _DatePickerField(vm: vm),
                    const SizedBox(height: 30),
                    Text(
                      "الوقت المفضل *",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Theme.of(context).textTheme.titleLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 15),
                    _TimePickerRow(vm: vm),
                    const SizedBox(height: 30),
                    Text(
                      "رقم الاتصال *",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Theme.of(context).textTheme.titleLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _PhoneField(vm: vm),
                    const SizedBox(height: 30),
                    Text(
                      "ملاحظات اضافية ( اختياري )",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Theme.of(context).textTheme.titleLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _NotesField(vm: vm),
                    const SizedBox(height: 30),
                    _OrderSummary(vm: vm),
                    const SizedBox(height: 30),
                    const _SubmitButton(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 30),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              const Text(
                "طلب خدمة",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 48), // Spacer for centering
            ],
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              "اطلب خدمات إضافية خاصة بالنظافة وإدارة النفايات",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final AppService service;
  final bool isSelected;
  final VoidCallback onTap;

  const _ServiceCard({
    required this.service,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF4285F4) : (isDark ? Colors.grey.shade800 : Colors.grey.shade200),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: service.iconBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(service.icon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold, 
                      fontSize: 16,
                      color: Theme.of(context).textTheme.titleMedium?.color,
                    ),
                  ),
                  Text(
                    service.subtitle,
                    style: TextStyle(
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, 
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      service.priceLabel ?? "${service.price?.toInt()} ريال",
                      style: TextStyle(
                        fontSize: 12, 
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: Color(0xFF4285F4), size: 24),
          ],
        ),
      ),
    );
  }
}

class _DatePickerField extends StatelessWidget {
  final ServicesViewModel vm;

  const _DatePickerField({required this.vm});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () async {
        final now = DateTime.now();
        // التأكد من أن التاريخ الأولي ليس قبل تاريخ اليوم لتجنب الخطأ البرمجي
        final initial = (vm.selectedDate != null && !vm.selectedDate!.isBefore(DateTime(now.year, now.month, now.day)))
            ? vm.selectedDate!
            : now;
            
        final date = await showDatePicker(
          context: context,
          initialDate: initial,
          firstDate: DateTime(now.year, now.month, now.day),
          lastDate: now.add(const Duration(days: 365)),
        );
        if (date != null) vm.selectDate(date);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                vm.selectedDate != null
                    ? intl.DateFormat('dd/MM/yyyy').format(vm.selectedDate!)
                    : "اختر التاريخ",
                style: TextStyle(
                  fontSize: 15,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF4A148C).withValues(alpha: 0.3) : const Color(0xFFF3E5F5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.calendar_today, color: Color(0xFF9C27B0), size: 20),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimePickerRow extends StatelessWidget {
  final ServicesViewModel vm;

  const _TimePickerRow({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _TimeOption(
          label: "صباحاً",
          time: "12:00 - 8:00",
          isSelected: vm.selectedTime == "صباحاً",
          onTap: () => vm.selectTime("صباحاً"),
        ),
        const SizedBox(width: 10),
        _TimeOption(
          label: "ظهراً",
          time: "4:00 - 12:00",
          isSelected: vm.selectedTime == "ظهراً",
          onTap: () => vm.selectTime("ظهراً"),
        ),
        const SizedBox(width: 10),
        _TimeOption(
          label: "مساءً",
          time: "8:00 - 4:00",
          isSelected: vm.selectedTime == "مساءً",
          onTap: () => vm.selectTime("مساءً"),
        ),
      ],
    );
  }
}

class _TimeOption extends StatelessWidget {
  final String label;
  final String time;
  final bool isSelected;
  final VoidCallback onTap;

  const _TimeOption({
    required this.label,
    required this.time,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            color: isSelected 
                ? (isDark ? const Color(0xFF1E88E5).withValues(alpha: 0.2) : const Color(0xFFE3F2FD)) 
                : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: isSelected ? const Color(0xFF4285F4) : (isDark ? Colors.grey.shade800 : Colors.grey.shade200),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.access_time,
                color: isSelected ? const Color(0xFF4285F4) : Colors.grey.shade400,
                size: 24,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? const Color(0xFF4285F4) : Theme.of(context).textTheme.bodyLarge?.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                time,
                style: TextStyle(color: Colors.grey.shade500, fontSize: 10),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhoneField extends StatelessWidget {
  final ServicesViewModel vm;

  const _PhoneField({required this.vm});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
      ),
      child: TextField(
        controller: vm.phoneController,
        keyboardType: TextInputType.phone,
        textAlign: TextAlign.left,
        style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          suffixIcon: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1B5E20).withValues(alpha: 0.3) : const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.phone_outlined, color: Color(0xFF4CAF50), size: 20),
          ),
        ),
      ),
    );
  }
}

class _NotesField extends StatelessWidget {
  final ServicesViewModel vm;

  const _NotesField({required this.vm});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
      ),
      child: TextField(
        controller: vm.notesController,
        maxLines: 4,
        style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
        decoration: InputDecoration(
          hintText: "أضف اي تفاصيل اضافية ...",
          hintStyle: TextStyle(
            color: isDark ? Colors.grey.shade500 : Colors.grey.shade600, 
            fontSize: 14,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(15),
        ),
      ),
    );
  }
}

class _OrderSummary extends StatelessWidget {
  final ServicesViewModel vm;

  const _OrderSummary({required this.vm});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF01579B).withValues(alpha: 0.2) : const Color(0xFFE1F5FE),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                "ملخص الطلب",
                style: TextStyle(
                  fontWeight: FontWeight.bold, 
                  fontSize: 16,
                  color: isDark ? Colors.lightBlue.shade100 : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                vm.selectedService?.title ?? "لم يتم الاختيار",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const Text("الخدمة:", style: TextStyle(color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                vm.selectedService?.priceLabel ?? "${vm.selectedService?.price?.toInt() ?? 0} ريال",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const Text("التكلفة:", style: TextStyle(color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton.icon(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("تم ارسال طلبك بنجاح")),
          );
        },
        icon: const Icon(Icons.send, size: 20),
        label: const Text(
          "ارسال الطلب",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2ECC71),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }
}
