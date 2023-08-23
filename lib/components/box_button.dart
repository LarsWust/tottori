import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tottori/classes/tottori_colors.dart';
import 'package:tottori/components/box_button_type.dart';

class BoxButton extends StatefulWidget {
  VoidCallback? onTap;
  String? title;
  IconData icon;
  BoxButtonType type = BoxButtonType.normal;
  String? leading;
  bool forceSquare = true;
  bool hold;

  BoxButton({
    super.key,
    this.leading,
    this.onTap,
    this.title,
    required this.icon,
    this.type = BoxButtonType.normal,
    this.forceSquare = true,
    this.hold = false,
  });

  @override
  State<BoxButton> createState() => _BoxButtonState();
}

class _BoxButtonState extends State<BoxButton> {
  double _anim = 0;
  final int _millis = 150;
  bool _holding = false;
  bool _confirm = false;
  int _falseAttempts = 0;

  @override
  Widget build(BuildContext context) {
    Color color;
    Color colorContainer;
    if (widget.type == BoxButtonType.normal) {
      color = Theme.of(context).colorScheme.secondary;
      colorContainer = Theme.of(context).colorScheme.surfaceTint;
    } else if (widget.type == BoxButtonType.warning) {
      color = Theme.of(context).colorScheme.error;
      colorContainer = Theme.of(context).colorScheme.errorContainer;
    } else {
      color = TottoriColors(context).green;
      colorContainer = TottoriColors(context).greenContainer;
    }
    Widget body = GestureDetector(
      //borderRadius: const BorderRadius.all(Radius.circular(8)),

      onTap: (widget.onTap != null && !widget.hold)
          ? () {
              widget.onTap!();
              setState(() {
                _anim = 1;
              });
              Future.delayed(Duration(milliseconds: _millis ~/ 1.25)).then((value) {
                setState(() {
                  _anim = 0;
                });
              });
              HapticFeedback.lightImpact();
            }
          : () {
              _falseAttempts++;
              if (_falseAttempts > 2) {
                _falseAttempts = 0;
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Theme.of(context).secondaryHeaderColor,
                    content: Text(
                      "Hold button down for 1 second to confirm!",
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
      onTapDown: (widget.onTap != null)
          ? (details) async {
              _holding = true;
              if (widget.hold) {
                int millis = 0;
                int freq = 100;
                int threshold = 1000;
                Future.doWhile(() async {
                  if ((_holding == false)) {
                    setState(() {
                      _anim = 0;
                      _holding = false;
                      _confirm = false;
                    });
                    return false;
                  }
                  await Future.delayed(Duration(milliseconds: freq));
                  millis += freq;
                  if (millis < threshold) {
                    setState(() {
                      _anim = 0.25 * (millis / threshold);
                    });
                    HapticFeedback.heavyImpact();
                    return true;
                  } else {
                    setState(() {
                      _anim = 1.5;
                      _confirm = true;
                    });
                    HapticFeedback.vibrate();
                    return false;
                  }
                });
              } else {
                setState(() {
                  _anim = 1;
                });

                HapticFeedback.lightImpact();
              }
            }
          : null,

      onTapUp: (widget.onTap != null)
          ? (details) {
              if (_confirm) {
                widget.onTap!();
              }
              setState(() {
                _anim = 0;
                _holding = false;
                _confirm = false;
              });
              HapticFeedback.heavyImpact();
            }
          : null,
      onTapCancel: (widget.onTap != null)
          ? () {
              setState(() {
                _anim = 0;
                _holding = false;
                _confirm = false;
              });
            }
          : null,

      child: TweenAnimationBuilder(
          tween: Tween<double>(begin: 0, end: _anim),
          duration: Duration(milliseconds: _millis),
          curve: Curves.easeOutQuad,
          builder: (context, value, child) {
            Widget innerBody = Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: Icon(
                        widget.icon,
                        color: color,
                        size: 24 - 6 * value,
                      ),
                    ),
                  ),
                  widget.title != null
                      ? Text(
                          widget.title!,
                          style: Theme.of(context).textTheme.labelMedium!.copyWith(color: color),
                        )
                      : const SizedBox.shrink(),
                ],
              ),
            );
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(8 + value * 8)),
                color: !_confirm ? colorContainer : color,
                boxShadow: [
                  BoxShadow(
                    color: !_confirm ? colorContainer : color,
                    spreadRadius: 4 * value,
                    blurRadius: 8 * value,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: widget.leading == null
                    ? innerBody
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            widget.leading!,
                            style: Theme.of(context).textTheme.labelMedium!.copyWith(color: color),
                          ),
                          innerBody,
                        ],
                      ),
              ),
            );
          }),
    );
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: widget.forceSquare
            ? AspectRatio(
                aspectRatio: 1,
                child: body,
              )
            : body);
  }
}
