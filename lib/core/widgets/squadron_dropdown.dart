import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';

/// Military-styled Squadron Selector Dropdown.
/// Displays active squadron with emblem icon and day total badge.
class SquadronDropdown extends StatelessWidget {
  final List<String> squadrons;
  final String selectedSquadron;
  final ValueChanged<String> onChanged;
  final double dayTotal;
  final bool showDayTotal;

  const SquadronDropdown({
    super.key,
    required this.squadrons,
    required this.selectedSquadron,
    required this.onChanged,
    this.dayTotal = 0.0,
    this.showDayTotal = true,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat('#,##0.00', 'en_US');

    // Ensure selected squadron is in list, fallback to first
    final currentVal = squadrons.contains(selectedSquadron)
        ? selectedSquadron
        : (squadrons.isNotEmpty ? squadrons.first : 'Sadruddin');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.bafNavy,
        border: Border.all(color: AppColors.bafGold, width: 1.2),
      ),
      child: Row(
        children: [
          // Tactical Shield Icon
          const Icon(Icons.shield_outlined, color: AppColors.bafGold, size: 18),
          const SizedBox(width: 8),

          // Label
          const Text(
            'SQUADRON:',
            style: TextStyle(
              color: AppColors.bafGold,
              fontSize: 10.5,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 8),

          // Dropdown selector
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: currentVal,
                isExpanded: true,
                dropdownColor: AppColors.bafNavy,
                icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.bafGold, size: 20),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                  letterSpacing: 0.3,
                ),
                items: squadrons.map((sqn) {
                  return DropdownMenuItem<String>(
                    value: sqn,
                    child: Text(
                      '$sqn Squadron'.toUpperCase(),
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    onChanged(val);
                  }
                },
              ),
            ),
          ),

          // Optional Day Total Badge
          if (showDayTotal) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.bafDeepBlue,
                border: Border.all(color: AppColors.bafGold.withAlpha(160), width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'DAY: ',
                    style: TextStyle(color: AppColors.bafGold, fontSize: 9, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '৳ ${currencyFormat.format(dayTotal)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
