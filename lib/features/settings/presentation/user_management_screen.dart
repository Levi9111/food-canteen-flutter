import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/canteen_theme_extension.dart';
import '../../../core/widgets/modal_action_bar.dart';
import '../../auth/models/session_user.dart';
import '../../auth/providers/operator_management_provider.dart';
import '../../auth/providers/session_provider.dart';
import '../../recruits_canteen/constants/canteen_constants.dart';

class UserManagementScreen extends ConsumerStatefulWidget {
  const UserManagementScreen({super.key});

  @override
  ConsumerState<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends ConsumerState<UserManagementScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(operatorManagementProvider.notifier).fetchOperators());
  }

  void _confirmRemoveOperator(BuildContext context, WidgetRef ref, SessionUser target) {
    final theme = context.canteenTheme;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.cardBackground,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        title: Row(
          children: [
            Icon(Icons.dangerous_rounded, color: theme.debit, size: 24),
            const SizedBox(width: 8),
            Text(
              'REVOKE ${target.role} APPOINTMENT',
              style: TextStyle(color: theme.debit, fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: theme.debit.withValues(alpha: 0.1),
                border: Border.all(color: theme.debit, width: 1.2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.report_problem, color: theme.debit, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'STRICT REVOCATION WARNING',
                        style: TextStyle(color: theme.debit, fontWeight: FontWeight.w900, fontSize: 10.5),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Revoking ${target.rank} ${target.name} (${target.bdNo}) will immediately terminate their login credentials and prevent further entry of financial transactions. The position will remain vacant until a new in-charge is appointed.',
                    style: TextStyle(color: theme.textPrimary, fontSize: 10.5, height: 1.35),
                  ),
                ],
              ),
            ),
            Text(
              'Are you sure you wish to revoke this appointment?',
              style: TextStyle(color: theme.textPrimary, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          ModalActionBar(
            cancelLabel: 'CANCEL',
            confirmLabel: 'REVOKE APPOINTMENT',
            confirmColor: theme.debit,
            confirmTextColor: Colors.white,
            confirmIcon: Icons.delete_forever,
            onCancel: () => Navigator.of(ctx).pop(),
            onConfirm: () async {
              Navigator.of(ctx).pop();
              final targetId = target.id ?? target.username;
              final success = await ref.read(operatorManagementProvider.notifier).removeOperator(targetId);
              if (context.mounted) {
                final opState = ref.read(operatorManagementProvider);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success
                        ? (opState.successMessage ?? 'Appointment revoked successfully')
                        : (opState.errorMessage ?? 'Revocation failed')),
                    backgroundColor: success ? AppColors.bafRoundelGreen : theme.debit,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  void _showEnrollOperatorDialog(BuildContext context, WidgetRef ref, String role) {
    final nameCtrl = TextEditingController();
    final usernameCtrl = TextEditingController();
    final bdNoCtrl = TextEditingController();
    final tradeCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    String selectedRank = role == 'JCOIC' ? 'MWO' : 'Cpl';
    final theme = context.canteenTheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(modalCtx).viewInsets.bottom + 16,
                top: 24,
              ),
              child: Center(
                child: Container(
                  width: 440,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: theme.cardBackground,
                    border: Border.all(color: theme.accentGold, width: 1.5),
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
                              const Icon(Icons.military_tech, color: AppColors.bafGold, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                'APPOINT $role IN-CHARGE',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // STRICT SECURITY MANDATE
                              Container(
                                padding: const EdgeInsets.all(10),
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: theme.surface,
                                  border: Border.all(color: theme.accentGold, width: 1),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.security, size: 16, color: AppColors.bafGold),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'SECURITY NOTICE: Appointing an operator grants financial ledger modification privileges, receipt generation, and closing rights. Ensure BD particulars belong to authorized active cadre personnel.',
                                        style: TextStyle(fontSize: 10, color: theme.textSecondary, height: 1.3),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              Text(
                                'FULL NAME:',
                                style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: theme.textPrimary),
                              ),
                              const SizedBox(height: 4),
                              TextField(
                                controller: nameCtrl,
                                style: TextStyle(color: theme.textPrimary, fontSize: 13),
                                decoration: InputDecoration(
                                  hintText: 'e.g. Humayun Kabir or Shanjid Ahmad',
                                  filled: true,
                                  fillColor: theme.surface,
                                  isDense: true,
                                  border: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: theme.cardBorder)),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'BD NUMBER:',
                                          style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: theme.textPrimary),
                                        ),
                                        const SizedBox(height: 4),
                                        TextField(
                                          controller: bdNoCtrl,
                                          style: TextStyle(color: theme.textPrimary, fontSize: 13),
                                          decoration: InputDecoration(
                                            hintText: 'e.g. 472770 or BD/472770',
                                            filled: true,
                                            fillColor: theme.surface,
                                            isDense: true,
                                            border: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: theme.cardBorder)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'TRADE:',
                                          style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: theme.textPrimary),
                                        ),
                                        const SizedBox(height: 4),
                                        TextField(
                                          controller: tradeCtrl,
                                          style: TextStyle(color: theme.textPrimary, fontSize: 13),
                                          decoration: InputDecoration(
                                            hintText: 'e.g. E&I Fitter',
                                            filled: true,
                                            fillColor: theme.surface,
                                            isDense: true,
                                            border: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: theme.cardBorder)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'BAF RANK:',
                                          style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: theme.textPrimary),
                                        ),
                                        const SizedBox(height: 4),
                                        DropdownButtonFormField<String>(
                                          initialValue: selectedRank,
                                          dropdownColor: theme.cardBackground,
                                          style: TextStyle(color: theme.textPrimary, fontSize: 13),
                                          decoration: InputDecoration(
                                            filled: true,
                                            fillColor: theme.surface,
                                            isDense: true,
                                            border: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: theme.cardBorder)),
                                          ),
                                          items: CanteenConstants.ranks.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                                          onChanged: (val) {
                                            if (val != null) {
                                              setModalState(() => selectedRank = val);
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'LOGIN USERNAME:',
                                          style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: theme.textPrimary),
                                        ),
                                        const SizedBox(height: 4),
                                        TextField(
                                          controller: usernameCtrl,
                                          style: TextStyle(color: theme.textPrimary, fontSize: 13),
                                          decoration: InputDecoration(
                                            hintText: role.toLowerCase(),
                                            filled: true,
                                            fillColor: theme.surface,
                                            isDense: true,
                                            border: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: theme.cardBorder)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'LOGIN PASSWORD:',
                                style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: theme.textPrimary),
                              ),
                              const SizedBox(height: 4),
                              TextField(
                                controller: passCtrl,
                                obscureText: true,
                                style: TextStyle(color: theme.textPrimary, fontSize: 13),
                                decoration: InputDecoration(
                                  hintText: 'Enter password (minimum 6 characters)',
                                  filled: true,
                                  fillColor: theme.surface,
                                  isDense: true,
                                  border: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: theme.cardBorder)),
                                ),
                              ),
                              const SizedBox(height: 18),
                              ModalActionBar(
                                cancelLabel: 'CANCEL',
                                confirmLabel: 'APPOINT $role',
                                onCancel: () => Navigator.of(ctx).pop(),
                                onConfirm: () async {
                                  final name = nameCtrl.text.trim();
                                  final bdNo = bdNoCtrl.text.trim();
                                  final trade = tradeCtrl.text.trim();
                                  final username = usernameCtrl.text.trim().isEmpty ? role.toLowerCase() : usernameCtrl.text.trim();
                                  final password = passCtrl.text;

                                  if (name.isEmpty || bdNo.isEmpty || password.length < 6) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Please fill all fields and provide password of at least 6 characters')),
                                    );
                                    return;
                                  }

                                  Navigator.of(ctx).pop();
                                  final success = await ref.read(operatorManagementProvider.notifier).enrollOperator(
                                        name: name,
                                        username: username,
                                        password: password,
                                        role: role,
                                        rank: selectedRank,
                                        bdNo: bdNo,
                                        trade: trade.isNotEmpty ? trade : null,
                                      );

                                  if (context.mounted) {
                                    final opState = ref.read(operatorManagementProvider);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(success
                                            ? (opState.successMessage ?? '$role appointment created successfully')
                                            : (opState.errorMessage ?? 'Appointment failed')),
                                        backgroundColor: success ? AppColors.bafRoundelGreen : theme.debit,
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

  @override
  Widget build(BuildContext context) {
    final theme = context.canteenTheme;
    final opState = ref.watch(operatorManagementProvider);
    final session = ref.watch(sessionProvider);
    final currentRole = session.user?.role ?? '';
    final currentUserId = session.user?.id;
    final currentUsername = session.user?.username ?? '';

    final ncoic = opState.operators.where((u) => u.role == 'NCOIC').firstOrNull;
    final jcoic = opState.operators.where((u) => u.role == 'JCOIC').firstOrNull;

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        backgroundColor: AppColors.bafNavy,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'DUTY APPOINTMENTS & OPERATORS',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 0.5, color: Colors.white),
        ),
        elevation: 0,
        shape: const Border(bottom: BorderSide(color: AppColors.bafGold, width: 1.5)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.bafGold, size: 20),
            tooltip: 'Refresh Operators',
            onPressed: () => ref.read(operatorManagementProvider.notifier).fetchOperators(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // STRICT SECURITY BANNER
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.bafNavy,
                border: Border.all(color: AppColors.bafGold, width: 1.5),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.shield_outlined, color: AppColors.bafGold, size: 24),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'OFFICIAL APPOINTMENT DISCIPLINE & ACCESS MANDATE',
                          style: TextStyle(
                            color: AppColors.bafGold,
                            fontWeight: FontWeight.w900,
                            fontSize: 11,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Only active BAF RTS personnel appointed to Canteen Duty (NCOIC/JCOIC) are authorized to maintain ledger records. All account modifications and credential updates are permanently audited.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.5,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // APPOINTMENTS
            _buildSectionHeader(Icons.military_tech, 'ACTIVE DUTY APPOINTMENTS'),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.cardBackground,
                border: Border.all(color: theme.cardBorderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // NCOIC Card
                  _buildRoleCard(
                    context: context,
                    ref: ref,
                    theme: theme,
                    roleTitle: 'NCO IN-CHARGE (NCOIC)',
                    roleTag: 'NCOIC',
                    operator: ncoic,
                    currentRole: currentRole,
                    currentUserId: currentUserId,
                    currentUsername: currentUsername,
                  ),
                  const SizedBox(height: 10),

                  // JCOIC Card
                  _buildRoleCard(
                    context: context,
                    ref: ref,
                    theme: theme,
                    roleTitle: 'JCO IN-CHARGE (JCOIC)',
                    roleTag: 'JCOIC',
                    operator: jcoic,
                    currentRole: currentRole,
                    currentUserId: currentUserId,
                    currentUsername: currentUsername,
                  ),
                  const SizedBox(height: 12),

                  if (opState.isFullyStaffed)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: theme.surface,
                        border: Border.all(color: theme.cardBorder),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_outline, size: 16, color: AppColors.bafRoundelGreen),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Both NCOIC and JCOIC duty posts are staffed and active.',
                              style: TextStyle(fontSize: 10.5, color: theme.textSecondary, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (opState.vacantRole != null)
                    SizedBox(
                      height: 40,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.person_add_alt_1, size: 16),
                        label: Text(
                          'APPOINT ${opState.vacantRole} IN-CHARGE',
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.5),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.bafGold,
                          foregroundColor: AppColors.bafNavy,
                          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                        ),
                        onPressed: () => _showEnrollOperatorDialog(context, ref, opState.vacantRole!),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required BuildContext context,
    required WidgetRef ref,
    required CanteenThemeColors theme,
    required String roleTitle,
    required String roleTag,
    required SessionUser? operator,
    required String currentRole,
    required String? currentUserId,
    required String currentUsername,
  }) {
    final isVacant = operator == null;
    final isSelf = !isVacant &&
        ((operator.id != null && operator.id == currentUserId) ||
            operator.username.toLowerCase() == currentUsername.toLowerCase());

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.surface,
        border: Border.all(
          color: isVacant ? theme.cardBorderLight : theme.accentGold.withValues(alpha: 0.5),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                color: isVacant ? AppColors.textMuted : AppColors.bafNavy,
                child: Text(
                  roleTag,
                  style: const TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.w900),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  roleTitle,
                  style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: theme.textSecondary),
                ),
              ),
              if (isSelf)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.bafRoundelGreen.withValues(alpha: 0.15),
                  ),
                  child: const Text(
                    'CURRENT USER',
                    style: TextStyle(color: AppColors.bafRoundelGreen, fontSize: 8.5, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          if (isVacant)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Position vacant — No personnel currently assigned.',
                    style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: theme.textSecondary),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _showEnrollOperatorDialog(context, ref, roleTag),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.bafGold,
                    foregroundColor: AppColors.bafNavy,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  ),
                  child: Text(
                    '+ Appoint $roleTag',
                    style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            )
          else
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        operator.name,
                        style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: theme.textPrimary),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${operator.rank} • BD No: ${operator.bdNo}${operator.trade != null ? ' • ${operator.trade}' : ''}',
                        style: TextStyle(fontSize: 11, color: theme.textSecondary),
                      ),
                      Text(
                        'Login ID: ${operator.username}',
                        style: TextStyle(fontSize: 10, color: theme.textMuted),
                      ),
                    ],
                  ),
                ),
                OutlinedButton.icon(
                  icon: Icon(Icons.person_remove_outlined, size: 14, color: theme.debit),
                  label: Text(
                    'Revoke',
                    style: TextStyle(color: theme.debit, fontSize: 10.5, fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: theme.debit),
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  ),
                  onPressed: () => _confirmRemoveOperator(context, ref, operator),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 13, color: AppColors.bafGold),
          const SizedBox(width: 6),
          Text(
            title,
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w900,
              color: AppColors.bafGold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
