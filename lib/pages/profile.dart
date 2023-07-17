import 'package:flutter/material.dart';
import 'package:tottori/components/profile_picture.dart';
import 'package:tottori/main.dart';
import 'package:tottori/pages/profile_setup.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Builder(builder: (context) {
              if (user.photoURL == null) {
                return const Icon(Icons.disabled_by_default);
              } else {
                return ProfilePicture.user(
                  user: user,
                  width: 100,
                  height: 100,
                  expanable: true,
                );
              }
            }),
            Text("${user.email}"),
          ],
        ),
        TextButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileSetupPage()));
            },
            child: const Text("Setup"))
      ],
    );
  }
}
