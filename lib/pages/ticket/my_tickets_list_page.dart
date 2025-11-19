// lib/pages/my_tickets_list_page.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import '../../models/purchased_ticket_model.dart';
import 'ticket_detail_page.dart'; // Mengarah ke TicketDetailPage

class MyTicketsListPage extends StatefulWidget {
  const MyTicketsListPage({super.key});

  @override
  State<MyTicketsListPage> createState() => _MyTicketsListPageState();
}

class _MyTicketsListPageState extends State<MyTicketsListPage> {
  List<PurchasedTicket> _purchasedTickets = [];
  bool _isLoading = true;
  String _errorMessage = '';

  // Ganti '10.0.2.2' dengan IP server/laptop Anda jika pakai HP fisik
  final String _baseUrl = 'http://10.0.2.2:8000/api/dolanbanyumas/midtrans';

  @override
  void initState() {
    super.initState();
    _fetchHistoryData();
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> _fetchHistoryData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    // --- 1. Dapatkan tanggal hari ini (tanpa jam) ---
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);


    final String? token = await _getToken();
    if (token == null || token.isEmpty) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Sesi Anda telah habis. Silakan login ulang.';
        });
      }
      return;
    }

    final headers = {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    };

    try {
      final responses = await Future.wait([
        http.get(Uri.parse('$_baseUrl/transactions'), headers: headers),
        http.get(Uri.parse('$_baseUrl/booking-parkir'), headers: headers),
      ]);

      final List<Map<String, dynamic>> allItems = [];

      // --- Proses data Tiket Wisata (transactions) ---
      if (responses[0].statusCode == 200) {
        final body = json.decode(responses[0].body);
        if (body['success'] == true) {
          final data = body['data'] as List;
          allItems.addAll(data.map((item) => (item as Map<String, dynamic>)..['type'] = 'transaction'));
        } else {
          throw Exception(body['message'] ?? 'Gagal memuat riwayat tiket');
        }
      } else if (responses[0].statusCode == 401) {
        throw Exception('Sesi habis. Silakan login ulang.');
      } else {
        throw Exception('Error Tiket: ${responses[0].statusCode}');
      }

      // --- Proses data Parkir (booking-parkir) ---
      if (responses[1].statusCode == 200) {
        final body = json.decode(responses[1].body);
        if (body['success'] == true) {
          final data = body['data'] as List;
          allItems.addAll(data.map((item) => (item as Map<String, dynamic>)..['type'] = 'parkir'));
        } else {
          throw Exception(body['message'] ?? 'Gagal memuat riwayat parkir');
        }
      } else if (responses[1].statusCode == 401) {
        throw Exception('Sesi habis. Silakan login ulang.');
      } else {
        throw Exception('Error Parkir: ${responses[1].statusCode}');
      }
      
      // --- 2. Filter data mentah SEBELUM di-map ---
      final List<Map<String, dynamic>> filteredItems = allItems.where((item) {
        
        // --- LANGKAH 1: Filter Status ---
        // Kita hanya mau status 'success' ATAU 'pending'.
        final String status = item['status'] ?? 'pending';
        if (status.toLowerCase() != 'success' && status.toLowerCase() != 'pending') {
          return false; // Buang 'failed', 'expired', 'canceled', dll.
        }

        // --- LANGKAH 2: Filter Tanggal (Berlaku untuk 'success' DAN 'pending') ---
        String? dateString;
        if (item['type'] == 'transaction') {
          dateString = item['visit_date'];
        } else {
          dateString = item['tanggal_booking'];
        }

        // Jika tidak ada tanggal, sembunyikan
        if (dateString == null) {
          return false; 
        }

        try {
          final visitDate = DateTime.parse(dateString);
          
          // Filter UTAMA: Tampilkan HANYA jika tanggalnya HARI INI atau MENDATANG.
          // !isBefore(today) berarti "sama dengan atau sesudah" hari ini
          return !visitDate.isBefore(today); 

        } catch (e) {
          return false; // Gagal parse tanggal, sembunyikan
        }

      }).toList(); // <-- Buat list baru dari hasil filter


      // --- 3. Urutkan data yang SUDAH DIFILTER ---
      filteredItems.sort((a, b) {
        try {
          return DateTime.parse(b['created_at']).compareTo(DateTime.parse(a['created_at']));
        } catch(e) {
          return 0;
        }
      });
      
      // --- 4. Map data yang SUDAH DIFILTER ---
      final List<PurchasedTicket> allTickets = filteredItems.map((item) {
        if (item['type'] == 'transaction') {
          return _mapTransactionToTicket(item);
        } else {
          return _mapParkirToTicket(item);
        }
      }).toList();


      if (mounted) {
        setState(() {
          _purchasedTickets = allTickets;
          _isLoading = false;
        });
      }

    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
      }
    }
  }

  // Helper untuk mapping data Tiket Wisata
  PurchasedTicket _mapTransactionToTicket(Map<String, dynamic> item) {
    final createdAt = DateTime.parse(item['created_at']);
    final orderDateOnly = DateFormat('yyyy-MM-dd').format(createdAt);
    
    final String? snapToken = item['snap_token'];
    final String? midtransUrl = snapToken != null
        ? "https://app.sandbox.midtrans.com/snap/v2/vtweb/$snapToken"
        : null;
    
    return PurchasedTicket(
      locationName: item['wisata_name'] ?? 'Wisata',
      category: 'Nama Wisata',
      visitDate: _formatSimpleDate(item['visit_date']),
      quantity: item['total_tickets'] ?? 0,
      imageUrl: 'assets/img/alunalun.jpg', // Gambar statis
      userName: item['user_name'] ?? 'Pengguna',
      orderDate: orderDateOnly,
      orderTime: "${DateFormat('HH:mm:ss', 'id_ID').format(createdAt)} WIB",
      ticketId: item['order_id'] ?? 'N/A',
      totalPrice: (double.tryParse(item['total_price'].toString()) ?? 0.0).toInt(),
      status: item['status'] ?? 'pending',
      midtransUrl: midtransUrl,
    );
  }

  // Helper untuk mapping data Parkir
  PurchasedTicket _mapParkirToTicket(Map<String, dynamic> item) {
    final createdAt = DateTime.parse(item['created_at']);
    final orderDateOnly = DateFormat('yyyy-MM-dd').format(createdAt);

    String category = item['parking_type'] ?? 'Parkir';
    if (category.contains(':')) {
      category = category.split(':').last.trim();
    }

    return PurchasedTicket(
      locationName: category,
      category: 'Tiket Parkir',
      visitDate: _formatSimpleDate(item['tanggal_booking']),
      quantity: item['jumlah'] ?? 0,
      imageUrl: 'assets/img/alunalun.jpg', // Gambar statis
      userName: item['nama_lengkap'] ?? 'Pengguna',
      orderDate: orderDateOnly,
      orderTime: "${DateFormat('HH:mm:ss', 'id_ID').format(createdAt)} WIB",
      ticketId: item['order_id'] ?? 'N/A',
      totalPrice: (double.tryParse(item['total_harga'].toString()) ?? 0.0).toInt(),
      status: item['status'] ?? 'pending',
      midtransUrl: item['midtrans_url'], // Langsung ambil dari API
    );
  }

  // Helper untuk format tanggal
  String _formatSimpleDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('d MMM y', 'id_ID').format(date);
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (_isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: Color(0xFFE57373)));
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline,
                  size: screenWidth * 0.15, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'Gagal memuat data: \n$_errorMessage',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: screenWidth * 0.04, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    if (_purchasedTickets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.airplane_ticket_outlined,
                size: screenWidth * 0.2, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Anda belum memiliki tiket',
              style: TextStyle(
                  fontSize: screenWidth * 0.045, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding:
          EdgeInsets.fromLTRB(screenWidth * 0.05, 20, screenWidth * 0.05, 80),
      itemCount: _purchasedTickets.length,
      itemBuilder: (context, index) {
        final ticket = _purchasedTickets[index];
        return _buildTicketCard(ticket, screenWidth);
      },
    );
  }

  Widget _buildTicketCard(PurchasedTicket ticket, double screenWidth) {
    return InkWell(
      onTap: () async{
       // 2. 'await' hasilnya
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TicketDetailPage(ticket: ticket),
          ),
        );

        // 3. Cek apakah ada sinyal 'refresh'
        if (result == 'refresh' && mounted) {
          // 4. Jika ya, panggil ulang API
          _fetchHistoryData();
        }
      },
      child: Card(
        elevation: 2,
        margin: EdgeInsets.only(bottom: screenWidth * 0.04),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(screenWidth * 0.04),
        ),
        color: const Color(0xFFE57373),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 3,
                child: Padding(
                  padding: EdgeInsets.all(screenWidth * 0.04),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        ticket.category,
                        style: TextStyle(
                            color: Colors.white70,
                            fontSize: screenWidth * 0.03),
                      ),
                      Text(
                        ticket.locationName,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenWidth * 0.04,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: screenWidth * 0.03),
                      Row(
                        children: [
                          _buildTicketInfo(
                              'Tanggal', ticket.visitDate, screenWidth),
                          SizedBox(width: screenWidth * 0.05),
                          _buildTicketInfo('Jumlah',
                              ticket.quantity.toString(), screenWidth),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Image.asset(
                  ticket.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.image_not_supported,
                          color: Colors.white),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTicketInfo(String label, String value, double screenWidth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style:
              TextStyle(color: Colors.white70, fontSize: screenWidth * 0.028),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
              color: Colors.white,
              fontSize: screenWidth * 0.035,
              fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}