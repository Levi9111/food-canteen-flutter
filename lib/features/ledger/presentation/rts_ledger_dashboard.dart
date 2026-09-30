import 'package:flutter/material.dart';
import '../../../../core/animations/smooth_transitions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../audit/presentation/monthly_audit_view.dart';
import 'widgets/recruits_ledger_view.dart';
import 'widgets/rts_military_header.dart';
import 'widgets/staff_ledger_view.dart';
import 'widgets/voucher_entry_modal.dart';

class RtsLedgerDashboard extends StatefulWidget {
  const RtsLedgerDashboard({super.key});

  @override
  State<RtsLedgerDashboard> createState() => _RtsLedgerDashboardState();
}

class _RtsLedgerDashboardState extends State<RtsLedgerDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      animationDuration: const Duration(milliseconds: 280),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openVoucherModal() {
    showSmoothMilitaryDialog(
      context: context,
      child: const VoucherEntryModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ledgerBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Top Military Masthead
            RtsMilitaryHeader(onNewVoucher: _openVoucherModal),

            // Sharp Military Tab Navigation Bar (Strict Zero Curves)
            Container(
              decoration: const BoxDecoration(
                color: AppColors.bafNavy,
                border: Border(
                  bottom: BorderSide(color: AppColors.ledgerBorder, width: 1),
                ),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorColor: AppColors.bafGold,
                indicatorWeight: 3.5,
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: AppColors.bafGold,
                unselectedLabelColor: Colors.white.withAlpha(180),
                labelStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                ),
                tabs: const [
                  Tab(
                    icon: Icon(Icons.groups, size: 18),
                    text: '1. RECRUITS MESS LEDGER (SQUADRONS)',
                  ),
                  Tab(
                    icon: Icon(Icons.badge, size: 18),
                    text: '2. PERMANENT STAFF LEDGER (BD NO)',
                  ),
                  Tab(
                    icon: Icon(Icons.assessment, size: 18),
                    text: '3. MONTHLY AUDIT & RECONCILIATION SHEET',
                  ),
                ],
              ),
            ),

            // Main Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  RecruitsLedgerView(),
                  StaffLedgerView(),
                  MonthlyAuditView(),
                ],
              ),
            ),

            // Bottom Military Status Ribbon
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              color: AppColors.bafNavy,
              child: const Row(
                children: [
                  Expanded(
                    child: Text(
                      'SECURITY: OFFICIAL USE ONLY • RECRUITS TRAINING SCHOOL (RTS) • BANGLADESH AIR FORCE',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.bafGold,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'OPERATOR: ACCOUNTS NCO • RTS BAF',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
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
}
