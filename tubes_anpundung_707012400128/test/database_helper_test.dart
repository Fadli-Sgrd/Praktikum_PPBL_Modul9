import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:tubes_anpundung_707012400128/db/database_helper.dart';
import 'package:tubes_anpundung_707012400128/models/laporan.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test('DatabaseHelper CRUD operations for Anpundung', () async {
    final helper = DatabaseHelper.instance;

    // 1. Create (Insert)
    final laporanBaru = Laporan(
      nomor: 'ANP-TEST01',
      kategori: 'Parkir',
      lokasi: 'Jl. Braga No. 12',
      deskripsi: 'Tarif parkir motor diminta Rp 10.000 tanpa karcis resmi.',
      waktu: DateTime.now(),
      status: 'Menunggu verifikasi',
      nominal: 10000,
      isAnonim: true,
    );

    final id = await helper.tambahLaporan(laporanBaru);
    expect(id, greaterThan(0));

    // 2. Read
    final semua = await helper.ambilSemuaLaporan();
    expect(semua.any((item) => item.id == id), isTrue);

    final fetched = await helper.ambilLaporanById(id);
    expect(fetched, isNotNull);
    expect(fetched!.nomor, equals('ANP-TEST01'));
    expect(fetched.nominal, equals(10000));

    // 3. Update
    final laporanDiubah = fetched.copyWith(
      status: 'Terverifikasi',
      deskripsi: 'Tarif parkir motor diminta Rp 10.000 (Terverifikasi oleh satpol PP).',
    );
    final countUpdate = await helper.ubahLaporan(laporanDiubah);
    expect(countUpdate, equals(1));

    final setelahUpdate = await helper.ambilLaporanById(id);
    expect(setelahUpdate!.status, equals('Terverifikasi'));

    // 4. Delete
    final countDelete = await helper.hapusLaporan(id);
    expect(countDelete, equals(1));

    final setelahDelete = await helper.ambilLaporanById(id);
    expect(setelahDelete, isNull);
  });
}

