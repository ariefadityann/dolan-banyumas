import 'dart:convert'; // <-- Diperlukan untuk jsonEncode/Decode
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart'; // <-- Diperlukan untuk email
import 'package:http/http.dart' as http; // <-- Diperlukan untuk API
import '../../models/wisata_model.dart'; // Pastikan path import ini sama
import 'midtrans_webview.dart'; // <-- Halaman WebView

class KonfirmasiBookingPage extends StatefulWidget {
  final TempatWisata parkir;
  final String nomorPlat;
  final int jumlahKendaraan;
  final double totalTarif;
  final DateTime tanggalBooking;
  final String namaPemesan;

  const KonfirmasiBookingPage({
    super.key,
    required this.parkir,
    required this.nomorPlat,
    required this.jumlahKendaraan,
    required this.totalTarif,
    required this.tanggalBooking,
    required this.namaPemesan,
  });

  @override
  State<KonfirmasiBookingPage> createState() => _KonfirmasiBookingPageState();
}

class _KonfirmasiBookingPageState extends State<KonfirmasiBookingPage> {
  bool _isAgreed = false;
  bool _isLoading = false;
  String _emailPemesanAktif = 'pengunjung@dolanbanyumas.com'; // Default email

  // Constants for colors
  static const _backgroundColor = Color(0xFFF9F6F0);
  static const _primaryColor = Color(0xFFF44336);
  static const _secondaryColor = Color(0xFFE57373);
  static const _accentColor = Color(0xFFF44336);

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedEmail = prefs.getString('user_email');

