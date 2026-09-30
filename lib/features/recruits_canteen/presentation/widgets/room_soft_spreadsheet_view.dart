import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/baf_rts_crest.dart';
import '../../constants/canteen_constants.dart';
import '../../providers/canteen_register_provider.dart';

class RoomSoftSpreadsheetView extends ConsumerWidget {
  const RoomSoftSpreadsheetView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(canteenRegisterProvider);
    final notifier = ref.read(canteenRegisterProvider.notifier);
    final currencyFormat = NumberFormat('#,##0.00', 'en_US');
    final dayNameFormat = DateFormat('EEEE');
    final dateDisplayFormat = DateFormat('dd MMM yyyy');

    final monthsList = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];

    final summary = state.getRoomMonthlySummary(
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
              ),
              const SizedBox(width: 6),
              SizedBox(
                width: 140,
                child: DropdownButtonFormField<String>(
                  isDense: true,
                  isExpanded: true,
                  initialValue: state.selectedSquadron,
                  decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8)),
                  items: CanteenConstants.squadrons.map((sqn) {
                    return DropdownMenuItem(
                      value: sqn,
                      child: Text('$sqn Sqn', style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) notifier.setSelectedSquadron(val);
                  },
                ),
              ),

              const SizedBox(width: 12),

              // Room Selector
              const Text(
                'ROOM:',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
              ),
              const SizedBox(width: 6),
              SizedBox(
                width: 120,
                child: DropdownButtonFormField<String>(
                  isDense: true,
                  isExpanded: true,
                  initialValue: state.selectedRoom,
                  decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8)),
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

              const SizedBox(width: 12),

              // Month & Year Selector
              const Text(
                'PERIOD:',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
              ),
              const SizedBox(width: 6),
              SizedBox(
                width: 130,
                child: DropdownButtonFormField<int>(
                  isDense: true,
                  initialValue: state.selectedMonth,
                  decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8)),
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
              SizedBox(
                width: 85,
                child: DropdownButtonFormField<int>(
                  isDense: true,
                  initialValue: state.selectedYear,
                  decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8)),
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

              const SizedBox(width: 24),

              // Print / Soft Copy Button
              ElevatedButton.icon(
                icon: const Icon(Icons.print_outlined, size: 16),
                label: const Text('PRINT SPREADSHEET'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.bafGold,
                  foregroundColor: AppColors.bafNavy,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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

        // The Formal Soft Spreadsheet Document (Scrollable & Printable Layout)
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 960),
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
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: AppColors.bafNavy,
                        border: Border(bottom: BorderSide(color: AppColors.bafGold, width: 2.5)),
                      ),
                      child: Row(
                        children: [
                          const BafRtsCrest(size: 60),
                          const SizedBox(width: 18),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "PEOPLE'S REPUBLIC OF BANGLADESH • BANGLADESH AIR FORCE",
                                  style: TextStyle(
                                    color: AppColors.bafGold,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'RECRUITS TRAINING SCHOOL (RTS)',
                                  style: AppTextStyles.titleLarge(Colors.white),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'FOOD CANTEEN — MONTHLY ROOM EXPENDITURE SPREADSHEET',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.bafDeepBlue,
                              border: Border.all(color: AppColors.bafGold),
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  'RECRUIT BATCH',
                                  style: TextStyle(color: AppColors.bafGold, fontSize: 9, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'ENTRY ${state.activeEntry}',
                                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Specific Room & Period Information Box
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      color: AppColors.bafLightBlue,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildMetaItem('SQUADRON', '${state.selectedSquadron.toUpperCase()} SQN'),
                          _buildMetaItem('TARGET ROOM', state.selectedRoom.toUpperCase()),
                          _buildMetaItem('MONTH & YEAR', '${monthsList[state.selectedMonth - 1].toUpperCase()} ${state.selectedYear}'),
                          _buildMetaItem('DAYS CONSUMED', '${summary.activeDaysCount} of ${summary.days.length} Days'),
                          _buildMetaItem('MANAGERS IN-CHARGE', 'NCOIC / JCOIC'),
                        ],
                      ),
                    ),

                    // The 31 Days Itemized Table
                    Table(
                      border: TableBorder.all(color: AppColors.ledgerBorder, width: 1),
                      columnWidths: const {
                        0: FlexColumnWidth(1.2),  // Day #
                        1: FlexColumnWidth(2.0),  // Date
                        2: FlexColumnWidth(2.0),  // Day of Week
                        3: FlexColumnWidth(4.5),  // Items / Particulars
                        4: FlexColumnWidth(2.4),  // Price (Tk)
                        5: FlexColumnWidth(1.8),  // Logged By
                        6: FlexColumnWidth(2.0),  // Rep Signature
                      },
                      children: [
                        // Header Row
                        TableRow(
                          decoration: const BoxDecoration(color: AppColors.bafNavy),
                          children: [
                            _buildCell('DAY', isHeader: true, align: TextAlign.center),
                            _buildCell('CALENDAR DATE', isHeader: true),
                            _buildCell('WEEKDAY', isHeader: true),
                            _buildCell('CANTEEN PARTICULARS / ITEMS PICKED', isHeader: true),
                            _buildCell('PRICE VALUE (TK)', isHeader: true, align: TextAlign.right),
                            _buildCell('LOGGED BY', isHeader: true, align: TextAlign.center),
                            _buildCell('REP INITIAL', isHeader: true, align: TextAlign.center),
                          ],
                        ),

                        // Day Rows
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

                        // Month End Sum Total Row (Rule 6: at the end of the month the total price sum total will be shown)
                        TableRow(
                          decoration: const BoxDecoration(color: AppColors.bafNavy),
                          children: [
                            _buildCell('', isHeader: true),
                            _buildCell('MONTH SUM TOTAL', isHeader: true, isBold: true),
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

                    // Official Certification Box & Signatures
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.bafGold, width: 1.2),
                              color: AppColors.bafLightBlue.withAlpha(40),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.verified_outlined, color: AppColors.bafNavy, size: 22),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'OFFICIAL RECONCILIATION CERTIFICATE: The above expenditures represent the daily documented canteen consumption of Entry ${state.activeEntry}, ${state.selectedSquadron} Squadron, ${state.selectedRoom} for ${monthsList[state.selectedMonth - 1]} ${state.selectedYear}. Grand Sum Total: Tk ${currencyFormat.format(summary.totalMonthlySpending)}.',
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, height: 1.4),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 36),

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

                          const SizedBox(height: 12),
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
          style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: AppColors.textMuted, letterSpacing: 0.5),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.bafNavy),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      child: Text(
        text,
        textAlign: align,
        style: TextStyle(
          fontSize: isHeader ? 10.5 : 11,
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
      width: 210,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(border: Border.all(color: AppColors.ledgerBorderLight)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(role, style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: AppColors.bafNavy)),
          const SizedBox(height: 28), // Physical Signature Line
          Container(height: 1, color: AppColors.ledgerBorder),
          const SizedBox(height: 4),
          Text(rank, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
          Text(unit, style: const TextStyle(fontSize: 9.5, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}
