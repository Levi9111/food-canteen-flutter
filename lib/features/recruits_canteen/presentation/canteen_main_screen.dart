import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/animations/smooth_transitions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/baf_rts_crest.dart';
import '../../../../core/widgets/modal_action_bar.dart';
import '../../../../core/widgets/rts_bottom_nav_bar.dart';
import '../../audit/presentation/monthly_audit_view.dart';
import '../../p_staff_canteen/presentation/widgets/p_staff_daily_entry_view.dart';
import '../../p_staff_canteen/presentation/widgets/p_staff_monthly_matrix_view.dart';
import '../../p_staff_canteen/presentation/widgets/p_staff_spreadsheet_view.dart';
import '../../p_staff_canteen/providers/p_staff_register_provider.dart';
import '../../settings/presentation/settings_screen.dart';
import '../constants/canteen_constants.dart';
import '../providers/canteen_register_provider.dart';
import 'widgets/daily_entry_view.dart';
import 'widgets/monthly_matrix_view.dart';

enum CanteenCustomerGroup { recruits, pStaff }

class CanteenMainScreen extends ConsumerStatefulWidget {
  const CanteenMainScreen({super.key});

  @override
  ConsumerState<CanteenMainScreen> createState() => _CanteenMainScreenState();
}

class _CanteenMainScreenState extends ConsumerState<CanteenMainScreen> {
  CanteenCustomerGroup _currentGroup = CanteenCustomerGroup.recruits;
  int _recruitsIndex = 0;
  int _pStaffIndex = 0;

  void _showNewEntryDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();

