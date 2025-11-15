import 'package:flutter/material.dart'; // import 'package:dolan_banyumas/widgets/rekomendasi_card.dart'; // Sesuaikan path jika berbeda
import 'package:flutter_map/flutter_map.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
  int _selectedTabIndex = 0; // 0: Tentang, 1: Lokasi, 2: Review

  @override
  void initState() {
    super.initState();
    _currentMainImage = widget.wisata.gambarUrl;
  }

  void _showDummySnackBar(String platform) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Menuju ke halaman $platform (dummy)'),
        duration: const Duration(seconds: 2),
      ),
    );
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
            expandedHeight: screenHeight * 0.3,
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
                      color: const Color(0xFFF44336),
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.wisata.kategori.toUpperCase(),
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.w600,
                      color: const Color.fromARGB(255, 74, 45, 45)
                          .withOpacity(0.7),
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildTabSelector(screenWidth),
                  const SizedBox(height: 32),
                  IndexedStack(
                    index: _selectedTabIndex,
                    children: [
                      _buildTentangSection(screenWidth, allImages),
                      _buildGambarSection(screenWidth, allImages),
                      _buildReviewSection(
                        screenWidth,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFullScreenImage(String imagePath) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Dialog(
            insetPadding: EdgeInsets.zero,
            backgroundColor: Colors.black.withOpacity(0.85),
            child: Stack(
              children: [
                InteractiveViewer(
                  panEnabled: true,
                  scaleEnabled: true,
                  child: Center(
                    child: Image.asset(
                      imagePath,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[900],
                        child:
                            const Icon(Icons.broken_image, color: Colors.white),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 32,
                  right: 16,
                  child: SafeArea(
                    child: InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
          Expanded(child: _buildTabButton('Gambar', 1, screenWidth)),
          Expanded(child: _buildTabButton('Review', 2, screenWidth)),
        ],
      ),
    );
  }

  Widget _buildTabButton(String title, int index, double screenWidth) {
    final bool isSelected = _selectedTabIndex == index;
    final activeColor = const Color(0xFFF44336);
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
      {Color iconColor = const Color(0xFF2D4A3E),
      required double screenWidth}) {
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
                color: const Color.fromARGB(255, 92, 66, 66),
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
      avatar: Icon(icon, color: const Color(0xFFF44336), size: 18),
      label: Text(label),
      labelStyle: const TextStyle(
          color: Color.fromARGB(255, 74, 45, 46), fontWeight: FontWeight.w600),
      backgroundColor: const Color(0xFFFFE6E5).withOpacity(0.1),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: const Color(0xFFF44336).withOpacity(0.2))),
    );
  }

  Widget _buildTentangSection(double screenWidth, List<String> allImages) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- Bagian Info (Harga, Jarak, Jam, Alamat) ---
        _buildInfoRow(
          Icons.attach_money,
          'Rp ${widget.wisata.harga}',
          iconColor: Colors.red.shade700,
          screenWidth: screenWidth,
        ),
        _buildInfoRow(
          Icons.location_on_outlined,
          iconColor: Colors.red.shade700,
          widget.wisata.jarak,
          screenWidth: screenWidth,
        ),
        _buildInfoRow(
          FontAwesomeIcons.route,
          widget.wisata.alamat, // Menggunakan alamat dari model
          iconColor: Colors.red.shade700,
          screenWidth: screenWidth,
        ),
        // --- PENTING: Placeholder untuk Jam Operasional ---
        // Ganti "08.00 - 17.00 WIB" dengan data dari model Anda jika ada
        // (Misal: widget.wisata.jamBuka)
        _buildInfoRow(
          Icons.access_time_outlined,
          '08.00 - 17.00 WIB', // Placeholder
          iconColor: Colors.red.shade700,
          screenWidth: screenWidth,
        ),
        _buildInfoRow(
          Icons.phone,
          widget.wisata.telepon, // Menggunakan alamat dari model
          iconColor: Colors.red.shade700,
          screenWidth: screenWidth,
        ),
        const SizedBox(height: 16),

        // --- Bagian Fasilitas (Placeholder) ---
        const Text(
          'Fasilitas',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Color(0xFFF44336),
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
        const SizedBox(height: 24),

// --- Bagian Media Sosial (BARU) ---
        const Text(
          'Media Sosial',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Color(0xFFF44336),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 16,
          children: [
            IconButton(
              icon: const Icon(FontAwesomeIcons.instagram,
                  size: 28, color: Colors.pink),
              onPressed: () => _showDummySnackBar('Instagram'),
            ),
            IconButton(
              icon: const Icon(FontAwesomeIcons.whatsapp,
                  size: 28, color: Colors.green),
              onPressed: () => _showDummySnackBar('WhatsApp'),
            ),
            IconButton(
              icon: const Icon(FontAwesomeIcons.facebook,
                  size: 28, color: Colors.blue),
              onPressed: () => _showDummySnackBar('Facebook'),
            ),
            IconButton(
              icon: const Icon(FontAwesomeIcons.tiktok,
                  size: 28, color: Colors.black),
              onPressed: () => _showDummySnackBar('TikTok'),
            ),
            IconButton(
              icon: const Icon(FontAwesomeIcons.youtube,
                  size: 28, color: Colors.red),
              onPressed: () => _showDummySnackBar('YouTube'),
            ),
          ],
        ),
        const SizedBox(height: 32),

        // --- Bagian Deskripsi (Tetap Sama) ---
        const Text(
          'Deskripsi',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Color(0xFFF44336),
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
        const SizedBox(height: 24),
        // --- Lokasi (dipindahkan ke bawah deskripsi) ---
        _buildLocationMapSection(screenWidth),
        const SizedBox(height: 40), // Spasi di bagian bawah
      ],
    );
  }

  Widget _buildLocationMapSection(double screenWidth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        const Text(
          'Lokasi',
          style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFFF44336)),
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
              fontSize: screenWidth * 0.04, color: const Color(0xFFF44336)),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _launchMapsUrl,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF44336),
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
      ],
    );
  }

  Widget _buildGambarSection(double screenWidth, List<String> allImages) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Gambar',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Color(0xFFF44336),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 180,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: allImages.map((imagePath) {
                return GestureDetector(
                  onTap: () {
                    _showFullScreenImage(imagePath);
                  },
                  child: Container(
                    width: 340,
                    height: 180,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        imagePath,
                        width: 340,
                        height: 180,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.broken_image,
                              color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildReviewSection(double screenWidth) {
    final List<Map<String, String>> reviews = [
      {
        'nama': 'Rina',
        'komentar': 'Tempatnya sejuk dan indah! Cocok buat healing.'
      },
      {
        'nama': 'Bagus',
        'komentar': 'Pemandangannya keren, cuma akses jalannya agak sempit.'
      },
      {
        'nama': 'Lina',
        'komentar': 'Bersih, banyak spot foto bagus! Recommended!'
      },
    ];

    final TextEditingController _namaController = TextEditingController();
    final TextEditingController _komentarController = TextEditingController();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Review Pengunjung',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Color(0xFFF44336),
          ),
        ),
        const SizedBox(height: 16),

        // --- Daftar komentar dummy ---
        Column(
          children: reviews.map((review) {
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.red.shade100),
              ),
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review['nama']!,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: screenWidth * 0.04,
                        color: const Color(0xFFF44336),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      review['komentar']!,
                      style: TextStyle(
                        fontSize: screenWidth * 0.037,
                        color: Colors.grey[700],
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 24),

        // --- Form input komentar ---
        const Text(
          'Tambahkan Komentar',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFFF44336),
          ),
        ),
        const SizedBox(height: 12),

        // Nama
        TextField(
          controller: _namaController,
          style: const TextStyle(color: Colors.black),
          decoration: InputDecoration(
            labelText: 'Nama',
            labelStyle: const TextStyle(color: Color(0xFFF44336)),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red.shade200),
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Color(0xFFF44336), width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Komentar
        TextField(
          controller: _komentarController,
          style: const TextStyle(color: Colors.black),
          maxLines: 3,
          decoration: InputDecoration(
            labelText: 'Komentar',
            labelStyle: const TextStyle(color: Color(0xFFF44336)),
            alignLabelWithHint: true,
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red.shade200),
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Color(0xFFF44336), width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Tombol kirim (dummy)
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              if (_namaController.text.isEmpty ||
                  _komentarController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Nama dan komentar tidak boleh kosong'),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Komentar berhasil dikirim (dummy) 😊'),
                  ),
                );
                _namaController.clear();
                _komentarController.clear();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF44336),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Kirim',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}
