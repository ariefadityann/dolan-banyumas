// File: models/wisata_model.dart

class TempatWisata {
  // Sesuaikan semua properti ini dengan data JSON Anda
  final String nama;
  final String kategori;
  final String deskripsi;
  final String caption;
  String jarak;
  final String harga;
  final String gambarUrl;
  final List<String> images;
  final String alamat;
  final String telepon;
  final String jamBuka;
  final double lat;
  final double lng;

  // Kita gunakan 'nama' sebagai ID unik sementara, karena JSON Anda tidak punya ID
  String get id => nama;

  TempatWisata({
    required this.nama,
    required this.kategori,
    required this.deskripsi,
    required this.caption,
    required this.jarak,
    required this.harga,
    required this.gambarUrl,
    required this.images,
    required this.alamat,
    required this.telepon,
    required this.jamBuka,
    required this.lat,
    required this.lng,
  });

  // METHOD PENTING #1: Untuk mengubah data dari server/JSON menjadi Object
  factory TempatWisata.fromJson(Map<String, dynamic> json) {
    // Helper function to convert relative URL to full URL
    String _getFullImageUrl(String? url) {
      if (url == null || url.isEmpty) return '';
      
      // If already full URL (starts with http/https), return as is
      if (url.startsWith('http://') || url.startsWith('https://')) {
        return url;
      }
      
      // If relative path, add base URL
      const String baseUrl = 'http://127.0.0.1:8000';
      
      // Remove leading slash if exists
      final cleanUrl = url.startsWith('/') ? url.substring(1) : url;
      
      final fullUrl = '$baseUrl/$cleanUrl';
      
      // Debug: Print URL conversion
      print('🖼️ Image URL Conversion:');
      print('   Original: $url');
      print('   Converted: $fullUrl');
      
      return fullUrl;
    }
    
    // Helper for images array
    List<String> _getFullImageUrls(dynamic imagesJson) {
      if (imagesJson == null) return [];
      
      final List<String> imagesList = List<String>.from(imagesJson);
      return imagesList.map((url) => _getFullImageUrl(url)).toList();
    }
    
    return TempatWisata(
      nama: json['nama'] ?? '',
      kategori: json['kategori'] ?? '',
      deskripsi: json['deskripsi'] ?? '',
      caption: json['caption'] ?? '',
      jarak: json['jarak'] ?? '',
      harga: json['harga'] ?? '0',
      // Try both 'gambar_url' (backend) and 'gambarUrl' (fallback)
      gambarUrl: _getFullImageUrl(json['gambar_url'] ?? json['gambarUrl']),
      images: _getFullImageUrls(json['images']),
      alamat: json['alamat'] ?? '',
      telepon: json['telepon'] ?? '',
      jamBuka: json['jamBuka'] ?? json['jam_buka'] ?? '',
      lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (json['lng'] as num?)?.toDouble() ?? 0.0,
    );
  }

  // METHOD PENTING #2: Untuk mengubah Object ini menjadi teks agar bisa disimpan
  Map<String, dynamic> toJson() {
    return {
      'nama': nama,
      'kategori': kategori,
      'deskripsi': deskripsi,
      'caption': caption,
      'jarak': jarak,
      'harga': harga,
      'gambarUrl': gambarUrl,
      'images': images,
      'alamat': alamat,
      'telepon': telepon,
      'jamBuka': jamBuka,
      'lat': lat,
      'lng': lng,
    };
  }
}