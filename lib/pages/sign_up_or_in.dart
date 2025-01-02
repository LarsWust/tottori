import 'package:flutter/src/widgets/framework.dart';
import 'package:tottori/pages/LoginPage.dart';
import 'package:tottori/pages/register.dart';

class AuthToggle extends StatefulWidget {
  const AuthToggle({super.key});

  @override
  State<AuthToggle> createState() => _AuthToggleState();
}

class _AuthToggleState extends State<AuthToggle> {
  bool showSignInPage = true;

  void toggleSignPage() {
    setState(() {
      showSignInPage = !showSignInPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showSignInPage) {
      return LoginPage(onTap: toggleSignPage);
    } else {
      return RegisterPage(onTap: toggleSignPage);
    }
  }
}
