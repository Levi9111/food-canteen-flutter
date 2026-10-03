import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/animations/smooth_transitions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/modal_action_bar.dart';
import '../../../../core/widgets/squadron_dropdown.dart';
import '../../models/daily_room_expense.dart';
import '../../providers/canteen_register_provider.dart';
import '../../providers/canteen_structure_provider.dart';

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
    final currencyFormat = NumberFormat('#,##0.00', 'en_US');
    final isMobile = MediaQuery.of(context).size.width < 768;

    final structure = ref.watch(canteenStructureProvider);

    final sqnDayTotal = state.getSquadronDayTotal(
      state.activeEntry,
      state.selectedSquadron,
      state.selectedDate,
    );

    double allSqnDayTotal = 0.0;
    for (final sqn in structure.squadrons) {
      allSqnDayTotal += state.getSquadronDayTotal(
        state.activeEntry,
        sqn,
        state.selectedDate,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Tactical Squadron Selection Dropdown
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: SquadronDropdown(
            squadrons: structure.squadrons,
            selectedSquadron: state.selectedSquadron,
            onChanged: (sqn) => notifier.setSelectedSquadron(sqn),
            dayTotal: sqnDayTotal,
            showDayTotal: true,
          ),
        ),

        // 2. Compact Date Navigator Bar & Quick Action
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 8 : 16,
            vertical: 6,
          ),
          decoration: const BoxDecoration(
            color: AppColors.ledgerSurface,
            border: Border(bottom: BorderSide(color: AppColors.ledgerBorderLight)),
          ),
          child: Row(
            children: [
              // Day step back
              IconButton(
                icon: const Icon(Icons.chevron_left, size: 20),
                visualDensity: VisualDensity.compact,
                tooltip: 'Previous Day',
                onPressed: () {
                  notifier.setSelectedDate(
                    state.selectedDate.subtract(const Duration(days: 1)),
                  );
                },
              ),

              // Date Picker Button
              Expanded(
                child: InkWell(
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
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.ledgerBackground,
                      border: Border.all(color: AppColors.ledgerBorder),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.calendar_today, size: 12, color: AppColors.bafNavy),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            DateFormat(isMobile ? 'dd MMM yyyy' : 'EEE, dd MMM yyyy')
                                .format(state.selectedDate)
                                .toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.bafNavy,
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
              ),

              // Day step forward
              IconButton(
                icon: const Icon(Icons.chevron_right, size: 20),
                visualDensity: VisualDensity.compact,
                tooltip: 'Next Day',
                onPressed: () {
                  notifier.setSelectedDate(
                    state.selectedDate.add(const Duration(days: 1)),
                  );
                },
              ),

              // Today Button
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  visualDensity: VisualDensity.compact,
                ),
                onPressed: () => notifier.setSelectedDate(DateTime.now()),
                child: const Text('TODAY', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
              ),

              if (isMobile) ...[
                const SizedBox(width: 6),
                IconButton(
                  key: const Key('toggle_daily_view_mode'),
                  icon: Icon(_forceTableView ? Icons.grid_view : Icons.table_chart, size: 16),
                  visualDensity: VisualDensity.compact,
                  tooltip: _forceTableView ? 'Switch to Cards' : 'Switch to Table',
                  onPressed: () => setState(() => _forceTableView = !_forceTableView),
                ),
              ],
            ],
          ),
        ),

        // 3. Crisp Unified Daily Calculation Ribbon (No clutter, No nested horizontal scroll)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          color: AppColors.bafLightBlue.withAlpha(120),
          child: Row(
            children: [
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 11, color: AppColors.textPrimary),
                    children: [
                      TextSpan(
                        text: '${state.selectedSquadron.toUpperCase()} SQN: ',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.bafDeepBlue),
                      ),
                      TextSpan(
                        text: '৳ ${currencyFormat.format(sqnDayTotal)}',
                        style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.bafNavy),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                height: 14,
                width: 1,
                color: AppColors.ledgerBorder,
                margin: const EdgeInsets.symmetric(horizontal: 8),
              ),
              RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 11, color: AppColors.textPrimary),
                  children: [
                    const TextSpan(
                      text: 'ALL SQNS: ',
                      style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                    ),
                    TextSpan(
                      text: '৳ ${currencyFormat.format(allSqnDayTotal)}',
                      style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.debitRed),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // 4. Room Register List (Fluid Vertical Scrolling without Gesture Clashes)
        Expanded(
          child: (isMobile && !_forceTableView)
              ? _buildMobileRoomCards(context, state, currencyFormat)
              : _buildDesktopDataTable(context, state, currencyFormat),
        ),
      ],
    );
  }

  /// Mobile-first smart tactical room card list
  Widget _buildMobileRoomCards(
    BuildContext context,
    CanteenRegisterState state,
    NumberFormat currencyFormat,
  ) {
    final rooms = ref.watch(canteenStructureProvider).getRoomsForSquadron(state.selectedSquadron);

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, AppSpacing.bottomInset),
      itemCount: rooms.length,
      itemBuilder: (context, idx) {
        final room = rooms[idx];
        final expense = state.getExpense(
          state.activeEntry,
          state.selectedSquadron,
          room,
          state.selectedDate,
        );
        final hasEntry = expense != null && expense.amount > 0;

        return Padding(
          padding: const EdgeInsets.only(bottom: 7),
          child: Container(
            decoration: BoxDecoration(
              color: hasEntry ? Colors.white : AppColors.ledgerSurface,
              border: Border.all(
                color: hasEntry ? AppColors.bafGold : AppColors.ledgerBorder,
                width: hasEntry ? 1.5 : 1.0,
              ),
            ),
            child: InkWell(
              onTap: () {
                _showDailyExpenseModal(
                  context,
                  ref,
                  room: room,
                  existingExpense: expense,
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                child: Row(
                  children: [
                    // Index Tag & Room Number
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      color: hasEntry ? AppColors.bafNavy : AppColors.ledgerBorderLight,
                      child: Text(
                        '#${idx + 1}',
                        style: TextStyle(
                          color: hasEntry ? AppColors.bafGold : AppColors.textSecondary,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Room & Entry Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                room,
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.bafNavy,
                                ),
                              ),
                              if (hasEntry) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                  color: AppColors.bafLightBlue,
                                  child: Text(
                                    expense.recordedBy,
                                    style: const TextStyle(
                                      fontSize: 8.5,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.bafDeepBlue,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            hasEntry
                                ? (expense.representativeName != null && expense.representativeName!.isNotEmpty
                                    ? 'Rep: ${expense.representativeName}'
                                    : (expense.itemsDescription ?? 'Consumption recorded'))
                                : 'No price recorded today',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10.5,
                              color: hasEntry ? AppColors.textPrimary : AppColors.textMuted,
                              fontStyle: hasEntry ? FontStyle.normal : FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Price Badge & Quick Action Button
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          hasEntry ? '৳ ${currencyFormat.format(expense.amount)}' : '৳ 0.00',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w900,
                            color: hasEntry ? AppColors.debitRed : AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: hasEntry ? AppColors.bafDeepBlue : AppColors.bafGold,
                          ),
                          child: Text(
                            hasEntry ? 'EDIT' : '+ LOG',
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w900,
                              color: hasEntry ? Colors.white : AppColors.bafNavy,
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
        );
      },
    );
  }

  /// Desktop Data Table View
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
                DataColumn(label: Text('#', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                DataColumn(label: Text('ROOM', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                DataColumn(label: Text('ROOM REPRESENTATIVE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                DataColumn(label: Text('CANTEEN PARTICULARS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                DataColumn(label: Text('DUTY', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                DataColumn(label: Text('PRICE (TK)', style: TextStyle(color: AppColors.bafGold, fontWeight: FontWeight.bold))),
                DataColumn(label: Text('ACTION', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
              ],
              rows: List.generate(
                ref.watch(canteenStructureProvider).getRoomsForSquadron(state.selectedSquadron).length,
                (idx) {
                  final room = ref.watch(canteenStructureProvider).getRoomsForSquadron(state.selectedSquadron)[idx];
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
                        ? (isEven ? AppColors.bafLightBlue.withAlpha(90) : AppColors.bafLightBlue.withAlpha(50))
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
                          color: hasEntry ? AppColors.debitRed : AppColors.textMuted,
                        ),
                      ),
                    ),
                    DataCell(
                      ElevatedButton.icon(
                        icon: Icon(hasEntry ? Icons.edit : Icons.add, size: 13),
                        label: Text(hasEntry ? 'EDIT' : 'ENTER'),
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
          constraints: const BoxConstraints(maxWidth: 480),
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
                            fontSize: 12,
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
                      // Context Strip
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        color: AppColors.bafLightBlue,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              dateFormat.format(state.selectedDate).toUpperCase(),
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'ENTRY: ${state.activeEntry}',
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              color: AppColors.bafNavy,
                              child: Text(
                                state.activeManager,
                                style: const TextStyle(
                                  fontSize: 9.5,
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
                          isDense: true,
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
                          hintText: 'e.g. Recruit Tariqul (Chest 42) / Room Rep',
                          isDense: true,
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
                          hintText: 'e.g. Snacks, biscuits, tea, toiletries',
                          isDense: true,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Actions
                      ModalActionBar(
                        cancelLabel: 'CANCEL',
                        confirmLabel: 'SAVE PRICE IN BOOK',
                        onCancel: () => Navigator.of(context).pop(),
                        onConfirm: () async {
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
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
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
  }
}
