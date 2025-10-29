import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  final String? username;
  final VoidCallback onMenuPressed;
  final VoidCallback onSearchTap;

  const HomeHeader({
    super.key,
    this.username,
    required this.onMenuPressed,
    required this.onSearchTap,
    // Parameter onFilterTap telah dihapus dari sini
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Background image
        Container(
          height: 270,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/img/lokalwisata.jpg'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        // Overlay gradient
        Container(
          height: 20,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.3),
                Colors.transparent,
                Colors.black.withOpacity(0.5),
              ],
            ),
          ),
        ),

        // SafeArea & Content
        SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 0.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundImage: AssetImage('assets/img/logo.png'),
                          backgroundColor: Colors.transparent,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Dolan Banyumas',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon:
                          const Icon(Icons.menu, color: Colors.white, size: 28),
                      onPressed: onMenuPressed,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(height: 30),
                Center(
                  child: Column(
                    children: [
                      Text(
                        'Haii, ${username ?? 'Iyan'} 👋',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Tidak perlu pusing lagi!!\nAyo mulai perjalananmu di Banyumas!',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // --- Search Bar (tanpa filter) ---
        Positioned(
          bottom: -25,
          left: 20,
          right: 20,
          child: GestureDetector(
            onTap: onSearchTap, // Panggil callback saat diklik
            child: Container(
              height: 55,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: Colors.grey[600]),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Cari Destinasi',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ),
                  // ===== PERUBAHAN DI SINI =====
                  // SizedBox dan IconButton untuk filter telah dihapus
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
