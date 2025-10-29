import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/wisata_model.dart';
import '../../providers/favorites_provider.dart';
import '../home/detail_wisata.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  // Kategori yang akan digunakan untuk filter
  final List<String> _categories = const [
    'Wisata',
    'Desa Wisata',
    'Kuliner',
    'Oleh Oleh',
    'Penginapan',
  ];

  // State untuk melacak filter dan pencarian
  late String _selectedCategory;
  bool _isSearching = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Atur filter default
    _selectedCategory = 'All';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<String> filterCategories = ['All', ..._categories];

    return Scaffold(
      backgroundColor: const Color(0xFFF9F8F5),
      body: SafeArea(
        child: Consumer<FavoritesProvider>(
          builder: (context, favoritesProvider, child) {
            // --- LOGIKA FILTER DAN PENCARIAN ---
            List<TempatWisata> finalItems = favoritesProvider.favorites;

            // 1. Filter berdasarkan KATEGORI
            if (_selectedCategory != 'All') {
              finalItems = finalItems
                  .where((item) => item.kategori == _selectedCategory)
                  .toList();
            }

            // 2. Filter berdasarkan PENCARIAN
            if (_searchQuery.isNotEmpty) {
              finalItems = finalItems
                  .where((item) => item.nama
                      .toLowerCase()
                      .contains(_searchQuery.toLowerCase()))
                  .toList();
            }
            // ------------------------------------

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _buildHeader(), // Header sekarang dinamis
                  const SizedBox(height: 20),
                  // Sembunyikan filter kategori saat sedang mencari
                  if (!_isSearching) ...[
                    _buildCategoryFilters(filterCategories),
                    const SizedBox(height: 20),
                  ],

                  if (favoritesProvider.favorites.isEmpty)
                    const Expanded(
                      child: Center(
                        child: Text(
                          'Anda belum memiliki item favorit.',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ),
                    )
                  else if (finalItems.isEmpty)
                    const Expanded(
                      child: Center(
                        child: Text(
                          'Tidak ada favorit yang cocok.',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    _buildFavoritesList(finalItems),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // --- WIDGET HEADER YANG DINAMIS ---
  Widget _buildHeader() {
    // Tampilkan Search Bar jika _isSearching adalah true
    if (_isSearching) {
      return TextField(
        controller: _searchController,
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'Cari favorit...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              setState(() {
                _isSearching = false;
                _searchQuery = '';
                _searchController.clear();
              });
            },
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide.none,
          ),
          filled: true,
          contentPadding: EdgeInsets.zero,
          fillColor: Colors.grey[200],
        ),
        onChanged: (query) {
          setState(() {
            _searchQuery = query;
          });
        },
      );
    }
    // Tampilkan Title Bar jika false
    else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Favorites',
            style: TextStyle(
                fontSize: 32,
                color: Color(0xFFF44336),
                fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.search, size: 28),
            onPressed: () {
              setState(() {
                _isSearching = true;
              });
            },
          ),
        ],
      );
    }
  }
  // ------------------------------------

  Widget _buildCategoryFilters(List<String> categories) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final bool isSelected = category == _selectedCategory;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = category;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFF44336) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFF44336), width: 1.5),
              ),
              child: Center(
                child: Text(
                  category,
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFFF44336),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFavoritesList(List<TempatWisata> items) {
    return Expanded(
      child: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return _buildFavoriteItemCard(item);
        },
      ),
    );
  }

  Widget _buildFavoriteItemCard(TempatWisata item) {
    final favoritesProvider =
        Provider.of<FavoritesProvider>(context, listen: false);

    // 2. Bungkus Container dengan GestureDetector
    return GestureDetector(
      onTap: () {
        // 3. Tambahkan navigasi ke halaman DetailWisata
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailWisata(wisata: item),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withAlpha(26),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          // ... sisa kode tidak berubah
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                item.gambarUrl,
                width: 110,
                height: 110,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: SizedBox(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.nama,
                            style: const TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 5),
                        Text(item.deskripsi,
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey.shade600)),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Text(item.rating.toString(),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange)),
                            const Icon(Icons.star,
                                color: Colors.orange, size: 16),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ],
                    ),
                    Text(
                      'Rp. ${item.harga}',
                      style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.favorite, color: Colors.red, size: 28),
              onPressed: () {
                favoritesProvider.toggleFavorite(item);
              },
            ),
          ],
        ),
      ),
    );
  }
}
