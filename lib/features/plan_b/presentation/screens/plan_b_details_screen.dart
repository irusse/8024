import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neighbours/core/components/custom_gap.dart';
import 'package:neighbours/core/components/custom_outlined_button.dart';
import 'package:neighbours/core/components/default_app_bar.dart';
import 'package:neighbours/core/components/default_loading_overlay.dart';
import 'package:neighbours/core/components/error_with_try_btn.dart';
import 'package:neighbours/core/constants/ui_constants.dart';
import 'package:neighbours/core/extensions/context_ext.dart';
import 'package:neighbours/core/state/api_state.dart';
import 'package:neighbours/features/plan_b/domain/enitities/plan_b_details/plan_b_details_entity.dart';
import 'package:neighbours/features/plan_b/presentation/cubits/plan_b/plan_b_cubit.dart';
import 'package:neighbours/features/plan_b/presentation/widgets/plan_b_category_status_badge.dart';
import 'package:neighbours/features/plan_b/presentation/widgets/plan_b_info_card.dart';
import 'package:neighbours/features/plan_b/presentation/widgets/plan_b_info_row.dart';
import 'package:neighbours/features/plan_b/presentation/widgets/plan_b_photo_gallery.dart';
import 'package:neighbours/features/plan_b/presentation/widgets/plan_b_text_card.dart';

class PlanBDetailsScreen extends StatefulWidget {
  final int planBId;

  const PlanBDetailsScreen({super.key, required this.planBId});

  @override
  State<PlanBDetailsScreen> createState() => _PlanBDetailsScreenState();
}

class _PlanBDetailsScreenState extends State<PlanBDetailsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<PlanBCubit>().getPlanBDetails(widget.planBId);
  }

  String _formatPrice(double? price) {
    if (price == null) return 'Не указана';
    return '${price.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]} ',
        )} ₽';
  }

  String _formatDate(DateTime date) {
    final months = [
      'января',
      'февраля',
      'марта',
      'апреля',
      'мая',
      'июня',
      'июля',
      'августа',
      'сентября',
      'октября',
      'ноября',
      'декабря'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatParameterValue(String? value) {
    if (value == null || value.isEmpty) return 'Не указано';
    
    // Преобразуем булевые значения
    if (value.toLowerCase() == 'true') return 'Да';
    if (value.toLowerCase() == 'false') return 'Нет';
    
    return value;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlanBCubit, PlanBState>(
      builder: (context, state) {
        return state.detailsState.when(
          initial: () => Scaffold(body: DefaultLoadingOverlay()),
          loading: () => Scaffold(
            body: const DefaultLoadingOverlay(),
          ),
          success: (details) => _buildContent(context, details),
          failure: (error) => Scaffold(
            appBar: DefaultAppBar(
              showBackButton: true,
              title: 'Plan B',
            ),
            body: ErrorWithTryBtn(
                error: state.fetchState.error!,
                onErrorClick: () =>
                    context.read<PlanBCubit>().getPlanBDetails(widget.planBId)),
          ),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, PlanBDetailsEntity details) {
    print(details.photos.first);
    return Scaffold(
      appBar: DefaultAppBar(
        showBackButton: true,
        title: details.name,
      ),
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Галерея фотографий
              PlanBPhotoGallery(photos: details.photos),

              const VerticalGap(24),

              // Основная информация
              _buildMainInfoCard(context, details),

              const VerticalGap(16),

              // Кнопка "Связаться"
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: UIConstants.defaultHorizontalPadding,
                ),
                child: CustomOutlinedButton(
                  verticalPadding: 12,
                  text: 'Связаться',
                  onPressed: () {
                    context.snackbar
                        .info(context, 'Функция связи в разработке');
                  },
                ),
              ),

              const VerticalGap(16),

              // Категория и статус
              PlanBCategoryStatusBadge(
                category: details.category.name,
                status: details.status,
              ),

              const VerticalGap(16),

              // Описание
              if (details.description != null &&
                  details.description!.isNotEmpty)
                _buildCard(
                  context,
                  child: PlanBTextCard(
                    icon: Icons.description_outlined,
                    title: 'Описание',
                    content: details.description!,
                  ),
                ),

              const VerticalGap(16),

              // Адрес
              if (details.address != null && details.address!.isNotEmpty)
                _buildCard(
                  context,
                  child: PlanBTextCard(
                    icon: Icons.location_on_outlined,
                    title: 'Адрес',
                    content: details.address!,
                  ),
                ),

              const VerticalGap(16),

              // Автономность
              if (details.autonomyNotes != null &&
                  details.autonomyNotes!.isNotEmpty)
                _buildCard(
                  context,
                  child: PlanBTextCard(
                    icon: Icons.bolt_outlined,
                    title: 'Автономность',
                    content: details.autonomyNotes!,
                  ),
                ),

              const VerticalGap(16),

              // Финансы
              if (details.financeInfo != null &&
                  details.financeInfo!.isNotEmpty)
                _buildCard(
                  context,
                  child: PlanBTextCard(
                    icon: Icons.account_balance_wallet_outlined,
                    title: 'Финансовая информация',
                    content: details.financeInfo!,
                  ),
                ),

              const VerticalGap(16),

              // Параметры
              if (details.parameters.isNotEmpty)
                PlanBInfoCard(
                  icon: Icons.tune_rounded,
                  title: 'Параметры',
                  child: Column(
                    children: details.parameters
                        .asMap()
                        .entries
                        .map((entry) => Column(
                              children: [
                                if (entry.key > 0) const VerticalGap(16),
                                PlanBInfoRow(
                                  icon: Icons.check_circle_outline,
                                  label: entry.value.name,
                                  value: _formatParameterValue(entry.value.value),
                                ),
                              ],
                            ))
                        .toList(),
                  ),
                ),

              const VerticalGap(24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, {required Widget child}) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: UIConstants.defaultHorizontalPadding,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: context.color.secondary,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: context.color.tertiary.withValues(alpha: .08),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: context.color.tertiary.withValues(alpha: .1),
            width: 1,
          ),
        ),
        child: child,
      ),
    );
  }

  Widget _buildMainInfoCard(BuildContext context, PlanBDetailsEntity details) {
    return PlanBInfoCard(
      icon: Icons.info_outline_rounded,
      title: 'Основная информация',
      child: Column(
        children: [
          PlanBInfoRow(
            icon: Icons.title_rounded,
            label: 'Название',
            value: details.name,
          ),
          const VerticalGap(16),
          PlanBInfoRow(
            icon: Icons.attach_money_rounded,
            label: 'Цена',
            value: _formatPrice(details.price),
          ),
          const VerticalGap(16),
          PlanBInfoRow(
            icon: Icons.calendar_today_outlined,
            label: 'Дата создания',
            value: _formatDate(details.createdAt),
          ),
        ],
      ),
    );
  }
}
