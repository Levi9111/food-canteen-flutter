import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/canteen_theme_extension.dart';
import '../../../../core/widgets/modal_action_bar.dart';
import '../../constants/p_staff_constants.dart';
import '../../models/p_staff_models.dart';
import '../../providers/p_staff_register_provider.dart';

class PStaffMonthlyMatrixView extends ConsumerStatefulWidget {
  const PStaffMonthlyMatrixView({super.key});

  @override
  ConsumerState<PStaffMonthlyMatrixView> createState() => _PStaffMonthlyMatrixViewState();
}

class _PStaffMonthlyMatrixViewState extends ConsumerState<PStaffMonthlyMatrixView> {
  bool _forceMatrixTable = false;

  void _showStaffAccountEditModal(BuildContext context, WidgetRef ref, PStaffProfile staff) {
    final theme = context.canteenTheme;
    final nameCtrl = TextEditingController(text: staff.name);
    final bdNoCtrl = TextEditingController(text: staff.bdNo);
    final preDueCtrl = TextEditingController(text: staff.preDue > 0 ? staff.preDue.toStringAsFixed(2) : '');
    final paidCtrl = TextEditingController(text: staff.paid > 0 ? staff.paid.toStringAsFixed(2) : '');
    String selectedRank = staff.rank;
    String selectedOffice = staff.office;

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
                              const Icon(Icons.account_balance_wallet, color: AppColors.bafGold, size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'P-STAFF ACCOUNT • ${staff.bdNo}',
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
                              Text('FULL NAME:', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: theme.textSecondary)),
                              const SizedBox(height: 4),
                              TextField(controller: nameCtrl, decoration: const InputDecoration(isDense: true)),
                              const SizedBox(height: 10),

                              Text('RANK:', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: theme.textSecondary)),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(color: theme.cardBackground, border: Border.all(color: theme.cardBorder)),
                                child: DropdownButton<String>(
                                  value: PStaffConstants.ranks.contains(selectedRank) ? selectedRank : PStaffConstants.ranks.first,
                                  dropdownColor: theme.surface,
                                  isExpanded: true,
                                  underline: const SizedBox(),
                                  items: PStaffConstants.ranks.map((r) => DropdownMenuItem(value: r, child: Text(r, style: TextStyle(color: theme.textPrimary)))).toList(),
                                  onChanged: (val) {
                                    if (val != null) setDialogState(() => selectedRank = val);
                                  },
                                ),
                              ),
                              const SizedBox(height: 10),

                              Text('ASSIGNED OFFICE:', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: theme.textSecondary)),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(color: theme.cardBackground, border: Border.all(color: theme.cardBorder)),
                                child: DropdownButton<String>(
                                  value: PStaffConstants.selectableOffices.contains(selectedOffice) ? selectedOffice : PStaffConstants.selectableOffices.first,
                                  dropdownColor: theme.surface,
                                  isExpanded: true,
                                  underline: const SizedBox(),
                                  items: PStaffConstants.selectableOffices.map((o) => DropdownMenuItem(value: o, child: Text(o, style: TextStyle(color: theme.textPrimary)))).toList(),
                                  onChanged: (val) {
                                    if (val != null) setDialogState(() => selectedOffice = val);
                                  },
                                ),
                              ),
                              const SizedBox(height: 10),

                              Text('PREVIOUS DUE (TK):', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: theme.textSecondary)),
                              const SizedBox(height: 4),
                              TextField(controller: preDueCtrl, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(isDense: true, prefixText: '৳ ')),
                              const SizedBox(height: 10),

                              Text('PAID AMOUNT (TK):', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: theme.textSecondary)),
                              const SizedBox(height: 4),
                              TextField(controller: paidCtrl, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(isDense: true, prefixText: '৳ ')),
                              const SizedBox(height: 16),

                              ModalActionBar(
                                cancelLabel: 'CANCEL',
                                confirmLabel: 'SAVE ACCOUNT',
                                onCancel: () => Navigator.of(ctx).pop(),
                                onConfirm: () {
                                  final pre = double.tryParse(preDueCtrl.text.trim()) ?? 0.0;
                                  final pd = double.tryParse(paidCtrl.text.trim()) ?? 0.0;
                                  ref.read(pStaffRegisterProvider.notifier).updateStaff(
                                    id: staff.id,
                                    name: nameCtrl.text.trim(),
                                    rank: selectedRank,
                                    bdNo: bdNoCtrl.text.trim(),
                                    office: selectedOffice,
                                    preDue: pre,
                                    paid: pd,
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
      },
    );
  }

  void _showQuickEditModal(
    BuildContext context,
    WidgetRef ref,
    PStaffProfile staff,
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
                              'QUICK ENTRY • ${staff.bdNo} ($dStr)',
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
                          Text('${staff.rank} ${staff.name}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: theme.textPrimary)),
                          const SizedBox(height: 8),
                          Text('PRICE VALUE (TK):', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: theme.textSecondary)),
                          const SizedBox(height: 6),
                          TextField(
                            controller: controller,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            autofocus: true,
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.debit),
                            decoration: const InputDecoration(prefixText: '৳ ', hintText: '0.00', isDense: true),
                          ),
                          const SizedBox(height: 16),
                          ModalActionBar(
                            cancelLabel: 'CANCEL',
                            confirmLabel: 'SAVE PRICE',
                            onCancel: () => Navigator.of(ctx).pop(),
                            onConfirm: () {
                              final val = double.tryParse(controller.text.trim()) ?? 0.0;
                              ref.read(pStaffRegisterProvider.notifier).recordStaffExpense(
                                staffId: staff.id,
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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pStaffRegisterProvider);
    final notifier = ref.read(pStaffRegisterProvider.notifier);
    final currencyFormat = NumberFormat('#,##0.00', 'en_US');

    final daysInMonth = DateTime(state.selectedYear, state.selectedMonth + 1, 0).day;
    final filteredStaff = state.filteredStaffProfiles;

    final preDueTotal = state.getAllStaffPreDueTotal();
    final monthTotal = state.getAllStaffMonthGrandTotal(state.selectedYear, state.selectedMonth);
    final paidTotal = state.getAllStaffPaidTotal();
    final netDueTotal = state.getAllStaffNetDueTotal(state.selectedYear, state.selectedMonth);

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
            // 1. Period Navigator & Office Filter
            Container(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 14, vertical: 6),
              decoration: const BoxDecoration(
                color: AppColors.ledgerSurface,
                border: Border(bottom: BorderSide(color: AppColors.ledgerBorderLight)),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    const Text('OFFICE:', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.ledgerBorder)),
                      child: DropdownButton<String>(
                        value: state.selectedOffice,
                        isDense: true,
                        underline: const SizedBox(),
                        items: PStaffConstants.offices.map((o) => DropdownMenuItem(value: o, child: Text(o, style: const TextStyle(fontSize: 11)))).toList(),
                        onChanged: (val) {
                          if (val != null) notifier.setSelectedOffice(val);
                        },
                      ),
                    ),

                    const SizedBox(width: 8),

                    const Text('PERIOD:', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.ledgerBorder)),
                      child: DropdownButton<int>(
                        value: state.selectedMonth,
                        isDense: true,
                        underline: const SizedBox(),
                        items: List.generate(12, (i) => i + 1).map((m) {
                          return DropdownMenuItem(value: m, child: Text(monthsList[m - 1], style: const TextStyle(fontSize: 11)));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) notifier.setSelectedMonth(state.selectedYear, val);
                        },
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.ledgerBorder)),
                      child: DropdownButton<int>(
                        value: state.selectedYear,
                        isDense: true,
                        underline: const SizedBox(),
                        items: [2025, 2026, 2027].map((y) {
                          return DropdownMenuItem(value: y, child: Text('$y', style: const TextStyle(fontSize: 11)));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) notifier.setSelectedMonth(val, state.selectedMonth);
                        },
                      ),
                    ),

                    const SizedBox(width: 12),

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

            // 2. Accounting Calculation Strip
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
                        Text('৳ ${currencyFormat.format(preDueTotal)}', style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900, color: AppColors.balanceAlert)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('MONTH SPEND', style: TextStyle(fontSize: 8, color: Colors.white70, fontWeight: FontWeight.bold)),
                        Text('৳ ${currencyFormat.format(monthTotal)}', style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900, color: Colors.white)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('PAID', style: TextStyle(fontSize: 8, color: Colors.white70, fontWeight: FontWeight.bold)),
                        Text('৳ ${currencyFormat.format(paidTotal)}', style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900, color: Colors.greenAccent)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('NET DUE', style: TextStyle(fontSize: 8, color: AppColors.bafGold, fontWeight: FontWeight.bold)),
                        Text('৳ ${currencyFormat.format(netDueTotal)}', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900, color: AppColors.bafGold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 3. Content View (Cards or Full Table)
            Expanded(
              child: (isMobile && !_forceMatrixTable)
                  ? _buildMobileStaffCards(context, ref, state, filteredStaff, daysInMonth, currencyFormat)
                  : _buildFullStaffTable(context, ref, state, filteredStaff, daysInMonth, currencyFormat),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMobileStaffCards(
    BuildContext context,
    WidgetRef ref,
    PStaffRegisterState state,
    List<PStaffProfile> staffList,
    int daysInMonth,
    NumberFormat currencyFormat,
  ) {
    if (staffList.isEmpty) {
      return const Center(child: Text('No P-Staff profiles in selected office'));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      itemCount: staffList.length,
      itemBuilder: (context, idx) {
        final staff = staffList[idx];
        final monthTotal = state.getStaffMonthTotal(staff.id, state.selectedYear, state.selectedMonth);
        final grandTotal = staff.preDue + monthTotal;
        final netDue = grandTotal - staff.paid;

        int activeDays = 0;
        for (int d = 1; d <= daysInMonth; d++) {
          final exp = state.getExpense(staff.id, DateTime(state.selectedYear, state.selectedMonth, d));
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
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        color: AppColors.bafNavy,
                        child: Text(
                          staff.bdNo,
                          style: const TextStyle(color: AppColors.bafGold, fontWeight: FontWeight.bold, fontSize: 9.5),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '${staff.rank} ${staff.name}',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.bafNavy),
                        ),
                      ),
                      InkWell(
                        onTap: () => _showStaffAccountEditModal(context, ref, staff),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.bafLightBlue,
                            border: Border.all(color: AppColors.bafDeepBlue),
                          ),
                          child: const Text('EDIT', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.bafDeepBlue)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(staff.office, style: const TextStyle(fontSize: 9.5, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),

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
                              Text('৳ ${currencyFormat.format(staff.preDue)}', style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.balanceAlert)),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('THIS MONTH', style: TextStyle(fontSize: 8, color: AppColors.textMuted, fontWeight: FontWeight.bold)),
                              Text('৳ ${currencyFormat.format(monthTotal)}', style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.debitRed)),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('PAID', style: TextStyle(fontSize: 8, color: AppColors.textMuted, fontWeight: FontWeight.bold)),
                              Text('৳ ${currencyFormat.format(staff.paid)}', style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.creditGreen)),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('$activeDays canteen visit${activeDays == 1 ? '' : 's'}', style: const TextStyle(fontSize: 9, color: AppColors.textMuted)),
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

  Widget _buildFullStaffTable(
    BuildContext context,
    WidgetRef ref,
    PStaffRegisterState state,
    List<PStaffProfile> staffList,
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
              const DataColumn(label: Text('BD NO', style: TextStyle(color: AppColors.bafGold, fontWeight: FontWeight.bold, fontSize: 9.5))),
              const DataColumn(label: Text('NAME & RANK', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10.5))),
              const DataColumn(label: Text('OFFICE', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 9.5))),
              const DataColumn(label: Text('PRE DUE', style: TextStyle(color: AppColors.bafGold, fontWeight: FontWeight.bold, fontSize: 9.5))),
              ...List.generate(daysInMonth, (d) {
                return DataColumn(
                  label: Text('${d + 1}', style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Colors.white)),
                );
              }),
              const DataColumn(label: Text('MONTH', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Colors.white70))),
              const DataColumn(label: Text('TOTAL', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.bafGold))),
              const DataColumn(label: Text('PAID', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: AppColors.creditGreen))),
              const DataColumn(label: Text('DUE', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900, color: Colors.white))),
            ],
            rows: [
              ...staffList.map((staff) {
                final monthTotal = state.getStaffMonthTotal(staff.id, state.selectedYear, state.selectedMonth);
                final grandTotal = staff.preDue + monthTotal;
                final netDue = grandTotal - staff.paid;

                return DataRow(
                  cells: [
                    DataCell(
                      InkWell(
                        onTap: () => _showStaffAccountEditModal(context, ref, staff),
                        child: Text(staff.bdNo, style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: AppColors.bafDeepBlue)),
                      ),
                    ),
                    DataCell(
                      InkWell(
                        onTap: () => _showStaffAccountEditModal(context, ref, staff),
                        child: Text('${staff.rank} ${staff.name}', style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: AppColors.bafNavy)),
                      ),
                    ),
                    DataCell(Text(staff.office, style: const TextStyle(fontSize: 9, color: AppColors.textSecondary))),
                    DataCell(Text(staff.preDue > 0 ? staff.preDue.toStringAsFixed(0) : '-', style: const TextStyle(fontSize: 9.5, color: AppColors.balanceAlert, fontWeight: FontWeight.bold))),
                    ...List.generate(daysInMonth, (d) {
                      final date = DateTime(state.selectedYear, state.selectedMonth, d + 1);
                      final exp = state.getExpense(staff.id, date);
                      final hasVal = exp != null && exp.amount > 0;
                      return DataCell(
                        InkWell(
                          onTap: () => _showQuickEditModal(context, ref, staff, date, exp?.amount ?? 0.0),
                          child: Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            color: hasVal ? AppColors.bafLightBlue.withAlpha(120) : Colors.transparent,
                            child: Text(
                              hasVal ? exp.amount.toStringAsFixed(0) : '-',
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
                    DataCell(Text(currencyFormat.format(monthTotal), style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: AppColors.debitRed))),
                    DataCell(Text(currencyFormat.format(grandTotal), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.bafNavy))),
                    DataCell(Text(staff.paid > 0 ? currencyFormat.format(staff.paid) : '-', style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: AppColors.creditGreen))),
                    DataCell(Text(currencyFormat.format(netDue), style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900, color: netDue > 0 ? AppColors.debitRed : AppColors.cleared))),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
