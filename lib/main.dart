import 'dart:async';

import 'package:align_positioned/align_positioned.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'CustomPageRoute.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.blue,
      ),
      home: const SplashScreen(title: 'Flutter Demo Home Page'),
    );
  }
}

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
    Timer(const Duration(milliseconds: 5500), () => Navigator.pushReplacement(context, CustomPageRoute(SecondScreen())));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AlignPositioned(
        moveByChildWidth: -((3000 - 2005) / 3000) / 2,
        child: Stack(
          children: [
            //Container(color: Colors.red),
            Lottie.asset(
              "assets/tottori_splash_8.json",
              repeat: false,
            ),
          ],
        ),
      ),
    );
  }
}

class SecondScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Test")),
      body: Center(
          child: Column(
        children: [
          Text(
            "Test",
            textScaleFactor: 2,
          ),
          FilledButton(
            onPressed: () {},
            icon: Icon(Icons.abc),
            label: Text("Test"),
          ),
        ],
      )),
    );
  }
}
