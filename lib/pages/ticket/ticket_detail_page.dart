// lib/pages/ticket_detail_page.dart
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart'; // <-- Import untuk format
import 'package:http/http.dart' as http; // <-- Import untuk API
import 'dart:convert'; // <-- Import untuk JSON
import 'package:shared_preferences/shared_preferences.dart'; // <-- Import untuk Token

import '../../models/purchased_ticket_model.dart';
// Sesuaikan path ini dengan lokasi MidtransWebViewPage Anda
import 'midtrans_webview.dart'; 

class TicketDetailPage extends StatelessWidget {
  final PurchasedTicket ticket;

  const TicketDetailPage({super.key, required this.ticket});

  static const _primaryColor = Color(0xFFF44336);
  static const _lightTextColor = Colors.white70;
  static const _darkTextColor = Color(0xFFF44336);
  static const _whiteColor = Colors.white;

  // Ganti URL ini jika perlu. '10.0.2.2' untuk emulator Android
  static const String _baseUrl = 'http://10.0.2.2:8000/api/dolanbanyumas';

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F8F5),
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(width * 0.06),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTicketStub(width, height),
            SizedBox(height: height * 0.04),
            _buildTicketDetails(width),
            SizedBox(height: height * 0.03),
            // Widget baru untuk tombol aksi
            _buildPendingActions(context, width, height),
            SizedBox(height: height * 0.03),
            _buildTotalPrice(width, height),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      toolbarHeight: 90,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      backgroundColor: _primaryColor,
      elevation: 0,
      centerTitle: true,
      title: const Text(
        'Detail Tiket', // Nama halaman
        style: TextStyle(
          color: _whiteColor,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: _whiteColor),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.ios_share, color: _whiteColor),
          onPressed: _shareTicket,
        ),
      ],
    );
  }

  Widget _buildTicketStub(double width, double height) {
    return Container(
      padding: EdgeInsets.all(width * 0.06),
      decoration: BoxDecoration(
        color: _primaryColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            ticket.locationName,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _whiteColor,
              fontSize: width * 0.055,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: height * 0.008),
          Text(
            // Format tanggal "YYYY-MM-DD" -> "17 November 2025"
            _formatDisplayDate(ticket.orderDate),
            style: TextStyle(
              color: _lightTextColor,
              fontSize: width * 0.035,
            ),
          ),
          SizedBox(height: height * 0.02),
          _buildUserInfoRow(width, height),
          SizedBox(height: height * 0.03),
          _buildDashedDivider(),
          SizedBox(height: height * 0.03),
          _buildQrCodeSection(width),
          SizedBox(height: height * 0.02),
          Text(
            ticket.ticketId,
            style: TextStyle(
              color: _whiteColor,
              fontSize: width * 0.045,
              letterSpacing: 2,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfoRow(double width, double height) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          flex: 2,
          child: Text(
            'Nama Pengguna\n${ticket.userName}',
            style: TextStyle(
              color: _whiteColor,
              fontSize: width * 0.035,
              height: 1.4,
            ),
          ),
        ),
        Flexible(
          flex: 1,
          child: Text(
            'Total Tiket\n${ticket.quantity}',
            textAlign: TextAlign.right,
            style: TextStyle(
              color: _whiteColor,
              fontSize: width * 0.035,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQrCodeSection(double width) {
    return Container(
      padding: EdgeInsets.all(width * 0.02),
      decoration: BoxDecoration(
        color: _whiteColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: QrImageView(
        data: ticket.ticketId,
        version: QrVersions.auto,
        size: width * 0.4,
      ),
    );
  }

  Widget _buildTicketDetails(double width) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Detail Tiket',
          style: TextStyle(
            fontSize: width * 0.05,
            fontWeight: FontWeight.bold,
            color: _darkTextColor,
          ),
        ),
        SizedBox(height: width * 0.03),
        Container(
          padding: EdgeInsets.all(width * 0.05),
          decoration: BoxDecoration(
            color: _primaryColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              _buildDetailRow('Nama Pemesan', ticket.userName, width),
              _buildDetailRow(
                  'Tanggal Pesan', _formatDisplayDate(ticket.orderDate), width),
              // --- PERUBAHAN: Menampilkan Status ---
              _buildDetailRow(
                  'Status', ticket.status.capitalizeFirst(), width),
              _buildDetailRow('Tempat Wisata', ticket.locationName, width),
              _buildDetailRow('Tanggal Berkunjung', ticket.visitDate, width),
              _buildDetailRow('Jumlah Tiket', ticket.quantity.toString(), width,
                  isLast: true),
            ],
          ),
        ),
      ],
    );
  }

  /// Widget BARU untuk tombol 'Lanjut Bayar' dan 'Batal'
  Widget _buildPendingActions(BuildContext context, double width, double height) {
    // Tampilkan hanya jika status 'pending'
    if (ticket.status != 'pending') {
      return const SizedBox.shrink(); // Kembalikan widget kosong
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Tombol Lanjutkan Pembayaran
        SizedBox(
          height: height * 0.06,
          child: ElevatedButton(
            onPressed: () => _continuePayment(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
              foregroundColor: _whiteColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Lanjutkan Pembayaran',
              style: TextStyle(
                fontSize: width * 0.04,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        SizedBox(height: height * 0.015),
        // Tombol Batalkan Pesanan
        SizedBox(
          height: height * 0.06,
          child: ElevatedButton(
            onPressed: () => _cancelBooking(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[200],
              foregroundColor: _darkTextColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: _primaryColor, width: 1.5),
              ),
              elevation: 0,
            ),
            child: Text(
              'Batalkan Pesanan',
              style: TextStyle(
                fontSize: width * 0.04,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, double width,
      {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : width * 0.03),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                color: _lightTextColor,
                fontSize: width * 0.035,
              ),
            ),
          ),
          Flexible(
            flex: 2,
            child: Text(
              value,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: _whiteColor,
                fontSize: width * 0.035,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalPrice(double width, double height) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: width * 0.05,
        vertical: height * 0.018,
      ),
      decoration: BoxDecoration(
        color: _primaryColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Total Harga',
            style: TextStyle(
              color: _whiteColor,
              fontSize: width * 0.04,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            NumberFormat.currency(
              locale: 'id_ID',
              symbol: 'Rp ',
              decimalDigits: 0,
            ).format(ticket.totalPrice), // Menggunakan int totalPrice
            style: TextStyle(
              color: _whiteColor,
              fontSize: width * 0.04,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashedDivider() {
    return Row(
      children: List.generate(
        20,
        (index) => Expanded(
          child: Container(
            color: index.isEven ? Colors.transparent : _lightTextColor,
            height: 2,
          ),
        ),
      ),
    );
  }

  /// Mengubah format "YYYY-MM-DD" menjadi "d MMMM y" (cth: "17 November 2025")
  String _formatDisplayDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('d MMMM y', 'id_ID').format(date);
    } catch (e) {
      return dateString;
    }
  }

  void _shareTicket() {
    Share.share(
      'Tiket Wisata: ${ticket.locationName}\n'
      'Tanggal: ${ticket.visitDate}\n'
      'Kode Tiket: ${ticket.ticketId}',
      subject: 'Tiket Wisata Anda',
    );
  }

  // --- LOGIKA-LOGIKA BARU ---

  /// Membuka WebView dan menunggu hasilnya
  void _continuePayment(BuildContext context) async {
    if (ticket.midtransUrl != null && ticket.midtransUrl!.isNotEmpty) {
      
      // 'await' hasil dari WebView
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MidtransWebViewPage(url: ticket.midtransUrl!),
        ),
      );

      // Cek hasil setelah kembali dari WebView
      if (result == 'success' && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pembayaran berhasil! Status akan segera diperbarui.'),
            backgroundColor: Colors.green,
          ),
        );
        // Tutup halaman detail, paksa user kembali ke list (yang akan auto-refresh)
        Navigator.pop(context, 'refresh');
      }

    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: URL Pembayaran tidak ditemukan.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Menampilkan dialog konfirmasi pembatalan
  void _cancelBooking(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Batalkan Pesanan?'),
        content: const Text(
            'Apakah Anda yakin ingin membatalkan pesanan ini? Tindakan ini tidak dapat diurungkan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Tidak'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext); // Tutup dialog konfirmasi
              _performCancelApi(context); // Lakukan pembatalan
            },
            child: const Text('Ya, Batalkan', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  /// Memanggil API untuk membatalkan pesanan
  Future<void> _performCancelApi(BuildContext context) async {
    // Tampilkan loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: _primaryColor),
      ),
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) throw Exception('Sesi tidak valid. Silakan login ulang.');

      // API endpoint baru yang harus Anda buat di Laravel
      final response = await http.post(
        Uri.parse('$_baseUrl/midtrans/cancel-booking'), // URL API Pembatalan
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode({'order_id': ticket.ticketId}),
      );

      Navigator.pop(context); // Tutup loading dialog

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pesanan berhasil dibatalkan.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, 'refresh');
      } else {
        final error = json.decode(response.body)['message'] ?? 'Gagal membatalkan pesanan';
        throw Exception(error);
      }
    } catch (e) {
      if (context.mounted) {
         Navigator.pop(context); // Tutup loading dialog jika error
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

/// Extension untuk membuat 'pending' -> 'Pending'
extension StringExtension on String {
  String capitalizeFirst() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}