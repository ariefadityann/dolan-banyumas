import 'package:flutter/material.dart';
import '../models/wisata_model.dart'; // Pastikan path ini benar

class WisataCard extends StatelessWidget {
  final TempatWisata wisata;

  const WisataCard({super.key, required this.wisata});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      margin: const EdgeInsets.only(bottom: 16),
      child: Stack(
        children: [
          // Gambar Background dari Network (API) - Flutter Web Compatible
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              image: wisata.gambarUrl.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(wisata.gambarUrl),
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                      onError: (error, stackTrace) {
                        print('❌ Image Load Error: $error');
                        print('   URL: ${wisata.gambarUrl}');
                      },
                    )
                  : null,
              color: wisata.gambarUrl.isEmpty ? Colors.grey[300] : null,
            ),
            child: wisata.gambarUrl.isEmpty
                ? const Center(
                    child: Icon(Icons.broken_image, color: Colors.grey, size: 40),
                  )
                : null,
          ),
          // Gradient Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                  begin: Alignment.bottomCenter,
                  end: Alignment.center,
                ),
              ),
            ),
          ),
          // Teks Nama Wisata
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Text(
              wisata.nama,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    blurRadius: 4.0,
                    color: Colors.black54,
                    offset: Offset(1.0, 1.0),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
