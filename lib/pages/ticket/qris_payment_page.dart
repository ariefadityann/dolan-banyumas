import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart'; // <-- JANGAN LUPA: flutter pub add qr_flutter
import 'payment_succes.dart'; // <-- Import halaman sukses

class QrisPaymentPage extends StatelessWidget {
  final double totalHarga;

  const QrisPaymentPage({
    super.key,
    required this.totalHarga,
  });

  // Constants for styling
  static const _pageBackgroundColor = Color(0xFFFFE6E5);
  static const _cardBackgroundColor = Color(0xFFFAFDFB);
  static const _primaryTextColor = Color(0xFFF44336);
  static const _buttonColor = Color(0xFFF44336);

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'RP ',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: _pageBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Kode QRIS',
          style: TextStyle(
            color: _primaryTextColor,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        backgroundColor: _pageBackgroundColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _primaryTextColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24.0, vertical: 32.0),
                decoration: BoxDecoration(
                  color: _cardBackgroundColor,
                  borderRadius: BorderRadius.circular(24.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 20,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Access',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: _primaryTextColor)),
                    const SizedBox(height: 4),
                    const Text('Curug Gomblang',
                        style:
                            TextStyle(fontSize: 16, color: _primaryTextColor)),
                    const SizedBox(height: 16),
                    Text(
                      currencyFormatter.format(totalHarga),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: _primaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 24),
                    QrImageView(
                      data: 'dummy_qris_data_for_${totalHarga.toInt()}',
                      version: QrVersions.auto,
                      size: 220.0,
                      gapless: false,
                      // Saya komentari aset logo agar tidak error jika file tidak ada
                      // embeddedImage: const AssetImage(
                      //     'assets/images/qris_logo.png'),
                      // embeddedImageStyle: const QrEmbeddedImageStyle(
                      //   size: Size(40, 40),
                      // ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildActionButton(
              text: 'Unduh QRIS',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Fitur unduh akan segera hadir!')),
                );
              },
            ),
            const SizedBox(height: 12),
            // --- INI TOMBOL DENGAN SOLUSI NAVIGASI ---
            _buildActionButton(
              text: 'Lanjutkan',
              onTap: () {
                // INI SOLUSINYA:
                // 1. Arahkan ke Halaman Sukses.
                // 2. Hapus SEMUA halaman di atas HomeScreen/IndexPage.
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PaymentSuccessPage(), // Ke halaman sukses
                  ),
                  // 'route.isFirst' berarti "berhenti menghapus ketika
                  // kita sampai di rute pertama", yaitu IndexPage Anda.
                  (Route<dynamic> route) => route.isFirst,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
      {required String text, required VoidCallback onTap}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: _buttonColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          elevation: 2,
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}