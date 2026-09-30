import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/baf_rts_crest.dart';
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
    final isMobile = MediaQuery.of(context).size.width < 768;

    final monthsList = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];

    // Compute formal room monthly summary model
    final RoomMonthlySummary summary = state.getRoomMonthlySummary(
      state.activeEntry,
      state.selectedSquadron,
      state.selectedRoom,
      state.selectedYear,
      state.selectedMonth,
    );

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
                          'Soft Spreadsheet for ${state.selectedRoom} (${state.selectedSquadron} Sqn) ready for printing.',
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

        // Mobile Quick Summary Banner (Visible on mobile for immediate clarity)
        if (isMobile)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            color: AppColors.bafLightBlue,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${state.selectedRoom.toUpperCase()} • ${state.selectedSquadron.toUpperCase()} SQN',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.bafNavy),
                      ),
                      Text(
                        '${summary.activeDaysCount} active days (Avg ৳ ${currencyFormat.format(summary.averageDailySpending)}/day)',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  color: AppColors.bafNavy,
                  child: Text(
                    '৳ ${currencyFormat.format(summary.totalMonthlySpending)}',
                    style: const TextStyle(color: AppColors.bafGold, fontSize: 13, fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
          ),

        // The Formal Soft Spreadsheet Document (Horizontally & Vertically Scrollable)
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 8 : 20,
              vertical: isMobile ? 8 : 16,
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                constraints: BoxConstraints(minWidth: isMobile ? 720 : 850, maxWidth: 960),
                decoration: BoxDecoration(
                  color: AppColors.ledgerSurface,
                  border: Border.all(color: AppColors.bafNavy, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(20),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
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
                          BafRtsCrest(size: 52),
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
                          _buildMetaItem('DAYS IN MONTH', '${summary.days.length} DAYS'),
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

                        // Day Rows (All Days of Selected Month)
                        ...summary.days.map((record) {
                          final isEven = record.dayNumber % 2 == 0;
                          final hasSpending = record.amount > 0;

                          return TableRow(
                            decoration: BoxDecoration(
                              color: hasSpending
                                  ? (isEven ? AppColors.bafLightBlue.withAlpha(50) : AppColors.bafLightBlue.withAlpha(25))
                                  : (isEven ? AppColors.ledgerSurface : AppColors.ledgerStripe),
                            ),
                            children: [
                              _buildCell('D-${record.dayNumber.toString().padLeft(2, '0')}', align: TextAlign.center, isBold: true),
                              _buildCell(dateDisplayFormat.format(record.date)),
                              _buildCell(dayNameFormat.format(record.date)),
                              _buildCell(
                                record.itemsDescription ?? (hasSpending ? 'Room items collected' : '—'),
                                isMuted: !hasSpending,
                              ),
                              _buildCell(
                                hasSpending ? currencyFormat.format(record.amount) : '0.00',
                                align: TextAlign.right,
                                isBold: hasSpending,
                                color: hasSpending ? AppColors.debitRed : AppColors.textMuted,
                              ),
                              _buildCell(
                                hasSpending ? record.recordedBy : '—',
                                align: TextAlign.center,
                                isBold: hasSpending,
                              ),
                              _buildCell(
                                hasSpending ? (record.representativeName ?? 'Checked') : '—',
                                align: TextAlign.center,
                                isMuted: !hasSpending,
                              ),
                            ],
                          );
                        }),

                        // Month End Sum Total Row
                        TableRow(
                          decoration: const BoxDecoration(color: AppColors.bafNavy),
                          children: [
                            _buildCell('', isHeader: true),
                            _buildCell('MONTH TOTAL', isHeader: true, isBold: true),
                            _buildCell('', isHeader: true),
                            _buildCell(
                              'TOTAL BILLED TO ${state.selectedRoom.toUpperCase()} (${state.selectedSquadron.toUpperCase()} SQN)',
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
                            _buildCell('VERIFIED', isHeader: true, align: TextAlign.center),
                            _buildCell('CLEARED', isHeader: true, align: TextAlign.center),
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
                                    'OFFICIAL RECONCILIATION CERTIFICATE: The above expenditures represent the daily documented canteen consumption of Entry ${state.activeEntry}, ${state.selectedSquadron} Squadron, ${state.selectedRoom} for ${monthsList[state.selectedMonth - 1]} ${state.selectedYear}. Grand Sum Total: Tk ${currencyFormat.format(summary.totalMonthlySpending)}.',
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
                              _buildSignatureColumn('ROOM REPRESENTATIVE', 'Senior Recruit / Chest Rep', state.selectedRoom),
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
  }

  static Widget _buildMetaItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.textMuted, letterSpacing: 0.5),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: AppColors.bafNavy),
        ),
      ],
    );
  }

  static Widget _buildCell(
    String text, {
    bool isHeader = false,
    bool isBold = false,
    bool isMuted = false,
    TextAlign align = TextAlign.left,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 6),
      child: Text(
        text,
        textAlign: align,
        style: TextStyle(
          fontSize: isHeader ? 10 : 10.5,
          fontWeight: (isHeader || isBold) ? FontWeight.bold : FontWeight.normal,
          color: isHeader
              ? (color ?? Colors.white)
              : (color ?? (isMuted ? AppColors.textMuted : AppColors.textPrimary)),
        ),
      ),
    );
  }

  static Widget _buildSignatureColumn(String role, String rank, String unit) {
    return Container(
      width: 170,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(border: Border.all(color: AppColors.ledgerBorderLight)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(role, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.bafNavy)),
          const SizedBox(height: 24),
          Container(height: 1, color: AppColors.ledgerBorder),
          const SizedBox(height: 3),
          Text(rank, style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w600)),
          Text(unit, style: const TextStyle(fontSize: 9, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}
