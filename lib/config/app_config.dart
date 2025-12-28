import 'package:flutter/foundation.dart';
import 'dart:io';

class AppConfig {
  static String baseUrl() {
    // 🌐 Production API URL - digunakan untuk semua platform
    return 'https://desa-sebet-kediri.site';
  }

  // 🖼️ BASE URL untuk gambar (image assets)
  static String imageBaseUrl() {
    // 🌐 Production Image URL - digunakan untuk semua platform
    return 'https://desa-sebet-kediri.site';
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
