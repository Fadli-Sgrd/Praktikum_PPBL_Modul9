import 'package:shared_preferences/shared_preferences.dart';

class PengaturanHelper {
  PengaturanHelper._();

  static const String kunciTemaGelap = 'tema_gelap';
  static const String kunciNamaPelapor = 'nama_pelapor';
  static const String kunciKontakPelapor = 'kontak_pelapor';
  static const String kunciModeAnonim = 'mode_anonim_default';

  static Future<bool> muatTemaGelap() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(kunciTemaGelap) ?? false;
  }

  static Future<void> simpanTemaGelap(bool aktif) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(kunciTemaGelap, aktif);
  }

  static Future<String> muatNamaPelapor() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(kunciNamaPelapor) ?? '';
  }

  static Future<void> simpanNamaPelapor(String nama) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(kunciNamaPelapor, nama);
  }

  static Future<String> muatKontakPelapor() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(kunciKontakPelapor) ?? '';
  }

  static Future<void> simpanKontakPelapor(String kontak) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(kunciKontakPelapor, kontak);
  }

  static Future<bool> muatModeAnonim() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(kunciModeAnonim) ?? true;
  }

  static Future<void> simpanModeAnonim(bool aktif) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(kunciModeAnonim, aktif);
  }

  static Future<void> resetSemua() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(kunciTemaGelap);
    await prefs.remove(kunciNamaPelapor);
    await prefs.remove(kunciKontakPelapor);
    await prefs.remove(kunciModeAnonim);
  }
}
