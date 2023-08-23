import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:tottori/components/profile_picture.dart';

class ExpandedProfile extends StatefulWidget {
  final Image image;
  final int tag;

  const ExpandedProfile({super.key, required this.image, required this.tag});

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
              tag: widget.tag,
              child: SizedBox(
                width: MediaQuery.of(context).size.shortestSide / 1.5,
                height: MediaQuery.of(context).size.shortestSide / 1.5,
                child: ProfilePicture.image(
                  image: widget.image,
                ),
              )),
        )),
      ),
    );
  }
}
