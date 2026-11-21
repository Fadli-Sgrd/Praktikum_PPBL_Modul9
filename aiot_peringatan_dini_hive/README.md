# AIoT Peringatan Dini SQLite

Implementasi Soal 1 Modul VIII: pencatatan lokal pembacaan sensor untuk pemantauan bencana.

## Menjalankan

```bash
flutter pub get
# Jalankan sekali untuk menyiapkan sqlite3.wasm dan sqflite_sw.js di web/.
dart run sqflite_common_ffi_web:setup
flutter run -d chrome --web-port 55129
```

Pada browser, setup satu kali membuat SQLite WASM dan worker yang dibutuhkan adapter web. Data web tersimpan di IndexedDB browser; gunakan port localhost yang sama saat menjalankan ulang agar membuka penyimpanan yang sama. Pada Android/iOS, aplikasi memakai plugin `sqflite` native. Di tab **Pantauan**, tekan **Input sensor**, pilih jenis sensor, masukkan nilai dan lokasi pos, lalu simpan. Tab **Riwayat** membaca semua catatan dari SQLite, menampilkan status siaga berdasarkan nilai terbaru setiap jenis sensor, memungkinkan koreksi nilai dengan mengetuk baris, dan menghapus baris dengan menggesernya ke kiri.

## Struktur

- `lib/models/pembacaan_sensor.dart`: model sensor dan konversi `toMap`/`fromMap`.
- `lib/db/database_helper.dart`: singleton SQLite, skema `pembacaan_sensor`, serta operasi Create, Read, Update, dan Delete.
- `lib/cubit/pantauan_cubit.dart`: data pantauan sementara untuk sesi aplikasi.
- `lib/pages/riwayat_sensor_page.dart`: data riwayat dan status siaga dibaca dari SQLite.

Database `aiot_peringatan_dini.db` dibuat lokal di perangkat dan tidak memerlukan koneksi internet. Status menggunakan nilai ambang praktikum: ketinggian air 100/150 cm, pergeseran tanah 5/8 mm, dan curah hujan 50/100 mm per jam untuk Waspada/Siaga. Sesuaikan ambang ini dengan standar BPBD sebelum penggunaan nyata.
