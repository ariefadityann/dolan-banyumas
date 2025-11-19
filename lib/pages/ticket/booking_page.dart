import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 1. Tambah Import ini
import '../../models/wisata_model.dart';
import 'order_detail_page.dart'; 

class BookingPage extends StatefulWidget {
  final TempatWisata wisata;

  const BookingPage({super.key, required this.wisata});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final Map<String, int> _ticketCounts = {
    'Dewasa': 0,
    'Dewasa Disabilitas': 0,
    'Anak Anak': 0,
    'Anak Anak Disabilitas': 0,
    'Lansia': 0,
    'Lansia Disabilitas': 0,
  };

  int _ticketPrice = 0;
  DateTime? _selectedDate;
  double _totalPrice = 0.0;
  
  // 2. Variabel untuk menyimpan nama user yang login
  String _namaUser = 'Pengunjung'; 

  @override
  void initState() {
    super.initState();
    final priceString = widget.wisata.harga.replaceAll('.', '');
    _ticketPrice = int.tryParse(priceString) ?? 0;
    
    // 3. Panggil fungsi load data user saat halaman dibuka
    _loadUserData();
  }

  // Fungsi mengambil data nama dari SharedPreferences
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedName = prefs.getString('user_name');
    
    if (savedName != null && mounted) {
      setState(() {
        _namaUser = savedName;
      });
    }
  }

  void _calculateTotalPrice() {
    int totalTickets = _ticketCounts.values.reduce((sum, count) => sum + count);
    setState(() {
      _totalPrice = (totalTickets * _ticketPrice).toDouble();
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      locale: const Locale('id', 'ID'),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFE6E5),
      appBar: AppBar(
        title: const Text(
          'Pemesanan Tiket',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: const Color(0xFFFFE6E5),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildWisataInfoCard(),
                const SizedBox(height: 24),
                _buildDateSection(),
                const SizedBox(height: 24),
                _buildTicketSection(),
                const SizedBox(height: 24),
                _buildTotalHarga(),
                const SizedBox(height: 32),
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWisataInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF44336),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white.withOpacity(0.1),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                widget.wisata.gambarUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.forest, size: 40, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.wisata.nama,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.wisata.deskripsi,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Sisa Kuota : 6000 Tiket',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tanggal',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => _selectDate(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        color: Colors.grey, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      _selectedDate == null
                          ? 'Pilih Tanggal'
                          : DateFormat('EEEE, d MMMM y', 'id_ID')
                              .format(_selectedDate!),
                      style: TextStyle(
                        fontSize: 16,
                        color: _selectedDate == null
                            ? Colors.grey
                            : Colors.black87,
                        fontWeight: _selectedDate == null
                            ? FontWeight.normal
                            : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const Icon(Icons.arrow_drop_down, color: Colors.grey),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTicketSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tiket',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: _ticketCounts.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildTicketCounterRow(entry.key),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildTicketCounterRow(String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFF44336),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Rp: ${NumberFormat("#,##0", "id_ID").format(_ticketPrice)}',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: const Color(0xFFF44336)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove, size: 18),
                  color: const Color(0xFFF44336),
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    if (_ticketCounts[title]! > 0) {
                      setState(() {
                        _ticketCounts[title] = _ticketCounts[title]! - 1;
                        _calculateTotalPrice();
                      });
                    }
                  },
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    _ticketCounts[title].toString(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFF44336),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add, size: 18),
                  color: const Color(0xFFF44336),
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    setState(() {
                      _ticketCounts[title] = _ticketCounts[title]! + 1;
                      _calculateTotalPrice();
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalHarga() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE6E5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE3F0E3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Total Harga',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFFF44336),
            ),
          ),
          Text(
            NumberFormat("#,##0", "id_ID").format(_totalPrice),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFFF44336),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _totalPrice > 0
                ? () {
                    // Validasi jika tanggal belum dipilih
                    if (_selectedDate == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Silakan pilih tanggal kunjungan terlebih dahulu.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    // Hitung total tiket
                    int totalTickets = _ticketCounts.values
                        .reduce((sum, count) => sum + count);

                    // Navigasi ke halaman detail pesanan
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrderDetailPage(
                          // 4. Gunakan variabel _namaUser yang sudah diambil dari Login
                          namaPemesan: _namaUser, 
                          tempatWisata: widget.wisata.nama,
                          tanggalBerkunjung: _selectedDate!,
                          jumlahTiket: totalTickets,
                          totalHarga: _totalPrice,
                        ),
                      ),
                    );
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF44336),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              disabledBackgroundColor: Colors.grey.shade400,
            ),
            child: const Text(
              'Lanjutkan Pembayaran',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFFF44336),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Color(0xFFF44336)),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Kembali',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}