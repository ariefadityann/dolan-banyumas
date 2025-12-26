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
      return 'http://10.0.2.2';

      // HP fisik (jika tidak pakai emulator)
      // return 'http://192.168.100.20';
    }

    // 🍎 iOS Simulator
    if (Platform.isIOS) {
      return 'http://localhost';
    }

    // Fallback
    return 'http://localhost';
  }

  static String getImageUrl(String? relativePath) {
    if (relativePath == null || relativePath.isEmpty) return '';

    if (relativePath.startsWith('http://') || relativePath.startsWith('https://')) {
      return relativePath;
    }

    final cleanPath =
        relativePath.startsWith('/') ? relativePath.substring(1) : relativePath;

    final fullUrl = '${baseUrl()}/$cleanPath';
    print('🧪 FINAL IMAGE URL = $fullUrl');
    return fullUrl;
  }
}
