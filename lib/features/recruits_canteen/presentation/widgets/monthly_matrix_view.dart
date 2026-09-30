import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/animations/smooth_transitions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../constants/canteen_constants.dart';
import '../../providers/canteen_register_provider.dart';

class MonthlyMatrixView extends ConsumerStatefulWidget {
  const MonthlyMatrixView({super.key});

  @override
  ConsumerState<MonthlyMatrixView> createState() => _MonthlyMatrixViewState();
}

class _MonthlyMatrixViewState extends ConsumerState<MonthlyMatrixView> {
  bool _forceMatrixTable = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(canteenRegisterProvider);
    final notifier = ref.read(canteenRegisterProvider.notifier);
    final currencyFormat = NumberFormat('#,##0.00', 'en_US');
    final isMobile = MediaQuery.of(context).size.width < 768;

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
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 10 : 16,
            vertical: isMobile ? 8 : 10,
          ),
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
                  'MONTH:',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.ledgerSurface,
                    border: Border.all(color: AppColors.ledgerBorder),
                  ),
                  child: DropdownButton<int>(
                    value: state.selectedMonth,
                    isDense: true,
                    underline: const SizedBox(),
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
                const SizedBox(width: 6),
                // Year Selector
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.ledgerSurface,
                    border: Border.all(color: AppColors.ledgerBorder),
                  ),
                  child: DropdownButton<int>(
                    value: state.selectedYear,
                    isDense: true,
                    underline: const SizedBox(),
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

                const SizedBox(width: 14),

                // Squadron Selector
                const Text(
                  'SQN:',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 6),
                Row(
                  children: CanteenConstants.squadrons.map((sqn) {
                    final isSelected = sqn == state.selectedSquadron;
                    return Padding(
                      padding: const EdgeInsets.only(left: 4),
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

                const SizedBox(width: 14),

                // Quick Info
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  color: AppColors.bafNavy,
                  child: Text(
                    'ENTRY ${state.activeEntry} • ${monthsList[state.selectedMonth - 1].toUpperCase()} ${state.selectedYear}',
                    style: const TextStyle(
                      color: AppColors.bafGold,
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Monthly Summary Calculation Header Ribbon (Responsive)
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 12 : 16,
            vertical: isMobile ? 8 : 10,
          ),
          color: AppColors.bafLightBlue,
          child: isMobile
              ? Column(
                  children: [
                    Row(
                      children: [
                        SmoothAnimatedMetricCard(
                          title: 'TOTAL ROOMS TRACKED',
                          value: CanteenConstants.rooms.length.toDouble(),
                          prefix: '',
                          textColor: AppColors.bafNavy,
                        ),
                        const SizedBox(width: 8),
                        SmoothAnimatedMetricCard(
                          title: 'CALENDAR DAYS',
                          value: daysInMonth.toDouble(),
                          prefix: '',
                          textColor: AppColors.textPrimary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SmoothAnimatedMetricCard(
                      title: '${state.selectedSquadron.toUpperCase()} SQN MONTHLY TOTAL',
                      value: sqnMonthGrandTotal,
                      textColor: AppColors.debitRed,
                      highlight: true,
                      useExpanded: false,
                    ),
                  ],
                )
              : Row(
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

        // Section Bar with View Switcher on Mobile
        if (isMobile)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            color: AppColors.ledgerSurface,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    _forceMatrixTable ? 'FULL 31-DAY MATRIX VIEW' : 'ROOM-WISE MONTHLY SUMMARY',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => setState(() => _forceMatrixTable = !_forceMatrixTable),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _forceMatrixTable ? AppColors.bafDeepBlue : AppColors.bafNavy,
                      border: Border.all(color: AppColors.bafGold),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _forceMatrixTable ? Icons.view_agenda : Icons.grid_on,
                          size: 13,
                          color: AppColors.bafGold,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _forceMatrixTable ? 'ROOM CARDS' : 'FULL MATRIX',
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Content Area: Mobile Cards or Full Cross-Sectional Table
        Expanded(
          child: (isMobile && !_forceMatrixTable)
              ? _buildMobileRoomMonthlyCards(context, state, daysInMonth, currencyFormat)
              : _buildFullMatrixTable(context, state, daysInMonth, currencyFormat),
        ),
      ],
    );
  }

  /// Mobile-first Room Monthly Summary Cards
  Widget _buildMobileRoomMonthlyCards(
    BuildContext context,
    CanteenRegisterState state,
    int daysInMonth,
    NumberFormat currencyFormat,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: CanteenConstants.rooms.length,
      itemBuilder: (context, idx) {
        final room = CanteenConstants.rooms[idx];
        final roomTotal = state.getRoomMonthTotal(
          state.activeEntry,
          state.selectedSquadron,
          room,
          state.selectedYear,
          state.selectedMonth,
        );

        // Count non-zero days
        int activeDays = 0;
        for (int d = 1; d <= daysInMonth; d++) {
          final exp = state.getExpense(
            state.activeEntry,
            state.selectedSquadron,
            room,
            DateTime(state.selectedYear, state.selectedMonth, d),
          );
          if (exp != null && exp.amount > 0) activeDays++;
        }

        final hasSpending = roomTotal > 0;

        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 8),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          color: hasSpending ? AppColors.bafLightBlue.withAlpha(50) : AppColors.ledgerSurface,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: hasSpending ? AppColors.bafNavy : AppColors.ledgerBorder,
                width: hasSpending ? 1.5 : 1,
              ),
            ),
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  color: AppColors.bafNavy,
                  child: Text(
                    '#${idx + 1}',
                    style: const TextStyle(color: AppColors.bafGold, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        room,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.bafNavy),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        activeDays > 0 ? '$activeDays active visiting days' : 'No visits recorded',
                        style: TextStyle(
                          fontSize: 11,
                          color: activeDays > 0 ? AppColors.textPrimary : AppColors.textMuted,
                          fontStyle: activeDays > 0 ? FontStyle.normal : FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('MONTH TOTAL', style: TextStyle(fontSize: 9.5, color: AppColors.textMuted, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(
                      '৳ ${currencyFormat.format(roomTotal)}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: hasSpending ? AppColors.debitRed : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Full 31-Day Cross-Sectional Grid Matrix
  Widget _buildFullMatrixTable(
    BuildContext context,
    CanteenRegisterState state,
    int daysInMonth,
    NumberFormat currencyFormat,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
          margin: const EdgeInsets.all(12),
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
                      final dayNum = d + 1;
                      final date = DateTime(state.selectedYear, state.selectedMonth, dayNum);
                      final expense = state.getExpense(
                        state.activeEntry,
                        state.selectedSquadron,
                        room,
                        date,
                      );
                      final hasVal = expense != null && expense.amount > 0;

                      return DataCell(
                        InkWell(
                          onTap: () => _showQuickEditModal(context, ref, room, date, expense?.amount ?? 0.0),
                          child: Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            color: hasVal ? AppColors.bafLightBlue.withAlpha(120) : Colors.transparent,
                            child: Text(
                              hasVal ? expense.amount.toStringAsFixed(0) : '-',
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
                      Text(
                        '৳ ${currencyFormat.format(roomMonthTotal)}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppColors.bafNavy,
                        ),
                      ),
                    ),
                  ],
                );
              }),

              // Daily Totals Footer Row
              DataRow(
                color: WidgetStateProperty.all(AppColors.bafNavy),
                cells: [
                  const DataCell(
                    Text(
                      'DAY TOTAL',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.bafGold,
                      ),
                    ),
                  ),
                  ...List.generate(daysInMonth, (d) {
                    final dayNum = d + 1;
                    final date = DateTime(state.selectedYear, state.selectedMonth, dayNum);
                    final dayTotal = state.getSquadronDayTotal(
                      state.activeEntry,
                      state.selectedSquadron,
                      date,
                    );
                    final hasTotal = dayTotal > 0;

                    return DataCell(
                      Container(
                        alignment: Alignment.center,
                        child: Text(
                          hasTotal ? dayTotal.toStringAsFixed(0) : '-',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: hasTotal ? Colors.white : Colors.white38,
                          ),
                        ),
                      ),
                    );
                  }),
                  DataCell(
                    Text(
                      '৳ ${currencyFormat.format(state.getSquadronMonthTotal(state.activeEntry, state.selectedSquadron, state.selectedYear, state.selectedMonth))}',
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w900,
                        color: AppColors.bafGold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showQuickEditModal(
    BuildContext context,
    WidgetRef ref,
    String room,
    DateTime date,
    double currentAmt,
  ) {
    final state = ref.read(canteenRegisterProvider);
    final controller = TextEditingController(
      text: currentAmt > 0 ? currentAmt.toStringAsFixed(2) : '',
    );
    final dateFormat = DateFormat('dd MMMM yyyy');

    showSmoothMilitaryDialog(
      context: context,
      child: Dialog(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
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
