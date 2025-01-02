import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tottori/helpers/account_helpers.dart';
import 'package:tottori/pages/profile_setup.dart';
import 'package:tottori/services/auth_service.dart';

import '../main.dart';

class LoginPage extends StatefulWidget {
  final Function()? onTap;
  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  int animDurationMillis = 5000;
  FocusNode emailFocus = FocusNode();
  FocusNode passwordFocus = FocusNode();
  String errorText = "";
  bool emailError = false;
  bool passwordError = false;
  double fill = 0;
  double _splashSize = 0;
  bool loginEnabled = true;

  final emailController = TextEditingController(text: "test@gmail.com");
  final passwordController = TextEditingController(text: "test123");

  void signInAnimation() {}

  void signIn() async {
    loggedIn = false;
    print("set loggedIn to $loggedIn");
    setState(() {
      loginEnabled = false;
      fill = 0;
      _splashSize = 0;
    });
    if (emailController.text.isEmpty && passwordController.text.isEmpty) {
      emailError = true;
      passwordError = true;
      errorText = "Please enter credentials";
    } else {
      if (emailController.text.isEmpty) {
        setState(() {
          emailError = true;
          passwordError = false;
          errorText = "Please enter email";
        });
      } else if (passwordController.text.isEmpty) {
        setState(() {
          emailError = false;
          passwordError = true;
          errorText = "Please enter passsword";
        });
      } else {
        try {
          setState(() {
            passwordError = false;
            emailError = false;
            errorText = "";
          });
          await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: emailController.text,
            password: passwordController.text,
          );
          fixAccount();
          setState(() {
            fill = 1;
          });
          var rng = Random();
          for (int i = 0; i < animDurationMillis ~/ 40; i++) {
            await Future.delayed(const Duration(milliseconds: 40));
            double progress = i / (animDurationMillis ~/ 40);
            if (rng.nextDouble() <= progress) {
              if (progress < 0.5) {
                HapticFeedback.lightImpact();
              } else if (progress < 0.8) {
                HapticFeedback.mediumImpact();
              } else {
                HapticFeedback.heavyImpact();
              }
            }
          }
          setState(() {
            _splashSize = 2000 - _splashSize;
          });
          HapticFeedback.vibrate();
          await Future.delayed(const Duration(milliseconds: 1000));

          setState(() {
            user = FirebaseAuth.instance.currentUser!;
          });
          // ignore: use_build_context_synchronously
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => const ProfileSetupPage()));

          //Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => const HomePage()));
          loggedIn = true;
        } on FirebaseAuthException catch (e) {
          if (e.code == 'invalid-email') {
            setState(() {
              passwordError = false;
              emailError = true;
              errorText = "Please enter a valid email";
            });
          } else if (e.code == 'user-not-found') {
            setState(() {
              passwordError = false;
              emailError = true;
              errorText = "Email not found";
            });
          } else if (e.code == 'wrong-password') {
            setState(() {
              passwordError = true;
              emailError = false;
              errorText = "Incorrect password";
            });
          } else {
            setState(() {
              passwordError = true;
              emailError = true;
              errorText = "Unknown error (${e.code})";
            });
          }
        }
      }
    }
    setState(() {
      loginEnabled = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Stack(
          children: [
            SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Container(
                color: Theme.of(context).colorScheme.background,
                child: SafeArea(
                  child: Center(
                    child: Column(
                      children: [
                        const SizedBox(height: 75),
                        TweenAnimationBuilder(
                            tween: Tween<double>(begin: 0, end: fill),
                            duration: Duration(milliseconds: animDurationMillis),
                            curve: Curves.easeInOut,
                            child: SvgPicture.asset(
                              "lib/assets/tottori_logo_without_i.svg",
                              width: 120,
                              height: 120,
                              colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                            ),
                            builder: (_, double value, myChild) {
                              return ShaderMask(
                                  shaderCallback: (bounds) => LinearGradient(
                                        begin: Alignment.bottomCenter,
                                        end: Alignment.topCenter,
                                        stops: [value, value],
                                        colors: [
                                          logoColor,
                                          Theme.of(context).colorScheme.outline,
                                        ],
                                      ).createShader(bounds),
                                  child: myChild);
                            }),
                        const SizedBox(height: 75),
                        Text(
                          "Welcome, please sign in",
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        const SizedBox(height: 25),

                        /*TextButton(
                          onPressed: () async {
                            setState(() {
                              fill = 1 - fill;
                              splashSize = 2000 - splashSize;
                            });
                            var rng = Random();
                            for (int i = 0; i < animDurationMillis ~/ 40; i++) {
                              await Future.delayed(const Duration(milliseconds: 40));
                              double progress = i / (animDurationMillis ~/ 40);
                              if (rng.nextDouble() <= progress) {
                                if (progress < 0.5) {
                                  HapticFeedback.lightImpact();
                                } else if (progress < 0.8) {
                                  HapticFeedback.mediumImpact();
                                } else {
                                  HapticFeedback.heavyImpact();
                                }
                              }
                            }
                            HapticFeedback.vibrate();
                          },
                          child: const Text("test"),
                        ),
                        IconButton(
                          onPressed: () {
                            themeNotifier.value = themeNotifier.value == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
                            themeNotifier.notifyListeners();
                          },
                          icon: const Icon(Icons.sunny),
                        ),*/
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 50),
                          child: TextField(
                            focusNode: emailFocus,
                            onEditingComplete: () {
                              FocusScope.of(context).requestFocus(passwordFocus);
                            },
                            onTap: () {
                              setState(() {
                                emailError = false;
                              });
                            },
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.emailAddress,
                            controller: emailController,
                            decoration: InputDecoration(
                                fillColor: Theme.of(context).colorScheme.surfaceTint,
                                filled: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                                focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color(0xfffaa700),
                                    width: 3,
                                  ),
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(10),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: emailError ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.outline,
                                    width: emailError ? 3 : 1,
                                  ),
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(10),
                                  ),
                                ),
                                hintText: "Email"),
                            autocorrect: false,
                            style: const TextStyle(),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 50),
                          child: ValueListenableBuilder(
                              valueListenable: hidePassword,
                              builder: (context, bool hide, _) {
                                return TextField(
                                  focusNode: passwordFocus,
                                  keyboardType: TextInputType.visiblePassword,
                                  textInputAction: TextInputAction.send,
                                  controller: passwordController,
                                  onEditingComplete: () {
                                    signIn();
                                    FocusScope.of(context).unfocus();
                                  },
                                  onTap: () {
                                    setState(() {
                                      emailError = false;
                                    });
                                  },
                                  decoration: InputDecoration(
                                      fillColor: Theme.of(context).colorScheme.surfaceTint,
                                      filled: true,
                                      suffixIcon: Padding(
                                        padding: const EdgeInsets.only(right: 8.0),
                                        child: IconButton(
                                            onPressed: () {
                                              setState(() {
                                                hidePassword.value = !hidePassword.value;
                                              });
                                            },
                                            icon: Icon(hidePassword.value ? Icons.visibility_off : Icons.visibility)),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                                      focusedBorder: const OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Color(0xfffaa700),
                                          width: 3,
                                        ),
                                        borderRadius: BorderRadius.vertical(
                                          bottom: Radius.circular(10),
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: passwordError ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.outline,
                                          width: passwordError ? 3 : 1,
                                        ),
                                        borderRadius: const BorderRadius.vertical(
                                          bottom: Radius.circular(10),
                                        ),
                                      ),
                                      hintText: "Password"),
                                  autocorrect: false,
                                  obscureText: hide,
                                  style: const TextStyle(),
                                );
                              }),
                        ),
                        const SizedBox(height: 5),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 50.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: SingleChildScrollView(
                                  physics: const ClampingScrollPhysics(),
                                  scrollDirection: Axis.horizontal,
                                  child: Text(
                                    errorText,
                                    style: Theme.of(context).textTheme.labelSmall!.copyWith(color: Theme.of(context).colorScheme.error),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {},
                                child: Text(
                                  "Forgot password?",
                                  style: Theme.of(context).textTheme.labelSmall,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 25),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 50),
                          child: Material(
                            child: InkWell(
                              splashColor: Theme.of(context).colorScheme.secondary,
                              onTap: loginEnabled ? signIn : null,
                              child: Ink(
                                width: double.infinity,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: loginEnabled ? const Color(0xfffaa700) : Theme.of(context).colorScheme.outline,
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(10),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    "Sign in",
                                    style: Theme.of(context).textTheme.labelLarge!.copyWith(color: loginEnabled ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.background),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 25,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 50.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              const Expanded(child: Divider(thickness: 1)),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text(
                                  "Or sign in with",
                                  style: Theme.of(context).textTheme.labelMedium,
                                ),
                              ),
                              const Expanded(child: Divider(thickness: 1)),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 25,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Material(
                              child: InkWell(
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(10),
                                ),
                                splashColor: Theme.of(context).colorScheme.surfaceVariant,
                                onTap: () async {
                                  await AuthService().signInWithGoogle();
                                  user = FirebaseAuth.instance.currentUser;
                                  //user?.reload();
                                  //fixAccount();
                                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => const ProfileSetupPage()));
                                },
                                child: Ink(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.surface,
                                    border: Border.all(color: Theme.of(context).colorScheme.surfaceVariant),
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(10),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(15.0),
                                    child: Image.asset(
                                      "lib/assets/google.png",
                                      color: Theme.of(context).colorScheme.outline,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 40,
                            ),
                            Material(
                              child: InkWell(
                                splashColor: Theme.of(context).colorScheme.surfaceVariant,
                                onTap: () {},
                                child: Ink(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.surface,
                                    border: Border.all(color: Theme.of(context).colorScheme.surfaceVariant),
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(10),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(14, 14, 16, 16),
                                    child: Image.asset(
                                      "lib/assets/apple.png",
                                      color: Theme.of(context).colorScheme.outline,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 25,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "New around here?",
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                            const SizedBox(
                              width: 4,
                            ),
                            GestureDetector(
                              onTap: widget.onTap,
                              child: Text(
                                "Register account",
                                style: Theme.of(context).textTheme.labelMedium!.copyWith(color: Colors.blue),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            TweenAnimationBuilder(
              tween: Tween<double>(begin: 0, end: _splashSize),
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeOut,
              builder: (context, double splash, _) {
                return Positioned(
                  top: 75 + 97.5 - ((splash - 10) / 2),
                  left: MediaQuery.of(context).size.width / 2 + 41.25 - ((splash - 10) / 2),
                  width: splash,
                  height: splash,
                  child: Container(
                    alignment: Alignment.center,
                    transformAlignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: logoColor,
                      shape: BoxShape.circle,
                    ),
                    width: 10,
                    height: 10,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
