import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/baf_rts_crest.dart';
import '../../constants/canteen_constants.dart';
import '../../models/room_monthly_summary.dart';
import '../../providers/canteen_register_provider.dart';
import '../../services/canteen_pdf_export_service.dart';

class RoomSoftSpreadsheetView extends ConsumerStatefulWidget {
  const RoomSoftSpreadsheetView({super.key});

  @override
  ConsumerState<RoomSoftSpreadsheetView> createState() => _RoomSoftSpreadsheetViewState();
}

class _RoomSoftSpreadsheetViewState extends ConsumerState<RoomSoftSpreadsheetView> {
  bool _isGeneratingPdf = false;

  Future<void> _handleDownloadPdf(
    BuildContext context,
    RoomMonthlySummary summary,
    CanteenRegisterState state,
  ) async {
    setState(() => _isGeneratingPdf = true);

    try {
      final pdfBytes = await CanteenPdfExportService.generateRoomSpreadsheetPdf(
        summary: summary,
        entryNumber: state.activeEntry,
        squadron: state.selectedSquadron,
        room: state.selectedRoom,
        year: state.selectedYear,
        month: state.selectedMonth,
      );

      final monthStr = state.selectedMonth.toString().padLeft(2, '0');
      final roomSlug = state.selectedRoom.replaceAll(' ', '_');
      final filename = 'BAF_RTS_Canteen_Entry${state.activeEntry}_${state.selectedSquadron}_${roomSlug}_${state.selectedYear}_$monthStr.pdf';

      final savedPath = await CanteenPdfExportService.downloadPdfToDevice(
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
                        'PDF DOWNLOAD COMPLETE',
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
                CanteenPdfExportService.shareOrOpenPdf(
                  pdfBytes: pdfBytes,
                  filename: filename,
                );
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.debitRed,
            content: Text('Failed to generate PDF: $e'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isGeneratingPdf = false);
    }
  }

  Future<void> _handleSharePdf(
    BuildContext context,
    RoomMonthlySummary summary,
    CanteenRegisterState state,
  ) async {
    setState(() => _isGeneratingPdf = true);

    try {
      final pdfBytes = await CanteenPdfExportService.generateRoomSpreadsheetPdf(
        summary: summary,
        entryNumber: state.activeEntry,
        squadron: state.selectedSquadron,
        room: state.selectedRoom,
        year: state.selectedYear,
        month: state.selectedMonth,
      );

      final monthStr = state.selectedMonth.toString().padLeft(2, '0');
      final roomSlug = state.selectedRoom.replaceAll(' ', '_');
      final filename = 'BAF_RTS_Canteen_Entry${state.activeEntry}_${state.selectedSquadron}_${roomSlug}_${state.selectedYear}_$monthStr.pdf';

      await CanteenPdfExportService.shareOrOpenPdf(
        pdfBytes: pdfBytes,
        filename: filename,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.debitRed,
            content: Text('Failed to export PDF: $e'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isGeneratingPdf = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(canteenRegisterProvider);
    final notifier = ref.read(canteenRegisterProvider.notifier);
    final currencyFormat = NumberFormat('#,##0.00', 'en_US');
    final dateDisplayFormat = DateFormat('dd MMM yyyy');
    final dayNameFormat = DateFormat('EEEE');

    final monthsList = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];

    final RoomMonthlySummary summary = state.getRoomMonthlySummary(
      state.activeEntry,
      state.selectedSquadron,
      state.selectedRoom,
      state.selectedYear,
      state.selectedMonth,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final isMobile = screenWidth < 800;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Toolbar: Squadron, Room, Period & Direct Download Buttons
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 8 : 14,
                vertical: isMobile ? 6 : 8,
              ),
              decoration: const BoxDecoration(
                color: AppColors.ledgerSurface,
                border: Border(bottom: BorderSide(color: AppColors.ledgerBorderLight)),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    // Squadron Dropdown
                    const Text('SQN:', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: AppColors.ledgerBorder),
                      ),
                      child: DropdownButton<String>(
                        value: state.selectedSquadron,
                        isDense: true,
                        underline: const SizedBox(),
                        items: CanteenConstants.squadrons.map((sqn) {
                          return DropdownMenuItem(
                            value: sqn,
                            child: Text(sqn, style: const TextStyle(fontSize: 11)),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) notifier.setSelectedSquadron(val);
                        },
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Room Dropdown
                    const Text('ROOM:', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: AppColors.ledgerBorder),
                      ),
                      child: DropdownButton<String>(
                        value: state.selectedRoom,
                        isDense: true,
                        underline: const SizedBox(),
                        items: CanteenConstants.rooms.map((r) {
                          return DropdownMenuItem(
                            value: r,
                            child: Text(r, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) notifier.setSelectedRoom(val);
                        },
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Month & Year Dropdown
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

                    const SizedBox(width: 12),

                    // DOWNLOAD AS PDF BUTTON (Replaced printing logic)
                    ElevatedButton.icon(
                      icon: _isGeneratingPdf
                          ? const SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.bafNavy),
                            )
                          : const Icon(Icons.picture_as_pdf, size: 14),
                      label: Text(_isGeneratingPdf ? 'PREPARING...' : 'DOWNLOAD PDF'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.bafGold,
                        foregroundColor: AppColors.bafNavy,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        textStyle: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold),
                      ),
                      onPressed: _isGeneratingPdf
                          ? null
                          : () => _handleDownloadPdf(context, summary, state),
                    ),

                    const SizedBox(width: 6),

                    // SHARE PDF BUTTON
                    OutlinedButton.icon(
                      icon: const Icon(Icons.share, size: 13),
                      label: const Text('SHARE'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.bafNavy,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        textStyle: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold),
                      ),
                      onPressed: _isGeneratingPdf
                          ? null
                          : () => _handleSharePdf(context, summary, state),
                    ),
                  ],
                ),
              ),
            ),

