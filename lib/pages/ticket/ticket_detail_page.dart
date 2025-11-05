// lib/pages/ticket_detail_page.dart
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/purchased_ticket_model.dart';

class TicketDetailPage extends StatelessWidget {
  final PurchasedTicket ticket;

  const TicketDetailPage({super.key, required this.ticket});

  static const _primaryColor = Color(0xFFF44336);
  static const _lightTextColor = Colors.white70;
  static const _darkTextColor = Color(0xFFF44336);
  static const _whiteColor = Colors.white;

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
        'Riwayat Wisata',
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
            ticket.orderDate,
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
              _buildDetailRow('Tanggal Pesan', ticket.orderDate, width),
              _buildDetailRow('Jam Pesan', ticket.orderTime, width),
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
            'Rp ${_formatPrice(ticket.totalPrice.toDouble())}',
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

  String _formatPrice(double price) {
    return price.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  void _shareTicket() {
    Share.share(
      'Tiket Wisata: ${ticket.locationName}\n'
      'Tanggal: ${ticket.visitDate}\n'
      'Kode Tiket: ${ticket.ticketId}',
      subject: 'Tiket Wisata Anda',
    );
  }
}
