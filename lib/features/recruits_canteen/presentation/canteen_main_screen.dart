import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/canteen_theme_extension.dart';
import '../../../../core/widgets/baf_rts_crest.dart';
import '../../../../core/widgets/rts_bottom_nav_bar.dart';
import '../../audit/presentation/monthly_audit_view.dart';
import '../../p_staff_canteen/presentation/widgets/p_staff_daily_entry_view.dart';
import '../../p_staff_canteen/presentation/widgets/p_staff_monthly_matrix_view.dart';
import '../../p_staff_canteen/presentation/widgets/p_staff_spreadsheet_view.dart';
import '../../settings/presentation/settings_screen.dart';
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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(canteenRegisterProvider);
    final theme = context.canteenTheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final isMobile = screenWidth < 800;

        return Scaffold(
          backgroundColor: theme.background,
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
                // 1. Consolidated Command Masthead
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 10 : 16,
                    vertical: isMobile ? 6 : 8,
                  ),
                  decoration: BoxDecoration(
                    color: theme.headerBackground,
                    border: Border(
                      bottom: BorderSide(color: theme.accentGold, width: 1.5),
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
                                      color: theme.textOnHeader,
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
                                color: theme.textOnHeader.withAlpha(180),
                                fontSize: isMobile ? 8.5 : 10,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Context Quick Badge (Taps directly to Settings)
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const SettingsScreen()),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: theme.headerSub,
                            border: Border.all(color: theme.accentGold.withAlpha(180), width: 1),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _currentGroup == CanteenCustomerGroup.recruits
                                    ? 'ENTRY ${state.activeEntry}'
                                    : 'P-STAFF',
                                style: TextStyle(
                                  color: theme.accentGold,
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                state.activeManager,
                                style: TextStyle(
                                  color: theme.textOnHeader,
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),

                      // Header Settings Icon (Full 48x48 Accessibility Target)
                      IconButton(
                        icon: const Icon(Icons.settings_outlined, color: AppColors.bafGold, size: 22),
                        tooltip: 'Settings & Structure',
                        constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
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
