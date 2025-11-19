class PurchasedTicket {
  final String locationName;
  final String category;
  final String visitDate;
  final int quantity;
  final String imageUrl;
  final String userName;
  final String orderDate;
  final String orderTime;
  final String ticketId;
  final int totalPrice;
  final String status; // <-- TAMBAHKAN INI
  final String? midtransUrl; // <-- TAMBAHKAN INI

  PurchasedTicket({
    required this.locationName,
    required this.category,
    required this.visitDate,
    required this.quantity,
    required this.imageUrl,
    required this.userName,
    required this.orderDate,
    required this.orderTime,
    required this.ticketId,
    required this.totalPrice,
    required this.status, // <-- TAMBAHKAN INI
    this.midtransUrl, // <-- TAMBAHKAN INI
  });
}