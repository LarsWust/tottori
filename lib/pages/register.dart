import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tottori/helpers/account_helpers.dart';
import 'package:tottori/pages/profile_setup.dart';
import 'package:tottori/services/auth_service.dart';

import '../main.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;
  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  int animDurationMillis = 5000;
  FocusNode emailFocus = FocusNode();
  FocusNode passwordFocus = FocusNode();
  FocusNode confirmFocus = FocusNode();

  String errorText = "";
  bool emailError = false;
  bool passwordError = false;
  bool confirmError = false;

  double fill = 0;
  double _splashSize = 0;
  bool signupEnabled = true;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  void signInAnimation() {}

  void signUp() async {
    loggedIn = false;
    setState(() {
      signupEnabled = false;
      fill = 0;
      _splashSize = 0;
      emailError = false;
      passwordError = false;
      confirmError = false;
      errorText = "";
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
      } else if (passwordController.text != confirmController.text) {
        setState(() {
          confirmError = true;
          errorText = "Passwords do not match!";
        });
      } else {
        try {
          setState(() {
            passwordError = false;
            emailError = false;
            errorText = "";
          });
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
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

          loggedIn = true;
        } on FirebaseAuthException catch (e) {
          if (e.code == 'email-already-in-use') {
            setState(() {
              emailError = true;
              passwordError = false;
              errorText = "Account already exists with email";
            });
          } else if (e.code == 'invalid-email') {
            setState(() {
              emailError = true;
              passwordError = false;
              errorText = "Please enter a valid email";
            });
          } else if (e.code == 'weak-password') {
            setState(() {
              emailError = false;
              passwordError = true;
              errorText = "Password is too weak!";
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
      signupEnabled = true;
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
                          child: TextField(
                            focusNode: passwordFocus,
                            onEditingComplete: () {
                              FocusScope.of(context).requestFocus(confirmFocus);
                              if (passwordController.text != confirmController.text) {
                                setState(() {
                                  confirmError = true;
                                  errorText = "Passwords do not match!";
                                });
                              } else {
                                setState(() {
                                  confirmError = false;
                                  errorText = "";
                                });
                              }
                            },
                            onTapOutside: (event) {
                              if (passwordController.text != confirmController.text) {
                                setState(() {
                                  confirmError = true;
                                  errorText = "Passwords do not match!";
                                });
                              } else {
                                setState(() {
                                  confirmError = false;
                                  errorText = "";
                                });
                              }
                            },
                            onTap: () {
                              setState(() {
                                passwordError = false;
                              });
                            },
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.visiblePassword,
                            controller: passwordController,
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
                                    top: Radius.zero,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: passwordError ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.outline,
                                    width: passwordError ? 3 : 1,
                                  ),
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.zero,
                                  ),
                                ),
                                hintText: "Password"),
                            autocorrect: false,
                            style: const TextStyle(),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 50),
                          child: TextField(
                            focusNode: confirmFocus,
                            onTapOutside: (event) {
                              if (passwordController.text != confirmController.text) {
                                setState(() {
                                  confirmError = true;
                                  errorText = "Passwords do not match!";
                                });
                              } else {
                                setState(() {
                                  confirmError = false;
                                  errorText = "";
                                });
                              }
                            },
                            onEditingComplete: () {
                              FocusScope.of(context).unfocus();
                              if (passwordController.text != confirmController.text) {
                                setState(() {
                                  confirmError = true;
                                  errorText = "Passwords do not match!";
                                });
                              } else {
                                setState(() {
                                  confirmError = false;
                                  errorText = "";
                                });
                              }
                            },
                            onTap: () {
                              setState(() {
                                confirmError = false;
                                errorText = "";
                              });
                            },
                            textInputAction: TextInputAction.send,
                            keyboardType: TextInputType.visiblePassword,
                            controller: confirmController,
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
                                    bottom: Radius.circular(10),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: confirmError ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.outline,
                                    width: confirmError ? 3 : 1,
                                  ),
                                  borderRadius: const BorderRadius.vertical(
                                    bottom: Radius.circular(10),
                                  ),
                                ),
                                hintText: "Confirm password"),
                            autocorrect: false,
                            style: const TextStyle(),
                          ),
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
                            ],
                          ),
                        ),
                        const SizedBox(height: 25),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 50),
                          child: Material(
                            child: InkWell(
                              splashColor: Theme.of(context).colorScheme.secondary,
                              onTap: signupEnabled ? signUp : null,
                              child: Ink(
                                width: double.infinity,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: signupEnabled ? const Color(0xfffaa700) : Theme.of(context).colorScheme.outline,
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(10),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    "Sign up",
                                    style: Theme.of(context).textTheme.labelLarge!.copyWith(color: signupEnabled ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.background),
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
                                  "Or sign up with",
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
                                splashColor: Theme.of(context).colorScheme.surfaceVariant,
                                onTap: () {
                                  AuthService().signInWithGoogle();
                                  user?.reload();
                                  fixAccount();
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
                              "Already have an account?",
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                            const SizedBox(
                              width: 4,
                            ),
                            GestureDetector(
                              onTap: widget.onTap,
                              child: Text(
                                "Log in",
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
