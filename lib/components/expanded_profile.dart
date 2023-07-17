import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:tottori/components/profile_picture.dart';

class ExpandedProfile extends StatefulWidget {
  final Image image;

  const ExpandedProfile({super.key, required this.image});

  @override
  State<ExpandedProfile> createState() => _ExpandedProfileState();
}

class _ExpandedProfileState extends State<ExpandedProfile> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        Navigator.pop(context);
      },
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: SafeArea(
            child: Center(
          child: Hero(
              tag: "profile",
              child: ProfilePicture.image(
                image: widget.image,
                width: MediaQuery.of(context).size.shortestSide / 2,
                height: MediaQuery.of(context).size.shortestSide / 2,
              )),
        )),
      ),
    );
  }
}
