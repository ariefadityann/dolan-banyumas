import 'dart:developer'; // Untuk log
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MidtransWebViewPage extends StatefulWidget {
  final String url;
  const MidtransWebViewPage({super.key, required this.url});

  @override
  State<MidtransWebViewPage> createState() => _MidtransWebViewPageState();
}

class _MidtransWebViewPageState extends State<MidtransWebViewPage> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            log('WebView: Page started loading: $url');
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            log('WebView: Page finished loading: $url');
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            log('WebView: Error: ${error.description}');
            setState(() {
              _isLoading = false;
            });
          },
          onNavigationRequest: (NavigationRequest request) {
            log('WebView: Navigating to ${request.url}');
            
            // Deteksi jika pembayaran selesai (URL finish)
            // Menggabungkan semua kemungkinan URL sukses
            if (request.url.contains('transaction/finish') ||
                request.url.contains('status_code=200') ||
                request.url.contains('example.com') ||
                request.url.contains('finish')) {
                  
              log('WebView: Payment success detected!');
              // Kembali ke aplikasi dengan status sukses
              Navigator.pop(context, 'success');
              return NavigationDecision.prevent;
            }
            // Deteksi jika gagal atau dibatalkan
            else if (request.url.contains('status_code=202') ||
                request.url.contains('gagal')) {
              log('WebView: Payment failed detected!');
              Navigator.pop(context, 'failed');
              return NavigationDecision.prevent;
            }
            // Izinkan navigasi lainnya di dalam webview
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  Future<bool> _onWillPop() async {
    // Tampilkan dialog konfirmasi
    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Batalkan Pembayaran?'),
        content: const Text(
            'Pesanan Anda akan tetap dibuat dalam status "pending". Anda bisa membayarnya nanti.'),
        actions: [
          TextButton(
            child: const Text('Tetap di sini'),
            onPressed: () => Navigator.of(ctx).pop(false), // Jangan keluar
          ),
          TextButton(
            child: const Text('Ya, Batalkan'),
            onPressed: () => Navigator.of(ctx).pop(true), // Ya, keluar
          ),
        ],
      ),
    );
    return shouldPop ?? false;
  }

  @override
  Widget build(BuildContext context) {
    // Gunakan WillPopScope untuk menangani tombol kembali Android
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Pembayaran"),
          backgroundColor: const Color(0xFFF44336),
          foregroundColor: Colors.white,
          // Ganti tombol close dengan leading agar berfungsi dengan WillPopScope
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              if (await _onWillPop()) {
                // ignore: use_build_context_synchronously
                Navigator.of(context).pop();
              }
            },
          ),
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(color: Color(0xFFF44336)),
              ),
          ],
        ),
      ),
    );
  }
}