import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/baf_rts_crest.dart';

class RtsMilitaryHeader extends StatelessWidget {
  final VoidCallback onNewVoucher;

  const RtsMilitaryHeader({
    super.key,
    required this.onNewVoucher,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.bafNavy,
        border: Border(
          bottom: BorderSide(color: AppColors.bafGold, width: 2),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // BAF RTS Insignia
          const BafRtsCrest(size: 52),
          const SizedBox(width: 16),

          // Official Military Titles
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      color: AppColors.bafRoundelGreen,
                      child: const Text(
                        'BANGLADESH AIR FORCE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      color: AppColors.bafDeepBlue,
                      child: const Text(
                        'RECRUITS TRAINING SCHOOL (RTS)',
                        style: TextStyle(
                          color: AppColors.bafGold,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${AppConstants.appName.toUpperCase()} — ACCOUNTS LEDGER',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${AppConstants.institutionName} • Calculations, Clearances & Audit Ledgers',
                  style: TextStyle(
                    color: Colors.white.withAlpha(200),
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),

          // Security Status & Quick Entry
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.bafDeepBlue,
                  border: Border.all(color: AppColors.bafGold.withAlpha(150)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.creditGreen,
                        shape: BoxShape.rectangle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'OFFICIAL AUDIT ACTIVE',
                      style: TextStyle(
                        color: AppColors.bafGold,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              ElevatedButton.icon(
                onPressed: onNewVoucher,
                icon: const Icon(Icons.add_box_outlined, size: 16),
                label: const Text('POST VOUCHER'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.bafGold,
                  foregroundColor: AppColors.bafNavy,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                  textStyle: AppTextStyles.titleMedium(AppColors.bafNavy),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
