import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:neighbours/core/components/custom_gap.dart';
import 'package:neighbours/core/extensions/context_ext.dart';

import '../../../../core/constants/ui_constants.dart'; // для форматирования даты

class DateTimeRow extends StatelessWidget {
  final DateTime dateTime;

  const DateTimeRow({super.key, required this.dateTime});

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('dd.MM.yyyy').format(dateTime);
    final time = DateFormat('HH:mm').format(dateTime);

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: UIConstants.defaultHorizontalPadding, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _InfoBlock(
            title: 'Дата',
            icon: Icons.calendar_today_outlined,
            value: date,
          ),
          _InfoBlock(
            title: 'Время',
            icon: Icons.access_time,
            value: time,
          ),
        ],
      ),
    );
  }
}

class _InfoBlock extends StatelessWidget {
  final String title;
  final IconData icon;
  final String value;

  const _InfoBlock({
    required this.title,
    required this.icon,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: context.text.bodyLarge,
        ),
        const VerticalGap(8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, color: context.color.secondaryText, size: 24),
            const HorizontalGap(8),
            Text(
              value,
              style: context.text.bodyLarge,
            ),
          ],
        )
      ],
    );
  }
}
