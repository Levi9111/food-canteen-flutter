import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/animations/smooth_transitions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/baf_rts_crest.dart';
import '../../audit/presentation/monthly_audit_view.dart';
import '../constants/canteen_constants.dart';
import '../providers/canteen_register_provider.dart';
import 'widgets/daily_entry_view.dart';
import 'widgets/monthly_matrix_view.dart';
import 'widgets/room_soft_spreadsheet_view.dart';

class CanteenMainScreen extends ConsumerStatefulWidget {
  const CanteenMainScreen({super.key});

  @override
  ConsumerState<CanteenMainScreen> createState() => _CanteenMainScreenState();
}

class _CanteenMainScreenState extends ConsumerState<CanteenMainScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 4,
      vsync: this,
      animationDuration: const Duration(milliseconds: 240),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('CANCEL'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            final val = controller.text.trim();
                            if (val.isNotEmpty) {
                              ref.read(canteenRegisterProvider.notifier).addNewEntry(val);
                            }
                            Navigator.of(context).pop();
                          },
                          child: const Text('CREATE BATCH'),
                        ),
                      ],
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
                    'SESSION PARAMETERS',
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
          body: SafeArea(
            child: Column(
              children: [
                // Streamlined, Compact Tactical Masthead (Reduced from 160px down to ~52px)
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
                      // Official BAF Emblem Crest
                      BafRtsCrest(size: isMobile ? 32 : 38),
                      const SizedBox(width: 8),

                      // App Title
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

                      // Quick Tactical Batch & Duty Capsule (Tappable to modify)
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
                                    'ENTRY ${state.activeEntry}',
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
                    ],
                  ),
                ),

                // Sharp, Sleek Tactical Tab Bar (Zero Curves, Gold Accent)
                Container(
                  decoration: const BoxDecoration(
                    color: AppColors.bafNavy,
                    border: Border(bottom: BorderSide(color: AppColors.ledgerBorder, width: 1)),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: false,
                    indicatorColor: AppColors.bafGold,
                    indicatorWeight: 3.0,
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: AppColors.bafGold,
                    unselectedLabelColor: Colors.white70,
                    labelPadding: EdgeInsets.zero,
                    labelStyle: TextStyle(
                      fontSize: isMobile ? 10 : 11.5,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                    tabs: [
                      Tab(icon: const Icon(Icons.menu_book, size: 15), text: isMobile ? 'REGISTER' : '1. DAILY REGISTER'),
                      Tab(icon: const Icon(Icons.grid_on, size: 15), text: isMobile ? 'MATRIX' : '2. MONTHLY MATRIX'),
                      Tab(icon: const Icon(Icons.table_chart, size: 15), text: isMobile ? 'SPREADSHEET' : '3. ROOM SOFT SPREADSHEET'),
                      Tab(icon: const Icon(Icons.verified, size: 15), text: isMobile ? 'AUDIT' : '4. AUDIT & RECON'),
                    ],
                  ),
                ),

                // Tab Views
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: const [
                      DailyEntryView(),
                      MonthlyMatrixView(),
                      RoomSoftSpreadsheetView(),
                      MonthlyAuditView(),
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
