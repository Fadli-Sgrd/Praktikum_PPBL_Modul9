import 'package:flutter_test/flutter_test.dart';
import 'package:kantin_kampus_sqlite/db/database_helper.dart';
import 'package:kantin_kampus_sqlite/models/pesanan.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test('DatabaseHelper CRUD operations for kantin_kampus_sqlite', () async {
    final helper = DatabaseHelper.instance;

    // Create
    final pesanan = Pesanan(
      ringkasanItem: 'Nasi Goreng x2, Es Teh Manis x1',
      totalItem: 3,
      totalHarga: 35000,
      tanggal: '2026-11-13 18:30:00',
    );
    final id = await helper.tambahPesanan(pesanan);
    expect(id, greaterThan(0));

    // Read
    final daftar = await helper.ambilSemuaPesanan();
    expect(daftar.any((p) => p.id == id), isTrue);

    // Update
    final barisTerbaru = daftar.firstWhere((p) => p.id == id);
    await helper.ubahPesanan(Pesanan(
      id: barisTerbaru.id,
      ringkasanItem: barisTerbaru.ringkasanItem,
      totalItem: 5,
      totalHarga: barisTerbaru.totalHarga,
      tanggal: barisTerbaru.tanggal,
    ));
    final daftarSetelahUpdate = await helper.ambilSemuaPesanan();
    final updated = daftarSetelahUpdate.firstWhere((p) => p.id == id);
    expect(updated.totalItem, equals(5));

    // Delete
    await helper.hapusPesanan(id);
    final daftarSetelahHapus = await helper.ambilSemuaPesanan();
    expect(daftarSetelahHapus.any((p) => p.id == id), isFalse);
  });
}

