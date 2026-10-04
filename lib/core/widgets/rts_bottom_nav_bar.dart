import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class RtsBottomNavBar extends StatelessWidget {
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
  Widget build(BuildContext context) {
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
              ? const [
                  NavigationDestination(
                    icon: Icon(Icons.menu_book_outlined),
                    selectedIcon: Icon(Icons.menu_book),
                    label: 'REGISTER',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.grid_on_outlined),
                    selectedIcon: Icon(Icons.grid_on),
                    label: 'MATRIX',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.verified_outlined),
                    selectedIcon: Icon(Icons.verified),
                    label: 'AUDIT',
                  ),
                ]
              : const [
                  NavigationDestination(
                    icon: Icon(Icons.person_outline),
                    selectedIcon: Icon(Icons.person),
                    label: 'STAFF BOOK',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.grid_on_outlined),
                    selectedIcon: Icon(Icons.grid_on),
                    label: 'MATRIX',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.picture_as_pdf_outlined),
                    selectedIcon: Icon(Icons.picture_as_pdf),
                    label: 'STATEMENT',
                  ),
                ],
        ),
      ),
    );
  }
}
