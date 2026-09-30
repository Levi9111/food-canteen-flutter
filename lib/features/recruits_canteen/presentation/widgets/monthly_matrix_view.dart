import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/animations/smooth_transitions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../constants/canteen_constants.dart';
import '../../providers/canteen_register_provider.dart';

class MonthlyMatrixView extends ConsumerWidget {
  const MonthlyMatrixView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(canteenRegisterProvider);
    final notifier = ref.read(canteenRegisterProvider.notifier);
    final currencyFormat = NumberFormat('#,##0.00', 'en_US');
    final shortCurrency = NumberFormat('#,##0', 'en_US');

    final daysInMonth = DateTime(state.selectedYear, state.selectedMonth + 1, 0).day;
    final sqnMonthGrandTotal = state.getSquadronMonthTotal(
      state.activeEntry,
      state.selectedSquadron,
      state.selectedYear,
      state.selectedMonth,
    );

    final monthsList = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Filter & Month Command Ribbon
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: const BoxDecoration(
            color: AppColors.ledgerSurface,
            border: Border(bottom: BorderSide(color: AppColors.ledgerBorderLight)),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
            children: [
              // Month Selector
              const Text(
                'ACCOUNTING MONTH:',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 130,
                child: DropdownButtonFormField<int>(
                  isDense: true,
                  initialValue: state.selectedMonth,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  ),
                  items: List.generate(12, (i) => i + 1).map((m) {
                    return DropdownMenuItem(
                      value: m,
                      child: Text(monthsList[m - 1], style: const TextStyle(fontSize: 12)),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) notifier.setSelectedMonth(state.selectedYear, val);
                  },
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 90,
                child: DropdownButtonFormField<int>(
                  isDense: true,
                  initialValue: state.selectedYear,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  ),
                  items: [2025, 2026, 2027].map((y) {
                    return DropdownMenuItem(
                      value: y,
                      child: Text('$y', style: const TextStyle(fontSize: 12)),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) notifier.setSelectedMonth(val, state.selectedMonth);
                  },
                ),
              ),

              const SizedBox(width: 24),

              // Squadron Selector
              const Text(
                'SQUADRON:',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 8),
              Row(
                children: CanteenConstants.squadrons.map((sqn) {
                  final isSelected = sqn == state.selectedSquadron;
                  return Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: InkWell(
                      onTap: () => notifier.setSelectedSquadron(sqn),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeOutCubic,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.bafDeepBlue : AppColors.ledgerSurface,
                          border: Border.all(
                            color: isSelected ? AppColors.bafDeepBlue : AppColors.ledgerBorder,
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Text(
                          '$sqn Sqn',
                          style: TextStyle(
                            color: isSelected ? Colors.white : AppColors.textPrimary,
                            fontSize: 11,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(width: 24),

              // Quick Info
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                color: AppColors.bafNavy,
                child: Text(
                  'ENTRY ${state.activeEntry} • ${monthsList[state.selectedMonth - 1].toUpperCase()} ${state.selectedYear}',
                  style: const TextStyle(
                    color: AppColors.bafGold,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

        // Monthly Summary Calculation Header Ribbon
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: AppColors.bafLightBlue,
          child: Row(
            children: [
              SmoothAnimatedMetricCard(
                title: 'TOTAL ROOMS TRACKED',
                value: CanteenConstants.rooms.length.toDouble(),
                prefix: '',
                textColor: AppColors.bafNavy,
              ),
              const SizedBox(width: 12),
              SmoothAnimatedMetricCard(
                title: 'CALENDAR DAYS IN MONTH',
                value: daysInMonth.toDouble(),
                prefix: '',
                textColor: AppColors.textPrimary,
              ),
              const SizedBox(width: 12),
              SmoothAnimatedMetricCard(
                title: '${state.selectedSquadron.toUpperCase()} SQN MONTHLY TOTAL',
                value: sqnMonthGrandTotal,
                textColor: AppColors.debitRed,
                highlight: true,
              ),
            ],
          ),
        ),

        // High-Density Cross-Sectional Grid Matrix
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.ledgerSurface,
                  border: Border.all(color: AppColors.ledgerBorder),
                ),
                child: DataTable(
                  headingRowHeight: 36,
                  dataRowMinHeight: 38,
                  dataRowMaxHeight: 42,
                  horizontalMargin: 8,
                  columnSpacing: 10,
                  headingRowColor: WidgetStateProperty.all(AppColors.bafNavy),
                  columns: [
                    const DataColumn(label: Text('ROOM')),
                    ...List.generate(daysInMonth, (d) {
                      final dayNum = d + 1;
                      return DataColumn(
                        label: Text(
                          'D$dayNum',
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      );
                    }),
                    const DataColumn(
                      label: Text(
                        'TOTAL (TK)',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppColors.bafGold,
                        ),
                      ),
                    ),
                  ],
                  rows: [
                    // Each Room Row
                    ...List.generate(CanteenConstants.rooms.length, (idx) {
                      final room = CanteenConstants.rooms[idx];
                      final isEven = idx % 2 == 0;
                      final roomMonthTotal = state.getRoomMonthTotal(
                        state.activeEntry,
                        state.selectedSquadron,
                        room,
                        state.selectedYear,
                        state.selectedMonth,
                      );

                      return DataRow(
                        color: WidgetStateProperty.all(
                          isEven ? AppColors.ledgerSurface : AppColors.ledgerStripe,
                        ),
                        cells: [
                          DataCell(
                            Text(
                              room,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.bafNavy,
                              ),
                            ),
                          ),
                          ...List.generate(daysInMonth, (d) {
                            final date = DateTime(state.selectedYear, state.selectedMonth, d + 1);
                            final expense = state.getExpense(
                              state.activeEntry,
                              state.selectedSquadron,
                              room,
                              date,
                            );
                            final amt = expense?.amount ?? 0.0;
                            final hasVal = amt > 0;

                            return DataCell(
                              InkWell(
                                onTap: () {
                                  _showQuickDayEdit(context, ref, room, date, expense);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                  decoration: hasVal
                                      ? BoxDecoration(
                                          color: AppColors.bafLightBlue.withAlpha(120),
                                          border: Border.all(color: AppColors.bafSkyBlue.withAlpha(80)),
                                        )
                                      : null,
                                  child: Text(
                                    hasVal ? shortCurrency.format(amt) : '·',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: hasVal ? FontWeight.bold : FontWeight.normal,
                                      color: hasVal ? AppColors.debitRed : AppColors.textMuted,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                              color: AppColors.bafLightBlue,
                              child: Text(
                                '৳ ${currencyFormat.format(roomMonthTotal)}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.bafNavy,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),

                    // Summary Row (Day Totals)
                    DataRow(
                      color: WidgetStateProperty.all(AppColors.bafLightBlue),
                      cells: [
                        const DataCell(
                          Text(
                            'DAY SUM (TK)',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: AppColors.bafNavy,
                            ),
                          ),
                        ),
                        ...List.generate(daysInMonth, (d) {
                          final date = DateTime(state.selectedYear, state.selectedMonth, d + 1);
                          final daySum = state.getSquadronDayTotal(
                            state.activeEntry,
                            state.selectedSquadron,
                            date,
                          );
                          return DataCell(
                            Text(
                              daySum > 0 ? shortCurrency.format(daySum) : '0',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                color: daySum > 0 ? AppColors.bafDeepBlue : AppColors.textMuted,
                              ),
                            ),
                          );
                        }),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                            color: AppColors.bafNavy,
                            child: Text(
                              '৳ ${currencyFormat.format(sqnMonthGrandTotal)}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: AppColors.bafGold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showQuickDayEdit(
    BuildContext context,
    WidgetRef ref,
    String room,
    DateTime date,
    dynamic existingExpense,
  ) {
    final state = ref.read(canteenRegisterProvider);
    final controller = TextEditingController(
      text: existingExpense != null && existingExpense.amount > 0
          ? existingExpense.amount.toStringAsFixed(2)
          : '',
    );
    final dateFormat = DateFormat('dd MMMM yyyy');

    showSmoothMilitaryDialog(
      context: context,
      child: Dialog(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        child: Container(
          width: 400,
          decoration: BoxDecoration(
            color: AppColors.ledgerSurface,
            border: Border.all(color: AppColors.bafNavy, width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                color: AppColors.bafNavy,
                child: Text(
                  '$room • ${dateFormat.format(date)}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SQUADRON: ${state.selectedSquadron.toUpperCase()} • ENTRY ${state.activeEntry}',
                      style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    const Text('PRICE VALUE (TK):', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: controller,
                      autofocus: true,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.debitRed),
                      decoration: const InputDecoration(prefixText: '৳ '),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('CANCEL'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () async {
                            final val = double.tryParse(controller.text.trim()) ?? 0.0;
                            await ref.read(canteenRegisterProvider.notifier).recordRoomExpense(
                              room: room,
                              amount: val,
                              date: date,
                            );
                            if (context.mounted) Navigator.of(context).pop();
                          },
                          child: const Text('UPDATE'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
