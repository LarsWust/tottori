import 'dart:async';
import 'package:align_positioned/align_positioned.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:tottori/CustomPageRoute.dart';
import 'package:tottori/pages/auth_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.title});
  final String title;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    var homeScreen = const AuthPage();
    Timer(const Duration(milliseconds: 5500), () => Navigator.pushReplacement(context, CustomPageRoute(homeScreen, context)));
    Timer(const Duration(milliseconds: 4050), () => HapticFeedback.heavyImpact());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AlignPositioned(
        moveByChildWidth: -((3000 - 2005) / 3000) / 2,
        child: Lottie.asset(
          "lib/assets/tottori_splash_8.json",
          repeat: false,
        ),
      ),
    );
  }
}
