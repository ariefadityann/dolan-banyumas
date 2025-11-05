import 'package:flutter/material.dart';
// 1. Tambahkan import untuk kedua file bottom sheet di sini
import 'add_card_bottom_sheet.dart'; // <-- GANTI 'your_project_name'

class AddPaymentMethodPage extends StatelessWidget {
  const AddPaymentMethodPage({super.key});

  // Constants for styling to match the image
  static const _pageBackgroundColor = Color(0xFFFFE6E5);
  static const _cardBackgroundColor = Color(0xFFFAFDFB);
  static const _primaryTextColor = Color(0xFFF44336);
  static const _secondaryTextColor = Color(0xFFE57373);
  static const _optionCardBorderColor = Color(0xFFF44336);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Metode Pembayaran',
          style: TextStyle(
            color: _primaryTextColor,
            fontWeight: FontWeight.w700, // Bold
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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          // Main content card
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
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
              mainAxisSize: MainAxisSize.min, // Card size fits content
              children: [
                // Image Section
                Image.asset(
                  'assets/img/wallet.png', // Pastikan path ini benar
                  height: 120,
                ),
                const SizedBox(height: 24),

                // Text Section
                const Text(
                  'Metode Pembayaran Belum Tersedia',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _primaryTextColor,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Silahkan tambahkan kartu debit atau E-wallet anda untuk mempermudah proses pembayaran anda',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: _secondaryTextColor,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),

                // Action Buttons
                _buildOptionCard(
                  context: context,
                  icon: Icons.credit_card, // More specific icon
                  title: 'Tambah Kartu Debit / Kredit',
                  subtitle:
                      'Saat ini Anda dapat menghubungkan kartu debit / kredit mandiri',
                  // 2. Ganti isi fungsi onTap di sini
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => Padding(
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom,
                        ),
                        child: const AddCardBottomSheet(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                _buildOptionCard(
                  context: context,
                  icon: Icons
                      .account_balance_wallet_outlined, // More specific icon
                  title: 'Tambah E-Wallet',
                  subtitle: 'Saat ini Anda dapat menghubungkan E-Wallet',
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // A reusable widget for the option cards inside the main card
  Widget _buildOptionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: _cardBackgroundColor, // Same as parent card background
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _optionCardBorderColor.withOpacity(0.7)),
        ),
        child: Row(
          children: [
            Icon(icon, color: _primaryTextColor, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _primaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: _secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                color: _secondaryTextColor, size: 14),
          ],
        ),
      ),
    );
  }
}
