import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/animations/smooth_transitions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
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
      animationDuration: const Duration(milliseconds: 280),
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
          width: 380,
          decoration: BoxDecoration(
            color: AppColors.ledgerSurface,
            border: Border.all(color: AppColors.bafNavy, width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                color: AppColors.bafNavy,
                child: const Text(
                  'CREATE NEW RECRUIT ENTRY BATCH',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ENTRY NUMBER (e.g. 55, 56):',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: controller,
                      keyboardType: TextInputType.number,
                      autofocus: true,
                      decoration: const InputDecoration(hintText: 'Enter batch number'),
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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(canteenRegisterProvider);
    final notifier = ref.read(canteenRegisterProvider.notifier);

    final isMobile = MediaQuery.of(context).size.width < 768;

    return Scaffold(
      backgroundColor: AppColors.ledgerBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Top Master Military Masthead
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 12 : 20,
                vertical: isMobile ? 8 : 12,
              ),
              decoration: const BoxDecoration(
                color: AppColors.bafNavy,
                border: Border(bottom: BorderSide(color: AppColors.bafGold, width: 2)),
              ),
              child: isMobile
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Mobile Header: Crest & Titles
                        Row(
                          children: [
                            const BafRtsCrest(size: 36),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                        color: AppColors.bafRoundelGreen,
                                        child: const Text(
                                          'BAF',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.8,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                        color: AppColors.bafDeepBlue,
                                        child: const Text(
                                          'RTS CANTEEN',
                                          style: TextStyle(
                                            color: AppColors.bafGold,
                                            fontSize: 9,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.6,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  const Text(
                                    'FOOD CANTEEN, RTS',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Mobile Controls: Entry Batch & Duty In-Charge
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              // Active Batch Selector
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.bafDeepBlue,
                                  border: Border.all(color: AppColors.bafGold.withAlpha(150)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      'ENTRY:',
                                      style: TextStyle(
                                        color: AppColors.bafGold,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    DropdownButton<String>(
                                      value: state.activeEntry,
                                      dropdownColor: AppColors.bafNavy,
                                      underline: const SizedBox(),
                                      isDense: true,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w900,
                                      ),
                                      items: state.allEntries.map((e) {
                                        return DropdownMenuItem(
                                          value: e,
                                          child: Text('Entry $e'),
                                        );
                                      }).toList(),
                                      onChanged: (val) {
                                        if (val != null) notifier.setActiveEntry(val);
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.add_circle, color: AppColors.bafGold, size: 16),
                                      tooltip: 'New Batch',
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      onPressed: () => _showNewEntryDialog(context, ref),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(width: 8),

                              // Duty In-Charge Selector
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.bafDeepBlue,
                                  border: Border.all(color: AppColors.bafGold.withAlpha(150)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      'DUTY:',
                                      style: TextStyle(
                                        color: AppColors.bafGold,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    _buildManagerChip(
                                      title: CanteenConstants.roleNcoic,
                                      isSelected: state.activeManager == CanteenConstants.roleNcoic,
                                      onTap: () => notifier.setActiveManager(CanteenConstants.roleNcoic),
                                    ),
                                    const SizedBox(width: 4),
                                    _buildManagerChip(
                                      title: CanteenConstants.roleJcoic,
                                      isSelected: state.activeManager == CanteenConstants.roleJcoic,
                                      onTap: () => notifier.setActiveManager(CanteenConstants.roleJcoic),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        const BafRtsCrest(size: 48),
                        const SizedBox(width: 14),

                        // Titles
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    color: AppColors.bafRoundelGreen,
                                    child: const Text(
                                      'BANGLADESH AIR FORCE',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    color: AppColors.bafDeepBlue,
                                    child: const Text(
                                      'RECRUITS TRAINING SCHOOL (RTS)',
                                      style: TextStyle(
                                        color: AppColors.bafGold,
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'FOOD CANTEEN, RTS',
                                style: AppTextStyles.titleLarge(Colors.white),
                              ),
                              const SizedBox(height: 1),
                              const Text(
                                'Recruits Room-Wise Daily Price Register & Monthly Spreadsheets',
                                style: TextStyle(color: Colors.white70, fontSize: 11),
                              ),
                            ],
                          ),
                        ),

                        // Entry Selector & Creator
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.bafDeepBlue,
                            border: Border.all(color: AppColors.bafGold.withAlpha(150)),
                          ),
                          child: Row(
                            children: [
                              const Text(
                                'ACTIVE BATCH:',
                                style: TextStyle(
                                  color: AppColors.bafGold,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              DropdownButton<String>(
                                value: state.activeEntry,
                                dropdownColor: AppColors.bafNavy,
                                underline: const SizedBox(),
                                isDense: true,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                ),
                                items: state.allEntries.map((e) {
                                  return DropdownMenuItem(
                                    value: e,
                                    child: Text('Entry $e'),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) notifier.setActiveEntry(val);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.add_circle, color: AppColors.bafGold, size: 18),
                                tooltip: 'Add New Entry Batch',
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () => _showNewEntryDialog(context, ref),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 14),

                        // Manager Switcher (NCOIC / JCOIC)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.bafDeepBlue,
                            border: Border.all(color: AppColors.bafGold.withAlpha(150)),
                          ),
                          child: Row(
                            children: [
                              const Text(
                                'DUTY IN-CHARGE:',
                                style: TextStyle(
                                  color: AppColors.bafGold,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              _buildManagerChip(
                                title: CanteenConstants.roleNcoic,
                                isSelected: state.activeManager == CanteenConstants.roleNcoic,
                                onTap: () => notifier.setActiveManager(CanteenConstants.roleNcoic),
                              ),
                              const SizedBox(width: 4),
                              _buildManagerChip(
                                title: CanteenConstants.roleJcoic,
                                isSelected: state.activeManager == CanteenConstants.roleJcoic,
                                onTap: () => notifier.setActiveManager(CanteenConstants.roleJcoic),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),

            // Sharp Military Tab Navigation (Strict Zero Curves)
            Container(
              decoration: const BoxDecoration(
                color: AppColors.bafNavy,
                border: Border(bottom: BorderSide(color: AppColors.ledgerBorder, width: 1)),
              ),
              child: TabBar(
                controller: _tabController,
                isScrollable: !isMobile,
                indicatorColor: AppColors.bafGold,
                indicatorWeight: 3.5,
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: AppColors.bafGold,
                unselectedLabelColor: Colors.white70,
                labelStyle: TextStyle(
                  fontSize: isMobile ? 9.5 : 11.5,
                  fontWeight: FontWeight.bold,
                  letterSpacing: isMobile ? 0.2 : 0.6,
                ),
                tabs: isMobile
                    ? const [
                        Tab(icon: Icon(Icons.menu_book, size: 16), text: 'REGISTER'),
                        Tab(icon: Icon(Icons.grid_on, size: 16), text: 'MATRIX'),
                        Tab(icon: Icon(Icons.table_chart, size: 16), text: 'SPREADSHEET'),
                        Tab(icon: Icon(Icons.verified, size: 16), text: 'AUDIT'),
                      ]
                    : const [
                        Tab(icon: Icon(Icons.menu_book, size: 16), text: '1. DAILY REGISTER (ROOM BOOK)'),
                        Tab(icon: Icon(Icons.grid_on, size: 16), text: '2. MONTHLY MATRIX (ALL ROOMS)'),
                        Tab(icon: Icon(Icons.table_chart, size: 16), text: '3. ROOM SOFT SPREADSHEET (PRINTABLE)'),
                        Tab(icon: Icon(Icons.verified, size: 16), text: '4. AUDIT & RECONCILIATION SHEET'),
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

            // Bottom Military Status Ribbon
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              color: AppColors.bafNavy,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      isMobile
                          ? 'RTS BAF • OFFICIAL CANTEEN REGISTER'
                          : 'SECURITY: OFFICIAL USE ONLY • RECRUITS TRAINING SCHOOL (RTS) • BANGLADESH AIR FORCE',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.bafGold,
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'ENTRY ${state.activeEntry} • ${state.activeManager}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 9.5,
                      fontWeight: FontWeight.bold,
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

  Widget _buildManagerChip({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.bafGold : Colors.transparent,
          border: Border.all(color: AppColors.bafGold),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isSelected ? AppColors.bafNavy : Colors.white,
          ),
        ),
      ),
    );
  }
}
