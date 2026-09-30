import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/animations/smooth_transitions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../models/recruit_account.dart';
import '../../providers/ledger_provider.dart';
import 'voucher_entry_modal.dart';

class RecruitsLedgerView extends ConsumerWidget {
  const RecruitsLedgerView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(recruitsLedgerProvider);
    final recruitsNotifier = ref.read(recruitsLedgerProvider.notifier);
    final numberFormat = NumberFormat('#,##0.00', 'en_US');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Filter & Search Command Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            color: AppColors.ledgerSurface,
            border: Border(
              bottom: BorderSide(color: AppColors.ledgerBorderLight),
            ),
          ),
          child: Row(
            children: [
              // Intake Selector
              const Text(
                'INTAKE:',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 140,
                child: DropdownButtonFormField<String>(
                  isDense: true,
                  isExpanded: true,
                  initialValue: state.selectedIntake,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  ),
                  items: state.availableIntakes.map((intake) {
                    return DropdownMenuItem(
                      value: intake,
                      child: Text(intake, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) recruitsNotifier.setIntake(val);
                  },
                ),
              ),
              const SizedBox(width: 16),

              // Squadron Selector
              const Text(
                'SQUADRON:',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 220,
                child: DropdownButtonFormField<String>(
                  isDense: true,
                  isExpanded: true,
                  initialValue: state.selectedSquadron,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  ),
                  items: state.availableSquadrons.map((sq) {
                    return DropdownMenuItem(
                      value: sq,
                      child: Text(sq, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) recruitsNotifier.setSquadron(val);
                  },
                ),
              ),
              const SizedBox(width: 16),

              // Search by Recruit No or Name
              Expanded(
                child: TextField(
                  onChanged: recruitsNotifier.setSearchQuery,
                  decoration: const InputDecoration(
                    hintText: 'Search by Recruit No (RCT-...), Name, or Flight...',
                    prefixIcon: Icon(Icons.search, size: 18),
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Summary Calculation Metrics Ribbon
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: AppColors.bafLightBlue,
          child: Row(
            children: [
              SmoothAnimatedMetricCard(
                title: 'RECRUITS IN VIEW',
                value: state.filteredRecruits.length.toDouble(),
                prefix: '',
                textColor: AppColors.bafNavy,
              ),
              const SizedBox(width: 12),
              SmoothAnimatedMetricCard(
                title: 'TOTAL CANTEEN CHARGES',
                value: state.totalDebits,
                textColor: AppColors.debitRed,
              ),
              const SizedBox(width: 12),
              SmoothAnimatedMetricCard(
                title: 'TOTAL RECOVERIES (PAID)',
                value: state.totalCredits,
                textColor: AppColors.creditGreen,
              ),
              const SizedBox(width: 12),
              SmoothAnimatedMetricCard(
                title: 'OUTSTANDING DUES / ARREARS',
                value: state.totalOutstandingDues,
                textColor: state.totalOutstandingDues > 0
                    ? AppColors.debitRed
                    : AppColors.cleared,
                highlight: true,
              ),
            ],
          ),
        ),

        // High Density Data Table
        Expanded(
          child: state.filteredRecruits.isEmpty
              ? const Center(
                  child: Text(
                    'No recruit accounts found matching current intake and squadron filters.',
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                )
              : SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: MediaQuery.of(context).size.width,
                      ),
                      child: DataTable(
                        headingRowHeight: 40,
                        dataRowMinHeight: 44,
                        dataRowMaxHeight: 48,
                        columns: const [
                          DataColumn(label: Text('#')),
                          DataColumn(label: Text('RECRUIT NO')),
                          DataColumn(label: Text('NAME')),
                          DataColumn(label: Text('INTAKE')),
                          DataColumn(label: Text('SQUADRON')),
                          DataColumn(label: Text('FLIGHT')),
                          DataColumn(label: Text('OPENING (TK)')),
                          DataColumn(label: Text('CHARGES / DEBIT (TK)')),
                          DataColumn(label: Text('RECOVERED (TK)')),
                          DataColumn(label: Text('CLOSING DUES (TK)')),
                          DataColumn(label: Text('STATUS')),
                          DataColumn(label: Text('ACTIONS')),
                        ],
                        rows: List.generate(state.filteredRecruits.length, (idx) {
                          final recruit = state.filteredRecruits[idx];
                          final isEven = idx % 2 == 0;

                          return DataRow(
                            color: WidgetStateProperty.all(
                              isEven ? AppColors.ledgerSurface : AppColors.ledgerStripe,
                            ),
                            cells: [
                              DataCell(Text('${idx + 1}', style: const TextStyle(fontSize: 12))),
                              DataCell(
                                Text(
                                  recruit.recruitNo,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: AppColors.bafDeepBlue,
                                  ),
                                ),
                              ),
                              DataCell(Text(recruit.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
                              DataCell(Text(recruit.intake, style: const TextStyle(fontSize: 12))),
                              DataCell(Text(recruit.squadron, style: const TextStyle(fontSize: 12))),
                              DataCell(Text(recruit.flight, style: const TextStyle(fontSize: 12))),
                              DataCell(Text(numberFormat.format(recruit.openingBalance), style: const TextStyle(fontSize: 12))),
                              DataCell(
                                Text(
                                  numberFormat.format(recruit.totalDebits),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.debitRed,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  numberFormat.format(recruit.totalCredits),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.creditGreen,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  numberFormat.format(recruit.closingBalance),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: recruit.closingBalance > 0
                                        ? AppColors.debitRed
                                        : AppColors.cleared,
                                  ),
                                ),
                              ),
                              DataCell(_buildStatusBadge(recruit)),
                              DataCell(
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.receipt_long, size: 16),
                                      tooltip: 'View Statement & History',
                                      onPressed: () => _showRecruitDetails(context, recruit),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.add_circle_outline, size: 16),
                                      tooltip: 'Add Voucher',
                                      color: AppColors.bafDeepBlue,
                                      onPressed: () {
                                        showSmoothMilitaryDialog(
                                          context: context,
                                          child: VoucherEntryModal(preselectedRecruitId: recruit.id),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }),
                      ),
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  static Widget _buildMetricCard({
    required String title,
    required String value,
    required Color textColor,
    bool highlight = false,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.ledgerSurface,
          border: Border.all(
            color: highlight ? textColor : AppColors.ledgerBorderLight,
            width: highlight ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: AppColors.textMuted,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildStatusBadge(RecruitAccount recruit) {
    if (recruit.isSettled) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.cleared.withAlpha(20),
          border: Border.all(color: AppColors.cleared),
        ),
        child: const Text(
          'CLEARED',
          style: TextStyle(
            color: AppColors.cleared,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.debitRed.withAlpha(20),
        border: Border.all(color: AppColors.debitRed),
      ),
      child: const Text(
        'DUE ARREARS',
        style: TextStyle(
          color: AppColors.debitRed,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  static void _showRecruitDetails(BuildContext context, RecruitAccount recruit) {
    final numberFormat = NumberFormat('#,##0.00', 'en_US');
    final dateFormat = DateFormat('dd MMM yyyy');

    showSmoothMilitaryDialog(
      context: context,
      child: Dialog(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        child: Container(
          width: 750,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.ledgerSurface,
              border: Border.all(color: AppColors.bafNavy, width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${recruit.recruitNo} — ${recruit.name}',
                          style: AppTextStyles.titleLarge(AppColors.bafNavy),
                        ),
                        Text(
                          '${recruit.squadron} • ${recruit.flight} • ${recruit.intake}',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const Divider(height: 24),
                // Balance Summary Row
                Row(
                  children: [
                    _buildMetricCard(
                      title: 'OPENING BALANCE',
                      value: '৳ ${numberFormat.format(recruit.openingBalance)}',
                      textColor: AppColors.textPrimary,
                    ),
                    const SizedBox(width: 8),
                    _buildMetricCard(
                      title: 'TOTAL CHARGES',
                      value: '৳ ${numberFormat.format(recruit.totalDebits)}',
                      textColor: AppColors.debitRed,
                    ),
                    const SizedBox(width: 8),
                    _buildMetricCard(
                      title: 'TOTAL RECOVERY',
                      value: '৳ ${numberFormat.format(recruit.totalCredits)}',
                      textColor: AppColors.creditGreen,
                    ),
                    const SizedBox(width: 8),
                    _buildMetricCard(
                      title: 'NET DUE BALANCE',
                      value: '৳ ${numberFormat.format(recruit.closingBalance)}',
                      textColor: recruit.closingBalance > 0 ? AppColors.debitRed : AppColors.cleared,
                      highlight: true,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'ITEMIZED VOUCHER AUDIT TRAIL',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 220,
                  child: recruit.transactions.isEmpty
                      ? const Center(
                          child: Text('No individual vouchers recorded for this recruit yet.'),
                        )
                      : ListView.separated(
                          itemCount: recruit.transactions.length,
                          separatorBuilder: (context, index) => const Divider(height: 1),
                          itemBuilder: (_, i) {
                            final tx = recruit.transactions[i];
                            return ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              title: Row(
                                children: [
                                  Text(
                                    tx.voucherNo,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                  const SizedBox(width: 10),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                    color: AppColors.bafLightBlue,
                                    child: Text(
                                      tx.category,
                                      style: const TextStyle(fontSize: 10, color: AppColors.bafNavy),
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    dateFormat.format(tx.date),
                                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                  ),
                                ],
                              ),
                              subtitle: Text(
                                '${tx.description} (Auth: ${tx.authorizedBy})',
                                style: const TextStyle(fontSize: 11),
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    tx.debit > 0
                                        ? '+ ৳ ${numberFormat.format(tx.debit)}'
                                        : '- ৳ ${numberFormat.format(tx.credit)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: tx.debit > 0 ? AppColors.debitRed : AppColors.creditGreen,
                                    ),
                                  ),
                                  Text(
                                    'Run Bal: ৳ ${numberFormat.format(tx.runningBalance)}',
                                    style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      );
  }
}
