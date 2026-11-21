import 'package:flutter_bloc/flutter_bloc.dart';

import '../db/database_helper.dart';
import '../models/laporan.dart';

class LaporanCubit extends Cubit<List<Laporan>> {
  LaporanCubit() : super(const []) {
    muatLaporan();
  }

  Future<void> muatLaporan() async {
    try {
      final daftar = await DatabaseHelper.instance.ambilSemuaLaporan();
      emit(daftar);
    } catch (_) {
      // Jika terjadi kesalahan koneksi db, biarkan state saat ini
    }
  }

  Future<int> tambahLaporan({
    required String kategori,
    required String lokasi,
    required String deskripsi,
    int nominal = 0,
    bool isAnonim = true,
  }) async {
    final waktu = DateTime.now();
    final nomorUnik = 'ANP-${waktu.millisecondsSinceEpoch.toString().substring(7)}';

    final laporanBaru = Laporan(
      nomor: nomorUnik,
      kategori: kategori,
      lokasi: lokasi,
      deskripsi: deskripsi,
      waktu: waktu,
      status: 'Menunggu verifikasi',
      nominal: nominal,
      isAnonim: isAnonim,
    );

    final id = await DatabaseHelper.instance.tambahLaporan(laporanBaru);
    await muatLaporan();
    return id;
  }

  Future<void> ubahLaporan(Laporan laporan) async {
    if (laporan.id == null) return;
    await DatabaseHelper.instance.ubahLaporan(laporan);
    await muatLaporan();
  }

  Future<void> hapusLaporan(int id) async {
    await DatabaseHelper.instance.hapusLaporan(id);
    await muatLaporan();
  }
}
