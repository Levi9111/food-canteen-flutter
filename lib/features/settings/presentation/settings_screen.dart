import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/locale_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/widgets/baf_rts_crest.dart';
import '../../../core/widgets/modal_action_bar.dart';
import '../../auth/providers/session_provider.dart';
import '../../recruits_canteen/providers/canteen_register_provider.dart';
import '../../recruits_canteen/providers/canteen_structure_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String? _selectedSquadronForRooms;

  void _showAddSquadronDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          child: Container(
            width: 360,
            color: AppColors.ledgerSurface,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  color: AppColors.bafNavy,
                  child: const Text(
                    'ADD NEW SQUADRON',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'SQUADRON NAME (e.g. Meghna, Jamuna):',
                        style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: controller,
                        autofocus: true,
                        decoration: const InputDecoration(hintText: 'Enter squadron name', isDense: true),
                      ),
                      const SizedBox(height: 16),
                      ModalActionBar(
                        cancelLabel: 'CANCEL',
                        confirmLabel: 'ADD SQUADRON',
                        onCancel: () => Navigator.of(ctx).pop(),
                        onConfirm: () async {
                          final val = controller.text.trim();
                          if (val.isNotEmpty) {
                            final success = await ref.read(canteenStructureProvider.notifier).addSquadron(val);
                            if (ctx.mounted) {
                              Navigator.of(ctx).pop();
                              if (!success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Squadron already exists or invalid')),
                                );
                              }
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddRoomDialog(BuildContext context, WidgetRef ref, String squadron) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          child: Container(
            width: 360,
            color: AppColors.ledgerSurface,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  color: AppColors.bafNavy,
                  child: Text(
                    'ADD ROOM TO $squadron SQN',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ROOM NAME (e.g. Room 17):',
                        style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: controller,
                        autofocus: true,
                        decoration: const InputDecoration(hintText: 'Enter room name', isDense: true),
                      ),
                      const SizedBox(height: 16),
                      ModalActionBar(
                        cancelLabel: 'CANCEL',
                        confirmLabel: 'ADD ROOM',
                        onCancel: () => Navigator.of(ctx).pop(),
                        onConfirm: () async {
                          final val = controller.text.trim();
                          if (val.isNotEmpty) {
                            final success = await ref.read(canteenStructureProvider.notifier).addRoom(squadron, val);
                            if (ctx.mounted) {
                              Navigator.of(ctx).pop();
                              if (!success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Room already exists in this squadron')),
                                );
                              }
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showNewEntryDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          child: Container(
            width: 360,
            color: AppColors.ledgerSurface,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  color: AppColors.bafNavy,
                  child: const Text(
                    'CREATE NEW RECRUIT ENTRY BATCH',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11.5),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ENTRY BATCH NUMBER (e.g. 55, 56):',
                        style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: controller,
                        keyboardType: TextInputType.number,
                        autofocus: true,
                        decoration: const InputDecoration(hintText: 'Enter batch number', isDense: true),
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
        );
      },
    );
  }

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          title: const Text('CONFIRM LOGOUT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          content: const Text('Are you sure you want to end this duty session and log out?'),
          actions: [
            ModalActionBar(
              cancelLabel: 'CANCEL',
              confirmLabel: 'LOGOUT',
              confirmColor: AppColors.debitRed,
              confirmTextColor: Colors.white,
              confirmIcon: Icons.logout,
              onCancel: () => Navigator.of(ctx).pop(),
              onConfirm: () {
                Navigator.of(ctx).pop();
                ref.read(sessionProvider.notifier).logout();
                Navigator.of(context).pop(); // Back to login screen
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
    final structureNotifier = ref.read(canteenStructureProvider.notifier);
    final registerState = ref.watch(canteenRegisterProvider);
    final registerNotifier = ref.read(canteenRegisterProvider.notifier);
    final session = ref.watch(sessionProvider);

    final squadrons = structure.squadrons;
    final activeSquadron = _selectedSquadronForRooms != null && squadrons.contains(_selectedSquadronForRooms)
        ? _selectedSquadronForRooms!
        : (squadrons.isNotEmpty ? squadrons.first : 'Sadruddin');
    final roomsForActiveSqn = structure.getRoomsForSquadron(activeSquadron);

    return Scaffold(
      backgroundColor: AppColors.ledgerBackground,
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
              color: AppColors.ledgerSurface,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('THEME MODE (LIGHT / DARK):', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildChoiceChip(
                          label: 'Light Mode',
                          icon: Icons.light_mode,
                          isSelected: themeMode == ThemeMode.light,
                          onTap: () => themeNotifier.setThemeMode(ThemeMode.light),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildChoiceChip(
                          label: 'Dark Mode',
                          icon: Icons.dark_mode,
                          isSelected: themeMode == ThemeMode.dark,
                          onTap: () => themeNotifier.setThemeMode(ThemeMode.dark),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildChoiceChip(
                          label: 'System',
                          icon: Icons.brightness_auto,
                          isSelected: themeMode == ThemeMode.system,
                          onTap: () => themeNotifier.setThemeMode(ThemeMode.system),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 2. Language Selection (English / Bengali)
            _buildSectionHeader(Icons.language, 'LANGUAGE (ভাষা)'),
            Container(
              padding: const EdgeInsets.all(12),
              color: AppColors.ledgerSurface,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('APP UI LANGUAGE:', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildChoiceChip(
                          label: 'English',
                          icon: Icons.check,
                          isSelected: language == AppLanguage.english,
                          onTap: () => localeNotifier.setLanguage(AppLanguage.english),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildChoiceChip(
                          label: 'বাংলা (Bengali)',
                          icon: Icons.translate,
                          isSelected: language == AppLanguage.bengali,
                          onTap: () => localeNotifier.setLanguage(AppLanguage.bengali),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 3. Recruit Entry Selection
            _buildSectionHeader(Icons.badge_outlined, 'ACTIVE RECRUIT ENTRY BATCH'),
            Container(
              padding: const EdgeInsets.all(12),
              color: AppColors.ledgerSurface,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.ledgerBorder),
                            color: Colors.white,
                          ),
                          child: DropdownButton<String>(
                            value: registerState.activeEntry,
                            isExpanded: true,
                            underline: const SizedBox(),
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
                      ),
                      const SizedBox(width: 8),
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

            // 4. Squadron Management (Add/Remove Squadrons)
            _buildSectionHeader(Icons.shield_outlined, 'SQUADRON MANAGEMENT (ADD / REMOVE)'),
            Container(
              padding: const EdgeInsets.all(12),
              color: AppColors.ledgerSurface,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'TOTAL SQUADRONS: ${squadrons.length}',
                        style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold),
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add, size: 14),
                        label: const Text('ADD SQUADRON'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.bafNavy,
                          foregroundColor: AppColors.bafGold,
                          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                        ),
                        onPressed: () => _showAddSquadronDialog(context, ref),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: squadrons.map((sqn) {
                      final roomCount = structure.getRoomsForSquadron(sqn).length;
                      return Chip(
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                        backgroundColor: sqn == activeSquadron ? AppColors.bafGold.withAlpha(50) : Colors.white,
                        side: BorderSide(
                          color: sqn == activeSquadron ? AppColors.bafGold : AppColors.ledgerBorder,
                          width: 1.2,
                        ),
                        avatar: const Icon(Icons.shield, size: 14, color: AppColors.bafNavy),
                        label: Text('$sqn ($roomCount Rooms)', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        deleteIcon: squadrons.length > 1
                            ? const Icon(Icons.close, size: 14, color: AppColors.debitRed)
                            : null,
                        onDeleted: squadrons.length > 1
                            ? () async {
                                final removed = await structureNotifier.removeSquadron(sqn);
                                if (removed && registerState.selectedSquadron == sqn) {
                                  final fallback = structure.squadrons.firstWhere((s) => s != sqn);
                                  registerNotifier.setSelectedSquadron(fallback);
                                }
                              }
                            : null,
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 5. Room Management (Per Squadron)
            _buildSectionHeader(Icons.meeting_room_outlined, 'ROOM MANAGEMENT (SEPARATE PER SQUADRON)'),
            Container(
              padding: const EdgeInsets.all(12),
              color: AppColors.ledgerSurface,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('SQUADRON: ', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.ledgerBorder),
                            color: Colors.white,
                          ),
                          child: DropdownButton<String>(
                            value: activeSquadron,
                            isExpanded: true,
                            underline: const SizedBox(),
                            items: squadrons.map((sqn) {
                              return DropdownMenuItem(value: sqn, child: Text('$sqn SQN'));
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _selectedSquadronForRooms = val);
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add, size: 14),
                        label: const Text('ADD ROOM'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.bafNavy,
                          foregroundColor: AppColors.bafGold,
                          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                        ),
                        onPressed: () => _showAddRoomDialog(context, ref, activeSquadron),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'ROOMS IN $activeSquadron SQUADRON (${roomsForActiveSqn.length} Rooms):',
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: roomsForActiveSqn.map((room) {
                      return Chip(
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: AppColors.ledgerBorder),
                        label: Text(room, style: const TextStyle(fontSize: 11)),
                        deleteIcon: roomsForActiveSqn.length > 1
                            ? const Icon(Icons.close, size: 12, color: AppColors.debitRed)
                            : null,
                        onDeleted: roomsForActiveSqn.length > 1
                            ? () => structureNotifier.removeRoom(activeSquadron, room)
                            : null,
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 6. Active Session & Logout
            _buildSectionHeader(Icons.person_pin, 'OPERATOR SESSION'),
            Container(
              padding: const EdgeInsets.all(12),
              color: AppColors.ledgerSurface,
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
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            Text(
                              '${session.user?.rank ?? ''} • ${session.user?.role ?? 'NCOIC'} (${session.user?.bdNo ?? ''})',
                              style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted),
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
                      icon: const Icon(Icons.logout, size: 16, color: AppColors.debitRed),
                      label: const Text(
                        'LOGOUT SESSION',
                        style: TextStyle(color: AppColors.debitRed, fontWeight: FontWeight.w900, fontSize: 11.5),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.debitRed, width: 1.2),
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
            const Center(
              child: Text(
                'BAF RTS Food Canteen System v1.1.0 • Tactical Ledger',
                style: TextStyle(fontSize: 9.5, color: AppColors.textMuted),
              ),
            ),
            const SizedBox(height: 20),
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
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.bafNavy : Colors.white,
          border: Border.all(
            color: isSelected ? AppColors.bafGold : AppColors.ledgerBorder,
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
              color: isSelected ? AppColors.bafGold : AppColors.textMuted,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.bold,
                color: isSelected ? AppColors.bafGold : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
