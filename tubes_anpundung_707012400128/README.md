# Anpundung Bandung

Aplikasi contoh untuk melaporkan dan memantau pungutan liar pada layanan publik di Kota Bandung.

## State management

- Form laporan memakai `setState()` untuk kategori kejadian dan pilihan laporan anonim.
- `LaporanCubit` mengelola daftar laporan bersama yang ditampilkan di beranda dan riwayat.
- `ThemeCubit` mengelola mode terang dan gelap. Sakelarnya tersedia di beranda.

Data laporan masih disimpan di memori dan akan kembali ke data awal saat aplikasi dimulai ulang.

## Menjalankan aplikasi

```sh
flutter pub get
flutter run
```
