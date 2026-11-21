import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/laporan_cubit.dart';
import '../cubit/theme_cubit.dart';
import '../models/laporan.dart';

class HalamanBeranda extends StatelessWidget {
  const HalamanBeranda({super.key});

  static const _hijau = Color(0xFF087E68);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
            sliver: SliverList.list(
              children: [
                Row(
                  children: [
                    Container(
                      height: 46,
                      width: 46,
                      decoration: BoxDecoration(
                        color: _hijau,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Icon(Icons.shield_outlined,
                          color: Colors.white, size: 27),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('ANPUNDUNG',
                            style: TextStyle(
                                fontWeight: FontWeight.w900, letterSpacing: 1)),
                        Text(
                          'Kota Bandung',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    const Icon(Icons.location_city_outlined, color: _hijau),
                  ],
                ),
                const SizedBox(height: 26),
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF087E68), Color(0xFF075B51)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Berani lapor, Bandung bebas pungli',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              height: 1.2,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 9),
                      Text(
                        'Laporkan pungutan liar dalam pelayanan publik dengan aman.',
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: .88),
                            height: 1.4),
                      ),
                      const SizedBox(height: 18),
                      BlocBuilder<LaporanCubit, List<Laporan>>(
                        builder: (context, laporan) => Row(
                          children: [
                            const Icon(Icons.assignment_turned_in_outlined,
                                color: Colors.white),
                            const SizedBox(width: 9),
                            Text('${laporan.length} laporan tercatat',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Card(
                  child: BlocBuilder<ThemeCubit, ThemeMode>(
                    builder: (context, mode) => SwitchListTile.adaptive(
                      secondary: Icon(
                        mode == ThemeMode.dark
                            ? Icons.dark_mode_outlined
                            : Icons.light_mode_outlined,
                      ),
                      title: const Text('Mode gelap'),
                      subtitle: Text(
                        mode == ThemeMode.dark
                            ? 'Tampilan gelap sedang aktif.'
                            : 'Tampilan terang sedang aktif.',
                      ),
                      value: mode == ThemeMode.dark,
                      onChanged: (_) => context.read<ThemeCubit>().ubahMode(),
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                const Text('Layanan Anpundung',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Row(
                  children: const [
                    Expanded(
                        child: _LayananCard(
                            icon: Icons.campaign_outlined,
                            title: 'Laporkan\nPungli',
                            color: Color(0xFFE6F4F0))),
                    SizedBox(width: 12),
                    Expanded(
                        child: _LayananCard(
                            icon: Icons.fact_check_outlined,
                            title: 'Pantau\nLaporan',
                            color: Color(0xFFFFF1DC))),
                    SizedBox(width: 12),
                    Expanded(
                        child: _LayananCard(
                            icon: Icons.menu_book_outlined,
                            title: 'Kenali\nPungli',
                            color: Color(0xFFE9EDFF))),
                  ],
                ),
                const SizedBox(height: 25),
                Row(
                  children: [
                    const Expanded(
                      child: Text('Laporan terbaru',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text('Lihat semua'),
                    ),
                  ],
                ),
                BlocBuilder<LaporanCubit, List<Laporan>>(
                  builder: (context, laporan) {
                    if (laporan.isEmpty) {
                      return const Text('Belum ada laporan.');
                    }
                    return _RingkasanLaporan(laporan: laporan.first);
                  },
                ),
                const SizedBox(height: 18),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.lock_outline_rounded, color: _hijau),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Identitas dan informasi laporan dijaga kerahasiaannya.',
                            style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            height: 1.35),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LayananCard extends StatelessWidget {
  const _LayananCard(
      {required this.icon, required this.title, required this.color});

  final IconData icon;
  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final skema = Theme.of(context).colorScheme;
    final bool modeGelap = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 118,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: modeGelap ? skema.surfaceContainerHigh : color,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: const Color(0xFF087E68)),
          Text(title,
              style: const TextStyle(fontWeight: FontWeight.w600, height: 1.2)),
        ],
      ),
    );
  }
}

class _RingkasanLaporan extends StatelessWidget {
  const _RingkasanLaporan({required this.laporan});

  final Laporan laporan;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(13)),
              child: const Icon(Icons.receipt_long, color: Color(0xFF087E68)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(laporan.kategori,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('${laporan.nomor} · ${laporan.lokasi}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      )),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}
