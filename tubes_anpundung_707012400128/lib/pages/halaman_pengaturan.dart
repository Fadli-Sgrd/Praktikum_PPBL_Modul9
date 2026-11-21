import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/theme_cubit.dart';
import '../helpers/pengaturan_helper.dart';

class HalamanPengaturan extends StatefulWidget {
  const HalamanPengaturan({super.key});

  @override
  State<HalamanPengaturan> createState() => _HalamanPengaturanState();
}

class _HalamanPengaturanState extends State<HalamanPengaturan> {
  bool _temaGelap = false;
  bool _modeAnonim = true;
  final _namaController = TextEditingController();
  final _kontakController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _muatPengaturan();
  }

  Future<void> _muatPengaturan() async {
    final gelap = await PengaturanHelper.muatTemaGelap();
    final nama = await PengaturanHelper.muatNamaPelapor();
    final kontak = await PengaturanHelper.muatKontakPelapor();
    final anonim = await PengaturanHelper.muatModeAnonim();
    if (mounted) {
      setState(() {
        _temaGelap = gelap;
        _namaController.text = nama;
        _kontakController.text = kontak;
        _modeAnonim = anonim;
      });
    }
  }

  Future<void> _resetSemua() async {
    await PengaturanHelper.resetSemua();
    if (_temaGelap && mounted) {
      context.read<ThemeCubit>().toggle();
    }
    if (mounted) {
      setState(() {
        _temaGelap = false;
        _modeAnonim = true;
        _namaController.clear();
        _kontakController.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preferensi berhasil direset.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _kontakController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan & Preferensi'),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Tampilan Aplikasi',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Card(
            child: SwitchListTile(
              secondary: Icon(
                _temaGelap ? Icons.dark_mode : Icons.light_mode,
                color: const Color(0xFF1976D2),
              ),
              title: const Text('Mode Gelap'),
              subtitle: Text(_temaGelap ? 'Tema gelap aktif' : 'Tema terang aktif'),
              value: _temaGelap,
              onChanged: (val) async {
                setState(() => _temaGelap = val);
                await PengaturanHelper.simpanTemaGelap(val);
                if (context.mounted) {
                  context.read<ThemeCubit>().toggle();
                }
              },
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Profil & Preferensi Pelapor',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          const Text(
            'Disimpan untuk mempercepat pengisian formulir pengaduan pungli.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: _namaController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Lengkap Pelapor',
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (val) async {
                      await PengaturanHelper.simpanNamaPelapor(val);
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _kontakController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Nomor Kontak / WhatsApp',
                      prefixIcon: Icon(Icons.phone_outlined),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (val) async {
                      await PengaturanHelper.simpanKontakPelapor(val);
                    },
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Default Pengaduan Anonim'),
                    subtitle: const Text('Sembunyikan identitas pelapor saat membuat aduan baru'),
                    value: _modeAnonim,
                    onChanged: (val) async {
                      setState(() => _modeAnonim = val);
                      await PengaturanHelper.simpanModeAnonim(val);
                    },
                  ),
                ],
              ),
            ),
          ),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
            ),
            onPressed: _resetSemua,
            icon: const Icon(Icons.restore),
            label: const Text('Reset Preferensi'),
          ),
        ],
      ),
    );
  }
}
