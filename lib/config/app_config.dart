// lib/config/app_config.dart

import 'package:flutter/foundation.dart';
import 'dart:io';

class AppConfig {
  /// Get base URL based on platform
  static String baseUrl() {
    if (kIsWeb) {
      // Flutter Web (Browser)
      // MUST use localhost (not 127.0.0.1) to match origin
      return 'http://localhost:8000';
    }

    // ANDROID
    if (Platform.isAndroid) {
      // Android Emulator MUST use 10.0.2.2
      // For physical device, use your computer's IP (e.g., 192.168.1.100)
      return 'http://10.0.2.2:8000';
    }

    // iOS Simulator
    if (Platform.isIOS) {
      return 'http://localhost:8000';
    }

    // Default fallback
    return 'http://localhost:8000';
  }

  /// Get full image URL from relative path
  static String getImageUrl(String? relativePath) {
    if (relativePath == null || relativePath.isEmpty) {
      return '';
    }

    // If already full URL, return as is
    if (relativePath.startsWith('http://') || relativePath.startsWith('https://')) {
      return relativePath;
    }

    // Remove leading slash if exists
    final cleanPath = relativePath.startsWith('/') 
        ? relativePath.substring(1) 
        : relativePath;

    final fullUrl = '${baseUrl()}/$cleanPath';
    
    // DEBUG: Print final URL
    print('🧪 FINAL IMAGE URL = $fullUrl');
    
    return fullUrl;
  }

  /// Get full image URLs from list of relative paths
  static List<String> getImageUrls(List<String> relativePaths) {
    return relativePaths.map((path) => getImageUrl(path)).toList();
  }
}