    showSmoothMilitaryDialog(
      context: context,
      child: Dialog(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        child: Container(
          width: 360,
          decoration: BoxDecoration(
            color: AppColors.ledgerSurface,
            border: Border.all(color: AppColors.bafNavy, width: 2),
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
                    const Text(
                      'ENTRY BATCH NUMBER (e.g. 55, 56):',
                      style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: controller,
                      keyboardType: TextInputType.number,
                      autofocus: true,
                      decoration: const InputDecoration(
                        hintText: 'Enter batch number',
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ModalActionBar(
                      cancelLabel: 'CANCEL',
                      confirmLabel: 'CREATE BATCH',
                      onCancel: () => Navigator.of(context).pop(),
                      onConfirm: () {
                        final val = controller.text.trim();
                        if (val.isNotEmpty) {
                          ref.read(canteenRegisterProvider.notifier).addNewEntry(val);
                        }
                        Navigator.of(context).pop();
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
  }

  void _showContextSettingsModal(BuildContext context, WidgetRef ref) {
    final state = ref.read(canteenRegisterProvider);
    final notifier = ref.read(canteenRegisterProvider.notifier);
    final staffNotifier = ref.read(pStaffRegisterProvider.notifier);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      backgroundColor: AppColors.ledgerSurface,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: AppColors.bafGold, width: 2)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'SESSION & DUTY PARAMETERS',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.6,
                      color: AppColors.bafNavy,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 6),
              const Text('ACTIVE RECRUIT ENTRY BATCH', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textMuted)),
              const SizedBox(height: 6),
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
                        value: state.activeEntry,
                        isExpanded: true,
                        underline: const SizedBox(),
                        items: state.allEntries.map((e) {
                          return DropdownMenuItem(value: e, child: Text('Entry $e'));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            notifier.setActiveEntry(val);
                            Navigator.pop(ctx);
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
                      backgroundColor: AppColors.bafDeepBlue,
                      foregroundColor: Colors.white,
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _showNewEntryDialog(context, ref);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Text('DUTY IN-CHARGE OFFICER', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textMuted)),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: _buildManagerSelectTile(
                      title: 'SGT (NCOIC)',
                      subtitle: 'Sergeant In-Charge',
                      isSelected: state.activeManager == CanteenConstants.roleNcoic,
                      onTap: () {
                        notifier.setActiveManager(CanteenConstants.roleNcoic);
                        staffNotifier.setActiveManager(CanteenConstants.roleNcoic);
                        Navigator.pop(ctx);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildManagerSelectTile(
                      title: 'WO (JCOIC)',
                      subtitle: 'Warrant Officer In-Charge',
                      isSelected: state.activeManager == CanteenConstants.roleJcoic,
                      onTap: () {
                        notifier.setActiveManager(CanteenConstants.roleJcoic);
                        staffNotifier.setActiveManager(CanteenConstants.roleJcoic);
                        Navigator.pop(ctx);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildManagerSelectTile({
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.bafNavy : Colors.white,
          border: Border.all(
            color: isSelected ? AppColors.bafGold : AppColors.ledgerBorder,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isSelected ? AppColors.bafGold : AppColors.bafNavy,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 9,
                color: isSelected ? Colors.white70 : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(canteenRegisterProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final isMobile = screenWidth < 800;

        return Scaffold(
          backgroundColor: AppColors.ledgerBackground,
          // Bottom Navigation Bar with BAF military styling
          bottomNavigationBar: RtsBottomNavBar(
            currentIndex: _currentGroup == CanteenCustomerGroup.recruits ? _recruitsIndex : _pStaffIndex,
            isRecruitsGroup: _currentGroup == CanteenCustomerGroup.recruits,
            onDestinationSelected: (idx) {
              setState(() {
                if (_currentGroup == CanteenCustomerGroup.recruits) {
                  _recruitsIndex = idx;
                } else {
                  _pStaffIndex = idx;
                }
              });
            },
          ),
          body: SafeArea(
            child: Column(
              children: [
                // 1. Command Masthead with BAF crest, title, context chip, and settings icon
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 10 : 16,
                    vertical: isMobile ? 6 : 8,
                  ),
                  decoration: const BoxDecoration(
                    color: AppColors.bafNavy,
                    border: Border(
                      bottom: BorderSide(color: AppColors.bafGold, width: 1.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Official BAF Emblem Crest (Transparent Background)
                      BafRtsCrest(size: isMobile ? 32 : 38),
                      const SizedBox(width: 8),

                      // Title & Subtitle
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    'FOOD CANTEEN, RTS',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: isMobile ? 13 : 15,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                  color: AppColors.bafRoundelGreen,
                                  child: const Text(
                                    'BAF',
                                    style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              'Recruits Training School • Shamshernagar',
                              style: TextStyle(
                                color: Colors.white.withAlpha(180),
                                fontSize: isMobile ? 8.5 : 10,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Context Capsule
                      InkWell(
                        onTap: () => _showContextSettingsModal(context, ref),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.bafDeepBlue,
                            border: Border.all(color: AppColors.bafGold.withAlpha(180), width: 1),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _currentGroup == CanteenCustomerGroup.recruits
                                        ? 'ENTRY ${state.activeEntry}'
                                        : 'P-STAFF',
                                    style: const TextStyle(
                                      color: AppColors.bafGold,
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    state.activeManager,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 8.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.arrow_drop_down, color: AppColors.bafGold, size: 16),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),

                      // Header Settings Icon
                      IconButton(
                        icon: const Icon(Icons.settings_outlined, color: AppColors.bafGold, size: 22),
                        tooltip: 'Settings & Structure',
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const SettingsScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // 2. Customer Group Switcher (Recruits Room-Wise vs Permanent Staffs Individual)
                Container(
                  color: AppColors.bafDeepBlue,
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Row(
                    children: [
                      // Recruits Canteen Tab Button
                      Expanded(
                        child: InkWell(
                          onTap: () => setState(() => _currentGroup = CanteenCustomerGroup.recruits),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 5.5),
                            decoration: BoxDecoration(
                              color: _currentGroup == CanteenCustomerGroup.recruits ? AppColors.bafGold : Colors.transparent,
                              border: Border.all(
                                color: _currentGroup == CanteenCustomerGroup.recruits ? AppColors.bafGold : AppColors.bafGold.withAlpha(80),
                                width: 1,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.groups,
                                  size: 13,
                                  color: _currentGroup == CanteenCustomerGroup.recruits ? AppColors.bafNavy : Colors.white,
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    isMobile ? 'RECRUITS' : '1. RECRUITS CANTEEN (ROOM-WISE)',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: _currentGroup == CanteenCustomerGroup.recruits ? AppColors.bafNavy : Colors.white,
                                      fontWeight: FontWeight.w900,
                                      fontSize: isMobile ? 9.5 : 11,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      // P-Staffs Canteen Tab Button
                      Expanded(
                        child: InkWell(
                          onTap: () => setState(() => _currentGroup = CanteenCustomerGroup.pStaff),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 5.5, horizontal: 4),
                            decoration: BoxDecoration(
                              color: _currentGroup == CanteenCustomerGroup.pStaff ? AppColors.bafGold : Colors.transparent,
                              border: Border.all(
                                color: _currentGroup == CanteenCustomerGroup.pStaff ? AppColors.bafGold : AppColors.bafGold.withAlpha(80),
                                width: 1,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.badge,
                                  size: 13,
                                  color: _currentGroup == CanteenCustomerGroup.pStaff ? AppColors.bafNavy : Colors.white,
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    isMobile ? 'P-STAFFS' : '2. P-STAFFS CANTEEN (INDIVIDUAL)',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: _currentGroup == CanteenCustomerGroup.pStaff ? AppColors.bafNavy : Colors.white,
                                      fontWeight: FontWeight.w900,
                                      fontSize: isMobile ? 9.5 : 11,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 3. Main Views Stack (Clean IndexedStack: Zero horizontal scroll conflict & preserved state)
                Expanded(
                  child: _currentGroup == CanteenCustomerGroup.recruits
                      ? IndexedStack(
                          index: _recruitsIndex,
                          children: const [
                            DailyEntryView(),
                            MonthlyMatrixView(),
                            MonthlyAuditView(),
                          ],
                        )
                      : IndexedStack(
                          index: _pStaffIndex,
                          children: const [
                            PStaffDailyEntryView(),
                            PStaffMonthlyMatrixView(),
                            PStaffSpreadsheetView(),
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
}
