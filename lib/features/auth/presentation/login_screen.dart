import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/baf_rts_crest.dart';
import '../providers/operator_management_provider.dart';
import '../providers/session_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _usernameCtrl = TextEditingController(text: '472770');
  final _passwordCtrl = TextEditingController(text: 'ncoic123');
  bool _obscurePassword = true;
  String _selectedRole = 'NCOIC';

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _selectRole(String role, String user, String pass) {
    setState(() {
      _selectedRole = role;
      _usernameCtrl.text = user;
      _passwordCtrl.text = pass;
    });
  }

  @override
  Widget build(BuildContext context) {
    final sessionState = ref.watch(sessionProvider);
    final sessionNotifier = ref.read(sessionProvider.notifier);
    final opState = ref.watch(operatorManagementProvider);
    final jcoic = opState.operators.where((u) => u.role == 'JCOIC').firstOrNull;

    return Scaffold(
      backgroundColor: AppColors.bafNavy,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Official BAF RTS Crest
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.bafDeepBlue,
                        border: Border.all(color: AppColors.bafGold, width: 2),
                      ),
                      child: const BafRtsCrest(size: 64),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 2. Titles
                  const Text(
                    'BANGLADESH AIR FORCE',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.bafGold,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'FOOD CANTEEN SYSTEM',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Recruits Training School • Shamshernagar',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withAlpha(180),
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 3. Card Container
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.ledgerSurface,
                      border: Border.all(color: AppColors.bafGold, width: 1.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'DUTY IN-CHARGE ACCOUNT',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: AppColors.bafNavy,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Role Selector Quick Buttons
                        Row(
                          children: [
                            Expanded(
                              child: _buildRoleSelectorTile(
                                role: 'NCOIC',
                                name: 'Cpl Shanjid Ahmad',
                                subtitle: 'BD/472770 • E&I Fitter',
                                isSelected: _selectedRole == 'NCOIC',
                                isVacant: false,
                                onTap: () => _selectRole('NCOIC', '472770', 'ncoic123'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildRoleSelectorTile(
                                role: 'JCOIC',
                                name: jcoic != null ? '${jcoic.rank} ${jcoic.name}' : 'Vacant Position',
                                subtitle: jcoic != null
                                    ? '${jcoic.bdNo}${jcoic.trade != null ? ' • ${jcoic.trade}' : ''}'
                                    : 'Appoint in Settings',
                                isSelected: _selectedRole == 'JCOIC',
                                isVacant: jcoic == null,
                                onTap: () {
                                  if (jcoic != null) {
                                    _selectRole('JCOIC', jcoic.username, '');
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'JCOIC position is currently vacant. Please login as NCOIC (Cpl Shanjid Ahmad) to appoint JCOIC from Settings.',
                                        ),
                                        backgroundColor: AppColors.bafNavy,
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Username Field
                        const Text(
                          'MILITARY BD NO / USERNAME',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 5),
                        TextField(
                          controller: _usernameCtrl,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.person, size: 18, color: AppColors.bafNavy),
                            hintText: 'Enter BD No (e.g. 472770) or Username',
                            isDense: true,
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Password Field
                        const Text(
                          'PASSWORD',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 5),
                        TextField(
                          controller: _passwordCtrl,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.lock, size: 18, color: AppColors.bafNavy),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                size: 18,
                              ),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                            hintText: 'Enter password',
                            isDense: true,
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Error Banner
                        if (sessionState.errorMessage != null) ...[
                          Container(
                            padding: const EdgeInsets.all(8),
                            color: AppColors.debitRed.withAlpha(25),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline, color: AppColors.debitRed, size: 16),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    sessionState.errorMessage!,
                                    style: const TextStyle(
                                      color: AppColors.debitRed,
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                        ],

                        // Sign In Button
                        SizedBox(
                          height: 46,
                          child: ElevatedButton.icon(
                            icon: sessionState.isLoading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.bafGold,
                                    ),
                                  )
                                : const Icon(Icons.login, size: 18, color: AppColors.bafGold),
                            label: const Text(
                              'SIGN IN TO CANTEEN',
                              style: TextStyle(
                                color: AppColors.bafGold,
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.6,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.bafNavy,
                              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                              elevation: 0,
                            ),
                            onPressed: sessionState.isLoading
                                ? null
                                : () {
                                    sessionNotifier.login(
                                      username: _usernameCtrl.text,
                                      password: _passwordCtrl.text,
                                    );
                                  },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleSelectorTile({
    required String role,
    required String name,
    required String subtitle,
    required bool isSelected,
    required bool isVacant,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.bafNavy : (isVacant ? const Color(0xFFF1F5F9) : Colors.white),
          border: Border.all(
            color: isSelected
                ? AppColors.bafGold
                : (isVacant ? AppColors.ledgerBorder : AppColors.ledgerBorder),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                  size: 13,
                  color: isSelected ? AppColors.bafGold : AppColors.textMuted,
                ),
                const SizedBox(width: 4),
                Text(
                  role,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                    color: isSelected ? AppColors.bafGold : AppColors.bafNavy,
                  ),
                ),
                if (isVacant) ...[
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    color: AppColors.textMuted.withValues(alpha: 0.2),
                    child: const Text(
                      'VACANT',
                      style: TextStyle(fontSize: 7.5, fontWeight: FontWeight.bold, color: AppColors.textMuted),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 3),
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : (isVacant ? AppColors.textMuted : AppColors.textPrimary),
              ),
            ),
            const SizedBox(height: 1),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 8.5,
                color: isSelected ? Colors.white70 : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
