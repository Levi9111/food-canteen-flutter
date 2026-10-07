import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/canteen_theme_extension.dart';

/// Standard military-styled action bar for dialogs and modals.
/// Guarantees perfectly matched, even-sized buttons that never overflow.
class ModalActionBar extends StatelessWidget {
  final String cancelLabel;
  final String confirmLabel;
  final IconData cancelIcon;
  final IconData confirmIcon;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;
  final bool isConfirmLoading;
  final Color confirmColor;
  final Color confirmTextColor;
  final Color? cancelTextColor;

  const ModalActionBar({
    super.key,
    this.cancelLabel = 'CANCEL',
    required this.confirmLabel,
    this.cancelIcon = Icons.close,
    this.confirmIcon = Icons.check,
    required this.onCancel,
    required this.onConfirm,
    this.isConfirmLoading = false,
    this.confirmColor = AppColors.bafNavy,
    this.confirmTextColor = AppColors.bafGold,
    this.cancelTextColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.canteenTheme;
    final resolvedCancelColor = cancelTextColor ?? theme.textPrimary;

    return Row(
      children: [
        // Cancel Button (Even 50% width)
        Expanded(
          child: SizedBox(
            height: 44,
            child: OutlinedButton.icon(
              onPressed: onCancel,
              icon: Icon(cancelIcon, size: 16, color: resolvedCancelColor),
              label: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  cancelLabel,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    color: resolvedCancelColor,
                  ),
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: resolvedCancelColor,
                side: BorderSide(color: theme.cardBorder, width: 1.2),
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                padding: const EdgeInsets.symmetric(horizontal: 10),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        // Confirm Button (Even 50% width)
        Expanded(
          child: SizedBox(
            height: 44,
            child: ElevatedButton.icon(
              onPressed: isConfirmLoading ? null : onConfirm,
              icon: isConfirmLoading
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: confirmTextColor,
                      ),
                    )
                  : Icon(confirmIcon, size: 16),
              label: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  confirmLabel,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                    color: confirmTextColor,
                  ),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: confirmColor,
                foregroundColor: confirmTextColor,
                elevation: 0,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                padding: const EdgeInsets.symmetric(horizontal: 10),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
