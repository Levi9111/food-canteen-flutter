import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/canteen_theme_extension.dart';

/// Shows an interactive military-styled in-app calculator modal.
/// Evaluates multi-item canteen expenses (e.g., 55 + 20 + 50 = 125)
/// and returns the computed total to set directly into the price field.
Future<double?> showCanteenCalculator(
  BuildContext context, {
  double? initialValue,
}) {
  return showModalBottomSheet<double>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => CanteenCalculatorSheet(initialValue: initialValue),
  );
}

class CanteenCalculatorSheet extends StatefulWidget {
  final double? initialValue;

  const CanteenCalculatorSheet({super.key, this.initialValue});

  @override
  State<CanteenCalculatorSheet> createState() => _CanteenCalculatorSheetState();
}

class _CanteenCalculatorSheetState extends State<CanteenCalculatorSheet> {
  String _expression = '';
  double _currentResult = 0.0;
  String _activeNumber = '';
  final List<double> _operands = [];
  final List<String> _operators = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null && widget.initialValue! > 0) {
      final str = widget.initialValue!.toStringAsFixed(
        widget.initialValue! % 1 == 0 ? 0 : 2,
      );
      _expression = str;
      _activeNumber = str;
      _currentResult = widget.initialValue!;
    }
  }

  void _onDigit(String digit) {
    setState(() {
      if (digit == '.' && _activeNumber.contains('.')) return;
      _activeNumber += digit;
      _expression += digit;
      _computeRunningResult();
    });
  }

  void _onOperator(String op) {
    if (_activeNumber.isEmpty && _operators.isNotEmpty) {
      // Replace last operator
      setState(() {
        _operators[_operators.length - 1] = op;
        _expression = '${_expression.substring(0, _expression.length - 3)} $op ';
      });
      return;
    }
    if (_activeNumber.isEmpty && _expression.isEmpty) return;

    final numVal = double.tryParse(_activeNumber) ?? 0.0;
    _operands.add(numVal);
    _operators.add(op);
    _activeNumber = '';

    setState(() {
      _expression += ' $op ';
      _computeRunningResult();
    });
  }

  void _computeRunningResult() {
    if (_operands.isEmpty && _activeNumber.isEmpty) {
      _currentResult = 0.0;
      return;
    }

    final tempOperands = List<double>.from(_operands);
    final tempOperators = List<String>.from(_operators);

    if (_activeNumber.isNotEmpty) {
      final lastNum = double.tryParse(_activeNumber);
      if (lastNum != null) {
        tempOperands.add(lastNum);
      }
    }

    if (tempOperands.isEmpty) {
      _currentResult = 0.0;
      return;
    }

    // Evaluate left to right (standard simple cashier calculator)
    double res = tempOperands.first;
    for (int i = 0; i < tempOperators.length; i++) {
      if (i + 1 < tempOperands.length) {
        final nextVal = tempOperands[i + 1];
        switch (tempOperators[i]) {
          case '+':
            res += nextVal;
            break;
          case '-':
            res -= nextVal;
            break;
          case '×':
          case '*':
            res *= nextVal;
            break;
          case '÷':
          case '/':
            if (nextVal != 0) res /= nextVal;
            break;
        }
      }
    }
    _currentResult = res;
  }

  void _onClear() {
    setState(() {
      _expression = '';
      _activeNumber = '';
      _operands.clear;
      _operators.clear;
      _currentResult = 0.0;
    });
  }

  void _onBackspace() {
    setState(() {
      if (_expression.isEmpty) return;
      if (_expression.endsWith(' ')) {
        // remove operator with spaces
        _expression = _expression.trimRight();
        if (_expression.isNotEmpty) {
          _expression = _expression.substring(0, _expression.length - 1).trimRight();
        }
        if (_operators.isNotEmpty) _operators.removeLast();
        if (_operands.isNotEmpty) {
          final last = _operands.removeLast();
          _activeNumber = last.toStringAsFixed(last % 1 == 0 ? 0 : 2);
        }
      } else {
        _expression = _expression.substring(0, _expression.length - 1);
        if (_activeNumber.isNotEmpty) {
          _activeNumber = _activeNumber.substring(0, _activeNumber.length - 1);
        }
      }
      _computeRunningResult();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.canteenTheme;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          decoration: BoxDecoration(
            color: theme.cardBackground,
            border: Border.all(color: theme.accentGold, width: 2),
            boxShadow: const [
              BoxShadow(color: Colors.black45, blurRadius: 16, offset: Offset(0, 8)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                color: AppColors.bafNavy,
                child: Row(
                  children: [
                    const Icon(Icons.calculate, color: AppColors.bafGold, size: 18),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'CANTEEN EXPENSE CALCULATOR',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70, size: 18),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),

              // Display Area
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: theme.surface,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _expression.isEmpty ? '0' : _expression,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.textSecondary,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'TOTAL (৳):',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: theme.accentGold,
                          ),
                        ),
                        Text(
                          '৳ ${_currentResult.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: theme.textPrimary,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Divider(height: 1, thickness: 1),

              // Keypad
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    _buildKeypadRow(['C', 'DEL', '÷', '×'], theme),
                    const SizedBox(height: 8),
                    _buildKeypadRow(['7', '8', '9', '-'], theme),
                    const SizedBox(height: 8),
                    _buildKeypadRow(['4', '5', '6', '+'], theme),
                    const SizedBox(height: 8),
                    _buildKeypadRow(['1', '2', '3', '='], theme),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: _buildButton('0', theme, onTap: () => _onDigit('0')),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 1,
                          child: _buildButton('.', theme, onTap: () => _onDigit('.')),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: SizedBox(
                            height: 42,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.check, size: 16),
                              label: const Text(
                                'APPLY AMOUNT',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 11,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.bafGold,
                                foregroundColor: AppColors.bafNavy,
                                elevation: 0,
                                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                              ),
                              onPressed: () {
                                Navigator.of(context).pop(_currentResult);
                              },
                            ),
                          ),
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

  Widget _buildKeypadRow(List<String> labels, CanteenThemeColors theme) {
    return Row(
      children: labels.map((label) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _buildButton(label, theme, onTap: () {
              if (label == 'C') {
                _onClear();
              } else if (label == 'DEL') {
                _onBackspace();
              } else if (label == '+' || label == '-' || label == '×' || label == '÷') {
                _onOperator(label);
              } else if (label == '=') {
                setState(() => _computeRunningResult());
              } else {
                _onDigit(label);
              }
            }),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildButton(
    String label,
    CanteenThemeColors theme, {
    required VoidCallback onTap,
  }) {
    final isOperator = ['+', '-', '×', '÷', '='].contains(label);
    final isSpecial = ['C', 'DEL'].contains(label);

    Color bgColor = theme.surface;
    Color textColor = theme.textPrimary;
    Color borderColor = theme.cardBorder;

    if (isOperator) {
      bgColor = AppColors.bafNavy;
      textColor = AppColors.bafGold;
      borderColor = AppColors.bafGold.withAlpha(120);
    } else if (isSpecial) {
      bgColor = theme.tableHighlight;
      textColor = theme.debit;
      borderColor = theme.debit.withAlpha(100);
    }

    return SizedBox(
      height: 42,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: textColor,
          side: BorderSide(color: borderColor, width: 1.2),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          padding: EdgeInsets.zero,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: isOperator ? 16 : 14,
            fontWeight: FontWeight.w900,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
