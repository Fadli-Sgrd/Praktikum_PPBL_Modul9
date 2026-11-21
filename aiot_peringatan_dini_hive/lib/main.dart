import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'cubit/pantauan_cubit.dart';
import 'cubit/theme_cubit.dart';
import 'helpers/hive_helper.dart';
import 'pages/dashboard_sensor_page.dart';
import 'pages/riwayat_sensor_page.dart';
import 'pages/pengaturan_page.dart';
import 'themes/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveHelper.init();
  runApp(const AplikasiPeringatanDini());
}

class AplikasiPeringatanDini extends StatelessWidget {
  const AplikasiPeringatanDini({super.key});

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => PantauanCubit()),
          BlocProvider(create: (_) => ThemeCubit()),
        ],
        child: BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, mode) => MaterialApp(
            title: 'Peringatan Dini AIoT',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: mode,
            home: const KerangkaAplikasi(),
          ),
        ),
      );
}

class KerangkaAplikasi extends StatefulWidget {
  const KerangkaAplikasi({super.key});

  @override
  State<KerangkaAplikasi> createState() => _KerangkaAplikasiState();
}

class _KerangkaAplikasiState extends State<KerangkaAplikasi> {
  int _indeks = 0;

  final _halaman = const [
    DashboardSensorPage(),
    RiwayatSensorPage(),
    PengaturanPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _halaman[_indeks],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indeks,
        onDestinationSelected: (index) => setState(() => _indeks = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.sensors), label: 'Pantauan'),
          NavigationDestination(icon: Icon(Icons.history), label: 'Riwayat'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Pengaturan'),
        ],
      ),
    );
  }
}
