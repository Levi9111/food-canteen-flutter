import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/locale_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/canteen_theme_extension.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/widgets/baf_rts_crest.dart';
import '../../../core/widgets/modal_action_bar.dart';
import '../../auth/providers/session_provider.dart';
import '../../recruits_canteen/providers/canteen_register_provider.dart';
import '../../recruits_canteen/providers/canteen_structure_provider.dart';
import 'squadron_management_screen.dart';
import 'user_management_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  void _showNewEntryDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    final theme = context.canteenTheme;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Center(
            child: Container(
              width: 380,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: theme.cardBackground,
                border: Border.all(color: theme.accentGold, width: 1.5),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    color: AppColors.bafNavy,
                    child: const Text(
                      'START NEW RECRUIT ENTRY BATCH',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ENTRY BATCH NUMBER (e.g. 55, 56):',
                          style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: theme.textPrimary),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: controller,
                          keyboardType: TextInputType.number,
                          autofocus: true,
                          style: TextStyle(color: theme.textPrimary, fontSize: 13),
                          decoration: InputDecoration(
                            hintText: 'Enter batch number',
                            hintStyle: TextStyle(color: theme.textSecondary),
                            filled: true,
                            fillColor: theme.surface,
                            isDense: true,
                            border: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: theme.cardBorder)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ModalActionBar(
                          cancelLabel: 'CANCEL',
                          confirmLabel: 'CREATE BATCH',
                          onCancel: () => Navigator.of(ctx).pop(),
                          onConfirm: () {
                            final val = controller.text.trim();
                            if (val.isNotEmpty) {
                              ref.read(canteenRegisterProvider.notifier).addNewEntry(val);
                            }
                            Navigator.of(ctx).pop();
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    final theme = context.canteenTheme;
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: theme.cardBackground,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          title: Text(
            'CONFIRM LOGOUT',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: theme.textPrimary),
          ),
          content: Text(
            'Are you sure you want to end this duty session and log out?',
            style: TextStyle(fontSize: 12, color: theme.textSecondary),
          ),
          actions: [
            ModalActionBar(
              cancelLabel: 'CANCEL',
              confirmLabel: 'LOGOUT',
              confirmColor: theme.debit,
              confirmTextColor: Colors.white,
              confirmIcon: Icons.logout,
              onCancel: () => Navigator.of(ctx).pop(),
              onConfirm: () {
                Navigator.of(ctx).pop();
                ref.read(sessionProvider.notifier).logout();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final themeNotifier = ref.read(themeModeProvider.notifier);
    final language = ref.watch(localeProvider);
    final localeNotifier = ref.read(localeProvider.notifier);
    final structure = ref.watch(canteenStructureProvider);
    final registerState = ref.watch(canteenRegisterProvider);
    final registerNotifier = ref.read(canteenRegisterProvider.notifier);
    final session = ref.watch(sessionProvider);

    final theme = context.canteenTheme;
    final squadrons = structure.squadrons;

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        backgroundColor: AppColors.bafNavy,
        title: const Text(
          'CANTEEN SETTINGS & CONFIGURATION',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 0.5),
        ),
        elevation: 0,
        shape: const Border(bottom: BorderSide(color: AppColors.bafGold, width: 1.5)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Appearance & Theme Mode Section
            _buildSectionHeader(Icons.palette_outlined, 'APPEARANCE & THEME'),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.cardBackground,
                border: Border.all(color: theme.cardBorderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('THEME MODE (LIGHT / DARK):', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: theme.textPrimary)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildChoiceChip(
                          label: 'Light Mode',
                          icon: Icons.light_mode,
                          isSelected: themeMode == ThemeMode.light,
                          onTap: () => themeNotifier.setThemeMode(ThemeMode.light),
                          theme: theme,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildChoiceChip(
                          label: 'Dark Mode',
                          icon: Icons.dark_mode,
                          isSelected: themeMode == ThemeMode.dark,
                          onTap: () => themeNotifier.setThemeMode(ThemeMode.dark),
                          theme: theme,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildChoiceChip(
                          label: 'System',
                          icon: Icons.brightness_auto,
                          isSelected: themeMode == ThemeMode.system,
                          onTap: () => themeNotifier.setThemeMode(ThemeMode.system),
                          theme: theme,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 2. Language & Localization Section
            _buildSectionHeader(Icons.language_outlined, 'LANGUAGE & LOCALIZATION'),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.cardBackground,
                border: Border.all(color: theme.cardBorderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('SYSTEM LANGUAGE:', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: theme.textPrimary)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildChoiceChip(
                          label: 'English (US)',
                          icon: Icons.translate,
                          isSelected: language == AppLanguage.english,
                          onTap: () => localeNotifier.setLanguage(AppLanguage.english),
                          theme: theme,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildChoiceChip(
                          label: 'বাংলা (Bengali)',
                          icon: Icons.g_translate,
                          isSelected: language == AppLanguage.bengali,
                          onTap: () => localeNotifier.setLanguage(AppLanguage.bengali),
                          theme: theme,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 3. Active Entry Batch Selection
            _buildSectionHeader(Icons.military_tech_outlined, 'ACTIVE RECRUIT ENTRY BATCH'),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.cardBackground,
                border: Border.all(color: theme.cardBorderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('CURRENT BATCH:', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: theme.textPrimary)),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                              decoration: BoxDecoration(
                                border: Border.all(color: theme.cardBorder),
                                color: theme.surface,
                              ),
                              child: DropdownButton<String>(
                                value: registerState.allEntries.contains(registerState.activeEntry)
                                    ? registerState.activeEntry
                                    : (registerState.allEntries.isNotEmpty ? registerState.allEntries.first : '54'),
                                isExpanded: true,
                                underline: const SizedBox(),
                                dropdownColor: theme.cardBackground,
                                style: TextStyle(color: theme.textPrimary, fontWeight: FontWeight.bold, fontSize: 13),
                                items: registerState.allEntries.map((e) {
                                  return DropdownMenuItem(value: e, child: Text('Entry $e'));
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    registerNotifier.setActiveEntry(val);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add, size: 14),
                        label: const Text('NEW BATCH'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.bafNavy,
                          foregroundColor: AppColors.bafGold,
                          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                        ),
                        onPressed: () => _showNewEntryDialog(context, ref),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 4. Dedicated Management Pages Navigation
            _buildSectionHeader(Icons.admin_panel_settings_outlined, 'CANTEEN CONFIGURATION & ACCESS CONTROL'),

            // Navigation Card 1: Squadron & Room Management
            _buildNavigationCard(
              theme: theme,
              icon: Icons.shield_outlined,
              iconColor: AppColors.bafGold,
              title: 'Squadron & Room Management',
              badge: '${squadrons.length} SQUADRONS',
              badgeColor: AppColors.bafGold,
              subtitle: 'Configure squadron names, manage dynamic room numbers, and cascade-update ledger database structures.',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SquadronManagementScreen()),
                );
              },
            ),
            const SizedBox(height: 10),

            // Navigation Card 2: Duty Appointments & Operators
            _buildNavigationCard(
              theme: theme,
              icon: Icons.military_tech_outlined,
              iconColor: AppColors.bafGold,
              title: 'Duty In-Charge & Operator Management',
              badge: 'SECURITY & ACCESS',
              badgeColor: AppColors.bafNavy,
              subtitle: 'Appoint or revoke NCOIC / JCOIC duty personnel, configure credentials, and manage financial authorization.',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const UserManagementScreen()),
                );
              },
            ),
            const SizedBox(height: 14),

            // 5. Active Session & Logout
            _buildSectionHeader(Icons.person_pin, 'OPERATOR SESSION'),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.cardBackground,
                border: Border.all(color: theme.cardBorderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        color: AppColors.bafNavy,
                        child: const BafRtsCrest(size: 28),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              session.user?.name ?? 'Operator',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: theme.textPrimary),
                            ),
                            Text(
                              '${session.user?.rank ?? ''} • ${session.user?.role ?? 'NCOIC'} (${session.user?.bdNo ?? ''})',
                              style: TextStyle(fontSize: 10.5, color: theme.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        color: AppColors.bafRoundelGreen,
                        child: Text(
                          session.user?.role ?? 'DUTY',
                          style: const TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 42,
                    child: OutlinedButton.icon(
                      icon: Icon(Icons.logout, size: 16, color: theme.debit),
                      label: Text(
                        'LOGOUT SESSION',
                        style: TextStyle(color: theme.debit, fontWeight: FontWeight.w900, fontSize: 11.5),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: theme.debit, width: 1.2),
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                      ),
                      onPressed: () => _confirmLogout(context, ref),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Footer
            Center(
              child: Text(
                'BAF RTS Food Canteen System v1.1.0 • Tactical Ledger',
                style: TextStyle(fontSize: 9.5, color: theme.textSecondary),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationCard({
    required CanteenThemeColors theme,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String badge,
    required Color badgeColor,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.cardBackground,
          border: Border.all(color: theme.cardBorderLight),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              color: AppColors.bafNavy,
              child: Icon(icon, size: 22, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: theme.textPrimary,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        color: badgeColor == AppColors.bafGold ? AppColors.bafGold : AppColors.bafNavy,
                        child: Text(
                          badge,
                          style: TextStyle(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w900,
                            color: badgeColor == AppColors.bafGold ? AppColors.bafNavy : Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 10.5, color: theme.textSecondary, height: 1.3),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.bafGold),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      color: AppColors.bafNavy,
      child: Row(
        children: [
          Icon(icon, color: AppColors.bafGold, size: 15),
          const SizedBox(width: 6),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.bafGold,
              fontSize: 10.5,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChoiceChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required CanteenThemeColors theme,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.bafNavy : theme.surface,
          border: Border.all(
            color: isSelected ? AppColors.bafGold : theme.cardBorder,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 13,
              color: isSelected ? AppColors.bafGold : theme.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.bold,
                color: isSelected ? AppColors.bafGold : theme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
