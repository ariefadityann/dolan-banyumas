import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart'; // Import Provider
import '../models/wisata_model.dart';
import '../pages/home/detail_wisata.dart';
import '../providers/favorites_provider.dart'; // Import FavoritesProvider

class RekomendasiCard extends StatelessWidget {
  final TempatWisata wisata;

  const RekomendasiCard({super.key, required this.wisata});

  @override
  Widget build(BuildContext context) {
    // --- LOGIKA FAVORIT DITAMBAHKAN DI SINI ---
    final favoritesProvider = Provider.of<FavoritesProvider>(context);
    final bool isFavorited = favoritesProvider.isFavorite(wisata);
    // -----------------------------------------

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailWisata(wisata: wisata),
          ),
        );
      },
      child: Container(
        width: 340,
        height: 180,
        margin: const EdgeInsets.only(right: 16, bottom: 10, top: 10),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Card Base (latar belakang putih)
            Positioned(
              top: 20,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withAlpha(38),
                      spreadRadius: 2,
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 140),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  wisata.nama,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  wisata.caption, // Menggunakan caption/deskripsi
                                  style: TextStyle(
                                      color: Colors.grey[600], fontSize: 12),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                SvgPicture.asset(
                                  'assets/icon/ticket.svg',
                                  width: 16,
                                  height: 16,
                                  colorFilter: const ColorFilter.mode(
                                      Colors.black, BlendMode.srcIn),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Rp ${wisata.harga}',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const Icon(Icons.location_on_outlined,
                                    color: Colors.black, size: 14),
                                const SizedBox(width: 4),
                                Text(wisata.jarak,
                                    style: const TextStyle(fontSize: 12)),
                                const SizedBox(width: 12),
                                const SizedBox(width: 4),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Lihat Selengkapnya',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold),
                                ),
                                // --- ICONBUTTON DIPERBARUI DI SINI ---
                                IconButton(
                                  onPressed: () {
                                    favoritesProvider.toggleFavorite(wisata);
                                  },
                                  icon: Icon(
                                    isFavorited
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: Colors.red,
                                    size: 24,
                                  ),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                                // -------------------------------------
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Gambar Wisata
            Positioned(
              top: -7,
              left: 15,
              child: Container(
                width: 120,
                height: 150,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(51),
                        spreadRadius: 2,
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      )
                    ]),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    wisata.gambarUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[200],
                        child: Icon(Icons.image_not_supported,
                            color: Colors.grey[400]),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

