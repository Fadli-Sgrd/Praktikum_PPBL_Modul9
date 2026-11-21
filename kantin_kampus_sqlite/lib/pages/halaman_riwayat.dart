import 'package:flutter/material.dart';

import '../db/database_helper.dart';
import '../models/pesanan.dart';

class HalamanRiwayat extends StatefulWidget {
  const HalamanRiwayat({super.key});

  @override
  State<HalamanRiwayat> createState() => _HalamanRiwayatState();
}

class _HalamanRiwayatState extends State<HalamanRiwayat> {
  late Future<List<Pesanan>> _pesanan;

  @override
  void initState() {
    super.initState();
    _muatUlangData();
  }

  void _muatUlangData() {
    setState(() {
      _pesanan = DatabaseHelper.instance.ambilSemuaPesanan();
    });
  }

  Future<void> _ubahJumlah(Pesanan pesanan) async {
    final controller = TextEditingController(text: '${pesanan.totalItem}');
    final jumlah = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ubah Jumlah Item'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Jumlah item'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          FilledButton(
            onPressed: () => Navigator.pop(context, int.tryParse(controller.text)),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (jumlah == null || jumlah < 1 || pesanan.id == null) return;
    await DatabaseHelper.instance.ubahPesanan(Pesanan(
      id: pesanan.id,
      ringkasanItem: pesanan.ringkasanItem,
      totalItem: jumlah,
      totalHarga: pesanan.totalHarga,
      tanggal: pesanan.tanggal,
    ));
    if (mounted) _muatUlangData();
  }

  Future<void> _hapus(Pesanan pesanan) async {
    if (pesanan.id == null) return;
    await DatabaseHelper.instance.hapusPesanan(pesanan.id!);
    if (mounted) _muatUlangData();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Riwayat Pesanan')),
        body: FutureBuilder<List<Pesanan>>(
          future: _pesanan,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Gagal memuat pesanan: ${snapshot.error}'));
            }
            final daftar = snapshot.data ?? [];
            if (daftar.isEmpty) {
              return const Center(child: Text('Belum ada riwayat pesanan.'));
            }
            return ListView.builder(
              itemCount: daftar.length,
              itemBuilder: (context, index) {
                final pesanan = daftar[index];
                return Dismissible(
                  key: ValueKey(pesanan.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Theme.of(context).colorScheme.error,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) => _hapus(pesanan),
                  child: ListTile(
                    title: Text(pesanan.ringkasanItem),
                    subtitle: Text('${pesanan.totalItem} item • ${pesanan.tanggal}'),
                    trailing: Text('Rp${pesanan.totalHarga}'),
                    onTap: () => _ubahJumlah(pesanan),
                  ),
                );
              },
            );
          },
        ),
      );
}
