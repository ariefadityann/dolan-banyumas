// File: models/wisata_model.dart

class TempatWisata {
  // Sesuaikan semua properti ini dengan data JSON Anda
  final String nama;
  final String kategori;
  final String deskripsi;
  final String caption;
  String jarak;
  final String harga;
  final String gambarUrl;  // ← PATH SAJA (images/alunalun.jpg)
  final List<String> images;  // ← PATH SAJA
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
    // Helper function to parse lat/lng that might come as String or num
    double parseCoordinate(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) {
        return double.tryParse(value) ?? 0.0;
      }
      return 0.0;
    }

    return TempatWisata(
      nama: json['nama'] ?? '',
      kategori: json['kategori'] ?? '',
      deskripsi: json['deskripsi'] ?? '',
      caption: json['caption'] ?? '',
      jarak: json['jarak'] ?? '',
      harga: json['harga'] ?? '0',
      // Simpan PATH saja, BUKAN full URL
      gambarUrl: json['gambar_url'] ?? json['gambarUrl'] ?? '',
      images: json['images'] != null ? List<String>.from(json['images']) : [],
      alamat: json['alamat'] ?? '',
      telepon: json['telepon'] ?? '',
      jamBuka: json['jamBuka'] ?? json['jam_buka'] ?? '',
      lat: parseCoordinate(json['lat']),
      lng: parseCoordinate(json['lng']),
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
