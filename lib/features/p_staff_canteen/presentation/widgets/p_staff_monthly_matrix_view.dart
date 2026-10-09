import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/canteen_theme_extension.dart';
import '../../../../core/widgets/modal_action_bar.dart';
import '../../constants/p_staff_constants.dart';
import '../../models/p_staff_models.dart';
import '../../providers/p_staff_register_provider.dart';
import '../../services/p_staff_pdf_export_service.dart';

class PStaffMonthlyMatrixView extends ConsumerStatefulWidget {
  const PStaffMonthlyMatrixView({super.key});

  @override
  ConsumerState<PStaffMonthlyMatrixView> createState() => _PStaffMonthlyMatrixViewState();
}

class _PStaffMonthlyMatrixViewState extends ConsumerState<PStaffMonthlyMatrixView> {
  bool _forceMatrixTable = false;
  bool _isGeneratingPdf = false;

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
                              TextField(
                                controller: nameCtrl,
                                style: TextStyle(color: theme.textPrimary, fontSize: 13),
                                decoration: const InputDecoration(isDense: true),
                              ),
                              const SizedBox(height: 10),

                              Text('RANK:', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: theme.textSecondary)),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(color: theme.cardBackground, border: Border.all(color: theme.cardBorder)),
                                child: DropdownButton<String>(
                                  value: PStaffConstants.ranks.contains(selectedRank) ? selectedRank : PStaffConstants.ranks.first,
                                  dropdownColor: theme.cardBackground,
                                  iconEnabledColor: theme.textPrimary,
                                  style: TextStyle(color: theme.textPrimary, fontSize: 12, fontWeight: FontWeight.w600),
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
                                  dropdownColor: theme.cardBackground,
                                  iconEnabledColor: theme.textPrimary,
                                  style: TextStyle(color: theme.textPrimary, fontSize: 12, fontWeight: FontWeight.w600),
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
                              TextField(
                                controller: preDueCtrl,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                style: TextStyle(color: theme.textPrimary, fontSize: 13),
                                decoration: const InputDecoration(isDense: true, prefixText: '৳ '),
                              ),
                              const SizedBox(height: 10),

                              Text('PAID AMOUNT (TK):', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: theme.textSecondary)),
                              const SizedBox(height: 4),
                              TextField(
                                controller: paidCtrl,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                style: TextStyle(color: theme.textPrimary, fontSize: 13),
                                decoration: const InputDecoration(isDense: true, prefixText: '৳ '),
                              ),
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
    final theme = context.canteenTheme;

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
              decoration: BoxDecoration(
                color: theme.surface,
                border: Border(bottom: BorderSide(color: theme.cardBorderLight)),
              ),
              child: isMobile
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Row 1: Office Selector
                        Row(
                          children: [
                            Text('OFFICE:', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: theme.textSecondary)),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: theme.cardBackground,
                                  border: Border.all(color: theme.cardBorder),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: DropdownButton<String>(
                                  value: state.selectedOffice,
                                  dropdownColor: theme.cardBackground,
                                  iconEnabledColor: theme.textPrimary,
                                  isExpanded: true,
                                  isDense: true,
                                  underline: const SizedBox(),
                                  style: TextStyle(fontSize: 11, color: theme.textPrimary, fontWeight: FontWeight.bold),
                                  items: PStaffConstants.offices.map((o) => DropdownMenuItem(
                                    value: o,
                                    child: Text(o, style: TextStyle(fontSize: 11, color: theme.textPrimary, fontWeight: FontWeight.bold)),
                                  )).toList(),
                                  onChanged: (val) {
                                    if (val != null) notifier.setSelectedOffice(val);
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        // Row 2: Period + Mode Toggle + Always-Visible Download PDF Button
                        Row(
                          children: [
                            Text('PERIOD:', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: theme.textSecondary)),
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: theme.cardBackground,
                                border: Border.all(color: theme.cardBorder),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: DropdownButton<int>(
                                value: state.selectedMonth,
                                dropdownColor: theme.cardBackground,
                                iconEnabledColor: theme.textPrimary,
                                isDense: true,
                                underline: const SizedBox(),
                                style: TextStyle(fontSize: 11, color: theme.textPrimary, fontWeight: FontWeight.bold),
                                items: List.generate(12, (i) => i + 1).map((m) {
                                  return DropdownMenuItem(
                                    value: m,
                                    child: Text(monthsList[m - 1], style: TextStyle(fontSize: 11, color: theme.textPrimary, fontWeight: FontWeight.bold)),
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
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: DropdownButton<int>(
                                value: state.selectedYear,
                                dropdownColor: theme.cardBackground,
                                iconEnabledColor: theme.textPrimary,
                                isDense: true,
                                underline: const SizedBox(),
                                style: TextStyle(fontSize: 11, color: theme.textPrimary, fontWeight: FontWeight.bold),
                                items: [2025, 2026, 2027].map((y) {
                                  return DropdownMenuItem(
                                    value: y,
                                    child: Text('$y', style: TextStyle(fontSize: 11, color: theme.textPrimary, fontWeight: FontWeight.bold)),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) notifier.setSelectedMonth(val, state.selectedMonth);
                                },
                              ),
                            ),
                            const Spacer(),
                            // Prominent PDF Download Button
                            InkWell(
                              onTap: _isGeneratingPdf ? null : () => _handleDownloadPdf(state),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                decoration: BoxDecoration(
                                  color: AppColors.bafGold,
                                  borderRadius: BorderRadius.circular(3),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.15),
                                      blurRadius: 3,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _isGeneratingPdf
                                        ? const SizedBox(
                                            width: 12,
                                            height: 12,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 1.5,
                                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.bafNavy),
                                            ),
                                          )
                                        : const Icon(Icons.download, size: 13, color: AppColors.bafNavy),
                                    const SizedBox(width: 4),
                                    Text(
                                      _isGeneratingPdf ? 'SAVING...' : 'DOWNLOAD PDF',
                                      style: const TextStyle(
                                        color: AppColors.bafNavy,
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            InkWell(
                              onTap: () => setState(() => _forceMatrixTable = !_forceMatrixTable),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
                                decoration: BoxDecoration(
                                  color: _forceMatrixTable ? AppColors.bafDeepBlue : AppColors.bafNavy,
                                  border: Border.all(color: AppColors.bafGold),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: Icon(
                                  _forceMatrixTable ? Icons.view_agenda : Icons.grid_on,
                                  size: 13,
                                  color: AppColors.bafGold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          Text('OFFICE:', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: theme.textSecondary)),
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: theme.cardBackground,
                              border: Border.all(color: theme.cardBorder),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: DropdownButton<String>(
                              value: state.selectedOffice,
                              dropdownColor: theme.cardBackground,
                              iconEnabledColor: theme.textPrimary,
                              isDense: true,
                              underline: const SizedBox(),
                              style: TextStyle(fontSize: 11, color: theme.textPrimary, fontWeight: FontWeight.bold),
                              items: PStaffConstants.offices.map((o) => DropdownMenuItem(
                                value: o,
                                child: Text(o, style: TextStyle(fontSize: 11, color: theme.textPrimary, fontWeight: FontWeight.bold)),
                              )).toList(),
                              onChanged: (val) {
                                if (val != null) notifier.setSelectedOffice(val);
                              },
                            ),
                          ),

                          const SizedBox(width: 8),

                          Text('PERIOD:', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: theme.textSecondary)),
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: theme.cardBackground,
                              border: Border.all(color: theme.cardBorder),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: DropdownButton<int>(
                              value: state.selectedMonth,
                              dropdownColor: theme.cardBackground,
                              iconEnabledColor: theme.textPrimary,
                              isDense: true,
                              underline: const SizedBox(),
                              style: TextStyle(fontSize: 11, color: theme.textPrimary, fontWeight: FontWeight.bold),
                              items: List.generate(12, (i) => i + 1).map((m) {
                                return DropdownMenuItem(
                                  value: m,
                                  child: Text(monthsList[m - 1], style: TextStyle(fontSize: 11, color: theme.textPrimary, fontWeight: FontWeight.bold)),
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
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: DropdownButton<int>(
                              value: state.selectedYear,
                              dropdownColor: theme.cardBackground,
                              iconEnabledColor: theme.textPrimary,
                              isDense: true,
                              underline: const SizedBox(),
                              style: TextStyle(fontSize: 11, color: theme.textPrimary, fontWeight: FontWeight.bold),
                              items: [2025, 2026, 2027].map((y) {
                                return DropdownMenuItem(
                                  value: y,
                                  child: Text('$y', style: TextStyle(fontSize: 11, color: theme.textPrimary, fontWeight: FontWeight.bold)),
                                );
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
                                borderRadius: BorderRadius.circular(3),
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

                          const SizedBox(width: 8),

                          // Download PDF Button
                          InkWell(
                            onTap: _isGeneratingPdf ? null : () => _handleDownloadPdf(state),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.bafGold,
                                border: Border.all(color: AppColors.bafGold),
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _isGeneratingPdf
                                      ? const SizedBox(
                                          width: 12,
                                          height: 12,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 1.5,
                                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.bafNavy),
                                          ),
                                        )
                                      : const Icon(Icons.download, size: 13, color: AppColors.bafNavy),
                                  const SizedBox(width: 4),
                                  Text(
                                    _isGeneratingPdf ? 'SAVING...' : 'DOWNLOAD PDF',
                                    style: const TextStyle(
                                      color: AppColors.bafNavy,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                    ),
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
    final theme = context.canteenTheme;
    if (staffList.isEmpty) {
      return Center(
        child: Text('No P-Staff profiles in selected office', style: TextStyle(color: theme.textSecondary)),
      );
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
              color: theme.cardBackground,
              border: Border.all(
                color: netDue > 0 ? AppColors.bafGold : theme.cardBorder,
                width: netDue > 0 ? 1.5 : 1.0,
              ),
              borderRadius: BorderRadius.circular(4),
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
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: theme.textPrimary),
                        ),
                      ),
                      InkWell(
                        onTap: () => _showStaffAccountEditModal(context, ref, staff),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: theme.stripe,
                            border: Border.all(color: AppColors.bafGold),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: const Text('EDIT', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.bafGold)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(staff.office, style: TextStyle(fontSize: 9.5, color: theme.textSecondary, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    decoration: BoxDecoration(
                      color: theme.stripe,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('PRE DUE', style: TextStyle(fontSize: 8, color: theme.textMuted, fontWeight: FontWeight.bold)),
                              Text('৳ ${currencyFormat.format(staff.preDue)}', style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.balanceAlert)),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('THIS MONTH', style: TextStyle(fontSize: 8, color: theme.textMuted, fontWeight: FontWeight.bold)),
                              Text('৳ ${currencyFormat.format(monthTotal)}', style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.debitRed)),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('PAID', style: TextStyle(fontSize: 8, color: theme.textMuted, fontWeight: FontWeight.bold)),
                              Text('৳ ${currencyFormat.format(staff.paid)}', style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.creditGreen)),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('NET DUE', style: TextStyle(fontSize: 8, color: theme.textPrimary, fontWeight: FontWeight.bold)),
                              Text('৳ ${currencyFormat.format(netDue)}', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900, color: netDue > 0 ? AppColors.debitRed : AppColors.creditGreen)),
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
                      Text('$activeDays canteen visit${activeDays == 1 ? '' : 's'}', style: TextStyle(fontSize: 9, color: theme.textMuted)),
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
    final theme = context.canteenTheme;
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.cardBackground,
            border: Border.all(color: theme.cardBorder, width: 1.0),
          ),
          child: DataTable(
            headingRowHeight: 36,
            dataRowMinHeight: 34,
            dataRowMaxHeight: 40,
            horizontalMargin: 8,
            columnSpacing: 8,
            headingRowColor: WidgetStateProperty.all(AppColors.bafNavy),
            dataRowColor: WidgetStateProperty.all(theme.cardBackground),
            dividerThickness: 1.0,
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
                        child: Text(staff.bdNo, style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: AppColors.bafSkyBlue)),
                      ),
                    ),
                    DataCell(
                      InkWell(
                        onTap: () => _showStaffAccountEditModal(context, ref, staff),
                        child: Text('${staff.rank} ${staff.name}', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: theme.textPrimary)),
                      ),
                    ),
                    DataCell(Text(staff.office, style: TextStyle(fontSize: 9, color: theme.textSecondary))),
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
                            color: hasVal ? theme.tableHighlight : Colors.transparent,
                            child: Text(
                              hasVal ? exp.amount.toStringAsFixed(0) : '-',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: hasVal ? FontWeight.bold : FontWeight.normal,
                                color: hasVal ? AppColors.debitRed : theme.textMuted,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                    DataCell(Text(currencyFormat.format(monthTotal), style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: AppColors.debitRed))),
                    DataCell(Text(currencyFormat.format(grandTotal), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: theme.textPrimary))),
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

  Future<void> _handleDownloadPdf(PStaffRegisterState state) async {
    setState(() => _isGeneratingPdf = true);
    try {
      final daysInMonth = DateTime(state.selectedYear, state.selectedMonth + 1, 0).day;
      final staffList = state.filteredStaffProfiles;

      final Map<String, Map<int, double>> expensesMap = {};
      for (final staff in staffList) {
        final Map<int, double> dayMap = {};
        for (int d = 1; d <= daysInMonth; d++) {
          final exp = state.getExpense(staff.id, DateTime(state.selectedYear, state.selectedMonth, d));
          if (exp != null && exp.amount > 0) {
            dayMap[d] = exp.amount;
          }
        }
        expensesMap[staff.id] = dayMap;
      }

      final totalPreDue = state.getAllStaffPreDueTotal();
      final totalMonthExpenses = state.getAllStaffMonthGrandTotal(state.selectedYear, state.selectedMonth);
      final totalPaid = state.getAllStaffPaidTotal();
      final totalNetDue = state.getAllStaffNetDueTotal(state.selectedYear, state.selectedMonth);

      final pdfBytes = await PStaffPdfExportService.generatePStaffMonthlyMatrixPdf(
        staffList: staffList,
        office: state.selectedOffice,
        year: state.selectedYear,
        month: state.selectedMonth,
        expensesMap: expensesMap,
        totalPreDue: totalPreDue,
        totalMonthExpenses: totalMonthExpenses,
        totalPaid: totalPaid,
        totalNetDue: totalNetDue,
      );

      final safeOffice = state.selectedOffice.replaceAll(' ', '_').replaceAll('/', '_');
      final filename =
          'BAF_RTS_PStaff_${safeOffice}_${state.selectedYear}_${state.selectedMonth.toString().padLeft(2, '0')}.pdf';

      final savedPath = await PStaffPdfExportService.downloadPdfToDevice(
        pdfBytes: pdfBytes,
        filename: filename,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.bafNavy,
          duration: const Duration(seconds: 4),
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: AppColors.bafGold, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'P-STAFF STATEMENT PDF DOWNLOAD COMPLETE',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.white),
                    ),
                    Text(
                      'Saved to: $savedPath',
                      style: const TextStyle(fontSize: 9.5, color: AppColors.bafSkyBlue),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red.shade900,
          content: Text('Failed to download PDF: $e'),
        ),
      );
    } finally {
      if (mounted) setState(() => _isGeneratingPdf = false);
    }
  }
}
