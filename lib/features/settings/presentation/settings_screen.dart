import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/locale_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/canteen_theme_extension.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/widgets/baf_rts_crest.dart';
import '../../../core/widgets/modal_action_bar.dart';
import '../../auth/models/session_user.dart';
import '../../auth/providers/operator_management_provider.dart';
import '../../auth/providers/session_provider.dart';
import '../../recruits_canteen/constants/canteen_constants.dart';
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
                      'ADD NEW SQUADRON',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SQUADRON NAME (e.g. Meghna, Jamuna):',
                          style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: theme.textPrimary),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: controller,
                          autofocus: true,
                          style: TextStyle(color: theme.textPrimary, fontSize: 13),
                          decoration: InputDecoration(
                            hintText: 'Enter squadron name',
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
          ),
        );
      },
    );
  }

  void _showAddRoomDialog(BuildContext context, WidgetRef ref, String squadron) {
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
                        Text(
                          'ROOM NAME (e.g. Room 17):',
                          style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: theme.textPrimary),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: controller,
                          autofocus: true,
                          style: TextStyle(color: theme.textPrimary, fontSize: 13),
                          decoration: InputDecoration(
                            hintText: 'Enter room name',
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
          ),
        );
      },
    );
  }

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
                      'CREATE NEW RECRUIT ENTRY BATCH',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11.5),
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

  void _confirmRemoveSquadron(BuildContext context, WidgetRef ref, String sqn, VoidCallback onConfirmed) {
    final theme = context.canteenTheme;
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: theme.cardBackground,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          title: Text(
            'CONFIRM SQUADRON REMOVAL',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: theme.debit),
          ),
          content: Text(
            'Are you sure you want to remove "$sqn Squadron" and all its assigned rooms? This action cannot be undone.',
            style: TextStyle(fontSize: 12, color: theme.textPrimary),
          ),
          actions: [
            ModalActionBar(
              cancelLabel: 'CANCEL',
              confirmLabel: 'REMOVE SQUADRON',
              confirmColor: theme.debit,
              confirmTextColor: Colors.white,
              confirmIcon: Icons.delete_forever,
              onCancel: () => Navigator.of(ctx).pop(),
              onConfirm: () {
                Navigator.of(ctx).pop();
                onConfirmed();
              },
            ),
          ],
        );
      },
    );
  }

  void _confirmRemoveRoom(BuildContext context, WidgetRef ref, String squadron, String room, VoidCallback onConfirmed) {
    final theme = context.canteenTheme;
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: theme.cardBackground,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          title: Text(
            'CONFIRM ROOM REMOVAL',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: theme.debit),
          ),
          content: Text(
            'Are you sure you want to remove "$room" from $squadron Squadron?',
            style: TextStyle(fontSize: 12, color: theme.textPrimary),
          ),
          actions: [
            ModalActionBar(
              cancelLabel: 'CANCEL',
              confirmLabel: 'REMOVE ROOM',
              confirmColor: theme.debit,
              confirmTextColor: Colors.white,
              confirmIcon: Icons.delete,
              onCancel: () => Navigator.of(ctx).pop(),
              onConfirm: () {
                Navigator.of(ctx).pop();
                onConfirmed();
              },
            ),
          ],
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

    final theme = context.canteenTheme;
    final squadrons = structure.squadrons;
    final activeSquadron = _selectedSquadronForRooms != null && squadrons.contains(_selectedSquadronForRooms)
        ? _selectedSquadronForRooms!
        : (squadrons.isNotEmpty ? squadrons.first : 'Sadruddin');
    final roomsForActiveSqn = structure.getRoomsForSquadron(activeSquadron);

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

            // 2. Language Selection (English / Bengali)
            _buildSectionHeader(Icons.language, 'LANGUAGE (ভাষা)'),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.cardBackground,
                border: Border.all(color: theme.cardBorderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('APP UI LANGUAGE:', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: theme.textPrimary)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildChoiceChip(
                          label: 'English',
                          icon: Icons.check,
                          isSelected: language == AppLanguage.english,
                          onTap: () => localeNotifier.setLanguage(AppLanguage.english),
                          theme: theme,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildChoiceChip(
                          label: 'বাংলা (Bengali)',
                          icon: Icons.translate,
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

            // 3. Recruit Entry Selection
            _buildSectionHeader(Icons.badge_outlined, 'ACTIVE RECRUIT ENTRY BATCH'),
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
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                          decoration: BoxDecoration(
                            border: Border.all(color: theme.cardBorder),
                            color: theme.surface,
                          ),
                          child: DropdownButton<String>(
                            value: registerState.activeEntry,
                            isExpanded: true,
                            underline: const SizedBox(),
                            dropdownColor: theme.cardBackground,
                            style: TextStyle(color: theme.textPrimary, fontWeight: FontWeight.bold, fontSize: 12),
                            items: registerState.allEntries.map((e) {
                              return DropdownMenuItem(value: e, child: Text('Entry $e', style: TextStyle(color: theme.textPrimary)));
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
              decoration: BoxDecoration(
                color: theme.cardBackground,
                border: Border.all(color: theme.cardBorderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'TOTAL SQUADRONS: ${squadrons.length}',
                        style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: theme.textPrimary),
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
                        backgroundColor: sqn == activeSquadron ? AppColors.bafGold.withAlpha(50) : theme.surface,
                        side: BorderSide(
                          color: sqn == activeSquadron ? AppColors.bafGold : theme.cardBorder,
                          width: 1.2,
                        ),
                        avatar: const Icon(Icons.shield, size: 14, color: AppColors.bafGold),
                        label: Text('$sqn ($roomCount Rooms)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: theme.textPrimary)),
                        deleteIcon: squadrons.length > 1
                            ? Icon(Icons.close, size: 14, color: theme.debit)
                            : null,
                        onDeleted: squadrons.length > 1
                            ? () {
                                _confirmRemoveSquadron(context, ref, sqn, () async {
                                  final removed = await structureNotifier.removeSquadron(sqn);
                                  if (removed && registerState.selectedSquadron == sqn) {
                                    final fallback = structure.squadrons.firstWhere((s) => s != sqn);
                                    registerNotifier.setSelectedSquadron(fallback);
                                  }
                                });
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
              decoration: BoxDecoration(
                color: theme.cardBackground,
                border: Border.all(color: theme.cardBorderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('SQUADRON: ', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: theme.textPrimary)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                          decoration: BoxDecoration(
                            border: Border.all(color: theme.cardBorder),
                            color: theme.surface,
                          ),
                          child: DropdownButton<String>(
                            value: activeSquadron,
                            isExpanded: true,
                            underline: const SizedBox(),
                            dropdownColor: theme.cardBackground,
                            style: TextStyle(color: theme.textPrimary, fontWeight: FontWeight.bold, fontSize: 12),
                            items: squadrons.map((sqn) {
                              return DropdownMenuItem(value: sqn, child: Text('$sqn SQN', style: TextStyle(color: theme.textPrimary)));
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
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: theme.textSecondary),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: roomsForActiveSqn.map((room) {
                      return Chip(
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                        backgroundColor: theme.surface,
                        side: BorderSide(color: theme.cardBorder),
                        label: Text(room, style: TextStyle(fontSize: 11, color: theme.textPrimary)),
                        deleteIcon: roomsForActiveSqn.length > 1
                            ? Icon(Icons.close, size: 12, color: theme.debit)
                            : null,
                        onDeleted: roomsForActiveSqn.length > 1
                            ? () {
                                _confirmRemoveRoom(context, ref, activeSquadron, room, () {
                                  structureNotifier.removeRoom(activeSquadron, room);
                                });
                              }
                            : null,
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 6. Canteen Duty Appointments
            _buildSectionHeader(Icons.military_tech, 'CANTEEN DUTY APPOINTMENTS'),
            _buildOperatorManagementSection(context, ref, theme, session),
            const SizedBox(height: 14),

            // 7. Active Session & Logout
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

  Widget _buildOperatorManagementSection(
    BuildContext context,
    WidgetRef ref,
    CanteenThemeColors theme,
    SessionState session,
  ) {
    final opState = ref.watch(operatorManagementProvider);
    final currentRole = session.user?.role ?? '';
    final currentUserId = session.user?.id;
    final currentUsername = session.user?.username ?? '';

    // Extract NCOIC and JCOIC operators
    final ncoic = opState.operators.where((u) => u.role == 'NCOIC').firstOrNull;
    final jcoic = opState.operators.where((u) => u.role == 'JCOIC').firstOrNull;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardBackground,
        border: Border.all(color: theme.cardBorderLight),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'DUTY IN-CHARGE APPOINTMENTS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: theme.textPrimary,
                  letterSpacing: 0.5,
                ),
              ),
              InkWell(
                onTap: () => ref.read(operatorManagementProvider.notifier).fetchOperators(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Row(
                    children: [
                      Icon(Icons.sync, size: 13, color: theme.accentGold),
                      const SizedBox(width: 3),
                      Text(
                        'REFRESH',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: theme.accentGold),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Appointed military personnel responsible for daily ledger maintenance, spending entries, and collections.',
            style: TextStyle(fontSize: 10, color: theme.textSecondary),
          ),
          const SizedBox(height: 12),

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
            canRemove: true,
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
            canRemove: true,
          ),
          const SizedBox(height: 12),

          // Status Notice or Appoint Button
          if (opState.isFullyStaffed)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: theme.surface,
                border: Border.all(color: theme.cardBorder),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_outline, size: 16, color: AppColors.bafRoundelGreen),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Both NCOIC and JCOIC positions are appointed and active.',
                      style: TextStyle(fontSize: 10.5, color: theme.textSecondary, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            )
          else if (opState.vacantRole != null)
            SizedBox(
              height: 38,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.person_add_alt_1, size: 16),
                label: Text(
                  'APPOINT ${opState.vacantRole} IN-CHARGE',
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.5),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.bafGold,
                  foregroundColor: AppColors.bafNavy,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
                onPressed: () => _showEnrollOperatorDialog(context, ref, opState.vacantRole!),
              ),
            ),
        ],
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
    required bool canRemove,
  }) {
    final isVacant = operator == null;
    final isSelf = !isVacant &&
        ((operator.id != null && operator.id == currentUserId) ||
            operator.username.toLowerCase() == currentUsername.toLowerCase());

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: theme.surface,
        border: Border.all(
          color: isVacant ? theme.cardBorderLight : theme.accentGold.withValues(alpha: 0.5),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(4),
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
                  style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  roleTitle,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: theme.textSecondary),
                ),
              ),
              if (isSelf)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.bafRoundelGreen.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: const Text(
                    'CURRENT USER',
                    style: TextStyle(color: AppColors.bafRoundelGreen, fontSize: 8.5, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (isVacant)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Position vacant — No in-charge currently assigned.',
                    style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: theme.textSecondary),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _showEnrollOperatorDialog(context, ref, roleTag),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.bafGold,
                    foregroundColor: AppColors.bafNavy,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
                  ),
                  child: Text(
                    '+ Appoint $roleTag',
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900),
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
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: theme.textPrimary),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${operator.rank} • BD No: ${operator.bdNo}${operator.trade != null ? ' • ${operator.trade}' : ''}',
                        style: TextStyle(fontSize: 10.5, color: theme.textSecondary),
                      ),
                      Text(
                        'Login ID: ${operator.username}',
                        style: TextStyle(fontSize: 9.5, color: theme.textMuted),
                      ),
                    ],
                  ),
                ),
                OutlinedButton.icon(
                  icon: Icon(Icons.person_remove_outlined, size: 14, color: theme.debit),
                  label: Text(
                    'Remove',
                    style: TextStyle(color: theme.debit, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: theme.debit),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
                  ),
                  onPressed: () => _confirmRemoveOperator(context, ref, operator),
                ),
              ],
            ),
        ],
      ),
    );
  }

  void _confirmRemoveOperator(BuildContext context, WidgetRef ref, SessionUser target) {
    final theme = context.canteenTheme;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: theme.debit, size: 22),
            const SizedBox(width: 8),
            Text(
              'Remove ${target.role} Appointment?',
              style: TextStyle(color: theme.textPrimary, fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          'Remove ${target.rank} ${target.name} (${target.bdNo}) from ${target.role} duty? The position will become vacant until a new in-charge is appointed.',
          style: TextStyle(color: theme.textSecondary, fontSize: 11.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('CANCEL', style: TextStyle(color: theme.textSecondary, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.debit,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              final targetId = target.id ?? target.username;
              final success = await ref.read(operatorManagementProvider.notifier).removeOperator(targetId);
              if (context.mounted) {
                final opState = ref.read(operatorManagementProvider);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success
                        ? (opState.successMessage ?? 'Appointment removed')
                        : (opState.errorMessage ?? 'Removal failed')),
                    backgroundColor: success ? AppColors.bafRoundelGreen : theme.debit,
                  ),
                );
              }
            },
            child: const Text('REMOVE APPOINTMENT', style: TextStyle(fontWeight: FontWeight.bold)),
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
                    borderRadius: BorderRadius.circular(6),
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
                              const Icon(Icons.person_add_alt_1, color: AppColors.bafGold, size: 18),
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
                              Text(
                                'FULL NAME:',
                                style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: theme.textPrimary),
                              ),
                              const SizedBox(height: 4),
                              TextField(
                                controller: nameCtrl,
                                style: TextStyle(color: theme.textPrimary, fontSize: 13),
                                decoration: InputDecoration(
                                  hintText: 'e.g. Humayun Kabir',
                                  filled: true,
                                  fillColor: theme.surface,
                                  isDense: true,
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide(color: theme.cardBorder)),
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
                                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide(color: theme.cardBorder)),
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
                                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide(color: theme.cardBorder)),
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
                                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide(color: theme.cardBorder)),
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
                                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide(color: theme.cardBorder)),
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
                                  hintText: 'Enter secure password (min 6 chars)',
                                  filled: true,
                                  fillColor: theme.surface,
                                  isDense: true,
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide(color: theme.cardBorder)),
                                ),
                              ),
                              const SizedBox(height: 18),
                              ModalActionBar(
                                cancelLabel: 'CANCEL',
                                confirmLabel: 'APPOINT $role',
                                onCancel: () => Navigator.of(ctx).pop(),
                                onConfirm: () async {
                                  final name = nameCtrl.text.trim();
                                  final username = usernameCtrl.text.trim();
                                  final bdNo = bdNoCtrl.text.trim();
                                  final trade = tradeCtrl.text.trim();
                                  final pass = passCtrl.text.trim();

                                  if (name.isEmpty || username.isEmpty || bdNo.isEmpty || pass.length < 6) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Please fill all fields properly (password min 6 chars)')),
                                    );
                                    return;
                                  }

                                  final success = await ref.read(operatorManagementProvider.notifier).enrollOperator(
                                    username: username,
                                    name: name,
                                    rank: selectedRank,
                                    bdNo: bdNo,
                                    trade: trade.isNotEmpty ? trade : null,
                                    password: pass,
                                    role: role,
                                  );

                                  if (ctx.mounted) {
                                    Navigator.of(ctx).pop();
                                    final opState = ref.read(operatorManagementProvider);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(success
                                            ? (opState.successMessage ?? 'Appointed successfully')
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
}
