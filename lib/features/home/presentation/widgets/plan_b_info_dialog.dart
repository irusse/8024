import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:neighbours/core/components/custom_gap.dart';
import 'package:neighbours/core/components/primary_button.dart';
import 'package:neighbours/core/extensions/context_ext.dart';
import 'package:neighbours/core/router/app_routes.dart';
import 'package:neighbours/core/themes/theme.dart';
import 'package:neighbours/features/plan_b/domain/enitities/plan_b_map/plan_b_map_entity.dart';

class PlanBInfoDialog extends StatelessWidget {
  final bool inClusterList;
  final PlanBMapEntity planB;

  const PlanBInfoDialog(
      {super.key, required this.planB, required this.inClusterList});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.color.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildPlanBCard(context),
          const VerticalGap(16),
          Row(
            children: [
              Expanded(
                child: PrimaryButton(
                  text: 'Подробнее',
                  onPressed: () {
                    context.push(AppRouteBuilder.planBDetails(planB.id));
                  },
                  verticalPadding: 10,
                ),
              ),
              const HorizontalGap(12),
              Expanded(
                child: PrimaryButton(
                  text: 'Связаться',
                  onPressed: () => _onContactPressed(context),
                  verticalPadding: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlanBCard(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (planB.icon != null && planB.icon!.isNotEmpty)
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: context.color.primary.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                planB.icon!,
                style: const TextStyle(fontSize: 30),
              ),
            ),
          )
        else
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: context.color.primary.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.business,
              size: 30,
              color: context.color.primary,
            ),
          ),
        const HorizontalGap(12),
        // Информация
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Название
              Text(
                planB.name,
                style: context.text.titleSmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const VerticalGap(4),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: CommonModeColors.orange.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  planB.categoryName,
                  style: context.text.bodySmall.copyWith(
                    color: CommonModeColors.orange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              // Цена
              const VerticalGap(8),
              Text(
                _formatPrice(planB.price),
                style: context.text.titleSmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.color.primary,
                ),
              ),
              // Описание
              if (planB.shortDescription != null &&
                  planB.shortDescription!.isNotEmpty) ...[
                const VerticalGap(8),
                Text(
                  planB.shortDescription!,
                  style: context.text.bodyMedium.copyWith(
                    color: context.color.secondaryText,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  String _formatPrice(double price) {
    return '${price.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]} ',
        )} ₽';
  }

  void _onContactPressed(BuildContext context) async {
    // TODO: Реализовать логику связи (телефон, email, мессенджер и т.д.)
    // Пока просто закрываем диалог
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Функция связи в разработке'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
