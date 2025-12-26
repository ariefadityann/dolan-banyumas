import 'package:flutter/material.dart';
import '../models/wisata_model.dart'; // Pastikan path ini benar
import '../config/app_config.dart'; // Import AppConfig

class WisataCard extends StatelessWidget {
  final TempatWisata wisata;

  const WisataCard({super.key, required this.wisata});

  @override
  Widget build(BuildContext context) {
    // Generate full URL from relative path
    final String imageUrl = AppConfig.getImageUrl(wisata.gambarUrl);

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
              image: imageUrl.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                      onError: (error, stackTrace) {
                        print('❌ Image Load Error: $error');
                        print('   URL: $imageUrl');
                      },
                    )
                  : null,
              color: imageUrl.isEmpty ? Colors.grey[300] : null,
            ),
            child: imageUrl.isEmpty
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
