import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/wisata_model.dart';
import '../../providers/favorites_provider.dart';
import 'detail_wisata.dart';

class AllItemTerdekat extends StatefulWidget {
  final List<TempatWisata> allWisata;

  const AllItemTerdekat({super.key, required this.allWisata});

  @override
  State<AllItemTerdekat> createState() => _AllItemTerdekatState();
}

class _AllItemTerdekatState extends State<AllItemTerdekat> {
  final TextEditingController _searchController = TextEditingController();

  List<TempatWisata> _allPlaces = [];
  List<TempatWisata> _filteredPlaces = [];
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _sortAndSetData();
  }

  void _sortAndSetData() {
    final List<TempatWisata> sortedList = List.from(widget.allWisata);
    sortedList.sort((a, b) {
      double distanceA = _parseDistance(a.jarak);
      double distanceB = _parseDistance(b.jarak);
      return distanceA.compareTo(distanceB);
    });

    setState(() {
      _allPlaces = sortedList;
      _filteredPlaces = sortedList;
    });
  }

  double _parseDistance(String jarakString) {
    try {
      String lower = jarakString.toLowerCase();
      double value = double.parse(lower.replaceAll(RegExp(r'[^0-9.]'), ''));
      if (lower.contains('m') && !lower.contains('km')) {
        return value / 1000;
      }
      return value;
    } catch (e) {
      return double.infinity;
    }
  }

  void _filterPlaces(String query) {
    if (query.isNotEmpty) {
      final List<TempatWisata> searchResult = _allPlaces
          .where(
              (place) => place.nama.toLowerCase().contains(query.toLowerCase()))
          .toList();
      setState(() {
        _filteredPlaces = searchResult;
      });
    } else {
      setState(() {
        _filteredPlaces = _allPlaces;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F6F0),
      body: Column(
        children: [
          _buildCustomHeader(context, screenWidth, screenHeight),
          Expanded(child: _buildBodyContent(screenWidth, screenHeight)),
        ],
      ),
    );
  }

  Widget _buildBodyContent(double screenWidth, double screenHeight) {
    if (_isLoading) return _buildLoadingState(screenWidth);
    if (_errorMessage.isNotEmpty)
      return _buildErrorState(_errorMessage, screenWidth);
    if (_filteredPlaces.isEmpty) {
      final bool isSearching = _searchController.text.isNotEmpty;
      return _buildEmptyState(screenWidth, isSearching: isSearching);
    }
    return _buildList(_filteredPlaces, screenWidth, screenHeight);
  }

  Widget _buildCustomHeader(
      BuildContext context, double screenWidth, double screenHeight) {
    return Container(
      padding: EdgeInsets.only(bottom: screenHeight * 0.02),
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 212, 72, 62),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.04,
                  vertical: screenHeight * 0.01),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Wisata Terdekat',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(width: screenWidth * 0.08),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
              child: TextField(
                controller: _searchController,
                onChanged: _filterPlaces,
                decoration: InputDecoration(
                  hintText: 'Cari tempat wisata...',
                  hintStyle: TextStyle(
                    color: Colors.grey[600],
                    fontSize: screenWidth * 0.035,
                  ),
                  prefixIcon:
                      const Icon(Icons.search, color: Color(0xFF2E7D32)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: screenHeight * 0.015,
                    horizontal: screenWidth * 0.05,
                  ),
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
          ],
        ),
      ),
    );
  }

  Widget _buildList(
      List<TempatWisata> places, double screenWidth, double screenHeight) {
    return ListView.builder(
      padding: EdgeInsets.all(screenWidth * 0.04),
      itemCount: places.length,
      itemBuilder: (context, index) {
        final place = places[index];
        return _buildPlaceItem(context, place, screenWidth, screenHeight);
      },
    );
  }

  Widget _buildPlaceItem(BuildContext context, TempatWisata place,
      double screenWidth, double screenHeight) {
    final favoritesProvider = Provider.of<FavoritesProvider>(context);
    final bool isFavorited = favoritesProvider.isFavorite(place);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DetailWisata(wisata: place)),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: screenHeight * 0.02),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 6,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Stack(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✅ Gambar dengan borderRadius
                Flexible(
                  flex: 4,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                    child: SizedBox(
                      height: screenHeight * 0.17,
                      child: Image.asset(
                        place.gambarUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.broken_image, color: Colors.grey),
                      ),
                    ),
                  ),
                ),

                // Detail teks
                Flexible(
                  flex: 6,
                  child: Padding(
                    padding: EdgeInsets.all(screenWidth * 0.03),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          place.nama,
                          style: TextStyle(
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: screenHeight * 0.012),
                        Row(
                          children: [
                            Icon(Icons.location_on,
                                size: screenWidth * 0.047,
                                color: Colors.grey[600]),
                            SizedBox(width: screenWidth * 0.01),
                            Flexible(
                              child: Text(
                                place.jarak,
                                style: TextStyle(
                                  fontSize: screenWidth * 0.035,
                                  color: Colors.grey[600],
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: screenHeight * 0.008),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: screenHeight * 0.01,
              right: screenWidth * 0.03,
              child: IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(
                  isFavorited ? Icons.favorite : Icons.favorite_border,
                  size: screenWidth * 0.08,
                  color: isFavorited ? Colors.red : Colors.grey[400],
                ),
                onPressed: () {
                  favoritesProvider.toggleFavorite(place);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(double screenWidth, {bool isSearching = false}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSearching
                  ? Icons.search_off_rounded
                  : Icons.location_off_outlined,
              size: screenWidth * 0.18,
              color: Colors.grey[400],
            ),
            SizedBox(height: screenWidth * 0.04),
            Text(
              isSearching ? 'Tidak Ditemukan' : 'Tidak Ada Data',
              style: TextStyle(
                fontSize: screenWidth * 0.045,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: screenWidth * 0.02),
            Text(
              isSearching
                  ? 'Tidak ada hasil untuk pencarian "${_searchController.text}"'
                  : 'Tidak ada data wisata terdekat yang bisa ditampilkan.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: screenWidth * 0.035,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState(double screenWidth) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
          ),
          SizedBox(height: screenWidth * 0.04),
          Text(
            'Mencari lokasimu...',
            style: TextStyle(
              color: Colors.black54,
              fontSize: screenWidth * 0.035,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error, double screenWidth) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.06),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline,
                size: screenWidth * 0.18, color: Colors.redAccent),
            SizedBox(height: screenWidth * 0.04),
            Text(
              'Terjadi Kesalahan',
              style: TextStyle(
                fontSize: screenWidth * 0.045,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: screenWidth * 0.02),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: screenWidth * 0.035,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: screenWidth * 0.05),
            ElevatedButton(
              onPressed: _sortAndSetData,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Coba Lagi',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: screenWidth * 0.04,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
