import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/animations/smooth_transitions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/baf_rts_crest.dart';
import '../../../../core/widgets/tactical_card.dart';
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final isMobile = screenWidth < 800;
        final isCompact = screenWidth < 500;

        return Scaffold(
          backgroundColor: AppColors.ledgerBackground,
          body: SafeArea(
            child: Column(
              children: [
                // Top Master Military Masthead (Tactical, Zero Curves, Never Wraps Vertically)
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: AppColors.bafNavy,
                    border: Border(
                      bottom: BorderSide(color: AppColors.bafGold, width: 2.0),
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Subtle tactical corner bracket markings on top header
                      Positioned(
                        top: 2,
                        right: 4,
                        child: Text(
                          'BAF-RTS // AUTH',
                          style: TextStyle(
                            fontSize: 7.5,
                            color: AppColors.bafGold.withAlpha(90),
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isCompact ? 10 : 16,
                          vertical: isCompact ? 8 : 10,
                        ),
                        child: isMobile
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Tier 1: Logo & App Title Row
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      // Official BAF Emblem Crest
                                      const BafRtsCrest(size: 38),
                                      const SizedBox(width: 10),

                                      // Main Title Block (Protected against any flex crush)
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const TacticalBadge(
                                                  label: 'BAF',
                                                  backgroundColor: AppColors.bafRoundelGreen,
                                                  textColor: Colors.white,
                                                  fontSize: 8.5,
                                                  padding: EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                                ),
                                                const SizedBox(width: 5),
                                                const TacticalBadge(
                                                  label: 'RTS CANTEEN',
                                                  backgroundColor: AppColors.bafDeepBlue,
                                                  borderColor: AppColors.bafGold,
                                                  textColor: AppColors.bafGold,
                                                  fontSize: 8.5,
                                                  padding: EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 3),
                                            const Text(
                                              'FOOD CANTEEN, RTS',
                                              maxLines: 1,
                                              softWrap: false,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w900,
                                                letterSpacing: 0.6,
                                              ),
                                            ),
                                            const Text(
                                              'Recruits Room-Wise Daily Price Register',
                                              maxLines: 1,
                                              softWrap: false,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: Colors.white70,
                                                fontSize: 9.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 8),

                                  // Tier 2: Tactical Controls Bar (Batch & Duty In-Charge)
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        _buildBatchSelector(state, notifier),
                                        const SizedBox(width: 8),
                                        _buildDutySelector(state, notifier),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            : Row(
                                children: [
                                  // Official BAF Emblem Crest
                                  const BafRtsCrest(size: 46),
                                  const SizedBox(width: 14),

                                  // Titles & Subtitles
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Row(
                                          children: [
                                            const TacticalBadge(
                                              label: 'BANGLADESH AIR FORCE',
                                              backgroundColor: AppColors.bafRoundelGreen,
                                              textColor: Colors.white,
                                              fontSize: 9,
                                              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                            ),
                                            const SizedBox(width: 6),
                                            const TacticalBadge(
                                              label: 'RECRUITS TRAINING SCHOOL (RTS)',
                                              backgroundColor: AppColors.bafDeepBlue,
                                              borderColor: AppColors.bafGold,
                                              textColor: AppColors.bafGold,
                                              fontSize: 9,
                                              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          'FOOD CANTEEN, RTS',
                                          maxLines: 1,
                                          softWrap: false,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppTextStyles.titleLarge(Colors.white),
                                        ),
                                        const Text(
                                          'Recruits Room-Wise Daily Price Register & Monthly Spreadsheets',
                                          maxLines: 1,
                                          softWrap: false,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(color: Colors.white70, fontSize: 11),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(width: 14),

                                  // Tactical Batch Selector
                                  _buildBatchSelector(state, notifier),
                                  const SizedBox(width: 10),

                                  // Tactical Duty Selector
                                  _buildDutySelector(state, notifier),
                                ],
                              ),
                      ),
                    ],
                  ),
                ),

                // Sharp Military Tab Navigation (Strict Zero Curves, Gold Accents)
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

                // Bottom Military Status Ribbon (Sharp & Crisp)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  color: AppColors.bafNavy,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          isMobile
                              ? 'RTS BAF • OFFICIAL CANTEEN PRICING REGISTER'
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
      },
    );
  }

  Widget _buildBatchSelector(CanteenRegisterState state, CanteenRegisterNotifier notifier) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.bafDeepBlue,
        border: Border.all(color: AppColors.bafGold.withAlpha(160), width: 1.0),
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
              letterSpacing: 0.5,
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
            tooltip: 'Add Batch',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () => _showNewEntryDialog(context, ref),
          ),
        ],
      ),
    );
  }

  Widget _buildDutySelector(CanteenRegisterState state, CanteenRegisterNotifier notifier) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.bafDeepBlue,
        border: Border.all(color: AppColors.bafGold.withAlpha(160), width: 1.0),
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
              letterSpacing: 0.5,
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
    );
  }

  Widget _buildManagerChip({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.bafGold : Colors.transparent,
          border: Border.all(
            color: isSelected ? AppColors.bafGold : AppColors.bafGold.withAlpha(120),
            width: 1.0,
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w800,
            color: isSelected ? AppColors.bafNavy : Colors.white,
          ),
        ),
      ),
    );
  }
}
