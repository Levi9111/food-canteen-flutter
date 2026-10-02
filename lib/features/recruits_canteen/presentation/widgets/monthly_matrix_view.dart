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
            // 1. Non-Scrollable Responsive 4-Squadron Segmented Bar (Zero scroll conflicts)
            Container(
              color: AppColors.bafNavy,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: CanteenConstants.squadrons.map((sqn) {
                  final isSelected = sqn == state.selectedSquadron;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: InkWell(
                        onTap: () => notifier.setSelectedSquadron(sqn),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 7),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.bafGold : AppColors.bafDeepBlue,
                            border: Border.all(
                              color: isSelected ? AppColors.bafGold : AppColors.bafDeepBlue,
                              width: 1,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            isMobile ? sqn.split(' ').first.toUpperCase() : '$sqn SQN',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isSelected ? AppColors.bafNavy : Colors.white,
                              fontSize: isMobile ? 10.5 : 12,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            // 2. Compact Period Navigator & View Switch
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 8 : 16,
                vertical: 6,
              ),
              decoration: const BoxDecoration(
                color: AppColors.ledgerSurface,
                border: Border(bottom: BorderSide(color: AppColors.ledgerBorderLight)),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    const Text('PERIOD:', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: AppColors.ledgerBorder),
                      ),
                      child: DropdownButton<int>(
                        value: state.selectedMonth,
                        isDense: true,
                        underline: const SizedBox(),
                        items: List.generate(12, (i) => i + 1).map((m) {
                          return DropdownMenuItem(
                            value: m,
                            child: Text(monthsList[m - 1], style: const TextStyle(fontSize: 11)),
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
                        color: Colors.white,
                        border: Border.all(color: AppColors.ledgerBorder),
                      ),
                      child: DropdownButton<int>(
                        value: state.selectedYear,
                        isDense: true,
                        underline: const SizedBox(),
                        items: [2025, 2026, 2027].map((y) {
                          return DropdownMenuItem(
                            value: y,
                            child: Text('$y', style: const TextStyle(fontSize: 11)),
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
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      itemCount: CanteenConstants.rooms.length,
      itemBuilder: (context, idx) {
        final room = CanteenConstants.rooms[idx];
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
              color: Colors.white,
              border: Border.all(
                color: netDue > 0 ? AppColors.bafGold : AppColors.ledgerBorder,
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
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: AppColors.bafNavy,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        color: AppColors.bafLightBlue,
                        child: Text(
                          rank,
                          style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: AppColors.bafDeepBlue),
                        ),
                      ),
                      const Spacer(),
                      InkWell(
                        onTap: () => _showRoomAccountEditModal(context, ref, room, preDue, paid, rank),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.bafLightBlue,
                            border: Border.all(color: AppColors.bafDeepBlue),
                          ),
                          child: const Text('EDIT ACCOUNT', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.bafDeepBlue)),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Calculations Row (Pre Due, Month, Paid, Net Due)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    color: AppColors.ledgerBackground,
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('PRE DUE', style: TextStyle(fontSize: 8, color: AppColors.textMuted, fontWeight: FontWeight.bold)),
                              Text('৳ ${currencyFormat.format(preDue)}', style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.balanceAlert)),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('THIS MONTH', style: TextStyle(fontSize: 8, color: AppColors.textMuted, fontWeight: FontWeight.bold)),
                              Text('৳ ${currencyFormat.format(roomTotal)}', style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.debitRed)),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('PAID', style: TextStyle(fontSize: 8, color: AppColors.textMuted, fontWeight: FontWeight.bold)),
                              Text('৳ ${currencyFormat.format(paid)}', style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.creditGreen)),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('NET DUE', style: TextStyle(fontSize: 8, color: AppColors.bafNavy, fontWeight: FontWeight.bold)),
                              Text('৳ ${currencyFormat.format(netDue)}', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900, color: AppColors.bafNavy)),
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
              ...List.generate(CanteenConstants.rooms.length, (idx) {
                final room = CanteenConstants.rooms[idx];
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
    final preDueCtrl = TextEditingController(text: currentPreDue > 0 ? currentPreDue.toStringAsFixed(2) : '');
    final paidCtrl = TextEditingController(text: currentPaid > 0 ? currentPaid.toStringAsFixed(2) : '');
    final rankCtrl = TextEditingController(text: currentRank);

    showSmoothMilitaryDialog(
      context: context,
      child: Dialog(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        child: Container(
          width: 360,
          decoration: BoxDecoration(
            color: AppColors.ledgerSurface,
            border: Border.all(color: AppColors.bafNavy, width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                color: AppColors.bafNavy,
                child: Text(
                  'ACCOUNT SETTINGS • $room',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('RANK / DESIGNATION (e.g. Rect Rep, Sgt, WO, Civ):', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    TextField(controller: rankCtrl, decoration: const InputDecoration(isDense: true)),
                    const SizedBox(height: 12),
                    const Text('PREVIOUS DUE (TK):', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    TextField(controller: preDueCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(isDense: true, prefixText: '৳ ')),
                    const SizedBox(height: 12),
                    const Text('PAID AMOUNT (TK):', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    TextField(controller: paidCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(isDense: true, prefixText: '৳ ')),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(onPressed: () => Navigator.of(context).pop(), child: const Text('CANCEL')),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            final preVal = double.tryParse(preDueCtrl.text.trim()) ?? 0.0;
                            final paidVal = double.tryParse(paidCtrl.text.trim()) ?? 0.0;
                            final rk = rankCtrl.text.trim();
                            ref.read(canteenRegisterProvider.notifier).updateRoomPreDue(room, preVal);
                            ref.read(canteenRegisterProvider.notifier).updateRoomPaid(room, paidVal);
                            if (rk.isNotEmpty) {
                              ref.read(canteenRegisterProvider.notifier).updateRoomRank(room, rk);
                            }
                            Navigator.of(context).pop();
                          },
                          child: const Text('SAVE ACCOUNT'),
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

  void _showQuickEditModal(
    BuildContext context,
    WidgetRef ref,
    String room,
    DateTime date,
    double currentVal,
  ) {
    final controller = TextEditingController(
      text: currentVal > 0 ? currentVal.toStringAsFixed(2) : '',
    );

    final dStr = DateFormat('dd MMM yyyy').format(date);

    showSmoothMilitaryDialog(
      context: context,
      child: Dialog(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        child: Container(
          width: 320,
          decoration: BoxDecoration(
            color: AppColors.ledgerSurface,
            border: Border.all(color: AppColors.bafNavy, width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                color: AppColors.bafNavy,
                child: Text(
                  'QUICK ENTRY • $room ($dStr)',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('PRICE VALUE (TK):', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: controller,
                      keyboardType: TextInputType.number,
                      autofocus: true,
                      decoration: const InputDecoration(
                        prefixText: '৳ ',
                        hintText: '0.00',
                      ),
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
                          onPressed: () {
                            final val = double.tryParse(controller.text.trim()) ?? 0.0;
                            ref.read(canteenRegisterProvider.notifier).recordRoomExpense(
                              room: room,
                              amount: val,
                              date: date,
                            );
                            Navigator.of(context).pop();
                          },
                          child: const Text('SAVE PRICE'),
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
