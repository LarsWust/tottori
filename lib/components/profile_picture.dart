import 'package:flutter/material.dart';
import 'package:tottori/components/expanded_profile.dart';

class ProfilePicture extends StatefulWidget {
  Image image = Image.asset("lib/assets/default_picture.png");
  int? heroTag;
  final bool expanable;
  ProfilePicture.image({super.key, required Image? image, this.expanable = false, this.heroTag}) {
    this.image = image ?? this.image;
  }
  ProfilePicture.blank({super.key, this.expanable = false});

  @override
  State<ProfilePicture> createState() => _ProfilePictureState();

  Widget circleImage(ImageProvider<Object> img) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(image: img, fit: BoxFit.fill),
        ),
      ),
    );
  }
}

class _ProfilePictureState extends State<ProfilePicture> {
  @override
  Widget build(BuildContext context) {
    if (widget.expanable) {
      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 500),
              reverseTransitionDuration: const Duration(milliseconds: 500),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
              opaque: false,
              pageBuilder: (context, _, __) => ExpandedProfile(
                image: widget.image,
                tag: widget.heroTag ?? hashCode,
              ),
            ),
          );
        },
        child: Hero(
          transitionOnUserGestures: true,
          flightShuttleBuilder: (flightContext, animation, flightDirection, fromHeroContext, toHeroContext) {
            return Stack(children: [
              Positioned.fill(child: fromHeroContext.widget),
              Positioned.fill(child: toHeroContext.widget),
            ]);
          },
          tag: widget.heroTag ?? hashCode,
          child: FadeTransition(
            opacity: ModalRoute.of(context)?.animation ?? const AlwaysStoppedAnimation(1),
            child: FadeTransition(
              opacity: ReverseAnimation(ModalRoute.of(context)?.secondaryAnimation ?? const AlwaysStoppedAnimation(1)),
              child: widget.circleImage(widget.image.image),
            ),
          ),
        ),
      );
    } else {
      return widget.circleImage(widget.image.image);
    }
  }
}
