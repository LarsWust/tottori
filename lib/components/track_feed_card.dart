import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tottori/classes/tottori_track.dart';
import 'package:tottori/classes/tottori_track_data.dart';
import 'package:tottori/classes/tottori_user.dart';
import 'package:tottori/classes/tottori_user_data.dart';
import 'package:tottori/components/box_button.dart';
import 'package:tottori/components/box_button_type.dart';
import 'package:tottori/components/profile_picture.dart';
import 'package:tottori/components/selectors/selectors.dart';
import 'package:tottori/helpers/time_format.dart';
import 'package:tottori/main.dart';
import 'package:tottori/pages/profile.dart';

import '../classes/tottori_queue.dart';
import '../classes/tottori_queue_data.dart';

class TrackFeedCard extends StatefulWidget {
  late TottoriTrackData trackData;
  MapEntry<MapEntry<TottoriUser, TottoriUserData>, MapEntry<TottoriTrack, TottoriTrackData>>? extendedData;
  late bool owned;
  late int heroTag;
  late bool tempLiked;

  TrackFeedCard.fromExtendedData(
    this.extendedData, {
    super.key,
    int? heroTag,
  }) {
    trackData = extendedData!.value.value;
    owned = trackData.owner.uuid == user?.uid;
    this.heroTag = heroTag ?? Random().nextInt(10000000);
    tempLiked = currentUserData.likedTracks.map((e) => e.uuid).cast<String>().contains(trackData.tot);
  }

  TrackFeedCard.fromTrackData(
    this.trackData, {
    super.key,
    int? heroTag,
  }) {
    owned = trackData.owner.uuid == user?.uid;
    this.heroTag = heroTag ?? Random().nextInt(10000000);
    tempLiked = currentUserData.likedTracks.map((e) => e.uuid).cast<String>().contains(trackData.tot);
  }

  Future<TottoriUserData> getData() async {
    return extendedData?.key.value ?? await trackData.owner.data;
  }

  @override
  State<TrackFeedCard> createState() => _TrackFeedCardState();
}

