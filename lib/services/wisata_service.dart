// lib/services/wisata_service.dart

import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/wisata_model.dart';

class WisataService {
  Future<List<TempatWisata>> fetchWisataData() async {
    final response = await rootBundle.loadString('assets/data/wisata.json');
    final List jsonResponse = json.decode(response);
    await Future.delayed(const Duration(milliseconds: 300));
    return jsonResponse.map((data) => TempatWisata.fromJson(data)).toList();
  }
}