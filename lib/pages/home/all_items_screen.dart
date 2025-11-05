import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/wisata_model.dart';
import '../../providers/favorites_provider.dart';
import 'detail_wisata.dart';

class AllItemsScreen extends StatefulWidget {
  final String category;
  final List<TempatWisata> allWisata; // Terima daftar lengkap

  const AllItemsScreen({
    super.key,
    required this.category,
    required this.allWisata, // Wajibkan parameter ini
  });

  @override
  State<AllItemsScreen> createState() => _AllItemsScreenState();
}

class _AllItemsScreenState extends State<AllItemsScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<TempatWisata> _allPlacesInCategory = [];
  List<TempatWisata> _filteredPlaces = [];

  // isLoading bisa dihilangkan atau diset false karena data sudah siap
  final bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Tidak perlu _fetchWisataData() lagi
    // Langsung filter data yang diterima dari widget
    _allPlacesInCategory = widget.allWisata
        .where((place) =>
            place.kategori.toLowerCase() == widget.category.toLowerCase())
        .toList();
    _filteredPlaces = _allPlacesInCategory;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Fungsi _fetchWisataData() dihapus seluruhnya

  void _runFilter(String enteredKeyword) {
    List<TempatWisata> results;
    if (enteredKeyword.isEmpty) {
      // Jika search bar kosong, tampilkan semua item dalam kategori
      results = _allPlacesInCategory;
    } else {
      // Jika ada keyword, filter dari daftar kategori
      results = _allPlacesInCategory
          .where((place) =>
              place.nama.toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();
    }
    // Update UI
    setState(() {
      _filteredPlaces = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F6F0),
      body: Column(
        children: [
          _CustomHeader(
            category: widget.category,
            searchController: _searchController,
            onSearchChanged: _runFilter,
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredPlaces.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Text(
                            _searchController.text.isEmpty
                                ? 'Tidak ada data untuk kategori "${widget.category}"'
                                : 'Tidak ada hasil untuk pencarian "${_searchController.text}"',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 16, color: Colors.grey),
                          ),
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(16.0),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.75,
                        ),
                        itemCount: _filteredPlaces.length,
                        itemBuilder: (context, index) {
                          final place = _filteredPlaces[index];
                          return _PlaceCard(place: place);
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

// --- Widget Header Kustom (Tidak Ada Perubahan) ---
class _CustomHeader extends StatelessWidget {
  final String category;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;

  const _CustomHeader({
    required this.category,
    required this.searchController,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 16.0),
      decoration: const BoxDecoration(
        color: Color(0xFFF44336),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Text(
                    category,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 48), // Spacer
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: TextField(
                controller: searchController,
                onChanged: onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Cari di ${category}...',
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: 20,
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

// --- Widget Card Tempat Wisata (Tidak Ada Perubahan) ---
class _PlaceCard extends StatelessWidget {
  final TempatWisata place;

  const _PlaceCard({required this.place});

  @override
  Widget build(BuildContext context) {
    final favoritesProvider = Provider.of<FavoritesProvider>(context);
    final isFavorited = favoritesProvider.isFavorite(place);

    return InkWell(
      borderRadius: BorderRadius.circular(15),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailWisata(wisata: place),
          ),
        );
      },
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Image.asset(
                    place.gambarUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[200],
                      child: Icon(Icons.broken_image, color: Colors.grey[400]),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
                  child: Text(
                    place.nama,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    isFavorited ? Icons.favorite : Icons.favorite_border,
                    color: isFavorited ? Colors.red : Colors.white,
                    size: 22,
                  ),
                  onPressed: () {
                    favoritesProvider.toggleFavorite(place);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
