import 'package:flutter/material.dart';
import 'screens.dart';

void main() => runApp(const AksesSehatApp());

class AksesSehatApp extends StatelessWidget {
  const AksesSehatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AksesSehat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: kTeal, primary: kTeal),
        scaffoldBackgroundColor: kBg,
        appBarTheme: const AppBarTheme(
          backgroundColor: kBg,
          foregroundColor: kInk,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        // height 1.35-1.4 supaya tanda nada huruf Thai tidak terpotong.
        textTheme: const TextTheme(
          headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, height: 1.35, color: kInk),
          titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, height: 1.4, color: kInk),
          bodyLarge: TextStyle(fontSize: 18, height: 1.4, color: kInk),
          bodyMedium: TextStyle(fontSize: 16, height: 1.4, color: kInk),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(60),
            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, height: 1.3),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
