import 'package:flutter/material.dart'; 
import 'package:flutter_bloc/flutter_bloc.dart'; 
import '../cubit/keranjang_cubit.dart'; 
import '../models/produk.dart'; 
import '../widgets/cart_summary_bar.dart'; 
import '../cubit/theme_toggle_button.dart';
import '../db/database_helper.dart';
import '../models/pesanan.dart';
import 'halaman_riwayat.dart';
 
class HalamanKeranjang extends StatelessWidget { 
  const HalamanKeranjang({super.key}); 

  Future<void> _checkout(BuildContext context, List<ItemKeranjang> items, int totalItem, int totalHarga) async {
    if (items.isEmpty) return;
    final ringkasan = items.map((item) => '${item.produk.nama} x${item.jumlah}').join(', ');
    await DatabaseHelper.instance.tambahPesanan(Pesanan(
      ringkasanItem: ringkasan,
      totalItem: totalItem,
      totalHarga: totalHarga,
      tanggal: DateTime.now().toLocal().toString().substring(0, 19),
    ));
    if (!context.mounted) return;
    context.read<KeranjangCubit>().kosongkan();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pesanan berhasil disimpan.')));
  }
 
  @override 
  Widget build(BuildContext context) { 
    return Scaffold( 
      appBar: AppBar( 
        title: const Text('Keranjang'), 
        actions: [
          const ThemeToggleButton(),
          IconButton(
            icon: const Icon(Icons.receipt_long),
            tooltip: 'Riwayat Pesanan',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HalamanRiwayat()),
              );
            },
          ),
        ], 
      ), 
      body: BlocBuilder<KeranjangCubit, List<ItemKeranjang>>( 
        builder: (context, daftarItem) { 
          final totalItem = daftarItem.fold(0, (a, b) => a + b.jumlah); 
          final totalHarga = daftarItem.fold(0, (a, b) => a + b.subtotal);
          return Column( 
            children: [ 
              Expanded( 
                child: ListView.builder( 
                  itemCount: daftarItem.length, 
                  itemBuilder: (context, index) { 
                    final item = daftarItem[index]; 
                    return ListTile( 
                      title: Text(item.produk.nama), 
                      subtitle: Text('${item.jumlah} x Rp${item.produk.harga}'), 
                      trailing: Text('Rp${item.subtotal}'), 
                    ); 
                  }, 
                ), 
              ), 
              CartSummaryBar( 
                totalItem: totalItem, 
                totalHarga: totalHarga, 
                onKosongkan: () => context.read<KeranjangCubit>().kosongkan(), 
                onCheckout: () => _checkout(context, daftarItem, totalItem, totalHarga),
              ), 
            ], 
          ); 
        }, 
      ), 
    ); 
  } 
}
