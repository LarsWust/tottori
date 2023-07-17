import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image/image.dart' as img;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tottori/components/profile_picture.dart';

import '../main.dart';

class ProfileSetupPage extends StatefulWidget {
  const ProfileSetupPage({super.key});

  @override
  State<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends State<ProfileSetupPage> {
  int animDurationMillis = 5000;
  FocusNode usernameFocus = FocusNode();
  ValueNotifier<Image> image = ValueNotifier<Image>(Image.asset("lib/assets/default_picture.png"));
  ValueNotifier<File?> updatedImage = ValueNotifier<File?>(null);

  String errorText = "";
  bool usernameError = false;
  Image? oldImage;

  double fill = 0;
  final double _splashSize = 0;
  bool setupEnabled = true;

  final usernameController = TextEditingController(text: user.displayName);

  void setUpAnimation() {}

  void setUp() async {
    //TODO: Add dupe username check
    setState(() {
      setupEnabled = false;
      errorText = "";
    });
    if (FirebaseAuth.instance.currentUser != null) {
      if (updatedImage.value != null) {
        try {
          img.Image resized = img.copyResize(img.decodeImage(await updatedImage.value!.readAsBytes())!, width: 256);
          File uploadFile = await updatedImage.value!.writeAsBytes(img.encodeJpg(resized, quality: 50));
          setState(() => {imageCache.clear(), imageCache.clearLiveImages()});
          final String pfpPath = 'user-profile-images/${user.uid}.jpg';
          final ref = FirebaseStorage.instance.ref().child(pfpPath);
          await ref.putFile(uploadFile);
          await user.updatePhotoURL(await ref.getDownloadURL());
          image.value = Image.file(uploadFile);
          oldImage = Image.file(uploadFile);
          updatedImage.value = null;
        } catch (e) {
          setState(() {
            errorText = "Failed to update profile image ($e)";
          });
        }
      }
      if ((usernameController.text != user.displayName)) {
        if (usernameController.text.trim().length >= 3 && usernameController.text.trim().length <= 48) {
          print("updating ${user.displayName} to ${usernameController.text.trim()} (${usernameController.text.trim().length})");

          await user.updateDisplayName(usernameController.text.trim());
          user = FirebaseAuth.instance.currentUser!;
        } else {
          errorText = "Username must be between 3-48 characters!";
        }
      }
    }
    setState(() {
      setupEnabled = true;
    });
  }

  @override
  void initState() {
    super.initState();
    if (user.photoURL == null) {
      image.value = Image.asset("lib/assets/default_picture.png");
      oldImage = Image.asset("lib/assets/default_picture.png");
    } else {
      image.value = Image.network(user.photoURL!);
      oldImage = Image.network(user.photoURL!);
    }
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
                          "Let's get your account set up!",
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        const SizedBox(height: 25),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 50),
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Center(
                                    child: GestureDetector(
                                      onTap: () async {
                                        if (updatedImage.value == null) {
                                          final ImagePicker picker = ImagePicker();
                                          final XFile? pick = await picker.pickImage(source: ImageSource.gallery);
                                          if (pick != null) {
                                            try {
                                              CroppedFile? croppedFile = await ImageCropper().cropImage(
                                                sourcePath: pick.path,
                                                aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
                                                cropStyle: CropStyle.rectangle,
                                                compressFormat: ImageCompressFormat.jpg,
                                                uiSettings: [
                                                  AndroidUiSettings(
                                                    toolbarTitle: 'Crop Profile Picture',
                                                    toolbarColor: Colors.deepOrange,
                                                    toolbarWidgetColor: Colors.white,
                                                    initAspectRatio: CropAspectRatioPreset.square,
                                                    lockAspectRatio: true,
                                                  ),
                                                  IOSUiSettings(
                                                    title: 'Crop Profile Picture',
                                                    aspectRatioLockEnabled: true,
                                                    minimumAspectRatio: 1,
                                                    aspectRatioPickerButtonHidden: true,
                                                    resetAspectRatioEnabled: false,
                                                  ),
                                                ],
                                              );
                                              if (croppedFile != null) {
                                                setState(() {
                                                  updatedImage.value = File(croppedFile.path);
                                                  image.value = Image.file(updatedImage.value!);
                                                });
                                              } else {
                                                print("crop cancelled");
                                              }
                                            } catch (e) {
                                              setState(() {
                                                errorText = "Error picking image ($e)";
                                              });
                                            }
                                          }
                                        } else {
                                          setState(() {
                                            image.value = oldImage!;
                                            updatedImage.value = null;
                                          });
                                        }
                                      },
                                      child: SizedBox(
                                        width: 150,
                                        height: 150,
                                        child: AspectRatio(
                                          aspectRatio: 1,
                                          child: Stack(
                                            children: [
                                              ValueListenableBuilder(
                                                  valueListenable: image,
                                                  builder: (context, Image img, child) {
                                                    return ProfilePicture.image(
                                                      image: img,
                                                      width: 150,
                                                      height: 150,
                                                    );
                                                  }),
                                              Center(
                                                child: Container(
                                                  width: 75, //MediaQuery.of(context).size.width / 2,
                                                  height: 75, //MediaQuery.of(context).size.height / 2,
                                                  decoration: const BoxDecoration(
                                                    color: Color.fromARGB(70, 0, 0, 0),
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                              ),
                                              Center(
                                                child: ValueListenableBuilder(
                                                    valueListenable: updatedImage,
                                                    builder: (context, upd8, child) {
                                                      return Icon(
                                                        (upd8 == null) ? Icons.edit : Icons.replay,
                                                        color: const Color.fromARGB(190, 255, 255, 255),
                                                      );
                                                    }),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  TextField(
                                    controller: usernameController,
                                    maxLines: 1,
                                    maxLength: 48,
                                    minLines: 1,
                                    maxLengthEnforcement: MaxLengthEnforcement.enforced,
                                    autocorrect: false,
                                    decoration: const InputDecoration(hintText: "Username"),
                                  ),
                                  Text(user.email!),
                                ],
                              ),
                            ),
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
                              onTap: setupEnabled ? setUp : null,
                              child: Ink(
                                width: double.infinity,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: setupEnabled ? const Color(0xfffaa700) : Theme.of(context).colorScheme.outline,
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(10),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    "Set up",
                                    style: Theme.of(context).textTheme.labelLarge!.copyWith(color: setupEnabled ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.background),
                                  ),
                                ),
                              ),
                            ),
                          ),
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
