import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../providers/ledger_provider.dart';

class VoucherEntryModal extends ConsumerStatefulWidget {
  final String? preselectedRecruitId;
  final String? preselectedStaffId;

  const VoucherEntryModal({
    super.key,
    this.preselectedRecruitId,
    this.preselectedStaffId,
  });

  @override
  ConsumerState<VoucherEntryModal> createState() => _VoucherEntryModalState();
}

class _VoucherEntryModalState extends ConsumerState<VoucherEntryModal> {
  String _accountType = 'Recruit'; // 'Recruit' or 'Permanent Staff'
  String? _selectedRecruitId;
  String? _selectedStaffId;
  String _txType = 'DEBIT'; // 'DEBIT' (Canteen Expense) or 'CREDIT' (Recovery/Payment)
  String _category = 'Canteen Consumption';

  final _voucherNoController = TextEditingController();
  final _amountController = TextEditingController();
  final _descController = TextEditingController();
  final _authorizedByController = TextEditingController(text: 'Accounts NCO, RTS');

  final List<String> _debitCategories = [
    'Canteen Consumption',
    'Dry Ration Supplies',
    'Tea & Refreshments',
    'Special Dining Meal',
    'Canteen Store Toiletries',
  ];

  final List<String> _creditCategories = [
    'Cash Settlement',
    'Pay Deduction Recovery',
    'Bank Transfer Deposit',
    'Refund / Adjustment',
  ];

  @override
  void initState() {
    super.initState();
    final randomSuffix = (1000 + (DateTime.now().millisecondsSinceEpoch % 9000)).toString();
    _voucherNoController.text = 'VCH-BAF-$randomSuffix';

    if (widget.preselectedRecruitId != null) {
      _accountType = 'Recruit';
      _selectedRecruitId = widget.preselectedRecruitId;
    } else if (widget.preselectedStaffId != null) {
      _accountType = 'Permanent Staff';
      _selectedStaffId = widget.preselectedStaffId;
    }
  }

