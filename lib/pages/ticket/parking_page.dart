import 'package:flutter/material.dart';
import '../../models/wisata_model.dart';
import '../../widgets/ticket/parking_card.dart';

class ParkingPage extends StatelessWidget {
  const ParkingPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Daftar data parkir manual (hardcoded)
    // Sekarang dilengkapi dengan semua parameter yang wajib diisi
    final List<TempatWisata> manualParkingData = [
      TempatWisata(
        // --- Data yang sudah ada ---
        nama: 'Parkir Roda 2 (dua)',
        deskripsi: 'parkir',
        harga: '1.000',
        gambarUrl: 'assets/img/alunalun.jpg',
        rating: 0,
        // --- TAMBAHAN: Parameter wajib yang harus diisi ---
        kategori: 'Parkir',
        caption: 'Area Parkir Resmi Roda 2',
        jarak: '0.1', // Contoh: 0.1 km
        images: [
          'assets/img/alunalun.jpg',
        ], // Contoh: list of image paths
        alamat: 'Jl. Jenderal Soedirman, Purwokerto',
        telepon: '08123456789',
        jamBuka: '24 Jam',
        lat: -7.4243, // Contoh latitude
        lng: 109.2345, // Contoh longitude
      ),
      TempatWisata(
        // --- Data yang sudah ada ---
        nama: 'Parkir Roda 4 (empat)',
        deskripsi: 'parkir',
        harga: '2.000',
        gambarUrl: 'assets/img/alunalun.jpg',
        rating: 0,
        // --- TAMBAHAN: Parameter wajib yang harus diisi ---
        kategori: 'Parkir',
        caption: 'Area Parkir Resmi Roda 4',
        jarak: '0.1',
        images: ['assets/img/alunalun.jpg'],
        alamat: 'Jl. Jenderal Soedirman, Purwokerto',
        telepon: '08123456789',
        jamBuka: '24 Jam',
        lat: -7.4243,
        lng: 109.2345,
      ),
      TempatWisata(
        // --- Data yang sudah ada ---
        nama: 'Parkir Roda 6 (enam)',
        deskripsi: 'parkir',
        harga: '5.000',
        gambarUrl: 'assets/img/alunalun.jpg',
        rating: 0,
        // --- TAMBAHAN: Parameter wajib yang harus diisi ---
        kategori: 'Parkir',
        caption: 'Area Parkir Resmi Roda 4',
        jarak: '0.1',
        images: ['assets/img/alunalun.jpg'],
        alamat: 'Jl. Jenderal Soedirman, Purwokerto',
        telepon: '08123456789',
        jamBuka: '24 Jam',
        lat: -7.4243,
        lng: 109.2345,
      ),
    ];

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
          20, 24, 20, 100), // <-- Tambahkan padding bawah yang lebih besar
      itemCount: manualParkingData.length,
      itemBuilder: (context, index) {
        final parkir = manualParkingData[index];
        return ParkingCard(parkir: parkir);
      },
    );
  }
}
