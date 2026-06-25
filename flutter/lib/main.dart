import 'package:flutter/material.dart';
import 'ui/calculator_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CalcProApp());
}

class CalcProApp extends StatelessWidget {
  const CalcProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const CalculatorScreen();
  }
}
