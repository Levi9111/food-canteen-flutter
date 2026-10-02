import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/baf_rts_crest.dart';
import '../../../../core/widgets/tactical_card.dart';
import '../../constants/canteen_constants.dart';
import '../../models/room_monthly_summary.dart';
import '../../providers/canteen_register_provider.dart';

class RoomSoftSpreadsheetView extends ConsumerWidget {
  const RoomSoftSpreadsheetView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            // Top Toolbar: Room, Squadron, Month Selectors & Print Button
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
                    // Squadron Selector
                    const Text(
                      'SQN:',
                      style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.ledgerSurface,
                        border: Border.all(color: AppColors.ledgerBorder),
                      ),
                      child: DropdownButton<String>(
                        value: state.selectedSquadron,
                        isDense: true,
                        underline: const SizedBox(),
                        items: CanteenConstants.squadrons.map((sqn) {
                          return DropdownMenuItem(
                            value: sqn,
                            child: Text('$sqn Sqn', style: const TextStyle(fontSize: 12)),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) notifier.setSelectedSquadron(val);
                        },
                      ),
                    ),

                    const SizedBox(width: 10),

                    // Room Selector
                    const Text(
                      'ROOM:',
                      style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.ledgerSurface,
                        border: Border.all(color: AppColors.ledgerBorder),
                      ),
                      child: DropdownButton<String>(
                        value: state.selectedRoom,
                        isDense: true,
                        underline: const SizedBox(),
                        items: CanteenConstants.rooms.map((r) {
                          return DropdownMenuItem(
                            value: r,
                            child: Text(r, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) notifier.setSelectedRoom(val);
                        },
                      ),
                    ),

                    const SizedBox(width: 10),

                    // Month & Year Selector
                    const Text(
                      'PERIOD:',
                      style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
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

                    const SizedBox(width: 16),

                    // Print / Soft Copy Button
                    ElevatedButton.icon(
                      icon: const Icon(Icons.print_outlined, size: 15),
                      label: const Text('PRINT SPREADSHEET'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.bafGold,
                        foregroundColor: AppColors.bafNavy,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Official soft copy for ${state.selectedRoom} (${state.selectedSquadron} Sqn) generated for official record.',
                            ),
                            backgroundColor: AppColors.bafDeepBlue,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Tactical Metric Strip (PreDue, Month Spend, Paid, Net Due)
            Container(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 10 : 16, vertical: 6),
              color: AppColors.bafNavy.withAlpha(8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    SizedBox(
                      width: 175,
                      child: TacticalMetricBox(
                        label: 'PREVIOUS DUE',
                        value: '৳ ${currencyFormat.format(summary.preDue)}',
                        subtitle: 'Last month balance',
                        valueColor: AppColors.balanceAlert,
                        accentColor: AppColors.balanceAlert,
                        icon: Icons.history,
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 175,
                      child: TacticalMetricBox(
                        label: 'MONTH SPENDING',
                        value: '৳ ${currencyFormat.format(summary.totalMonthlySpending)}',
                        subtitle: '${summary.activeDaysCount} canteen visits',
                        valueColor: AppColors.debitRed,
                        accentColor: AppColors.debitRed,
                        icon: Icons.receipt_long,
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 175,
                      child: TacticalMetricBox(
                        label: 'TOTAL PAID',
                        value: '৳ ${currencyFormat.format(summary.paid)}',
                        subtitle: 'Received from room',
                        valueColor: AppColors.creditGreen,
                        accentColor: AppColors.creditGreen,
                        icon: Icons.payments,
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 185,
                      child: TacticalMetricBox(
                        label: 'CLOSING NET DUE',
                        value: '৳ ${currencyFormat.format(summary.netDue)}',
                        subtitle: 'Payable balance',
                        valueColor: AppColors.bafNavy,
                        accentColor: AppColors.bafGold,
                        icon: Icons.account_balance_wallet,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // The Formal Soft Spreadsheet Document
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 8 : 20,
                  vertical: isMobile ? 8 : 16,
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Container(
                    constraints: BoxConstraints(minWidth: isMobile ? 740 : 880, maxWidth: 980),
                    decoration: BoxDecoration(
                      color: AppColors.ledgerSurface,
                      border: Border.all(color: AppColors.bafNavy, width: 2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Document Official Masthead
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: const BoxDecoration(
                            color: AppColors.bafNavy,
                            border: Border(bottom: BorderSide(color: AppColors.bafGold, width: 2.5)),
                          ),
                          child: Row(
                            children: [
                              const BafRtsCrest(size: 54),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "PEOPLE'S REPUBLIC OF BANGLADESH • BANGLADESH AIR FORCE",
                                      style: TextStyle(
                                        color: AppColors.bafGold,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'RECRUITS TRAINING SCHOOL (RTS)',
                                      style: AppTextStyles.titleLarge(Colors.white),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'FOOD CANTEEN • MONTHLY ROOM EXPENDITURE SPREADSHEET (ENTRY ${state.activeEntry})',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.6,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Sheet Metadata Strip
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          color: AppColors.bafLightBlue,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildMetaItem('SQUADRON', '${state.selectedSquadron.toUpperCase()} SQN'),
                              _buildMetaItem('ASSIGNED ROOM', state.selectedRoom.toUpperCase()),
                              _buildMetaItem('ACCOUNTING MONTH', '${monthsList[state.selectedMonth - 1].toUpperCase()} ${state.selectedYear}'),
                              _buildMetaItem('RECRUIT ENTRY BATCH', 'ENTRY ${state.activeEntry}'),
                              _buildMetaItem('DESIGNATION / RK', summary.rank.toUpperCase()),
                            ],
                          ),
                        ),

                        // Official Canteen Register Spreadsheet Table
                        Table(
                          border: TableBorder.all(color: AppColors.ledgerBorder, width: 1),
                          columnWidths: const {
                            0: FixedColumnWidth(55),  // Day #
                            1: FixedColumnWidth(110), // Date
                            2: FixedColumnWidth(95),  // Day Name
                            3: FlexColumnWidth(2.5),  // Items Picked
                            4: FixedColumnWidth(110), // Price in Tk
                            5: FixedColumnWidth(75),  // Logged By
                            6: FixedColumnWidth(110), // Rep Sign
                          },
                          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                          children: [
                            // Header Row
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

                            // Day Rows
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
                                    record.itemsDescription ?? (hasSpending ? 'Assorted canteen snacks' : '—'),
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

                            // Accounting Settlement Block (Reflecting Draft PDF)
                            // 1. Month Spending Subtotal
                            TableRow(
                              decoration: const BoxDecoration(color: AppColors.bafNavy),
                              children: [
                                _buildCell('', isHeader: true),
                                _buildCell('1. MONTH TOTAL', isHeader: true, isBold: true),
                                _buildCell('', isHeader: true),
                                _buildCell(
                                  'CURRENT MONTH SPENDING FOR ${state.selectedRoom.toUpperCase()}',
                                  isHeader: true,
                                  isBold: true,
                                ),
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

                            // 2. Previous Due
                            TableRow(
                              decoration: BoxDecoration(color: AppColors.bafLightBlue.withAlpha(120)),
                              children: [
                                _buildCell('', isBold: true),
                                _buildCell('2. PREVIOUS DUE', isBold: true, color: AppColors.balanceAlert),
                                _buildCell(''),
                                _buildCell('ARREARS CARRIED OVER FROM PREVIOUS AUDIT', isBold: true, color: AppColors.textSecondary),
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

                            // 3. Grand Total Liability
                            TableRow(
                              decoration: const BoxDecoration(color: AppColors.bafNavy),
                              children: [
                                _buildCell('', isHeader: true),
                                _buildCell('3. GRAND TOTAL', isHeader: true, isBold: true),
                                _buildCell('', isHeader: true),
                                _buildCell('GROSS PAYABLE (PRE DUE + CURRENT MONTH)', isHeader: true, isBold: true),
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

                            // 4. Less: Amount Paid
                            TableRow(
                              decoration: BoxDecoration(color: AppColors.creditGreen.withAlpha(20)),
                              children: [
                                _buildCell(''),
                                _buildCell('4. LESS: PAID', isBold: true, color: AppColors.creditGreen),
                                _buildCell(''),
                                _buildCell('AMOUNT SETTLED / CASH COLLECTED FROM ROOM', isBold: true, color: AppColors.creditGreen),
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

                            // 5. Net Closing Due
                            TableRow(
                              decoration: const BoxDecoration(color: AppColors.bafNavy),
                              children: [
                                _buildCell('', isHeader: true),
                                _buildCell('5. NET CLOSING DUE', isHeader: true, isBold: true),
                                _buildCell('', isHeader: true),
                                _buildCell('NET OUTSTANDING BALANCE AS OF MONTH END', isHeader: true, isBold: true),
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

                        // Spreadsheet Footer & Official Sign-off Certification Blocks
                        Container(
                          padding: const EdgeInsets.all(16),
                          color: AppColors.ledgerSurface,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Certification Note
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.bafLightBlue.withAlpha(80),
                                  border: Border.all(color: AppColors.bafGold),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.verified, color: AppColors.bafDeepBlue, size: 20),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        'OFFICIAL RECONCILIATION CERTIFICATE: The above expenditures represent the daily documented canteen consumption of Entry ${state.activeEntry}, ${state.selectedSquadron} Squadron, ${state.selectedRoom} for ${monthsList[state.selectedMonth - 1]} ${state.selectedYear}. Grand Sum Total: Tk ${currencyFormat.format(summary.grandTotal)}. Net Due: Tk ${currencyFormat.format(summary.netDue)}.',
                                        style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, height: 1.3),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 28),

                              // Military Sign-off Blocks (Room Rep, NCOIC, JCOIC, OC)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildSignatureColumn('ROOM REPRESENTATIVE', summary.rank, state.selectedRoom),
                                  _buildSignatureColumn('NCOIC (CANTEEN)', 'Sergeant (Sgt)', 'Recruits Training School'),
                                  _buildSignatureColumn('JCOIC (CANTEEN)', 'Warrant Officer (WO)', 'Recruits Training School'),
                                  _buildSignatureColumn('COUNTERSIGNED (OC)', 'Officer Commanding', 'Recruits Training School (RTS)'),
                                ],
                              ),

                              const SizedBox(height: 10),
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

  Widget _buildMetaItem(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 8.5, color: AppColors.textSecondary, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 1),
        Text(
          value,
          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900, color: AppColors.bafNavy),
        ),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      child: Text(
        text,
        textAlign: align,
        style: TextStyle(
          fontSize: isHeader ? 10 : 11,
          fontWeight: (isHeader || isBold) ? FontWeight.bold : FontWeight.normal,
          color: color ?? (isHeader ? Colors.white : AppColors.textPrimary),
          letterSpacing: isHeader ? 0.5 : 0.0,
        ),
      ),
    );
  }

  Widget _buildSignatureColumn(String title, String rank, String unit) {
    return Column(
      children: [
        Container(
          width: 140,
          height: 1,
          color: AppColors.bafNavy,
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.bafNavy),
        ),
        Text(
          rank,
          style: const TextStyle(fontSize: 9, color: AppColors.textSecondary),
        ),
        Text(
          unit,
          style: const TextStyle(fontSize: 8.5, color: AppColors.textMuted),
        ),
      ],
    );
  }
}
