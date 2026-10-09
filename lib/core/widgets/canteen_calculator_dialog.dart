import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Shows an upgraded tactical cockpit-style in-app calculator modal.
/// Evaluates multi-item canteen expenses (e.g., 55 + 20 + 50 = 125)
/// with tactical OLED display, tactile squircle keys, and preset quick-adds.
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

  void _onQuickAdd(double delta) {
    setState(() {
      if (_expression.isEmpty && _activeNumber.isEmpty) {
        final str = delta.toStringAsFixed(0);
        _expression = str;
        _activeNumber = str;
      } else {
        if (_activeNumber.isNotEmpty) {
          final cur = double.tryParse(_activeNumber) ?? 0.0;
          _operands.add(cur);
          _operators.add('+');
        } else if (_operators.isNotEmpty && _operators.last != '+') {
          _operators.add('+');
        }
        final deltaStr = delta.toStringAsFixed(0);
        _activeNumber = deltaStr;
        _expression = '$_expression + $deltaStr';
      }
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

    // Evaluate left to right (standard POS cashier calculator)
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
      _operands.clear();
      _operators.clear();
      _currentResult = 0.0;
    });
  }

  void _onBackspace() {
    setState(() {
      if (_expression.isEmpty) return;
      if (_expression.endsWith(' ')) {
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 380),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0A111E) : const Color(0xFF0F1E36),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.bafGold.withValues(alpha: 0.6),
              width: 1.8,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.6),
                blurRadius: 30,
                spreadRadius: 2,
                offset: const Offset(0, 14),
              ),
              BoxShadow(
                color: AppColors.bafGold.withValues(alpha: 0.15),
                blurRadius: 20,
                spreadRadius: -4,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Sleek Cockpit Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.bafNavy,
                        const Color(0xFF0F264A),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border(
                      bottom: BorderSide(
                        color: AppColors.bafGold.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: AppColors.bafGold.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.bafGold.withValues(alpha: 0.4),
                          ),
                        ),
                        child: const Icon(
                          Icons.calculate_rounded,
                          color: AppColors.bafGold,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'CANTEEN EXPENSE CALCULATOR',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.8,
                              ),
                            ),
                            SizedBox(height: 1),
                            Text(
                              'TACTICAL RAPID ENTRY MATRIX',
                              style: TextStyle(
                                color: AppColors.bafSkyBlue,
                                fontSize: 8.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, color: Colors.white70, size: 16),
                        ),
                      ),
                    ],
                  ),
                ),

                // 2. High-Tech OLED Bezel Display
                Container(
                  margin: const EdgeInsets.all(14),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF03070E),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFF1E3A5F),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.8),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Formula expression
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0A2239),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'EXPR',
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.w900,
                                color: AppColors.bafSkyBlue,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Expanded(
                            flex: 6,
                            child: Text(
                              _expression.isEmpty ? '0' : _expression,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF8AB4F8),
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Computed Live Total
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'TOTAL (৳)',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              color: AppColors.bafGold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            '৳ ${_currentResult.toStringAsFixed(_currentResult % 1 == 0 ? 0 : 2)}',
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFFFFD54F),
                              fontFamily: 'monospace',
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // 3. Quick-Add Preset Chips
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                    children: [
                      const Text(
                        'QUICK:',
                        style: TextStyle(
                          fontSize: 8.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.bafGold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 6),
                      ...[10.0, 20.0, 50.0, 100.0].map((amt) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: InkWell(
                            onTap: () => _onQuickAdd(amt),
                            borderRadius: BorderRadius.circular(6),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFF142742),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: const Color(0xFF2B4D7E),
                                  width: 0.8,
                                ),
                              ),
                              child: Text(
                                '+${amt.toInt()}',
                                style: const TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // 4. Tactical Keypad Grid
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Column(
                    children: [
                      _buildKeypadRow(['C', 'DEL', '÷', '×']),
                      const SizedBox(height: 7),
                      _buildKeypadRow(['7', '8', '9', '-']),
                      const SizedBox(height: 7),
                      _buildKeypadRow(['4', '5', '6', '+']),
                      const SizedBox(height: 7),
                      _buildKeypadRow(['1', '2', '3', '=']),
                      const SizedBox(height: 7),
                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: _buildTacticalKey('0', onTap: () => _onDigit('0')),
                          ),
                          const SizedBox(width: 7),
                          Expanded(
                            flex: 1,
                            child: _buildTacticalKey('.', onTap: () => _onDigit('.')),
                          ),
                          const SizedBox(width: 7),
                          Expanded(
                            flex: 2,
                            child: SizedBox(
                              height: 44,
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.done_all, size: 16),
                                label: const Text(
                                  'APPLY TOTAL',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 11,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.bafGold,
                                  foregroundColor: AppColors.bafNavy,
                                  elevation: 4,
                                  shadowColor: AppColors.bafGold.withValues(alpha: 0.5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
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

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKeypadRow(List<String> labels) {
    return Row(
      children: labels.asMap().entries.map((entry) {
        final idx = entry.key;
        final label = entry.value;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: idx == 0 ? 0 : 3.5, right: idx == 3 ? 0 : 3.5),
            child: _buildTacticalKey(label, onTap: () {
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

  Widget _buildTacticalKey(
    String label, {
    required VoidCallback onTap,
  }) {
    final isOperator = ['+', '-', '×', '÷'].contains(label);
    final isEqual = label == '=';
    final isClear = label == 'C';
    final isDel = label == 'DEL';

    Color bgTop;
    Color bgBottom;
    Color textColor;
    Color borderCol;

    if (isEqual) {
      bgTop = const Color(0xFF1E7E34);
      bgBottom = const Color(0xFF155724);
      textColor = Colors.white;
      borderCol = const Color(0xFF28A745);
    } else if (isOperator) {
      bgTop = const Color(0xFF1E3A5F);
      bgBottom = const Color(0xFF0F264A);
      textColor = AppColors.bafGold;
      borderCol = AppColors.bafGold.withValues(alpha: 0.4);
    } else if (isClear || isDel) {
      bgTop = const Color(0xFF3E1A24);
      bgBottom = const Color(0xFF2A0D15);
      textColor = const Color(0xFFFF6B81);
      borderCol = const Color(0xFF8B263E);
    } else {
      // Normal Digit
      bgTop = const Color(0xFF1B2C47);
      bgBottom = const Color(0xFF121F33);
      textColor = Colors.white;
      borderCol = const Color(0xFF2A4269);
    }

    return SizedBox(
      height: 44,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          splashColor: AppColors.bafGold.withValues(alpha: 0.2),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [bgTop, bgBottom],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: borderCol, width: 1.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: TextStyle(
                fontSize: (isOperator || isEqual) ? 17 : (isClear || isDel ? 11.5 : 15),
                fontWeight: FontWeight.w900,
                color: textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
