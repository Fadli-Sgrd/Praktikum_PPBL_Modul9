import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:aiot_peringatan_dini_hive/main.dart';
import 'package:aiot_peringatan_dini_hive/helpers/hive_helper.dart';
import 'package:aiot_peringatan_dini_hive/models/pembacaan_sensor.dart';

void main() {
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_test_');
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(PembacaanSensorAdapter());
    }
    await Hive.openBox<PembacaanSensor>(HiveHelper.namaBoxPembacaan);
  });

  tearDownAll(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  testWidgets('Aplikasi peringatan dini displays header and nav', (WidgetTester tester) async {
    await tester.pumpWidget(const AplikasiPeringatanDini());
    await tester.pumpAndSettle();

    expect(find.text('Pantauan'), findsOneWidget);
    expect(find.text('Riwayat'), findsOneWidget);
    expect(find.text('Pengaturan'), findsOneWidget);
  });
}
