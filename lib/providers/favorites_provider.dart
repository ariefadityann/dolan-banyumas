// lib/providers/favorites_provider.dart

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // Diperlukan untuk jsonEncode dan jsonDecode
import '../models/wisata_model.dart';

class FavoritesProvider with ChangeNotifier {
  List<TempatWisata> _favoriteWisata = [];

  // Constructor ini akan langsung dipanggil saat provider dibuat.
  // Kita akan memuat data favorit di sini.
  FavoritesProvider() {
    loadFavorites();
  }

  List<TempatWisata> get favorites => _favoriteWisata;

  void toggleFavorite(TempatWisata wisata) {
    if (isFavorite(wisata)) {
      _favoriteWisata.removeWhere((item) => item.id == wisata.id);
    } else {
      _favoriteWisata.add(wisata);
    }
    // Setelah mengubah list, simpan ke penyimpanan lokal
    _saveFavorites();
    notifyListeners();
  }

  bool isFavorite(TempatWisata wisata) {
    return _favoriteWisata.any((item) => item.id == wisata.id);
  }

  // --- METHOD BARU UNTUK MENYIMPAN DATA ---
  Future<void> _saveFavorites() async {
    // 1. Dapatkan instance SharedPreferences
    final prefs = await SharedPreferences.getInstance();

    // 2. Ubah List<TempatWisata> menjadi List<Map<String, dynamic>>
    //    menggunakan method toJson() yang sudah Anda buat.
    final List<Map<String, dynamic>> favoritesJson =
        _favoriteWisata.map((wisata) => wisata.toJson()).toList();

    // 3. Encode List tersebut menjadi sebuah String JSON.
    //    SharedPreferences hanya bisa menyimpan tipe data primitif seperti String, int, bool.
    final String jsonString = jsonEncode(favoritesJson);

    // 4. Simpan String JSON ke SharedPreferences dengan sebuah key.
    await prefs.setString('favorite_wisata_list', jsonString);
  }

  // --- METHOD BARU UNTUK MEMUAT DATA ---
  Future<void> loadFavorites() async {
    // 1. Dapatkan instance SharedPreferences
    final prefs = await SharedPreferences.getInstance();

    // 2. Ambil String JSON dari SharedPreferences menggunakan key yang sama.
    final String? jsonString = prefs.getString('favorite_wisata_list');

    // 3. Jika datanya ada (tidak null)
    if (jsonString != null) {
      // 4. Decode String JSON kembali menjadi List<dynamic> (karena isinya map)
      final List<dynamic> favoritesJson = jsonDecode(jsonString);

      // 5. Ubah setiap item di list dari Map menjadi object TempatWisata
      //    menggunakan factory fromJson() yang sudah Anda buat.
      _favoriteWisata = favoritesJson
          .map((json) => TempatWisata.fromJson(json))
          .toList();

      // 6. Beri tahu listener (UI) bahwa data sudah dimuat dan siap ditampilkan.
      notifyListeners();
    }
  }
}