import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ExpandedSvg extends StatefulWidget {
  final SvgPicture svg;
  final int tag;

  const ExpandedSvg({super.key, required this.svg, required this.tag});

  @override
  State<ExpandedSvg> createState() => _ExpandedSvgState();
}

class _ExpandedSvgState extends State<ExpandedSvg> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        Navigator.pop(context);
      },
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          color: Theme.of(context).colorScheme.background.withAlpha(160),
          child: SafeArea(
            child: Center(
              child: Hero(
                tag: widget.tag,
                child: SizedBox(
                  width: MediaQuery.of(context).size.shortestSide / 1.5,
                  height: MediaQuery.of(context).size.shortestSide / 1.5,
                  child: widget.svg,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
