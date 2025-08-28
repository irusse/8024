import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Универсальный список, который группирует элементы по дате (createdAt)
class DateGroupedList<T> extends StatelessWidget {
  const DateGroupedList({
    super.key,
    required this.items,
    required this.dateOf,
    required this.itemBuilder,
    this.sortDescending = true,
    this.showTodayYesterday = true,
    this.dateLocale = 'ru_RU',
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.itemSpacing = 8.0,
    this.headerTextStyle,
    this.headerBuilder,
  });

  /// Элементы списка
  final List<T> items;

  /// Функция, которая возвращает дату для элемента
  final DateTime Function(T item) dateOf;

  /// Рендер карточки элемента
  final Widget Function(BuildContext context, T item) itemBuilder;

  /// Сортировать ли по убыванию даты (новые сверху)
  final bool sortDescending;

  /// Показывать ли "Сегодня"/"Вчера"
  final bool showTodayYesterday;

  /// Локаль форматирования дат
  final String dateLocale;

  /// Отступы списка
  final EdgeInsets padding;

  /// Вертикальный отступ между элементами списка
  final double itemSpacing;

  /// Стиль текста заголовка
  final TextStyle? headerTextStyle;

  /// Кастомный билд заголовка. Если не задан — рисуется дефолтный.
  /// [date] — дата группы (без времени), [title] — уже отформатированная строка.
  final Widget Function(BuildContext context, DateTime date, String title)?
      headerBuilder;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    // Копия и сортировка
    final sorted = List<T>.from(items);
    sorted.sort((a, b) {
      final da = dateOnly(dateOf(a));
      final db = dateOnly(dateOf(b));
      final cmp = db.compareTo(da); // по убыванию
      return sortDescending ? cmp : -cmp;
    });

    final rows = _buildRows(sorted);

    return ListView.separated(
      padding: padding,
      itemCount: rows.length,
      separatorBuilder: (_, __) => SizedBox(height: itemSpacing),
      itemBuilder: (context, index) {
        final row = rows[index];
        return switch (row) {
          _HeaderRow(:final date) => _buildHeader(context, date),
          _ItemRow<T>(:final item) => itemBuilder(context, item),
          _ => const SizedBox.shrink(),
        };
      },
    );
  }

  // ===== внутренняя логика =====

  DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  String _formatHeader(DateTime date) {
    final today = dateOnly(DateTime.now());
    final that = dateOnly(date);

    if (showTodayYesterday) {
      if (that == today) return 'Сегодня';
      if (that == today.subtract(const Duration(days: 1))) return 'Вчера';
    }
    return DateFormat('d MMMM yyyy', dateLocale).format(that);
  }

  Widget _buildHeader(BuildContext context, DateTime date) {
    final title = _formatHeader(date);
    if (headerBuilder != null) {
      return headerBuilder!(context, date, title);
    }
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: (headerTextStyle ??
                  theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  )) ??
              const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Divider(color: theme.dividerColor, height: 1),
      ],
    );
  }

  List<_RowBase> _buildRows(List<T> items) {
    final result = <_RowBase>[];
    DateTime? current;

    for (final item in items) {
      final d = dateOnly(dateOf(item));
      if (current == null || d != current) {
        result.add(_HeaderRow(d));
        current = d;
      }
      result.add(_ItemRow<T>(item));
    }
    return result;
  }
}

// ===== внутренняя модель строк =====

sealed class _RowBase {
  const _RowBase();
}

class _HeaderRow extends _RowBase {
  final DateTime date;

  const _HeaderRow(this.date);
}

class _ItemRow<T> extends _RowBase {
  final T item;

  const _ItemRow(this.item);
}
