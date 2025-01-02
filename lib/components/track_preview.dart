import 'package:flutter/material.dart';
import 'package:tottori/classes/tottori_track.dart';
import 'package:tottori/classes/tottori_track_data.dart';
import 'package:tottori/classes/tottori_user.dart';
import 'package:tottori/classes/tottori_user_data.dart';
import 'package:tottori/components/track_feed_card.dart';
import 'package:tottori/main.dart';

class TrackPreview extends StatefulWidget {
  final TottoriTrack track;
  final TottoriUserData? currentUser;
  final bool expandable;
  final TottoriUser? whoLiked;
  TrackPreview({super.key, required this.track, this.expandable = false, this.currentUser, this.whoLiked});

  @override
  State<TrackPreview> createState() => _TrackPreviewState();

  Future<TottoriUserData> getData() async {
    if (currentUser != null) {
      return Future.value(currentUser);
    } else {
      return TottoriUser(user!.uid).data;
    }
  }
}

class _TrackPreviewState extends State<TrackPreview> {
  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: FutureBuilder(
            future: widget.getData(),
            builder: (context, currentUser) {
              return FutureBuilder(
                future: widget.whoLiked == null ? widget.track.data : widget.track.getDataInCase(whoLiked: widget.whoLiked),
                builder: (context, snapshot) {
                  print("dsnasphtodata: ${snapshot.data?.title} for ${widget.track.uuid}");
                  if (snapshot.data != null && snapshot.connectionState == ConnectionState.done) {
                    Widget svgPicutre = snapshot.data!.svgPicture(context);
                    return GestureDetector(
                      onTap: () {
                        print("trapped ${snapshot.data!.title}");
                      },
                      behavior: HitTestBehavior.translucent,
                      child: GestureDetector(
                        onTap: (currentUser.connectionState == ConnectionState.done && snapshot.connectionState == ConnectionState.done)
                            ? () {
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
                                    pageBuilder: (context, _, __) => SafeArea(
                                      child: Padding(
                                        padding: const EdgeInsets.all(24.0),
                                        child: Dialog(
                                          backgroundColor: Colors.transparent,
                                          insetPadding: EdgeInsets.zero,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
                                          child: TrackFeedCard.fromTrackData(
                                            snapshot.data!,
                                            //liked: currentUser.data!.likedTracks.map((e) => e.uuid).contains(widget.track.uuid),
                                            heroTag: widget.hashCode,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }
                            : null,
                        child: Material(
                          borderRadius: const BorderRadius.all(Radius.circular(1000)),
                          elevation: 4,
                          child: Container(
                            decoration: BoxDecoration(shape: BoxShape.circle, color: Theme.of(context).colorScheme.surface),
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: widget.expandable
                                  ? Hero(
                                      tag: widget.hashCode.toString(),
                                      child: svgPicutre,
                                    )
                                  : svgPicutre,
                            ),
                          ),
                        ),
                      ),
                    );
                  } else {
                    return AspectRatio(
                      aspectRatio: 1,
                      child: TottoriTrackData.defaultSvg(context),
                    );
                  }
                },
              );
            }),
      ),
    );
  }
}
