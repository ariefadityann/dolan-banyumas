import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// Ganti dengan path yang benar ke file model dan halaman detail Anda
import '../../models/wisata_model.dart';
import 'detail_wisata.dart';

// Model untuk filter kategori
class CategoryFilter {
  final String name;
  final IconData icon;
  CategoryFilter({required this.name, required this.icon});
}

class SearchPage extends StatefulWidget {
  final List<TempatWisata> allWisata;

  const SearchPage({super.key, required this.allWisata});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _searchController = TextEditingController();
  List<TempatWisata> _filteredWisata = [];
  String _selectedCategory = 'Wisata';
  List<TempatWisata> _searchHistory = [];
  bool _isLoadingHistory = true;

  final List<CategoryFilter> _categories = [
    CategoryFilter(name: 'Wisata', icon: Icons.tour_outlined),
    CategoryFilter(name: 'Desa Wisata', icon: Icons.holiday_village_outlined),
    CategoryFilter(name: 'Kuliner', icon: Icons.restaurant_outlined),
    CategoryFilter(name: 'Oleh Oleh', icon: Icons.shopping_bag_outlined),
    CategoryFilter(name: 'Penginapan', icon: Icons.hotel_outlined),
  ];

  @override
  void initState() {
    super.initState();
    _filteredWisata = widget.allWisata;
    _searchController.addListener(_performSearch);
    _loadSearchHistory();
  }

  @override
  void dispose() {
    _searchController.removeListener(_performSearch);
    _searchController.dispose();
    super.dispose();
  }

