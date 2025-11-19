import 'dart:convert'; // Untuk jsonDecode
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Import http

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false; // Untuk indikator loading

  // 1. DEFINISI CONTROLLER
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _waController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    // Bersihkan controller ketika halaman ditutup
    _usernameController.dispose();
    _nameController.dispose();
    _waController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // 2. FUNGSI UNTUK HIT API
  Future<void> _registerUser() async {
    // Validasi dasar
    if (_usernameController.text.isEmpty ||
        _nameController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon lengkapi semua data')),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password konfirmasi tidak sama')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    const String url = 'http://10.0.2.2:8000/api/dolanbanyumas/register';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': _usernameController.text,
          'nama_lengkap': _nameController.text,
          'no_wa': _waController.text,
          'password': _passwordController.text,
          'password_confirmation': _confirmPasswordController.text,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // BERHASIL
        final data = jsonDecode(response.body);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Registrasi Berhasil: ${data['message'] ?? 'Silahkan login'}')),
          );
          Navigator.pop(context); // Kembali ke halaman login
        }
      } else {
        // GAGAL (Validasi server dll)
        final errorData = jsonDecode(response.body);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal: ${errorData['message'] ?? 'Terjadi kesalahan'}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error koneksi: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/img/background.jpg'),
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),
          ),

          // Registration Form Sheet
          Align(
            alignment: Alignment.bottomCenter,
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.fromLTRB(32.0, 32.0, 32.0, 40.0),
                decoration: const BoxDecoration(
                  color: Color(0xFFFAF6F1),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    topRight: Radius.circular(30.0),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Daftar Aplikasi',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildSectionDivider('Data'),
                    const SizedBox(height: 16),
                    // 3. PASANG CONTROLLER KE TEXTFIELD
                    _buildTextField(
                      label: 'Username', 
                      hint: 'Username', 
                      controller: _usernameController
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      label: 'Nama Lengkap', 
                      hint: 'Nama Lengkap Anda', 
                      controller: _nameController
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      label: 'No WA',
                      hint: 'Contoh: 081234567890',
                      isNumeric: true,
                      controller: _waController
                    ),
                    const SizedBox(height: 16),
                    _buildSectionDivider('Password'),
                    const SizedBox(height: 16),
                    _buildPasswordTextField(
                      label: 'Password',
                      isPasswordVisible: _isPasswordVisible,
                      controller: _passwordController,
                      onToggleVisibility: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildPasswordTextField(
                      label: 'Ulangi Password',
                      isPasswordVisible: _isConfirmPasswordVisible,
                      controller: _confirmPasswordController,
                      onToggleVisibility: () {
                        setState(() {
                          _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : () {
                           // PANGGIL FUNGSI REGISTER
                           _registerUser();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF44336),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading 
                          ? const SizedBox(
                              height: 20, width: 20, 
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                            )
                          : const Text(
                              'Daftar',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: RichText(
                        text: const TextSpan(
                          text: 'Sudah punya akun? ',
                          style: TextStyle(
                              color: Colors.black54,
                              fontSize: 14,
                              fontFamily: 'Poppins'),
                          children: <TextSpan>[
                            TextSpan(
                              text: 'Masuk disini',
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionDivider(String title) {
    return Row(
      children: [
        const Expanded(child: Divider(thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            '--$title--',
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ),
        const Expanded(child: Divider(thickness: 1)),
      ],
    );
  }

  // MODIFIKASI: Tambahkan parameter controller
  Widget _buildTextField({
    required String label, 
    required String hint, 
    required TextEditingController controller, // Tambahan
    bool isNumeric = false
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller, // Pasang disini
          keyboardType: isNumeric ? TextInputType.phone : TextInputType.text,
          style: const TextStyle(color: Colors.black87),
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  // MODIFIKASI: Tambahkan parameter controller
  Widget _buildPasswordTextField({
    required String label,
    required bool isPasswordVisible,
    required TextEditingController controller, // Tambahan
    required VoidCallback onToggleVisibility,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller, // Pasang disini
          obscureText: !isPasswordVisible,
          style: const TextStyle(color: Colors.black87),
          decoration: InputDecoration(
            hintText: 'Password',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            suffixIcon: IconButton(
              icon: Icon(
                isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                color: Colors.grey,
              ),
              onPressed: onToggleVisibility,
            ),
          ),
        ),
      ],
    );
  }
}