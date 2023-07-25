import 'package:flutter/material.dart';
import 'package:tottori/components/expanded_profile.dart';

class ProfilePicture extends StatefulWidget {
  final double height;
  final double width;
  Image image = Image.asset("lib/assets/default_picture.png");
  final bool expanable;
  ProfilePicture.image({super.key, required this.image, this.height = 100, this.width = 100, this.expanable = false});
  ProfilePicture.blank({super.key, this.height = 100, this.width = 100, this.expanable = false});

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
      return Hero(
        tag: widget.hashCode.toString(),
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                opaque: false,
                pageBuilder: (context, _, __) => ExpandedProfile(
                  image: widget.image,
                  tag: widget.hashCode.toString(),
                ),
              ),
            );
          },
          child: widget.circleImage(widget.image.image),
        ),
      );
    } else {
      return widget.circleImage(widget.image.image);
    }
  }
}
