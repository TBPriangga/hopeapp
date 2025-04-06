import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomDateField extends StatelessWidget {
  final String? label;
  final TextEditingController controller;
  final String? errorText;
  final String? hintText;
  final bool enabled;
  final Function(DateTime) onDateSelected;

  const CustomDateField({
    super.key,
    this.label,
    required this.controller,
    required this.onDateSelected,
    this.errorText,
    this.hintText,
    this.enabled = true,
  });

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF3949AB), // Header background color
              onPrimary: Colors.white, // Header text color
              onSurface: Colors.black, // Calendar text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF3949AB), // Button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      controller.text = DateFormat('dd/MM/yyyy').format(picked);
      onDateSelected(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: controller,
          readOnly: true,
          enabled: enabled,
          onTap: enabled ? () => _selectDate(context) : null,
          style: TextStyle(
            fontSize: 16,
            color: enabled ? Colors.black : Colors.grey,
          ),
          decoration: InputDecoration(
            hintText: hintText ?? 'Pilih tanggal lahir',
            hintStyle: TextStyle(
              color: Colors.grey[400],
            ),
            filled: true,
            fillColor: enabled ? Colors.white : Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            suffixIcon: Icon(
              Icons.calendar_today,
              color: enabled ? const Color(0xFF3949AB) : Colors.grey,
              size: 20,
            ),
            errorText: errorText,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF3949AB),
                width: 1,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
