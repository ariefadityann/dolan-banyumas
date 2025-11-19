import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart'; // --- TAMBAHAN 1 ---
import '../../models/wisata_model.dart'; // Pastikan path import ini benar
import 'order_detail_ticket.dart'; // Import halaman konfirmasi yang baru

class BookingParkirPage extends StatefulWidget {
  final TempatWisata parkir;

  const BookingParkirPage({super.key, required this.parkir});

  @override
  State<BookingParkirPage> createState() => _BookingParkirPageState();
}

class _BookingParkirPageState extends State<BookingParkirPage> {
  final _platController = TextEditingController();
  int _jumlahKendaraan = 1;
  int _tarif = 0;
  double _totalTarif = 0.0;
  DateTime? _selectedDate;

  // --- TAMBAHAN 2: Variabel untuk menyimpan nama pemesan ---
  String _namaPemesan = 'Pengunjung';

  @override
  void initState() {
    super.initState();
    final hargaString = widget.parkir.harga.replaceAll('.', '');
    _tarif = int.tryParse(hargaString) ?? 0;
    _selectedDate = DateTime.now(); // Default tanggal hari ini
    _calculateTotal();

    // --- TAMBAHAN 3: Panggil fungsi load data user ---
    _loadUserData();
  }

  // --- TAMBAHAN 4: Fungsi untuk mengambil data nama dari SharedPreferences ---
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    // Pastikan key 'user_name' sesuai dengan yang Anda simpan saat login
    final String? savedName = prefs.getString('user_name');

    if (savedName != null && mounted) {
      setState(() {
        _namaPemesan = savedName;
      });
    }
  }

  void _calculateTotal() {
    setState(() {
      _totalTarif = (_jumlahKendaraan * _tarif).toDouble();
    });
  }

  void _updateJumlah(int newJumlah) {
    if (newJumlah >= 1) {
      // Jumlah tidak boleh kurang dari 1
      setState(() {
        _jumlahKendaraan = newJumlah;
        _calculateTotal();
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      locale: const Locale('id', 'ID'), // Menggunakan locale Indonesia
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // --- FUNGSI BARU UNTUK NAVIGASI ---
  void _lanjutPemesanan() {
    if (_platController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan isi nomor plat kendaraan.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Navigasi ke halaman konfirmasi dengan membawa semua data
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => KonfirmasiBookingPage(
          parkir: widget.parkir,
          nomorPlat: _platController.text,
          jumlahKendaraan: _jumlahKendaraan,
          totalTarif: _totalTarif,
          tanggalBooking: _selectedDate!,
          // --- PERBAIKAN 5: Tambahkan parameter namaPemesan ---
          namaPemesan: _namaPemesan,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _platController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ... Sisa kode build (UI) Anda tidak perlu diubah ...
    // ... (Saya salin sisa kodenya di bawah agar lengkap) ...
    return Scaffold(
      backgroundColor: const Color(0xFFFFE6E5),
      appBar: AppBar(
        title: const Text(
          'Pemesanan Parkir',
          style: TextStyle(
              color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: const Color(0xFFFFE6E5),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
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
                _buildParkirInfoCard(),
                const SizedBox(height: 24),
                _buildDateSection(),
                const SizedBox(height: 24),
                _buildDetailSection(),
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

  Widget _buildParkirInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF44336),
        borderRadius: BorderRadius.circular(16),
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
            child:
                const Icon(Icons.local_parking, size: 40, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.parkir.nama,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.parkir.deskripsi,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
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
        const Text('Tanggal',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87)),
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
                      DateFormat('EEEE, d MMMM y', 'id_ID')
                          .format(_selectedDate!),
                      style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500),
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

  Widget _buildDetailSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Detail Kendaraan',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87)),
        const SizedBox(height: 12),
        TextField(
          controller: _platController,
          textCapitalization: TextCapitalization.characters,
          style: const TextStyle(color: Colors.black),
          decoration: InputDecoration(
            labelText: 'Nomer Plat Kendaraan',
            hintText: 'Contoh: B 1234 ABC',
            filled: true,
            fillColor: const Color(0xFFF5F5F5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildCounterRow('Jumlah Kendaraan', _jumlahKendaraan, (newCount) {
          _updateJumlah(newCount);
        }),
      ],
    );
  }

  Widget _buildCounterRow(String title, int count, Function(int) onUpdate) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE6E5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFF44336))),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: const Color(0xFFF44336)),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove,
                      size: 18, color: Color(0xFFF44336)),
                  onPressed: () => onUpdate(count - 1),
                ),
                Text(count.toString(),
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFF44336))),
                IconButton(
                  icon:
                      const Icon(Icons.add, size: 18, color: Color(0xFFF44336)),
                  onPressed: () => onUpdate(count + 1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalHarga() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Total Harga',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFFF44336))),
        Text(
          'Rp ${NumberFormat("#,##0", "id_ID").format(_totalTarif)}',
          style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFFF44336)),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            // Menggunakan fungsi _lanjutPemesanan yang baru dibuat
            onPressed: _lanjutPemesanan,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF44336),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Lanjut Pemesanan',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Color(0xFFF44336)),
              ),
              elevation: 0,
            ),
            child: const Text('Batalkan',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }
}