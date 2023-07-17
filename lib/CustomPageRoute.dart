import 'package:flutter/material.dart';

class CustomPageRoute<T> extends PageRoute<T> {
  CustomPageRoute(this.child, this.context);
  @override
  // TODO: implement barrierColor
  Color get barrierColor => Theme.of(context).colorScheme.background;

  @override
  String? get barrierLabel => null;

  final Widget child;
  final BuildContext context;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 1000);
}
