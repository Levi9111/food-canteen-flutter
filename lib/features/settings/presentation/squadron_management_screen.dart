import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/canteen_theme_extension.dart';
import '../../../core/widgets/modal_action_bar.dart';
import '../../recruits_canteen/constants/canteen_constants.dart';
import '../../recruits_canteen/providers/canteen_register_provider.dart';
import '../../recruits_canteen/providers/canteen_structure_provider.dart';

class SquadronManagementScreen extends ConsumerStatefulWidget {
  const SquadronManagementScreen({super.key});

  @override
  ConsumerState<SquadronManagementScreen> createState() => _SquadronManagementScreenState();
}

class _SquadronManagementScreenState extends ConsumerState<SquadronManagementScreen> {
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
              width: 420,
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
                    child: const Row(
                      children: [
                        Icon(Icons.shield, color: AppColors.bafGold, size: 16),
                        SizedBox(width: 8),
                        Text(
                          'ADD NEW SQUADRON TO CANTEEN',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Notice banner
                        Container(
                          padding: const EdgeInsets.all(10),
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: theme.surface,
                            border: Border.all(color: theme.cardBorder),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline, size: 16, color: theme.accentGold),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'A newly added squadron is automatically initialized with 16 rooms and registered in the database.',
                                  style: TextStyle(fontSize: 10, color: theme.textSecondary),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          'SQUADRON NAME (e.g. Padma, Meghna):',
                          style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: theme.textPrimary),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: controller,
                          autofocus: true,
                          style: TextStyle(color: theme.textPrimary, fontSize: 13),
                          decoration: InputDecoration(
                            hintText: 'Enter new squadron name',
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
                                if (success) {
                                  setState(() => _selectedSquadronForRooms = val);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Squadron "$val" created with 16 rooms successfully')),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Squadron already exists or name is invalid')),
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

  void _showRenameSquadronDialog(BuildContext context, WidgetRef ref, String oldSquadron) {
    final controller = TextEditingController(text: oldSquadron);
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
              width: 440,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: theme.cardBackground,
                border: Border.all(color: theme.debit, width: 2),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    color: theme.debit,
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'RENAME SQUADRON: $oldSquadron',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // STRICT WARNING BANNER
                        Container(
                          padding: const EdgeInsets.all(10),
                          margin: const EdgeInsets.only(bottom: 14),
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
                                    'CRITICAL CASCADE WARNING',
                                    style: TextStyle(
                                      color: theme.debit,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 10.5,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Renaming "$oldSquadron" will cascade-update all past expense ledgers, monthly closings, and payment records in the database. This action permanently changes historical references.',
                                style: TextStyle(
                                  color: theme.textPrimary,
                                  fontSize: 10,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          'NEW SQUADRON NAME:',
                          style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: theme.textPrimary),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: controller,
                          autofocus: true,
                          style: TextStyle(color: theme.textPrimary, fontSize: 13),
                          decoration: InputDecoration(
                            hintText: 'Enter new squadron name',
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
                          confirmLabel: 'CONFIRM CASCADE RENAME',
                          confirmColor: theme.debit,
                          confirmTextColor: Colors.white,
                          onCancel: () => Navigator.of(ctx).pop(),
                          onConfirm: () async {
                            final val = controller.text.trim();
                            if (val.isNotEmpty) {
                              final success = await ref.read(canteenStructureProvider.notifier).updateSquadronName(oldSquadron, val);
                              if (ctx.mounted) {
                                Navigator.of(ctx).pop();
                                if (success) {
                                  if (_selectedSquadronForRooms == oldSquadron) {
                                    setState(() => _selectedSquadronForRooms = val);
                                  }
                                  final regState = ref.read(canteenRegisterProvider);
                                  if (regState.selectedSquadron == oldSquadron) {
                                    ref.read(canteenRegisterProvider.notifier).setSelectedSquadron(val);
                                  }
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Squadron updated from $oldSquadron to $val successfully')),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Squadron name already exists or invalid')),
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

  void _confirmRemoveSquadron(BuildContext context, WidgetRef ref, String squadron, VoidCallback onConfirmed) {
    final theme = context.canteenTheme;
    final structure = ref.read(canteenStructureProvider);
    final roomCount = structure.getRoomsForSquadron(squadron).length;

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: theme.cardBackground,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          title: Row(
            children: [
              Icon(Icons.dangerous_rounded, color: theme.debit, size: 22),
              const SizedBox(width: 8),
              Text(
                'CONFIRM SQUADRON DEACTIVATION',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: theme.debit),
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
                child: Text(
                  'STRICT WARNING: Deactivating "$squadron" will remove its $roomCount rooms from active daily ledger entries. Active batch balances must be reconciled first.',
                  style: TextStyle(fontSize: 11, color: theme.textPrimary, height: 1.35),
                ),
              ),
              Text(
                'Are you completely sure you want to deactivate and remove "$squadron" Squadron?',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: theme.textPrimary),
              ),
            ],
          ),
          actions: [
            ModalActionBar(
              cancelLabel: 'CANCEL',
              confirmLabel: 'DEACTIVATE SQUADRON',
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
                                if (success) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Added $val to $squadron Squadron successfully')),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Room already exists in this squadron or invalid')),
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

  void _confirmRemoveRoom(BuildContext context, WidgetRef ref, String squadron, String room, VoidCallback onConfirmed) {
    final theme = context.canteenTheme;
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: theme.cardBackground,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: theme.debit, size: 20),
              const SizedBox(width: 8),
              Text(
                'CONFIRM ROOM REMOVAL',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: theme.debit),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: theme.debit.withValues(alpha: 0.1),
                  border: Border.all(color: theme.debit.withValues(alpha: 0.6)),
                ),
                child: Text(
                  'WARNING: Removing "$room" prevents new daily expenses from being entered for this room. Ensure all dues are closed.',
                  style: TextStyle(fontSize: 10.5, color: theme.textPrimary, height: 1.3),
                ),
              ),
              Text(
                'Are you sure you want to remove "$room" from $squadron Squadron?',
                style: TextStyle(fontSize: 12, color: theme.textPrimary),
              ),
            ],
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

  @override
  Widget build(BuildContext context) {
    final structure = ref.watch(canteenStructureProvider);
    final structureNotifier = ref.read(canteenStructureProvider.notifier);
    final registerState = ref.watch(canteenRegisterProvider);
    final registerNotifier = ref.read(canteenRegisterProvider.notifier);
    final theme = context.canteenTheme;
    final squadrons = structure.squadrons;

    final activeSquadron = _selectedSquadronForRooms != null && squadrons.contains(_selectedSquadronForRooms)
        ? _selectedSquadronForRooms!
        : (squadrons.isNotEmpty ? squadrons.first : (CanteenConstants.squadrons.first));
    final roomsForActiveSqn = structure.getRoomsForSquadron(activeSquadron);

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        backgroundColor: AppColors.bafNavy,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'SQUADRON & ROOM MANAGEMENT',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 0.5, color: Colors.white),
        ),
        elevation: 0,
        shape: const Border(bottom: BorderSide(color: AppColors.bafGold, width: 1.5)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // STRICT TOP BANNER
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.debit.withValues(alpha: 0.08),
                border: Border.all(color: theme.debit.withValues(alpha: 0.5), width: 1.5),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.shield_outlined, color: theme.debit, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'MILITARY LEDGER STRUCTURE DIRECTIVE',
                          style: TextStyle(
                            color: theme.debit,
                            fontWeight: FontWeight.w900,
                            fontSize: 11,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Squadron designations and room layouts define the accounting architecture of recruit batches. Renaming or deactivating squadrons directly impacts active and historical ledger reports.',
                          style: TextStyle(
                            color: theme.textPrimary,
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

            // SQUADRON SECTION
            _buildSectionHeader(Icons.shield_outlined, 'CONFIGURED SQUADRONS (${squadrons.length})'),
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
                  const SizedBox(height: 10),
                  Column(
                    children: squadrons.map((sqn) {
                      final roomCount = structure.getRoomsForSquadron(sqn).length;
                      final isSelected = sqn == activeSquadron;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.bafGold.withAlpha(25) : theme.surface,
                          border: Border.all(
                            color: isSelected ? AppColors.bafGold : theme.cardBorder,
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.shield, size: 16, color: isSelected ? AppColors.bafGold : theme.accentGold),
                            const SizedBox(width: 10),
                            Expanded(
                              child: InkWell(
                                onTap: () => setState(() => _selectedSquadronForRooms = sqn),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          sqn,
                                          style: TextStyle(
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.bold,
                                            color: theme.textPrimary,
                                          ),
                                        ),
                                        if (isSelected) ...[
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                            color: AppColors.bafGold,
                                            child: const Text(
                                              'ACTIVE',
                                              style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w900, color: AppColors.bafNavy),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    Text(
                                      '$roomCount Rooms configured • Tap to manage rooms',
                                      style: TextStyle(fontSize: 10, color: theme.textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Rename Squadron Button
                            IconButton(
                              icon: Icon(Icons.edit_outlined, size: 18, color: theme.accentGold),
                              tooltip: 'Rename Squadron (Strict Cascade)',
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                              onPressed: () => _showRenameSquadronDialog(context, ref, sqn),
                            ),
                            // Delete Squadron Button
                            if (squadrons.length > 1)
                              IconButton(
                                icon: Icon(Icons.delete_outline, size: 18, color: theme.debit),
                                tooltip: 'Deactivate Squadron',
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                onPressed: () {
                                  _confirmRemoveSquadron(context, ref, sqn, () async {
                                    final removed = await structureNotifier.removeSquadron(sqn);
                                    if (removed) {
                                      if (activeSquadron == sqn) {
                                        final fallback = structure.squadrons.firstWhere((s) => s != sqn);
                                        setState(() => _selectedSquadronForRooms = fallback);
                                      }
                                      if (registerState.selectedSquadron == sqn) {
                                        final fallback = structure.squadrons.firstWhere((s) => s != sqn);
                                        registerNotifier.setSelectedSquadron(fallback);
                                      }
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Deactivated $sqn Squadron')),
                                        );
                                      }
                                    }
                                  });
                                },
                              ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // ROOM SECTION
            _buildSectionHeader(Icons.meeting_room_outlined, 'ROOM MANAGEMENT ($activeSquadron SQUADRON)'),
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
                      Text('SELECT SQUADRON: ', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: theme.textPrimary)),
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
                                _confirmRemoveRoom(context, ref, activeSquadron, room, () async {
                                  final removed = await structureNotifier.removeRoom(activeSquadron, room);
                                  if (removed && context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Removed $room from $activeSquadron Squadron')),
                                    );
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
          ],
        ),
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