            // Accounting Summary Strip (Pre Due, Month Spend, Paid, Net Due)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              color: AppColors.bafNavy,
              child: Row(
                children: [
                  Expanded(
                    child: _buildHeaderMetric(
                      'PRE DUE',
                      '৳ ${currencyFormat.format(summary.preDue)}',
                      AppColors.balanceAlert,
                    ),
                  ),
                  Expanded(
                    child: _buildHeaderMetric(
                      'MONTH SPEND',
                      '৳ ${currencyFormat.format(summary.totalMonthlySpending)}',
                      Colors.white,
                    ),
                  ),
                  Expanded(
                    child: _buildHeaderMetric(
                      'PAID',
                      '৳ ${currencyFormat.format(summary.paid)}',
                      Colors.greenAccent,
                    ),
                  ),
                  Expanded(
                    child: _buildHeaderMetric(
                      'NET DUE',
                      '৳ ${currencyFormat.format(summary.netDue)}',
                      AppColors.bafGold,
                    ),
                  ),
                ],
              ),
            ),

            // Document Viewport (Interactive View of the Official Document)
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 6 : 16,
                  vertical: isMobile ? 8 : 12,
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Container(
                    constraints: BoxConstraints(minWidth: isMobile ? 700 : 840, maxWidth: 940),
                    decoration: BoxDecoration(
                      color: AppColors.ledgerSurface,
                      border: Border.all(color: AppColors.bafNavy, width: 1.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Official Masthead
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
                                      style: TextStyle(
                                        color: AppColors.bafGold,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                    const SizedBox(height: 1),
                                    const Text(
                                      'RECRUITS TRAINING SCHOOL (RTS)',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'FOOD CANTEEN • ROOM EXPENDITURE SPREADSHEET (${state.selectedSquadron.toUpperCase()} SQN • ${state.selectedRoom.toUpperCase()})',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.bold,
                                      ),
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
                          color: AppColors.bafLightBlue,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildMetaItem('SQUADRON', '${state.selectedSquadron.toUpperCase()} SQN'),
                              _buildMetaItem('ROOM', state.selectedRoom.toUpperCase()),
                              _buildMetaItem('PERIOD', '${monthsList[state.selectedMonth - 1].toUpperCase()} ${state.selectedYear}'),
                              _buildMetaItem('ENTRY', 'ENTRY ${state.activeEntry}'),
                              _buildMetaItem('RANK', summary.rank.toUpperCase()),
                            ],
                          ),
                        ),

                        // Ledger Table
                        Table(
                          border: TableBorder.all(color: AppColors.ledgerBorder, width: 0.8),
                          columnWidths: const {
                            0: FixedColumnWidth(48),  // Day #
                            1: FixedColumnWidth(95),  // Date
                            2: FixedColumnWidth(85),  // Weekday
                            3: FlexColumnWidth(2.5),  // Particulars
                            4: FixedColumnWidth(95),  // Price
                            5: FixedColumnWidth(65),  // Duty
                            6: FixedColumnWidth(95),  // Rep Sign
                          },
                          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                          children: [
                            // Header
                            TableRow(
                              decoration: const BoxDecoration(color: AppColors.bafNavy),
                              children: [
                                _buildCell('DAY', isHeader: true, align: TextAlign.center),
                                _buildCell('DATE', isHeader: true),
                                _buildCell('WEEKDAY', isHeader: true),
                                _buildCell('ITEMS PICKED / PARTICULARS', isHeader: true),
                                _buildCell('PRICE (TK)', isHeader: true, align: TextAlign.right),
                                _buildCell('DUTY', isHeader: true, align: TextAlign.center),
                                _buildCell('REP SIGN', isHeader: true, align: TextAlign.center),
                              ],
                            ),

                            // Rows
                            ...summary.days.map((record) {
                              final isEven = record.dayNumber % 2 == 0;
                              final hasSpending = record.amount > 0;

                              return TableRow(
                                decoration: BoxDecoration(
                                  color: hasSpending
                                      ? (isEven ? AppColors.bafLightBlue.withAlpha(90) : AppColors.bafLightBlue.withAlpha(50))
                                      : (isEven ? AppColors.ledgerSurface : AppColors.ledgerStripe),
                                ),
                                children: [
                                  _buildCell(
                                    record.dayNumber.toString().padLeft(2, '0'),
                                    align: TextAlign.center,
                                    isBold: true,
                                    color: hasSpending ? AppColors.bafNavy : AppColors.textMuted,
                                  ),
                                  _buildCell(dateDisplayFormat.format(record.date)),
                                  _buildCell(
                                    dayNameFormat.format(record.date),
                                    color: (record.date.weekday == DateTime.friday)
                                        ? AppColors.debitRed
                                        : AppColors.textPrimary,
                                  ),
                                  _buildCell(
                                    record.itemsDescription ?? (hasSpending ? 'Canteen refreshments' : '—'),
                                    color: hasSpending ? AppColors.textPrimary : AppColors.textMuted,
                                  ),
                                  _buildCell(
                                    hasSpending ? '৳ ${currencyFormat.format(record.amount)}' : '—',
                                    align: TextAlign.right,
                                    isBold: hasSpending,
                                    color: hasSpending ? AppColors.debitRed : AppColors.textMuted,
                                  ),
                                  _buildCell(
                                    hasSpending ? record.recordedBy : '—',
                                    align: TextAlign.center,
                                    color: hasSpending ? AppColors.bafNavy : AppColors.textMuted,
                                  ),
                                  _buildCell(
                                    hasSpending ? (record.representativeName ?? 'Verified') : '—',
                                    align: TextAlign.center,
                                    color: hasSpending ? AppColors.creditGreen : AppColors.textMuted,
                                  ),
                                ],
                              );
                            }),

                            // Subtotal 1: Month Total
                            TableRow(
                              decoration: const BoxDecoration(color: AppColors.bafNavy),
                              children: [
                                _buildCell('', isHeader: true),
                                _buildCell('1. MONTH TOTAL', isHeader: true, isBold: true),
                                _buildCell('', isHeader: true),
                                _buildCell('CURRENT MONTH SPENDING', isHeader: true, isBold: true),
                                _buildCell(
                                  '৳ ${currencyFormat.format(summary.totalMonthlySpending)}',
                                  isHeader: true,
                                  align: TextAlign.right,
                                  isBold: true,
                                  color: AppColors.bafGold,
                                ),
                                _buildCell('LOGGED', isHeader: true, align: TextAlign.center),
                                _buildCell('AUDITED', isHeader: true, align: TextAlign.center),
                              ],
                            ),

                            // Subtotal 2: Previous Due
                            TableRow(
                              decoration: BoxDecoration(color: AppColors.bafLightBlue.withAlpha(120)),
                              children: [
                                _buildCell('', isBold: true),
                                _buildCell('2. PREVIOUS DUE', isBold: true, color: AppColors.balanceAlert),
                                _buildCell(''),
                                _buildCell('ARREARS BROUGHT FORWARD', isBold: true, color: AppColors.textSecondary),
                                _buildCell(
                                  '৳ ${currencyFormat.format(summary.preDue)}',
                                  align: TextAlign.right,
                                  isBold: true,
                                  color: AppColors.balanceAlert,
                                ),
                                _buildCell('BROUGHT FWD', align: TextAlign.center),
                                _buildCell('CONFIRMED', align: TextAlign.center),
                              ],
                            ),

                            // Subtotal 3: Grand Total
                            TableRow(
                              decoration: const BoxDecoration(color: AppColors.bafNavy),
                              children: [
                                _buildCell('', isHeader: true),
                                _buildCell('3. GRAND TOTAL', isHeader: true, isBold: true),
                                _buildCell('', isHeader: true),
                                _buildCell('GROSS LIABILITY (PRE DUE + MONTH)', isHeader: true, isBold: true),
                                _buildCell(
                                  '৳ ${currencyFormat.format(summary.grandTotal)}',
                                  isHeader: true,
                                  align: TextAlign.right,
                                  isBold: true,
                                  color: AppColors.bafGold,
                                ),
                                _buildCell('VERIFIED', isHeader: true, align: TextAlign.center),
                                _buildCell('VERIFIED', isHeader: true, align: TextAlign.center),
                              ],
                            ),

                            // Subtotal 4: Less Paid
                            TableRow(
                              decoration: BoxDecoration(color: AppColors.creditGreen.withAlpha(20)),
                              children: [
                                _buildCell(''),
                                _buildCell('4. LESS: PAID', isBold: true, color: AppColors.creditGreen),
                                _buildCell(''),
                                _buildCell('CASH RECEIVED FROM ROOM', isBold: true, color: AppColors.creditGreen),
                                _buildCell(
                                  '৳ ${currencyFormat.format(summary.paid)}',
                                  align: TextAlign.right,
                                  isBold: true,
                                  color: AppColors.creditGreen,
                                ),
                                _buildCell('COLLECTED', align: TextAlign.center),
                                _buildCell('RECEIPTED', align: TextAlign.center),
                              ],
                            ),

                            // Subtotal 5: Net Closing Due
                            TableRow(
                              decoration: const BoxDecoration(color: AppColors.bafNavy),
                              children: [
                                _buildCell('', isHeader: true),
                                _buildCell('5. NET CLOSING DUE', isHeader: true, isBold: true),
                                _buildCell('', isHeader: true),
                                _buildCell('OUTSTANDING BALANCE AT MONTH END', isHeader: true, isBold: true),
                                _buildCell(
                                  '৳ ${currencyFormat.format(summary.netDue)}',
                                  isHeader: true,
                                  align: TextAlign.right,
                                  isBold: true,
                                  color: summary.netDue > 0 ? Colors.amberAccent : Colors.greenAccent,
                                ),
                                _buildCell('FINAL', isHeader: true, align: TextAlign.center),
                                _buildCell(summary.netDue <= 0 ? 'CLEARED' : 'PENDING', isHeader: true, align: TextAlign.center),
                              ],
                            ),
                          ],
                        ),

                        // Sign-off
                        Container(
                          padding: const EdgeInsets.all(16),
                          color: AppColors.ledgerSurface,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildSignatureColumn('ROOM REPRESENTATIVE', summary.rank, state.selectedRoom),
                              _buildSignatureColumn('NCOIC (CANTEEN)', 'Sergeant (Sgt)', 'RTS BAF'),
                              _buildSignatureColumn('JCOIC (CANTEEN)', 'Warrant Officer (WO)', 'RTS BAF'),
                              _buildSignatureColumn('COUNTERSIGNED (OC)', 'Officer Commanding', 'RTS (BAF)'),
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

  Widget _buildMetaItem(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title, style: const TextStyle(fontSize: 8, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
        Text(value, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900, color: AppColors.bafNavy)),
      ],
    );
  }

  Widget _buildCell(
    String text, {
    bool isHeader = false,
    bool isBold = false,
    TextAlign align = TextAlign.left,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      child: Text(
        text,
        textAlign: align,
        style: TextStyle(
          fontSize: isHeader ? 9.5 : 10.5,
          fontWeight: (isHeader || isBold) ? FontWeight.bold : FontWeight.normal,
          color: color ?? (isHeader ? Colors.white : AppColors.textPrimary),
        ),
      ),
    );
  }

  Widget _buildSignatureColumn(String title, String rank, String unit) {
    return Column(
      children: [
        Container(width: 120, height: 1, color: AppColors.bafNavy),
        const SizedBox(height: 5),
        Text(title, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.bafNavy)),
        Text(rank, style: const TextStyle(fontSize: 8.5, color: AppColors.textSecondary)),
        Text(unit, style: const TextStyle(fontSize: 8, color: AppColors.textMuted)),
      ],
    );
  }
}
