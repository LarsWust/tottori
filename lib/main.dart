import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:tottori/firebase_options.dart';
import 'package:tottori/pages/SplashScreen.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);
final ValueNotifier<bool> hidePassword = ValueNotifier(true);
bool loggedIn = true;
Color logoColor = const Color(0xfffaa700);
User? user = FirebaseAuth.instance.currentUser!;
final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state != AppLifecycleState.resumed) {
      //setState(() {
      hidePassword.value = true;
      //});
    }
    return;
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: themeNotifier,
        builder: (_, mode, __) {
          return MaterialApp(
            title: 'Tottori',
            themeMode: mode,
            darkTheme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xfffaa700),
                secondary: Colors.deepPurple,
                brightness: Brightness.dark,
                background: const Color.fromARGB(255, 32, 32, 48),
                surface: const Color.fromARGB(255, 56, 56, 83),
                surfaceTint: const Color.fromARGB(255, 49, 49, 72),
                surfaceVariant: const Color.fromARGB(255, 78, 78, 118),
                outline: const Color.fromARGB(255, 125, 125, 177),
                onBackground: const Color.fromARGB(255, 185, 185, 231),
                error: const Color.fromARGB(255, 185, 60, 60),
              ),
              //scaffoldBackgroundColor: const Color.fromARGB(255, 32, 32, 48),
              primaryColorLight: const Color.fromARGB(255, 64, 64, 96),
              primaryColorDark: const Color.fromARGB(255, 18, 18, 26),
              cardColor: const Color.fromARGB(255, 53, 53, 79),
              textTheme: TextTheme(
                labelLarge: TextStyle(fontSize: 16, color: Colors.grey[400]),
                labelMedium: TextStyle(fontSize: 14, color: Colors.grey[400]),
                labelSmall: TextStyle(fontSize: 12, color: Colors.grey[400]),
                headlineLarge: TextStyle(fontSize: 32, color: Colors.grey[200], fontWeight: FontWeight.bold),
                headlineMedium: TextStyle(fontSize: 28, color: Colors.grey[200], fontWeight: FontWeight.bold),
                headlineSmall: TextStyle(fontSize: 24, color: Colors.grey[200], fontWeight: FontWeight.bold),
                bodyLarge: TextStyle(fontSize: 18, color: Colors.grey[200]),
                bodyMedium: TextStyle(fontSize: 16, color: Colors.grey[200]),
                bodySmall: TextStyle(fontSize: 14, color: Colors.grey[200]),
              ),
            ),
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xfffaa700),
                secondary: Colors.deepPurple,
                brightness: Brightness.light,
                background: const Color.fromARGB(255, 221, 221, 221),
                surface: const Color.fromARGB(255, 201, 201, 201),
                surfaceTint: const Color.fromARGB(255, 233, 233, 233),
                surfaceVariant: const Color.fromARGB(255, 175, 175, 175),
                outline: const Color.fromARGB(255, 142, 142, 142),
                error: const Color.fromARGB(255, 215, 69, 69),
              ),
              //scaffoldBackgroundColor: Colors.grey[400],
              primaryColorLight: const Color.fromARGB(255, 175, 175, 175),
              primaryColorDark: const Color.fromARGB(255, 20, 20, 20),
              cardColor: const Color.fromARGB(255, 205, 205, 205),
              textTheme: TextTheme(
                labelLarge: TextStyle(fontSize: 16, color: Colors.grey[600]),
                labelMedium: TextStyle(fontSize: 14, color: Colors.grey[600]),
                labelSmall: TextStyle(fontSize: 12, color: Colors.grey[600]),
                headlineLarge: TextStyle(fontSize: 32, color: Colors.grey[800], fontWeight: FontWeight.bold),
                headlineMedium: TextStyle(fontSize: 28, color: Colors.grey[800], fontWeight: FontWeight.bold),
                headlineSmall: TextStyle(fontSize: 24, color: Colors.grey[800], fontWeight: FontWeight.bold),
                bodyLarge: TextStyle(fontSize: 18, color: Colors.grey[800]),
                bodyMedium: TextStyle(fontSize: 16, color: Colors.grey[800]),
                bodySmall: TextStyle(fontSize: 14, color: Colors.grey[800]),
              ),
            ),
            home: const SplashScreen(title: 'Flutter Demo Home Page'),
          );
        });
  }
}
