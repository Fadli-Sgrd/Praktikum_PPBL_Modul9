# Kantin Kampus SQLite

Aplikasi praktikum Modul VIII yang menyimpan riwayat checkout secara lokal memakai SQLite.

## Menjalankan

```bash
flutter pub get
flutter run
```

SQLite melalui `sqflite` digunakan pada Android/iOS. Tambahkan produk ke keranjang dan pilih **Checkout** untuk menyimpan pesanan. Buka tab **Riwayat** untuk membaca pesanan; ketuk baris untuk mengubah jumlah item atau geser ke kiri untuk menghapusnya.

## Struktur penting

- `lib/models/pesanan.dart`: model dan konversi `toMap`/`fromMap`.
- `lib/db/database_helper.dart`: koneksi singleton, pembuatan tabel, serta operasi CRUD dengan kondisi `id = ?`.
- `lib/pages/halaman_keranjang.dart`: menyimpan checkout ke SQLite.
- `lib/pages/halaman_riwayat.dart`: membaca, mengubah, dan menghapus riwayat.

Database `kantin_kampus.db` dibuat pada perangkat saat pertama kali dibuka.
