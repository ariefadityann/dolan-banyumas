// lib/pages/my_tickets_list_page.dart

import 'package:flutter/material.dart';
import '../../models/purchased_ticket_model.dart';
import 'ticket_detail_page.dart';

class MyTicketsListPage extends StatefulWidget {
  const MyTicketsListPage({super.key});

  @override
  State<MyTicketsListPage> createState() => _MyTicketsListPageState();
}

class _MyTicketsListPageState extends State<MyTicketsListPage> {
  final List<PurchasedTicket> _purchasedTickets = [
    PurchasedTicket(
      locationName: 'Hutan Pinus Limpakuwus',
      category: 'Nama Wisata',
      visitDate: '20 Apr 2025',
      quantity: 2,
      imageUrl: 'assets/img/alunalun.jpg',
      userName: 'Muhammad Arief Adityan',
      orderDate: '2025-04-15',
      orderTime: '15:44:45 WIB',
      ticketId: '0405014091',
      totalPrice: 10000,
    ),
    PurchasedTicket(
      locationName: 'The Village',
      category: 'Nama Wisata',
      visitDate: '25 Mei 2025',
      quantity: 3,
      imageUrl: 'assets/img/alunalun.jpg',
      userName: 'Muhammad Arief Adityan',
      orderDate: '2025-05-20',
      orderTime: '10:30:00 WIB',
      ticketId: '0520103000',
      totalPrice: 75000,
    ),
    PurchasedTicket(
      locationName: 'Thr Pangsar Soedirman',
      category: 'Parkir Roda 2 (dua)',
      visitDate: '25 Mei 2025',
      quantity: 1,
      imageUrl: 'assets/img/alunalun.jpg',
      userName: 'Muhammad Arief Adityan',
      orderDate: '2025-05-20',
      orderTime: '10:31:00 WIB',
      ticketId: 'PARK05201031',
      totalPrice: 3000,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // RESPONSIVE: Get screen width for proportional sizing
    final screenWidth = MediaQuery.of(context).size.width;

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
      // RESPONSIVE: Use proportional horizontal padding
      padding:
          EdgeInsets.fromLTRB(screenWidth * 0.05, 20, screenWidth * 0.05, 80),
      itemCount: _purchasedTickets.length,
      itemBuilder: (context, index) {
        final ticket = _purchasedTickets[index];
        // RESPONSIVE: Pass screenWidth to the card builder
        return _buildTicketCard(ticket, screenWidth);
      },
    );
  }

  Widget _buildTicketCard(PurchasedTicket ticket, double screenWidth) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TicketDetailPage(ticket: ticket),
          ),
        );
      },
      child: Card(
        elevation: 2,
        // RESPONSIVE: Proportional margin
        margin: EdgeInsets.only(bottom: screenWidth * 0.04),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          // RESPONSIVE: Proportional border radius
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
                  // RESPONSIVE: Proportional padding
                  padding: EdgeInsets.all(screenWidth * 0.04),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        ticket.category,
                        // RESPONSIVE: Proportional font size
                        style: TextStyle(
                            color: Colors.white70,
                            fontSize: screenWidth * 0.03),
                      ),
                      Text(
                        ticket.locationName,
                        style: TextStyle(
                          color: Colors.white,
                          // RESPONSIVE: Proportional font size
                          fontSize: screenWidth * 0.04,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      // RESPONSIVE: Proportional spacing
                      SizedBox(height: screenWidth * 0.03),
                      Row(
                        children: [
                          // RESPONSIVE: Pass screenWidth to info builder
                          _buildTicketInfo(
                              'Tanggal', ticket.visitDate, screenWidth),
                          // RESPONSIVE: Proportional spacing
                          SizedBox(width: screenWidth * 0.05),
                          _buildTicketInfo('Jumlah Tiket',
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
          // RESPONSIVE: Proportional font size
          style:
              TextStyle(color: Colors.white70, fontSize: screenWidth * 0.028),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          // RESPONSIVE: Proportional font size
          style: TextStyle(
              color: Colors.white,
              fontSize: screenWidth * 0.035,
              fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
