import 'package:shared_preferences/shared_preferences.dart';

class PengaturanHelper {
  PengaturanHelper._();

  static const String keyBatasWaspadaAir = 'batas_waspada_air';
  static const String keyBatasSiagaAir = 'batas_siaga_air';

  static const String keyBatasWaspadaTanah = 'batas_waspada_tanah';
  static const String keyBatasSiagaTanah = 'batas_siaga_tanah';

  static const String keyBatasWaspadaHujan = 'batas_waspada_hujan';
  static const String keyBatasSiagaHujan = 'batas_siaga_hujan';

  static Future<Map<String, double>> muatSemuaAmbangBatas() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      keyBatasWaspadaAir: prefs.getDouble(keyBatasWaspadaAir) ?? 2.0,
      keyBatasSiagaAir: prefs.getDouble(keyBatasSiagaAir) ?? 3.5,
      keyBatasWaspadaTanah: prefs.getDouble(keyBatasWaspadaTanah) ?? 5.0,
      keyBatasSiagaTanah: prefs.getDouble(keyBatasSiagaTanah) ?? 10.0,
      keyBatasWaspadaHujan: prefs.getDouble(keyBatasWaspadaHujan) ?? 50.0,
      keyBatasSiagaHujan: prefs.getDouble(keyBatasSiagaHujan) ?? 100.0,
    };
  }

  static Future<void> simpanAmbangBatas(String key, double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(key, value);
  }

  static String hitungStatusSiaga(
      String jenisSensor, double nilai, Map<String, double> batas) {
    double waspada = 2.0;
    double siaga = 3.5;

    if (jenisSensor == 'ketinggian_air') {
      waspada = batas[keyBatasWaspadaAir] ?? 2.0;
      siaga = batas[keyBatasSiagaAir] ?? 3.5;
    } else if (jenisSensor == 'pergeseran_tanah') {
      waspada = batas[keyBatasWaspadaTanah] ?? 5.0;
      siaga = batas[keyBatasSiagaTanah] ?? 10.0;
    } else if (jenisSensor == 'curah_hujan') {
      waspada = batas[keyBatasWaspadaHujan] ?? 50.0;
      siaga = batas[keyBatasSiagaHujan] ?? 100.0;
    }

    if (nilai >= siaga) return 'Siaga';
    if (nilai >= waspada) return 'Waspada';
    return 'Aman';
  }
}
