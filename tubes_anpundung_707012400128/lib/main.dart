import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'cubit/laporan_cubit.dart';
import 'cubit/theme_cubit.dart';
import 'helpers/hive_helper.dart';
import 'helpers/pengaturan_helper.dart';
import 'navigation/kerangka_navigasi.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveHelper.init();
  final temaGelap = await PengaturanHelper.muatTemaGelap();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<LaporanCubit>(create: (_) => LaporanCubit()),
        BlocProvider<ThemeCubit>(
          create: (_) =>
              ThemeCubit(temaGelap ? ThemeMode.dark : ThemeMode.light),
        ),
      ],
      child: const AnpundungApp(),
    ),
  );
}

class AnpundungApp extends StatelessWidget {
  const AnpundungApp({super.key});

  static const Color _warnaUtama = Color(0xFF1976D2); // Biru Anpundung

  ThemeData _buatTema(Brightness brightness) {
    final ColorScheme skema = ColorScheme.fromSeed(
      seedColor: _warnaUtama,
      brightness: brightness,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: skema,
      scaffoldBackgroundColor: skema.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: skema.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: skema.surfaceContainerLow,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: skema.outlineVariant.withAlpha(128)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, mode) => MaterialApp(
        title: 'Anpundung Bandung',
        debugShowCheckedModeBanner: false,
        theme: _buatTema(Brightness.light),
        darkTheme: _buatTema(Brightness.dark),
        themeMode: mode,
        home: const KerangkaNavigasi(),
      ),
    );
  }
}
