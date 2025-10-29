import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../../models/wisata_model.dart';
import '../../services/location_service.dart';

class TransportPage extends StatefulWidget {
  final List<TempatWisata> allWisata;
  final String? username;

  const TransportPage({
    super.key,
    required this.allWisata,
    this.username,
  });

  @override
  State<TransportPage> createState() => _TransportPageState();
}

class _TransportPageState extends State<TransportPage> {
  final LocationService _locationService = LocationService();
  final MapController _mapController = MapController();
  StreamSubscription<Position>? _positionStreamSubscription;

  List<Marker> _wisataMarkers = [];
  Marker? _currentUserMarker;
  LatLng? _initialCenter;

  @override
  void initState() {
    super.initState();
    _initializePage();
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initializePage() async {
    await _fetchInitialLocation();
    _createWisataMarkers();
    _startListeningToLocationUpdates();
  }

  Future<void> _fetchInitialLocation() async {
    try {
      final Position position = await _locationService.getCurrentLocation();
      if (mounted) {
        setState(() {
          _initialCenter = LatLng(position.latitude, position.longitude);
          _currentUserMarker =
              _buildUserMarker(LatLng(position.latitude, position.longitude));
        });
      }
    } catch (e) {
      print("Gagal mendapatkan lokasi awal: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  "Gagal mendapatkan lokasi. Menampilkan lokasi default.")),
        );
        setState(() {
          _initialCenter =
              const LatLng(-7.4313, 109.2478); // Fallback ke Purwokerto
        });
      }
    }
  }

  void _startListeningToLocationUpdates() {
    _positionStreamSubscription =
        Geolocator.getPositionStream().listen((Position position) {
      final newPosition = LatLng(position.latitude, position.longitude);
      if (mounted) {
        setState(() {
          _currentUserMarker = _buildUserMarker(newPosition);
        });
        // Optionally move the map to follow the user
        // _mapController.move(newPosition, _mapController.camera.zoom);
      }
    });
  }

  void _createWisataMarkers() {
    final screenWidth = MediaQuery.of(context).size.width;
    final markers = <Marker>[];
    for (final wisata in widget.allWisata) {
      markers.add(
        Marker(
          point: LatLng(wisata.lat, wisata.lng),
          width: 80,
          height: 80,
          child: Tooltip(
            message: wisata.nama,
            child: Icon(
              Icons.location_pin,
              size: screenWidth * 0.09,
              color: Colors.red,
            ),
          ),
        ),
      );
    }
    if (mounted) {
      setState(() {
        _wisataMarkers = markers;
      });
    }
  }

  Marker _buildUserMarker(LatLng position) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Marker(
      point: position,
      width: 80,
      height: 80,
      child: Icon(
        Icons.my_location,
        size: screenWidth * 0.07,
        color: Colors.blueAccent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final allMarkers = List<Marker>.from(_wisataMarkers);
    if (_currentUserMarker != null) {
      allMarkers.add(_currentUserMarker!);
    }

    return Scaffold(
      body: Stack(
        children: [
          if (_initialCenter == null)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    "Mendapatkan lokasimu...",
                    style: TextStyle(fontSize: screenWidth * 0.04),
                  ),
                ],
              ),
            )
          else
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _initialCenter!,
                initialZoom: 13.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.dolan_banyumas',
                ),
                MarkerLayer(markers: allMarkers),
              ],
            ),
          _buildHeader(screenWidth, screenHeight),
          _buildAccountCard(screenWidth, screenHeight),
        ],
      ),
    );
  }

  Widget _buildHeader(double screenWidth, double screenHeight) {
    return Positioned(
      top: 0.0,
      left: 0.0,
      right: 0.0,
      child: SafeArea(
        child: Container(
          margin:
              EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: 8),
          padding: EdgeInsets.symmetric(
              vertical: 10, horizontal: screenWidth * 0.04),
          decoration: BoxDecoration(
            color: const Color(0xFF425C48), // Mengubah warna menjadi hijau tua
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset('assets/img/logo_DB.png',
                  height: screenHeight * 0.05),
              Image.asset('assets/img/logo.png', height: screenHeight * 0.05),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountCard(double screenWidth, double screenHeight) {
    return Positioned(
      bottom: screenHeight * 0.23,
      // =========================
      left: screenWidth * 0.05,
      right: screenWidth * 0.05,
      child: Container(
        padding: EdgeInsets.all(screenWidth * 0.04),
        decoration: BoxDecoration(
          color: const Color(0xFFE6F0E5).withOpacity(0.95),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Informasi Akun',
                style: TextStyle(
                    color: Colors.black54, fontSize: screenWidth * 0.035)),
            const Divider(color: Colors.black26),
            Text('Selamat datang kembali,',
                style: TextStyle(
                    color: Colors.black87, fontSize: screenWidth * 0.04)),
            const SizedBox(height: 4),
            Text(
              widget.username ?? 'Pengguna',
              style: TextStyle(
                color: Colors.black,
                fontSize: screenWidth * 0.045,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                    child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF425C48),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8))),
                        child: Text(
                          'Booking Tiket',
                          style: TextStyle(fontSize: screenWidth * 0.034),
                        ))),
                const SizedBox(width: 10),
                Expanded(
                    child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF425C48),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8))),
                        child: Text(
                          'Tiket Saya',
                          style: TextStyle(fontSize: screenWidth * 0.035),
                        ))),
              ],
            )
          ],
        ),
      ),
    );
  }
}
