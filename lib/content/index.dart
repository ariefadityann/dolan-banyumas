import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login.dart'; // Pastikan path ke login.dart benar
// Sesuaikan path ini ke file IndexPage (halaman utama) Anda
import '../pages/home/home_screen.dart'; 

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // 1. Tambahkan state loading
  bool _isCheckingSession = true;

  @override
  void initState() {
    super.initState();
    // 2. Saat halaman ini dibuka, langsung cek status login
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('auth_token');
    final String? userName = prefs.getString('user_name');
    final String? userEmail = prefs.getString('user_email');

    if (!mounted) return;

    if (token != null && userName != null && userEmail != null) {
      // 3. KASUS 1: SUDAH LOGIN
      // Langsung lempar ke halaman utama (IndexPage)
      // Pengguna tidak akan melihat halaman "Ayo Mulai"
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => IndexPage(
            username: userName,
            email: userEmail,
          ),
        ),
      );
    } else {
      // 4. KASUS 2: BELUM LOGIN
      // Berhenti loading dan tampilkan halaman "Ayo Mulai"
      setState(() {
        _isCheckingSession = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 5. Tampilkan loading spinner selagi session diperiksa
    if (_isCheckingSession) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // 6. Jika tidak loading (karena belum login), tampilkan UI "Ayo Mulai"
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Transform.translate(
            offset: const Offset(0, -120),
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/img/background.jpg'),
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                  colorFilter: ColorFilter.mode(
                      Color.fromRGBO(0, 0, 0, 0.3), BlendMode.darken),
                ),
              ),
            ),
          ),
          // Teks tengah
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Spacer(flex: 1),
                Container(
                  margin: const EdgeInsets.only(left: 27),
                  child: const Text(
                    'Jelajahi Banyumas Bersama.',
                    style: TextStyle(
                      fontFamily: 'SFProText',
                      fontSize: 60,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                      color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  width: 345,
                  height: 65,
                  child: const Text(
                    'Kami Dolan Banyumas siap membantu Anda untuk berlibur keliling Banyumas.',
                    style: TextStyle(
                      fontFamily: 'SFProText',
                      fontSize: 16,
                      height: 1.5,
                      color: Colors.white,
                    ),
                  ),
                ),
                const Spacer(flex: 3),
              ],
            ),
          ),

          // Bagian bawah (tombol dan teks)
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              height: 150,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 250,
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigasi ke halaman login
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginPage(), // Pergi ke Login
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 15),
                        backgroundColor: Colors.red.shade500,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Ayo Mulai',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                          SizedBox(width: 10),
                          Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      // Pastikan Anda memiliki rute '/register' di main.dart
                      // atau ganti dengan MaterialPageRoute
                      Navigator.pushNamed(context, '/register');
                    },
                    child: RichText(
                      text: TextSpan(
                        text: 'Belum punya akun? ',
                        style: TextStyle(
                            color: Colors.black, fontFamily: 'Poppins'),
                        children: [
                          TextSpan(
                            text: 'daftar disini',
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
        ],
      ),
    );
  }
}