class _TrackFeedCardState extends State<TrackFeedCard> {
  bool _likable = true;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: widget.getData(),
        initialData: TottoriUser.defaultData,
        builder: (context, snapshot) {
          return ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            clipBehavior: Clip.antiAlias,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: const Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    color: Theme.of(context).secondaryHeaderColor,
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => Scaffold(
                                appBar: AppBar(title: const Text("Profile")),
                                body: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Profile(
                                    uuid: widget.trackData.owner.uuid,
                                    data: snapshot.data!,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              ProfilePicture.image(
                                image: snapshot.data!.pfp,
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        snapshot.data!.displayName,
                                        style: Theme.of(context).textTheme.bodyMedium,
                                      ),
                                      Text(
                                        " • ${ago(widget.trackData.created.toDate())} ago",
                                        style: Theme.of(context).textTheme.bodyMedium,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(64, 16, 64, 8),
                    child: Builder(builder: (context) {
                      return Hero(
                        tag: widget.heroTag,
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: widget.trackData.svgPicture(context),
                        ),
                      );
                    }),
                  ),
                  Center(
                    child: Text(
                      widget.trackData.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Divider(
                      height: 8,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  widget.trackData.caption != ""
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            widget.trackData.caption,
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.left,
                          ),
                        )
                      : const SizedBox.shrink(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      "Length: ${((widget.trackData.distance * 100).round()) / 100}",
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.left,
                    ),
                  ),
                  SizedBox(
                    height: 80,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        !widget.owned
                            ? Builder(builder: (context) {
                                //bool liked = currentUserData.likedTracks.map((e) => e.uuid).cast<String>().contains(widget.trackData.tot);
                                return BoxButton(
                                  onTap: _likable
                                      ? () async {
                                          setState(() {
                                            _likable = false;
                                          });
                                          if (widget.tempLiked == false) {
                                            setState(() {
                                              widget.tempLiked = true;
                                            });
                                            await TottoriUser(user!.uid).likeTrack(TottoriTrack(widget.trackData.tot)).then((value) {
                                              setState(() {
                                                _likable = true;
                                              });
                                            });
                                          } else {
                                            setState(() {
                                              widget.tempLiked = false;
                                            });
                                            await TottoriUser(user!.uid).unlikeTrack(TottoriTrack(widget.trackData.tot)).then((value) {
                                              setState(() {
                                                _likable = true;
                                              });
                                            });
                                          }
                                        }
                                      : null,
                                  icon: widget.tempLiked ? Icons.thumb_up_alt : Icons.thumb_up_alt_outlined,
                                  leading: "${widget.trackData.likes.length + (widget.tempLiked ? 1 : 0)}",
                                );
                              })
                            : const SizedBox.shrink(),
                        Flexible(
                          child: BoxButton(
                            onTap: () async {
                              List<TottoriQueueData> toAdd = await selectAddingQueues(context);
                              for (TottoriQueueData addQueueData in toAdd) {
                                TottoriQueue(addQueueData.uid).addTrack(widget.trackData);
                              }
                            },
                            icon: Icons.add,
                          ),
                        ),
                        Flexible(
                          child: BoxButton(
                            onTap: () async {
                              if (widget.trackData.svg != null) {
                                File? tot = await widget.trackData.getTot(name: widget.trackData.title);
                                if (tot != null) {
                                  await Share.shareXFiles([XFile(tot.path)], subject: '"${widget.trackData.title}" on Tottori');
                                }
                              }
                            },
                            icon: Icons.ios_share,
                          ),
                        ),
                        widget.owned
                            ? Flexible(
                                child: BoxButton(
                                  onTap: () {
                                    Navigator.of(context).push(PageRouteBuilder(
                                        opaque: false,
                                        transitionDuration: const Duration(milliseconds: 500),
                                        reverseTransitionDuration: const Duration(milliseconds: 500),
                                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                          return FadeTransition(
                                            opacity: animation,
                                            child: child,
                                          );
                                        },
                                        pageBuilder: (BuildContext context, _, __) {
                                          FocusNode captionFocus = FocusNode();
                                          FocusNode titleFocus = FocusNode();
                                          TextEditingController captionController = TextEditingController(text: widget.trackData.caption);
                                          TextEditingController titleController = TextEditingController(text: widget.trackData.title);
                                          return BackdropFilter(
                                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                            child: Dialog(
                                              child: Padding(
                                                padding: const EdgeInsets.all(24.0),
                                                child: ListView(
                                                  padding: EdgeInsets.zero,
                                                  shrinkWrap: true,
                                                  children: [
                                                    Hero(
                                                      tag: widget.heroTag,
                                                      child: Expanded(
                                                        child: AspectRatio(
                                                          aspectRatio: 1,
                                                          child: widget.trackData.svgPicture(context),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 16,
                                                    ),
                                                    TextField(
                                                      controller: titleController,
                                                      style: Theme.of(context).textTheme.titleLarge,
                                                      focusNode: titleFocus,
                                                      maxLength: 64,
                                                      onTapOutside: (event) {
                                                        titleFocus.unfocus();
                                                      },
                                                      onEditingComplete: () {
                                                        titleFocus.nextFocus();
                                                      },
                                                      textInputAction: TextInputAction.next,
                                                      decoration: InputDecoration(
                                                        hintText: "Track title",
                                                        counterText: "",
                                                        focusedBorder: const OutlineInputBorder(
                                                          borderSide: BorderSide(
                                                            color: Color(0xfffaa700),
                                                            width: 3,
                                                          ),
                                                          borderRadius: BorderRadius.vertical(
                                                            top: Radius.circular(10),
                                                          ),
                                                        ),
                                                        enabledBorder: OutlineInputBorder(
                                                          borderSide: BorderSide(
                                                            color: Theme.of(context).colorScheme.outline,
                                                            width: 1,
                                                          ),
                                                          borderRadius: const BorderRadius.vertical(
                                                            top: Radius.circular(10),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: TextField(
                                                        focusNode: captionFocus,
                                                        controller: captionController,
                                                        maxLength: 1024,
                                                        style: Theme.of(context).textTheme.bodyMedium,
                                                        maxLines: null,
                                                        onTapOutside: (event) {
                                                          captionFocus.unfocus();
                                                        },
                                                        decoration: InputDecoration(
                                                          counterText: "",
                                                          hintText: "Give me a short caption!",
                                                          focusedBorder: const OutlineInputBorder(
                                                            borderSide: BorderSide(
                                                              color: Color(0xfffaa700),
                                                              width: 3,
                                                            ),
                                                            borderRadius: BorderRadius.vertical(
                                                              bottom: Radius.circular(10),
                                                            ),
                                                          ),
                                                          enabledBorder: OutlineInputBorder(
                                                            borderSide: BorderSide(
                                                              color: Theme.of(context).colorScheme.outline,
                                                              width: 1,
                                                            ),
                                                            borderRadius: const BorderRadius.vertical(
                                                              bottom: Radius.circular(10),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 16,
                                                    ),
                                                    TextButton(
                                                      onPressed: () async {
                                                        await TottoriTrack(widget.trackData.tot).updateData(title: titleController.text, caption: captionController.text);
                                                        setState(() {
                                                          widget.trackData.title = titleController.text;
                                                          widget.trackData.caption = captionController.text;
                                                        });
                                                        if (context.mounted) {
                                                          Navigator.of(context).pop();
                                                        }
                                                      },
                                                      child: const Text("Confirm"),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        }));
                                  },
                                  icon: Icons.edit,
                                  type: BoxButtonType.normal,
                                ),
                              )
                            : const SizedBox.shrink(),
                        widget.owned
                            ? Flexible(
                                child: BoxButton(
                                  onTap: () async {
                                    TottoriTrack(widget.trackData.tot).delete();
                                    if (context.mounted) {
                                      Navigator.of(context).pop();
                                    }
                                  },
                                  icon: Icons.delete_forever,
                                  type: BoxButtonType.warning,
                                  hold: true,
                                ),
                              )
                            : const SizedBox.shrink(),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                ],
              ),
            ),
          );
        });
  }
}
