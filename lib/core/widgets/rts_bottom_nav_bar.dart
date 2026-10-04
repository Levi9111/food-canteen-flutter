import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../localization/locale_provider.dart';
import '../theme/app_colors.dart';

class RtsBottomNavBar extends ConsumerWidget {
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  final bool isRecruitsGroup;

  const RtsBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.isRecruitsGroup,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(localeProvider);
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bafNavy,
        border: Border(
          top: BorderSide(color: AppColors.bafGold, width: 1.5),
        ),
      ),
      child: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: AppColors.bafNavy,
          indicatorColor: AppColors.bafGold,
          indicatorShape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          elevation: 0,
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            final isSelected = states.contains(WidgetState.selected);
            return TextStyle(
              fontSize: 10.5,
              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
              color: isSelected ? AppColors.bafGold : Colors.white70,
              letterSpacing: 0.3,
            );
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            final isSelected = states.contains(WidgetState.selected);
            return IconThemeData(
              size: 20,
              color: isSelected ? AppColors.bafNavy : Colors.white70,
            );
          }),
        ),
        child: NavigationBar(
          height: 62,
          selectedIndex: currentIndex,
          onDestinationSelected: onDestinationSelected,
          destinations: isRecruitsGroup
              ? [
                  NavigationDestination(
                    icon: const Icon(Icons.menu_book_outlined),
                    selectedIcon: const Icon(Icons.menu_book),
                    label: AppTranslations.tr('register', lang),
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.grid_on_outlined),
                    selectedIcon: const Icon(Icons.grid_on),
                    label: AppTranslations.tr('matrix', lang),
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.verified_outlined),
                    selectedIcon: const Icon(Icons.verified),
                    label: AppTranslations.tr('audit', lang),
                  ),
                ]
              : [
                  NavigationDestination(
                    icon: const Icon(Icons.person_outline),
                    selectedIcon: const Icon(Icons.person),
                    label: AppTranslations.tr('staff_book', lang),
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.grid_on_outlined),
                    selectedIcon: const Icon(Icons.grid_on),
                    label: AppTranslations.tr('matrix', lang),
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.picture_as_pdf_outlined),
                    selectedIcon: const Icon(Icons.picture_as_pdf),
                    label: AppTranslations.tr('statement', lang),
                  ),
                ],
        ),
      ),
    );
  }
}
