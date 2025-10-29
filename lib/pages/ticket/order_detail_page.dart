import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dolan_banyumas/pages/ticket/payment_method_page.dart';

class OrderDetailPage extends StatefulWidget {
  final String namaPemesan;
  final String tempatWisata;
  final DateTime tanggalBerkunjung;
  final int jumlahTiket;
  final double totalHarga;

  const OrderDetailPage({
    super.key,
    required this.namaPemesan,
    required this.tempatWisata,
    required this.tanggalBerkunjung,
    required this.jumlahTiket,
    required this.totalHarga,
  });

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  bool _isAgreed = false;

  // Constants for colors and styling
  static const _backgroundColor = Color(0xFFF9F6F0);
  static const _primaryColor = Color(0xFF3B614A);
  static const _secondaryColor = Color(0xFF4C7C60);
  static const _accentColor = Color(0xFFE87A5D);
  static const _spacing = 20.0;
  static const _cardBorderRadius = 16.0;
  static const _buttonHeight = 50.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 24.0,
            vertical: 32.0,
          ),
          child: Column(
            children: [
              // Header Section
              _buildHeaderSection(),
              const SizedBox(height: _spacing),

              // Order Details Card
              _buildOrderDetailCard(),
              const SizedBox(height: _spacing),

              // Terms & Conditions Card
              _buildTermsAndConditionsCard(),
              const SizedBox(height: _spacing),

              // Agreement Checkbox
              _buildAgreementCheckbox(),
              const SizedBox(height: 32),

              // Action Buttons
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  // Header Section with Icon and Title
  Widget _buildHeaderSection() {
    return const Column(
      children: [
        Icon(
          Icons.check_circle,
          color: _primaryColor,
          size: 60,
        ),
        SizedBox(height: 16),
        Text(
          'Detail Pesanan',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: _primaryColor,
          ),
        ),
      ],
    );
  }

  // Main Order Details Card
  Widget _buildOrderDetailCard() {
    final formatters = _buildFormatters();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _primaryColor,
        borderRadius: BorderRadius.circular(_cardBorderRadius),
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
          ),
          _buildDetailRow(
            label: 'Tanggal Pesan',
            value: formatters['orderDate']!,
          ),
          _buildDetailRow(
            label: 'Jam Pesan',
            value: '${formatters['orderTime']!} WIB',
          ),
          _buildDetailRow(
            label: 'Tempat Wisata',
            value: widget.tempatWisata,
          ),
          _buildDetailRow(
            label: 'Tanggal Berkunjung',
            value: formatters['visitDate']!,
          ),
          _buildDetailRow(
            label: 'Jumlah Tiket',
            value: widget.jumlahTiket.toString(),
          ),

          const Divider(
            color: Colors.white38,
            height: 32,
            thickness: 1,
          ),

          // Total Price Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Harga',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                formatters['currencyFormatter']!.format(widget.totalHarga),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Individual Detail Row
  Widget _buildDetailRow({
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            textAlign: TextAlign.end,
          ),
        ],
      ),
    );
  }

  // Terms & Conditions Card
  Widget _buildTermsAndConditionsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _secondaryColor,
        borderRadius: BorderRadius.circular(_cardBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Syarat dan Ketentuan',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 16),

          // Pemesanan Section
          _TermSection(
            title: 'Pemesanan',
            content: 'Pemesanan secara elektronik dilakukan 3 hari sebelum '
                'kunjungan ke tempat wisata.',
          ),
          SizedBox(height: 16),

          // Pembayaran Section
          _TermSection(
            title: 'Pembayaran',
            content: 'Pembayaran dilakukan sejak pemesanan online sampai '
                'dengan hari kunjungan ke tempat wisata.',
          ),
        ],
      ),
    );
  }

  // Agreement Checkbox
  Widget _buildAgreementCheckbox() {
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
        padding: const EdgeInsets.symmetric(
          horizontal: 12.0,
          vertical: 8.0,
        ),
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
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const Expanded(
              child: Text(
                'Ya! saya setuju dengan syarat dan ketentuan yang berlaku.',
                style: TextStyle(
                  color: _primaryColor,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Action Buttons
  Widget _buildActionButtons() {
    return Column(
      children: [
        // Continue Button
        SizedBox(
          width: double.infinity,
          height: _buttonHeight,
          child: ElevatedButton(
            onPressed: _isAgreed ? _onContinuePressed : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              disabledBackgroundColor: Colors.grey.shade400,
              elevation: 2,
            ),
            child: const Text(
              'Lanjutkan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Cancel Button
        SizedBox(
          width: double.infinity,
          height: _buttonHeight,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: _accentColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: const Text(
              'Batalkan',
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

  // Helper method to create formatters
  Map<String, dynamic> _buildFormatters() {
    final now = DateTime.now();
    return {
      'orderDate': DateFormat('yyyy-MM-dd').format(now),
      'orderTime': DateFormat('HH:mm:ss').format(now),
      'visitDate': DateFormat('yyyy-MM-dd').format(widget.tanggalBerkunjung),
      'currencyFormatter': NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp ',
        decimalDigits: 0,
      ),
    };
  }

  // Continue button handler
  void _onContinuePressed() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Menuju halaman pembayaran...'),
        duration: Duration(seconds: 1), // Durasi dipercepat
      ),
    );

    // Navigasi ke halaman pembayaran baru
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentMethodPage(
          totalHarga: widget.totalHarga, // Mengirim total harga
        ),
      ),
    );
  }
}

// Reusable Term Section Widget for Terms & Conditions
class _TermSection extends StatelessWidget {
  final String title;
  final String content;

  const _TermSection({
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          content,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 13,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
