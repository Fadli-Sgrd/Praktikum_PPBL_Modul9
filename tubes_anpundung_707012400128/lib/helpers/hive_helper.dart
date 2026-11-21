import 'package:hive_flutter/hive_flutter.dart';
import '../models/pantauan_laporan.dart';

class HiveHelper {
  HiveHelper._internal();
  static final HiveHelper instance = HiveHelper._internal();

  static const String namaBoxPantauan = 'pantauanLaporanBox';

  static Future<void> init() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(PantauanLaporanAdapter());
    }
    await Hive.openBox<PantauanLaporan>(namaBoxPantauan);
  }

  static Box<PantauanLaporan> get box =>
      Hive.box<PantauanLaporan>(namaBoxPantauan);

  Future<void> simpanPantauan(PantauanLaporan laporan) async {
    await box.put(laporan.nomorLaporan, laporan);
  }

  bool isDipantau(String nomorLaporan) {
    return box.containsKey(nomorLaporan);
  }

  Future<void> togglePantauan(PantauanLaporan laporan) async {
    if (box.containsKey(laporan.nomorLaporan)) {
      await box.delete(laporan.nomorLaporan);
    } else {
      await box.put(laporan.nomorLaporan, laporan);
    }
  }

  Future<void> hapusPantauan(String nomorLaporan) async {
    await box.delete(nomorLaporan);
  }
}
