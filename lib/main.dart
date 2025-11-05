import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // ✅ Tambahan penting

import 'providers/favorites_provider.dart';
import 'content/index.dart'; // ganti path ke HomePage yang baru

void main() {
  initializeDateFormatting('id_ID', null).then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => FavoritesProvider(),
      child: ScreenUtilInit(
        // ✅ Tambahan utama
        designSize:
            const Size(390, 844), // ukuran dasar dari desain (misal iPhone 12)
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Dolan Banyumas',
            theme: ThemeData(
              primarySwatch: Colors.red,
              scaffoldBackgroundColor: const Color(0xFFF5F5F0),
              fontFamily: 'Poppins',
              textTheme: Typography.englishLike2018.apply(
                fontSizeFactor: 1.sp, // ✅ agar teks juga adaptif
              ),
            ),
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('id', 'ID'),
            ],
            home: const HomePage(), // ✅ tetap menuju halaman utama kamu
          );
        },
      ),
    );
  }
}
