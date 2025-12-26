
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/wisata_model.dart';
import '../config/app_config.dart'; // Import AppConfig

class WisataService {
  /// Fetch semua data wisata dari API
  Future<List<TempatWisata>> fetchWisataData() async {
    try {
      final url = Uri.parse('${AppConfig.baseUrl()}/api/dolanbanyumas/wisata-all');
      
      print('🔵 Fetching wisata data from: $url');
      
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      print('📡 Response Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        
        // Handle different response formats
        List<dynamic> jsonResponse;
        
        // Check if response has 'data' wrapper
        if (responseData is Map && responseData.containsKey('data')) {
          jsonResponse = responseData['data'] as List;
        } else if (responseData is List) {
          jsonResponse = responseData;
        } else {
          throw Exception('Unexpected response format');
        }
        
        print('✅ Loaded ${jsonResponse.length} wisata items');
        print('📋 First item: ${jsonResponse.isNotEmpty ? jsonResponse[0] : "empty"}');
        print('📋 Last item: ${jsonResponse.isNotEmpty ? jsonResponse[jsonResponse.length - 1] : "empty"}');
        
        return jsonResponse.map((data) => TempatWisata.fromJson(data)).toList();
      } else {
        print('❌ Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to load wisata data: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching wisata data: $e');
      throw Exception('Error fetching wisata data: $e');
    }
  }
  
  /// Fetch wisata by ID (optional, jika backend support)
  Future<TempatWisata?> fetchWisataById(String id) async {
    try {
      final url = Uri.parse('${AppConfig.baseUrl()}/api/dolanbanyumas/wisata/$id');
      
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        
        // Handle response with 'data' wrapper
        final data = responseData is Map && responseData.containsKey('data')
            ? responseData['data']
            : responseData;
        
        return TempatWisata.fromJson(data);
      } else {
        print('❌ Error fetching wisata by ID: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Error: $e');
      return null;
    }
  }
  
  /// Fetch wisata by kategori (optional)
  Future<List<TempatWisata>> fetchWisataByKategori(String kategori) async {
    try {
      final url = Uri.parse('${AppConfig.baseUrl()}/api/dolanbanyumas/wisata/kategori/$kategori');
      
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        
        List<dynamic> jsonResponse;
        if (responseData is Map && responseData.containsKey('data')) {
          jsonResponse = responseData['data'] as List;
        } else if (responseData is List) {
          jsonResponse = responseData;
        } else {
          throw Exception('Unexpected response format');
        }
        
        return jsonResponse.map((data) => TempatWisata.fromJson(data)).toList();
      } else {
        throw Exception('Failed to load wisata by kategori');
      }
    } catch (e) {
      print('❌ Error: $e');
      throw Exception('Error fetching wisata by kategori: $e');
    }
  }
}