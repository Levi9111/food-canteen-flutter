import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../ledger/providers/ledger_provider.dart';
import '../models/monthly_audit_statement.dart';

final monthlyAuditProvider = Provider<MonthlyAuditStatement>((ref) {
  final recruitsState = ref.watch(recruitsLedgerProvider);
  final staffState = ref.watch(staffLedgerProvider);

  final rRecruits = recruitsState.allRecruits;
  final rStaff = staffState.allStaff;

  final recruitOpening =
      rRecruits.fold(0.0, (sum, r) => sum + r.openingBalance);
  final recruitDebits =
      rRecruits.fold(0.0, (sum, r) => sum + r.totalDebits);
  final recruitCredits =
      rRecruits.fold(0.0, (sum, r) => sum + r.totalCredits);
  final recruitClosing =
      rRecruits.fold(0.0, (sum, r) => sum + r.closingBalance);

  final staffOpening =
      rStaff.fold(0.0, (sum, s) => sum + s.openingBalance);
  final staffDebits =
      rStaff.fold(0.0, (sum, s) => sum + s.totalDebits);
  final staffCredits =
      rStaff.fold(0.0, (sum, s) => sum + s.totalCredits);
  final staffClosing =
      rStaff.fold(0.0, (sum, s) => sum + s.closingBalance);

  final now = DateTime.now();
  final months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];
  final currentMonthName = '${months[now.month - 1]} ${now.year}';

  return MonthlyAuditStatement(
    period: currentMonthName,
    generatedDate: now,
    totalRecruitsEnrolled: rRecruits.length,
    totalStaffEnrolled: rStaff.length,
    recruitOpeningBalance: recruitOpening,
    recruitTotalDebits: recruitDebits,
    recruitTotalCredits: recruitCredits,
    recruitClosingBalance: recruitClosing,
    staffOpeningBalance: staffOpening,
    staffTotalDebits: staffDebits,
    staffTotalCredits: staffCredits,
    staffClosingBalance: staffClosing,
  );
});
