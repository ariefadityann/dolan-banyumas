// lib/models/purchased_ticket_model.dart

class PurchasedTicket {
  final String locationName;
  final String category;
  final String imageUrl;
  final int quantity;
  final String visitDate; // Tanggal di kartu daftar tiket
  
  // Informasi untuk halaman detail
  final String userName;
  final String orderDate;
  final String orderTime;
  final String ticketId;
  final int totalPrice;

  PurchasedTicket({
    required this.locationName,
    required this.category,
    required this.imageUrl,
    required this.quantity,
    required this.visitDate,
    required this.userName,
    required this.orderDate,
    required this.orderTime,
    required this.ticketId,
    required this.totalPrice,
  });
}