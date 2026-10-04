import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/canteen_theme_extension.dart';
import '../../../../core/widgets/modal_action_bar.dart';
import '../../../../core/widgets/squadron_dropdown.dart';
import '../../providers/canteen_register_provider.dart';
import '../../providers/canteen_structure_provider.dart';

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
    final theme = context.canteenTheme;

    final daysInMonth = DateTime(state.selectedYear, state.selectedMonth + 1, 0).day;
    final sqnMonthGrandTotal = state.getSquadronMonthTotal(
      state.activeEntry,
      state.selectedSquadron,
      state.selectedYear,
      state.selectedMonth,
    );
    final sqnPreDueTotal = state.getSquadronPreDueTotal(state.activeEntry, state.selectedSquadron);
    final sqnPaidTotal = state.getSquadronPaidTotal(state.activeEntry, state.selectedSquadron);
    final sqnNetDueTotal = state.getSquadronNetDueTotal(state.activeEntry, state.selectedSquadron, state.selectedYear, state.selectedMonth);

    final monthsList = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final isMobile = screenWidth < 850;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Tactical Squadron Selection Dropdown
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: SquadronDropdown(
                squadrons: ref.watch(canteenStructureProvider).squadrons,
                selectedSquadron: state.selectedSquadron,
                onChanged: (sqn) => notifier.setSelectedSquadron(sqn),
                dayTotal: sqnMonthGrandTotal,
                showDayTotal: false,
              ),
            ),

            // 2. Compact Period Navigator & View Switch
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 8 : 16,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: theme.surface,
                border: Border(bottom: BorderSide(color: theme.cardBorderLight)),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Text('PERIOD:', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: theme.textSecondary)),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.cardBackground,
                        border: Border.all(color: theme.cardBorder),
                      ),
                      child: DropdownButton<int>(
                        value: state.selectedMonth,
                        dropdownColor: theme.surface,
                        isDense: true,
                        underline: const SizedBox(),
                        items: List.generate(12, (i) => i + 1).map((m) {
                          return DropdownMenuItem(
                            value: m,
                            child: Text(monthsList[m - 1], style: TextStyle(fontSize: 11, color: theme.textPrimary)),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) notifier.setSelectedMonth(state.selectedYear, val);
                        },
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.cardBackground,
                        border: Border.all(color: theme.cardBorder),
                      ),
                      child: DropdownButton<int>(
                        value: state.selectedYear,
                        dropdownColor: theme.surface,
                        isDense: true,
                        underline: const SizedBox(),
                        items: [2025, 2026, 2027].map((y) {
                          return DropdownMenuItem(
                            value: y,
                            child: Text('$y', style: TextStyle(fontSize: 11, color: theme.textPrimary)),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) notifier.setSelectedMonth(val, state.selectedMonth);
                        },
                      ),
                    ),

                    const SizedBox(width: 14),

                    // Mode Toggle Button
                    InkWell(
                      onTap: () => setState(() => _forceMatrixTable = !_forceMatrixTable),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                              _forceMatrixTable ? 'CARD VIEW' : 'FULL TABLE',
                              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 3. Compact Squadron Accounting Strip (No horizontal scrolling on mobile)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              color: AppColors.bafNavy,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('PRE DUE', style: TextStyle(fontSize: 8, color: Colors.white70, fontWeight: FontWeight.bold)),
                        Text('৳ ${currencyFormat.format(sqnPreDueTotal)}', style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900, color: AppColors.balanceAlert)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('MONTH SPEND', style: TextStyle(fontSize: 8, color: Colors.white70, fontWeight: FontWeight.bold)),
                        Text('৳ ${currencyFormat.format(sqnMonthGrandTotal)}', style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900, color: Colors.white)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('PAID', style: TextStyle(fontSize: 8, color: Colors.white70, fontWeight: FontWeight.bold)),
                        Text('৳ ${currencyFormat.format(sqnPaidTotal)}', style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900, color: Colors.greenAccent)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('NET DUE', style: TextStyle(fontSize: 8, color: AppColors.bafGold, fontWeight: FontWeight.bold)),
                        Text('৳ ${currencyFormat.format(sqnNetDueTotal)}', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900, color: AppColors.bafGold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 4. Content Area
            Expanded(
              child: (isMobile && !_forceMatrixTable)
                  ? _buildMobileRoomMonthlyCards(context, state, daysInMonth, currencyFormat)
                  : _buildFullMatrixTable(context, state, daysInMonth, currencyFormat),
            ),
          ],
        );
      },
    );
  }

  /// Mobile-first Room Monthly Summary Cards with Tactical Styling
  Widget _buildMobileRoomMonthlyCards(
    BuildContext context,
    CanteenRegisterState state,
    int daysInMonth,
    NumberFormat currencyFormat,
  ) {
    final theme = context.canteenTheme;
    final rooms = ref.watch(canteenStructureProvider).getRoomsForSquadron(state.selectedSquadron);

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, AppSpacing.bottomInset),
      itemCount: rooms.length,
      itemBuilder: (context, idx) {
        final room = rooms[idx];
        final rank = state.getRoomRank(state.activeEntry, state.selectedSquadron, room);
        final preDue = state.getRoomPreDue(state.activeEntry, state.selectedSquadron, room);
        final paid = state.getRoomPaid(state.activeEntry, state.selectedSquadron, room);
        final roomTotal = state.getRoomMonthTotal(
          state.activeEntry,
          state.selectedSquadron,
          room,
          state.selectedYear,
          state.selectedMonth,
        );
        final grandTotal = preDue + roomTotal;
        final netDue = grandTotal - paid;

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

        return Padding(
          padding: const EdgeInsets.only(bottom: 7),
          child: Container(
            decoration: BoxDecoration(
              color: theme.cardBackground,
              border: Border.all(
                color: netDue > 0 ? theme.accentGold : theme.cardBorder,
                width: netDue > 0 ? 1.5 : 1.0,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        color: AppColors.bafNavy,
                        child: Text(
                          '#${idx + 1}',
                          style: const TextStyle(
                            color: AppColors.bafGold,
                            fontWeight: FontWeight.bold,
                            fontSize: 9.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        room,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: theme.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        color: theme.tableHighlight,
                        child: Text(
                          rank,
                          style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: theme.accentGold),
                        ),
                      ),
                      const Spacer(),
                      InkWell(
                        onTap: () => _showRoomAccountEditModal(context, ref, room, preDue, paid, rank),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: theme.tableHighlight,
                            border: Border.all(color: theme.accentGold),
                          ),
                          child: Text('EDIT ACCOUNT', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: theme.accentGold)),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Calculations Row (Pre Due, Month, Paid, Net Due)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    color: theme.surface,
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('PRE DUE', style: TextStyle(fontSize: 8, color: theme.textSecondary, fontWeight: FontWeight.bold)),
                              Text('৳ ${currencyFormat.format(preDue)}', style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.balanceAlert)),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('THIS MONTH', style: TextStyle(fontSize: 8, color: theme.textSecondary, fontWeight: FontWeight.bold)),
                              Text('৳ ${currencyFormat.format(roomTotal)}', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: theme.debit)),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('PAID', style: TextStyle(fontSize: 8, color: theme.textSecondary, fontWeight: FontWeight.bold)),
                              Text('৳ ${currencyFormat.format(paid)}', style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.creditGreen)),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('NET DUE', style: TextStyle(fontSize: 8, color: theme.textPrimary, fontWeight: FontWeight.bold)),
                              Text('৳ ${currencyFormat.format(netDue)}', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900, color: netDue > 0 ? theme.debit : theme.accentGold)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Active Days & Status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$activeDays visit${activeDays == 1 ? '' : 's'} recorded',
                        style: const TextStyle(fontSize: 9, color: AppColors.textMuted),
                      ),
                      Text(
                        netDue <= 0 ? 'CLEARED' : 'PENDING',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: netDue <= 0 ? AppColors.cleared : AppColors.balanceAlert,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Full Cross-Sectional Table matching the scanned Canteen Ledger PDF
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
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.ledgerSurface,
            border: Border.all(color: AppColors.ledgerBorder, width: 1.0),
          ),
          child: DataTable(
            headingRowHeight: 36,
            dataRowMinHeight: 34,
            dataRowMaxHeight: 40,
            horizontalMargin: 8,
            columnSpacing: 8,
            headingRowColor: WidgetStateProperty.all(AppColors.bafNavy),
            columns: [
              const DataColumn(label: Text('RK', style: TextStyle(color: AppColors.bafGold, fontWeight: FontWeight.bold, fontSize: 9.5))),
              const DataColumn(label: Text('ROOM / NAME', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10.5))),
              const DataColumn(label: Text('PRE DUE', style: TextStyle(color: AppColors.bafGold, fontWeight: FontWeight.bold, fontSize: 9.5))),
              ...List.generate(daysInMonth, (d) {
                final dayNum = d + 1;
                return DataColumn(
                  label: Text(
                    '$dayNum',
                    style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                );
              }),
              const DataColumn(label: Text('MONTH', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Colors.white70))),
              const DataColumn(label: Text('TOTAL', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.bafGold))),
              const DataColumn(label: Text('PAID', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: AppColors.creditGreen))),
              const DataColumn(label: Text('DUE', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900, color: Colors.white))),
            ],
            rows: [
              // Each Room Row
              ...List.generate(
                ref.watch(canteenStructureProvider).getRoomsForSquadron(state.selectedSquadron).length,
                (idx) {
                  final room = ref.watch(canteenStructureProvider).getRoomsForSquadron(state.selectedSquadron)[idx];
                  final isEven = idx % 2 == 0;
                final rank = state.getRoomRank(state.activeEntry, state.selectedSquadron, room);
                final preDue = state.getRoomPreDue(state.activeEntry, state.selectedSquadron, room);
                final paid = state.getRoomPaid(state.activeEntry, state.selectedSquadron, room);
                final roomMonthTotal = state.getRoomMonthTotal(
                  state.activeEntry,
                  state.selectedSquadron,
                  room,
                  state.selectedYear,
                  state.selectedMonth,
                );
                final grandTotal = preDue + roomMonthTotal;
                final netDue = grandTotal - paid;

                return DataRow(
                  color: WidgetStateProperty.all(
                    isEven ? AppColors.ledgerSurface : AppColors.ledgerStripe,
                  ),
                  cells: [
                    // Rank
                    DataCell(
                      InkWell(
                        onTap: () => _showRoomAccountEditModal(context, ref, room, preDue, paid, rank),
                        child: Text(
                          rank,
                          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                        ),
                      ),
                    ),
                    // Room
                    DataCell(
                      InkWell(
                        onTap: () => _showRoomAccountEditModal(context, ref, room, preDue, paid, rank),
                        child: Text(
                          room,
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            color: AppColors.bafNavy,
                          ),
                        ),
                      ),
                    ),
                    // Pre Due
                    DataCell(
                      InkWell(
                        onTap: () => _showRoomAccountEditModal(context, ref, room, preDue, paid, rank),
                        child: Text(
                          preDue > 0 ? preDue.toStringAsFixed(0) : '-',
                          style: const TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                            color: AppColors.balanceAlert,
                          ),
                        ),
                      ),
                    ),
                    // Days 1..31
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
                                fontSize: 9.5,
                                fontWeight: hasVal ? FontWeight.bold : FontWeight.normal,
                                color: hasVal ? AppColors.debitRed : AppColors.textMuted,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                    // Month Spending
                    DataCell(
                      Text(
                        currencyFormat.format(roomMonthTotal),
                        style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: AppColors.debitRed),
                      ),
                    ),
                    // Grand Total
                    DataCell(
                      Text(
                        currencyFormat.format(grandTotal),
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.bafNavy),
                      ),
                    ),
                    // Paid
                    DataCell(
                      InkWell(
                        onTap: () => _showRoomAccountEditModal(context, ref, room, preDue, paid, rank),
                        child: Text(
                          paid > 0 ? currencyFormat.format(paid) : '-',
                          style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: AppColors.creditGreen),
                        ),
                      ),
                    ),
                    // Net Due
                    DataCell(
                      Text(
                        currencyFormat.format(netDue),
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w900,
                          color: netDue > 0 ? AppColors.debitRed : AppColors.cleared,
                        ),
                      ),
                    ),
                  ],
                );
              }),

              // Grand Total Footer Row
              DataRow(
                color: WidgetStateProperty.all(AppColors.bafNavy),
                cells: [
                  const DataCell(
                    Text(
                      'TOTAL',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w900,
                        color: AppColors.bafGold,
                      ),
                    ),
                  ),
                  const DataCell(
                    Text(
                      'GRAND TOTAL',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w900,
                        color: AppColors.bafGold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  DataCell(
                    Text(
                      currencyFormat.format(state.getSquadronPreDueTotal(state.activeEntry, state.selectedSquadron)),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
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
                    final hasVal = dayTotal > 0;

                    return DataCell(
                      Text(
                        hasVal ? dayTotal.toStringAsFixed(0) : '-',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: hasVal ? Colors.white : Colors.white38,
                        ),
                      ),
                    );
                  }),
                  DataCell(
                    Text(
                      currencyFormat.format(state.getSquadronMonthTotal(state.activeEntry, state.selectedSquadron, state.selectedYear, state.selectedMonth)),
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white),
                    ),
                  ),
                  DataCell(
                    Text(
                      currencyFormat.format(state.getSquadronGrandTotal(state.activeEntry, state.selectedSquadron, state.selectedYear, state.selectedMonth)),
                      style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900, color: AppColors.bafGold),
                    ),
                  ),
                  DataCell(
                    Text(
                      currencyFormat.format(state.getSquadronPaidTotal(state.activeEntry, state.selectedSquadron)),
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.greenAccent),
                    ),
                  ),
                  DataCell(
                    Text(
                      currencyFormat.format(state.getSquadronNetDueTotal(state.activeEntry, state.selectedSquadron, state.selectedYear, state.selectedMonth)),
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.white),
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

  void _showRoomAccountEditModal(
    BuildContext context,
    WidgetRef ref,
    String room,
    double currentPreDue,
    double currentPaid,
    String currentRank,
  ) {
    final theme = context.canteenTheme;
    final preDueCtrl = TextEditingController(text: currentPreDue > 0 ? currentPreDue.toStringAsFixed(2) : '');
    final paidCtrl = TextEditingController(text: currentPaid > 0 ? currentPaid.toStringAsFixed(2) : '');
    final rankCtrl = TextEditingController(text: currentRank);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final bottomInset = MediaQuery.of(ctx).viewInsets.bottom;
        return Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 420),
              decoration: BoxDecoration(
                color: theme.surface,
                border: Border.all(color: AppColors.bafNavy, width: 2),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      color: AppColors.bafNavy,
                      child: Row(
                        children: [
                          const Icon(Icons.account_balance_wallet, color: AppColors.bafGold, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'ACCOUNT SETTINGS • $room',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white, size: 18),
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                            onPressed: () => Navigator.of(ctx).pop(),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('RANK / DESIGNATION (e.g. Rect Rep, Sgt, WO, Civ):', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: theme.textSecondary)),
                          const SizedBox(height: 4),
                          TextField(controller: rankCtrl, decoration: const InputDecoration(isDense: true)),
                          const SizedBox(height: 12),
                          Text('PREVIOUS DUE (TK):', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: theme.textSecondary)),
                          const SizedBox(height: 4),
                          TextField(controller: preDueCtrl, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(isDense: true, prefixText: '৳ ')),
                          const SizedBox(height: 12),
                          Text('PAID AMOUNT (TK):', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: theme.textSecondary)),
                          const SizedBox(height: 4),
                          TextField(controller: paidCtrl, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(isDense: true, prefixText: '৳ ')),
                          const SizedBox(height: 16),
                          ModalActionBar(
                            cancelLabel: 'CANCEL',
                            confirmLabel: 'SAVE ACCOUNT',
                            onCancel: () => Navigator.of(ctx).pop(),
                            onConfirm: () {
                              final preVal = double.tryParse(preDueCtrl.text.trim()) ?? 0.0;
                              final paidVal = double.tryParse(paidCtrl.text.trim()) ?? 0.0;
                              final rk = rankCtrl.text.trim();
                              ref.read(canteenRegisterProvider.notifier).updateRoomPreDue(room, preVal);
                              ref.read(canteenRegisterProvider.notifier).updateRoomPaid(room, paidVal);
                              if (rk.isNotEmpty) {
                                ref.read(canteenRegisterProvider.notifier).updateRoomRank(room, rk);
                              }
                              Navigator.of(ctx).pop();
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showQuickEditModal(
    BuildContext context,
    WidgetRef ref,
    String room,
    DateTime date,
    double currentVal,
  ) {
    final theme = context.canteenTheme;
    final controller = TextEditingController(
      text: currentVal > 0 ? currentVal.toStringAsFixed(2) : '',
    );
    final dStr = DateFormat('dd MMM yyyy').format(date);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final bottomInset = MediaQuery.of(ctx).viewInsets.bottom;
        return Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 380),
              decoration: BoxDecoration(
                color: theme.surface,
                border: Border.all(color: AppColors.bafNavy, width: 2),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      color: AppColors.bafNavy,
                      child: Row(
                        children: [
                          const Icon(Icons.edit_note, color: AppColors.bafGold, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'QUICK ENTRY • $room ($dStr)',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white, size: 18),
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                            onPressed: () => Navigator.of(ctx).pop(),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('PRICE VALUE (TK):', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: theme.textSecondary)),
                          const SizedBox(height: 6),
                          TextField(
                            controller: controller,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            autofocus: true,
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.debit),
                            decoration: const InputDecoration(
                              prefixText: '৳ ',
                              hintText: '0.00',
                            ),
                          ),
                          const SizedBox(height: 16),
                          ModalActionBar(
                            cancelLabel: 'CANCEL',
                            confirmLabel: 'SAVE PRICE',
                            onCancel: () => Navigator.of(ctx).pop(),
                            onConfirm: () {
                              final val = double.tryParse(controller.text.trim()) ?? 0.0;
                              ref.read(canteenRegisterProvider.notifier).recordRoomExpense(
                                room: room,
                                amount: val,
                                date: date,
                              );
                              Navigator.of(ctx).pop();
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
