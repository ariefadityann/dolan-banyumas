import 'package:flutter/material.dart';

class MorePage extends StatefulWidget {
  const MorePage({super.key});

  @override
  State<MorePage> createState() => _MorePageState();
}

class _MorePageState extends State<MorePage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final Map<String, List<String>> _allMenuData = {
    'Wisata': [
      'Tiket Wisata',
      'Bus Pariwisata',
      'Terdekat',
      'Objek Wisata',
      'Event',
      'Oleh Oleh',
      'Desa Wisata',
      'Kuliner',
      'Penginapan',
      'Biro Perjalanan',
    ],
    'Kesehatan': ['PSC 119', 'Simpus'],
    'Pendidikan': ['PPDB Online SMP'],
    'Perekonomian': ['Galeri UMKM'],
    'Lingkungan Hidup': ['Jeknyong'],
    'Layanan Umum': ['Info Banyumas'],
    'Pemerintahan': ['Perizinan Online', 'Eling PBB', 'SimPKB'],
    'Unggulan Desa': ['Sistem Informasi Desa'],
    'Darurat': ['Panic Button', 'Lapak Aduan', 'Damkar'],
    'CCTV': ['ATCS'],
    'Transportasi': ['Intanmas'],
  };

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get screen width for responsive sizing
    final screenWidth = MediaQuery.of(context).size.width;

    final Map<String, List<String>> filteredMenuData = {};
    if (_searchQuery.isEmpty) {
      filteredMenuData.addAll(_allMenuData);
    } else {
      _allMenuData.forEach((category, items) {
        final List<String> matchingItems = items
            .where((item) =>
                item.toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList();

        if (matchingItems.isNotEmpty) {
          filteredMenuData[category] = matchingItems;
        }
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9F8F5),
      body: SafeArea(
        child: SingleChildScrollView(
          // Proportional padding
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Text(
                'Menu Lainnya',
                style: TextStyle(
                  // Proportional font size
                  fontSize: screenWidth * 0.055,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              _buildSearchField(),
              const SizedBox(height: 24),

              // Display filtered data or an empty state message
              if (filteredMenuData.isEmpty && _searchQuery.isNotEmpty)
                _buildEmptySearchResult(screenWidth)
              else
                Column(
                  children: filteredMenuData.entries.map((entry) {
                    return _buildMenuSection(
                        entry.key, entry.value, screenWidth);
                  }).toList(),
                ),

              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Cari aplikasi disini...',
        hintStyle: TextStyle(color: Colors.grey[600]),
        prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 15.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF425C48), width: 1.5),
        ),
      ),
    );
  }

  Widget _buildMenuSection(
      String title, List<String> items, double screenWidth) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Container(
        // Proportional padding
        padding: EdgeInsets.all(screenWidth * 0.04),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                // Proportional font size
                fontSize: screenWidth * 0.045,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 8,
              // === PERUBAHAN DI SINI ===
              // Adjusted to give more vertical space for text
              childAspectRatio: 0.75,
              // =========================
              children: items
                  .map((label) => _buildMenuItem(label, screenWidth))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(String label, double screenWidth) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          // Proportional icon container size
          height: screenWidth * 0.15,
          width: screenWidth * 0.15,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        const SizedBox(height: 8),
        // === PERUBAHAN DI SINI ===
        // Removed Flexible as it's no longer needed with the correct aspect ratio
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            // Proportional font size
            fontSize: screenWidth * 0.03,
            color: Colors.black54,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        // =========================
      ],
    );
  }

  Widget _buildEmptySearchResult(double screenWidth) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 50),
      child: Column(
        children: [
          Icon(Icons.search_off,
              color: Colors.grey[400], size: screenWidth * 0.15),
          const SizedBox(height: 16),
          Text(
            'Menu tidak ditemukan',
            style: TextStyle(
              fontSize: screenWidth * 0.04,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