    if (mounted && savedEmail != null) {
      setState(() {
        _emailPemesanAktif = savedEmail;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.06,
                vertical: 32.0,
              ),
              child: Column(
                children: [
                  _buildHeaderSection(screenWidth),
                  SizedBox(height: screenWidth * 0.05),
                  _buildOrderDetailCard(screenWidth),
                  SizedBox(height: screenWidth * 0.05),
                  _buildTermsAndConditionsCard(screenWidth),
                  SizedBox(height: screenWidth * 0.05),
                  _buildAgreementCheckbox(screenWidth),
                  const SizedBox(height: 32),
                  _buildActionButtons(screenWidth),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: _primaryColor),
              ),
            ),
        ],
      ),
    );
  }

  // Header Section with Icon and Title
  Widget _buildHeaderSection(double screenWidth) {
    return Column(
      children: [
        Icon(
          Icons.check_circle_outline,
          color: _primaryColor,
          size: screenWidth * 0.15,
        ),
        const SizedBox(height: 16),
        Text(
          'Detail Pesanan Parkir',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: screenWidth * 0.06,
            fontWeight: FontWeight.bold,
            color: _primaryColor,
          ),
        ),
      ],
    );
  }

  // Main Order Details Card
  Widget _buildOrderDetailCard(double screenWidth) {
    final formatters = _buildFormatters();

    return Container(
      padding: EdgeInsets.all(screenWidth * 0.05),
      decoration: BoxDecoration(
        color: _primaryColor,
        borderRadius: BorderRadius.circular(screenWidth * 0.04),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildDetailRow(
              label: 'Nama Pemesan',
              value: widget.namaPemesan,
              screenWidth: screenWidth),
          _buildDetailRow(
              label: 'Tanggal Pesan',
              value: formatters['orderDate']!,
              screenWidth: screenWidth),
          _buildDetailRow(
              label: 'Jam Pesan',
              value: '${formatters['orderTime']!} WIB',
              screenWidth: screenWidth),
          _buildDetailRow(
              label: 'Lokasi Parkir',
              value: widget.parkir.nama,
              screenWidth: screenWidth),
          _buildDetailRow(
              label: 'Tanggal Booking',
              value: formatters['visitDate']!,
              screenWidth: screenWidth),
          _buildDetailRow(
              label: 'Nomor Plat',
              value: widget.nomorPlat.toUpperCase(),
              screenWidth: screenWidth),
          _buildDetailRow(
              label: 'Jumlah Kendaraan',
              value: '${widget.jumlahKendaraan} Kendaraan',
              screenWidth: screenWidth),
          const Divider(color: Colors.white38, height: 32, thickness: 1),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Harga',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: screenWidth * 0.04,
                ),
              ),
              Text(
                formatters['currencyFormatter']!.format(widget.totalTarif),
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: screenWidth * 0.045,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Individual Detail Row
  Widget _buildDetailRow(
      {required String label,
      required String value,
      required double screenWidth}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white70,
              fontSize: screenWidth * 0.035,
            ),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: screenWidth * 0.035,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  // Terms & Conditions Card
  Widget _buildTermsAndConditionsCard(double screenWidth) {
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.05),
      decoration: BoxDecoration(
        color: _secondaryColor,
        borderRadius: BorderRadius.circular(screenWidth * 0.04),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Syarat dan Ketentuan Parkir',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: screenWidth * 0.04,
            ),
          ),
          const SizedBox(height: 16),
          _TermSection(
            screenWidth: screenWidth,
            title: 'Validitas',
            content:
                'Pemesanan parkir hanya berlaku untuk tanggal yang telah dipilih saat proses booking.',
          ),
          const SizedBox(height: 16),
          _TermSection(
            screenWidth: screenWidth,
            title: 'Tanggung Jawab',
            content:
                'Kehilangan atau kerusakan kendaraan menjadi tanggung jawab penuh pemilik kendaraan.',
          ),
        ],
      ),
    );
  }

  // Agreement Checkbox
  Widget _buildAgreementCheckbox(double screenWidth) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Row(
          children: [
            Checkbox(
              value: _isAgreed,
              onChanged: (bool? value) {
                setState(() {
                  _isAgreed = value ?? false;
                });
              },
              activeColor: _primaryColor,
              side: const BorderSide(color: _primaryColor),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4)),
            ),
            Expanded(
              child: Text(
                'Ya! saya setuju dengan syarat dan ketentuan yang berlaku.',
                style: TextStyle(
                  color: _primaryColor,
                  fontSize: screenWidth * 0.035,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Action Buttons
  Widget _buildActionButtons(double screenWidth) {
    final buttonHeight = screenWidth * 0.13;

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: buttonHeight,
          child: ElevatedButton(
            onPressed: (_isAgreed && !_isLoading) ? _processPayment : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              disabledBackgroundColor: Colors.grey.shade400,
              elevation: 2,
            ),
            child: Text(
              _isLoading ? 'Memproses...' : 'Lanjutkan Pembayaran',
              style: TextStyle(
                fontSize: screenWidth * 0.04,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: buttonHeight,
          child: ElevatedButton(
            onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: _accentColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 2,
            ),
            child: Text(
              'Batalkan',
              style: TextStyle(
                fontSize: screenWidth * 0.04,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Map<String, dynamic> _buildFormatters() {
    final now = DateTime.now();
    return {
      'orderDate': DateFormat('EEEE, d MMMM y', 'id_ID').format(now),
      'orderTime': DateFormat('HH:mm').format(now),
      'visitDate':
          DateFormat('EEEE, d MMMM y', 'id_ID').format(widget.tanggalBooking),
      'currencyFormatter': NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp ',
        decimalDigits: 0,
      ),
    };
  }

  // --- FUNGSI DENGAN KEY JSON YANG DIPERBAIKI ---
  Future<void> _processPayment() async {
    setState(() => _isLoading = true);

    const String apiUrl = 'https://unwild-uninfected-victoria.ngrok-free.dev/api/dolanbanyumas/midtrans/booking-parkir';

    try {
      // --- PERBAIKAN KEY JSON DISINI ---
      final Map<String, dynamic> requestBody = {
        // Key untuk mencari user_id (diasumsikan backend menangani ini)
        'first_name': widget.namaPemesan,
        'email': _emailPemesanAktif,

        // Key yang disamakan dengan nama kolom tabel 'parkir_bookings'
        'total_harga': widget.totalTarif,         // BUKAN 'gross_amount'
        'parking_type': 'Parkir: ${widget.parkir.nama}', // BUKAN 'wisata_name'
        'tanggal_booking': DateFormat('yyyy-MM-dd').format(widget.tanggalBooking), // BUKAN 'visit_date'
        'jumlah': widget.jumlahKendaraan,      // BUKAN 'quantity'
        'plat_nomor': widget.nomorPlat,       // Ini sudah benar
      };
      // --- AKHIR PERBAIKAN ---

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == 'success') {
          final String redirectUrl = data['redirect_url'];

          // Navigasi ke WebView
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MidtransWebViewPage(url: redirectUrl),
            ),
          );

          if (!mounted) return;

          // Handle hasil setelah dari webview
          if (result == 'success') {
            final messenger = ScaffoldMessenger.of(context);
            // Kembali ke halaman utama (home)
            Navigator.popUntil(context, (route) => route.isFirst);
            messenger.showSnackBar(
              const SnackBar(
                content: Text(
                    "Pesanan parkir berhasil dibuat!"),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 3),
              ),
            );
          }
        } else {
          throw Exception(
              'Gagal mendapatkan link pembayaran: ${data['message']}');
        }
      } else {
        // --- PERBAIKAN ERROR HANDLING UNTUK 422 ---
        final errorBody = jsonDecode(response.body);
        String errorMessage = errorBody['message'] ?? 'Data tidak valid';
        
        // Cek jika ada detail error validasi dari Laravel
        if (errorBody.containsKey('errors')) {
          // Ambil pesan error validasi pertama
          errorMessage = errorBody['errors'].entries.first.value[0];
        }
        throw Exception('Server Error: ${response.statusCode}. Pesan: $errorMessage');
        // --- AKHIR PERBAIKAN ERROR HANDLING ---
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Terjadi kesalahan: $e"),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

// Reusable Term Section Widget for Terms & Conditions
class _TermSection extends StatelessWidget {
  final String title;
  final String content;
  final double screenWidth;

  const _TermSection({
    required this.title,
    required this.content,
    required this.screenWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: screenWidth * 0.035,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          content,
          style: TextStyle(
            color: Colors.white70,
            fontSize: screenWidth * 0.032,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}