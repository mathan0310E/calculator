import 'package:flutter/material.dart';
import 'package:calc_pro/ui/widgets/calc_button.dart';

class ScientificGrid extends StatelessWidget {
  final void Function(String) onButtonPressed;

  const ScientificGrid({super.key, required this.onButtonPressed});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width > 600 ? 6 : 5;
        final spacing = width * 0.01;

        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(spacing),
            child: Column(
              children: [
                _buildFunctionRow(context, ['sin', 'cos', 'tan', 'log', 'ln']),
                SizedBox(height: spacing),
                _buildFunctionRow(context, ['asin', 'acos', 'atan', 'sqrt', 'cbrt']),
                SizedBox(height: spacing),
                _buildFunctionRow(context, ['x²', 'x³', 'xʸ', 'x!', '1/x']),
                SizedBox(height: spacing),
                _buildFunctionRow(context, ['π', 'e', 'eˣ', '10ˣ', '|x|']),
                SizedBox(height: spacing * 2),
                Row(
                  children: [
                    _buildBtn(context, 'AC', 'clear', ButtonType.clear),
                    _buildBtn(context, '⌫', 'backspace', ButtonType.clear),
                    _buildBtn(context, '%', 'percent', ButtonType.operation),
                    _buildBtn(context, '÷', 'divide', ButtonType.operation),
                    _buildBtn(context, '×', 'multiply', ButtonType.operation),
                  ],
                ),
                SizedBox(height: spacing),
                Row(
                  children: [
                    _buildBtn(context, '7', '7'),
                    _buildBtn(context, '8', '8'),
                    _buildBtn(context, '9', '9'),
                    _buildBtn(context, '−', 'subtract', ButtonType.operation),
                    _buildBtn(context, '+', 'add', ButtonType.operation),
                  ],
                ),
                SizedBox(height: spacing),
                Row(
                  children: [
                    _buildBtn(context, '4', '4'),
                    _buildBtn(context, '5', '5'),
                    _buildBtn(context, '6', '6'),
                    _buildBtn(context, '(', 'lparen', ButtonType.function),
                    _buildBtn(context, ')', 'rparen', ButtonType.function),
                  ],
                ),
                SizedBox(height: spacing),
                Row(
                  children: [
                    _buildBtn(context, '1', '1'),
                    _buildBtn(context, '2', '2'),
                    _buildBtn(context, '3', '3'),
                    _buildBtn(context, '±', 'negate', ButtonType.function),
                    _buildBtn(context, '=', 'equals', ButtonType.equals),
                  ],
                ),
                SizedBox(height: spacing),
                Row(
                  children: [
                    Expanded(flex: 2, child: _buildBtn(context, '0', '0')),
                    _buildBtn(context, '.', 'decimal'),
                    const Spacer(flex: 2),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFunctionRow(BuildContext context, List<String> labels) {
    return Row(
      children: labels.map((label) {
        String action = label;
        String display = label;
        switch (label) {
          case 'x²': action = 'square'; display = 'x²';
          case 'x³': action = 'cube'; display = 'x³';
          case 'xʸ': action = 'power'; display = 'xʸ';
          case 'x!': action = 'factorial'; display = 'x!';
          case '1/x': action = 'reciprocal'; display = '1/x';
          case 'π': action = 'pi'; display = 'π';
          case 'e': action = 'e'; display = 'e';
          case 'eˣ': action = 'exp'; display = 'eˣ';
          case '10ˣ': action = 'tenx'; display = '10ˣ';
          case '|x|': action = 'abs'; display = '|x|';
          case 'asin': display = 'sin⁻¹';
          case 'acos': display = 'cos⁻¹';
          case 'atan': display = 'tan⁻¹';
          case 'sqrt': display = '√';
          case 'cbrt': display = '∛';
          default: action = label; display = label;
        }
        return Expanded(
          child: CalcButton(
            label: display,
            action: action,
            type: ButtonType.function,
            onPressed: () => onButtonPressed(action),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBtn(BuildContext context, String label, String action, [ButtonType type = ButtonType.number]) {
    return Expanded(
      child: CalcButton(
        label: label,
        action: action,
        type: type,
        onPressed: () => onButtonPressed(action),
      ),
    );
  }
}
