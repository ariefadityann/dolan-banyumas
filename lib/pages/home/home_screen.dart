import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Wajib untuk logout

// Sesuaikan path import Login Page Anda
import '../../content/login.dart'; 

import '../../providers/favorites_provider.dart';

// Models & Services
import '../../models/wisata_model.dart';
import '../../services/wisata_service.dart';
import '../../services/location_service.dart';

// Widgets
import '../../widgets/custom_bottom_nav_bar.dart';
import '../../widgets/event_banner.dart';
import '../../widgets/home_header.dart';
import '../../widgets/kategori_filter.dart';
import '../../widgets/rekomendasi_card.dart';
import '../../widgets/section_title.dart';
import '../../widgets/terdekat_card.dart';

// Pages
import 'search_page.dart';
import 'all_items_screen.dart';
import 'all_item_terdekat.dart';
import '../ticket/ticket_page.dart';
import '../transport/transport_page.dart';
import '../more/more_page.dart';
import '../favorite/favorites_page.dart';

class IndexPage extends StatefulWidget {
  final String? username;
  final String? email;

  const IndexPage({super.key, this.username, this.email});

  @override
  State<IndexPage> createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final WisataService _wisataService = WisataService();
  final LocationService _locationService = LocationService();

  List<TempatWisata> _allWisata = [];
  bool _isLoading = true;

  int _selectedIndex = 0;
  String _selectedCategory = 'Wisata';

  final List<String> _categories = const [
    'Wisata',
    'Desa Wisata',
    'Kuliner',
    'Oleh Oleh',
    'Penginapan',
  ];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final List<TempatWisata> loadedWisata =
          await _wisataService.fetchWisataData();

      try {
        final Position position = await _locationService.getCurrentLocation();
        for (var wisata in loadedWisata) {
          final distance = _locationService.calculateDistance(
            position.latitude,
            position.longitude,
            wisata.lat,
            wisata.lng,
          );
          wisata.jarak = '${distance.toStringAsFixed(1)} km';
        }
      } catch (e) {
        print("Gagal mendapatkan lokasi di IndexPage: $e");
      }

      if (mounted) {
        setState(() {
          _allWisata = loadedWisata;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data wisata: $e')),
        );
      }
    }
  }

  // === FUNGSI LOGOUT ===
  Future<void> _logout() async {
    // 1. Tampilkan Dialog Konfirmasi
    final bool? shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      // 2. Hapus Data Session
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear(); 

      // 3. Navigasi Balik ke Login (dan hapus history halaman sebelumnya)
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (Route<dynamic> route) => false,
        );
      }
    }
  }
  // =====================

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  void _onCategorySelected(String category) {
    setState(() => _selectedCategory = category);
  }

  void _navigateToSearchPage() {
    if (_allWisata.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SearchPage(allWisata: _allWisata),
        ),
      );
    }
  }

  List<TempatWisata> _filterWisataByCategory(List<TempatWisata> allWisata) {
    return allWisata
        .where(
            (w) => w.kategori.toLowerCase() == _selectedCategory.toLowerCase())
        .toList();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF9F8F5),
      drawer: _buildAppDrawer(),
      body: Stack(
        children: [
          IndexedStack(
            index: _selectedIndex,
            children: [
              _buildHomeContent(),
              TicketPage(allWisata: _allWisata),
              TransportPage(
                allWisata: _allWisata,
                username: widget.username,
              ),
              const FavoritesPage(),
              const MorePage(),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: CustomBottomNavBar(
              selectedIndex: _selectedIndex,
              onItemTapped: _onItemTapped,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeContent() {
    return RefreshIndicator(
      onRefresh: _fetchData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HomeHeader(
              username: widget.username,
              onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
              onSearchTap: _navigateToSearchPage,
            ),
            const SizedBox(height: 80),
            const EventBanner(),
            const SizedBox(height: 24),
            KategoriFilter(
              categories: _categories,
              selectedCategory: _selectedCategory,
              onCategorySelected: _onCategorySelected,
            ),
            const SizedBox(height: 24),
            SectionTitle(
              title: 'Rekomendasi',
              onPressed: () {
                if (_allWisata.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AllItemsScreen(
                        category: _selectedCategory,
                        allWisata: _allWisata,
                      ),
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 16),
            _buildRekomendasiList(),
            const SizedBox(height: 24),
            SectionTitle(
              title: 'Terdekat',
              onPressed: () {
                if (_allWisata.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AllItemTerdekat(
                        allWisata: _allWisata,
                      ),
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 16),
            _buildTerdekatList(),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildRekomendasiList() {
    if (_isLoading) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_allWisata.isEmpty) {
      return const Center(child: Text('Tidak ada data wisata.'));
    }

    final filteredList = _filterWisataByCategory(_allWisata);

    final favoritesProvider =
        Provider.of<FavoritesProvider>(context, listen: false);
    filteredList.sort((a, b) {
      bool isAFavorited = favoritesProvider.isFavorite(a);
      bool isBFavorited = favoritesProvider.isFavorite(b);

      if (isAFavorited && !isBFavorited) return -1;
      if (!isAFavorited && isBFavorited) return 1;
      return 0;
    });

    if (filteredList.isEmpty) {
      return const SizedBox(
        height: 100,
        child: Center(child: Text('Rekomendasi tidak ditemukan.')),
      );
    }

    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        itemCount: filteredList.length,
        itemBuilder: (context, index) {
          return RekomendasiCard(wisata: filteredList[index]);
        },
      ),
    );
  }

  Widget _buildTerdekatList() {
    if (_isLoading) return const SizedBox.shrink();
    if (_allWisata.isEmpty) {
      return const Center(child: Text('Tidak ada data wisata terdekat.'));
    }

    final List<TempatWisata> filteredList = _filterWisataByCategory(_allWisata);

    if (filteredList.isEmpty) {
      return const SizedBox(
        height: 100,
        child: Center(
            child: Text('Tidak ada lokasi terdekat untuk kategori ini.')),
      );
    }

    filteredList.sort(
        (a, b) => _parseDistance(a.jarak).compareTo(_parseDistance(b.jarak)));

    final terdekatList =
        filteredList.length > 5 ? filteredList.sublist(0, 5) : filteredList;

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      itemCount: terdekatList.length,
      itemBuilder: (context, index) {
        return TerdekatCard(wisata: terdekatList[index]);
      },
    );
  }

  Drawer _buildAppDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFFF44336)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage('assets/img/logo.png'),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.username ?? 'Pengguna',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // === EMAIL DITAMPILKAN DI SINI ===
                Text(
                  widget.email ?? 'email@banyumas.com', 
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Profil'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.favorite_border),
            title: const Text('Favorit'),
            onTap: () {
              Navigator.pop(context);
              _onItemTapped(3);
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Pengaturan'),
            onTap: () => Navigator.pop(context),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            // === AKSI LOGOUT ===
            onTap: () {
              Navigator.pop(context); // Tutup drawer
              _logout(); // Panggil fungsi logout
            },
          ),
        ],
      ),
    );
  }
}