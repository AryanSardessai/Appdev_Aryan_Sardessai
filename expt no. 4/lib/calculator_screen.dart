import 'package:flutter/material.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreen();
}

class _CalculatorScreen extends State<CalculatorScreen> {
  String display = "0";
  String _expression = "";

  final List<String> buttons = [
    'C', '÷', '×', '⌫',
    '7', '8', '9', '-',
    '4', '5', '6', '+',
    '1', '2', '3', '=',
    '0', '.', '', '',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Output display
            Container(
              alignment: Alignment.bottomRight,
              padding: const EdgeInsets.all(16),
              child: Text(
                display,
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.end,
              ),
            ),
            const SizedBox(height: 8),
            // Buttons grid
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: GridView.builder(
                  itemCount: buttons.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    childAspectRatio: 1.1,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemBuilder: (context, index) {
                    final label = buttons[index];
                    if (label.isEmpty) return const SizedBox.shrink();
                    return ElevatedButton(
                      onPressed: () => _onButtonPressed(label),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _getButtonColor(label, context),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w500,
                          color: _getButtonTextColor(label, context),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onButtonPressed(String label) {
    setState(() {
      if (label == 'C') {
        _expression = "";
        display = "0";
      } else if (label == '⌫') {
        if (_expression.isNotEmpty) {
          _expression = _expression.substring(0, _expression.length - 1);
          display = _expression.isEmpty ? "0" : _expression;
        }
      } else if (label == '=') {
        try {
          String result = _evaluateExpression(_expression);
          display = result;
          _expression = result;
        } catch (e) {
          display = "Error";
          _expression = "";
        }
      } else {
        // Prevent multiple operators in a row
        if (_isOperator(label)) {
          if (_expression.isEmpty || _isOperator(_expression[_expression.length - 1])) {
            return;
          }
        }
        _expression += label;
        display = _expression;
      }
    });
  }

  String _evaluateExpression(String expr) {
    // Replace symbols for Dart eval
    expr = expr.replaceAll('×', '*').replaceAll('÷', '/');
    // Remove trailing operator
    if (expr.isEmpty) return "0";
    if (_isOperator(expr[expr.length - 1])) {
      expr = expr.substring(0, expr.length - 1);
    }
    // Use Dart's expression evaluation (very basic)
    double result = _calculate(expr);
    if (result % 1 == 0) {
      return result.toInt().toString();
    } else {
      return result.toString();
    }
  }

  double _calculate(String expr) {
    // Very basic parser for +, -, *, /
    // For a real app, use a math expression package
    List<String> tokens = [];
    String number = "";
    for (int i = 0; i < expr.length; i++) {
      String c = expr[i];
      if ('0123456789.'.contains(c)) {
        number += c;
      } else if ('+-*/'.contains(c)) {
        if (number.isNotEmpty) {
          tokens.add(number);
          number = "";
        }
        tokens.add(c);
      }
    }
    if (number.isNotEmpty) tokens.add(number);

    // Operator precedence: */ before +-
    for (int i = 0; i < tokens.length; i++) {
      if (tokens[i] == '*' || tokens[i] == '/') {
        double left = double.parse(tokens[i - 1]);
        double right = double.parse(tokens[i + 1]);
        double res = tokens[i] == '*' ? left * right : left / right;
        tokens[i - 1] = res.toString();
        tokens.removeAt(i); // operator
        tokens.removeAt(i); // right operand
        i--;
      }
    }
    double result = double.parse(tokens[0]);
    for (int i = 1; i < tokens.length; i += 2) {
      String op = tokens[i];
      double next = double.parse(tokens[i + 1]);
      if (op == '+') {
        result += next;
      } else if (op == '-') {
        result -= next;
      }
    }
    return result;
  }

  bool _isOperator(String label) {
    return label == '+' || label == '-' || label == '×' || label == '÷';
  }

  // Helper to style operator buttons
  Color _getButtonColor(String label, BuildContext context) {
    if (label == 'C' || label == '⌫') {
      return Colors.redAccent.withOpacity(0.8);
    } else if (label == '=' || label == '+' || label == '-' || label == '×' || label == '÷') {
      return Colors.blueAccent.withOpacity(0.8);
    } else {
      return Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.7);
    }
  }

  Color _getButtonTextColor(String label, BuildContext context) {
    if (label == 'C' || label == '⌫') {
      return Colors.white;
    } else if (label == '=' || label == '+' || label == '-' || label == '×' || label == '÷') {
      return Colors.white;
    } else {
      return Theme.of(context).colorScheme.onSurfaceVariant;
    }
  }
}