import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:tottori/classes/tottori_queue_data.dart';
import 'package:tottori/classes/tottori_track_data.dart';
import 'package:tottori/components/queue_view.dart';
import 'package:tottori/components/track_feed_card.dart';

void pushTrackCard(BuildContext context, {int? heroTag, required TottoriTrackData trackData}) {
  Navigator.push(
    context,
    PageRouteBuilder(
      opaque: false,
      barrierDismissible: true,
      fullscreenDialog: false,
      transitionDuration: const Duration(milliseconds: 500),
      reverseTransitionDuration: const Duration(milliseconds: 500),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      pageBuilder: (context, _, __) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
              child: TrackFeedCard.fromTrackData(
                trackData,
                //liked: currentUserDataStream.likedTracks.map((e) => e.uuid).contains(widget.track.uuid),
                heroTag: heroTag,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

void pushQueueView(BuildContext context, {int? heroTag, required TottoriQueueData queueData}) {
  Navigator.push(
    context,
    PageRouteBuilder(
      opaque: false,
      barrierDismissible: true,
      fullscreenDialog: false,
      transitionDuration: const Duration(milliseconds: 500),
      reverseTransitionDuration: const Duration(milliseconds: 500),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      pageBuilder: (context, _, __) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Dialog(
              backgroundColor: Theme.of(context).colorScheme.background,
              insetPadding: const EdgeInsets.all(4),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: QueueView(
                queueData: queueData,
                heroTag: heroTag,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
