import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tottori/components/expanded_profile.dart';

class ProfilePicture extends StatefulWidget {
  final double height;
  final double width;
  // final bool edit;
  // File? updatedImage;
  late Image image;
  final bool expanable;
  //late Image oldImage;
  // IconData icon = Icons.edit;

  ProfilePicture.user({super.key, required User user, this.height = 100, this.width = 100, this.expanable = false}) {
    if (user.photoURL == null) {
      image = Image.asset("lib/assets/default_picture.png");
      //oldImage = image;
    } else {
      try {
        image = Image.network(user.photoURL!);
      } catch (e) {
        image = Image.asset("lib/assets/default_picture.png");
      }
      //oldImage = image;
    }
  }

  ProfilePicture.image({super.key, required this.image, this.height = 100, this.width = 100, this.expanable = false});

  @override
  State<ProfilePicture> createState() => _ProfilePictureState();
}

class _ProfilePictureState extends State<ProfilePicture> {
  @override
  Widget build(BuildContext context) {
    if (widget.expanable) {
      return Hero(
        tag: "profile",
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                opaque: false,
                pageBuilder: (context, _, __) => ExpandedProfile(image: widget.image),
              ),
            );
          },
          child: SizedBox(
            width: widget.width,
            height: widget.height,
            child: AspectRatio(
              aspectRatio: 1,
              child: Container(
                width: widget.width,
                height: widget.height,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(image: widget.image.image, fit: BoxFit.fill),
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: AspectRatio(
          aspectRatio: 1,
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(image: widget.image.image, fit: BoxFit.fill),
            ),
          ),
        ),
      );
    }
  }
}
