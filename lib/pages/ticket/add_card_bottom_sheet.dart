import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AddCardBottomSheet extends StatefulWidget {
  const AddCardBottomSheet({super.key});

  @override
  State<AddCardBottomSheet> createState() => _AddCardBottomSheetState();
}

class _AddCardBottomSheetState extends State<AddCardBottomSheet> {
  // Constants for styling to match the image
  static const _backgroundColor = Color(0xFFFAFBFB);
  static const _primaryTextColor = Color(0xFFF44336);
  static const _secondaryTextColor = Color(0xFFE57373);
  static const _buttonColor = Color(0xFFF44336);
  static const _borderColor = Color(0xFFE57373);
  static const _labelColor = Color(0xFFF44336);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: const BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Section
          _buildHeader(),
          const SizedBox(height: 24),

          // Title and Subtitle
          const Text(
            'Tambahkan Kartu Debit',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _primaryTextColor,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Saat ini kamu dapat menghubungkan kartu debit',
            style: TextStyle(
              fontSize: 14,
              color: _secondaryTextColor,
            ),
          ),
          const SizedBox(height: 24),

          // Form Fields
          _buildTextField(
            label: 'Nomor kartu',
            hint: '0000-0000-0000-0000',
            keyboardType: TextInputType.number,
            // Format input kartu kredit
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(16),
              _CardNumberInputFormatter(),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  label: 'Masa berlaku',
                  hint: 'MM / YY',
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                    _CardDateInputFormatter(),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  label: 'CVV',
                  hint: '*',
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(3),
                  ],
                  isObscure: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Submit Button
          _buildSubmitButton(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // Header with close button and title
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: const Icon(Icons.close, color: _primaryTextColor),
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(width: 12),
            const Text(
              'Metode Pembayaran Saya',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _primaryTextColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // A reusable widget for text fields
  Widget _buildTextField({
    required String label,
    required String hint,
    required TextInputType keyboardType,
    List<TextInputFormatter>? inputFormatters,
    bool isObscure = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: _labelColor,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          obscureText: isObscure,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400),
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: const BorderSide(color: _borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: const BorderSide(color: _borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: const BorderSide(color: _buttonColor, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  // Submit button
  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: () {
        // TODO: Add logic to save the card
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kartu berhasil ditambahkan!')),
        );
        Navigator.pop(context); // Close the bottom sheet
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: _buttonColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        elevation: 2,
      ),
      child: const Text(
        'Tambah Kartu Baru',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// Custom formatter for card number (xxxx-xxxx-xxxx-xxxx)
class _CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text;
    if (newValue.selection.baseOffset == 0) return newValue;

    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 4 == 0 && nonZeroIndex != text.length) {
        buffer.write('-');
      }
    }

    var string = buffer.toString();
    return newValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}

// Custom formatter for card expiry date (MM/YY)
class _CardDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text;
    if (newValue.selection.baseOffset == 0) return newValue;

    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 2 == 0 && nonZeroIndex != text.length) {
        buffer.write(' / ');
      }
    }

    var string = buffer.toString();
    return newValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}
