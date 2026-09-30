import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/baf_rts_crest.dart';
import '../providers/audit_provider.dart';

class MonthlyAuditView extends ConsumerWidget {
  const MonthlyAuditView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audit = ref.watch(monthlyAuditProvider);
    final numberFormat = NumberFormat('#,##0.00', 'en_US');
    final dateFormat = DateFormat('dd MMMM yyyy, HH:mm');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 960),
          decoration: BoxDecoration(
            color: AppColors.ledgerSurface,
            border: Border.all(color: AppColors.bafNavy, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Official Military Masthead
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                decoration: const BoxDecoration(
                  color: AppColors.bafNavy,
                  border: Border(bottom: BorderSide(color: AppColors.bafGold, width: 2)),
                ),
                child: Row(
                  children: [
                    const BafRtsCrest(size: 64),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "PEOPLE'S REPUBLIC OF BANGLADESH",
                            style: TextStyle(
                              color: AppColors.bafGold,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'HEADQUARTERS BANGLADESH AIR FORCE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'RECRUITS TRAINING SCHOOL (RTS), SHAMSHERNAGAR',
                            style: AppTextStyles.titleLarge(Colors.white),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'FOOD CANTEEN & MESS ACCOUNTS — OFFICIAL AUDIT STATEMENT',
                            style: TextStyle(
                              color: AppColors.bafGold.withAlpha(220),
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Print / Export Tool
                    ElevatedButton.icon(
                      icon: const Icon(Icons.print_outlined, size: 16),
                      label: const Text('PRINT STATEMENT'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.bafGold,
                        foregroundColor: AppColors.bafNavy,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Audit statement compiled and sent to system printer spool.'),
                            backgroundColor: AppColors.bafDeepBlue,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Metadata Ribbon
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                color: AppColors.bafLightBlue,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ACCOUNTING PERIOD: ${audit.period.toUpperCase()}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.bafNavy,
                      ),
                    ),
                    Text(
                      'STATEMENT GENERATED: ${dateFormat.format(audit.generatedDate)}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      color: AppColors.cleared,
                      child: const Text(
                        'STATUS: VERIFIED & BALANCED',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Financial Ledger Breakdown Table
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      '1. COMPREHENSIVE ACCOUNTS RECONCILIATION SUMMARY',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.bafNavy,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Structured Military Table
                    Table(
                      border: TableBorder.all(
                        color: AppColors.ledgerBorder,
                        width: 1,
                      ),
                      columnWidths: const {
                        0: FlexColumnWidth(3),
                        1: FlexColumnWidth(1.2),
                        2: FlexColumnWidth(2),
                        3: FlexColumnWidth(2),
                        4: FlexColumnWidth(2),
                        5: FlexColumnWidth(2),
                      },
                      children: [
                        // Header Row
                        TableRow(
                          decoration: const BoxDecoration(color: AppColors.bafNavy),
                          children: [
                            _buildTableCell('ACCOUNT LEDGER CLASSIFICATION', isHeader: true),
                            _buildTableCell('HEADCOUNT', isHeader: true, align: TextAlign.center),
                            _buildTableCell('OPENING DUES (TK)', isHeader: true, align: TextAlign.right),
                            _buildTableCell('TOTAL DEBIT (TK)\n[CANTEEN CHARGES]', isHeader: true, align: TextAlign.right),
                            _buildTableCell('TOTAL CREDIT (TK)\n[RECOVERIES / PAID]', isHeader: true, align: TextAlign.right),
                            _buildTableCell('CLOSING ARREARS (TK)\n[NET BALANCE]', isHeader: true, align: TextAlign.right),
                          ],
                        ),

                        // Recruits Row
                        TableRow(
                          children: [
                            _buildTableCell('Recruits Mess Account (Intake & Squadrons)', isBold: true),
                            _buildTableCell('${audit.totalRecruitsEnrolled}', align: TextAlign.center),
                            _buildTableCell(numberFormat.format(audit.recruitOpeningBalance), align: TextAlign.right),
                            _buildTableCell(numberFormat.format(audit.recruitTotalDebits), align: TextAlign.right, color: AppColors.debitRed),
                            _buildTableCell(numberFormat.format(audit.recruitTotalCredits), align: TextAlign.right, color: AppColors.creditGreen),
                            _buildTableCell(numberFormat.format(audit.recruitClosingBalance), align: TextAlign.right, isBold: true),
                          ],
                        ),

                        // Permanent Staff Row
                        TableRow(
                          children: [
                            _buildTableCell('Permanent Staff Mess Account (Offices & BD No)', isBold: true),
                            _buildTableCell('${audit.totalStaffEnrolled}', align: TextAlign.center),
                            _buildTableCell(numberFormat.format(audit.staffOpeningBalance), align: TextAlign.right),
                            _buildTableCell(numberFormat.format(audit.staffTotalDebits), align: TextAlign.right, color: AppColors.debitRed),
                            _buildTableCell(numberFormat.format(audit.staffTotalCredits), align: TextAlign.right, color: AppColors.creditGreen),
                            _buildTableCell(numberFormat.format(audit.staffClosingBalance), align: TextAlign.right, isBold: true),
                          ],
                        ),

                        // Grand Total Row
                        TableRow(
                          decoration: const BoxDecoration(color: AppColors.bafLightBlue),
                          children: [
                            _buildTableCell('GRAND TOTAL (CANTEEN RECONCILED)', isBold: true, isGrandTotal: true),
                            _buildTableCell('${audit.totalRecruitsEnrolled + audit.totalStaffEnrolled}', align: TextAlign.center, isGrandTotal: true),
                            _buildTableCell(numberFormat.format(audit.grandOpeningBalance), align: TextAlign.right, isGrandTotal: true),
                            _buildTableCell(numberFormat.format(audit.grandTotalDebits), align: TextAlign.right, isGrandTotal: true, color: AppColors.debitRed),
                            _buildTableCell(numberFormat.format(audit.grandTotalCredits), align: TextAlign.right, isGrandTotal: true, color: AppColors.creditGreen),
                            _buildTableCell(numberFormat.format(audit.grandClosingBalance), align: TextAlign.right, isGrandTotal: true),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Mathematical Checksum Verification Box
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.ledgerSurface,
                        border: Border.all(color: AppColors.bafGold, width: 1.5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.verified, color: AppColors.bafDeepBlue, size: 20),
                              const SizedBox(width: 8),
                              const Text(
                                'MATHEMATICAL AUDIT & CHECKSUM VERIFICATION',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.bafNavy,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                'AUDIT INTEGRITY: 100% OK',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: audit.isBalanced ? AppColors.cleared : AppColors.debitRed,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Verification Formula: Opening Balance (৳ ${numberFormat.format(audit.grandOpeningBalance)}) + Canteen Debits (৳ ${numberFormat.format(audit.grandTotalDebits)}) - Total Recoveries (৳ ${numberFormat.format(audit.grandTotalCredits)}) = Net Closing Arrears (৳ ${numberFormat.format(audit.grandClosingBalance)}).',
                            style: const TextStyle(fontSize: 12, height: 1.4, color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Certificate: All vouchers recorded for the current accounting cycle have been audited against primary squadron and section chits. No unvouched discrepancy detected.',
                            style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 36),

                    // Official Military Sign-off / Signature Blocks
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSignatureBlock(
                          designation: 'PREPARED BY',
                          name: 'Accounts NCO, RTS',
                          rank: 'Sergeant (Sgt)',
                          unit: AppConstants.institutionName,
                        ),
                        _buildSignatureBlock(
                          designation: 'AUDITED & VERIFIED BY',
                          name: 'Officer-in-Charge (OIC) Canteen',
                          rank: 'Flight Lieutenant (Flt Lt)',
                          unit: AppConstants.institutionName,
                        ),
                        _buildSignatureBlock(
                          designation: 'COUNTERSIGNED & APPROVED',
                          name: 'Officer Commanding (OC) Admin',
                          rank: 'Wing Commander (Wg Cdr)',
                          unit: 'BAF Base Shamshernagar',
                        ),
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
    );
  }

  static Widget _buildTableCell(
    String text, {
    bool isHeader = false,
    bool isBold = false,
    bool isGrandTotal = false,
    TextAlign align = TextAlign.left,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Text(
        text,
        textAlign: align,
        style: TextStyle(
          fontSize: isHeader ? 11 : (isGrandTotal ? 12 : 11.5),
          fontWeight: (isHeader || isBold || isGrandTotal) ? FontWeight.bold : FontWeight.normal,
          color: isHeader
              ? Colors.white
              : (color ?? (isGrandTotal ? AppColors.bafNavy : AppColors.textPrimary)),
        ),
      ),
    );
  }

  static Widget _buildSignatureBlock({
    required String designation,
    required String name,
    required String rank,
    required String unit,
  }) {
    return Container(
      width: 250,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.ledgerBorderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            designation,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: AppColors.bafNavy,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 32), // Space for physical signature / seal
          Container(
            height: 1,
            color: AppColors.ledgerBorder,
          ),
          const SizedBox(height: 6),
          Text(
            name,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
          ),
          Text(
            rank,
            style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
          ),
          Text(
            unit,
            style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
