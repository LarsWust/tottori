import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tottori/classes/tottori_track.dart';
import 'package:tottori/classes/tottori_track_data.dart';
import 'package:tottori/classes/tottori_user.dart';
import 'package:tottori/components/box_button.dart';
import 'package:tottori/components/box_button_type.dart';
import 'package:tottori/components/profile_picture.dart';
import 'package:tottori/helpers/time_format.dart';
import 'package:tottori/main.dart';

class TrackCard extends StatefulWidget {
  final TottoriTrack track;
  String? tag;
  TottoriTrackData? data;
  TrackCard({super.key, required this.track, this.tag, this.data});

  Stream<TottoriTrackData> getData() {
    // if (data != null) {
    //   return Stream.value(data!);
    // } else {
    return track.dataStream;
    // }
  }

  @override
  State<TrackCard> createState() => _TrackCardState();
}

class _TrackCardState extends State<TrackCard> {
  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: SafeArea(
        child: Dialog(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: StreamBuilder(
                stream: widget.getData(),
                initialData: widget.data ?? TottoriTrack.defaultData,
                builder: (context, track) {
                  if (track.connectionState == ConnectionState.waiting && widget.data != null) {
                    track = AsyncSnapshot.withData(ConnectionState.active, widget.data!);
                  }
                  Widget svg = track.data!.svgPicture(context);
                  bool owned = track.data!.owner.uuid == user?.uid;
                  return FutureBuilder(
                      initialData: TottoriUser.defaultData,
                      future: track.data!.owner.data,
                      builder: (context, user) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 60,
                                  height: 60,
                                  child: ProfilePicture.image(
                                    image: user.data!.pfp,
                                    expanable: true,
                                  ),
                                ),
                                const SizedBox(
                                  width: 16,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      user.data!.displayName,
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                    Text(
                                      " • ${ago(track.data!.created.toDate())} ago",
                                      style: Theme.of(context).textTheme.labelMedium,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Container(
                              transform: Matrix4.translationValues(0, -20, 0),
                              child: AspectRatio(
                                aspectRatio: 1,
                                child: widget.tag == null
                                    ? svg
                                    : Hero(
                                        tag: widget.tag!,
                                        child: svg,
                                      ),
                              ),
                            ),
                            const Divider(
                              height: 0,
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            Center(
                              child: Text(
                                track.data!.title,
                                style: Theme.of(context).textTheme.headlineSmall,
                              ),
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            track.data!.caption.isNotEmpty
                                ? Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border.fromBorderSide(
                                          BorderSide(
                                            color: Theme.of(context).colorScheme.onSurface,
                                            width: 1,
                                          ),
                                        ),
                                        borderRadius: const BorderRadius.all(
                                          Radius.circular(10),
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          track.data!.caption,
                                          style: Theme.of(context).textTheme.bodyMedium,
                                        ),
                                      ),
                                    ),
                                  )
                                : const SizedBox.shrink(),
                            Row(
                              children: [
                                Flexible(
                                  child: BoxButton(
                                    onTap: () {},
                                    icon: Icons.thumb_up_alt,
                                    title: "Like",
                                  ),
                                ),
                                Flexible(
                                  child: BoxButton(
                                    onTap: () {},
                                    icon: Icons.add,
                                    title: "Add",
                                  ),
                                ),
                                Flexible(
                                  child: BoxButton(
                                    onTap: () async {
                                      if (track.data != null && track.data!.svg != null) {
                                        File? tot = await widget.track.getTot(name: track.data!.title);
                                        if (tot != null) {
                                          await Share.shareXFiles([XFile(tot.path)], subject: '"${track.data!.title}" on Tottori');
                                        }
                                      }
                                    },
                                    icon: Icons.ios_share,
                                    title: "Share",
                                  ),
                                ),
                                owned
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
                                                  TextEditingController captionController = TextEditingController(text: track.data!.caption);
                                                  TextEditingController titleController = TextEditingController(text: track.data!.title);
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
                                                              tag: widget.tag ?? "",
                                                              child: Expanded(
                                                                child: AspectRatio(
                                                                  aspectRatio: 1,
                                                                  child: svg,
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
                                                                await widget.track.updateData(title: titleController.text, caption: captionController.text);
                                                                widget.data = null;
                                                                setState(() {});
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
                                          title: "Edit",
                                          type: BoxButtonType.normal,
                                        ),
                                      )
                                    : Flexible(
                                        flex: 1,
                                        child: Container(),
                                      ),
                              ],
                            ),
                            owned
                                ? Row(
                                    children: [
                                      Flexible(flex: 3, child: Container()),
                                      Flexible(
                                        child: BoxButton(
                                          onTap: () async {
                                            await widget.track.delete();
                                            if (context.mounted) {
                                              Navigator.of(context).pop();
                                            }
                                          },
                                          icon: Icons.delete_forever,
                                          title: "Delete",
                                          type: BoxButtonType.normal,
                                        ),
                                      ),
                                    ],
                                  )
                                : const SizedBox.shrink(),
                          ],
                        );
                      });
                }),
          ),
        ),
      ),
    );
  }
}
