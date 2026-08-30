import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFBD5E3), Color(0xFFE877A0), Color(0xFFF5F5F5)],
          ),
        ),
        alignment: Alignment.topCenter,
        padding: const EdgeInsets.only(top: 40),
        child: const Text('Trang chủ (đang trống)'),
      ),
    );
  }
}
