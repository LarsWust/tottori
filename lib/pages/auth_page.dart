import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tottori/main.dart';
import 'package:tottori/pages/home_page.dart';
import 'package:tottori/pages/profile_setup.dart';
import 'package:tottori/pages/sign_up_or_in.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            user = snapshot.data!;

            print("grahhh $loggedIn");
            if (loggedIn == false) {
              return const AuthToggle();
            } else {
              if (user.displayName != null) {
                return const HomePage();
              } else {
                return const ProfileSetupPage();
              }
            }
          } else {
            return const AuthToggle();
          }
        },
      ),
    );
  }
}
