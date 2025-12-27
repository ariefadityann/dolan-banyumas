import 'package:flutter/foundation.dart';
import 'dart:io';

class AppConfig {
  static String baseUrl() {
    // 🌐 FLUTTER WEB
    if (kIsWeb) {
      return 'http://app-dolan-banyumas.test';
    }

    // 🤖 ANDROID
    if (Platform.isAndroid) {
      // Emulator Android
      // Gunakan ini jika pakai emulator
      return 'http://10.0.2.2:8000';

      // HP fisik (jika tidak pakai emulator)
      // return 'http://192.168.100.20';
    }

    // 🍎 iOS Simulator
    if (Platform.isIOS) {
      return 'http://localhost:8000';
    }

    // Fallback
    return 'http://localhost:8000';
  }

  // 🖼️ BASE URL untuk gambar (image assets)
  static String imageBaseUrl() {
    // 🌐 FLUTTER WEB
    if (kIsWeb) {
      return 'http://192.168.18.171/dashboard/public/images';
    }

    // 🤖 ANDROID (Emulator & Physical Device)
    if (Platform.isAndroid) {
      // Gunakan IP lokal untuk akses gambar
      return 'http://192.168.18.171/dashboard/public/images';
    }

    // 🍎 iOS Simulator
    if (Platform.isIOS) {
      return 'http://192.168.18.171/dashboard/public/images';
    }

    // Fallback
    return 'http://192.168.18.171/dashboard/public/images';
  }

  static String getImageUrl(String? relativePath) {
    if (relativePath == null || relativePath.isEmpty) return '';

    if (relativePath.startsWith('http://') || relativePath.startsWith('https://')) {
      return relativePath;
    }

    final cleanPath =
        relativePath.startsWith('/') ? relativePath.substring(1) : relativePath;

    // Gunakan imageBaseUrl() untuk gambar, bukan baseUrl()
    final fullUrl = '${imageBaseUrl()}/$cleanPath';
    print('🖼️ IMAGE URL = $fullUrl');
    return fullUrl;
  }
}
