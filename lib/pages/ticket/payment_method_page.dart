import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'add_payment_method_page.dart';
import 'qris_payment_page.dart'; // <-- GANTI 'your_project_name'

class PaymentMethodPage extends StatelessWidget {
  final double totalHarga;

  const PaymentMethodPage({
    super.key,
    required this.totalHarga,
  });

  // Constants for styling
  static const _pageBackgroundColor = Color(0xFFF8FDF9);
  static const _cardBackgroundColor = Colors.white;
  static const _primaryTextColor = Color(0xFF2E7D32);
  static const _secondaryTextColor = Color(0xFF666666);
  static const _accentColor = Color(0xFF4CAF50);
  static const _shadowColor = Color(0x1A000000);

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: _pageBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Pilih Metode Pembayaran',
          style: TextStyle(
            color: _primaryTextColor,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: _primaryTextColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Header with order summary

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // My Payment Methods Section
                  _buildSectionHeader(
                    'Metode Pembayaran Saya',
                    Icons.payment_rounded,
                  ),
                  _buildPaymentOption(
                    icon: Icons.add_circle_outline_rounded,
                    label: 'Tambah Kartu Pembayaran',
                    subtitle: 'Tambah kartu kredit/debit baru',
                    onTap: () {
                      // Navigasi ke halaman baru
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddPaymentMethodPage(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  _buildSectionHeader(
                    'Pembayaran Cepat',
                    Icons.bolt_rounded,
                  ),
                  _buildPaymentOption(
                    icon: Icons.qr_code_2_rounded,
                    label: 'QRIS',
                    subtitle: 'Scan QR code untuk pembayaran',
                    // 2. Ganti logika onTap di sini
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QrisPaymentPage(
                            totalHarga:
                                totalHarga, // Kirim total harga ke halaman QRIS
                          ),
                        ),
                      );
                    },
                    isPopular: true,
                  ),
                  const SizedBox(height: 16),

                  // E-Wallet Section
                  _buildSectionHeader(
                    'E-Wallet',
                    Icons.account_balance_wallet_rounded,
                  ),
                  _buildEWalletOptions(context),
                  const SizedBox(height: 16),

                  // Bank Transfer Section
                  _buildSectionHeader(
                    'Transfer Bank',
                    Icons.account_balance_rounded,
                  ),
                  _buildBankOptions(context),
                ],
              ),
            ),
          ),

          // Total Price Footer
          _buildTotalPriceFooter(currencyFormatter.format(totalHarga)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, color: _primaryTextColor, size: 18),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              color: _primaryTextColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEWalletOptions(BuildContext context) {
    return Column(
      children: [
        _buildPaymentOption(
          icon: Icons.wallet_rounded,
          label: 'OVO',
          iconColor: const Color(0xFF4C2A86),
          onTap: () => _onPaymentSelected(context, 'OVO'),
        ),
        const SizedBox(height: 12),
        _buildPaymentOption(
          icon: Icons.wallet_rounded,
          label: 'Gopay',
          iconColor: const Color(0xFF00AA13),
          onTap: () => _onPaymentSelected(context, 'Gopay'),
        ),
        const SizedBox(height: 12),
        _buildPaymentOption(
          icon: Icons.wallet_rounded,
          label: 'Dana',
          iconColor: const Color(0xFF0FAFE7),
          onTap: () => _onPaymentSelected(context, 'Dana'),
        ),
        const SizedBox(height: 12),
        _buildPaymentOption(
          icon: Icons.wallet_rounded,
          label: 'LinkAja',
          iconColor: const Color(0xFFE61E5F),
          onTap: () => _onPaymentSelected(context, 'LinkAja'),
        ),
      ],
    );
  }

  Widget _buildBankOptions(BuildContext context) {
    return Column(
      children: [
        _buildPaymentOption(
          icon: Icons.account_balance_rounded,
          label: 'BANK BNI',
          subtitle: 'Virtual Account',
          iconColor: const Color(0xFF0066A0),
          onTap: () => _onPaymentSelected(context, 'BANK BNI'),
        ),
        const SizedBox(height: 12),
        _buildPaymentOption(
          icon: Icons.account_balance_rounded,
          label: 'BANK MANDIRI',
          subtitle: 'Virtual Account',
          iconColor: const Color(0xFF0033A0),
          onTap: () => _onPaymentSelected(context, 'BANK MANDIRI'),
        ),
        const SizedBox(height: 12),
        _buildPaymentOption(
          icon: Icons.account_balance_rounded,
          label: 'BANK BCA',
          subtitle: 'Virtual Account',
          iconColor: const Color(0xFF0066A0),
          onTap: () => _onPaymentSelected(context, 'BANK BCA'),
        ),
        const SizedBox(height: 12),
        _buildPaymentOption(
          icon: Icons.account_balance_rounded,
          label: 'BANK BRI',
          subtitle: 'Virtual Account',
          iconColor: const Color(0xFF0033A0),
          onTap: () => _onPaymentSelected(context, 'BANK BRI'),
        ),
      ],
    );
  }

  Widget _buildPaymentOption({
    required IconData icon,
    required String label,
    String? subtitle,
    required VoidCallback onTap,
    Color iconColor = _primaryTextColor,
    bool isPopular = false,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 1,
      shadowColor: _shadowColor,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade100, width: 1),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        color: _primaryTextColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: _secondaryTextColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (isPopular) ...[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Populer',
                    style: TextStyle(
                      color: _accentColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              const Icon(Icons.arrow_forward_ios_rounded,
                  color: _secondaryTextColor, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTotalPriceFooter(String formattedPrice) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: _shadowColor,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
        border: Border(
          top: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Pembayaran',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: _secondaryTextColor,
                ),
              ),
              Text(
                'Termasuk pajak aplikasi',
                style: TextStyle(
                  fontSize: 11,
                  color: _secondaryTextColor,
                ),
              ),
            ],
          ),
          Text(
            formattedPrice,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: _primaryTextColor,
            ),
          ),
        ],
      ),
    );
  }

  void _onPaymentSelected(BuildContext context, String method) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Metode pembayaran $method dipilih.'),
        backgroundColor: _accentColor,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
    // TODO: Implement further payment logic here
  }
}
