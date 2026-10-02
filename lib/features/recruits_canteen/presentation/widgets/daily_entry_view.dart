import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/animations/smooth_transitions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../constants/canteen_constants.dart';
import '../../models/daily_room_expense.dart';
import '../../providers/canteen_register_provider.dart';
import '../../../../core/widgets/tactical_card.dart';

class DailyEntryView extends ConsumerStatefulWidget {
  const DailyEntryView({super.key});

  @override
  ConsumerState<DailyEntryView> createState() => _DailyEntryViewState();
}

class _DailyEntryViewState extends ConsumerState<DailyEntryView> {
  bool _forceTableView = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(canteenRegisterProvider);
    final notifier = ref.read(canteenRegisterProvider.notifier);
    final dateFormat = DateFormat('EEEE, dd MMMM yyyy');
    final currencyFormat = NumberFormat('#,##0.00', 'en_US');
    final isMobile = MediaQuery.of(context).size.width < 768;

    final sqnDayTotal = state.getSquadronDayTotal(
      state.activeEntry,
      state.selectedSquadron,
      state.selectedDate,
    );

    double allSqnDayTotal = 0.0;
    for (final sqn in CanteenConstants.squadrons) {
      allSqnDayTotal += state.getSquadronDayTotal(
        state.activeEntry,
        sqn,
        state.selectedDate,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Date & Command Control Bar
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
                // Date Navigation
                IconButton(
                  icon: const Icon(Icons.chevron_left, size: 20),
                  tooltip: 'Previous Day',
                  onPressed: () {
                    notifier.setSelectedDate(
                      state.selectedDate.subtract(const Duration(days: 1)),
                    );
                  },
                ),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: state.selectedDate,
                      firstDate: DateTime(2024),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) notifier.setSelectedDate(picked);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.bafNavy,
                      border: Border.all(color: AppColors.bafGold),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.calendar_today, size: 13, color: AppColors.bafGold),
                        const SizedBox(width: 6),
                        Text(
                          DateFormat('dd MMM yyyy').format(state.selectedDate).toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right, size: 20),
                  tooltip: 'Next Day',
                  onPressed: () {
                    notifier.setSelectedDate(
                      state.selectedDate.add(const Duration(days: 1)),
                    );
                  },
                ),
                const SizedBox(width: 4),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  ),
                  onPressed: () => notifier.setSelectedDate(DateTime.now()),
                  child: const Text('TODAY', style: TextStyle(fontSize: 11)),
                ),

                const SizedBox(width: 14),

                // Squadron Selector Tabs
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
              ],
            ),
          ),
        ),

        // Daily Calculation Summary Ribbon (Responsive)
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 12 : 16,
            vertical: isMobile ? 8 : 10,
          ),
          color: AppColors.bafLightBlue,
          child: isMobile
              ? Column(
                  children: [
                    // Mobile Row 1: Entry & Duty Officer
                    Row(
                      children: [
                        SmoothAnimatedMetricCard(
                          title: 'CURRENT ENTRY',
                          value: double.tryParse(state.activeEntry) ?? 54.0,
                          prefix: 'Entry ',
                          textColor: AppColors.bafNavy,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                            decoration: BoxDecoration(
                              color: AppColors.ledgerSurface,
                              border: Border.all(color: AppColors.bafGold, width: 1.5),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'DUTY IN-CHARGE',
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textMuted,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                      color: AppColors.bafNavy,
                                      child: Text(
                                        state.activeManager,
                                        style: const TextStyle(
                                          color: AppColors.bafGold,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    const Flexible(
                                      child: Text(
                                        'PRESENT',
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.cleared,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Mobile Row 2: Selected Sqn Total & All Sqns Grand Total
                    Row(
                      children: [
                        SmoothAnimatedMetricCard(
                          title: '${state.selectedSquadron.toUpperCase()} SQN DAY',
                          value: sqnDayTotal,
                          textColor: AppColors.bafDeepBlue,
                        ),
                        const SizedBox(width: 8),
                        SmoothAnimatedMetricCard(
                          title: 'ALL SQNS DAY TOTAL',
                          value: allSqnDayTotal,
                          textColor: AppColors.debitRed,
                        ),
                      ],
                    ),
                  ],
                )
              : Row(
                  children: [
                    SmoothAnimatedMetricCard(
                      title: 'CURRENT ENTRY',
                      value: double.tryParse(state.activeEntry) ?? 54.0,
                      prefix: 'Entry ',
                      textColor: AppColors.bafNavy,
                    ),
                    const SizedBox(width: 12),
                    SmoothAnimatedMetricCard(
                      title: '${state.selectedSquadron.toUpperCase()} SQN DAY TOTAL',
                      value: sqnDayTotal,
                      textColor: AppColors.bafDeepBlue,
                    ),
                    const SizedBox(width: 12),
                    SmoothAnimatedMetricCard(
                      title: 'ALL SQUADRONS DAY TOTAL',
                      value: allSqnDayTotal,
                      textColor: AppColors.debitRed,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.ledgerSurface,
                          border: Border.all(color: AppColors.bafGold, width: 1.5),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'LOGGING OFFICER IN-CHARGE',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textMuted,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                  color: AppColors.bafNavy,
                                  child: Text(
                                    state.activeManager,
                                    style: const TextStyle(
                                      color: AppColors.bafGold,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'PRESENT AT CANTEEN',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.cleared,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        ),

        // Section Bar with View Switcher
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          color: AppColors.ledgerSurface,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '${state.selectedSquadron.toUpperCase()} SQN • 16 ROOMS REGISTER (${dateFormat.format(state.selectedDate).toUpperCase()})',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              if (isMobile)
                InkWell(
                  onTap: () => setState(() => _forceTableView = !_forceTableView),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _forceTableView ? AppColors.bafDeepBlue : AppColors.bafNavy,
                      border: Border.all(color: AppColors.bafGold),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _forceTableView ? Icons.grid_view : Icons.table_chart,
                          size: 13,
                          color: AppColors.bafGold,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _forceTableView ? 'CARD VIEW' : 'TABLE VIEW',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),

        // Daily Rooms List / Table
        Expanded(
          child: (isMobile && !_forceTableView)
              ? _buildMobileRoomCards(context, state, currencyFormat)
              : _buildDesktopDataTable(context, state, currencyFormat),
        ),
      ],
    );
  }

  /// Mobile-first responsive card list
  Widget _buildMobileRoomCards(
    BuildContext context,
    CanteenRegisterState state,
    NumberFormat currencyFormat,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: CanteenConstants.rooms.length,
      itemBuilder: (context, idx) {
        final room = CanteenConstants.rooms[idx];
        final expense = state.getExpense(
          state.activeEntry,
          state.selectedSquadron,
          room,
          state.selectedDate,
        );
        final hasEntry = expense != null && expense.amount > 0;

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: TacticalCard(
            accentColor: hasEntry ? AppColors.bafGold : null,
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Card Header: Room Name & Today's Price Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          color: AppColors.bafNavy,
                          child: Text(
                            '#${idx + 1}',
                            style: const TextStyle(color: AppColors.bafGold, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          room,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: AppColors.bafNavy,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      color: hasEntry ? AppColors.bafDeepBlue : AppColors.ledgerBorderLight,
                      child: Text(
                        hasEntry ? '৳ ${currencyFormat.format(expense.amount)}' : '৳ 0.00 (NIL)',
                        style: TextStyle(
                          color: hasEntry ? AppColors.bafGold : AppColors.textMuted,
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Details Row
                if (hasEntry) ...[
                  Row(
                    children: [
                      const Icon(Icons.person, size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 6),
                      Text(
                        'Rep: ${expense.representativeName ?? "Attended"}',
                        style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        color: AppColors.bafNavy,
                        child: Text(
                          expense.recordedBy,
                          style: const TextStyle(color: AppColors.bafGold, fontSize: 9.5, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.shopping_bag_outlined, size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          expense.itemsDescription ?? 'Snacks & refreshments',
                          style: const TextStyle(fontSize: 11, color: AppColors.textPrimary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],

                // Action Button
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    icon: Icon(hasEntry ? Icons.edit : Icons.add, size: 14),
                    label: Text(hasEntry ? 'EDIT PRICE' : 'LOG PRICE'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: hasEntry ? AppColors.bafDeepBlue : AppColors.bafGold,
                      foregroundColor: hasEntry ? Colors.white : AppColors.bafNavy,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      _showDailyExpenseModal(
                        context,
                        ref,
                        room: room,
                        existingExpense: expense,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Desktop Data Table
  Widget _buildDesktopDataTable(
    BuildContext context,
    CanteenRegisterState state,
    NumberFormat currencyFormat,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1100),
          decoration: BoxDecoration(
            color: AppColors.ledgerSurface,
            border: Border.all(color: AppColors.ledgerBorder),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowHeight: 38,
              dataRowMinHeight: 46,
              dataRowMaxHeight: 52,
              headingRowColor: WidgetStateProperty.all(AppColors.bafNavy),
              columns: const [
                DataColumn(label: Text('#')),
                DataColumn(label: Text('ROOM')),
                DataColumn(label: Text('ROOM REPRESENTATIVE')),
                DataColumn(label: Text('CANTEEN ITEMS / PARTICULARS')),
                DataColumn(label: Text('RECORDED BY')),
                DataColumn(label: Text('TODAY\'S PRICE (TK)')),
                DataColumn(label: Text('ACTION')),
              ],
              rows: List.generate(CanteenConstants.rooms.length, (idx) {
                final room = CanteenConstants.rooms[idx];
                final expense = state.getExpense(
                  state.activeEntry,
                  state.selectedSquadron,
                  room,
                  state.selectedDate,
                );
                final isEven = idx % 2 == 0;
                final hasEntry = expense != null && expense.amount > 0;

                return DataRow(
                  color: WidgetStateProperty.all(
                    hasEntry
                        ? (isEven ? AppColors.bafLightBlue.withAlpha(80) : AppColors.bafLightBlue.withAlpha(50))
                        : (isEven ? AppColors.ledgerSurface : AppColors.ledgerStripe),
                  ),
                  cells: [
                    DataCell(Text('${idx + 1}', style: const TextStyle(fontSize: 12))),
                    DataCell(
                      Text(
                        room,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.bafNavy,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        expense?.representativeName ?? '—',
                        style: TextStyle(
                          fontSize: 12,
                          color: hasEntry ? AppColors.textPrimary : AppColors.textMuted,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        expense?.itemsDescription ?? 'Nil consumption',
                        style: TextStyle(
                          fontSize: 12,
                          fontStyle: hasEntry ? FontStyle.normal : FontStyle.italic,
                          color: hasEntry ? AppColors.textPrimary : AppColors.textMuted,
                        ),
                      ),
                    ),
                    DataCell(
                      expense != null
                          ? Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              color: AppColors.bafNavy,
                              child: Text(
                                expense.recordedBy,
                                style: const TextStyle(
                                  color: AppColors.bafGold,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          : const Text('—', style: TextStyle(color: AppColors.textMuted)),
                    ),
                    DataCell(
                      Text(
                        hasEntry ? '৳ ${currencyFormat.format(expense.amount)}' : '৳ 0.00',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: hasEntry ? FontWeight.bold : FontWeight.normal,
                          color: hasEntry ? AppColors.bafNavy : AppColors.textMuted,
                        ),
                      ),
                    ),
                    DataCell(
                      ElevatedButton.icon(
                        icon: Icon(hasEntry ? Icons.edit : Icons.add, size: 13),
                        label: Text(hasEntry ? 'EDIT' : 'ENTER PRICE'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: hasEntry ? AppColors.bafDeepBlue : AppColors.bafGold,
                          foregroundColor: hasEntry ? Colors.white : AppColors.bafNavy,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                        onPressed: () {
                          _showDailyExpenseModal(
                            context,
                            ref,
                            room: room,
                            existingExpense: expense,
                          );
                        },
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  void _showDailyExpenseModal(
    BuildContext context,
    WidgetRef ref, {
    required String room,
    DailyRoomExpense? existingExpense,
  }) {
    final state = ref.read(canteenRegisterProvider);
    final amountController = TextEditingController(
      text: existingExpense != null && existingExpense.amount > 0
          ? existingExpense.amount.toStringAsFixed(2)
          : '',
    );
    final repController = TextEditingController(
      text: existingExpense?.representativeName ?? '',
    );
    final itemsController = TextEditingController(
      text: existingExpense?.itemsDescription ?? '',
    );
    final dateFormat = DateFormat('dd MMMM yyyy');

    showSmoothMilitaryDialog(
      context: context,
      child: Dialog(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          decoration: BoxDecoration(
            color: AppColors.ledgerSurface,
            border: Border.all(color: AppColors.bafNavy, width: 2),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  color: AppColors.bafNavy,
                  child: Row(
                    children: [
                      const Icon(Icons.menu_book, color: AppColors.bafGold, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'CANTEEN BOOK — ${state.selectedSquadron.toUpperCase()} SQN • $room',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white, size: 18),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Info Row
                      Container(
                        padding: const EdgeInsets.all(8),
                        color: AppColors.bafLightBlue,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              dateFormat.format(state.selectedDate).toUpperCase(),
                              style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'ENTRY: ${state.activeEntry}',
                              style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              color: AppColors.bafNavy,
                              child: Text(
                                state.activeManager,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.bafGold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Amount Field
                      const Text(
                        'TOTAL ROOM PRICE VALUE (TK) *',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: amountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        autofocus: true,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.debitRed,
                        ),
                        decoration: const InputDecoration(
                          prefixText: '৳ ',
                          hintText: '0.00',
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Representative
                      const Text(
                        'ATTENDING ROOM REPRESENTATIVE',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: repController,
                        decoration: const InputDecoration(
                          hintText: 'e.g. RCT Tariqul (Chest 42) / Room Head',
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Items Description
                      const Text(
                        'ITEMS PICKED / PARTICULARS',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: itemsController,
                        decoration: const InputDecoration(
                          hintText: 'e.g. Tea, Biscuits, Soap, Dry Canteen Items',
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Actions
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('CANCEL'),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.check, size: 16),
                            label: const Text('SAVE PRICE IN BOOK'),
                            onPressed: () async {
                              final amt = double.tryParse(amountController.text.trim()) ?? 0.0;
                              await ref.read(canteenRegisterProvider.notifier).recordRoomExpense(
                                room: room,
                                amount: amt,
                                representativeName: repController.text.trim().isEmpty
                                    ? null
                                    : repController.text.trim(),
                                itemsDescription: itemsController.text.trim().isEmpty
                                    ? null
                                    : itemsController.text.trim(),
                              );
                              if (context.mounted) {
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Saved: $room - ৳ ${amt.toStringAsFixed(2)}'),
                                    backgroundColor: AppColors.cleared,
                                  ),
                                );
                              }
                            },
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
      ),
    );
  }
}
