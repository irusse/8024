import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:neighbours/core/components/custom_gap.dart';
import 'package:neighbours/core/components/custom_label.dart';
import 'package:neighbours/features/home/presentation/widgets/select_field.dart';

class DateTimeSelectField extends StatelessWidget {
  final DateTime? selectedDateTime;
  final void Function(DateTime) onDateTimeChanged;
  final bool isRequired;

  const DateTimeSelectField({
    super.key,
    required this.selectedDateTime,
    required this.onDateTimeChanged,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomLabel(text: 'Дата', isRequired: isRequired),
              const VerticalGap(8),
              SelectField(
                label: '__.__.__',
                value: selectedDateTime != null
                    ? DateFormat('dd.MM.yyyy').format(selectedDateTime!)
                    : '',
                icon: Icons.calendar_month,
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: selectedDateTime ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    final newDateTime = DateTime(
                      date.year,
                      date.month,
                      date.day,
                      selectedDateTime?.hour ?? DateTime.now().hour,
                      selectedDateTime?.minute ?? DateTime.now().minute,
                    );
                    onDateTimeChanged(newDateTime);
                  }
                },
              ),
            ],
          ),
        ),
        const HorizontalGap(16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomLabel(text: 'Время', isRequired: isRequired),
              const VerticalGap(8),
              SelectField(
                label: '__:__',
                value: selectedDateTime != null
                    ? '${selectedDateTime!.hour.toString().padLeft(2, '0')}:${selectedDateTime!.minute.toString().padLeft(2, '0')}'
                    : '',
                icon: Icons.access_time,
                onTap: () async {
                  final currentTime = selectedDateTime != null 
                      ? TimeOfDay.fromDateTime(selectedDateTime!)
                      : TimeOfDay.now();
                  final time = await showTimePicker(
                    context: context,
                    initialTime: currentTime,
                  );
                  if (time != null) {
                    final newDateTime = DateTime(
                      selectedDateTime?.year ?? DateTime.now().year,
                      selectedDateTime?.month ?? DateTime.now().month,
                      selectedDateTime?.day ?? DateTime.now().day,
                      time.hour,
                      time.minute,
                    );
                    onDateTimeChanged(newDateTime);
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
