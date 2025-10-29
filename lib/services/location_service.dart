import 'package:geolocator/geolocator.dart';

class LocationService {
  // Fungsi untuk mendapatkan lokasi pengguna saat ini
  Future<Position> getCurrentLocation() async {
    // 1. Cek apakah layanan lokasi aktif
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Jika tidak aktif, kembalikan error
      return Future.error('Layanan lokasi tidak aktif.');
    }

    // 2. Cek izin lokasi dari pengguna
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Jika pengguna menolak, kembalikan error
        return Future.error('Izin lokasi ditolak.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Jika pengguna menolak permanen, kembalikan error
      return Future.error('Izin lokasi ditolak permanen, silakan aktifkan di pengaturan.');
    }

    // 3. Jika semua sudah oke, dapatkan lokasi saat ini
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  // Fungsi untuk menghitung jarak antara dua titik koordinat
  // Hasilnya dalam kilometer (km)
  double calculateDistance(double startLat, double startLng, double endLat, double endLng) {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng) / 1000;
  }
}