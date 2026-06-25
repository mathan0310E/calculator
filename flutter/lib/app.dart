import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calc_pro/core/theme/app_theme.dart';
import 'package:calc_pro/providers/theme_provider.dart';
import 'package:calc_pro/ui/screens/calculator_screen.dart';

class CalcProApp extends ConsumerWidget {
  const CalcProApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'Calc Pro',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      home: const CalculatorScreen(),
    );
  }
}
