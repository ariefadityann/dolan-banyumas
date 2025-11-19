import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 1. Tambah Import Ini
import '../../models/wisata_model.dart';
import '../../widgets/wisata_card.dart';
import 'booking_page.dart';
import 'parking_page.dart';
import 'my_tickets_list_page.dart';
import 'riwayat_tiket_list.dart';

class TicketPage extends StatefulWidget {
  final List<TempatWisata> allWisata;

  const TicketPage({
    super.key,
    required this.allWisata,
  });

  @override
  State<TicketPage> createState() => _TicketPageState();
}

class _TicketPageState extends State<TicketPage> {
  // Constants
  static const _backgroundColor = Color(0xFFF44336);
  static const _surfaceColor = Color(0xFFF9F8F5);
  static const _primaryColor = Color(0xFFF44336);
  static const _accentColor = Color(0xFFFFE6E5);
  static const _borderRadius = 24.0;
  static const _filterBorderRadius = 30.0;

  // State variables
  TempatWisata? _selectedWisataUntukTiket;
  List<TempatWisata> _ticketableWisata = [];
  List<TempatWisata> _popularWisata = [];
  String _selectedFilter = 'Pesan';
  final List<String> _filters = ['Pesan', 'Parkir', 'Tiket', 'Riwayat'];

  // 2. Variabel untuk menyimpan nama user
  String _namaUser = 'Pengunjung'; 

  @override
  void initState() {
    super.initState();
    _loadUserData(); // 3. Panggil fungsi load data
    _filterDataForPage();
  }

  // 4. Fungsi untuk mengambil Nama dari Shared Preferences
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedName = prefs.getString('user_name');