   Future<void> _loadSearchHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyString = prefs.getString('search_history_wisata_v2');
      if (historyString != null) {
        final List decoded = jsonDecode(historyString);
        _searchHistory =
            decoded.map((item) => TempatWisata.fromJson(item)).toList();
      }
    } catch (e) {
      // Jika terjadi error (misal data lama tidak cocok), cetak errornya
      print("===== ERROR SAAT MEMUAT RIWAYAT: $e");
      // Dan bersihkan riwayat yang rusak agar tidak error lagi di kemudian hari
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('search_history_wisata_v2');
      _searchHistory = [];
    } finally {
      // FINALLY akan selalu dijalankan, baik ada error maupun tidak.
      // Ini menjamin spinner akan selalu berhenti.
      if (mounted) { // Pengecekan 'mounted' adalah praktik yang baik
        setState(() {
          _isLoadingHistory = false;
        });
      }
    }
  }
  
  /// Helper function untuk update data riwayat di SharedPreferences
  Future<void> _updatePersistentHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData =
        jsonEncode(_searchHistory.map((item) => item.toJson()).toList());
    await prefs.setString('search_history_wisata_v2', encodedData);
  }

  Future<void> _saveToHistory(TempatWisata wisata) async {
    setState(() {
      _searchHistory.removeWhere((item) => item.id == wisata.id);
      _searchHistory.insert(0, wisata);
      if (_searchHistory.length > 20) {
        _searchHistory = _searchHistory.sublist(0, 20);
      }
    });
    await _updatePersistentHistory();
  }
  
  Future<void> _deleteFromHistory(TempatWisata wisata) async {
    setState(() {
      _searchHistory.removeWhere((item) => item.id == wisata.id);
    });
    await _updatePersistentHistory();
  }

  // UPDATE: Fungsi ini sekarang menghapus riwayat berdasarkan kategori yang aktif
  Future<void> _clearHistoryByCategory() async {
    setState(() {
      // Hapus semua item dari _searchHistory yang kategorinya sama dengan _selectedCategory
      _searchHistory.removeWhere((item) => item.kategori == _selectedCategory);
    });
    // Simpan kembali daftar riwayat yang sudah difilter
    await _updatePersistentHistory();
  }


  void _performSearch() {
    setState(() {});
  }

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  @override
  Widget build(BuildContext context) {
    final String query = _searchController.text.toLowerCase();
    final bool isSearching = query.isNotEmpty;
    
    if (isSearching) {
      _filteredWisata = widget.allWisata
          .where((wisata) => wisata.nama.toLowerCase().contains(query))
          .toList();
    }

    final List<TempatWisata> displayedHistory = _searchHistory
        .where((wisata) => wisata.kategori == _selectedCategory)
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Search', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        children: [
          _buildSearchBar(),
          const SizedBox(height: 24),
          _buildCategoryFilters(),
          const SizedBox(height: 24),
          _buildSectionHeader(isSearching, displayedHistory.isNotEmpty),
          const SizedBox(height: 16),

          if (isSearching)
            _buildResultsList(_filteredWisata)
          else if (_isLoadingHistory)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 50.0),
                child: CircularProgressIndicator(),
              ),
            )
          else
            _buildHistoryList(displayedHistory),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search something...',
        hintStyle: TextStyle(color: Colors.grey.shade500),
        prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30.0), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(vertical: 15.0),
      ),
    );
  }

  Widget _buildCategoryFilters() {
    return SizedBox(
      height: 95,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = category.name == _selectedCategory;
          return GestureDetector(
            onTap: () => _onCategorySelected(category.name),
            child: Column(
              children: [
                Container(
                  width: 65, height: 65,
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFFF9B50) : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(category.icon, color: isSelected ? Colors.white : Colors.grey.shade700, size: 32),
                ),
                const SizedBox(height: 8),
                Text(category.name, style: TextStyle(fontSize: 12, color: Colors.grey.shade800, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
              ],
            ),
          );
        },
      ),
    );
  }

  // UPDATE: Panggil fungsi baru _clearHistoryByCategory
  Widget _buildSectionHeader(bool isSearching, bool historyIsNotEmpty) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          isSearching ? 'Hasil Pencarian' : 'Riwayat Pencarian',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        if (!isSearching && historyIsNotEmpty)
          TextButton(
            onPressed: _clearHistoryByCategory, // Panggil fungsi yang benar
            child: const Text(
              'Hapus Semua',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
            ),
          ),
      ],
    );
  }

 Widget _buildResultsList(List<TempatWisata> list) {
    if (list.isEmpty) {
      return const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 50.0), child: Text('Destinasi tidak ditemukan.')));
    }
    return Column(
      children: list.map((wisata) => Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: SearchResultCard(
          wisata: wisata,
          onCardTap: (selectedWisata) {
            _saveToHistory(selectedWisata);
            Navigator.push(context, MaterialPageRoute(builder: (context) => DetailWisata(wisata: selectedWisata)));
          },
        ),
      )).toList(),
    );
  }

  Widget _buildHistoryList(List<TempatWisata> history) {
    if (history.isEmpty) {
      return const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 50.0), child: Text('Belum ada riwayat untuk kategori ini.')));
    }
    return Column(
      children: history.map((wisata) => Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: SearchResultCard(
          wisata: wisata,
          onCardTap: (selectedWisata) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => DetailWisata(wisata: selectedWisata)));
          },
        ),
      )).toList(),
    );
  }
}

class SearchResultCard extends StatelessWidget {
  final TempatWisata wisata;
  final Function(TempatWisata) onCardTap;

  const SearchResultCard({super.key, required this.wisata, required this.onCardTap});

  @override
  Widget build(BuildContext context) {
    final double rating = wisata.rating;
    final String ratingText = rating >= 4.5 ? 'Greate' : 'Good';

    return InkWell(
      onTap: () => onCardTap(wisata),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200, width: 1.5),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16.0),
              child: Image.asset(
                wisata.gambarUrl,
                width: 80, height: 80, fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 80, height: 80, color: Colors.grey.shade200,
                  child: const Icon(Icons.image_not_supported, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(wisata.nama, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Text(wisata.kategori, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
              decoration: BoxDecoration(color: const Color(0xFFF1F1F1).withOpacity(0.5), borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(rating.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(width: 4),
                      const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(ratingText, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}