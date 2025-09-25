import 'package:flutter/material.dart';
import 'package:neighbours/core/components/custom_gap.dart';
import 'package:neighbours/core/extensions/context_ext.dart';

import '../../../../core/services/clipboard_service.dart';
import '../../../../core/themes/theme.dart';

class PropertyConfirmationBanner extends StatelessWidget {
  final String confirmationCode;

  const PropertyConfirmationBanner({super.key, required this.confirmationCode});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            CommonModeColors.orange.withValues(alpha: 0.1),
            CommonModeColors.orange.withValues(alpha: .05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border(
          bottom: BorderSide(
            color: CommonModeColors.orange.withValues(alpha: .3),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: CommonModeColors.orange,
                size: 24,
              ),
              const HorizontalGap(8),
              Expanded(
                child: Text(
                  'Объект ожидает подтверждения',
                  style: context.text.bodyLarge.copyWith(
                    color: CommonModeColors.orange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const VerticalGap(8),
          Text(
            'Если объект не будет подтвержден в течение 24 часов, он будет автоматически удален из системы.',
            style: context.text.bodyMedium.copyWith(
              color: context.color.secondaryText,
              height: 1.4,
            ),
          ),
          const VerticalGap(8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.color.secondary,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: CommonModeColors.orange.withValues(alpha: .3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Поделитесь кодом с соседями для подтверждения:',
                  style: context.text.bodySmall.copyWith(
                    color: context.color.secondaryText,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () async {
                    await ClipboardService.copyToClipboard(
                      context: context,
                      text: confirmationCode,
                      successMessage: 'Код подтверждения скопирован',
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: CommonModeColors.orange.withValues(alpha: .1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: CommonModeColors.orange.withValues(alpha: .3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          confirmationCode,
                          style: context.text.bodyLarge.copyWith(
                            color: CommonModeColors.orange,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.copy_rounded,
                          size: 16,
                          color: CommonModeColors.orange,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