    // === PERBAIKAN DI SINI ===
    // Validasi: Pastikan tidak null, tidak kosong, dan BUKAN tulisan 'undefined'
    if (savedName != null && 
        savedName.isNotEmpty && 
        savedName.toLowerCase() != 'undefined' && 
        savedName.toLowerCase() != 'null' &&
        mounted) {
      setState(() {
        _namaUser = savedName; 
      });
    }
    // Jika 'undefined', dia akan tetap pakai default 'Pengunjung'
  }

  @override
  void didUpdateWidget(covariant TicketPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.allWisata != oldWidget.allWisata) {
      _filterDataForPage();
    }
  }

  void _filterDataForPage() {
    _ticketableWisata = widget.allWisata.where((wisata) {
      return wisata.deskripsi.toLowerCase() == 'wisata alam';
    }).toList();

    _popularWisata = widget.allWisata.where((wisata) {
      final bool isWisataAlam = wisata.deskripsi.toLowerCase() == 'wisata alam';
      return isWisataAlam; 
    }).toList();

    if (mounted) {
      setState(() {});
    }
  }

  void _onFilterSelected(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
  }

  void _onWisataSelected(TempatWisata wisata) {
    FocusScope.of(context).unfocus();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingPage(wisata: wisata),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            _buildHeaderSection(screenWidth),

            // Content Section
            Expanded(
              child: Container(
                clipBehavior: Clip.hardEdge,
                decoration: const BoxDecoration(
                  color: _surfaceColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(_borderRadius),
                    topRight: Radius.circular(_borderRadius),
                  ),
                ),
                child: _buildContentSection(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Header Section with Greeting and Logo
  Widget _buildHeaderSection(double screenWidth) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.05,
        vertical: 20,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 5. Tampilkan nama user di sini
                Text(
                  'Haii, $_namaUser 👋', 
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: screenWidth * 0.055,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis, // Jaga-jaga jika nama terlalu panjang
                  maxLines: 1,
                ),
                const SizedBox(height: 4),
                Text(
                  'Mau kemana hari ini',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: screenWidth * 0.04,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16), 
          Container(
            width: screenWidth * 0.12,
            height: screenWidth * 0.12,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Image.asset(
              'assets/img/logo.png', 
            ),
          ),
        ],
      ),
    );
  }

  // ... (SISA KODE KE BAWAH TIDAK ADA PERUBAHAN) ...

  // Main Content Section
  Widget _buildContentSection() {
    final screenWidth = MediaQuery.of(context).size.width;
    return Column(
      children: [
        // Filter Chips
        Padding(
          padding: EdgeInsets.fromLTRB(
              screenWidth * 0.04, 24, screenWidth * 0.04, 0),
          child: _buildFilterChips(),
        ),

        // Page Content
        Expanded(
          child: _buildPageContent(),
        ),
      ],
    );
  }

  // Filter Chips Row
  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_filterBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: _filters
            .map((filter) => Expanded(child: _buildFilterChip(filter)))
            .toList(),
      ),
    );
  }

  // Individual Filter Chip
  Widget _buildFilterChip(String label) {
    final bool isSelected = _selectedFilter == label;

    return GestureDetector(
      onTap: () => _onFilterSelected(label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFE6E5) : Colors.transparent,
          borderRadius: BorderRadius.circular(_filterBorderRadius),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? const Color(0xFFF44336) : Colors.grey[700],
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  // Page Content based on selected filter
  Widget _buildPageContent() {
    switch (_selectedFilter) {
      case 'Pesan':
        return _buildPesanContent();

      case 'Parkir':
        return const ParkingPage();

      case 'Tiket':
        return const MyTicketsListPage();

      case 'Riwayat':
        return const RiwayatTiketList();

      default:
        return _buildPlaceholderContent();
    }
  }

  // Content for "Pesan" filter
  Widget _buildPesanContent() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return SingleChildScrollView(
      padding: EdgeInsets.all(screenWidth * 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pesan Tiket',
            style: TextStyle(
              fontSize: screenWidth * 0.055,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: screenHeight * 0.025),
          _buildSearchAutocomplete(),
          SizedBox(height: screenHeight * 0.03),
          _buildPopularSection(),
        ],
      ),
    );
  }

  // Search Autocomplete Widget
  Widget _buildSearchAutocomplete() {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth * 0.05;

    return Autocomplete<TempatWisata>(
      key: ValueKey(_selectedWisataUntukTiket),
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<TempatWisata>.empty();
        }
        return _ticketableWisata.where((TempatWisata option) {
          return option.nama
              .toLowerCase()
              .contains(textEditingValue.text.toLowerCase());
        });
      },
      displayStringForOption: (TempatWisata option) => option.nama,
      fieldViewBuilder: (
        BuildContext context,
        TextEditingController fieldTextEditingController,
        FocusNode fieldFocusNode,
        VoidCallback onFieldSubmitted,
      ) {
        return TextFormField(
          controller: fieldTextEditingController,
          focusNode: fieldFocusNode,
          decoration: InputDecoration(
            hintText: 'Cari & pilih tujuan wisata',
            prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
        );
      },
      optionsViewBuilder: (
        BuildContext context,
        AutocompleteOnSelected<TempatWisata> onSelected,
        Iterable<TempatWisata> options,
      ) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4.0,
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: screenWidth - (horizontalPadding * 2),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: options.length,
                shrinkWrap: true,
                itemBuilder: (BuildContext context, int index) {
                  final TempatWisata option = options.elementAt(index);
                  return ListTile(
                    leading: const Icon(Icons.location_on, size: 20),
                    title:
                        Text(option.nama, style: const TextStyle(fontSize: 14)),
                    onTap: () => onSelected(option),
                  );
                },
              ),
            ),
          ),
        );
      },
      onSelected: _onWisataSelected,
    );
  }

  // Popular Destinations Section
  Widget _buildPopularSection() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Destinasi Populer',
          style: TextStyle(
            fontSize: screenWidth * 0.05,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: screenHeight * 0.02),
        _popularWisata.isEmpty
            ? _buildEmptyState("Tidak ada destinasi populer yang ditemukan")
            : Column(
                children: _popularWisata
                    .map((wisata) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      BookingPage(wisata: wisata),
                                ),
                              );
                            },
                            child: WisataCard(wisata: wisata),
                          ),
                        ))
                    .toList(),
              ),
      ],
    );
  }

  // Placeholder or Empty State Content
  Widget _buildEmptyState(String message) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off,
              size: screenWidth * 0.15, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderContent() {
    final screenWidth = MediaQuery.of(context).size.width;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.construction,
              size: screenWidth * 0.15, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              'Fitur "$_selectedFilter" sedang dalam pengembangan',
              style: TextStyle(
                  fontSize: screenWidth * 0.045, color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}