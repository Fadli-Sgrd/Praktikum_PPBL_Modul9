import 'package:hive_flutter/hive_flutter.dart';
import '../models/pembacaan_sensor.dart';

class HiveHelper {
  HiveHelper._internal();
  static final HiveHelper instance = HiveHelper._internal();

  static const String namaBoxPembacaan = 'pembacaanSensorBox';

  static Future<void> init() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(PembacaanSensorAdapter());
    }
    await Hive.openBox<PembacaanSensor>(namaBoxPembacaan);
  }

  static Box<PembacaanSensor> get box =>
      Hive.box<PembacaanSensor>(namaBoxPembacaan);

  Future<void> tambahPembacaan(PembacaanSensor pembacaan) async {
    await box.put(pembacaan.id, pembacaan);
  }

  List<PembacaanSensor> muatSemuaPembacaan() {
    final list = box.values.toList();
    list.sort((a, b) => b.waktu.compareTo(a.waktu));
    return list;
  }

  Future<void> hapusPembacaan(String id) async {
    await box.delete(id);
  }
}
