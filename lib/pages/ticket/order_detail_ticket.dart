import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/wisata_model.dart'; // Pastikan path import ini sama

class KonfirmasiBookingPage extends StatefulWidget {
  final TempatWisata parkir;
  final String nomorPlat;
  final int jumlahKendaraan;
  final double totalTarif;
  final DateTime tanggalBooking;

  const KonfirmasiBookingPage({
    super.key,
    required this.parkir,
    required this.nomorPlat,
    required this.jumlahKendaraan,
    required this.totalTarif,
    required this.tanggalBooking,
  });

  @override
  State<KonfirmasiBookingPage> createState() => _KonfirmasiBookingPageState();
}

class _KonfirmasiBookingPageState extends State<KonfirmasiBookingPage> {
  bool _isAgreed = false;

  // Constants for colors
  static const _backgroundColor = Color(0xFFF9F6F0);
  static const _primaryColor = Color(0xFF3B614A);
  static const _secondaryColor = Color(0xFF4C7C60);
  static const _accentColor = Color(0xFFE87A5D);

  @override
  Widget build(BuildContext context) {
    // RESPONSIVE: Get screen width for proportional sizing
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          // RESPONSIVE: Use proportional padding
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.06,
            vertical: 32.0,
          ),
          child: Column(
            children: [
              // Header Section
              _buildHeaderSection(screenWidth),
              SizedBox(height: screenWidth * 0.05),

              // Order Details Card
              _buildOrderDetailCard(screenWidth),
              SizedBox(height: screenWidth * 0.05),

              // Terms & Conditions Card
              _buildTermsAndConditionsCard(screenWidth),
              SizedBox(height: screenWidth * 0.05),

              // Agreement Checkbox
              _buildAgreementCheckbox(screenWidth),
              const SizedBox(height: 32),

              // Action Buttons
              _buildActionButtons(screenWidth),
            ],
          ),
        ),
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
          // RESPONSIVE: Proportional icon size
          size: screenWidth * 0.15,
        ),
        const SizedBox(height: 16),
        Text(
          'Detail Pesanan Parkir',
          textAlign: TextAlign.center,
          style: TextStyle(
            // RESPONSIVE: Proportional font size
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
      // RESPONSIVE: Proportional padding
      padding: EdgeInsets.all(screenWidth * 0.05),
      decoration: BoxDecoration(
        color: _primaryColor,
        // RESPONSIVE: Proportional border radius
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
              value: 'Pengguna',
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
                  // RESPONSIVE: Proportional font size
                  fontSize: screenWidth * 0.04,
                ),
              ),
              Text(
                formatters['currencyFormatter']!.format(widget.totalTarif),
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  // RESPONSIVE: Proportional font size
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
              // RESPONSIVE: Proportional font size
              fontSize: screenWidth * 0.035,
            ),
          ),
          const SizedBox(width: 16),
          // RESPONSIVE: Use Flexible to allow text to wrap if it's too long
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                // RESPONSIVE: Proportional font size
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
      // RESPONSIVE: Proportional padding
      padding: EdgeInsets.all(screenWidth * 0.05),
      decoration: BoxDecoration(
        color: _secondaryColor,
        // RESPONSIVE: Proportional border radius
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
              // RESPONSIVE: Proportional font size
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
                  // RESPONSIVE: Proportional font size
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
    // RESPONSIVE: Proportional button height
    final buttonHeight = screenWidth * 0.13;

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: buttonHeight,
          child: ElevatedButton(
            onPressed: _isAgreed ? _onContinuePressed : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              disabledBackgroundColor: Colors.grey.shade400,
              elevation: 2,
            ),
            child: Text(
              'Lanjutkan Pembayaran',
              style: TextStyle(
                // RESPONSIVE: Proportional font size
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
            onPressed: () => Navigator.of(context).pop(),
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
                // RESPONSIVE: Proportional font size
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

  void _onContinuePressed() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pemesanan berhasil! Menuju halaman pembayaran...'),
        backgroundColor: _primaryColor,
        duration: Duration(seconds: 2),
      ),
    );
    // TODO: Add navigation to payment page
    print('Navigasi ke halaman pembayaran...');
  }
}

// Reusable Term Section Widget for Terms & Conditions
class _TermSection extends StatelessWidget {
  final String title;
  final String content;
  // RESPONSIVE: Accept screenWidth
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
            // RESPONSIVE: Proportional font size
            fontSize: screenWidth * 0.035,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          content,
          style: TextStyle(
            color: Colors.white70,
            // RESPONSIVE: Proportional font size
            fontSize: screenWidth * 0.032,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
