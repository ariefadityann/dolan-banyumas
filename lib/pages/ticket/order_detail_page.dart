import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; 
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'midtrans_webview.dart';

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
  bool _isLoading = false;
  String _namaPemesanAktif = '';
  String _emailPemesanAktif = '';

  // Constants
  static const _backgroundColor = Color(0xFFF9F6F0);
  static const _primaryColor = Color(0xFFF44336);
  static const _secondaryColor = Color(0xFFE57373);
  static const _accentColor = Color(0xFFF44336);
  static const _spacing = 20.0;
  static const _cardBorderRadius = 16.0;
  static const _buttonHeight = 50.0;

  @override
  void initState() {
    super.initState();
    _namaPemesanAktif = widget.namaPemesan;
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedName = prefs.getString('user_name');
    final String? savedEmail = prefs.getString('user_email');

    if (mounted) {
      setState(() {
        if (savedName != null &&
            savedName.isNotEmpty &&
            savedName != 'undefined') {
          _namaPemesanAktif = savedName;
        }
        _emailPemesanAktif = savedEmail ?? 'pengunjung@dolanbanyumas.com';
      });
    }
  }

  Future<void> _processPayment() async {
  setState(() => _isLoading = true);

  const String apiUrl =
      'https://unwild-uninfected-victoria.ngrok-free.dev/api/dolanbanyumas/midtrans/transaction';

  try {
    final Map<String, dynamic> requestBody = {
      'gross_amount': widget.totalHarga,
      'first_name': _namaPemesanAktif,
      'email': _emailPemesanAktif,
      'wisata_name': widget.tempatWisata,
      'visit_date': DateFormat('yyyy-MM-dd').format(widget.tanggalBerkunjung),
      'quantity': widget.jumlahTiket,
    };

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(requestBody),
    );

    if (!mounted) return;

    if (response.statusCode != 200) {
      throw Exception("Server error: ${response.statusCode}");
    }

    final data = jsonDecode(response.body);

    if (data['status'] != 'success') {
      throw Exception("Midtrans error: ${data['message']}");
    }

    final String redirectUrl = data['redirect_url'];

    // --------------------------
    // PLATFORM CHECKING
    // --------------------------

    if (kIsWeb) {
      // WEB → buka tab baru
      final Uri url = Uri.parse(redirectUrl);
      await launchUrl(url, mode: LaunchMode.externalApplication);
      return;
    }

    // ANDROID → buka WebView
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MidtransWebViewPage(url: redirectUrl),
      ),
    );

    if (!mounted) return;

    if (result == "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Pembayaran berhasil!"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }

  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              child: Column(
                children: [
                  _buildHeaderSection(),
                  const SizedBox(height: _spacing),
                  _buildOrderDetailCard(),
                  const SizedBox(height: _spacing),
                  _buildTermsAndConditionsCard(),
                  const SizedBox(height: _spacing),
                  _buildAgreementCheckbox(),
                  const SizedBox(height: 32),
                  _buildActionButtons(),
                ],
              ),
            ),
            if (_isLoading)
              Container(
                color: Colors.black54, // PERBAIKAN: Mengganti withOpacity
                child: const Center(
                  child: CircularProgressIndicator(color: _primaryColor),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return const Column(
      children: [
        Icon(Icons.check_circle, color: _primaryColor, size: 60),
        SizedBox(height: 16),
        Text('Detail Pesanan',
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: _primaryColor)),
      ],
    );
  }

  Widget _buildOrderDetailCard() {
    final formatters = _buildFormatters();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _primaryColor,
        borderRadius: BorderRadius.circular(_cardBorderRadius),
        boxShadow: [
          BoxShadow(
              color: Colors.black12, // PERBAIKAN: Mengganti withOpacity
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          _buildDetailRow(label: 'Nama Pemesan', value: _namaPemesanAktif),
          _buildDetailRow(
              label: 'Tanggal Pesan', value: formatters['orderDate']!),
          _buildDetailRow(
              label: 'Jam Pesan', value: '${formatters['orderTime']!} WIB'),
          _buildDetailRow(label: 'Tempat Wisata', value: widget.tempatWisata),
          _buildDetailRow(
              label: 'Tanggal Berkunjung', value: formatters['visitDate']!),
          _buildDetailRow(
              label: 'Jumlah Tiket', value: widget.jumlahTiket.toString()),
          const Divider(color: Colors.white38, height: 32, thickness: 1),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Harga',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
              Text(
                formatters['currencyFormatter']!.format(widget.totalHarga),
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 14)),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14),
              textAlign: TextAlign.end),
        ],
      ),
    );
  }

  Widget _buildTermsAndConditionsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: _secondaryColor,
          borderRadius: BorderRadius.circular(_cardBorderRadius),
          boxShadow: [
             BoxShadow(
                color: Colors.black12, // PERBAIKAN: Mengganti withOpacity
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ]
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Syarat dan Ketentuan',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
          SizedBox(height: 16),
          _TermSection(
              title: 'Pemesanan',
              content:
                  'Pemesanan secara elektronik dilakukan 3 hari sebelum kunjungan ke tempat wisata.'),
          SizedBox(height: 16),
          _TermSection(
              title: 'Pembayaran',
              content:
                  'Pembayaran dilakukan sejak pemesanan online sampai dengan hari kunjungan ke tempat wisata.'),
        ],
      ),
    );
  }

  Widget _buildAgreementCheckbox() {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white, 
          borderRadius: BorderRadius.circular(12),
           boxShadow: [
             BoxShadow(
                color: Colors.black.withOpacity(0.05), // Ini juga bisa diganti
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
           ]
          ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Row(
          children: [
            Checkbox(
              value: _isAgreed,
              onChanged: (bool? value) =>
                  setState(() => _isAgreed = value ?? false),
              activeColor: _primaryColor,
              side: const BorderSide(color: _primaryColor),
            ),
            const Expanded(
                child: Text(
                    'Ya! saya setuju dengan syarat dan ketentuan yang berlaku.',
                    style: TextStyle(color: _primaryColor, fontSize: 14))),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: _buttonHeight,
          child: ElevatedButton(
            onPressed: (_isAgreed && !_isLoading) ? _processPayment : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              disabledBackgroundColor: Colors.grey.shade400,
            ),
            child: Text(
              _isLoading ? 'Memproses...' : 'Lanjutkan Pembayaran',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: _buttonHeight,
          child: ElevatedButton(
            onPressed: _isLoading ? null : () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: _accentColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Batalkan',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Map<String, dynamic> _buildFormatters() {
    final now = DateTime.now();
    return {
      'orderDate': DateFormat('yyyy-MM-dd').format(now),
      'orderTime': DateFormat('HH:mm:ss').format(now),
      'visitDate': DateFormat('yyyy-MM-dd').format(widget.tanggalBerkunjung),
      'currencyFormatter': NumberFormat.currency(
          locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0),
    };
  }
}

class _TermSection extends StatelessWidget {
  final String title;
  final String content;
  const _TermSection({required this.title, required this.content});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14)),
        const SizedBox(height: 4),
        Text(content,
            style: const TextStyle(
                color: Colors.white70, fontSize: 13, height: 1.4)),
      ],
    );
  }
}