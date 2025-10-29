import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// Pastikan path import ini sudah benar sesuai struktur proyek Anda
import '../../models/wisata_model.dart'; 
import '../../pages/ticket/booking_parkir_page.dart';


class ParkingCard extends StatelessWidget {
  final TempatWisata parkir;

  const ParkingCard({
    super.key,
    required this.parkir,
  });

  static const Color _primaryColor = Color(0xFF425C48);
  static const Color _accentColor = Color(0xFFE3F0E3);

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final priceString = parkir.harga.replaceAll('.', '');
    final price = int.tryParse(priceString) ?? 0;

    return Card(
      color: _primaryColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      elevation: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            parkir.gambarUrl,
            height: 120,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              height: 120,
              color: Colors.black26,
              child: const Icon(Icons.local_parking, color: Colors.white54, size: 50),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Thr Pangsar Soedirman',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      parkir.nama,
                      style: const TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    Text(
                      currencyFormatter.format(price),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    // --- PERUBAHAN HANYA DI BAGIAN INI ---
                    onPressed: () {
                      // Kode sebelumnya yang menampilkan SnackBar diganti
                      // dengan kode navigasi ke halaman booking.
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookingParkirPage(parkir: parkir),
                        ),
                      );
                    },
                    // --- AKHIR DARI PERUBAHAN ---
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _accentColor,
                      foregroundColor: _primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Pesan Sekarang',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
}