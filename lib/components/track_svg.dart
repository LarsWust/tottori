import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tottori/components/expanded_svg.dart';

class TrackSvg extends StatelessWidget {
  const TrackSvg(
    this.context, {
    super.key,
    this.expandable = false,
    this.color,
    this.svg,
  });

  final BuildContext context;
  final bool expandable;
  final Color? color;
  final File? svg;

  @override
  Widget build(BuildContext context) {
    SvgPicture svgPic = svg != null
        ? SvgPicture.file(
            svg!,
            colorFilter: ColorFilter.mode(
              color ?? Theme.of(context).colorScheme.onBackground,
              BlendMode.srcIn,
            ),
          )
        : SvgPicture.asset(
            "lib/assets/default_track.svg",
            colorFilter: ColorFilter.mode(
              color ?? Theme.of(context).colorScheme.onBackground,
              BlendMode.srcIn,
            ),
          );
    return expandable
        ? Hero(
            tag: hashCode,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    opaque: false,
                    transitionDuration: const Duration(milliseconds: 500),
                    reverseTransitionDuration: const Duration(milliseconds: 500),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      return FadeTransition(
                        opacity: animation,
                        child: child,
                      );
                    },
                    pageBuilder: (context, _, __) => ExpandedSvg(
                      svg: svgPic,
                      tag: hashCode,
                    ),
                  ),
                );
              },
              child: svgPic,
            ),
          )
        : svgPic;
  }
}
