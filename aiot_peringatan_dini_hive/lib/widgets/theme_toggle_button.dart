import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/theme_cubit.dart';

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeCubit>().state == ThemeMode.dark;
    return IconButton(
      tooltip: isDark ? 'Ganti ke mode terang' : 'Ganti ke mode gelap',
      onPressed: () => context.read<ThemeCubit>().toggle(),
      icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
    );
  }
}
