import 'package:flutter/material.dart';
// import 'package:dolan_banyumas/widgets/rekomendasi_card.dart'; // Sesuaikan path jika berbeda
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlong;
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/wisata_model.dart';
import '../../providers/favorites_provider.dart';

class DetailWisata extends StatefulWidget {
  final TempatWisata wisata;

  const DetailWisata({super.key, required this.wisata});

  @override
  State<DetailWisata> createState() => _DetailWisataState();
}

class _DetailWisataState extends State<DetailWisata> {
  late String _currentMainImage;
  int _selectedTabIndex = 0; // 0: Tentang, 1: Lokasi

  @override
  void initState() {
    super.initState();
    _currentMainImage = widget.wisata.gambarUrl;
  }

  Future<void> _launchMapsUrl() async {
    // 1. Ambil lat dan lng dari widget
    final lat = widget.wisata.lat;
    final lng = widget.wisata.lng;

    // 2. Buat URL Google Maps yang universal
    // Ini akan mencari berdasarkan koordinat
    final Uri googleMapsUrl =
        Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');

    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Tidak bisa membuka peta. Pastikan Google Maps terinstall.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final favoritesProvider = Provider.of<FavoritesProvider>(context);
    final isFavorited = favoritesProvider.isFavorite(widget.wisata);
    final List<String> allImages = [
      widget.wisata.gambarUrl,
      ...widget.wisata.images
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF9F8F5),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: screenHeight * 0.4,
            backgroundColor: const Color(0xFFF9F8F5),
            elevation: 0,
            pinned: true,
            stretch: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                    child: Image.asset(
                      _currentMainImage,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[300],
                        child: const Center(
                            child:
                                Icon(Icons.broken_image, color: Colors.grey)),
                      ),
                    ),
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.center,
                        colors: [
                          Colors.black,
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: screenWidth * 0.05,
                    right: screenWidth * 0.05,
                    child: _buildImageGallery(allImages, screenWidth),
                  ),
                ],
              ),
            ),
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon:
                    const Icon(Icons.arrow_back, color: Colors.white, size: 24),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    isFavorited ? Icons.favorite : Icons.favorite_border,
                    color: isFavorited ? Colors.red : Colors.white,
                    size: 24,
                  ),
                  onPressed: () {
                    favoritesProvider.toggleFavorite(widget.wisata);
                  },
                ),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(screenWidth * 0.06),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.wisata.nama.toUpperCase(),
                    style: TextStyle(
                      fontSize: screenWidth * 0.07,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF2D4A3E),
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.wisata.kategori.toUpperCase(),
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2D4A3E).withOpacity(0.7),
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildTabSelector(screenWidth),
                  const SizedBox(height: 32),
                  IndexedStack(
                    index: _selectedTabIndex,
                    children: [
                      _buildTentangSection(screenWidth),
                      _buildLocationSection(screenWidth),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomButton(screenWidth),
    );
  }

  Widget _buildTabSelector(double screenWidth) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(child: _buildTabButton('Tentang', 0, screenWidth)),
          Expanded(child: _buildTabButton('Lokasi', 1, screenWidth)),
        ],
      ),
    );
  }

  Widget _buildTabButton(String title, int index, double screenWidth) {
    final bool isSelected = _selectedTabIndex == index;
    final activeColor = const Color(0xFF2D4A3E);
    final inactiveColor = Colors.grey[700];

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTabIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.white : inactiveColor,
              fontWeight: FontWeight.w600,
              fontSize: screenWidth * 0.04,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text,
      {Color iconColor = const Color(0xFF2D4A3E), required double screenWidth}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: screenWidth * 0.04, // Sekitar 14-15px
                color: const Color(0xFF425C48),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFasilitasChip(IconData icon, String label) {
    return Chip(
      avatar: Icon(icon, color: const Color(0xFF2D4A3E), size: 18),
      label: Text(label),
      labelStyle:
          const TextStyle(color: Color(0xFF2D4A3E), fontWeight: FontWeight.w600),
      backgroundColor: const Color(0xFF2D4A3E).withOpacity(0.1),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: const Color(0xFF2D4A3E).withOpacity(0.2))),
    );
  }

  Widget _buildTentangSection(double screenWidth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- Bagian Info (Harga, Jarak, Jam, Alamat) ---
        _buildInfoRow(
          Icons.attach_money,
          'Rp ${widget.wisata.harga}',
          iconColor: Colors.green.shade700,
          screenWidth: screenWidth,
        ),
        _buildInfoRow(
          Icons.location_on_outlined,
          widget.wisata.jarak,
          screenWidth: screenWidth,
        ),
        _buildInfoRow(
          Icons.place_outlined,
          widget.wisata.alamat, // Menggunakan alamat dari model
          screenWidth: screenWidth,
        ),

        // --- PENTING: Placeholder untuk Jam Operasional ---
        // Ganti "08.00 - 17.00 WIB" dengan data dari model Anda jika ada
        // (Misal: widget.wisata.jamBuka)
        _buildInfoRow(
          Icons.access_time_outlined,
          '08.00 - 17.00 WIB', // Placeholder
          screenWidth: screenWidth,
        ),

        const SizedBox(height: 16),

        // --- Bagian Fasilitas (Placeholder) ---
        const Text(
          'Fasilitas',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Color(0xFF2D4A3E),
          ),
        ),
        const SizedBox(height: 16),
        // Ganti list ini dengan data dari model Anda jika ada
        // (Misal: widget.wisata.fasilitas.map((f) => _buildFasilitasChip(f.icon, f.nama)).toList())
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: [
            _buildFasilitasChip(Icons.wc, 'Toilet'),
            _buildFasilitasChip(Icons.storefront, 'Warung'),
            _buildFasilitasChip(Icons.mosque, 'Mushola'),
            _buildFasilitasChip(Icons.local_parking, 'Parkir'),
          ],
        ),
        // --- Akhir Bagian Fasilitas ---

        const SizedBox(height: 32),

        // --- Bagian Deskripsi (Tetap Sama) ---
        const Text(
          'Deskripsi',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Color(0xFF2D4A3E),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          widget.wisata.caption,
          style: TextStyle(
            fontSize: screenWidth * 0.035,
            color: const Color(0xFF666666).withOpacity(0.8),
            height: 1.5,
          ),
          textAlign: TextAlign.justify,
        ),
        const SizedBox(height: 40), // Spasi di bagian bawah
      ],
    );
  }

  Widget _buildLocationSection(double screenWidth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Lokasi',
          style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D4A3E)),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: screenWidth * 0.5,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: FlutterMap(
              options: MapOptions(
                initialCenter:
                    latlong.LatLng(widget.wisata.lat, widget.wisata.lng),
                initialZoom: 15.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.dolan_banyumas',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point:
                          latlong.LatLng(widget.wisata.lat, widget.wisata.lng),
                      width: 80,
                      height: 80,
                      child: Icon(
                        Icons.location_pin,
                        color: Colors.red,
                        size: screenWidth * 0.1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          widget.wisata.alamat,
          style: TextStyle(
              fontSize: screenWidth * 0.04, color: const Color(0xFF425C48)),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _launchMapsUrl,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF425C48),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              'Menuju lokasi',
              style: TextStyle(
                  fontSize: screenWidth * 0.045, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildImageGallery(List<String> images, double screenWidth) {
    final galleryHeight = screenWidth * 0.2;
    return Container(
      height: galleryHeight,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        itemBuilder: (context, index) {
          final imagePath = images[index];
          final bool isSelected = imagePath == _currentMainImage;
          return GestureDetector(
            onTap: () {
              setState(() {
                _currentMainImage = imagePath;
              });
            },
            child: Container(
              width: galleryHeight - 16,
              height: galleryHeight - 16,
              margin: const EdgeInsets.symmetric(horizontal: 6.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color:
                      isSelected ? const Color(0xFF2D4A3E) : Colors.transparent,
                  width: 3,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.broken_image, color: Colors.grey),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomButton(double screenWidth) {
    return Container(
      padding:
          EdgeInsets.symmetric(horizontal: screenWidth * 0.06, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          // Navigasi ke halaman booking
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2D4A3E),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Text(
          'PESAN SEKARANG',
          style: TextStyle(
            fontSize: screenWidth * 0.045,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}