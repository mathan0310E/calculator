import 'package:flutter/material.dart';
import 'package:calc_pro/ui/widgets/calc_button.dart';

class BasicGrid extends StatelessWidget {
  final void Function(String) onButtonPressed;

  const BasicGrid({super.key, required this.onButtonPressed});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final spacing = constraints.maxWidth * 0.015;

        return Padding(
          padding: EdgeInsets.all(spacing),
          child: Column(
            children: [
              Row(
                children: [
                  _buildBtn(context, 'AC', 'clear', ButtonType.clear),
                  _buildBtn(context, '⌫', 'backspace', ButtonType.clear),
                  _buildBtn(context, '%', 'percent', ButtonType.operation),
                  _buildBtn(context, '÷', 'divide', ButtonType.operation),
                ],
              ),
              Row(
                children: [
                  _buildBtn(context, '7', '7'),
                  _buildBtn(context, '8', '8'),
                  _buildBtn(context, '9', '9'),
                  _buildBtn(context, '×', 'multiply', ButtonType.operation),
                ],
              ),
              Row(
                children: [
                  _buildBtn(context, '4', '4'),
                  _buildBtn(context, '5', '5'),
                  _buildBtn(context, '6', '6'),
                  _buildBtn(context, '−', 'subtract', ButtonType.operation),
                ],
              ),
              Row(
                children: [
                  _buildBtn(context, '1', '1'),
                  _buildBtn(context, '2', '2'),
                  _buildBtn(context, '3', '3'),
                  _buildBtn(context, '+', 'add', ButtonType.operation),
                ],
              ),
              Expanded(
                child: Row(
                  children: [
                    Expanded(flex: 2, child: _buildBtn(context, '0', '0')),
                    _buildBtn(context, '.', 'decimal'),
                    _buildBtn(context, '=', 'equals', ButtonType.equals),
                  ],
                ),
              ),
            ],
          ),
        );
      },
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