  @override
  void dispose() {
    _voucherNoController.dispose();
    _amountController.dispose();
    _descController.dispose();
    _authorizedByController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recruitsState = ref.watch(recruitsLedgerProvider);
    final staffState = ref.watch(staffLedgerProvider);
    final numberFormat = NumberFormat('#,##0.00', 'en_US');

    return Dialog(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      backgroundColor: AppColors.ledgerSurface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        width: 600,
        decoration: BoxDecoration(
          color: AppColors.ledgerSurface,
          border: Border.all(color: AppColors.bafNavy, width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Modal Title Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: AppColors.bafNavy,
              child: Row(
                children: [
                  const Icon(Icons.receipt_long, color: AppColors.bafGold, size: 20),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'POST ACCOUNTING VOUCHER — RTS CANTEEN',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 18),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Form Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row 1: Account Type Selection & Transaction Type
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'PERSONNEL CATEGORY',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                _buildSelectChip(
                                  label: 'Recruits (Intake/Sq)',
                                  isSelected: _accountType == 'Recruit',
                                  onTap: () {
                                    setState(() {
                                      _accountType = 'Recruit';
                                      _selectedRecruitId = null;
                                    });
                                  },
                                ),
                                const SizedBox(width: 8),
                                _buildSelectChip(
                                  label: 'Staff (BD/Office)',
                                  isSelected: _accountType == 'Permanent Staff',
                                  onTap: () {
                                    setState(() {
                                      _accountType = 'Permanent Staff';
                                      _selectedStaffId = null;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Transaction Type (Debit vs Credit)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'TRANSACTION CLASSIFICATION',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                _buildSelectChip(
                                  label: 'DEBIT (Charge/Due)',
                                  isSelected: _txType == 'DEBIT',
                                  color: AppColors.debitRed,
                                  onTap: () {
                                    setState(() {
                                      _txType = 'DEBIT';
                                      _category = _debitCategories.first;
                                    });
                                  },
                                ),
                                const SizedBox(width: 8),
                                _buildSelectChip(
                                  label: 'CREDIT (Payment)',
                                  isSelected: _txType == 'CREDIT',
                                  color: AppColors.creditGreen,
                                  onTap: () {
                                    setState(() {
                                      _txType = 'CREDIT';
                                      _category = _creditCategories.first;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Personnel Selection Dropdown
                  if (_accountType == 'Recruit') ...[
                    const Text(
                      'SELECT RECRUIT ACCOUNT',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      isDense: true,
                      initialValue: _selectedRecruitId ??
                          (recruitsState.allRecruits.isNotEmpty
                              ? recruitsState.allRecruits.first.id
                              : null),
                      decoration: const InputDecoration(),
                      items: recruitsState.allRecruits.map((r) {
                        return DropdownMenuItem(
                          value: r.id,
                          child: Text(
                            '${r.recruitNo} — ${r.name} (${r.squadron}, ${r.intake}) [Bal: Tk ${numberFormat.format(r.closingBalance)}]',
                            style: const TextStyle(fontSize: 12),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedRecruitId = val),
                    ),
                  ] else ...[
                    const Text(
                      'SELECT PERMANENT STAFF ACCOUNT',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      isDense: true,
                      initialValue: _selectedStaffId ??
                          (staffState.allStaff.isNotEmpty
                              ? staffState.allStaff.first.id
                              : null),
                      decoration: const InputDecoration(),
                      items: staffState.allStaff.map((s) {
                        return DropdownMenuItem(
                          value: s.id,
                          child: Text(
                            '${s.bdNo} ${s.rank} ${s.name} (${s.office}) [Bal: Tk ${numberFormat.format(s.closingBalance)}]',
                            style: const TextStyle(fontSize: 12),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedStaffId = val),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Row: Voucher No, Category & Amount
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'VOUCHER / REFERENCE NO',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextField(
                              controller: _voucherNoController,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'CATEGORY',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<String>(
                              isDense: true,
                              initialValue: _category,
                              decoration: const InputDecoration(),
                              items: (_txType == 'DEBIT' ? _debitCategories : _creditCategories)
                                  .map((c) => DropdownMenuItem(
                                        value: c,
                                        child: Text(c, style: const TextStyle(fontSize: 12)),
                                      ))
                                  .toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => _category = val);
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'AMOUNT (TK)',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextField(
                              controller: _amountController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: _txType == 'DEBIT' ? AppColors.debitRed : AppColors.creditGreen,
                              ),
                              decoration: const InputDecoration(
                                prefixText: '৳ ',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Description
                  const Text(
                    'TRANSACTION PARTICULARS / VOUCHER DETAILS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _descController,
                    decoration: const InputDecoration(
                      hintText: 'Enter mess items description, bill reference, or deduction month',
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('CANCEL'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.check_circle_outline, size: 16),
                        label: const Text('RECORD & UPDATE LEDGER'),
                        onPressed: () {
                          _submitVoucher(recruitsState, staffState);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    Color color = AppColors.bafDeepBlue,
  }) {
    return InkWell(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color : AppColors.ledgerSurface,
          border: Border.all(
            color: isSelected ? color : AppColors.ledgerBorder,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  void _submitVoucher(RecruitsLedgerState recruitsState, StaffLedgerState staffState) {
    final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid amount greater than zero.'),
          backgroundColor: AppColors.debitRed,
        ),
      );
      return;
    }

    final debit = _txType == 'DEBIT' ? amount : 0.0;
    final credit = _txType == 'CREDIT' ? amount : 0.0;
    final voucherNo = _voucherNoController.text.trim();
    final description = _descController.text.trim().isEmpty
        ? '$_category - Canteen accounts posting'
        : _descController.text.trim();
    final authorizedBy = _authorizedByController.text.trim();

    if (_accountType == 'Recruit') {
      final recruitId = _selectedRecruitId ??
          (recruitsState.allRecruits.isNotEmpty ? recruitsState.allRecruits.first.id : null);
      if (recruitId == null) return;

      ref.read(recruitsLedgerProvider.notifier).postTransaction(
            recruitId: recruitId,
            voucherNo: voucherNo,
            category: _category,
            description: description,
            debit: debit,
            credit: credit,
            authorizedBy: authorizedBy,
          );
    } else {
      final staffId = _selectedStaffId ??
          (staffState.allStaff.isNotEmpty ? staffState.allStaff.first.id : null);
      if (staffId == null) return;

      ref.read(staffLedgerProvider.notifier).postTransaction(
            staffId: staffId,
            voucherNo: voucherNo,
            category: _category,
            description: description,
            debit: debit,
            credit: credit,
            authorizedBy: authorizedBy,
          );
    }

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Voucher $voucherNo recorded and ledger balance updated.'),
        backgroundColor: AppColors.cleared,
      ),
    );
  }
}
