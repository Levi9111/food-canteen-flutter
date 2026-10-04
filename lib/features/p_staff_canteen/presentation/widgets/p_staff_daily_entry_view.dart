import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/canteen_theme_extension.dart';
import '../../../../core/widgets/modal_action_bar.dart';
import '../../constants/p_staff_constants.dart';
import '../../models/p_staff_models.dart';
import '../../providers/p_staff_register_provider.dart';

class PStaffDailyEntryView extends ConsumerStatefulWidget {
  const PStaffDailyEntryView({super.key});

  @override
  ConsumerState<PStaffDailyEntryView> createState() => _PStaffDailyEntryViewState();
}

class _PStaffDailyEntryViewState extends ConsumerState<PStaffDailyEntryView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showNewStaffDialog(BuildContext context, WidgetRef ref) {
    final theme = context.canteenTheme;
    final nameCtrl = TextEditingController();
    final bdNoCtrl = TextEditingController();
    final preDueCtrl = TextEditingController();
    String selectedRank = PStaffConstants.ranks.contains('Sgt') ? 'Sgt' : PStaffConstants.ranks.first;
    String selectedOffice = PStaffConstants.selectableOffices.first;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final bottomInset = MediaQuery.of(ctx).viewInsets.bottom;
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return Padding(
              padding: EdgeInsets.only(bottom: bottomInset),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 440),
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
                              const Icon(Icons.person_add, color: AppColors.bafGold, size: 18),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  'ENROLL NEW PERMANENT STAFF (P-STAFF)',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11.5),
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
                              // BD Number
                              Text('BD NUMBER (SERVICE ID) *', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: theme.textSecondary)),
                              const SizedBox(height: 4),
                              TextField(
                                controller: bdNoCtrl,
                                decoration: const InputDecoration(hintText: 'e.g. BD/48291 or CIV/1042', isDense: true),
                                textCapitalization: TextCapitalization.characters,
                              ),
                              const SizedBox(height: 12),

                              // Rank Dropdown
                              Text('RANK / DESIGNATION *', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: theme.textSecondary)),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                                decoration: BoxDecoration(
                                  color: theme.cardBackground,
                                  border: Border.all(color: theme.cardBorder),
                                ),
                                child: DropdownButton<String>(
                                  value: selectedRank,
                                  dropdownColor: theme.surface,
                                  isExpanded: true,
                                  underline: const SizedBox(),
                                  items: PStaffConstants.ranks.map((r) => DropdownMenuItem(value: r, child: Text(r, style: TextStyle(fontSize: 12, color: theme.textPrimary)))).toList(),
                                  onChanged: (val) {
                                    if (val != null) setDialogState(() => selectedRank = val);
                                  },
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Full Name
                              Text('FULL NAME *', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: theme.textSecondary)),
                              const SizedBox(height: 4),
                              TextField(
                                controller: nameCtrl,
                                decoration: const InputDecoration(hintText: 'e.g. Tariqul Islam', isDense: true),
                              ),
                              const SizedBox(height: 12),

                              // Office Dropdown
                              Text('ASSIGNED OFFICE / SECTION *', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: theme.textSecondary)),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                                decoration: BoxDecoration(
                                  color: theme.cardBackground,
                                  border: Border.all(color: theme.cardBorder),
                                ),
                                child: DropdownButton<String>(
                                  value: selectedOffice,
                                  dropdownColor: theme.surface,
                                  isExpanded: true,
                                  underline: const SizedBox(),
                                  items: PStaffConstants.selectableOffices.map((o) => DropdownMenuItem(value: o, child: Text(o, style: TextStyle(fontSize: 12, color: theme.textPrimary)))).toList(),
                                  onChanged: (val) {
                                    if (val != null) setDialogState(() => selectedOffice = val);
                                  },
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Previous Due
                              Text('PREVIOUS DUE CARRIED FORWARD (TK)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: theme.textSecondary)),
                              const SizedBox(height: 4),
                              TextField(
                                controller: preDueCtrl,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: const InputDecoration(hintText: '0.00', prefixText: '৳ ', isDense: true),
                              ),
                              const SizedBox(height: 18),

                              ModalActionBar(
                                cancelLabel: 'CANCEL',
                                confirmLabel: 'ENROLL P-STAFF',
                                onCancel: () => Navigator.of(ctx).pop(),
                                onConfirm: () {
                                  final name = nameCtrl.text.trim();
                                  final bd = bdNoCtrl.text.trim();
                                  final pre = double.tryParse(preDueCtrl.text.trim()) ?? 0.0;
                                  if (name.isNotEmpty && bd.isNotEmpty) {
                                    ref.read(pStaffRegisterProvider.notifier).addNewStaff(
                                      name: name,
                                      rank: selectedRank,
                                      bdNo: bd,
                                      office: selectedOffice,
                                      preDue: pre,
                                    );
                                    Navigator.of(ctx).pop();
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
          },
        );
      },
    );
  }

  void _showStaffExpenseModal(
    BuildContext context,
    WidgetRef ref, {
    required PStaffProfile staff,
    DailyStaffExpense? existingExpense,
  }) {
    final state = ref.read(pStaffRegisterProvider);
    final theme = context.canteenTheme;
    final amountController = TextEditingController(
      text: existingExpense != null && existingExpense.amount > 0
          ? existingExpense.amount.toStringAsFixed(2)
          : '',
    );
    final itemsController = TextEditingController(
      text: existingExpense?.particulars ?? '',
    );
    final dateFormat = DateFormat('dd MMMM yyyy');

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
              constraints: const BoxConstraints(maxWidth: 480),
              decoration: BoxDecoration(
                color: theme.surface,
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
                          const Icon(Icons.receipt_long, color: AppColors.bafGold, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'P-STAFF BOOK • ${staff.rank} ${staff.name} (${staff.bdNo})',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
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
                          // Context Strip
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            color: theme.tableHighlight,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  dateFormat.format(state.selectedDate).toUpperCase(),
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: theme.textPrimary),
                                ),
                                Text(
                                  staff.office.toUpperCase(),
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: theme.accentGold),
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
                          Text(
                            'TODAY\'S CANTEEN PRICE (TK) *',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: theme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: amountController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            autofocus: true,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: theme.debit,
                            ),
                            decoration: const InputDecoration(
                              prefixText: '৳ ',
                              hintText: '0.00',
                              isDense: true,
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Items / Particulars
                          Text(
                            'CANTEEN ITEMS / PARTICULARS',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: theme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: itemsController,
                            decoration: const InputDecoration(
                              hintText: 'e.g. Tea, special snacks, lunch, cold drinks',
                              isDense: true,
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Actions with matched even-sized buttons
                          ModalActionBar(
                            cancelLabel: 'CANCEL',
                            confirmLabel: 'SAVE PRICE IN BOOK',
                            onCancel: () => Navigator.of(ctx).pop(),
                            onConfirm: () async {
                              final amt = double.tryParse(amountController.text.trim()) ?? 0.0;
                              await ref.read(pStaffRegisterProvider.notifier).recordStaffExpense(
                                staffId: staff.id,
                                amount: amt,
                                particulars: itemsController.text.trim().isEmpty
                                    ? null
                                    : itemsController.text.trim(),
                              );
                              if (ctx.mounted) {
                                Navigator.of(ctx).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Saved: ${staff.name} - ৳ ${amt.toStringAsFixed(2)}'),
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pStaffRegisterProvider);
    final notifier = ref.read(pStaffRegisterProvider.notifier);
    final currencyFormat = NumberFormat('#,##0.00', 'en_US');
    final isMobile = MediaQuery.of(context).size.width < 768;
    final theme = context.canteenTheme;

    final todayTotal = state.getStaffDayTotal(state.selectedDate);
    final filteredStaff = state.filteredStaffProfiles;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Office Selector Ribbon & New Staff Button
        Container(
          color: AppColors.bafNavy,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Row(
            children: [
              const Text('OFFICE:', style: TextStyle(color: AppColors.bafGold, fontSize: 10, fontWeight: FontWeight.bold)),
              const SizedBox(width: 6),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  color: AppColors.bafDeepBlue,
                  child: DropdownButton<String>(
                    value: state.selectedOffice,
                    isExpanded: true,
                    dropdownColor: AppColors.bafNavy,
                    underline: const SizedBox(),
                    isDense: true,
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                    items: PStaffConstants.offices.map((o) {
                      return DropdownMenuItem(value: o, child: Text(o));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) notifier.setSelectedOffice(val);
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                icon: const Icon(Icons.person_add, size: 13),
                label: Text(isMobile ? '+ STAFF' : '+ NEW P-STAFF'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.bafGold,
                  foregroundColor: AppColors.bafNavy,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  textStyle: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900),
                ),
                onPressed: () => _showNewStaffDialog(context, ref),
              ),
            ],
          ),
        ),

        // 2. Date Navigator & Search Bar
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 8 : 14,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: theme.surface,
            border: Border(bottom: BorderSide(color: theme.cardBorderLight)),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, size: 20),
                visualDensity: VisualDensity.compact,
                onPressed: () {
                  notifier.setSelectedDate(state.selectedDate.subtract(const Duration(days: 1)));
                },
              ),
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
                      color: theme.background,
                      border: Border.all(color: theme.cardBorder),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.calendar_today, size: 12, color: theme.accentGold),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            DateFormat(isMobile ? 'dd MMM yyyy' : 'EEE, dd MMM yyyy')
                                .format(state.selectedDate)
                                .toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: theme.textPrimary,
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
              IconButton(
                icon: const Icon(Icons.chevron_right, size: 20),
                visualDensity: VisualDensity.compact,
                onPressed: () {
                  notifier.setSelectedDate(state.selectedDate.add(const Duration(days: 1)));
                },
              ),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  visualDensity: VisualDensity.compact,
                  foregroundColor: theme.accentGold,
                  side: BorderSide(color: theme.accentGold),
                ),
                onPressed: () => notifier.setSelectedDate(DateTime.now()),
                child: const Text('TODAY', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),

        // 3. Search Bar & Day Total Ribbon
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          color: theme.tableHighlight,
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 32,
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => notifier.setSearchQuery(val),
                    style: TextStyle(fontSize: 12, color: theme.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Search Name or BD No...',
                      hintStyle: TextStyle(fontSize: 11, color: theme.textSecondary),
                      prefixIcon: Icon(Icons.search, size: 15, color: theme.textSecondary),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 14),
                              onPressed: () {
                                _searchController.clear();
                                notifier.setSearchQuery('');
                              },
                            )
                          : null,
                      contentPadding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                      fillColor: theme.surface,
                      filled: true,
                      isDense: true,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                color: AppColors.bafNavy,
                child: Text(
                  'DAY: ৳ ${currencyFormat.format(todayTotal)}',
                  style: const TextStyle(color: AppColors.bafGold, fontWeight: FontWeight.w900, fontSize: 11),
                ),
              ),
            ],
          ),
        ),

        // 4. Staff List
        Expanded(
          child: filteredStaff.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.badge_outlined, size: 44, color: AppColors.textMuted),
                      const SizedBox(height: 8),
                      Text(
                        'NO P-STAFF FOUND',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: theme.textSecondary),
                      ),
                      const SizedBox(height: 4),
                      TextButton.icon(
                        icon: const Icon(Icons.add, size: 14),
                        label: const Text('ENROLL FIRST P-STAFF'),
                        onPressed: () => _showNewStaffDialog(context, ref),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  itemCount: filteredStaff.length,
                  itemBuilder: (context, idx) {
                    final staff = filteredStaff[idx];
                    final expense = state.getExpense(staff.id, state.selectedDate);
                    final hasSpent = expense != null && expense.amount > 0;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 7),
                      child: Container(
                        decoration: BoxDecoration(
                          color: hasSpent ? theme.cardBackground : theme.surface,
                          border: Border.all(
                            color: hasSpent ? theme.accentGold : theme.cardBorder,
                            width: hasSpent ? 1.5 : 1.0,
                          ),
                        ),
                        child: InkWell(
                          onTap: () {
                            _showStaffExpenseModal(
                              context,
                              ref,
                              staff: staff,
                              existingExpense: expense,
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                            child: Row(
                              children: [
                                // BD Number Tag
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                  color: hasSpent ? AppColors.bafNavy : theme.cardBorderLight,
                                  child: Text(
                                    staff.bdNo,
                                    style: TextStyle(
                                      color: hasSpent ? AppColors.bafGold : theme.textSecondary,
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),

                                // Staff Details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            '${staff.rank} ${staff.name}',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w900,
                                              color: theme.textPrimary,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                            color: theme.tableHighlight,
                                            child: Text(
                                              staff.office,
                                              style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: theme.accentGold),
                                            ),
                                          ),
                                          if (hasSpent && expense.particulars != null) ...[
                                            const SizedBox(width: 6),
                                            Expanded(
                                              child: Text(
                                                expense.particulars!,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(fontSize: 9.5, color: theme.textSecondary),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(width: 8),

                                // Amount & Action
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      hasSpent ? '৳ ${currencyFormat.format(expense.amount)}' : '৳ 0.00',
                                      style: TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w900,
                                        color: hasSpent ? theme.debit : theme.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      color: hasSpent ? AppColors.bafNavy : theme.accentGold,
                                      child: Text(
                                        hasSpent ? 'EDIT' : '+ LOG',
                                        style: TextStyle(
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w900,
                                          color: hasSpent ? Colors.white : AppColors.bafNavy,
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
                ),
        ),
      ],
    );
  }
}
