import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:tubes_anpundung_707012400128/cubit/laporan_cubit.dart';
import 'package:tubes_anpundung_707012400128/cubit/theme_cubit.dart';
import 'package:tubes_anpundung_707012400128/helpers/hive_helper.dart';
import 'package:tubes_anpundung_707012400128/models/pantauan_laporan.dart';
import 'package:tubes_anpundung_707012400128/main.dart';

Widget _buatAplikasiUntukTes() {
  return MultiBlocProvider(
    providers: [
      BlocProvider<LaporanCubit>(create: (_) => LaporanCubit()),
      BlocProvider<ThemeCubit>(create: (_) => ThemeCubit()),
    ],
    child: const AnpundungApp(),
  );
}

void main() {
  late Directory tempDir;

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    tempDir = await Directory.systemTemp.createTemp('hive_anpundung_test_');
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(PantauanLaporanAdapter());
    }
    await Hive.openBox<PantauanLaporan>(HiveHelper.namaBoxPantauan);
  });

  tearDownAll(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  testWidgets('Aplikasi Anpundung menampilkan navigasi dan judul beranda', (tester) async {
    await tester.pumpWidget(_buatAplikasiUntukTes());
    await tester.pumpAndSettle();

    expect(find.text('ANPUNDUNG'), findsOneWidget);
    expect(find.text('Beranda'), findsOneWidget);
    expect(find.text('Lapor'), findsOneWidget);
    expect(find.text('Riwayat'), findsOneWidget);
    expect(find.text('Pantauan'), findsOneWidget);
    expect(find.text('Pengaturan'), findsOneWidget);
  });

  testWidgets('Sakelar mode gelap mengubah tema aplikasi', (tester) async {
    await tester.pumpWidget(_buatAplikasiUntukTes());
    await tester.pumpAndSettle();

    expect(tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
        ThemeMode.light);

    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();

    expect(tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
        ThemeMode.dark);
  });
}
