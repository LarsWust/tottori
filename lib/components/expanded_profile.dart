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

      //try convert to imagefilter https://github.com/flutter/flutter/issues/32804#issuecomment-735009692
      child: Container(
        color: const Color.fromARGB(100, 0, 0, 0),
        child: SafeArea(
          child: Center(
            child: Hero(
              transitionOnUserGestures: true,
              flightShuttleBuilder: (flightContext, animation, flightDirection, fromHeroContext, toHeroContext) {
                return Stack(children: [
                  Positioned.fill(child: fromHeroContext.widget),
                  Positioned.fill(child: toHeroContext.widget),
                ]);
              },
              tag: widget.tag,
              child: FadeTransition(
                opacity: ModalRoute.of(context)?.animation ?? const AlwaysStoppedAnimation(1),
                child: FadeTransition(
                  opacity: ReverseAnimation(ModalRoute.of(context)?.secondaryAnimation ?? const AlwaysStoppedAnimation(1)),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.shortestSide / 1.5,
                    height: MediaQuery.of(context).size.shortestSide / 1.5,
                    child: ProfilePicture.image(
                      image: widget.image,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
