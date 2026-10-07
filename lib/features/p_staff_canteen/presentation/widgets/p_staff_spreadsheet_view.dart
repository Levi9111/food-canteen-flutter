import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/canteen_theme_extension.dart';
import '../../../../core/widgets/baf_rts_crest.dart';
import '../../../../core/widgets/canteen_calculator_dialog.dart';
import '../../../../core/widgets/modal_action_bar.dart';
import '../../models/p_staff_models.dart';
import '../../providers/p_staff_register_provider.dart';
import '../../services/p_staff_pdf_export_service.dart';

class PStaffSpreadsheetView extends ConsumerStatefulWidget {
  const PStaffSpreadsheetView({super.key});

  @override
  ConsumerState<PStaffSpreadsheetView> createState() => _PStaffSpreadsheetViewState();
}

class _PStaffSpreadsheetViewState extends ConsumerState<PStaffSpreadsheetView> {
  bool _isGeneratingPdf = false;

  void _showRecordPaymentDialog(
    BuildContext context,
    PStaffProfile staff,
  ) {
    final theme = context.canteenTheme;
    final amountController = TextEditingController();
    final noteController = TextEditingController();
    DateTime paymentDate = DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final bottomInset = MediaQuery.of(ctx).viewInsets.bottom;
            return Padding(
              padding: EdgeInsets.only(bottom: bottomInset),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 460),
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
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          color: AppColors.bafNavy,
                          child: Row(
                            children: [
                              const Icon(Icons.payments_outlined, color: AppColors.bafGold, size: 18),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'LOG PAYMENT • ${staff.rank} ${staff.name} (${staff.bdNo})',
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
                              Text(
                                'PAYMENT DATE *',
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: theme.textSecondary),
                              ),
                              const SizedBox(height: 4),
                              InkWell(
                                onTap: () async {
                                  final picked = await showDatePicker(
                                    context: ctx,
                                    initialDate: paymentDate,
                                    firstDate: DateTime(2024),
                                    lastDate: DateTime(2030),
                                  );
                                  if (picked != null) {
                                    setModalState(() => paymentDate = picked);
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: theme.cardBackground,
                                    border: Border.all(color: theme.cardBorder),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.calendar_month, size: 14, color: theme.accentGold),
                                      const SizedBox(width: 8),
                                      Text(
                                        DateFormat('dd MMMM yyyy').format(paymentDate),
                                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: theme.textPrimary),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'AMOUNT RECEIVED (TK) *',
                                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: theme.textSecondary),
                                  ),
                                  InkWell(
                                    onTap: () async {
                                      final cur = double.tryParse(amountController.text.trim());
                                      final calcResult = await showCanteenCalculator(
                                        context,
                                        initialValue: cur,
                                      );
                                      if (calcResult != null) {
                                        amountController.text = calcResult.toStringAsFixed(2);
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: AppColors.bafNavy,
                                        border: Border.all(color: AppColors.bafGold),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.calculate_outlined, color: AppColors.bafGold, size: 14),
                                          SizedBox(width: 4),
                                          Text(
                                            'CALCULATOR',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.bafGold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              TextField(
                                controller: amountController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                autofocus: true,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: theme.credit,
                                ),
                                decoration: const InputDecoration(
                                  prefixText: '৳ ',
                                  hintText: '0.00',
                                  isDense: true,
                                ),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                'RECEIPT / NOTE / REMARKS',
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: theme.textSecondary),
                              ),
                              const SizedBox(height: 4),
                              TextField(
                                controller: noteController,
                                decoration: const InputDecoration(
                                  hintText: 'e.g. Cash payment on salary day, partial settlement',
                                  isDense: true,
                                ),
                              ),
                              const SizedBox(height: 18),
                              ModalActionBar(
                                cancelLabel: 'CANCEL',
                                confirmLabel: 'SAVE PAYMENT',
                                onCancel: () => Navigator.of(ctx).pop(),
                                onConfirm: () async {
                                  final amt = double.tryParse(amountController.text.trim()) ?? 0.0;
                                  if (amt <= 0) return;
                                  await ref.read(pStaffRegisterProvider.notifier).recordStaffPayment(
                                    staffId: staff.id,
                                    amount: amt,
                                    date: paymentDate,
                                    receiptNote: noteController.text.trim().isEmpty ? null : noteController.text.trim(),
                                  );
                                  if (ctx.mounted) {
                                    Navigator.of(ctx).pop();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Payment logged: ${staff.name} • ৳ ${amt.toStringAsFixed(2)}'),
                                        backgroundColor: AppColors.cleared,
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
      },
    );
  }

  Future<void> _handleDownloadPdf(
    BuildContext context,
    StaffMonthlySummary summary,
    PStaffRegisterState state,
  ) async {
    setState(() => _isGeneratingPdf = true);

    try {
      final pdfBytes = await PStaffPdfExportService.generateStaffSpreadsheetPdf(
        summary: summary,
        year: state.selectedYear,
        month: state.selectedMonth,
      );

      final monthStr = state.selectedMonth.toString().padLeft(2, '0');
      final bdClean = summary.staff.bdNo.replaceAll('/', '_');
      final filename = 'BAF_RTS_PStaff_${bdClean}_${state.selectedYear}_$monthStr.pdf';

      final savedPath = await PStaffPdfExportService.downloadPdfToDevice(
        pdfBytes: pdfBytes,
        filename: filename,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.bafNavy,
            duration: const Duration(seconds: 5),
            content: Row(
              children: [
                const Icon(Icons.download_done, color: AppColors.bafGold, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'P-STAFF PDF DOWNLOAD COMPLETE',
                        style: TextStyle(color: AppColors.bafGold, fontWeight: FontWeight.bold, fontSize: 11),
                      ),
                      Text(
                        'Saved: $savedPath',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            action: SnackBarAction(
              label: 'SHARE',
              textColor: AppColors.bafGold,
              onPressed: () {
                PStaffPdfExportService.shareOrOpenPdf(pdfBytes: pdfBytes, filename: filename);
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: AppColors.debitRed, content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isGeneratingPdf = false);
    }
  }

  Future<void> _handleSharePdf(
    BuildContext context,
    StaffMonthlySummary summary,
    PStaffRegisterState state,
  ) async {
    setState(() => _isGeneratingPdf = true);

    try {
      final pdfBytes = await PStaffPdfExportService.generateStaffSpreadsheetPdf(
        summary: summary,
        year: state.selectedYear,
        month: state.selectedMonth,
      );

      final monthStr = state.selectedMonth.toString().padLeft(2, '0');
      final bdClean = summary.staff.bdNo.replaceAll('/', '_');
      final filename = 'BAF_RTS_PStaff_${bdClean}_${state.selectedYear}_$monthStr.pdf';

      await PStaffPdfExportService.shareOrOpenPdf(pdfBytes: pdfBytes, filename: filename);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: AppColors.debitRed, content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isGeneratingPdf = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pStaffRegisterProvider);
    final notifier = ref.read(pStaffRegisterProvider.notifier);
    final currencyFormat = NumberFormat('#,##0.00', 'en_US');
    final dateDisplayFormat = DateFormat('dd MMM yyyy');
    final dayNameFormat = DateFormat('EEEE');

    final monthsList = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];

    final currentStaff = state.selectedStaffId != null
        ? state.getStaffById(state.selectedStaffId!)
        : (state.staffProfiles.isNotEmpty ? state.staffProfiles.first : null);

    if (currentStaff == null) {
      return const Center(child: Text('No P-Staff profiles available'));
    }

    final summary = state.getStaffMonthlySummary(
      currentStaff.id,
      state.selectedYear,
      state.selectedMonth,
    );

    final theme = context.canteenTheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final isMobile = screenWidth < 800;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Toolbar: Select Staff, Month, Year & Download
            Container(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 14, vertical: 6),
              decoration: BoxDecoration(
                color: theme.cardBackground,
                border: Border(bottom: BorderSide(color: theme.cardBorderLight)),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Text('STAFF:', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: theme.textSecondary)),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: theme.surface, border: Border.all(color: theme.cardBorder)),
                      child: DropdownButton<String>(
                        value: currentStaff.id,
                        isDense: true,
                        underline: const SizedBox(),
                        dropdownColor: theme.cardBackground,
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: theme.textPrimary),
                        items: state.staffProfiles.map((s) {
                          return DropdownMenuItem(
                            value: s.id,
                            child: Text('${s.rank} ${s.name} (${s.bdNo})', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: theme.textPrimary)),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) notifier.setSelectedStaffId(val);
                        },
                      ),
                    ),

                    const SizedBox(width: 8),

                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: theme.surface, border: Border.all(color: theme.cardBorder)),
                      child: DropdownButton<int>(
                        value: state.selectedMonth,
                        isDense: true,
                        underline: const SizedBox(),
                        dropdownColor: theme.cardBackground,
                        style: TextStyle(fontSize: 11, color: theme.textPrimary),
                        items: List.generate(12, (i) => i + 1).map((m) {
                          return DropdownMenuItem(value: m, child: Text(monthsList[m - 1], style: TextStyle(fontSize: 11, color: theme.textPrimary)));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) notifier.setSelectedMonth(state.selectedYear, val);
                        },
                      ),
                    ),

                    const SizedBox(width: 8),

                    ElevatedButton.icon(
                      icon: const Icon(Icons.add_card, size: 13),
                      label: const Text('+ LOG PAYMENT'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.credit,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                        textStyle: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () => _showRecordPaymentDialog(context, currentStaff),
                    ),

                    const SizedBox(width: 8),

                    ElevatedButton.icon(
                      icon: _isGeneratingPdf
                          ? const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.bafNavy))
                          : const Icon(Icons.picture_as_pdf, size: 14),
                      label: Text(_isGeneratingPdf ? 'PREPARING...' : 'DOWNLOAD PDF'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.bafGold,
                        foregroundColor: AppColors.bafNavy,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        textStyle: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold),
                      ),
                      onPressed: _isGeneratingPdf ? null : () => _handleDownloadPdf(context, summary, state),
                    ),

                    const SizedBox(width: 6),

                    OutlinedButton.icon(
                      icon: const Icon(Icons.share, size: 13),
                      label: const Text('SHARE'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.accentGold,
                        side: BorderSide(color: theme.accentGold),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        textStyle: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold),
                      ),
                      onPressed: _isGeneratingPdf ? null : () => _handleSharePdf(context, summary, state),
                    ),
                  ],
                ),
              ),
            ),

            // Accounting Header Strip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              color: AppColors.bafNavy,
              child: Row(
                children: [
                  Expanded(
                    child: _buildHeaderMetric('PRE DUE', '৳ ${currencyFormat.format(summary.preDue)}', AppColors.balanceAlert),
                  ),
                  Expanded(
                    child: _buildHeaderMetric('MONTH SPEND', '৳ ${currencyFormat.format(summary.totalMonthlySpending)}', Colors.white),
                  ),
                  Expanded(
                    child: _buildHeaderMetric('PAID RANDOM', '৳ ${currencyFormat.format(summary.paid)}', Colors.greenAccent),
                  ),
                  Expanded(
                    child: _buildHeaderMetric('EFFECTIVE BILL', '৳ ${currencyFormat.format(summary.effectiveBill)}', AppColors.bafGold),
                  ),
                ],
              ),
            ),

            // Document Viewport
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: isMobile ? 6 : 16, vertical: isMobile ? 8 : 12),
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 940),
                    decoration: BoxDecoration(
                      color: theme.cardBackground,
                      border: Border.all(color: theme.accentGold, width: 1.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Masthead
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          color: AppColors.bafNavy,
                          child: Row(
                            children: [
                              const BafRtsCrest(size: 42),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "PEOPLE'S REPUBLIC OF BANGLADESH • BANGLADESH AIR FORCE",
                                      style: TextStyle(color: AppColors.bafGold, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.8),
                                    ),
                                    const SizedBox(height: 1),
                                    const Text(
                                      'RECRUITS TRAINING SCHOOL (RTS)',
                                      style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      'FOOD CANTEEN • P-STAFF STATEMENT (${currentStaff.rank} ${currentStaff.name} • ${currentStaff.bdNo})',
                                      style: const TextStyle(color: Colors.white70, fontSize: 9.5, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Metadata Strip
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          color: theme.surface,
                          child: Wrap(
                            spacing: 12,
                            runSpacing: 4,
                            alignment: WrapAlignment.spaceBetween,
                            children: [
                              _buildMetaItem('STAFF NAME', '${currentStaff.rank} ${currentStaff.name}', theme: theme),
                              _buildMetaItem('BD NUMBER', currentStaff.bdNo, theme: theme),
                              _buildMetaItem('OFFICE / SECTION', currentStaff.office, theme: theme),
                              _buildMetaItem('PERIOD', '${monthsList[state.selectedMonth - 1].toUpperCase()} ${state.selectedYear}', theme: theme),
                              _buildMetaItem('VISITS', '${summary.activeDaysCount} Days', theme: theme),
                            ],
                          ),
                        ),

                        // Table - Wrapped in horizontal scroll for mobile (ITEMS CONSUMED REMOVED)
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SizedBox(
                            width: isMobile ? 680 : null,
                            child: Table(
                              border: TableBorder.all(color: theme.cardBorder, width: 0.8),
                              columnWidths: const {
                                0: FixedColumnWidth(48),
                                1: FixedColumnWidth(105),
                                2: FixedColumnWidth(95),
                                3: FlexColumnWidth(2.2),
                                4: FixedColumnWidth(105),
                                5: FixedColumnWidth(110),
                              },
                              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                              children: [
                                TableRow(
                                  decoration: const BoxDecoration(color: AppColors.bafNavy),
                                  children: [
                                    _buildCell('DAY', isHeader: true, align: TextAlign.center, theme: theme),
                                    _buildCell('DATE', isHeader: true, theme: theme),
                                    _buildCell('WEEKDAY', isHeader: true, theme: theme),
                                    _buildCell('DUTY IN-CHARGE', isHeader: true, theme: theme),
                                    _buildCell('STAFF VERIFICATION', isHeader: true, align: TextAlign.center, theme: theme),
                                    _buildCell('PRICE (TK)', isHeader: true, align: TextAlign.right, theme: theme),
                                  ],
                                ),
                                ...summary.days.map((record) {
                                  final isEven = record.dayNumber % 2 == 0;
                                  final hasSpending = record.amount > 0;
                                  return TableRow(
                                    decoration: BoxDecoration(
                                      color: hasSpending
                                          ? theme.tableHighlight
                                          : (isEven ? theme.cardBackground : theme.stripe),
                                    ),
                                    children: [
                                      _buildCell(
                                        record.dayNumber.toString().padLeft(2, '0'),
                                        align: TextAlign.center,
                                        isBold: true,
                                        color: hasSpending ? AppColors.bafGold : theme.textSecondary,
                                        theme: theme,
                                      ),
                                      _buildCell(dateDisplayFormat.format(record.date), theme: theme),
                                      _buildCell(
                                        dayNameFormat.format(record.date),
                                        color: (record.date.weekday == DateTime.friday) ? theme.debit : theme.textPrimary,
                                        theme: theme,
                                      ),
                                      _buildCell(
                                        hasSpending ? record.recordedBy : '—',
                                        color: hasSpending ? theme.textPrimary : theme.textSecondary,
                                        theme: theme,
                                      ),
                                      _buildCell(
                                        hasSpending ? 'Recorded' : '—',
                                        align: TextAlign.center,
                                        color: hasSpending ? theme.credit : theme.textSecondary,
                                        theme: theme,
                                      ),
                                      _buildCell(
                                        hasSpending ? '৳ ${currencyFormat.format(record.amount)}' : '—',
                                        align: TextAlign.right,
                                        isBold: hasSpending,
                                        color: hasSpending ? theme.debit : theme.textSecondary,
                                        theme: theme,
                                      ),
                                    ],
                                  );
                                }),

                                // Subtotal 1
                                TableRow(
                                  decoration: const BoxDecoration(color: AppColors.bafNavy),
                                  children: [
                                    _buildCell('', isHeader: true, theme: theme),
                                    _buildCell('1. MONTH TOTAL', isHeader: true, isBold: true, theme: theme),
                                    _buildCell('', isHeader: true, theme: theme),
                                    _buildCell('CURRENT MONTH TOTAL PRICE', isHeader: true, isBold: true, theme: theme),
                                    _buildCell('AUDITED', isHeader: true, align: TextAlign.center, theme: theme),
                                    _buildCell('৳ ${currencyFormat.format(summary.totalMonthlySpending)}', isHeader: true, align: TextAlign.right, isBold: true, color: AppColors.bafGold, theme: theme),
                                  ],
                                ),

                                // Subtotal 2: Pre Due
                                TableRow(
                                  decoration: BoxDecoration(color: theme.surface),
                                  children: [
                                    _buildCell('', isBold: true, theme: theme),
                                    _buildCell('2. PREVIOUS DUE', isBold: true, color: AppColors.balanceAlert, theme: theme),
                                    _buildCell('', theme: theme),
                                    _buildCell('ARREARS BROUGHT FORWARD', isBold: true, color: theme.textSecondary, theme: theme),
                                    _buildCell('CONFIRMED', align: TextAlign.center, theme: theme),
                                    _buildCell('৳ ${currencyFormat.format(summary.preDue)}', align: TextAlign.right, isBold: true, color: AppColors.balanceAlert, theme: theme),
                                  ],
                                ),

                                // Subtotal 3: Grand Total
                                TableRow(
                                  decoration: const BoxDecoration(color: AppColors.bafNavy),
                                  children: [
                                    _buildCell('', isHeader: true, theme: theme),
                                    _buildCell('3. GROSS TOTAL', isHeader: true, isBold: true, theme: theme),
                                    _buildCell('', isHeader: true, theme: theme),
                                    _buildCell('GROSS LIABILITY (PRE DUE + MONTH)', isHeader: true, isBold: true, theme: theme),
                                    _buildCell('VERIFIED', isHeader: true, align: TextAlign.center, theme: theme),
                                    _buildCell('৳ ${currencyFormat.format(summary.grandTotal)}', isHeader: true, align: TextAlign.right, isBold: true, color: AppColors.bafGold, theme: theme),
                                  ],
                                ),

                                // Subtotal 4: Less Paid
                                TableRow(
                                  decoration: BoxDecoration(color: theme.credit.withAlpha(25)),
                                  children: [
                                    _buildCell('', theme: theme),
                                    _buildCell('4. LESS: PAID', isBold: true, color: theme.credit, theme: theme),
                                    _buildCell('', theme: theme),
                                    _buildCell('TOTAL RANDOM PAYMENTS RECEIVED', isBold: true, color: theme.credit, theme: theme),
                                    _buildCell('RECEIPTED', align: TextAlign.center, theme: theme),
                                    _buildCell('৳ ${currencyFormat.format(summary.paid)}', align: TextAlign.right, isBold: true, color: theme.credit, theme: theme),
                                  ],
                                ),

                                // Subtotal 5: Effective Bill
                                TableRow(
                                  decoration: const BoxDecoration(color: AppColors.bafNavy),
                                  children: [
                                    _buildCell('', isHeader: true, theme: theme),
                                    _buildCell('5. EFFECTIVE BILL', isHeader: true, isBold: true, theme: theme),
                                    _buildCell('', isHeader: true, theme: theme),
                                    _buildCell('NET EFFECTIVE BILL AT MONTH END', isHeader: true, isBold: true, theme: theme),
                                    _buildCell(summary.effectiveBill <= 0 ? 'CLEARED' : 'PENDING', isHeader: true, align: TextAlign.center, theme: theme),
                                    _buildCell('৳ ${currencyFormat.format(summary.effectiveBill)}', isHeader: true, align: TextAlign.right, isBold: true, color: summary.effectiveBill > 0 ? Colors.amberAccent : Colors.greenAccent, theme: theme),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Section 2: Random Payments with Dates List
                        Container(
                          margin: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.surface,
                            border: Border.all(color: theme.cardBorder),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                color: AppColors.bafNavy,
                                child: Row(
                                  children: [
                                    const Icon(Icons.payments_outlined, color: AppColors.bafGold, size: 16),
                                    const SizedBox(width: 8),
                                    const Expanded(
                                      child: Text(
                                        'RANDOM PAYMENTS LOGGED (SHOWING DATES & PRICES)',
                                        style: TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () => _showRecordPaymentDialog(context, currentStaff),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        color: AppColors.bafGold,
                                        child: const Text(
                                          '+ LOG PAYMENT',
                                          style: TextStyle(color: AppColors.bafNavy, fontSize: 9.5, fontWeight: FontWeight.w900),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (summary.payments.isEmpty)
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Text(
                                    'No random payment logged for this month. Effective bill equals gross balance.',
                                    style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: theme.textSecondary),
                                  ),
                                )
                              else
                                ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: summary.payments.length,
                                  separatorBuilder: (context, index) => Divider(height: 1, color: theme.cardBorderLight),
                                  itemBuilder: (ctx, idx) {
                                    final p = summary.payments[idx];
                                    return ListTile(
                                      dense: true,
                                      visualDensity: VisualDensity.compact,
                                      leading: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        color: theme.tableHighlight,
                                        child: Text(
                                          DateFormat('dd MMM yyyy').format(p.date),
                                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: theme.textPrimary),
                                        ),
                                      ),
                                      title: Text(
                                        p.receiptNote ?? 'Random payment deposit',
                                        style: TextStyle(fontSize: 11, color: theme.textPrimary),
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            '৳ ${currencyFormat.format(p.amount)}',
                                            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: theme.credit),
                                          ),
                                          const SizedBox(width: 6),
                                          IconButton(
                                            icon: const Icon(Icons.delete_outline, size: 16, color: AppColors.debitRed),
                                            onPressed: () {
                                              ref.read(pStaffRegisterProvider.notifier).deleteStaffPayment(currentStaff.id, p.id);
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                            ],
                          ),
                        ),

                        // Signature Blocks
                        Container(
                          padding: const EdgeInsets.all(16),
                          color: theme.cardBackground,
                          child: Wrap(
                            spacing: 16,
                            runSpacing: 16,
                            alignment: WrapAlignment.spaceAround,
                            children: [
                              _buildSignatureColumn('INDIVIDUAL P-STAFF', currentStaff.rank, currentStaff.bdNo, theme: theme),
                              _buildSignatureColumn('NCOIC (CANTEEN)', 'Sergeant (Sgt)', 'RTS BAF', theme: theme),
                              _buildSignatureColumn('JCOIC (CANTEEN)', 'Warrant Officer (WO)', 'RTS BAF', theme: theme),
                              _buildSignatureColumn('COUNTERSIGNED (OC)', 'Officer Commanding', 'RTS (BAF)', theme: theme),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeaderMetric(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(label, style: const TextStyle(fontSize: 8.5, color: Colors.white70, fontWeight: FontWeight.bold)),
        const SizedBox(height: 1),
        Text(value, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900, color: color)),
      ],
    );
  }

  Widget _buildMetaItem(String title, String value, {required CanteenThemeColors theme}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title, style: TextStyle(fontSize: 8, color: theme.textSecondary, fontWeight: FontWeight.bold)),
        Text(value, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900, color: theme.textPrimary)),
      ],
    );
  }

  Widget _buildCell(
    String text, {
    bool isHeader = false,
    bool isBold = false,
    TextAlign align = TextAlign.left,
    Color? color,
    required CanteenThemeColors theme,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      child: Text(
        text,
        textAlign: align,
        style: TextStyle(
          fontSize: isHeader ? 9.5 : 10.5,
          fontWeight: (isHeader || isBold) ? FontWeight.bold : FontWeight.normal,
          color: color ?? (isHeader ? Colors.white : theme.textPrimary),
        ),
      ),
    );
  }

  Widget _buildSignatureColumn(String title, String rank, String unit, {required CanteenThemeColors theme}) {
    return Column(
      children: [
        Container(width: 120, height: 1, color: theme.cardBorder),
        const SizedBox(height: 5),
        Text(title, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.bafGold)),
        Text(rank, style: TextStyle(fontSize: 8.5, color: theme.textSecondary)),
        Text(unit, style: TextStyle(fontSize: 8, color: theme.textSecondary)),
      ],
    );
  }
}
