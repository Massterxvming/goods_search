import 'package:flutter/material.dart';

import '../../../../domain/models/price_history.dart';

String monthLabel(DateTime value) =>
    '${value.year}.${value.month.toString().padLeft(2, '0')}';

class PriceRangeSelector extends StatelessWidget {
  const PriceRangeSelector({
    super.key,
    required this.range,
    required this.custom,
    required this.enabled,
    required this.onChanged,
  });
  final PriceHistoryRange range;
  final bool custom;
  final bool enabled;
  final void Function(PriceHistoryRange range, bool custom) onChanged;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        '想看多久的变化？',
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 10),
      Wrap(
        spacing: 7,
        runSpacing: 7,
        children: [
          for (final preset in const {
            3: '近3个月',
            6: '近6个月',
            12: '近1年',
            24: '近2年',
          }.entries)
            ChoiceChip(
              key: ValueKey('price-range-${preset.key}'),
              label: Text(preset.value, style: const TextStyle(fontSize: 11)),
              selected: !custom && range.monthCount == preset.key,
              showCheckmark: false,
              onSelected: enabled
                  ? (_) =>
                        onChanged(PriceHistoryRange.recent(preset.key), false)
                  : null,
            ),
          ChoiceChip(
            key: const Key('price-range-custom'),
            label: const Text('自定义月份', style: TextStyle(fontSize: 11)),
            selected: custom,
            showCheckmark: false,
            avatar: const Icon(Icons.date_range_outlined, size: 15),
            onSelected: enabled
                ? (_) async {
                    final selected = await showDialog<PriceHistoryRange>(
                      context: context,
                      builder: (_) => _MonthRangeDialog(initial: range),
                    );
                    if (selected != null) onChanged(selected, true);
                  }
                : null,
          ),
        ],
      ),
      const SizedBox(height: 11),
      Text(
        '${monthLabel(range.startMonth)} — ${monthLabel(range.endMonth)} · 共${range.monthCount}个月',
        key: const Key('selected-price-range'),
        style: const TextStyle(fontSize: 11, color: Color(0xFF7C8980)),
      ),
    ],
  );
}

class _MonthRangeDialog extends StatefulWidget {
  const _MonthRangeDialog({required this.initial});
  final PriceHistoryRange initial;

  @override
  State<_MonthRangeDialog> createState() => _MonthRangeDialogState();
}

class _MonthRangeDialogState extends State<_MonthRangeDialog> {
  late DateTime _start = widget.initial.startMonth;
  late DateTime _end = widget.initial.endMonth;
  late final _months = List.generate(24, (i) {
    final current = PriceHistoryRange.recent(1).endMonth;
    return DateTime.utc(current.year, current.month - i);
  });

  @override
  Widget build(BuildContext context) {
    final valid = !_start.isAfter(_end);
    return AlertDialog(
      title: const Text('选择起止月份'),
      content: SizedBox(
        width: 350,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('最近24个月内，按自然月查询。', style: TextStyle(fontSize: 12)),
            const SizedBox(height: 24),
            DropdownButtonFormField<DateTime>(
              key: const Key('custom-start-month'),
              initialValue: _start,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: '开始月份',
                border: OutlineInputBorder(),
              ),
              items: _items(),
              onChanged: (value) {
                if (value != null) setState(() => _start = value);
              },
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<DateTime>(
              key: const Key('custom-end-month'),
              initialValue: _end,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: '结束月份',
                border: OutlineInputBorder(),
              ),
              items: _items(),
              onChanged: (value) {
                if (value != null) setState(() => _end = value);
              },
            ),
            const SizedBox(height: 14),
            Text(
              valid
                  ? '共${(_end.year - _start.year) * 12 + _end.month - _start.month + 1}个月（含起止月）'
                  : '开始月份不能晚于结束月份',
              style: TextStyle(
                fontSize: 12,
                color: valid
                    ? const Color(0xFF7C8980)
                    : Theme.of(context).colorScheme.error,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        FilledButton(
          key: const Key('confirm-price-range'),
          onPressed: valid
              ? () => Navigator.pop(
                  context,
                  PriceHistoryRange(startMonth: _start, endMonth: _end),
                )
              : null,
          child: const Text('使用此区间'),
        ),
      ],
    );
  }

  List<DropdownMenuItem<DateTime>> _items() => _months
      .map(
        (month) => DropdownMenuItem(
          value: month,
          child: Text(
            '${month.year}年${month.month.toString().padLeft(2, '0')}月',
          ),
        ),
      )
      .toList();
}
