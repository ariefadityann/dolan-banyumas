// File: models/wisata_model.dart

class TempatWisata {
  // Sesuaikan semua properti ini dengan data JSON Anda
  final String nama;
  final String kategori;
  final String deskripsi;
  final String caption;
  String jarak;
  final String harga;
  final double rating;
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
    required this.rating,
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
    return TempatWisata(
      nama: json['nama'] ?? '',
      kategori: json['kategori'] ?? '',
      deskripsi: json['deskripsi'] ?? '',
      caption: json['caption'] ?? '',
      jarak: json['jarak'] ?? '',
      harga: json['harga'] ?? '0',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      gambarUrl: json['gambarUrl'] ?? '',
      images: json['images'] != null ? List<String>.from(json['images']) : [],
      alamat: json['alamat'] ?? '',
      telepon: json['telepon'] ?? '',
      jamBuka: json['jamBuka'] ?? '',
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
      'rating': rating,
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